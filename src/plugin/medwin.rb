#!/usr/bin/env ruby
# MedwinPlugin -- oddb -- 06.10.2003 -- maege@ywesee.com

require 'plugin/plugin'
require 'util/persistence'
require 'util/html_parser'
require 'util/http'
require 'model/text'

module ODDB
	class MedwinWriter < NullWriter
		def initialize(medwin_template)
			@tablehandlers = []
			@medwin_template = medwin_template
		end
		def extract_data
			data = {}
			@tablehandlers.each { |handler|
				unless(handler.nil?)
					id = handler.attributes.first[1]
					if(id.match(/tblFind/) || id.match(/Table2/))
						data = handler.extract_cdata(@medwin_template)
					end
				end
			}
			data
		end
		def new_tablehandler(handler)
			@current_tablehandler = handler
			@tablehandlers.push(handler)
		end
		def send_flowing_data(data) 
			unless(@current_tablehandler.nil?)
				@current_tablehandler.send_cdata(data)
			end
		end
	end
	class MedwinPlugin < Plugin
		HTTP_SERVER = 'www.medwin.ch'
		def initialize(app)
			super
			@checked = 0
			@temp_count = 0
			@found = 0
			@updated = []
			@errors = {}
			@session = MedwinSession.new(HTTP_SERVER)
		end
		def check_html(obj, html)
			if(obj.respond_to?(:name))
				id = obj.name
			elsif(obj.respond_to?(:barcode))
				id = [obj.barcode, obj.name_base].join(" - ")
			end
			if(!html.index('ctl2_Link'))
				@errors.store(id, 'no search results')
				nil
			elsif(html.index('ctl3_Link'))
			  @errors.store(id, 'multiple search results')
				nil
			else
				html
			end
		end
		def extract(html)
			writer = MedwinWriter.new(@medwin_template)
			formatter = HtmlFormatter.new(writer)
			parser = HtmlParser.new(formatter)
			parser.feed(html)
			writer.extract_data
		end
	end
	class MedwinCompanyPlugin < MedwinPlugin
		HTTP_PATH = '/frmSearchPartner.aspx?lang=de' 
		def initialize(app)
			super
			@medwin_template = {
				:ean13		=>	[1,0],
				:address	=>	[1,4],
				:plz			=>	[1,5],
				:location	=>	[2,5],
				:phone		=>	[1,6],
				:fax			=>	[2,6],
			}
		end
		def company_html(comp)
			@session.http_path = HTTP_PATH
			html = @session.company_html(comp)
			check_html(comp, html)
		end
		def report
			lines = [
				"Checked #{@checked} Companies",
				"Compared #{@found} Medwin Entries",
				"Updated  #{@updated.size} Companies:",
			] + @updated.sort
			lines.push("Errors:")
			@errors.each { |key, value|
				lines.push(key + " => " + value)
			}
			lines.join("\n")
		end
		def update
			@checked = @app.companies.size
			@app.companies.each_value { |comp| 
				update_company(comp)
			}
		end
		def update_company(comp)
			#comp_name = comp.name.gsub(/\W/," ").split(" ")
			if(html = company_html(comp))
				@found += 1
				data = extract(html)
				update_company_data(comp, data)
			end
		end
		def update_company_data(comp, data)
			update = data.inject({}) { |inj, pair|
				key, val = pair
				val.gsub!(/\240/, ' ')
				val.strip!
				unless(comp.listed? || comp.has_user?)
					if(comp.respond_to?(key))
						inj.store(*pair)
					end
				end
				inj
			}
			unless(update.empty?)
				@updated.push(comp.name)
				@app.update(comp.pointer, update)
			end
		end
	end
	class MedwinPackagePlugin < MedwinPlugin
		HTTP_PATH = '/frmSearchProduct.aspx?lang=de' 
		def initialize(app)
			super
			@medwin_template = {
				:pharmacode	=>	[3,2],
			}	
		end
		def report
			lines = [
				"Checked #{@checked} Packages",
				"Compared #{@found} Medwin Entries",
				"Updated  #{@updated.size} Packages",
			]
			lines.push("Errors:")
			@errors.each { |key, value|
				lines.push(key + " => " + value)
			}
			lines.join("\n")
		end
		def update
			@app.each_package { |pack| update_package(pack) }
		end
		def update_package(pack)
			@checked += 1
