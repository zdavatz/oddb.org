#!/bin/sh
# Tests the SCHEDULE dispatcher in bin/oddb_cron.
#
#   sh test/test_bin/schedule.sh
#
# Not part of test/suite.rb, which runs minitest against src/. The thing worth
# checking here cannot be observed in production without waiting a day: that
# two entries sharing a minute run one after the other, in table order. That is
# what lets update_fachinfo_rss_feeds sit in the same 05:01 slot as
# update_today - the feed job must not start until update_today has released
# log/job.pid, or it would exit with "Duplicate Job" and the feed would keep
# yesterday's Fachinfos for another day.
#
# date, bundle, curl, svc and svstat are replaced by stubs on PATH, so nothing
# here touches the real jobs, the database or /etc/service.

set -u

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
SCRIPT=$ROOT/bin/oddb_cron
WORK=${TMPDIR:-/tmp}/oddb_schedule_test.$$
FAILURES=0

mkdir -p "$WORK/bin" "$WORK/root/log/cron" "$WORK/root/jobs" || exit 1
trap 'rm -rf "$WORK"' EXIT INT TERM

# Every job named in the schedule has to exist, or cmd_job exits 2.
for job in rebuild_indices update_today update_fachinfo_rss_feeds \
           update_drugshortage_hpc_dhcp import_bsv import_swissmedic \
           update_drugshortage import_whocc import_refdata_nat; do
  : > "$WORK/root/jobs/$job"
done

# Answers the four date formats the script asks for; the clock comes from
# FAKE_MIN/FAKE_HOUR/FAKE_DOM so a test can stand at any minute of the year.
cat > "$WORK/bin/date" <<'STUB'
#!/bin/sh
case "${1:-}" in
  +%-M) echo "${FAKE_MIN:-0}" ;;
  +%-H) echo "${FAKE_HOUR:-0}" ;;
  +%-d) echo "${FAKE_DOM:-1}" ;;
  +%Y-%m) echo "2026-08" ;;
  *) echo "2026-08-25 ${FAKE_HOUR:-0}:${FAKE_MIN:-0}:00 +0200" ;;
esac
STUB

# Records the order jobs are dispatched in. Sleeps briefly so that a dispatcher
# running them in parallel would interleave and the order file would show it.
cat > "$WORK/bin/bundle" <<'STUB'
#!/bin/sh
for arg in "$@"; do
  case "$arg" in jobs/*) echo "${arg#jobs/}" >> "$ORDER" ;; esac
done
sleep 0.2
exit "${JOB_EXIT:-0}"
STUB

# The healthcheck runs at the top of every schedule invocation. Keep it quiet.
cat > "$WORK/bin/curl" <<'STUB'
#!/bin/sh
printf 200
STUB
cat > "$WORK/bin/svc"    <<'STUB'
#!/bin/sh
exit 0
STUB
cat > "$WORK/bin/svstat" <<'STUB'
#!/bin/sh
echo "$1: up (pid 1) 99 seconds"
STUB

chmod +x "$WORK/bin/date" "$WORK/bin/bundle" "$WORK/bin/curl" "$WORK/bin/svc" "$WORK/bin/svstat"
PATH=$WORK/bin:$PATH
export PATH ODDB_ROOT=$WORK/root

# usage: run_at <minute> <hour> <day-of-month>
run_at() {
  FAKE_MIN=$1 FAKE_HOUR=$2 FAKE_DOM=$3
  ORDER=$WORK/order
  export FAKE_MIN FAKE_HOUR FAKE_DOM ORDER
  : > "$ORDER"
  sh "$SCRIPT" schedule > "$WORK/out" 2>&1
  echo $? > "$WORK/status"
}

assert() {
  if [ "$2" = "$3" ]; then
    echo "  ok   $1"
  else
    echo "  FAIL $1: expected '$3', got '$2'"
    FAILURES=$((FAILURES + 1))
  fi
}

echo "a minute with no entry runs nothing"
run_at 33 13 25
assert "no job dispatched" "$(wc -l < "$WORK/order" | tr -d ' ')" "0"
assert "exit 0"            "$(cat "$WORK/status")" "0"

echo "05:01 runs update_today and then the feed, in that order"
run_at 1 5 25
assert "two jobs"       "$(wc -l < "$WORK/order" | tr -d ' ')" "2"
assert "update_today first" "$(sed -n 1p "$WORK/order")" "update_today"
assert "feed second"        "$(sed -n 2p "$WORK/order")" "update_fachinfo_rss_feeds"

echo "the feed no longer runs in the evening"
run_at 1 19 25
assert "nothing at 19:01" "$(wc -l < "$WORK/order" | tr -d ' ')" "0"

echo "a day-of-month entry fires only on its day"
run_at 50 8 20
assert "import_whocc on the 20th" "$(cat "$WORK/order")" "import_whocc"
run_at 50 8 21
assert "nothing on the 21st" "$(wc -l < "$WORK/order" | tr -d ' ')" "0"

echo "a failing job is reported, and does not stop the next one"
JOB_EXIT=3 run_at 1 5 25
assert "both still ran" "$(wc -l < "$WORK/order" | tr -d ' ')" "2"
assert "exit 1"         "$(cat "$WORK/status")" "1"

echo "the log keeps each job's output"
run_at 1 5 25
assert "update_today logged" \
  "$(grep -c '=== update_today started' "$WORK"/root/log/cron/update_today-2026-08.log)" "3"
assert "feed logged" \
  "$(grep -c '=== update_fachinfo_rss_feeds started' "$WORK"/root/log/cron/update_fachinfo_rss_feeds-2026-08.log)" "3"

echo
if [ "$FAILURES" -eq 0 ]; then
  echo "all schedule tests passed"
else
  echo "$FAILURES schedule test(s) failed"
fi
exit "$FAILURES"
