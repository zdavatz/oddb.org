#!/usr/bin/env ruby

# ODDB::DeregistrationDates -- oddb.org -- 01.09.2026
#
# Wann wurde eine Registrierung de-registriert? `inactive_date` sollte das
# sagen, tut es aber nicht immer: am 27.09.2017 hat ein einmaliger
# Aufraeumjob (`jobs/fix_expired_packages`, inzwischen entfernt) 2089
# Registrierungen auf einen Schlag deaktiviert und dabei `inactive_date`
# auf *den Tag des Laufs* gesetzt. Das Datum sagt seither, wann wir
# aufgeraeumt haben, nicht wann Swissmedic die Zulassung strich - bei
# Cardiolite 1318 Tage daneben.
#
# Die Quelle fuer das richtige Datum liegt im Haus: `data/xls/` haelt 241
# Swissmedic-Packungslisten von 2014-01-23 bis heute. Faellt eine IKSNR
# zwischen zwei Listen heraus, ist sie spaetestens am Tag der spaeteren
# Liste weg. Genauer geht es nicht - zwischen zwei Listen liegt ein Monat -
# und das ist immer noch drei Jahre genauer als der Aufraeumtag.
#
# Grenzen, beide gemessen:
#
#   * Die Listen beginnen 2014-01-23. Wer vorher verschwand, ist so nicht
#     datierbar (4053 von 6824 inaktiven). Fuer die bleibt
#     `expiration_date`, und das ist eine andere Tatsache - das nominelle
#     Ende der Zulassung, nicht der Tag des Verschwindens.
#   * Aus der Packungsliste zu fallen heisst nicht "Zulassung widerrufen".
#     41 aktive Registrierungen sind verschwunden, obwohl ihre Zulassung
#     bis 2028/2029 laeuft - alle mit null Packungen: zugelassen, aber
#     nicht vermarktet. Diese Klasse fasst der Job nicht an, er korrigiert
#     nur Daten an bereits inaktiven Registrierungen.
#
# `manual_inactive_date` bleibt unberuehrt: das ist eine Entscheidung von
# Hand und keine Messung.

require "date"
require "zip"

