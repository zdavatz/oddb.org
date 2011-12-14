#!/usr/bin/env ruby
# encoding: utf-8
# Parinfo -- oddb -- 29.10.2003 -- rwaltert@ywesee.com

require 'util/language'
require 'model/sequence_observer'

module ODDB
	class Patinfo
		include Language
		include SequenceObserver
		def company_name
			_sequence_delegate(:company_name)
		end
		def name_base
			_sequence_delegate(:name_base)
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
			:company,
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
			:date,
		]
		attr_accessor :name, :company, :galenic_form, :effects
		attr_accessor :purpose, :amendments, :contra_indications, :precautions
		attr_accessor :pregnancy, :usage, :unwanted_effects
		attr_accessor :general_advice, :other_advice, :composition, :packages
		attr_accessor :distribution, :date, :fabrication
		attr_accessor :iksnrs # interface only, no data
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
		CHAPTERS = [
      :amzv,
			:name,
			:company,
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
			:date,
		]
		attr_accessor :amzv
	end
end
