#!/usr/bin/env ruby
# -- oddb -- 09.12.2004 -- jlang@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))
$: << File.dirname(__FILE__)

require 'util/http'
require 'util/html_parser'
require 'cgi'

module ODDB
	module MedData
class Session < HttpSession
	FORM_KEYS = {
		:partner => [
			[:name,	'txtSearchName'],
			[:country, 'ddlSearchCountry'],
			[:plz, 'txtSearchZIP'],
			[:city,	'txtSearchCity'],
			[:state, 'ddlSearchStates'],
			[:functions, 'ddlSearchFunctions'],
			[:ean,	'txtSearchEAN'],
		],
		:product => [
			[:name,	'txtSearchProductName'],
			[:ean,	'txtSearchEAN'],
			[:pharmacode, 'txtSearchPharmacode'],
			[:company,	'txtSearchProducer'],
		],
	}
	HTTP_PATHS = {
		:partner =>	'/refdata_wa_medwin/frmSearchPartner.aspx?lang=de',
		:product =>	'/refdata_wa_medwin/frmSearchProduct.aspx?lang=de',
	}
	DETAIL_KEYS = {
		:partner => "DgMedwinPartner",
		:product => "DgMedrefProduct",
	}
	attr_accessor :http_path, :form_keys, :detail_key
	def initialize(server, search_type=:partner)
		@http_path = HTTP_PATHS[search_type]
		@form_keys = FORM_KEYS[search_type]
		@detail_key = DETAIL_KEYS[search_type]
		super(server)
		resp = get(self)
		handle_resp!(resp)
	end
	def detail_html(ctl)
		hash = post_hash({}, ctl)
		tries = 3
		begin
			resp = post(@http_path, hash)
			resp.body
		rescue Errno::ECONNRESET
			if(tries > 0)
				tries -= 1
				sleep(3 - tries)
				retry
			else
				raise
			end
		end
	end
	def handle_resp!(resp)
		@cookie_header = resp["set-cookie"]
		resp.body.each { |line|
			if(line.match(/VIEWSTATE/))
				arr = line.split('value')[1].split('"')
				@viewstate = arr[1]
			end
		}
		@viewstate
	end
	def get_result_list(criteria)
		hash = post_hash(criteria)
		resp = post(self.http_path, hash)
		@viewstate = handle_resp!(resp)
		resp.body
	end
	def post_hash(criteria, ctl=nil)
		data = if(ctl)
			[['__EVENTTARGET',
				"#@detail_key:#{ctl}:_ctl0"],
				['__EVENTARGUMENT',	''],
			]
		else
			[
				['__EVENTTARGET',	''],
				['__EVENTARGUMENT',	''],
		    ['btnSearch',	'Suche'],
			]
		end
		if(@viewstate)
			data.push(['__VIEWSTATE', @viewstate])
		end
		@form_keys.each { |key, new_key|
			if(val = criteria[key])
				val = Iconv.iconv('utf8', 'latin1', val.to_s).first
				data.push([new_key, val])
			end
		}
		data.push(['hiddenlang',	'de'])
		data
	end
	def post_headers
		headers = super
		if(@cookie_header)
			headers.push(['Cookie', @cookie_header])
		end
		headers
	end
end
	end
end
