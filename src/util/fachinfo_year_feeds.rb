#!/usr/bin/env ruby

# ODDB::FachinfoYearFeeds -- oddb.org -- 27.08.2026
#
# Die Jahresfeeds fachinfo-<jahr>.rss aus den Aenderungen selbst, nicht aus
# dem Bestand.
#
# Bis hierher baute Plugin#update_yearly_fachinfo_feeds sie aus
# app.sorted_fachinfos, also aus den heutigen Fachinformationen, sortiert nach
# dem Jahr ihrer letzten Revision. Jede Fachinfo hat genau ein revision-Datum,
# also landete jede in genau einem Jahr - eine Aufteilung des Bestands, keine
# Geschichte. Gemessen am 27.08.2026: ueber alle Jahresdateien zusammen 5053
# verschiedene Fachinfos, davon drei in mehr als einem Jahr. Und weil ein Jahr
# nur behaelt, was seither nicht wieder angefasst wurde, schrumpfen die alten:
# der Massenreparse vom Februar 2026 zog 2191 Dokumente aus ihren frueheren
# Jahren heraus, so dass 2025 auf 66 Eintraege fiel und 2026 auf 2871 stieg.
#
# Die Geschichte liegt im change_log der Dokumente - dieselbe Quelle, aus der
# die /diff/-Seiten kommen. Ein Eintrag ist hier eine Aenderung mit ihrem
# Datum und verweist auf den Diff, nicht auf die Fachinformation.
#
# Ein Eintrag je Fachinfo und Datum, nicht je Registrierung: eine Fachinfo
# gehoert im Schnitt zu 2.3 Registrierungen, und der Text hat sich einmal
# geaendert, nicht zweimal. Verlinkt wird ueber eine davon.
#
# Der Rumpf steht in YearFeeds, den sich die Patienteninformationen teilen.

require "util/year_feeds"

module ODDB
  class FachinfoYearFeeds < YearFeeds
    BASE_NAME = "fachinfo"

    CHANNELS = {
      "de" => ["Fachinfo-Online von ODDB.org",
        "Neue und geänderte Fachinformtionen im Schweizer Gesundheitsmarkt"],
      "fr" => ["IPro-Online chez ODDB.org",
        "Informations professionnelles nouvelles et actualisées sur le marché de santé suisse."],
      "en" => ["DocInfo-Online on ODDB.org",
        "New and modified information for professionals in the Swiss Healthcare Market"]
    }.freeze

    # => { "de" => { 2015 => [Entry, ...] } }
    def collect(limit: nil)
      buckets = {}
      seen = {}
      list = @app.sorted_fachinfos
      list = list.first(limit) if limit
      list.each_with_index { |fi, index|
        reg = registration_for(fi)
        next unless reg
        iksnr = value(reg, :iksnr)
        next unless iksnr
        name = value(reg, :name_base).to_s
        LANGUAGES.each_value.to_a.uniq.each { |lang|
          each_change_date(fi, lang) { |date|
            key = [lang, iksnr, date]
            next if seen[key]
            seen[key] = true
            @counts[:entries] += 1
            (buckets[lang] ||= {})[date.year] ||= []
            buckets[lang][date.year] << Entry.new(date, iksnr, name)
          }
        }
        @counts[:fachinfos] += 1
        retire(fi)
        progress(index + 1, "Fachinfos")
      }
      buckets
    end

    def link_for(dir, entry)
      "#{ROOT_URL}/#{dir}/gcc/show/fachinfo/#{entry.iksnr}/diff/" +
        entry.date.strftime("%d.%m.%Y")
    end

    private

    # Eine Fachinfo gehoert zu mehreren Registrierungen. Verlinkt wird ueber
    # die, die auch auf sie zurueckzeigt - eine Registrierung kann eine
    # fremde Fachinfo tragen, wenn eine Referenz verwaist ist.
    def registration_for(fachinfo)
      regs = begin
        Array(fachinfo.registrations)
      rescue
        []
      end
      regs.find { |reg|
        begin
          reg.respond_to?(:iksnr) && reg.fachinfo.equal?(fachinfo)
        rescue
          false
        end
      } || regs.find { |reg| reg.respond_to?(:iksnr) }
    end
  end
end
