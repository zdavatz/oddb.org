#!/usr/bin/env ruby
# FachifoPlugin -- ODDB -- 14.11.2003 -- hwyss@ywesee.com

require 'plugin/plugin'
require 'util/oddbconfig'
require 'drb/drb'
require 'util/persistence'
require 'fileutils'
require 'view/rss/fachinfo'

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
		NEWS_PATHS = [
			'/content/default.aspx',
		]
		RECIPIENTS = [ ]
		def initialize(app)
			super
			@success = 0
			@unknown_iksnrs = {}
			@iksless = []
			@hdrs = {
				'User-Agent'=>	'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1) ',
				'Accept'		=>	'image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, */* ',
			}
			@successes = []	
			@failures = []	
      @host = 'www.documedinfo.ch'
		end
		def extract_iksnrs(languages)
			iksnrs = []
			languages.each_value { |doc|
				src = doc.iksnrs.to_s.gsub("'", "")
				if(match = src.match(/[0-9]{3,5}(?:\s*,\s*[0-9]{3,5})*/))
					iksnrs += match.to_s.split(/\s*,\s*/)
				end
			}
			iksnrs.collect { |iksnr| sprintf("%05i", iksnr) }.uniq
		end
		def extract_name(languages)
			languages.sort.first.last.name.to_s rescue 'Unknown'
		end
		def fachinfo_news
			ids = []
			NEWS_PATHS.each { |source|
				target = File.join(HTML_PATH, File.basename(source))
				if(http_file(@host, source, target, nil, @hdrs))
					ids += PARSER.parse_fachinfo_news(File.read(target))
				else 
					raise "Could not download #{source} from #{@host}"
				end
			}
			ids
		end
		def fetch_languages(idx)
			host = "www.kompendium.ch"
			urls = []
			successes = LANGUAGES.select { |lang|
				url = sprintf(
					"/FrmMainMonographie.aspx?Id=%s&lang=%s&MonType=fi", 
					idx, lang)
				urls.push(url)
				http_file(host, url, target(lang, idx), nil, @hdrs)
			}
			if(successes.empty?)
				msg = "could not download any fachinfos from #{host}\n"
				msg << urls.join("\n")
				raise msg	
			end
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
				File.readlines(LOG_PATH).collect { |line| line.strip }
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
    def postprocess
      update_rss_feeds('fachinfo.rss', @app.sorted_fachinfos, View::Rss::Fachinfo)
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
				@iksless.join("\n"), nil,
				"Parse Errors: #{@failures.size}", 
				@failures.join("\n"), 
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
			updates = true_news(news, old_news())
			updates.each { |idx|
				fetch_languages(idx)
				languages = package_languages(idx)
				if(languages.empty?)
					@failures.push(idx)
				else
					update_registrations(languages) 
					@successes.push(idx)
				end
			}
			log_news(updates)
      postprocess
			!updates.empty?
		end
		def update_registrations(languages)
			iksnrs = begin
				extract_iksnrs(languages)
			rescue StandardError
				[]
			end
			if(iksnrs.empty?)
				@iksless.push(extract_name(languages))
			else
				fachinfo = nil
				iksnrs.each { |nr|
					iksnr = sprintf('%05i', nr.to_i)
					if(reg = @app.registration(iksnr))
						fachinfo ||= store_fachinfo(languages)
						@app.replace_fachinfo(iksnr, fachinfo.pointer)
					else
						@unknown_iksnrs.store(iksnr, extract_name(languages))
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
