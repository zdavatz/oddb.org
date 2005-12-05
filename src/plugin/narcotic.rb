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
			@narcotic_texts = {}
			@reserve_substances = []
			@unknwon_substances_text = []
			@packages = []
			@narcs = {}
			super(app)
		end
		def casrns(row)
			casrns = row.at(1).to_s.split('/').collect { |casrn|
				if(/\d+/.match(casrn))
					casrn.to_s.strip
				end
			}.compact
		end
		def category(row)
			category = row.at(5).to_s
			if(category == "")
				category = "a"
			end
			category
		end
		def name(row)
			row.at(0).to_s.strip
		end
		def strip_name(row)
			orig = name(row)
			orig.split(/\(\s*((unter\s*)?Vorbehalt|voir)/i, 2)
		end
		def text2name(text, language)
			case language
			when :de 
				if(match = /^(.+)haltige/.match(text))
					match[1]
				end
			when :fr
				if(match = /contenant (de la |du |d')([^\s]+)/.match(text))
					match[2]
				end
			else
				raise "unhandled language: '#{language}'"
			end
		end
		def report_text(row)
			if(row.at(0))
				name = row.at(0)
				row.delete_at(0)
				text = row.join(" | ")
				name + "\n" + text + "\n"
			else
				"Error! Entry has no name!"
			end
		end
		def update(path, language)
			CSV.open(path, 'r', ';').each { |row|
					if(/^7611/.match(row.at(3)))
						casrn = casrns(row).first
						narc = update_narcotic(row, casrn, language)
						@narcs.store(casrn, narc)
						update_substance(row, casrn, narc, language)
					elsif(/^7680/.match(row.at(3)))
						@packages.push(row)
					end
			}
			@packages.each { |row|
				casrns(row).each { |casrn|
					if(narc = @narcs[casrn])
						update_package(row, narc, language)
					end
				}
			}
			update_narcotic_texts(language)
		end
		def update_narcotic(row, casrn, language)
			smcd = smcd(row)
			category = category(row)
			name = name(row)
			values = {}
			# When smcd and casrn are nil, we have a text description
			if(category == "c" && (subst = text2name(name, language)))
				@narcotic_texts.store(subst, name)
			elsif(casrn || smcd)
				if(category)
					values.store(:category, category)
				end
				# Search narcotic objects by casrn or swissmedic code.
				# The new narc objects will be stored with the
				# swissmedic code or with the casrn number
				narc = @app.narcotic_by_casrn(casrn) \
					|| @app.narcotic_by_smcd(smcd)
				if(narc) 
					pointer =	narc.pointer
				else
					pointer = Persistence::Pointer.new(:narcotic).creator
				end
				@app.update(pointer, values)
			end
		end
		def update_narcotic_texts(language)
			@narcotic_texts.each { |name, text|
				@reserve_substances.delete_if { |substance|
					if(substance.send(language).include?(name))
						ptr = substance.narcotic.pointer + :reservation_text
						args = {
							language	=> text,
						}	
						@app.update(ptr.creator, args)
					end
				}
			}
		end
		def update_package(row, narc, language)
			if((smcd = smcd(row)) \
				&& (registration = @app.registration(smcd[0,5])))
				if(package = registration.package(smcd[5,3])) 
					#@app.update(package.pointer, {:narcotic => narc})
					package.add_narcotic(narc)
					package.odba_store
				else
					@unknown_packages.push(report_text(row))
				end
			else
				@unknown_registrations.push(report_text(row))
			end
		end
		def update_substance(row, casrn, narc, language)
			smcd = smcd(row)
			name, rest = strip_name(row)
			pointer = Persistence::Pointer.new(:substance).creator
			data = {
				language					=> name.strip,
				:narcotic					=> narc,
				:casrn						=> casrn,
				:swissmedic_code	=> smcd,
			}
			substance = @app.substance_by_smcd(smcd) \
				|| @app.substance(name)
			if(substance)
				pointer = substance.pointer
			else
				@new_substances.push(report_text(row))
			end
			substance = @app.update(pointer, data)
			if(rest)
				@reserve_substances.push(substance)
			end
			substance
		end
		def report
			[
				"Narcotics Update", "\n",
				"Time: ", Time.now,
				"\n",
				"Name", "Casrn | Pharmacode | Ean-Code | Company | Level",
				"\n",
				"Unknown registrations: #{@unknown_registrations.size} \n",
				@unknown_registrations,
				"\n",
				"Unknown packages: #{@unknown_packages.size} \n",
				@unknown_packages,
				"\n",
				"New substances: #{@new_substances.size} \n",
				@new_substances,
				"\n",
				"New Narcotic Text: #{@narcotic_texts.size}",
				@narcotic_texts,
			].join("\n")
		end
		def smcd(row)
			smcd = row.at(3).to_s
			if(/\d+/.match(smcd))
				smcd[4,8]
			end
		end
	end
end
