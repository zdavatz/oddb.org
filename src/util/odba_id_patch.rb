#!/usr/bin/env ruby

# Die odba_id kommt aus einer Postgres-Sequenz, nicht aus einem Zaehler je
# Prozess.
#
# ODBA::Storage#next_id war `@next_id += 1` unter einem Mutex, und @next_id
# wurde einmal beim Start aus `SELECT odba_id FROM object ORDER BY odba_id
# DESC LIMIT 1` gesetzt. Der Mutex schuetzt innerhalb eines Prozesses; hier
# laufen aber vier Rack-Backends und dazu jeder Job mit einem eigenen
# Zaehler. Zwei Prozesse, die gleichzeitig Objekte anlegen, vergeben
# dieselben ids - nachgemessen am 31.08.2026, zwei Prozesse nebeneinander:
#
#   PROZESS 1644841 ids=[61935067, 61935068, 61935069]
#   PROZESS 1644842 ids=[61935067, 61935068, 61935069]
#
# Wer zuletzt schreibt, ueberschreibt die Zeile des anderen in `object`. Der
# Verweis darauf bleibt bestehen und zeigt danach auf ein fremdes Objekt.
# Genau das war der Schaden, den wir wochenlang einzeln repariert haben:
# eine Array in @sequences eines Patinfo, die zu einem PatinfoDocument
# wurde, dasselbe in @change_log eines Dokuments, 30 Zeilen im
# Pointer-Index, die auf Array oder Hash zeigten. Das Dokument lag immer 1
# bis 16 ids nach seinem Patinfo - derselbe Importlauf.
#
# ODBA::Cache#next_id hatte dagegen eine Sicherung, und die war wirkungslos:
#
#   @peers.each { |peer| peer.reserve_next_id id rescue DRb::DRbError }
#   ...
#   rescue OdbaDuplicateIdError
#     retry
#
# reserve_next_id wirft auf dem Peer OdbaDuplicateIdError, wenn die id schon
# vergeben ist - aber das `rescue` ohne Klasse faengt jeden StandardError,
# also auch diesen, und liefert die Klasse als Wert zurueck. Das `retry`
# konnte nie greifen. In odba 1.2.0/1.2.1 ist daraus ein Block-rescue
# geworden, immer noch ohne Klasse; ein Upgrade hilft also nicht.
#
# Beides wird hier geradegerueckt: die Sequenz vergibt prozessuebergreifend,
# und der Peer-Konflikt fuehrt wieder zu einem neuen Versuch.

require "odba/cache"
require "odba/storage"

# Seit odba 1.2.2 steckt beides im Gem selbst (Storage#id_sequence? und
# das auf DRb::DRbError eingegrenzte rescue in Cache#next_id). Dann ist
# hier nichts zu tun - der Patch bleibt nur liegen, damit ein Rueckschritt
# auf 1.1.9 nicht still den Fehler zurueckholt und readonlyd seinen
# require behaelt.
return if ODBA::Storage.method_defined?(:id_sequence?)

module ODBA
  class Storage
    ID_SEQUENCE = "odba_id_seq"

    # Der Abstand beim Anlegen: Prozesse, die in diesem Moment noch mit
    # ihrem alten Zaehler laufen, haben ids im Speicher, die noch nicht in
    # `object` stehen. Die Sequenz startet darueber, damit sie nicht in
    # deren Bereich hineinvergibt. Uebersprungene Zahlen kosten nichts - die
    # odba_id ist ein Surrogatschluessel und traegt keine Bedeutung.
    ID_SEQUENCE_GAP = 100_000

    def ensure_id_sequence
      return if @odba_id_sequence_ready
      dbi.do(<<~SQL)
        DO $$
        BEGIN
          IF NOT EXISTS (SELECT 1 FROM pg_class
                         WHERE relkind = 'S' AND relname = '#{ID_SEQUENCE}') THEN
            EXECUTE format('CREATE SEQUENCE #{ID_SEQUENCE} START WITH %s',
                           (SELECT COALESCE(MAX(odba_id), 0) + #{ID_SEQUENCE_GAP}
                            FROM object));
          END IF;
        END $$;
      SQL
      @odba_id_sequence_ready = true
    end

    def next_id
      ensure_id_sequence
      id = dbi.select_one("SELECT nextval('#{ID_SEQUENCE}')").first.to_i
      # @next_id bleibt gepflegt, weil max_id und reserve_next_id ihn lesen.
      @id_mutex.synchronize {
        @next_id = id if @next_id.nil? || @next_id < id
      }
      id
    end
  end

  class Cache
    def next_id
      id = if @file_lock
        dbname = ODBA.storage.instance_variable_get(:@dbi).dbi_args.first.split(":").last
        new_id(dbname, ODBA.storage)
      else
        ODBA.storage.next_id
      end
      @peers.each { |peer|
        begin
          peer.reserve_next_id(id)
        rescue DRb::DRbError
          # Ein Peer, den wir nicht erreichen, darf die Vergabe nicht
          # aufhalten - das war die Absicht der Zeile im Original. Nur darf
          # sie OdbaDuplicateIdError nicht mitverschlucken: der muss nach
          # oben, damit das retry eine neue id holt.
        end
      }
      id
    rescue OdbaDuplicateIdError
      # Die naechste id aus der Sequenz ist echt groesser, der Lauf endet.
      retry
    end
  end
end
