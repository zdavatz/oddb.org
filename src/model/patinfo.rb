#!/usr/bin/env ruby
# Parinfo -- oddb -- 29.10.2003 -- rwaltert@ywesee.com

require 'util/language'
require 'model/sequence_observer'

module ODDB
	class Patinfo
		include Language
		include SequenceObserver
		def company_name
			if(seq = @sequences.first)
				seq.company_name
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
			:date,
		]
		attr_accessor :name, :company, :galenic_form, :effects
		attr_accessor :purpose, :amendments, :contra_indications, :precautions
		attr_accessor :pregnancy, :usage, :unwanted_effects
		attr_accessor :general_advice, :other_advice, :composition, :packages
		attr_accessor :distribution, :date
		attr_accessor :iksnrs # interface only, no data
		def to_s
			self::class::CHAPTERS.collect { |name|
				self.send(name)
			}.compact.join("\n")
		end
	end
	class PatinfoDocument2001 < PatinfoDocument
		attr_accessor :amzv
	end
end
