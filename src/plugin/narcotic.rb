#!/usr/bin/env ruby
# ODDV::NarcaticPlugin -- oddb -- 03.11.2005 -- ffricker@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'csv'
require 'plugin/plugin'
require	'iconv'
require 'model/package'


module ODDB
	class NarcoticPlugin < Plugin
		def initialize(app)
			@unknown_registrations = []
			@new_substances = []
			@unknown_packages = []
			super(app)
		end
		def casrn(row)
			casrn = row.at(1)
			unless(casrn.nil? || casrn.empty? || casrn == "nil")
				casrn
			end
		end
		def name(row)
			name = row.at(0)
		end
		def update(path, language = :de)
			CSV.open(path, 'r', ';').each { |row|
				narc = update_narcotic(row, language)
				update_package_or_substance(row, narc, language)
			}
		end
		def update_narcotic(row, language)
			casrn = casrn(row)
			smcd = smcd(row)
			narc = @app.narcotic_by_casrn(casrn) \
			|| @app.narcotic_by_smcd(smcd)
			if(narc.nil?)
				pointer = Persistence::Pointer.new(:narcotic)
				values = {}
				if(casrn)
					values.store(:casrn, casrn)
				else
					values.store(:smcd, smcd)
				end
				narc = @app.update(pointer.creator, values)
			end
			narc
		end
		def update_package(row, narc, language)
			smcd = smcd(row)
			if(registration = @app.registration(smcd[0,5]))
				if(package = registration.package(smcd[5,3])) 
					@app.update(package.pointer, {:narcotic => narc})
				else
					@unknown_packages.push(row)
				end
			else
				@unknown_registrations.push(row)
			end
		end
		def update_substance(row, narc, language)
			smcd = smcd(row)
			name = name(row)
			casrn = casrn(row)
			pointer = Persistence::Pointer.new(:substance).creator
			data = {
				language					=> name,
				:narcotic					=> narc,
				:swissmedic_code	=> smcd,
				:casrn						=> casrn,
			}
			substance = @app.substance_by_smcd(smcd) \
				|| @app.substance(name)
			if(substance)
				pointer = substance.pointer
			else
				@new_substances.push(row)
			end
			@app.update(pointer, data)
		end
		def update_package_or_substance(row, narc, language)
			case row.at(3)
			when /^7680/
				update_package(row, narc, language)
			when /^7611/
				update_substance(row, narc, language)
			end
		end
		def smcd(row)
			raw = row.at(3).to_s
			if(raw.size == 13)
				raw[4,8]
			end
		end
	end
end
