#!/usr/bin/env ruby
# FachifoPlugin -- ODDB -- 14.11.2003 -- hwyss@ywesee.com

require 'plugin/plugin'
require 'util/oddbconfig'
require 'drb/drb'
require 'util/persistence'
require 'fileutils'
require 'view/rss/fachinfo'
require 'mechanize'

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
			'/content/page_1.aspx',
		]
		RECIPIENTS = [ ]
    @@fi_ptrn = /Monographie.aspx\?Id=([0-9A-Fa-f\-]{36}).*MonType=fi/
		def initialize(app)
			super
			@success = 0
			@unknown_iksnrs = {}
			@iksless = []
      init_agent
			@successes = []	
			@failures = []	
      @host = 'www.documedinfo.ch'
		end
    def init_agent
      @agent = WWW::Mechanize.new
      @agent.user_agent = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_4_11; de-de) AppleWebKit/525.18 (KHTML, like Gecko) Version/3.1.2 Safari/525.22"
    end
    def extract_fachinfo_id(href)
      if match = @@fi_ptrn.match(href.to_s)
        match[1]
      end
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
      NEWS_PATHS.each do |source|
        target = File.join(HTML_PATH, File.basename(source))
        url = "http://#{@host}#{source}"
        if page = @agent.get(url)
          page.links.each do |link|
            if match = @@fi_ptrn.match(link.href)
              ids.push match[1]
            end
          end
        else
          raise "Could not download #{source} from #{@host}"
        end
      end
      ids
    end
    def fetch_languages(idx, langs=LANGUAGES)
      host = "www.kompendium.ch"
      urls = []
      successes = langs.select { |lang|
        sleep 1
        search = sprintf "Id=%s&lang=%s&MonType=fi", idx, lang
        url = "http://#{host}/Monographie.aspx?#{search}"
        urls.push(url)
        page = @agent.get url
        if (form = page.forms.first) && (button = form.buttons.first)
          sleep 1
          page = form.submit button
        end
        url = "http://#{host}/FrmMainMonographie.aspx?#{search}"
        urls.push(url)
        sleep 1
        page = @agent.get url
        page.save_as target(lang, idx)
      }
      if(successes.empty?)
        msg = "could not download any fachinfos from #{host}\n"
        msg << urls.join("\n")
        raise msg
      end
    rescue WWW::Mechanize::ResponseCodeError, EOFError
      retries ||= 10
      if retries > 0
        retries -= 1
        init_agent
        retry
      else
        raise
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
		def package_languages(idx, langs=LANGUAGES)
			langs.inject({}) { |inj, language|
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
    def parse_from_id(idx, langs=LANGUAGES)
      fetch_languages(idx, langs)
      package_languages(idx, langs)
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
      updates.reverse.each do |idx|
        languages = parse_from_id(idx)
        if(languages.empty?)
          @failures.push(idx)
        else
          update_registrations(languages)
          @successes.push(idx)
        end
        log_news([idx])
      end
      postprocess
			!updates.empty?
		end
    def update_from_id idx
      languages = parse_from_id(idx)
      if(languages.empty?)
        @failures.push(idx)
      else
        update_registrations(languages)
        @successes.push(idx)
      end
      postprocess
      @failures.empty?
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
