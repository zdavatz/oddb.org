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
	#HTTP_PATH = '/frmSearchPartner.aspx?lang=de&' 
	HTTP_PATH = '/refdata_wa_medwin/frmSearchPartner.aspx?lang=de'
	FORM_KEYS = [
		[:name,	'txtSearchName'],
		[:country, 'ddlSearchCountry'],
		[:plz, 'txtSearchZIP'],
		[:city,	'txtSearchCity'],
		[:state, 'ddlSearchStates'],
		[:functions, 'ddlSearchFunctions'],
		[:ean,	'txtSearchEAN'],
	]
	def initialize(server)
		super
		resp = get(HTTP_PATH)
		handle_resp!(resp)
	end
	def post_hash(criteria, ctl=nil)
		data = if(ctl)
			[['__EVENTTARGET',
				"DgMedwinPartner:#{ctl}:_ctl0"],
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
		FORM_KEYS.each { |key, new_key|
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
			#headers.push(['User-Agent', 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.7) Gecko/20040917 Firefox/0.9.3'])
			#headers.push(['Accept', 'text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5'])
			#headers.push(['Accept-Language', 'en-us,en;q=0.5'])
			#headers.push(['Accept-Encoding', 'gzip,deflate'])
			#headers.push(['Accept-Charset', 'ISO-8859-1,utf-8;q=0.7,*;q=0.7'])
			#headers.push(['Keep-Alive', '300'])
			#headers.push(['Connection', 'keep-alive'])
			#headers.push(['Referer', 'http://www.medwin.ch/frmSearchPartner.aspx?lang=de'])
			headers.push(['Cookie', @cookie_header])
		end
		headers
	end
	def handle_resp!(resp)
		@cookie_header = resp["set-cookie"]
		@viewstate = String.new
		resp.body.each { |line|
			if(line.match(/VIEWSTATE/))
				arr = line.split('value')[1].split('"')
				@viewstate = arr[1]
			end
		}
		@viewstate
	end
	def detail_html(ctl)
		#hash = post_hash(ctl)
		hash = post_hash({}, ctl)
		resp = post(HTTP_PATH, hash)
		#@viewstate = nil
		resp.body
	end
	def get_result_list(criteria)
		hash = post_hash(criteria)
		resp = post(HTTP_PATH, hash)
		@viewstate = handle_resp!(resp)
		resp.body
	end
end
	end
end
