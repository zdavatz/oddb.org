#!/usr/bin/env ruby
# encoding: utf-8
# @config -- oddb.org -- 18.04.2012 -- yasaka@ywesee.com
# @config -- oddb.org -- 29.02.2012 -- mhatakeyama@ywesee.com
# @config -- oddb.org -- 08.09.2006 -- hwyss@ywesee.com

require 'rclconf'

module ODDB
  SERVER_URI ||="druby://127.0.0.1:10000"
  SERVER_NAME ||='ch.oddb.org'
  SERVER_URI_FOR_CRAWLER ||="druby://127.0.0.1:10001"
  SERVER_URI_FOR_GOOGLE_CRAWLER ||="druby://127.0.0.1:10008"
  FIPARSE_URI ||="druby://127.0.0.1:10002"
  FIPDF_URI ||="druby://127.0.0.1:10003"
  DOCPARSE_URI ||="druby://127.0.0.1:10004"
  EXPORT_URI ||="druby://127.0.0.1:10005"
  MEDDATA_URI ||="druby://127.0.0.1:10006"
  SWISSREG_URI ||="druby://127.0.0.1:10007"
  READONLY_URI ||="druby://127.0.0.1:10013"
  YUS_URI ||="drbssl://127.0.0.1:9997"
  MIGEL_URI ||='druby://127.0.0.1:33000'
  YUS_DOMAIN ||='oddb.org'

  oddb_dir = File.expand_path('..', File.dirname(__FILE__))
  default_dir = File.expand_path('etc', oddb_dir)
  default_config_files = [
    File.join(default_dir, 'oddb.yml'),
    '/etc/oddb/oddb.yml',
  ]
  defaults = {
    'config'			        => default_config_files,
    'data_dir'            => File.expand_path('../data', File.dirname(__FILE__)),
    'log_dir'             => File.expand_path('../log', File.dirname(__FILE__)),
    'log_pattern'         => File.join(Dir.pwd, defined?(MiniTest) ? 'test/log' : 'log','/%Y/%m/%d/app_log'),
    'url_bag_sl_zip'      => 'http://www.xn--spezialittenliste-yqb.ch/File.axd?file=XMLPublications.zip',
    'bsv_archives'        => '(?:PR|BSV_per_20)(0[3-8])[\d.]+(?:txt|xls)',
    'server_url'          => SERVER_URI,
    'migel_base_url'      =>  'https://migel_base_url.net/wsv/wv_getMigel.aspx?Lang=DE&Query', # non working default
    'smtp_authtype'       => :plain,
    'smtp_domain'         => 'oddb.org',
    'smtp_server'         => 'localhost',
    'smtp_user'           => nil,
    'smtp_pass'           => nil,
    'smtp_port'           => 587,
    'text_info_searchform'=> nil,
    'text_info_searchform2' => nil,
    'text_info_max_retry' => 5,
    'text_info_newssource'=> nil,
    'mail_from'           => '"ODDB-Mails" <mail@oddb.org>',
    'invoice_from'        => '"ODDB-Invoices" <cfo@oddb.org>',
    'reply_to'            => 'reply_to@oddb.org',
    'mail_to'             => [],
    'testenvironment1'    => '',
    'testenvironment2'    => '',
    'flickr_api_key'       => '',
    'flickr_shared_secret' => '',
    'scrolliris_project_id'   => '',
    'scrolliris_fi_write_key' => '',
    'scrolliris_fi_read_key'  => '',
    'scrolliris_pi_write_key' => '',
    'scrolliris_pi_read_key'  => '',
    'app_user_agent'       => '', # as Regexp
    'paypal_server'        => 'www.paypal.com',     # or www.sandbox.paypal.com
    'paypal_receiver'      => 'zdavatz@ywesee.com', # or test_paypal@ywesee.com
  }

  config = RCLConf::RCLConf.new(ARGV, defaults)
  config.load(config.config)
  @config = config
  def ODDB.config
    @config
  end
end
