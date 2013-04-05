#!/usr/bin/env ruby
# encoding: utf-8
# Parinfo -- oddb -- 05.04.2013 -- yasaka@ywesee.com
# Parinfo -- oddb -- 29.10.2003 -- rwaltert@ywesee.com

require 'util/language'
require 'model/sequence_observer'

module ODDB
	class Patinfo
		include Persistence
		include Language
		include SequenceObserver
    def article_codes
      codes = []
      @sequences.collect { |seq|
        next unless seq.patinfo == self # invalid reference
        next unless(seq.public? and seq.has_patinfo?)
        seq.each_package { |pac|
          cds = {
            :article_ean13 => pac.barcode.to_s,
          }
          if(pcode = pac.pharmacode)
            cds.store(:article_pcode, pcode)
          end
          if(psize = pac.size)
            cds.store(:article_size, psize)
          end
          if(pdose = pac.dose)
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
      (!@descriptions.nil?) \
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
			if(seq = @sequences.first)
				seq.send(symbol)
			end
		end
	end
	class PatinfoDocument
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
			:date,
		]
		attr_accessor :name, :company, :galenic_form, :effects
		attr_accessor :purpose, :amendments, :contra_indications, :precautions
		attr_accessor :pregnancy, :usage, :unwanted_effects
		attr_accessor :general_advice, :other_advice, :composition, :packages
		attr_accessor :distribution, :date, :fabrication
		attr_accessor :iksnrs
    def chapter_names
      self::class::CHAPTERS
    end
    def empty?
    end
		def to_s
			self::class::CHAPTERS.collect { |name|
				self.send(name)
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
			:date,
		]
		attr_accessor :amzv
	end
end
