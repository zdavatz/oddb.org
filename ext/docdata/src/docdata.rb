#!/usr/bin/env ruby
# DoctorParser -- oddb -- 20.10.2003 -- maege@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))
$: << File.dirname(__FILE__)

require 'plugin/plugin'
require 'util/html_parser'
#require 'util/http'
require 'plugin/medwin'
require 'iconv'
require 'cgi'
require 'csv'
require 'parser'
require 'drb/drb'
require 'util/oddbconfig'
require 'ext/meddata/src/result'
#require 'ext/meddata/src/session'

module ODDB
	module DocData
		MEDDATA_SERVER = DRbObject.new(nil, MEDDATA_URI)
		HTTP_SERVER = 'www.emh.ch'
		HTML_PATH = '/medical_adresses/physicians_fmh/detail.cfm'
		RETRIES = 3
		RETRY_WAIT = 5
		def data_path(doc_id)
			attributes = {
				'ds1nr'	=>	doc_id,	
			}
			doc_path(attributes)
		end
		def doc_path(hsh)
			attributes = hsh.sort.collect { |pair| 
				pair.join('=')
			}.join('&')
			[ HTML_PATH, attributes ].join('?')
		end
	def doc_data(doc_id)
			html = doc_data_body(doc_id)
			if(html.index('Name:'))
				parse_doc_data(html)
			else
				nil
			end
		end
		def doc_data_body(doc_id)
			retr = RETRIES
			begin
				session = Net::HTTP.new(HTTP_SERVER)
				resp = session.get(data_path(doc_id))
				if(resp.is_a? Net::HTTPOK)
					enc_resp = ODDB::HttpSession::ResponseWrapper.new(resp)
					enc_resp.body
				end
			rescue Timeout::Error
				if(retr > 0)
					sleep RETRY_WAIT
					retr -= 1
					retry
				end
			end
		end
		def doc_data_add_ean(doc_id)
			data = doc_data(doc_id)
			# define Struct
			_define_struct
			unless(data.nil?)
				result = MEDDATA_SERVER.search(data)
				keys = []
				result.select { |value|
					if(value[1] == data[:firstname])
						keys.push(key)
					end
				}
				ean13 = nil
				if(keys.size == 1)
					ean13 = parse_medwin_detail_data(MEDDATA_SERVER.detail_html(keys.first))[:ean13]
					puts "######### >>> #{ean13}"
				end
				unless(ean13.nil?)
					data.store(:ean13, ean13)
				end
			end
			data
		end
		def parse_doc_data(html)
			writer = DoctorWriter.new
			formatter = DoctorFormatter.new(writer)
			parser = HtmlParser.new(formatter)
			parser.feed(html)
			writer.extract_data
			writer.collected_values
		end
		def _define_struct
			Struct.new("Result", :session, :values, :ctl)
		end

module_function :data_path
module_function :doc_path
module_function :doc_data
module_function :doc_data_body
module_function :doc_data_add_ean
module_function :parse_doc_data
module_function :_define_struct
	end
end
