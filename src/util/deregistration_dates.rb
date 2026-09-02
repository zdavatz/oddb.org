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
    # Der Tag, an dem `jobs/fix_expired_packages` (einmalig, 27.09.2017,
    # am 12.11.2025 aus dem Baum entfernt) 2089 Registrierungen auf einen
    # Schlag deaktiviert und ihnen `inactive_date: today` gegeben hat.
    # Sein Kriterium war `expiration_date < 2017-08` - das Verfalldatum
    # ist hier also nicht ein fremdes Feld, sondern der Ausloeser der
    # Deaktivierung, und damit der beste Beleg, den es fuer diese Gruppe
    # gibt. Nur fuer diesen einen Tag: die anderen grossen Tage
    # (2012-08-07, 2011-07-04, 2014-03-06 ...) sind normale Importtage in
    # der ersten Monatswoche, an denen der Import echt bemerkt hat, dass
    # etwas aus der Packungsdatei fiel - die sind aus den Snapshots
    # datierbar und brauchen diesen Rueckfall nicht.
    CLEANUP_DAY = Date.new(2017, 9, 27)

    attr_reader :counts, :dates, :index, :changes, :deactivations, :deleted

    # index: { "00450" => Date } - letztes Auftreten je IKSNR.
    # dates: alle Snapshot-Daten, sortiert.
    def initialize(index, dates, opts = {})
      @index = index
      @dates = dates.sort
      # Alles, was Swissmedic heute als Zulassung fuehrt. Leer heisst
      # "nicht geprueft" - dann deaktiviert #vanished nichts, denn ohne
      # diese Liste laesst sich eine Exportzulassung nicht erkennen.
      @authorised = opts[:authorised] || {}
      # { "46466" => Date } - fruehestes Flag 14 je IKSNR aus med-drugs.
      # Rueckfall fuer alles, was vor der ersten Packungsliste verschwand.
      @deleted = opts[:deleted] || {}
      @apply = opts[:apply]
      @undo_log = opts[:undo_log]
      @counts = Hash.new(0)
      @undo = []
      # Was geaendert wuerde, auch im Trockenlauf - eine Zahl allein
      # laesst sich nicht nachpruefen.
      @changes = []
      @deactivations = []
    end

    # Das Lesen der 349 Listen dauert acht Minuten, fast alles davon die
    # 108 alten .xls. Der Index haengt nur an den Dateien, und die aendern
    # sich einmal im Monat - also einmal lesen und ablegen. Der Stempel
    # zaehlt Dateien und nimmt die neueste mtime; kommt eine Liste dazu,
    # passt er nicht mehr und der Cache wird verworfen.
    CACHE = ".packungen_index.tsv"
    # Die zweite Quelle, und ohne sie ist die erste gefaehrlich: die
    # Praeparateliste fuehrt die *Zulassungen*, die Packungsliste nur die
    # Packungen. Eine Exportzulassung hat keine Packung fuer den Schweizer
    # Markt und steht deshalb nie in der Packungsliste - sie ist trotzdem
    # zugelassen. Am 01.09.2026 waren 369 von 987 Deaktivierungen genau
    # das und mussten zurueckgenommen werden.
    PREPARATIONS = "Präparateliste-latest.xlsx"
    # Die dritte Quelle, und sie reicht am weitesten zurueck: unsere eigenen
    # med-drugs-Exporte, 439 Stueck seit dem 13.10.2003. Jede ist eine
    # Aenderungsliste, und Flag 14 in Spalte A heisst :delete - der Tag, an
    # dem der Export eine Loeschung gemeldet hat. Das ist wieder ein
    # Beobachtungsdatum, aber ein zeitnahes (Wochen), nicht ein Aufraeumlauf
    # dreizehn Jahre spaeter. 930 Registrierungen, die in keiner
    # Packungsliste je standen, werden damit datierbar (Stand 01.09.2026).
    MED_DRUGS_GLOB = "med-drugs-*.xls"
    MED_DRUGS_CACHE = ".meddrugs_deleted.tsv"
    DELETE_FLAG = "14"

    def self.from_directory(dir, cache: true)
      paths = Dir.glob(File.join(dir, SNAPSHOT_GLOB), File::FNM_EXTGLOB).sort
      stamp = "#{paths.size}\t#{paths.collect { |p| File.mtime(p).to_i }.max}"
      cache_file = File.join(dir, CACHE)
      if cache && (cached = read_cache(cache_file, stamp))
        return cached
      end
      source = build(paths)
      write_cache(cache_file, stamp, source) if cache
      source
    end

    def self.read_cache(path, stamp)
      return nil unless File.exist?(path)
      lines = File.readlines(path, chomp: true)
      return nil unless lines.shift == stamp
      index = {}
      dates = []
      lines.each { |line|
        key, value = line.split("\t")
        (key == "!") ? dates << Date.parse(value) : index[key] = Date.parse(value)
      }
      new(index, dates)
    rescue
      nil
    end

    def self.write_cache(path, stamp, source)
      File.open(path, "w") { |file|
        file.puts(stamp)
        source.dates.each { |date| file.puts("!\t#{date}") }
        source.index.each { |key, date| file.puts("#{key}\t#{date}") }
      }
    rescue
      nil
    end

    def self.build(paths)
      index = {}
      dates = []
      paths.each { |path|
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

    # Die IKSNR aller heute gefuehrten Zulassungen, aus
    # Präparateliste-latest.xlsx. Gleicher Trick wie bei der Packungsliste:
    # Spalte A aus dem rohen Sheet-XML, das spart den XLSX-Leser.
    def self.authorised_in(dir)
      path = File.join(dir, PREPARATIONS)
      return {} unless File.exist?(path)
      found = {}
      Zip::File.open(path) { |zip|
        entry = zip.find_entry(SHEET) or return found
        entry.get_input_stream.read.scan(/<c r="A(\d+)"[^>]*><v>(\d+)</) { |row, value|
          next if row.to_i < FIRST_DATA_ROW
          nr = iksnr_from(value) and found[nr] = true
        }
      }
      found
    end

    # Fruehestes Loeschdatum je IKSNR aus den med-drugs-Exporten. Gecacht
    # wie der Packungsindex, aus demselben Grund: 439 .xls zu je einer
    # Sekunde.
    def self.deleted_in(dir, cache: true)
      paths = Dir.glob(File.join(dir, MED_DRUGS_GLOB)).sort
      # Zahl und juengster Name, nicht die mtime: med-drugs-20040115.xls ist
      # kaputt (RuntimeError beim Oeffnen), und Spreadsheet setzt ihr bei
      # jedem Versuch eine neue mtime - ein mtime-Stempel passte deshalb
      # nie zweimal, und der Cache wurde bei jedem Lauf neu gebaut (130 s).
      # Die datierten Namen sind unveraenderlich; ein neuer Export ist ein
      # neuer Name.
      stamp = "#{paths.size}\t#{File.basename(paths.last.to_s)}"
      cache_file = File.join(dir, MED_DRUGS_CACHE)
      if cache && File.exist?(cache_file)
        lines = File.readlines(cache_file, chomp: true)
        if lines.shift == stamp
          return lines.to_h { |line|
            k, v = line.split("\t")
            [k, Date.parse(v)]
          }
        end
      end
      deleted = build_deleted(paths)
      if cache
        File.open(cache_file, "w") { |file|
          file.puts(stamp)
          deleted.each { |k, d| file.puts("#{k}\t#{d}") }
        }
      end
      deleted
    rescue
      {}
    end

    def self.build_deleted(paths)
      require "spreadsheet"
      Spreadsheet.client_encoding = "UTF-8"
      deleted = {}
      paths.each { |path|
        date = med_drugs_date_of(path) or next
        begin
          Spreadsheet.open(path) { |book|
            book.worksheet(0).each_with_index { |row, i|
              # Drei Kopfzeilen: Titel, englische und deutsche Spaltennamen.
              next if i < 3
              flags = row[0].to_s.strip.split(",")
              next unless flags.include?(DELETE_FLAG)
              nr = iksnr_from(row[1]) or next
              deleted[nr] = date if deleted[nr].nil? || deleted[nr] > date
            }
          }
        rescue
          # Zwei der 439 Dateien sind kaputt (20040115, 20080401: OLE-
          # Fehler). Zwei fehlende Stichtage sind hinnehmbar, ein Abbruch
          # nicht.
          next
        end
      }
      deleted
    end

    # med-drugs-20040115.xls -> Date
    def self.med_drugs_date_of(path)
      File.basename(path)[/med-drugs-(\d{4})(\d{2})(\d{2})\.xls\z/] or return nil
      Date.new($1.to_i, $2.to_i, $3.to_i)
    rescue Date::Error
      nil
    end

    # Der erste Snapshot nach dem letzten Auftritt: bis dahin war sie da,
    # dort nicht mehr. nil, wenn sie noch in der neuesten Liste steht oder
    # nie in einer stand.
    def deregistered_on(iksnr)
      last = @index[iksnr.to_s] or return nil
      @dates.find { |date| date > last }
    end

    def run(registrations, mode = :examine)
      registrations.each { |reg| send(mode, reg) }
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
      source = :packungsliste
      if truth.nil?
        # Vor der ersten Packungsliste (2008-03-28) bleibt nur der Tag, an
        # dem unser med-drugs-Export die Loeschung gemeldet hat. Nur als
        # Rueckfall: stand die Registrierung je in einer Packungsliste,
        # ist die feiner und gewinnt.
        truth = @deleted[reg.iksnr.to_s]
        source = :med_drugs
      end
      if truth.nil? && current == CLEANUP_DAY
        # Dritter Rueckfall, nur fuer den Aufraeumtag: das Verfalldatum.
        # Es ist keine Messung des Tages, an dem Swissmedic sie aus der
        # Liste nahm - aber es ist eine untere Schranke dafuer, und der
        # gespeicherte 27.09.2017 ist nachweislich falsch. Spaeter als der
        # Aufraeumtag taugt es nicht als Beleg.
        expiry = reg.expiration_date
        if expiry.respond_to?(:year) && expiry < CLEANUP_DAY
          truth = expiry
          source = :verfall
        end
      end
      return tally(:nicht_datierbar) if truth.nil?
      diff = (current - truth).to_i
      return tally(:stimmt) if diff.abs <= TOLERANCE_DAYS
      # Frueher als der Beleg heisst, dass jemand mehr wusste als die
      # Liste - das ueberschreiben wir nicht.
      return tally(:frueher_als_beleg) if diff.negative?
      tally(:korrigiert)
      tally(:"korrigiert_via_#{source}")
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

    # Registrierungen, die aus den Swissmedic-Listen verschwunden sind und
    # bei uns noch als aktiv stehen. Zwei Ausnahmen, beide gemessen und
    # beide notwendig:
    #
    #   * Wer nie in einer Liste stand, ist nicht "verschwunden" - das sind
    #     419, darunter die frisch zugelassenen (70893 Comirnaty XFG,
    #     70418 Triofan Levodrop), die nach dem letzten Snapshot kamen.
    #   * Wessen Zulassung heute noch laeuft, ist nicht widerrufen. 41 sind
    #     aus der Packungsliste gefallen, obwohl ihre Zulassung bis 2028
    #     oder 2029 reicht - alle mit null Packungen: zugelassen, aber
    #     nicht vermarktet. Aus der Liste fallen heisst "keine Packung im
    #     Handel", nicht "Zulassung erloschen".
    #
    # Und ein `renewal_flag` heisst, dass eine Verlaengerung laeuft.
    def vanished(reg, today = Date.today)
      return tally(:keine_praeparateliste) if @authorised.empty?
      return tally(:inaktiv) if reg.inactive?
      # Steht sie in der Praeparateliste, ist sie zugelassen - Punkt. Das
      # Verfalldatum taugt dafuer nicht: Exportzulassungen tragen oft gar
      # keines ("unbegrenzt"), und ein `expiry > today` laesst nil glatt
      # durch.
      return tally(:zugelassen) if @authorised.key?(reg.iksnr.to_s)
      truth = deregistered_on(reg.iksnr)
      if truth.nil?
        # nil heisst zweierlei: nie in einer Liste gestanden, oder noch in
        # der neuesten. Beide bleiben unangetastet, aber sie im Bericht
        # zusammenzuwerfen verschleiert, wovon 6299 die eine und 163 die
        # andere Sorte sind.
        return tally(@index.key?(reg.iksnr.to_s) ? :noch_gelistet : :nie_gelistet)
      end
      return tally(:verlaengerung) if reg.renewal_flag
      expiry = reg.expiration_date
      return tally(:zulassung_laeuft) if expiry.respond_to?(:year) && expiry > today
      tally(:deaktiviert)
      @deactivations.push([reg.iksnr, expiry, truth])
      @undo.push("#{reg.iksnr}\t#{expiry}\t#{truth}")
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
      LogFile.debug("DeregistrationDates vanished #{nr}: #{error.class} #{error.message}")
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
      unless @deactivations.empty?
        puts
        puts "=== deaktiviert (Verfall -> gesetztes Datum) ==="
        @deactivations.sort_by { |_, _, set| set }.first(10).each { |iksnr, expiry, set|
          puts format("  %-6s Verfall %-11s -> weg seit %s", iksnr, expiry || "keiner", set)
        }
        puts
        puts "=== gesetzte Daten nach Jahr ==="
        @deactivations.group_by { |_, _, set| set.year }.sort.each { |year, rows|
          puts format("  %s  %5d", year, rows.size)
        }
      end
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
