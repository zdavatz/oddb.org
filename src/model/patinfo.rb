#!/usr/bin/env ruby

# Parinfo -- oddb -- 05.04.2013 -- yasaka@ywesee.com
# Parinfo -- oddb -- 29.10.2003 -- rwaltert@ywesee.com

require "util/persistence"
require "util/language"
require "model/sequence_observer"
require "diffy"
require "util/today"
require "util/logfile"

module ODDB
  class Patinfo
    include Persistence
    include Language
    include SequenceObserver
    def same_as?(patinfo)
      LogFile.debug("#{self.class}: same_as? called for #{odba_id}")
      false
    end

    def article_codes
      codes = []
      @sequences.collect { |seq|
        next unless seq.patinfo == self # invalid reference
        next unless seq.public? and seq.has_patinfo?
        seq.each_package { |pac|
          cds = {
            article_ean13: pac.barcode.to_s
          }
          if (pcode = pac.pharmacode)
            cds.store(:article_pcode, pcode)
          end
          if (psize = pac.size)
            cds.store(:article_size, psize)
          end
          if (pdose = pac.dose)
            cds.store(:article_dose, pdose.to_s)
          end
          codes.push(cds)
        }
      }
      codes
    end

    def company_name
      _sequence_delegate(:company_name)
    end

    def name_base
      _sequence_delegate(:name_base)
    end

    def valid?
      !@descriptions.nil? \
      and @descriptions.respond_to?(:[]) \
      and @descriptions.respond_to?(:empty?) \
      and !@descriptions.empty?
    end

    def odba_store
      @descriptions.odba_store
      super
    end

    private

    def _sequence_delegate(symbol)
      if (seq = @sequences.first)
        seq.send(symbol)
      end
    end
  end

  class PatinfoDocument
    include Persistence
    def same_as?(patinfo)
      LogFile.debug("#{self.class}: same_as? called for #{odba_id}")
      false
    end

    def pointer_descr
      "Patinfo"
    end

    class ChangeLogItem
      include Persistence
      attr_accessor :time, :diff
      def <=>(other)
        # [diff.to_s, time] <=> [anOther.diff.to_s, anOther.time]
        diff.to_s <=> other.diff.to_s
      end

      def pointer_descr
        time.strftime("%d.%m.%Y")
      end
    end
    Patinfo_diff_options = {diff: "-U 3",
                            source: "strings",
                            include_plus_and_minus_in_html: true,
                            include_diff_info: false,
                            context: 0,
                            allow_empty_diff: false}
    def add_change_log_item(old_text, new_text, date = @@today, options = Patinfo_diff_options)
      return if old_text.to_s.eql?(new_text.to_s)
      @change_log ||= []
      item = ChangeLogItem.new
      item.time = date
      item.diff = Diffy::Diff.new(old_text ? old_text.to_s : "", new_text.to_s, options)
      already_disabled = GC.disable
      begin
        if @change_log && @change_log.find { |x| x.diff.to_s.eql?(item.diff.to_s) }
          return
        end
      rescue => error
        # Faellt die Dublettenpruefung aus, faellt die Pruefung aus - nicht die
        # Historie. Hier stand bis August 2026 @change_log = [item], was das
        # gesamte Aenderungsprotokoll durch den einen neuen Eintrag ersetzte.
        # Ein einziger Eintrag, dessen diff.to_s stolpert, riss damit alle
        # uebrigen mit: sie blieben in der Datenbank liegen, aber nichts zeigte
        # mehr auf sie. x.diff.to_s ruft Diffy auf, das zwei Tempfiles schreibt
        # und diff startet - dort sitzen die bekannten Kodierungsprobleme.
        #
        # Am 26.08.2026 gemessen: von 22 an einem Tag gespeicherten Patinfos
        # verloren 2 ihre Historie. Ueber zwanzig Jahre ergibt das die 26293
        # unerreichbaren PatinfoDocument::ChangeLogItems, gegen 5154 auf der
        # Fachinfo-Seite, wo derselbe rescue die Liste in Ruhe laesst.
        #
        # Schlimmstenfalls entsteht jetzt eine Dublette. Das ist nichts gegen
        # den Verlust von hunderten Eintraegen.
        LogFile.debug("Patinfo::ChangeLogItem: duplicate check failed " \
                      "(#{error.class}: #{error.message}), keeping #{@change_log.size} entries")
      end
      already_disabled = GC.disable
      @change_log.push(item)
      odba_store
      GC.enable unless already_disabled
      item
    end

    attr_writer :change_log
    def change_log
      @change_log ||= []
    end
    CHAPTERS = [
      :name,
      :galenic_form,
      :effects,
      :purpose,
      :amendments,
      :contra_indications,
      :precautions,
      :pregnancy,
      :usage,
      :unwanted_effects,
      :general_advice,
      :other_advice,
      :composition,
      :packages,
      :distribution,
      :fabrication,
      :iksnrs,
      :company,
      :date
    ]
    attr_accessor :name, :company, :galenic_form, :effects
    attr_accessor :purpose, :amendments, :contra_indications, :precautions
    attr_accessor :pregnancy, :usage, :unwanted_effects
    attr_accessor :general_advice, :other_advice, :composition, :packages
    attr_accessor :distribution, :date, :fabrication
    attr_accessor :iksnrs
    def chapter_names
      self.class::CHAPTERS
    end

    def empty?
    end

    def to_s
      self.class::CHAPTERS.collect { |name|
        send(name)
      }.compact.join("\n")
    end
  end

  class PatinfoDocument2001 < PatinfoDocument
    CHAPTERS = [ # display order
      :amzv,
      :name,
      :galenic_form,
      :effects,
      :purpose,
      :amendments,
      :contra_indications,
      :precautions,
      :pregnancy,
      :usage,
      :unwanted_effects,
      :general_advice,
      :other_advice,
      :composition,
      :packages,
      :distribution,
      :fabrication,
      :iksnrs,
      :company,
      :date
    ]
    attr_accessor :amzv
  end
end
