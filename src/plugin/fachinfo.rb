#!/usr/bin/env ruby
# FachifoPlugin -- ODDB -- 14.11.2003 -- hwyss@ywesee.com

require 'plugin/plugin'
require 'util/oddbconfig'
require 'drb/drb'
require 'util/persistence'
require 'fileutils'

module ODDB
	class FachinfoPlugin < Plugin
		HTML_PATH = File.expand_path('../../data/html/fachinfo', 
			File.dirname(__FILE__))
		PDF_PATH = File.expand_path('../../data/pdf/fachinfo', 
			File.dirname(__FILE__))
		LANGUAGES = ['de', 'fr']
		LOG_PATH = File.expand_path('../../log/fachinfo.txt', 
			File.dirname(__FILE__))
		PARSER = DRbObject.new(nil, FIPARSE_URI)
		RECIPIENTS = [ ]
		def initialize(app)
			super
			@success = 0
			@unknown_iksnrs = {}
			@iksless = []
		end
		def extract_iksnrs(languages)
			iksnrs = []
			languages.each_value { |doc|
				src = doc.iksnrs.to_s.gsub("'", "")
				if(match = src.match(/[0-9]{4,5}(?:\s*,\s*[0-9]{4,5})*/))
					iksnrs += match.to_s.split(/\s*,\s*/)
				end
			}
			iksnrs.uniq
		end
		def fachinfo_news
			path = File.expand_path('fachinfo/index.html', 
				self::class::HTML_PATH)
			if(http_file('www.documed.ch', '/deutsch/', path))
				PARSER.parse_fachinfo_news(File.read(path))
			end
		end
		def fetch_languages(idx)
			LANGUAGES.select { |lang|
				ln = lang[0,1]
				url = sprintf("//data/fi_%s/%sk%05i_.htm", ln, ln, idx)
				http_file("www.kompendium.ch", url, target(lang, idx))
			}.size > 0
		end
		def log_news(lines)
			new_news = (lines + (old_news - lines))
			dir = File.dirname(LOG_PATH)
			FileUtils.mkdir_p(dir)
			File.open(LOG_PATH, 'w') { |fh|
				fh.puts(new_news)
			}
		end
		def old_news
			begin
				File.readlines(LOG_PATH).collect { |line| line.to_i }
			rescue Errno::ENOENT
				[]
			end
		end
		def package_languages(idx)
			LANGUAGES.inject({}) { |inj, language|
				if(fi = parse_fachinfo(language, idx))
					inj.store(language, fi)
				end
				inj
			}
		end
		def parse_fachinfo(language, idx)
			filepath = target(language, idx)
			if(File.exist?(filepath))
				retries = 3
				begin
					PARSER.parse_fachinfo_pdf(File.read(filepath))
				rescue StandardError => e
					puts e.class
					puts e.message
					if(retries > 0)
						sleep 1
						retries -= 1
						retry
					end
				end
			end
		end
		def report
			unknown_size = @unknown_iksnrs.size
			unknown = @unknown_iksnrs.collect { |iksnr, name|
				"#{name} (#{iksnr})"
			}.join("\n")
			[
				"Stored #{@success} Fachinfo-Texts", nil,
				"Unknown Iks-Numbers: #{unknown_size}",
				unknown, nil,
				"Fachinfo without iksnrs: #{@iksless.size}",
				@iksless.join("\n"),
			].join("\n")
		end
		def store_fachinfo(languages)
			@success += 1
			pointer = Persistence::Pointer.new(:fachinfo)
			@app.update(pointer.creator, languages)
		end
		def true_news(news, old_news)
			if(idx = news.index(old_news.first))
				news[0...idx]
			else
				news
			end
		end
		def update
			news = fachinfo_news
			updates = true_news(news, old_news)
			updates.each { |idx|
				if(fetch_languages(idx))
					languages = package_languages(idx)
					update_registrations(languages) unless languages.empty?
				end
			}
			log_news(updates)
			!updates.empty?
		end
		def update_all
			1000.upto(10010) { |idx| 
				languages = package_languages(idx)
				unless(languages.empty?)
					update_registrations(languages)
				end
			}
		end
		def update_news
			newsdir = File.expand_path('news', self::class::PDF_PATH)
			updates = self::class::LANGUAGES.inject([]) { |inj, lang|
				target_dir = File.expand_path(lang, self::class::PDF_PATH)
				source_dir = File.expand_path(lang, newsdir)
				Dir.foreach(source_dir) { |entry|
					if(match = /([0-9A-F\-]{36})\.pdf/.match(entry))
						inj << match[1].to_s
						File.rename(File.expand_path(entry, source_dir), 
							File.expand_path(entry, target_dir))
					end
				}
				inj
			}.uniq
			updates.each { |idx| 
				languages = package_languages(idx)	
				update_registrations(languages) unless languages.empty?
			}
			log_news(updates)
		end
		def update_registrations(languages)
			iksnrs = begin
				extract_iksnrs(languages)
			rescue StandardError
				[]
			end
			if(iksnrs.empty?)
				@iksless.push(name)
			else
				fachinfo = nil
				iksnrs.each { |nr|
					iksnr = sprintf('%05i', nr.to_i)
					if(reg = @app.registration(iksnr))
						fachinfo ||= store_fachinfo(languages)
						@app.replace_fachinfo(iksnr, fachinfo.pointer)
					else
						@unknown_iksnrs.store(iksnr, name)
						store_orphaned(iksnr, languages)
					end
				}
			end
		end
		def store_orphaned(iksnr, languages)
				pointer = Persistence::Pointer.new(:orphaned_fachinfo)
				store = {
					:key => iksnr,
					:languages => languages,
				}				
				@app.update(pointer.creator, store) 
		end	
		private
		def target(lang, idx)
			File.expand_path(
				sprintf("%s/%s.pdf", lang, idx),
				self::class::PDF_PATH
			)
		end
	end
end
