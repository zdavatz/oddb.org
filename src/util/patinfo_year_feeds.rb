#!/usr/bin/env ruby

# ODDB::PatinfoYearFeeds -- oddb.org -- 30.08.2026
#
# Dasselbe wie FachinfoYearFeeds, fuer die Patienteninformationen: ein Eintrag
# je Patinfo und Aenderungsdatum, verlinkt auf den Diff.
#
# Zwei Unterschiede zur Fachinfo-Seite, beide kommen von der Adresse des
# Diffs. /show/fachinfo/<iksnr>/diff/<datum> braucht nur die Registrierung;
# /show/patinfo/<iksnr>/<seqnr>/<ikscd>/diff/<datum> braucht Sequenz und
# Packung dazu (Session::PI_DIFF_REGEXP loest genau so auf). Und eine Patinfo
# haengt nicht an Registrierungen, sondern an Sequenzen - der Weg zu ihr geht
# also ueber Registrierung, Sequenz, Packung.
#
# Deshalb wird hier ueber die lebenden Registrierungen gelaufen und nicht ueber
# app.patinfos: nur eine Packung, die es noch gibt, ergibt einen Verweis, den
# die Seite auch aufloesen kann. Eine Patinfo, die an mehreren Sequenzen
# haengt, ergibt trotzdem einen Eintrag je Datum - die erste gefundene Packung
# ist der Verweis.
#
# Warum die Patinfo-Historie besonders lueckenhaft ist, steht in
# PatinfoDocument#add_change_log_item: bis August 2026 ersetzte ein
# stolpernder Dublettenvergleich das ganze Aenderungsprotokoll durch den einen
# neuen Eintrag. 26293 der 55993 Eintraege waren dadurch unerreichbar, gegen
# 5154 von 73090 auf der Fachinfo-Seite.

require "util/year_feeds"

module ODDB
  class PatinfoYearFeeds < YearFeeds
    BASE_NAME = "patinfo"

    CHANNELS = {
      "de" => ["Patinfo-Online von ODDB.org",
        "Neue und geänderte Patienteninformationen im Schweizer Gesundheitsmarkt"],
      "fr" => ["Info-Patient en ligne chez ODDB.org",
        "Informations destinées aux patients nouvelles et actualisées sur le marché de santé suisse."],
      "en" => ["PatInfo-Online on ODDB.org",
        "New and modified patient information in the Swiss Healthcare Market"]
    }.freeze

    # => { "de" => { 2015 => [Entry, ...] } }
    def collect(limit: nil)
      buckets = {}
      seen = {}
      done = 0
      catch(:enough) {
        @app.each_registration { |reg|
          collect_registration(reg, buckets, seen)
          retire(reg)
          done += 1
          progress(done, "Registrierungen")
          throw :enough if limit && done >= limit
        }
      }
      buckets
    end

    def link_for(dir, entry)
      "#{ROOT_URL}/#{dir}/gcc/show/patinfo/#{entry.iksnr}/#{entry.seqnr}/" \
        "#{entry.ikscd}/diff/" + entry.date.strftime("%d.%m.%Y")
    end

    private

    def collect_registration(reg, buckets, seen)
      iksnr = value(reg, :iksnr)
      return unless iksnr
      each_patinfo(reg) { |patinfo, seqnr, ikscd, name|
        @counts[:patinfos] += 1
        LANGUAGES.each_value.to_a.uniq.each { |lang|
          each_change_date(patinfo, lang) { |date|
            # Je Patinfo und Datum eine Zeile. Dieselbe Patinfo an mehreren
            # Sequenzen ist eine Aenderung, nicht drei.
            key = [lang, value(patinfo, :odba_id) || [iksnr, seqnr], date]
            next if seen[key]
            seen[key] = true
            @counts[:entries] += 1
            (buckets[lang] ||= {})[date.year] ||= []
            buckets[lang][date.year] << Entry.new(date, iksnr, name, seqnr, ikscd)
          }
        }
        retire(patinfo)
      }
    end

    # Die erste Packung, ueber die die Patinfo erreichbar ist - sie steht im
    # Verweis. Package#patinfo faellt auf die der Sequenz zurueck; seit 2016
    # kann eine Packung eine eigene tragen (Tramal, 43788), darum wird sie
    # und nicht die Sequenz gefragt.
    def each_patinfo(reg)
      seen = {}
      value(reg, :sequences).to_h.each_value { |seq|
        seqnr = value(seq, :seqnr)
        next unless seqnr
        packages = begin
          seq.packages.to_h.values
        rescue
          []
        end
        packages.each { |pac|
          patinfo = value(pac, :patinfo)
          next unless patinfo
          # Nicht is_a? auf dem Wert: ODBA::Stub#is_a? antwortet aus der
          # deklarierten Klasse, ohne aufzuloesen, und liegt damit genau dort
          # falsch, wo eine Referenz kaputt ist. odba_instance loest auf -
          # was hier ohnehin passieren muss, um das change_log zu lesen.
          # Sequence#has_patinfo? fragt seit Jahren genauso.
          instance = value(patinfo, :odba_instance)
          next unless instance.is_a?(ODDB::Patinfo)
          patinfo = instance
          id = value(patinfo, :odba_id) || patinfo.object_id
          next if seen[id]
          seen[id] = true
          ikscd = value(pac, :ikscd)
          next unless ikscd
          name = value(pac, :name_base).to_s
          yield(patinfo, seqnr, ikscd, name)
        }
        # Sequenzen und Packungen einzeln loslassen, nicht nur die
        # Registrierung: eine Sequenz haengt auch an ihrer ATC-Klasse, und
        # die stehen alle in app.atc_classes. Ohne das haelt der Weg ueber
        # die ATC-Klasse Sequenz, Packung und damit die Patinfo am Leben -
        # gemessen 205 MB nach 300 und 624 MB nach 2000 Registrierungen,
        # also ueber vier Gigabyte am Ende. Mit den beiden Zeilen bleibt es
        # flach, so wie beim Fachinfo-Lauf.
        packages.each { |pac| retire(pac) }
        retire(seq)
      }
    end
  end
end