module ODDB
  class DeregistrationDates
    # Beide Formate: Swissmedic hat bis Ende 2013 .xls geliefert, seit 2014
    # .xlsx. Zusammen decken sie 2008-03-28 bis heute ab.
    SNAPSHOT_GLOB = "Packungen-*.xls{,x}"
    SHEET = "xl/worksheets/sheet1.xml"
    # Kopfzeilen der Swissmedic-Datei; die Daten beginnen bei 7.
    FIRST_DATA_ROW = 7
    # Unterhalb dessen ist die Abweichung der Monatsraster der Listen und
    # keine Korrektur wert.
    TOLERANCE_DAYS = 45

    attr_reader :counts, :dates, :index, :changes

    # index: { "00450" => Date } - letztes Auftreten je IKSNR.
    # dates: alle Snapshot-Daten, sortiert.
    def initialize(index, dates, opts = {})
      @index = index
      @dates = dates.sort
      @apply = opts[:apply]
      @undo_log = opts[:undo_log]
      @counts = Hash.new(0)
      @undo = []
      # Was geaendert wuerde, auch im Trockenlauf - eine Zahl allein
      # laesst sich nicht nachpruefen.
      @changes = []
    end

    def self.from_directory(dir)
      index = {}
      dates = []
      Dir.glob(File.join(dir, SNAPSHOT_GLOB), File::FNM_EXTGLOB).sort.each { |path|
        date = date_of(path)
        next unless date
        dates << date
        iksnrs_in(path).each { |iksnr|
          index[iksnr] = date if index[iksnr].nil? || index[iksnr] < date
        }
      }
      new(index, dates)
    end

    # Packungen-2026.08.06.xlsx -> Date. Packungen-latest.xlsx traegt kein
    # Datum und wird uebergangen - es ist eine Kopie der neuesten Liste.
    def self.date_of(path)
      File.basename(path)[/Packungen-(\d{4})\.(\d{2})\.(\d{2})\.xlsx?\z/] or return nil
      Date.new($1.to_i, $2.to_i, $3.to_i)
    end

    # Aus einer Zelle der Spalte A eine IKSNR machen, oder nil. Die Formate
    # sind uneinheitlich, und zwar innerhalb der .xls-Reihe: bis 2013 steht
    # dort Text mit fuehrender Null ("08537"), danach eine Zahl (274.0),
    # und im .xlsx eine Zahl ohne fuehrende Null. Kopfzeilen fallen von
    # selbst weg, weil sie diesem Muster nicht entsprechen.
    def self.iksnr_from(value)
      text = value.is_a?(Numeric) ? value.to_i.to_s : value.to_s.strip
      text = text.sub(/\.0\z/, "")
      return nil unless /\A0*\d{1,5}\z/.match?(text)
      number = text.to_i
      return nil if number.zero?
      "%05d" % number
    end

    # Nur Spalte A, und ohne den XLSX-Leser: RubyXL braucht 16 Sekunden je
    # Datei, das Lesen der Zellen aus dem entpackten XML 0.3 - bei 241
    # Dateien der Unterschied zwischen einer Stunde und einer Minute.
    #
    # Die IKSNR steht dort als blanke Zahl: `00450` ist `<v>450</v>`. Die
    # fuehrende Null fehlt in der Datei und muss ergaenzt werden, sonst
    # findet man die 199 alten Registrierungen nicht wieder, die mit einer
    # Null beginnen (00268 M-M-R-II, 00300 Serocytol, 08671 Alka-Seltzer).
    def self.iksnrs_in(path)
      return iksnrs_in_xls(path) if File.extname(path) == ".xls"
      found = {}
      Zip::File.open(path) { |zip|
        entry = zip.find_entry(SHEET) or return found.keys
        entry.get_input_stream.read.scan(/<c r="A(\d+)"[^>]*><v>(\d+)</) { |row, value|
          next if row.to_i < FIRST_DATA_ROW
          nr = iksnr_from(value) and found[nr] = true
        }
      }
      found.keys
    end

    # Das alte Format ist kein Zip, hier hilft nur ein Excel-Leser. Rund
    # eine Sekunde je Datei - bei 108 Dateien vertretbar, und es sind die
    # Jahre 2008 bis 2013, die sonst ganz fehlen.
    def self.iksnrs_in_xls(path)
      require "spreadsheet"
      Spreadsheet.client_encoding = "UTF-8"
      found = {}
      Spreadsheet.open(path) { |book|
        book.worksheet(0).each { |row|
          nr = iksnr_from(row[0]) and found[nr] = true
        }
      }
      found.keys
    end

    # Der erste Snapshot nach dem letzten Auftritt: bis dahin war sie da,
    # dort nicht mehr. nil, wenn sie noch in der neuesten Liste steht oder
    # nie in einer stand.
    def deregistered_on(iksnr)
      last = @index[iksnr.to_s] or return nil
      @dates.find { |date| date > last }
    end

    def run(registrations)
      registrations.each { |reg| examine(reg) }
      flush_undo
      @counts
    end

    def examine(reg)
      return tally(:aktiv) unless reg.inactive?
      # Von Hand gesetzt heisst entschieden, nicht gemessen.
      return tally(:manuell) if reg.manual_inactive_date
      current = reg.inactive_date
      return tally(:ohne_datum) unless current.respond_to?(:year)
      truth = deregistered_on(reg.iksnr)
      return tally(:nicht_datierbar) if truth.nil?
      diff = (current - truth).to_i
      return tally(:stimmt) if diff.abs <= TOLERANCE_DAYS
      # Frueher als der Beleg heisst, dass jemand mehr wusste als die
      # Liste - das ueberschreiben wir nicht.
      return tally(:frueher_als_beleg) if diff.negative?
      tally(:korrigiert)
      @changes.push([reg.iksnr, current, truth, diff])
      @undo.push("#{reg.iksnr}\t#{current}\t#{truth}")
      if @apply
        reg.inactive_date = truth
        reg.odba_isolated_store
      end
      truth
    rescue => error
      tally(:fehler)
      nr = begin
        reg.iksnr
      rescue
        "?"
      end
      LogFile.debug("DeregistrationDates #{nr}: #{error.class} #{error.message}")
      nil
    end

    def tally(key)
      @counts[key] += 1
      nil
    end

    def flush_undo
      return if @undo.empty? || @undo_log.nil? || !@apply
      File.open(@undo_log, "a") { |file| file.puts(@undo) }
      @undo.clear
    end

    def report
      puts @apply ? "=== angewendet ===" : "=== Trockenlauf, nichts geschrieben ==="
      @counts.sort_by { |_key, count| -count }.each { |key, count|
        puts format("  %-20s %7d", key, count)
      }
      return if @changes.empty?
      puts
      puts "=== groesste Verschiebungen ==="
      @changes.sort_by { |_, _, _, diff| -diff }.first(10).each { |iksnr, from, to, diff|
        puts format("  %-6s %s -> %s  (%d Tage frueher)", iksnr, from, to, diff)
      }
      puts
      puts "=== verschobene Daten nach Jahr ==="
      by_year = @changes.group_by { |_, _, to, _| to.year }
      by_year.sort.each { |year, rows| puts format("  %s  %5d", year, rows.size) }
    end
  end
end
