#!/bin/sh
# Tests the pg_backup.sh precondition in bin/install_crontab.
#
#   sh test/test_bin/install_crontab.sh
#
# Not part of test/suite.rb, which runs minitest against src/. What matters
# here cannot be seen in production without breaking it: the versioned
# scripts/pg_backup.sh carries no password, so installing it over the current
# one before /etc/oddb/pg_backup.conf exists would turn the nightly backup
# into a silent failure. Four cases - missing, wrong mode, empty, good.
#
# id and install are replaced by stubs on PATH, so nothing here needs root and
# nothing is written outside the work directory. PG_BACKUP_CONF points the
# script at a temporary file instead of /etc.

set -u

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
SCRIPT=$ROOT/bin/install_crontab
WORK=${TMPDIR:-/tmp}/oddb_install_crontab_test.$$
FAILURES=0

mkdir -p "$WORK/bin" || exit 1
trap 'rm -rf "$WORK"' EXIT INT TERM

# Root vortaeuschen, ohne root zu sein.
cat > "$WORK/bin/id" <<'STUB'
#!/bin/sh
[ "${1:-}" = "-u" ] && { echo 0; exit 0; }
exec /usr/bin/id "$@"
STUB

# Nichts wirklich installieren - nur aufschreiben, was installiert wuerde.
cat > "$WORK/bin/install" <<'STUB'
#!/bin/sh
for arg in "$@"; do
  case "$arg" in /*) last=$arg ;; esac
done
echo "$last" >> "$INSTALLED"
STUB

chmod 755 "$WORK/bin/id" "$WORK/bin/install"
PATH="$WORK/bin:$PATH"
export PATH

run() {
  INSTALLED=$WORK/installed
  export INSTALLED
  : > "$INSTALLED"
  OUT=$(PG_BACKUP_CONF="$1" sh "$SCRIPT" 2>&1)
  RC=$?
}

check() {
  if [ "$2" = "$3" ]; then
    echo "ok    $1"
  else
    echo "FAIL  $1: erwartet '$3', bekommen '$2'"
    FAILURES=$((FAILURES + 1))
  fi
}

contains() {
  case "$2" in
    *"$3"*) echo "ok    $1" ;;
    *) echo "FAIL  $1: '$3' fehlt in der Ausgabe"; FAILURES=$((FAILURES + 1)) ;;
  esac
}

# 1. Keine Zugangsdatei - pg_backup.sh wird uebersprungen, Status 1.
run "$WORK/nicht-da.conf"
check "fehlende conf meldet sich" "$RC" "1"
contains "fehlende conf nennt den Grund" "$OUT" "is missing"
contains "fehlende conf sagt, wie man sie anlegt" "$OUT" "install -d -m 700"

# 2. Da, aber fuer alle lesbar - das Passwort gehoert nicht in ein 644.
conf=$WORK/pg_backup.conf
printf "PGPASSWORD='geheim'\n" > "$conf"
chmod 644 "$conf"
run "$conf"
check "644 wird abgelehnt" "$RC" "1"
contains "644 nennt den Modus" "$OUT" "mode 644"

# 3. Richtiger Modus, aber ohne Wert.
: > "$conf"
chmod 600 "$conf"
run "$conf"
check "leere conf wird abgelehnt" "$RC" "1"
contains "leere conf nennt den Grund" "$OUT" "sets no PGPASSWORD"

# 4. Alles da - jetzt gehoert pg_backup.sh in die Liste.
printf "PGPASSWORD='geheim'\n" > "$conf"
chmod 600 "$conf"
run "$conf"
check "gute conf laeuft durch" "$RC" "0"
contains "gute conf nimmt pg_backup.sh auf" "$OUT" "/usr/local/sbin/pg_backup.sh"
case "$OUT" in
  *SKIP*) echo "FAIL  gute conf darf nichts ueberspringen"; FAILURES=$((FAILURES + 1)) ;;
  *) echo "ok    gute conf ueberspringt nichts" ;;
esac

# Und das Passwort darf in keinem Fall in der Ausgabe stehen.
case "$OUT" in
  *geheim*) echo "FAIL  Passwort steht in der Ausgabe"; FAILURES=$((FAILURES + 1)) ;;
  *) echo "ok    Passwort bleibt aus der Ausgabe" ;;
esac

# Auch nicht ueber den angezeigten Diff: die abgeloeste pg_backup.sh traegt
# ihres im Klartext, und ein blosser Probelauf zeigte es auf dem Terminal.
old=$WORK/alt.sh
new=$WORK/neu.sh
printf "PGPASSWORD='streng-geheim'\nAPI_KEY = abc123\nharmlos\n" > "$old"
printf "PGPASSWORD=\"$(printf x)\"\nharmlos\n" > "$new"
# Der Ausdruck ist hier gespiegelt, nicht aufgerufen - die Zielpfade im Skript
# sind fest. Damit die Spiegelung nicht auseinanderlaeuft, wird gleich noch
# geprueft, dass das Skript denselben Ausdruck fuehrt.
REDACTED=$(diff -u "$old" "$new" \
  | sed -E "s/((PGPASSWORD|PASSWORD|SECRET|TOKEN|API_KEY)[[:space:]]*=[[:space:]]*).*/\\1<redacted>/I")
case "$REDACTED" in
  *streng-geheim*|*abc123*) echo "FAIL  Diff-Filter laesst Geheimnisse durch"; FAILURES=$((FAILURES + 1)) ;;
  *) echo "ok    Diff-Filter schwaerzt Passwort und Schluessel" ;;
esac
contains "Diff-Filter laesst harmlose Zeilen stehen" "$REDACTED" "harmlos"
if grep -q 'PGPASSWORD|PASSWORD|SECRET|TOKEN|API_KEY' "$SCRIPT"; then
  echo "ok    Skript fuehrt denselben Filter"
else
  echo "FAIL  Skript und Test verwenden verschiedene Filter"
  FAILURES=$((FAILURES + 1))
fi

echo
if [ "$FAILURES" = "0" ]; then
  echo "alle Pruefungen bestanden"
else
  echo "$FAILURES Pruefung(en) fehlgeschlagen"
fi
exit $FAILURES
