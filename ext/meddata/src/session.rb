#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::MedData::Session -- oddb.org -- 22.04.2013 -- yasaka@ywesee.com
# ODDB::MedData::Session -- oddb.org -- 27.12.2011 -- mhatakeyama@ywesee.com
# ODDB::MedData::Session -- oddb.org -- 09.12.2004 -- jlang@ywesee.com

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
		:refdata => [
			[:name,	'txtSearchProductName'],
			[:ean,	'txtSearchEAN'],
			[:company,	'txtSearchProducer'],
		],
	}
	HTTP_PATHS = {
		:partner =>	'/refdata_wa_medwin/frmSearchPartner.aspx?lang=de',
		:product =>	'/refdata_wa_medwin/frmSearchProduct.aspx?lang=de',
		:refdata => '/refdata_wa/frmSearchProduct.aspx?lang=de'
	}
	DETAIL_KEYS = {
		:partner => "DgMedwinPartner",
		:product => "DgMedrefProduct",
		:refdata => "DgMedrefProduct",
	}
	SERVERS = {
		:partner	=>	'www.medwin.ch',
		:product	=>	'www.medwin.ch',
		:refdata	=>	'www.refdata.ch',
	}
	attr_accessor :http_path, :form_keys, :detail_key, :sleeps_in_seconds # usually 1, but 0.01 while running Tests
	def initialize(search_type=:partner, server=SERVERS[search_type])
		@http_path = HTTP_PATHS[search_type]
		@form_keys = FORM_KEYS[search_type]
		@detail_key = DETAIL_KEYS[search_type]
    @sleeps_in_seconds = Module.constants.index(:MiniTest) ? 0.01 : 1
		super(server)
    resp = get '/'    
    sleep(2*@sleeps_in_seconds) # for Timeout::Error
    resp = get @http_path
		handle_resp!(resp)
  rescue Timeout::Error => err
    raise err.exception(err.message + " - #{server} is not responding")
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
				sleep(3*@sleeps_in_seconds - tries*@sleeps_in_seconds)
				retry
			else
				raise
			end
		end
	end
	def handle_resp!(resp)
		@cookie_header = resp["set-cookie"]
    body = resp.body
    body.force_encoding('utf-8')
    begin
      if(match = /VIEWSTATE.*?value="([^"]+)"/u.match(body))
        @viewstate = match[1]
      else
        @viewstate = nil
      end
      if(match = /EVENTVALIDATION.*?value="([^"]+)"/u.match(body))
        @eventvalidation = match[1]
      else
        @eventvalidation = nil
      end
    rescue
      @viewstate = nil
    end
		@viewstate
	end
	def get_result_list(criteria)
		hash = post_hash(criteria)
		resp = post(self.http_path, hash)
		@viewstate = handle_resp!(resp)
		resp.body
  rescue Errno::ENETUNREACH
    retries ||= 3
    if retries > 0
      retries -= 1
      sleep 60*@sleeps_in_seconds # wait a minute for the network to recover
      retry
    else
      raise
    end
  rescue RuntimeError => err
    if /InternalServerError/u.match err.message
      require 'pp'
      puts "error for criteria: #{criteria.pretty_inspect}"
      puts "... post_data: #{hash.pretty_inspect}"
      retries ||= 3
      if retries > 0
        retries -= 1
        sleep 600*@sleeps_in_seconds # wait 10 minutes for the server to recover
        retry
      else
        raise
      end
    else
      raise
    end
	end
  def post_hash(criteria, ctl=nil)
    data = if(ctl)
      [['__EVENTTARGET',
        "#@detail_key$#{ctl}$ctl00"],
        ['__EVENTARGUMENT',  ''],
      ]
    else
      [
        ['__EVENTTARGET',  ''],
        ['__EVENTARGUMENT',  ''],
        ['btnSearch',  'Suche'],
      ]
    end
    if(@viewstate)
      data.push(['__VIEWSTATE', @viewstate])
    end
    if @eventvalidation
      data.push(['__EVENTVALIDATION', @eventvalidation])
    end
    @form_keys.each { |key, new_key|
      if(val = criteria[key])
        data.push([new_key, CGI.escape(val).tr('+', ' ').gsub('%5B', '[').gsub('%5D', ']')])
      end
    }
    data.push(['hiddenlang',  'de'])
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
