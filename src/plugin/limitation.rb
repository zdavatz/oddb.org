#!/usr/bin/env ruby
# LimitationPlugin -- oddb -- 05.11.2003 -- mhuggler@ywesee.com

require 'plugin/plugin'
require 'util/html_parser'
require 'model/text'

module ODDB
	class LimitationResult
		attr_accessor :link
		attr_reader :iksnr, :languages
		def initialize(iksnr, languages, par_count)
			@iksnr = iksnr
			@languages = languages
			@par_count = par_count
		end
		def acceptable?
			true
		end
	end
	class GeneralLimitationResult < LimitationResult
		ACCEPTABLE_LINKS = ['5501.htm', '5810.htm', '4875.htm','5900.htm', 
			'6037.htm']
    #TODO: '4665.htm', 
		def acceptable?
			@par_count == 1 || ACCEPTABLE_LINKS.include?(@link)
		end
	end
	class LimitationIndexWriter < NullWriter
		attr_reader :collected_values
		def initialize
			@linkhandlers = []
			@collected_values = []
		end
		def extract_data
			@linkhandlers.each { |lh|
				unless(lh.nil?)
					value = lh.value
					href = lh.attribute('href')
					@collected_values << href
				end
			}
		end
		def new_linkhandler(handler)
			@current_linkhandler = handler
			@linkhandlers.push(handler)
		end
		def send_flowing_data(data) 
			unless(@current_linkhandler.nil?)
				@current_linkhandler.send_adata(data)
			end
		end
	end
	class LimitationSequenceWriter < NullWriter
		attr_reader :collected_values
    UNPARSEABLE = { 
      '[57856 001] (363 10 14)' => [2,1,2],
      '[57862 001] (348 21 69)' => [5,4,5],
    }
		def initialize
			@tablehandlers = []
			@collected_values = {}
		end
		def get_limitations
			limitations = []
			limhandler = nil
			@tablehandlers.each { |th|
				unless(th.nil?)
					th.each_row { |row|
						if(row.cdata(0)=='(L)' && row.cdata(2)!='Andere')
							limhandler = ODDB::HtmlLimitationHandler.new
							limitations.push(limhandler)
						end
						unless(limhandler.nil?)
							if(row.cdata(1).match(/^[0-9]{5}$/))
								th.each_row { |tr|
									limhandler.feed(tr)
								}
								limhandler = nil
							else
								limhandler.feed(row)
							end
						end
					}
				end
			}
			limitations
		end
		def extract_data
			limitations = get_limitations
			limitations.inject([]) { |data, lim|
				values = []
				keys = []
				lim.rows.each { |row|
					unless(row.cdata(5).nil?)
						keys << row.cdata(5)
					end
					if(row.cdata(2).is_a?(Array))
						values << row.cdata(2)
					end
				}
				klass = ODDB::LimitationResult
				if(values.empty?)
					klass = ODDB::GeneralLimitationResult
					values = parse_limitatio
				end
				keys.each { |key|
					if(pair = handle_data(key, values))
						iksnr, languages = pair
						data.push(klass.new(iksnr, languages, values.size))
					end
				}
				data
			}
		end
		def handle_data(key, values)
			limitatio = false
			chap_de = Text::Chapter.new
			chap_fr = Text::Chapter.new
			chap_it = Text::Chapter.new
			values.each { |array| 
        sec_de = chap_de.next_section
				de = sec_de.next_paragraph
        sec_fr = chap_fr.next_section
				fr = sec_fr.next_paragraph
        sec_it = chap_it.next_section
				it = sec_it.next_paragraph
        lines_de = lines_fr = lines_it = lines = [array.size / 3, 1].max
        if( manual = UNPARSEABLE[key] )
          lines_de, lines_fr, lines_it = manual
          lines = manual.max
        end
				array.each_with_index { |value, idx|
					if(value.match(/^Limitatio:/))
						limitatio = true
						de << value[11..-1]
						fr << array[lines_de].to_s
						it << array[lines_de + lines_fr].to_s
            1.upto(lines - 1) { |offset|
              if(offset < lines_de)
                sec_de.next_paragraph << array[offset].to_s
              end
              if(offset < lines_fr)
                sec_fr.next_paragraph << array[lines_de + offset].to_s
              end
              if(offset < lines_it)
                sec_it.next_paragraph << array[lines_de + lines_fr + offset].to_s
              end
            }
					end
				}
			}
			values = {
				'de'	=>	chap_de,
				'fr'	=>	chap_fr,
				'it'	=>	chap_it,
			}
			if(limitatio)
				ikskey, pkg = key[1,9].split(" ")
				## bsv and swissmedic do not agree on the id of vaccines
				if(ikskey == '00000')
					ikskey = sprintf('%05i', pkg)
					pkg = '000'
				end
				[[ikskey, pkg], values]
			end
		end
		def new_tablehandler(handler)
			@current_tablehandler = handler
			@tablehandlers.push(handler)
		end
		def parse_limitatio
			limitatio = []
			@tablehandlers.each { |th|
				unless(th.nil?)
					th.each_row { |row|
						if((cdata = row.cdata(2)) && cdata.is_a?(Array))	
							cdata.each { |data|
								if(data.match(/^Limitatio:/))
									limitatio.push(cdata)
								end
							}
						end
					}
				end
			}
			limitatio
		end
		def send_flowing_data(data) 
			unless(@current_tablehandler.nil?)
				@current_tablehandler.send_cdata(data)
			end
		end
		def send_line_break
			unless(@current_tablehandler.nil?)
				@current_tablehandler.next_line
			end
		end
	end
	class LimitationPlugin < Plugin
		HTTP_SERVER = 'www.galinfo.net'
		HTML_PATH = '/sl/batchhtm'
		EXT = 'htm'
		#RANGE = ['O']
		RANGE = ('A'..'Z').to_a
		RECIPIENTS = []
		RETRIES = 3
		RETRY_WAIT = 5
		def initialize(app)
			@app = app
			@indices = []
			@updated_packages = []
			@parsing_errors = {}
		end
		def check_data(data)
			unless(data.nil? || data.empty?)	
				update_packages(data)
			end
		end
		def collect_parsed_indices
			RANGE.each { |letter|
				if(data = index_data(letter))
					@indices.concat(data)
				end
			}
		end
		def index_data(letter)
			if(body = index_data_body(letter))
				parse_index_data(body)
			end
		end
		def index_data_body(letter)
			retr = RETRIES
			begin
				session = Net::HTTP.new(HTTP_SERVER)
				resp = session.get(index_data_path(letter))
				if(resp.is_a? Net::HTTPOK)
					resp.body
				end
			rescue Timeout::Error
				if(retr > 0)
					sleep RETRY_WAIT
					retr -= 1
					retry
				end
			end
		end
		def index_data_path(letter)
			attributes = {
				'Index'	=>	letter,	
			}
			index_path(attributes)
		end
		def index_path(hsh)
			attributes = hsh.sort.collect { |pair| 
				pair.join('_')
			}.join('&')
			[[ HTML_PATH, attributes].join('/'), EXT ].join('.')
		end
		def sequence_data(link)
			if(body = sequence_data_body(link))
				parse_sequence_data(body, link)
			end
		end
		def sequence_data_body(link)
			retr = RETRIES
			begin
				session = Net::HTTP.new(HTTP_SERVER)
				resp = session.get(sequence_data_path(link))
				if(resp.is_a? Net::HTTPOK)
					resp.body
				end
			rescue Timeout::Error
				if(retr > 0)
					sleep RETRY_WAIT
					retr -= 1
					retry
				end
			end
		end
		def sequence_data_path(link)
			[ HTML_PATH, link].join('/')
		end
		def parse_index_data(html)
			writer = LimitationIndexWriter.new
			formatter = HtmlFormatter.new(writer)
			parser = HtmlParser.new(formatter)
			parser.feed(html)
			writer.extract_data
			writer.collected_values
		end
		def parse_sequence_data(html, link)
			writer = LimitationSequenceWriter.new
			formatter = HtmlFormatter.new(writer)
			parser = HtmlParser.new(formatter)
			parser.feed(html)
			limitations = writer.extract_data
			res = {}
			limitations.each { |lim|
				lim.link = link
				if(lim.acceptable?)
					res.store(lim.iksnr, lim.languages)
				else
					@parsing_errors.store(link, 'more than one general-limitation found.')
				end
			}
			res
		end
		def purge_limitation_texts
			@app.each_package { |pack| 
				sl_entry = pack.sl_entry
				unless(sl_entry.nil? || @updated_packages.include?(pack))
					if(limit = sl_entry.limitation_text)
						@app.delete(limit.pointer)
					end
				end
			}
		end
		def report
			errors = []
			unless(@parsing_errors.empty?)
				@parsing_errors.to_a.each { |error|
					errors << error.join(" => ")	
				}
			end
			lines = [
				"updated packages: #{@updated_packages.size}",
				"parsing errors:   #{@parsing_errors.size}",
			] + errors.sort
			lines.join("\n")
		end
		def update
			collect_parsed_indices
			@indices.each { |link|
				data = sequence_data(link)
				check_data(data)
			}
			purge_limitation_texts
		end
		def update_package(pack, values)
			sl_pointer = pack.pointer + [:sl_entry]
			unless(pack.sl_entry)
				@app.update(sl_pointer.creator, {:limitation => true}, 
									 :galinfo)
			end
			@updated_packages.push(pack)
			pointer = sl_pointer + [:limitation_text]
			@app.update(pointer.creator, values, :galinfo)
		end
		def update_packages(data_hsh)
			data_hsh.each { |ikskey, values|
				if(reg = @app.registration(ikskey[0]))
					if(pack = reg.package(ikskey[1]))
						update_package(pack, values)
					elsif(ikskey[1] == '000')
						## vaccines and blood-substitutes have no ikscd
						reg.each_package { |pack|
							update_package(pack, values)
						}
					end
				end
			}
		end
	end
end