#			@temp_count += 1
			if(html = package_html(pack))
				@found += 1
				data = extract(html)
				update_package_data(pack, data)
			end
=begin
			if(@temp_count==100)
				sleep 300
				@temp_count = 0
			end
=end
		end
		def update_package_data(pack, data)
			update = data.inject({}) { |inj, pair|
				key, val = pair
				val.gsub!(/\240/, ' ')
				val.strip!
				inj.store(*pair)
				inj
			}
			unless(update.empty?)
				@updated.push(pack.barcode)
				@app.update(pack.pointer, update)
			end
		end
		def package_html(pack)
			@session.http_path = HTTP_PATH
			html = @session.package_html(pack)
			if(html.is_a?(Hash))
				html.each { |id, error_type|
					@errors.store(id, error_type)
				}
				nil
			else
				check_html(pack, html)
			end
		end
	end
	class MedwinSession < HttpSession
		RETRIES = 10
		RETRY_WAIT = 120
		attr_accessor :http_path
		def build_first_post_hash(comp_name, ean13)
			{
				'__EVENTTARGET'		=>	'',
				'txtSearchName'		=>	comp_name,
				'txtSearchEAN'		=>	ean13,
				'btnSearch'				=>	'Suche',
			}
		end
		def handle_resp(html)
			value_viewstate = String.new
			html.each { |line|
				if(line.match(/VIEWSTATE/))
					arr = line.split('value')[1].split('"')
					value_viewstate = arr[1]
				end
			}
			value_viewstate
		end
		def company_html(comp)
			unless(comp.ean13.nil?)
				hash = build_first_post_hash("", comp.ean13)
			else
				name_array = comp.name.gsub(/'/, "").split(" ")
				checked_names = name_array.select { |part|
					part.size > 3
				}
				hash = build_first_post_hash(checked_names.first.downcase, "")
			end
			event_target = "DgMedwinPartner:_ctl2:_ctl0"
			medwin_html(hash, event_target, comp.name)
		end
		def post(path, hash, id)
			retr = RETRIES
			begin
				resp = @http.post(path, post_body(hash), post_headers)
				if(resp.is_a? Net::HTTPOK)
					ResponseWrapper.new(resp)
				elsif(resp.is_a? Net::HTTPNotFound)
					{id => 'connection error: not found'}
				elsif(resp.is_a? Net::HTTPFound)
					{id => 'connection error: found'}
				else
					raise("could not connect to #{@http_server}: #{resp}")
				end
			rescue Timeout::Error, Errno::EINTR 
				if(retr > 0)
					sleep RETRY_WAIT
					retr -= 1
					retry
				end
			end
		end
		def package_html(package)
			ean13 = package.barcode
			hash = build_first_post_hash("", ean13)
			event_target = "DgMedrefProduct:_ctl2:_ctl0"
			medwin_html(hash, event_target, ean13)
		end
		def medwin_html(hash, event_target, id)
			resp = post(@http_path, hash, id)
			unless(resp.is_a?(Hash))
				value_viewstate = handle_resp(resp.body)
				hash = {
					'__EVENTTARGET'		=>	event_target,
					'__VIEWSTATE'			=>	value_viewstate,
				}
				resp = post(@http_path, hash, id)
				if(resp.is_a?(Hash))
					resp
				else
					resp.body
				end
			else
				resp
			end
		end
		def get_headers 
			headers = super
			headers.store('Referer', ['http://', @http_server, @http_path].join)
			headers
		end
	end
end
