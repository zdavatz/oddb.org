#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Swissreg::Session -- oddb.org -- 18.04.2013 -- yasaka@ywesee.com
# ODDB::Swissreg::Session -- oddb.org -- 09.01.2012 -- mhatakeyama@ywesee.com
# ODDB::Swissreg::Session -- oddb.org -- 04.05.2006 -- hwyss@ywesee.com

require 'writer'
require 'hpricot'
require 'util/http'
require 'util/hpricot'
require 'iconv'

module ODDB
  module Swissreg
class Session < HttpSession
  def initialize
    host = 'www.swissreg.ch'
    super(host)
    @base_uri = "https://#{host}"
    @http.read_timeout = 120
    @http.use_ssl = true
    @http.instance_variable_set("@port", '443')
    # swissreg does not have sslv3 cert
    #@http.ssl_version = 'SSLv3'
    @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
  def extract_result_links(response)
    body = response.body
    body.force_encoding('utf-8')
    doc = Hpricot.make(body, {})
    path = "//a[@target='detail']/span[@title='zur Detailansicht']"
    url   = @base_uri + "/srclient/faces/jsp/spc/sr30.jsp"
    param = nil
    if input = (doc/"//input[@value^=SPC]").first
      param = input.attributes['value']
    else
      # Not found in swissreg.ch
    end
    if param
      state = view_state(response)
      (doc/path).collect { |span|
        unless span.inner_html =~ /^</ # skip strange images
          if span.parent['onclick'].to_s =~ /\[\[.*'(\d*)'\]\]/
            id = $1
            [url, id, state, param]
          end
        end
      }.uniq.compact
    else
      []
    end
  end
  def get(url, *args) # this method can not handle redirect
    res = super
    @referer = url
    res
  end
  def fetch(uri, limit = 5)
    raise ArgumentError, 'HTTP redirect too deep' if limit == 0
    url = URI.parse(URI.encode(uri.strip))
    option = {
      :use_ssl     => true,
      # ignore swissreg.ch cert
      :verify_mode => OpenSSL::SSL::VERIFY_NONE
    }
    response = Net::HTTP.start(url.host, option) do |http|
      http.get url.request_uri
    end
    @referer = uri
    case response
    when Net::HTTPSuccess
      response
    when Net::HTTPRedirection
      fetch(response['location'], limit - 1)
    else
      response.value
    end
  end
  def detail(url, id, state, param)
    criteria = [
      ["autoScroll", "0,0"],
      ["id_swissreg:_idcl", "id_swissreg:mainContent:data:0:id_detail"],
      ["id_swissreg:_link_hidden_", ""],
      ["id_swissreg:mainContent:id_sub_options_result:id_ckbSpcChoice", "spc_lbl_title"],
      ["id_swissreg:mainContent:id_sub_options_result:id_ckbSpcChoice", "spc_lbl_pat_type"],
      ["id_swissreg:mainContent:id_sub_options_result:id_ckbSpcChoice", "spc_lbl_basic_pat_no"],
      ["id_swissreg:mainContent:id_sub_options_result:sub_fieldset:id_cbxHitsPerPage", "25"],
      ["id_swissreg:mainContent:scroll_1", ""],
      ["id_swissreg:mainContent:vivian", param],
      ["id_swissreg_SUBMIT", "1"],
      ["javax.faces.ViewState", state],
      ["spcMainId", id]
    ]
    response = post(url, criteria)
    update_cookie(response)
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
  def get_result_list(iksnr)
    path = '/srclient/'
    # discard this first response
    # swissreg.ch could not handle cookie by redirect.
    # HTTP status code is also strange at redirection.
    response = fetch(@base_uri + path)
    # get only view state
    state = view_state(response)
    # get cookie
    path = "/srclient/faces/jsp/start.jsp"
    response = fetch(@base_uri + path)
    update_cookie(response)
    data = [
      ["autoScroll", "0,0"],
      ["id_swissreg:_link_hidden_", ""],
      ["id_swissreg_SUBMIT", "1"],
      ["id_swissreg:_idcl", "id_swissreg_sub_nav_ipiNavigation_item10"],
      ["javax.faces.ViewState", state],
    ]
    response = post(@base_uri + path, data)
    # swissreg.ch does not recognize request.
    # we must send same request again :(
    sleep(1)
    response = post(@base_uri + path, data)
    update_cookie(response)
    state = view_state(response)
    data = [
      ["autoScroll", "0,0"],
      ["id_swissreg:_link_hidden_", ""],
      ["id_swissreg:mainContent:id_txf_basic_pat_no",""],
      ["id_swissreg:mainContent:id_txf_spc_no",""],
      ["id_swissreg:mainContent:id_txf_title",""],
      ["id_swissreg_SUBMIT", "1"],
      ["id_swissreg:_idcl", "id_swissreg_sub_nav_ipiNavigation_item10_item13"],
      ["javax.faces.ViewState", state],
    ]
    path = "/srclient/faces/jsp/spc/sr1.jsp"
    response = post(@base_uri + path, data)
    update_cookie(response)
    criteria = [
      ["autoScroll", "0,0"],
      ["id_swissreg:_idcl", ""],
      ["id_swissreg:_link_hidden_", ""],
      ["id_swissreg:mainContent:id_cbxHitsPerPage", "25"],
      ["id_swissreg:mainContent:id_cbxSpcAppCountry", "_ALL"],
      ["id_swissreg:mainContent:id_cbxSpcAppSearchMode", "_ALL"],
      ["id_swissreg:mainContent:id_cbxSpcAuthority", "_ALL"],
      ["id_swissreg:mainContent:id_cbxSpcFormatChoice", "1"],
      ["id_swissreg:mainContent:id_cbxSpcLanguage", "_ALL"],
      ["id_swissreg:mainContent:id_ckbSpcChoice", "spc_lbl_title"],
      ["id_swissreg:mainContent:id_ckbSpcChoice", "spc_lbl_pat_type"],
      ["id_swissreg:mainContent:id_ckbSpcChoice", "spc_lbl_basic_pat_no"],
      ["id_swissreg:mainContent:id_ckbSpcPubReason", "1"],
      ["id_swissreg:mainContent:id_ckbSpcPubReason", "2"],
      ["id_swissreg:mainContent:id_ckbSpcPubReason", "7"],
      ["id_swissreg:mainContent:id_ckbSpcPubReason", "8"],
      ["id_swissreg:mainContent:id_ckbSpcPubReason", "3"],
      ["id_swissreg:mainContent:id_ckbSpcPubReason", "4"],
      ["id_swissreg:mainContent:id_ckbSpcPubReason", "5"],
      ["id_swissreg:mainContent:id_ckbSpcPubReason", "6"],
      ["id_swissreg:mainContent:id_ckbSpcViewState", "act"],
      ["id_swissreg:mainContent:id_ckbSpcViewState", "pen"],
      ["id_swissreg:mainContent:id_ckbSpcViewState", "del"],
      ["id_swissreg:mainContent:id_txf_agent", ""],
      ["id_swissreg:mainContent:id_txf_app_city", ""],
      ["id_swissreg:mainContent:id_txf_app_date", ""],
      ["id_swissreg:mainContent:id_txf_applicant", ""],
      ["id_swissreg:mainContent:id_txf_auth_date", ""],
      ["id_swissreg:mainContent:id_txf_auth_no", iksnr],
      ["id_swissreg:mainContent:id_txf_basic_pat_no", ""],
      ["id_swissreg:mainContent:id_txf_basic_pat_start_date", ""],
      ["id_swissreg:mainContent:id_txf_del_date", ""],
      ["id_swissreg:mainContent:id_txf_expiry_date", ""],
      ["id_swissreg:mainContent:id_txf_grant_date", ""],
      ["id_swissreg:mainContent:id_txf_pub_app_date", ""],
      ["id_swissreg:mainContent:id_txf_pub_date", ""],
      ["id_swissreg:mainContent:id_txf_spc_no", ""],
      ["id_swissreg:mainContent:id_txf_title", ""],
      ["id_swissreg:mainContent:sub_fieldset:id_submit", "suchen"],
      ["id_swissreg_SUBMIT", "1"],
      ["javax.faces.ViewState", view_state(response)]
    ]
    path = "/srclient/faces/jsp/spc/sr3.jsp"
    response = post(@base_uri + path, criteria)
    update_cookie(response)
    extract_result_links(response)
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
