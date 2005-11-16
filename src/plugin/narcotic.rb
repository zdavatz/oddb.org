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
			super(app)
		end
		def casrn(row)
			casrn = row.at(1).to_s
			if(/\d+/.match(casrn))
				casrn
			end
		end
		def category(row)
			category = row.at(5).to_s
			unless(category == "")
				category
			end
		end
		def name(row)
			row.at(0).to_s.strip
		end
		def strip_name(row)
			orig = name(row)
			orig.split(/\(\s*(unter\s*)?Vorbehalt/i, 2)
		end
		def text2name(text)
			text.split("haltige", 2).first
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
		def update(path, text_path, language = :de)
			CSV.open(path, 'r', ';').each { |row|
				narc = update_narcotic(row, language)
				update_package_or_substance(row, narc, language)
			}
			update_narcotic_texts(language)
			send_report
		end
		def update_narcotic(row, language)
			casrn = casrn(row)
			smcd = smcd(row)
			category = category(row)
			name = name(row)
			values = {}
			# When smcd and casrn are nil, we have a text description
			if(category == "c" && smcd.nil? && casrn.nil?)
				@narcotic_texts.store(text2name(name(row)), name(row))
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
				if(casrn)
					values.store(:casrn, casrn)
				else
					values.store(:swissmedic_code, smcd)
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
			smcd = smcd(row)
			if(registration = @app.registration(smcd[0,5]))
				if(package = registration.package(smcd[5,3])) 
					@app.update(package.pointer, {:narcotic => narc})
				else
					@unknown_packages.push(report_text(row))
				end
			else
				@unknown_registrations.push(report_text(row))
			end
		end
		def update_substance(row, narc, language)
			smcd = smcd(row)
			casrn = casrn(row)
			name, rest = strip_name(row)
			pointer = Persistence::Pointer.new(:substance).creator
			data = {
				language					=> name.strip,
				:narcotic					=> narc,
				:swissmedic_code	=> smcd,
				:casrn						=> casrn,
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
		def update_package_or_substance(row, narc, language)
			case row.at(3)
			when /^7680/
				update_package(row, narc, language)
			when /^7611/
				update_substance(row, narc, language)
			end
		end
		def send_report
			mail = TMail::Mail.new
			mail.to = "ffricker@ywesee.com" #ODDB::Log::MAIL_TO
			mail.from =	ODDB::Log::MAIL_FROM
			mail.subject = "Narcotics-Update-Report"
			mail.date = Time.now
			mail.body = [
			"Narcotics Update", "\n",
			"Time: ", mail.date,
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
			Net::SMTP.start(SMTP_SERVER) { |smtp|
				smtp.sendmail(mail.encoded, SMTP_FROM, mail.to) 
			}
		end
		def smcd(row)
			smcd = row.at(3).to_s
			if(/\d+/.match(smcd))
				smcd[4,8]
			end
		end
	end
end
