#!/usr/bin/env ruby

# ODDB::SupersededDocument -- oddb.org -- 27.08.2026
#
# Wenn eine Fach- oder Patienteninformation aktualisiert wird, baut der Parser
# ein neues Dokument, und SimpleLanguage#update_values setzt es an die Stelle
# des alten in @descriptions. Das alte Dokument haengt danach an nichts mehr -
# samt seinen rund zwanzig Kapiteln - und wurde bis August 2026 nie geloescht.
#
# Was daraus wurde: auf rund 6300 lebende Fachinfos kamen 200000 abgeloeste
# Dokumentfassungen und 3.95 Millionen Kapitel, zusammen 7.5 der 19 GB. Rund
# 20000 Dokumente im Jahr.
#
# Verloren geht dabei nichts, und das ist der Grund, warum man sie loeschen
# darf: store_fachinfo nimmt das change_log ins neue Dokument mit, und ein
# Diffy::Diff legt den vollstaendigen alten *und* neuen Text ab. Jeder Eintrag
# im change_log ist damit fuer sich schon eine ganze Fassung - angezeigt wird
# ohnehin nur die neueste.
#
# Zwei Bedingungen, beide notwendig:
#
#   * Das change_log wird nie angefasst. Es wird ins neue Dokument geklont,
#     die Eintraege haengen also an beiden. ODBA::Cache#delete kaskadiert
#     nicht - es loescht das Objekt und kappt die Verweise *auf* es -, aber
#     darauf verlassen wir uns nicht: die Liste wird vorher aus dem alten
#     Dokument genommen.
#   * Ein Kapitel, das das neue Dokument ebenfalls benutzt, bleibt. Der Parser
#     baut zwar jedes Kapitel neu, aber das ist eine Annahme ueber fremden
#     Code, und eine falsche Annahme kostete hier den Text eines lebenden
#     Praeparats.

require "util/logfile"

module ODDB
  module SupersededDocument
    # Loescht ein abgeloestes Dokument samt seinen Kapiteln. Gibt die Anzahl
    # geloeschter Objekte zurueck.
    def self.discard(old, successor = nil)
      return 0 unless persistable?(old)
      return 0 if successor && same_object?(old, successor)
      keep = chapter_ids(successor)
      count = 0
      chapters(old).each { |chapter|
        id = odba_id(chapter)
        next unless id
        next if keep.include?(id)
        count += 1 if delete(chapter)
      }
      # Die Historie aus dem Dokument nehmen, bevor es faellt.
      old.instance_variable_set(:@change_log, nil) if old.instance_variable_defined?(:@change_log)
      count += 1 if delete(old)
      count
    rescue => error
      LogFile.debug("SupersededDocument.discard: #{error.class} #{error.message}")
      0
    end

    # Nur echte, gespeicherte Dokumente. In @descriptions stehen bei den
    # meisten Modellen Zeichenketten - Substanznamen, galenische Formen -,
    # und die haben weder odba_id noch Kapitel.
    def self.persistable?(object)
      object.is_a?(ODDB::Persistence) && !odba_id(object).nil? && object.respond_to?(:chapters)
    rescue
      false
    end

    def self.same_object?(one, other)
      a = odba_id(one)
      b = odba_id(other)
      !a.nil? && a == b
    end

    def self.chapter_ids(document)
      return [] unless document
      chapters(document).filter_map { |chapter| odba_id(chapter) }
    end

    # chapters gibt die Namen der Kapitel als Symbole zurueck; erst
    # document.send(name) liefert das Kapitel selbst.
    def self.chapters(document)
      return [] unless document.respond_to?(:chapters)
      names = begin
        Array(document.chapters)
      rescue
        []
      end
      names.filter_map { |name|
        next unless name.is_a?(Symbol) || name.is_a?(String)
        begin
          document.send(name)
        rescue
          nil
        end
      }
    end

    def self.odba_id(object)
      object.respond_to?(:odba_id) ? object.odba_id : nil
    rescue
      nil
    end

    def self.delete(object)
      return false unless odba_id(object)
      object.odba_delete
      true
    rescue => error
      LogFile.debug("SupersededDocument.delete #{odba_id(object)}: #{error.class} #{error.message}")
      false
    end
  end
end
