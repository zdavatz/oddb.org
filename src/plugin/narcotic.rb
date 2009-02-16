#!/usr/bin/env ruby
# ODDV::NarcaticPlugin -- oddb -- 03.11.2005 -- ffricker@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'csv'
require 'plugin/plugin'
require	'iconv'
require 'model/package'
require 'rpdf2txt/parser'

module ODDB
  class NarcoticHandler < Rpdf2txt::ColumnHandler
    def initialize callback
      @callback = callback
      super()
    end
    def send_page
      previous = nil
      @lines.each do |line|
        line.each do |column| column.strip! if column end
      end
      @lines.delete_if do |line|
        name = line.first.to_s
        name.empty? || /ad\.?\s*us\.?\s*vet/i.match(name)
      end
      @lines.collect! do |line|
        data = line[0,1]
        data.push(line.find do |item| /^\d+-\d+-\d+/.match item end)
        data.push(line.find do |item| /^\d{7}$/.match item end.to_i.to_s)
        data.push(line.find do |item| /^76/.match item end)
        data.push(nil)
        data.push(line.find do |item| /^\s*[a-d]\s*$/.match item end)
        if(data[1..-1].compact.empty?)
          if previous && !previous[0].include?(data[0])
            previous[0] = previous[0].to_s + ' ' + line[0]
            previous = nil
          end
        else
          previous = data
        end
        data
      end
      @lines.each do |data|
        @callback.call data
      end
    end
  end
	class NarcoticPlugin < Plugin
		def initialize(app)
			@unknown_registrations = []
			@new_substances = []
			@unknown_packages = []
			@narcotic_texts = {}
			@reserve_substances = []
			@unknwon_substances_text = []
			@removed_narcotics = []
			@packages = []
      @updated = {}
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
    def postprocess(language)
			@packages.each { |row|
        update_package(row, language)
			}
			update_narcotic_texts(language)
      unless @updated.empty?
        @app.each_package do |pac|
          unless pac.narcotics.empty?
            upd = @updated[pac.pointer]
            pac.narcotics.each do |narc|
              unless upd && upd.include?(narc)
                pac.remove_narcotic narc
                row = [
                  pac.name_base,
                  narc.casrn,
                  pac.pharmacode,
                  pac.barcode.to_s,
                  pac.company_name,
                  narc.category,
                ]
				        @removed_narcotics.push(report_text(row))
              end
            end
          end
        end
      end
		end
    def process_row(row, language)
      if(/^7611/.match(row.at(3)) && casrn = casrns(row).first)
        narc = update_narcotic(row, casrn, language)
        @narcs.store(casrn, narc)
        update_substance(row, casrn, narc, language)
      elsif(/^7680/.match(row.at(3)))
        @packages.push(row)
      end
    end
    def report
      [
        "Narcotics Update", "\n",
        "Time: ", Time.now,
        "\n",
        "Name", "Casrn | Pharmacode | Ean-Code | Company | Level",
        "\n",
        "Unknown registrations: #{@unknown_registrations.size}\n",
        @unknown_registrations,
        "\n",
        "Unknown packages: #{@unknown_packages.size}\n",
        @unknown_packages,
        "\n",
        "New substances: #{@new_substances.size}\n",
        @new_substances,
        "\n",
        "New Narcotic Text: #{@narcotic_texts.size}",
        @narcotic_texts,
        "\n",
        "Removed Narcotics #{@removed_narcotics.size}\n",
        @removed_narcotics,
      ].join("\n")
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
    def smcd(row)
      smcd = row.at(3).to_s
      if(/\d+/.match(smcd))
        smcd[4,8]
      end
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
    def update(languages = [:de, :fr])
      agent = WWW::Mechanize.new
      url = "http://www.swissmedic.ch/produktbereiche/00447/00536/index.html"
      dir = File.join ARCHIVE_PATH, 'pdf'
      languages.each do |language|
        page = agent.get url + "?lang=#{language}"
        link = page.links.find do |link| /^a\./.match link.text end
        pdf = link.click
        latest = File.join dir, "narcotics-#{language}-latest.pdf"
        unless File.exist?(latest) && File.read(latest) == pdf.body
          name = @@today.strftime "narcotics-#{language}-%d.%m.%Y.pdf"
          path = File.join dir, name
          pdf.save path
          update_from_pdf path, language
          ## if everything went well, save the pdf as 'latest'
          pdf.save latest
        end
      end
    end
		def update_from_csv(path, language)
			CSV.open(path, 'r', ';').each { |row|
        process_row(row)
			}
      postprocess(language)
    end
    def update_from_pdf(path, language)
      parser = Rpdf2txt::Parser.new(File.read(path), 'iso-8859-1')
      callback = Proc.new do |row| process_row row, language end
      handler = NarcoticHandler.new callback
      parser.extract_text(handler)
      postprocess(language)
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
				@app.update(pointer, values, :swissmedic)
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
						@app.update(ptr.creator, args, :swissmedic)
					end
				}
			}
		end
		def update_package(row, language)
			if((smcd = smcd(row)) \
				&& (registration = @app.registration(smcd[0,5])))
				if(package = registration.package(smcd[5,3]) \
           || ((pcode = row.at(2)) && Package.find_by_pharmacode(pcode)))
          casrns(row).each { |casrn|
            if !casrn.to_s.strip.empty? && (narc = @narcs[casrn])
              package.add_narcotic(narc)
              (@updated[package.pointer] ||= []).push narc
            end
          }
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
			substance = @app.update(pointer, data, :swissmedic)
			if(rest)
				@reserve_substances.push(substance)
			end
			substance
		end
	end
end
