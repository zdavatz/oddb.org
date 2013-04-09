#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Swissreg::Session -- oddb.org -- 10.04.2013 -- yasaka@ywesee.com
# ODDB::Swissreg::Session -- oddb.org -- 09.01.2012 -- mhatakeyama@ywesee.com
# ODDB::Swissreg::Session -- oddb.org -- 04.05.2006 -- hwyss@ywesee.com

require 'writer'
require 'hpricot'
require 'util/http'
require 'iconv'

module ODDB
  module Swissreg
class Session < HttpSession
  def initialize
    super('www.swissreg.ch')
    @http.read_timeout = 120
    @http.use_ssl = true
    @http.instance_variable_set("@port", '443')
    # swissreg does not have sslv3 cert
    #@http.ssl_version = 'SSLv3'
    @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
  def extract_result_links(html)
    doc = Hpricot.make(html, {})
    path = "//a[@target='detail']/span[@title='zur Detailansicht']"
    link = "/srclient/faces/jsp/spc/sr300.jsp?language=de&section=spc&id=%s"
    (doc/path).collect { |span|
      link % span.inner_html
    }
  end
  def get(url, *args) # this method can not handle redirect
    res = super
    @referer = url
    res
  end
  def fetch(uri, limit = 5)
    raise ArgumentError, 'HTTP redirect too deep' if limit == 0
    url = URI.parse(uri)
    option = {
      :use_ssl     => true,
      # ignore swissreg.ch cert
      :verify_mode => OpenSSL::SSL::VERIFY_NONE
    }
    response = Net::HTTP.start(url.host, option) do |http|
      http.get url.request_uri
    end
    case response
    when Net::HTTPSuccess
      response
    when Net::HTTPRedirection
      fetch(response['location'], limit - 1)
    else
      response.value
    end
  end
  def get_detail(url)
    response = fetch(url)
    writer = DetailWriter.new
    formatter = ODDB::HtmlFormatter.new(writer)
    parser = ODDB::HtmlParser.new(formatter)
    parser.feed(response.body)
    writer.extract_data
  rescue Timeout::Error
    {}
  end
  def get_headers
    hdrs = super
    if(@cookie_id)
      hdrs.push(['Cookie', @cookie_id])
    end
    hdrs
  end
  def get_result_list(substance)
    base_uri = 'https://www.swissreg.ch'
    path = '/srclient/'
    # discard this first response
    # swissreg.ch could not handle cookie by redirect.
    # HTTP status code is also strange at redirection.
    response = fetch(base_uri + path)
    # get only view state
    state = view_state(response)
    # get cookie
    path = "/srclient/faces/jsp/start.jsp"
    response = fetch(base_uri + path)
    update_cookie(response)
    data = [
      ["autoScroll", "0,91"],
      ["id_swissreg:_link_hidden_", ""],
      ["id_swissreg_SUBMIT", "1"],
      ["id_swissreg:_idcl", "id_swissreg_sub_nav_ipiNavigation_item0"],
      ["javax.faces.ViewState", state],
    ]
    response = post(base_uri + path, data)
    update_cookie(response)
    criteria = [
      ["autoScroll", "0,169"],
      ["id_swissreg:mainContent:id_txf_tm_no", ""],
      ["id_swissreg:mainContent:id_txf_app_no", ""],
      ["id_swissreg:mainContent:id_txf_tm_text", "%s*" % substance],
      ["id_swissreg:mainContent:id_txf_applicant", ""],
      #["id_swissreg:mainContent:empty_hits:_idJsp154", false]
      ["id_swissreg:mainContent:sub_fieldset:id_submit", "suchen"],
      ["id_swissreg_SUBMIT", "1"],
      ["id_swissreg:_idcl", ""],
      ["id_swissreg:_link_hidden_", ""],
      ["javax.faces.ViewState", view_state(response)],
    ]
    path = "/srclient/faces/jsp/spc/sr1.jsp"
    response = post(base_uri + path, criteria)
    update_cookie(response)
    extract_result_links(response.body)
  rescue Timeout::Error
    []
  end
  def post(url, *args)
    res = super
    @referer = url
    res
  end
  def update_cookie(response)
    if(hdr = response['set-cookie'])
      @cookie_id = hdr[/^[^;]+/u]
    end
  end
  def view_state(response)
    if match = /javax.faces.ViewState.*?value="([^"]+)"/u.match(response.body.force_encoding('utf-8'))
      match[1]
    else
      ""
    end
  end
end
  end
end
