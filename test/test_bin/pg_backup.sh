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

# Die Datenbankliste wird aus psqls Ausgabe geparst, und die Fusszeile wird
# dabei beim Namen erkannt: unter de_CH.UTF-8 heisst sie "(4 Zeilen)" und nicht
# "(4 rows)", rutscht durch das grep und awk gibt "(4" als Datenbanknamen
# zurueck - jede Nacht ein 14 Byte grosser Dump "(4-backup.bz2" neben den
# echten. Der psql-Aufruf ist deshalb auf LC_ALL=C festgenagelt; nimmt man das
# heraus, antwortet der Stub hier deutsch und die Pruefung faellt um.
CONN=$(sed -n '/^db_connectivity() {/,/^}/p' "$SCRIPT")
if [ -z "$CONN" ]; then
  echo "FAIL  db_connectivity nicht gefunden - Skript umgebaut?"
  FAILURES=$((FAILURES + 1))
else
  mkdir -p "$WORK/bin"
  cat > "$WORK/bin/psql" <<'STUB'
#!/bin/sh
# So antwortet psql wirklich: uebersetzt wird nur die Fusszeile.
if [ "${LC_ALL:-}" = "C" ]; then footer="(4 rows)"; else footer="(4 Zeilen)"; fi
cat <<OUT
 datname
----------
 postgres
 ch_oddb
 migel
 yus
$footer
OUT
STUB
  chmod 755 "$WORK/bin/psql"

  db_list() {
    ( PGBINDIR=$WORK/bin
      PARAM_PGHOST=
      PGUSER=postgres
      PGLOGDIR=$WORK/psql.log
      timeinfo=jetzt
      exclusions=${1:-}
      eval "$CONN"
      db_connectivity
      echo $databases )
  }

  got=$(db_list)
  if [ "$got" = "ch_oddb migel yus" ]; then
    echo "ok    Datenbankliste ohne Fusszeile"
  else
    echo "FAIL  Datenbankliste: '$got' statt 'ch_oddb migel yus'"
    FAILURES=$((FAILURES + 1))
  fi

  got=$(db_list "migel")
  if [ "$got" = "ch_oddb yus" ]; then
    echo "ok    Ausschluss greift weiterhin"
  else
    echo "FAIL  mit Ausschluss: '$got' statt 'ch_oddb yus'"
    FAILURES=$((FAILURES + 1))
  fi
fi

echo
if [ "$FAILURES" = "0" ]; then
  echo "alle Pruefungen bestanden"
else
  echo "$FAILURES Pruefung(en) fehlgeschlagen"
fi
exit $FAILURES
