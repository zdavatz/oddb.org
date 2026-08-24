#!/bin/sh
# Tests bin/oddb_cron healthcheck.
#
#   sh test/test_bin/healthcheck.sh
#
# Not part of test/suite.rb, which runs minitest against src/. This exercises a
# shell script, and the interesting part of it cannot be observed in
# production: whether the escalation waits long enough. The backends restart
# themselves every hour or two once they pass MEMORY_LIMIT_CRAWLER, and a check
# that acted on those normal restarts would be worse than no check at all.
#
# curl, svc and svstat are replaced by stubs on PATH, so nothing here touches
# /etc/service or the running application.

set -u

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
SCRIPT=$ROOT/bin/oddb_cron
WORK=${TMPDIR:-/tmp}/oddb_healthcheck_test.$$
FAILURES=0

mkdir -p "$WORK/bin" || exit 1
trap 'rm -rf "$WORK"' EXIT INT TERM

cat > "$WORK/bin/curl" <<'STUB'
#!/bin/sh
# 000 for any port named in DEAD_PORTS, 200 otherwise - curl reports 000 when
# the connection is refused, which is the state a missing backend leaves behind.
for arg in "$@"; do
  case "$arg" in http://localhost:*) url=$arg ;; esac
done
port=$(echo "${url:-}" | sed 's#.*localhost:##; s#/.*##')
case " ${DEAD_PORTS:-} " in
  *" $port "*) printf 000 ;;
  *) printf 200 ;;
esac
STUB

cat > "$WORK/bin/svc" <<'STUB'
#!/bin/sh
echo "$1 $2" >> "$SVC_LOG"
STUB

cat > "$WORK/bin/svstat" <<'STUB'
#!/bin/sh
case " ${DOWN_SERVICES:-} " in
  *" $(basename "$1") "*) echo "$1: down 3 seconds" ;;
  *) echo "$1: up (pid 1) 99 seconds" ;;
esac
STUB

chmod +x "$WORK/bin/curl" "$WORK/bin/svc" "$WORK/bin/svstat"
PATH=$WORK/bin:$PATH
export PATH

# Runs the healthcheck n times against a fresh state directory.
# usage: run_minutes <case-name> <dead-ports> <down-services> <count>
run_minutes() {
  case_name=$1
  DEAD_PORTS=$2
  DOWN_SERVICES=$3
  count=$4
  ODDB_ROOT=$WORK/$case_name
  SVC_LOG=$WORK/$case_name.svc
  export DEAD_PORTS DOWN_SERVICES ODDB_ROOT SVC_LOG
  mkdir -p "$ODDB_ROOT/log/cron"
  : > "$SVC_LOG"
  i=0
  while [ "$i" -lt "$count" ]; do
    sh "$SCRIPT" healthcheck > "$WORK/$case_name.out" 2>&1
    i=$((i + 1))
  done
}

assert() {
  if [ "$2" = "$3" ]; then
    echo "  ok   $1"
  else
    echo "  FAIL $1: expected '$3', got '$2'"
    FAILURES=$((FAILURES + 1))
  fi
}

echo "a backend that answers is left alone"
run_minutes answers "" "" 6
assert "no svc call" "$(wc -l < "$WORK/answers.svc" | tr -d ' ')" "0"
assert "counter stays 0" "$(cat "$WORK/answers/log/cron/health/generika")" "0"

echo "a normal restart is not a fault"
# Two silent minutes, then back - a restarted process needs about forty
# seconds, so this is the ordinary cycle and must not trigger anything.
ODDB_ROOT=$WORK/restart SVC_LOG=$WORK/restart.svc DOWN_SERVICES=""
export ODDB_ROOT SVC_LOG DOWN_SERVICES
mkdir -p "$ODDB_ROOT/log/cron"
: > "$SVC_LOG"
DEAD_PORTS=8112 sh "$SCRIPT" healthcheck > /dev/null 2>&1
DEAD_PORTS=8112 sh "$SCRIPT" healthcheck > /dev/null 2>&1
assert "counter counts up" "$(cat "$WORK/restart/log/cron/health/google_crawler")" "2"
DEAD_PORTS= sh "$SCRIPT" healthcheck > /dev/null 2>&1
assert "counter resets" "$(cat "$WORK/restart/log/cron/health/google_crawler")" "0"
assert "no svc call" "$(wc -l < "$WORK/restart.svc" | tr -d ' ')" "0"
assert "recovery logged" \
  "$(grep -c 'back after 2 min' "$WORK"/restart/log/cron/healthcheck-*.log)" "1"

echo "a backend that stays silent is restarted, then killed"
run_minutes wedged 8512 "" 18
assert "three interventions in 18 min" "$(wc -l < "$WORK/wedged.svc" | tr -d ' ')" "3"
assert "first is TERM"  "$(sed -n 1p "$WORK/wedged.svc")" "-t /etc/service/generika"
assert "second is TERM" "$(sed -n 2p "$WORK/wedged.svc")" "-t /etc/service/generika"
assert "third is KILL"  "$(sed -n 3p "$WORK/wedged.svc")" "-k /etc/service/generika"
assert "nothing before the grace period" \
  "$(grep -c 'silent for [1-4] min,' "$WORK"/wedged/log/cron/healthcheck-*.log)" "0"

echo "a service taken down on purpose is left alone"
# svstat reports "down" only after somebody ran svc -d. That is a decision.
run_minutes disabled 8212 crawler 8
assert "no svc call" "$(wc -l < "$WORK/disabled.svc" | tr -d ' ')" "0"
assert "counter stays 0" "$(cat "$WORK/disabled/log/cron/health/crawler")" "0"

echo "one silent backend does not mask the others"
run_minutes mixed 8512 "" 6
assert "generika counted" "$(cat "$WORK/mixed/log/cron/health/generika")" "6"
assert "oddb unaffected" "$(cat "$WORK/mixed/log/cron/health/oddb")" "0"
assert "crawler unaffected" "$(cat "$WORK/mixed/log/cron/health/crawler")" "0"

echo
if [ "$FAILURES" -eq 0 ]; then
  echo "all healthcheck tests passed"
else
  echo "$FAILURES healthcheck test(s) failed"
fi
exit "$FAILURES"
