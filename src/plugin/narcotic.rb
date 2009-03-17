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
        name, casrn, third = line
        casrn = casrn.to_s.strip
        if casrn.empty? && (found = name.slice!(/\s+\d+-\d+-\d+\s*$/u))
          line[1] = found
        elsif /\d+-\d+-\d/u.match(third)
          line[0] = line[0].to_s + ' ' + casrn
          line.delete_at(1)
        end
        line.each do |column| column.strip! if column end
      end
      @lines.delete_if do |line|
        name = line.first.to_s
        name.empty? || /\bad\s*us\.?\s*(vet)?/iu.match(name)
      end
      @lines.collect! do |line|
        data = line[0,1]
        data.push(line.find do |item| /^\d+-\d+-\d+/u.match item end)
        pcode = line.find do |item| /^\d{7}$/u.match item end
        pcode = pcode.to_i.to_s if pcode
        data.push pcode
        data.push(line.find do |item| /^76/u.match item end)
        data.push(line.find do |item|
          /\w{2,}/u.match(item.to_s) && !data.include?(item)
        end)
        data.push(line.find do |item| /^\s*[a-d]\s*$/u.match item end)
        compact = data[1..-1].compact
        if(previous && compact.size == 1)
          previous[4] = previous[4].to_s + ' ' + compact.shift
        end
        if(compact.empty?)
=begin ## it seems impossible to get this right: this code is supposed to
        # append the following line to the first column, but since it's unclear
        # when this is desired and when it is not, I've decided to disable it.
          if previous && !/l.gende/i.match(data[0]) \
            && !previous[0].include?(data[0])
            previous[0] = previous[0].to_s + ' ' + line[0]
            previous = nil
          end
=end
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
    MEDDATA_SERVER = DRbObject.new(nil, MEDDATA_URI)
		def initialize(app)
			@unknown_registrations = []
			@new_substances = []
      @new_narcotics = 0
			@unknown_packages = []
			@narcotic_texts = {}
			@reserve_substances = []
			@unknwon_substances_text = []
			@removed_narcotics = []
			@packages = []
      @updated_packages = {}
      @updated_narcs = {}
			@narcs = {}
			super(app)
		end
		def casrns(row)
			casrns = row.at(1).to_s.split('/').collect { |casrn|
				if(/\d+/u.match(casrn))
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
      prune_narcotics
		end
    def process_row(row, language)
      if /^7611/u.match(row.at(3))
        casrn = casrns(row).first
        if narc = update_narcotic(row, casrn, language)
          @narcs.store(casrn, narc) if casrn
          @updated_narcs.store(narc.oid, narc)
        end
        update_substance(row, casrn, narc, language)
      elsif(/^7680/u.match(row.at(3)))
        @packages.push(row)
      end
    end
    def prune_narcotics
      unless @updated_packages.empty?
        @app.each_package do |pac|
          unless pac.narcotics.empty?
            upd = @updated_packages[pac.pointer]
            pac.narcotics.dup.each do |narc|
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
      unless @narcs.empty?
        @app.narcotics.each do |oid, narc|
          unless @updated_narcs.include?(oid)
            @app.delete narc.pointer
          end
        end
      end
    end
    def report
      [
        "Narcotics: #{@updated_narcs.size}",
        "Narcotics with CASRN: #{@narcs.size}",
        "Packages with Narcotics: #{@updated_packages.size}",
        "Unknown registrations: #{@unknown_registrations.size}",
        "Unknown packages: #{@unknown_packages.size}",
        "Created Substances: #{@new_substances.size}",
        "Created Narcotics: #{@new_narcotics}",
        "Created Narcotic Texts: #{@narcotic_texts.size}",
        "Removed Narcotics #{@removed_narcotics.size}",
        "\n",
        "Name", "Casrn | Pharmacode | Ean-Code | Company | Level",
        "\n",
        "Unknown registrations: #{@unknown_registrations.size}\n",
        @unknown_registrations,
        "\n",
        <<-EOS,
Unknown packages: #{@unknown_packages.size}
Packungen, die weder anhand des Swissmedic-Codes noch anhand des
Pharmacodes in der ODDB gefunden wurden. Kann auch ausser-Handel
Packungen beinhalten.
Diese Produkte werden in ch.oddb.org nicht angezeigt (zu wenig Informationen).
        EOS
        @unknown_packages,
        "\n",
        "New substances: #{@new_substances.size}\n",
        @new_substances,
        "\n",
        "New Narcotic Texts: #{@narcotic_texts.size}\n",
        @narcotic_texts,
        "\n",
        "Removed Narcotics #{@removed_narcotics.size}\n",
        @removed_narcotics,
      ].join("\n")
    end
    def report_text(row)
      if(name = row.first)
        name + "\n" + row[1..-1].join(" | ") + "\n"
      else
        row.join(" | ") + "\n"
      end
    end
    def smcd(row)
      smcd = row.at(3).to_s
      if(/\d+/u.match(smcd))
        smcd[4,8]
      end
    end
		def strip_name(row)
			orig = name(row)
			orig.split(/\(\s*((unter\s*)?Vorbehalt|voir)/iu, 2)
		end
		def text2name(text, language)
			case language
			when :de 
				if(match = /^(.+)haltige/u.match(text))
					match[1]
				end
			when :fr
				if(match = /contenant (de la |du |d')([^\s]+)/u.match(text))
					match[2]
				end
			else
				raise "unhandled language: '#{language}'"
			end
		end
    def update(languages = [:de, :fr])
      pattern = /^(Verzeichnis\s+aller|Indice\s+de\s+tous)/u
      agent = WWW::Mechanize.new
      url = "http://www.swissmedic.ch/produktbereiche/00447/00536/index.html"
      dir = File.join ARCHIVE_PATH, 'pdf'
      success = false
      languages.each do |language|
        page = agent.get url + "?lang=#{language}"
        link = page.links.find do |link| pattern.match link.text end
        pdf = link.click
        latest = File.join dir, "narcotics-#{language}-latest.pdf"
        unless File.exist?(latest) && File.read(latest) == pdf.body
          name = @@today.strftime "narcotics-#{language}-%d.%m.%Y.pdf"
          path = File.join dir, name
          pdf.save path
          update_from_pdf path, language
          ## if everything went well, save the pdf as 'latest'
          pdf.save latest
          success = true
        end
      end
      success
    end
		def update_from_csv(path, language)
			CSV.open(path, 'r', ';').each { |row|
        process_row(row)
			}
      postprocess(language)
    end
    def update_from_pdf(path, language)
      parser = Rpdf2txt::Parser.new(File.read(path), 'UTF-8')
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
        nil
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
          @new_narcotics += 1
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
			if((smcd = smcd(row)) && (registration = @app.registration(smcd[0,5])))
        package = registration.package(smcd[5,3])
        if package.nil?
          pcode = row.at(2)
          unless pcode
            begin
              MEDDATA_SERVER.session(:product) { |meddata|
                results = meddata.search(:ean13 => row.at(3))
                if(results.size == 1)
                  data = meddata.detail(results.first, {:pharmacode => [3,2]})
                  pcode = data[:pharmacode]
                end
              }
            rescue MedData::OverflowError
              ## obviously something went wrong, and we have received too many
              #  results.. since we're only interested in results of size 1, we
              #  can safely ignore this.
            end
          end
          package = Package.find_by_pharmacode(pcode) if pcode
        end
        if package
          casrns(row).each { |casrn|
            if !casrn.to_s.strip.empty? && (narc = @narcs[casrn])
              package.add_narcotic(narc)
              (@updated_packages[package.pointer] ||= []).push narc
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
