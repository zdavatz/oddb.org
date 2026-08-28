#!/bin/sh
# Tests how scripts/pg_backup.sh finds its password.
#
#   sh test/test_bin/pg_backup.sh
#
# Nicht Teil von test/suite.rb, das minitest gegen src/ laeuft. Geprueft wird
# der echte Block aus dem Skript - mit sed herausgeschnitten und ausgefuehrt -,
# damit Test und Skript nicht auseinanderlaufen koennen. Das Skript selbst
# aufzurufen ginge nicht: es wuerde ein Backup anlegen.
#
# Der Punkt dabei: oddb.yml wird *gelesen*, nicht eingelesen. Das Skript laeuft
# als root und die Datei gehoert dem Anwendungsbenutzer - ein "." darauf waere
# ein Weg von einer kompromittierten Anwendung zu root.

set -u

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
SCRIPT=$ROOT/scripts/pg_backup.sh
WORK=${TMPDIR:-/tmp}/oddb_pg_backup_test.$$
FAILURES=0

mkdir -p "$WORK" || exit 1
trap 'rm -rf "$WORK"' EXIT INT TERM

BLOCK=$(sed -n '/^ODDB_YML=/,/^postgresql_password=/p' "$SCRIPT")
[ -n "$BLOCK" ] || { echo "FAIL  Block nicht gefunden - Skript umgebaut?"; exit 1; }

# Liefert den Wert, den das Skript ermitteln wuerde.
found() {
  ( unset PGPASSWORD
    [ -n "${1:-}" ] && PGPASSWORD=$1
    ODDB_YML=$WORK/oddb.yml
    export ODDB_YML
    eval "$BLOCK"
    printf %s "$postgresql_password" )
}

t() {
  printf "db_password: %s\n" "$2" > "$WORK/oddb.yml"
  got=$(found "")
  if [ "$got" = "$3" ]; then
    echo "ok    $1"
  else
    echo "FAIL  $1: '$got' statt '$3'"
    FAILURES=$((FAILURES + 1))
  fi
}

t "unquotiert"          "geheim"            "geheim"
t "einfach quotiert"    "'geheim'"          "geheim"
t "doppelt quotiert"    '"geheim"'          "geheim"
t "mit Leerzeichen"     "'a b c'"           "a b c"
t "mit Doppelpunkt"     "'a:b#c'"           "a:b#c"
t "verdoppeltes Hochkomma" "'mit''hoch'"    "mit'hoch"

# Nichts wird ausgefuehrt - der Wert bleibt Text.
t "keine Kommandoersetzung" "'\$(id -u)'"   '$(id -u)'
t "keine Backticks"         "'\`id -u\`'"   '`id -u`'

# Kein Schluessel, keine Datei.
printf "smtp_port: 587\n" > "$WORK/oddb.yml"
got=$(found "")
[ -z "$got" ] && echo "ok    ohne db_password bleibt es leer" \
  || { echo "FAIL  ohne db_password kam '$got'"; FAILURES=$((FAILURES + 1)); }

rm -f "$WORK/oddb.yml"
got=$(found "")
[ -z "$got" ] && echo "ok    ohne Datei bleibt es leer" \
  || { echo "FAIL  ohne Datei kam '$got'"; FAILURES=$((FAILURES + 1)); }

# Die Umgebung hat Vorrang und die Datei wird dann gar nicht erst gelesen.
printf "db_password: 'aus-datei'\n" > "$WORK/oddb.yml"
got=$(found "aus-umgebung")
[ "$got" = "aus-umgebung" ] && echo "ok    Umgebung hat Vorrang" \
  || { echo "FAIL  Umgebung ergab '$got'"; FAILURES=$((FAILURES + 1)); }

# Und das Skript darf kein Passwort mehr enthalten.
if grep -qE "^PGPASSWORD=['\"]?[^\$'\"[:space:]]" "$SCRIPT"; then
  echo "FAIL  scripts/pg_backup.sh weist PGPASSWORD einen festen Wert zu"
  FAILURES=$((FAILURES + 1))
else
  echo "ok    Skript traegt kein Passwort"
fi

echo
if [ "$FAILURES" = "0" ]; then
  echo "alle Pruefungen bestanden"
else
  echo "$FAILURES Pruefung(en) fehlgeschlagen"
fi
exit $FAILURES
