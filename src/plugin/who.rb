#!/usr/bin/env ruby
# WhoPlugin -- ODDB -- 23.02.2004 -- hwyss@ywesee.com

require 'delegate'
require 'cgi'
require 'csv'
require 'plugin/plugin'
require 'model/text'
require 'model/dose'
require 'util/html_parser'
require 'util/persistence'

module ODDB
	ATC_TOP_LEVEL = %w{A B C D G H J L M N P R S V}
	#ATC_TOP_LEVEL = %w{A10BB}
	ATC_PATTERN = "[#{ATC_TOP_LEVEL.join}](?:\\d{2}(?:[A-Z]\\s*(?:[A-Z](?:\\d{2})?)?)?)?"
	class WhoWriter < NullWriter
		def initialize
			@linkhandlers = []
			@tablehandlers = []
			@descriptions = {}
			@guidelines = {}
			@ddd_guidelines = {}
			@ddd = {}
		end
		def extract_ddd
			@tablehandlers.inject({}) { |inj, handler|
				code = nil
				handler.each_row { |row|
					if(((match = /^#{ATC_PATTERN}$/.match(row.cdata(0).strip)) \
						|| code) && !row.cdata(2).strip.empty?)
						code = match[0] unless match.nil?
						(inj[code] ||= []).push(row2ddd(row))
					end
				}
				inj
			}
		end
		def extract_descriptions
			@descriptions
		end
		def extract_chapters(chapters)
      replace = {}
			chapters.each { |code, chapter|
        if(chapter)
          chapter.clean!
          if(chapter.empty?)
            replace[code] = nil
          end
        end
			}
      chapters.update(replace)
			chapters
		end
		def extract_ddd_guidelines
			extract_chapters(@ddd_guidelines)
		end
		def extract_guidelines
			extract_chapters(@guidelines)
		end
		def handle_data(data, new_chapter=false)
			if(new_chapter)
				@chapter = Text::Chapter.new
				@section = @chapter.next_section
				@paragraph = @section.next_paragraph
			end
			@paragraph << data if(@paragraph)
		end
		def handle_ddd(data)
			@current_tablehandler.send_cdata(data)
		end
		def handle_ddd_guideline(data)
			new_chapter = !@ddd_guidelines[@current_code]
			handle_data(data, new_chapter)	
			if(new_chapter)
				@ddd_guidelines[@current_code] = @chapter
			end
		end
		def handle_guideline(code, data)
			new_chapter = !@guidelines[code]
			handle_data(data, new_chapter)	
			if(new_chapter)
				@guidelines[code] = @chapter
			end
		end
		def href2atc(href)
			pattern = /query=(#{ATC_PATTERN})(?:$|&)/i
			if(match = pattern.match(href))
				match[1]
			end
		end
		def new_linkhandler(handler)
			if(@current_linkhandler \
				&& (code = href2atc(@current_linkhandler.attributes["href"])))
				@descriptions[code] = @current_linkhandler.value
				if(@paragraph && /^#{ATC_PATTERN}$/.match(@paragraph.text))
					@section.paragraphs.pop
				end
			end
      if(handler)
        @linkhandlers.push(handler)
        if(@current_code = href2atc(handler.attributes["href"]))
          @ddd_guidelines[@current_code] ||= nil
          @guidelines[@current_code] ||= nil
        end
      end
			@current_linkhandler = handler
		end
		def new_tablehandler(handler)
			@tablehandlers.push(handler) if handler
			@current_tablehandler = handler
		end
		def row2ddd(row)
			qty = row.cdata(2).strip
			unit = row.cdata(3).strip
			note = row.cdata(5).strip
			if(match = /^([^\d\s]+)\s*(\d+\))/.match(unit))
				unit = match[1]
				note.gsub!(/^#{Regexp.escape(match[2])}\s*/, '')
			end
			ddd = {
				:dose									=>	Dose.new(qty, unit),
				:administration_route	=>	row.cdata(4).strip,
				:note									=>	note,
			}
		end
		def send_flowing_data(data) 
			data.tr!("\xA0", ' ') # remove &nbsp;
			if(@current_linkhandler)
				@current_linkhandler.send_adata(data)
			elsif(@current_tablehandler)
				if(@current_tablehandler.attributes.any? { |key, val| 
					key == 'bgcolor'
				})
					handle_ddd_guideline(data)
				else
					handle_ddd(data)
				end
			elsif((lh = @linkhandlers.last) \
				&& (code = href2atc(lh.attributes["href"])))
				handle_guideline(code, data)
			end
		end
		def send_line_break
			@paragraph = @section.next_paragraph if @section
		end
		def send_paragraph(blankline)
			if(@chapter)
				@section = @chapter.next_section 
				@paragraph = @section.next_paragraph
			end
		end
	end
	class WhoCodeHandler
		def initialize
			@codes = ATC_TOP_LEVEL.dup
			@visited = []
		end
		def push(code)
			#res = @codes.push(code) unless((@visited | @codes).include?(code))
			total = @codes + @visited
			unless(total.include?(code))
				@codes.push(code)
			end
		end
		def shift
			code = @codes.shift
			@visited.push(code)
			code
		end
	end
	class WhoSession < SimpleDelegator
		CREDENTIALS = File.expand_path('../../etc/who.txt',
			File.dirname(__FILE__))
		HTTP_PATH = '/atcddd/database/index.php'
		#HTTP_PATH = '/spike/post.rbx' 
		HTTP_SERVER = 'www.whocc.no'
		#HTTP_SERVER = 'www.oddb.org.local'
		def initialize
			@http = Net::HTTP.new(HTTP_SERVER)
			@output = ''
			@cookies = {}
			super(@http)
		end
		def atc_query(code)
			"#{HTTP_PATH}?query=#{code}&showdescription=yes"
		end
		def cookies
			@cookies.sort.collect { |pair| pair.join('=') }.join('; ')
		end
		def get(source)
			@http.get(source, get_headers)
		end
		def get_code(code)
			get(atc_query(code))
		end
		def get_headers
			headers = {
				'Accept'          =>  'text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,video/x-mng,image/png,image/jpeg,image/gif;q=0.2,*/*;q=0.1',
				'Accept-Charset'	=>	'ISO-8859-1',
				'Accept-Language' =>  'de-ch,en-us;q=0.7,en;q=0.3',
				'Accept-Encoding' =>  'gzip,deflate',
				'Connection'			=>	'keep-alive',
				'Host'						=>	HTTP_SERVER,
				'Keep-Alive'			=>	'300',
				'User-Agent'      =>  'Mozilla/5.0 (X11; U; Linux ppc; en-US; rv:1.4) Gecko/20030716',
				'Referer'         =>  ['http://', HTTP_SERVER, HTTP_PATH].join
			}
			if((cks = cookies) && !cks.empty?)
				headers.store('Cookie', cks)
			end
			headers
		end
		def load_credentials(path)
			hash = {}
			File.foreach(path) { |line|
				if(match = /(\w+)\s*=\s*([^\s]+)/.match(line))
					hash.store(match[1], match[2])
				end
			}
			hash
		end
		def login
			hash = load_credentials(CREDENTIALS)
			resp = post(HTTP_PATH, post_body(hash), post_headers)
			if(resp.is_a? Net::HTTPOK)
				update_cookies(resp)
			else
				raise("could not connect to #{HTTP_SERVER}: #{resp}")
			end
			resp
		end
		def logout
			get(HTTP_PATH + "?logout=true")
		end
		def update_cookies(resp=nil)
			if(resp && (cookiestring = resp['set-cookie']))
				ptrn = /(?:^|, (?!\d))([^;]+)/
				cookiestring.scan(ptrn) { |cookie|
					@cookies.store(*(cookie[0].split('=',2)))
				}
			end
		end
		def post_headers
			headers = get_headers
			headers.store('Content-Type', 'application/x-www-form-urlencoded')
			headers
		end
		def post_body(hash)
			sorted = hash.sort.collect { |pair| 
				pair.collect { |item| CGI.escape(item) }.join('=') 
			}
			sorted.join("&")
		end
	end
	class WhoPlugin < Plugin
		def initialize(*args)
			super
			@code_handler = WhoCodeHandler.new
		end
		def login
		end
		def update
			@session = WhoSession.new
			@session.login
			while(code = @code_handler.shift)
				resp = @session.get_code(code)
				if(resp.is_a?(Net::HTTPOK))
					begin 
						extract(resp.read_body)
					rescue StandardError => e
						puts e
						puts e.message
						puts e.backtrace
					end
				end
				sleep(1)
			end
			@session.logout
		end
		def update_from_csv(fname)
			path = File.join(ARCHIVE_PATH, 'csv', fname)
			writer = Struct.new( "CsvWriter", 
				:extract_descriptions, :extract_ddd).new
			writer.extract_descriptions = descr = {}
			writer.extract_ddd = daily = {}
			CSV.open(path, 'r', ?;) { |csv_row|
				unless(csv_row[2].to_s.strip.empty?)	
					ddds = csv_row[4].to_s.split(/,/).collect { |ar|
						ddd = {
							:dose	=>	Dose.new(csv_row[2].to_s, csv_row[3].to_s),
							:administration_route	=>	ar.strip,
						}
					}
					daily.store(csv_row[0].to_s, ddds)
				end
				descr.store(csv_row[0].to_s, csv_row[1].to_s)
			}
			extract_descriptions(writer)
			extract_ddd(writer)
		end
		def extract(html)
			writer = WhoWriter.new
			formatter = HtmlFormatter.new(writer)
			parser = HtmlParser.new(formatter)
			parser.feed(html)
			extract_descriptions(writer)
			extract_guidelines(writer)
			extract_ddd_guidelines(writer)
			extract_ddd(writer)
		end
		def extract_descriptions(writer)
			writer.extract_descriptions.each { |code, description|
				@code_handler.push(code)
				if(!(atc = @app.atc_class(code)) || atc.en != description)	
					pointer = Persistence::Pointer.new([:atc_class, code])
					@app.update(pointer.creator, {:en => description}, :who)
				end
			}
		end
		def extract_guidelines(writer)
			store_guidelines(writer.extract_guidelines, :guidelines)
		end
		def extract_ddd_guidelines(writer)
			store_guidelines(writer.extract_ddd_guidelines, :ddd_guidelines)
		end
		def extract_ddd(writer)
			writer.extract_ddd.each { |code, ddds|
				pointer = Persistence::Pointer.new([:atc_class, code])
				ddds.each { |hash|
          dkey = sprintf("%s%s", hash[:administration_route]||'*',
                         hash[:note])
					ddd_ptr = pointer + [:ddd, dkey]
					if(!(ddd = @app.resolve(ddd_ptr)) || ddd != hash)
						@app.update(ddd_ptr.creator, hash, :who)
					end
				}
			}
		end
		def store_guidelines(hash, name)
			hash.each { |code, guidelines|
				pointer = Persistence::Pointer.new([:atc_class, code],
					[name])
        if(guidelines.nil?)
          @app.delete(pointer)
        elsif(!(document = @app.resolve(pointer)) \
					|| document.en != guidelines)
					@app.update(pointer.creator, {:en => guidelines}, :who)
				end
			}
		end
	end
end
