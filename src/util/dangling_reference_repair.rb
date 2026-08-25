#!/usr/bin/env ruby

# ODDB::DanglingReferenceRepair -- oddb.org -- 2026
#
# Setzt Verweise auf Objekte zurueck, die es nicht mehr gibt.
#
# 7614 Kanten in object_connection zeigen auf eine odba_id, unter der in object
# keine Zeile steht. Der haeufigste Fall sind 3950 Packungen mit einem
# @sl_entry-Stub auf einen geloeschten SlEntry und 141 mit einem toten @parts.
# Jeder Zugriff darauf wirft ODBA::OdbaError - package.limitation und
# package.limitation_text scheitern heute an 292 von 300 Stichproben, waehrend
# Preis, Selbstbehalt und Name aus anderen Feldern kommen und funktionieren.
#
# Aufraeumen und nicht wiederherstellen ist hier richtig: von 3924 betroffenen
# Packungen stehen nur 135 ueberhaupt noch im BAG-Export, die restlichen 3789
# sind nicht mehr in der Spezialitaetenliste. Der Verweis ist also nicht nur
# kaputt, er ist auch gegenstandslos. Kommt eine Packung zurueck in die SL,
# setzt der naechste BSV-Import @sl_entry ohnehin neu.
#
# Die Form bleibt erhalten: ein Stub, der eine Array-Klasse deklariert, wird zu
# [], alles andere zu nil - damit sich Code, der @parts.is_a?(Array) fragt,
# weiter gleich verhaelt.
#
# Die Liste der haengenden Kanten kommt von aussen:
#
#   SELECT c.origin_id, c.target_id FROM object_connection c
#   WHERE NOT EXISTS (SELECT 1 FROM object o WHERE o.odba_id = c.target_id);
#
# Ob das Ziel wirklich fehlt, prueft der Job selbst noch einmal nach - die
# Datei sagt nur, wo er suchen soll.

require "util/logfile"

module ODDB
  class DanglingReferenceRepair
    attr_reader :counts

    def initialize(app, opts = {})
      @app = app
      @apply = opts[:apply]
      @undo_log = opts[:undo_log]
      @counts = Hash.new(0)
      @undo = []
    end

    def run(pairs)
      by_object = Hash.new { |hash, key| hash[key] = [] }
      pairs.each { |origin, target| by_object[origin].push(target) }
      by_object.each_with_index do |(odba_id, targets), index|
        repair(odba_id, targets)
        report_progress(index + 1) if ((index + 1) % 500).zero?
      end
      flush_undo
      report
      @counts
    end

    def repair(odba_id, targets)
      object = ODBA.cache.fetch(odba_id, nil)
      # Nur Modellobjekte. Unter den haengenden Kanten sitzen auch Interna von
      # ODBA selbst - @rebuilt, @failures, @to_drop, @deffered_indices auf
      # Index- und Cache-Objekten. Deren Aufraeumen ist Sache von
      # jobs/rebuild_indices, nicht dieses Jobs.
      unless object.class.to_s.start_with?("ODDB::")
        return tally(:"uebersprungen_#{object.class.to_s.split("::").first}")
      end
      tally(:"klasse_#{object.class.to_s.split("::").last}")
      cleared = []
      object.instance_variables.each do |name|
        var = object.instance_variable_get(name)
        next unless var.is_a?(ODBA::Stub)
        next unless targets.include?(var.odba_id)
        next unless really_missing?(var.odba_id)
        object.instance_variable_set(name, empty_for(var))
        cleared.push("#{name}=#{var.odba_id}")
        tally(name.to_s.delete("@").to_sym)
      end
      return tally(:nichts_zu_tun) if cleared.empty?
      tally(:objekte_bereinigt)
      @undo.push("#{odba_id} #{cleared.join(" ")}")
      object.odba_isolated_store if @apply
    rescue => error
      tally(:fehler)
      LogFile.debug("DanglingReferenceRepair #{odba_id}: #{error.class} #{error.message}")
    end

    # Nicht der Eingabedatei glauben: zwischen ihrer Erzeugung und diesem Lauf
    # kann ein Import das Ziel angelegt haben.
    def really_missing?(target_id)
      ODBA.storage.restore(target_id).nil?
    rescue
      true
    end

    # Ein Stub kennt die Klasse, die er vertritt, ohne aufzuloesen - was hier
    # der einzige Weg ist, denn aufloesen laesst er sich ja gerade nicht.
    def empty_for(stub)
      klass = stub.instance_variable_get(:@odba_class)
      return [] if klass == Array
      return {} if klass == Hash
      nil
    end

    def tally(key)
      @counts[key] += 1
      nil
    end

    def report_progress(done)
      warn "#{done} Objekte bearbeitet, #{@counts[:objekte_bereinigt]} bereinigt"
      flush_undo
    end

    def flush_undo
      return if @undo.empty? || @undo_log.nil? || !@apply
      File.open(@undo_log, "a") { |file| file.puts(@undo) }
      @undo.clear
    end

    def report
      puts @apply ? "=== angewendet ===" : "=== Trockenlauf, nichts geschrieben ==="
      @counts.sort_by { |_key, count| -count }.each { |key, count|
        puts format("  %-24s %7d", key, count)
      }
    end
  end
end
