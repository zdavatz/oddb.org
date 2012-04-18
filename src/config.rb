#!/usr/bin/env ruby
# encoding: utf-8
# @config -- oddb.org -- 18.04.2012 -- yasaka@ywesee.com
# @config -- oddb.org -- 29.02.2012 -- mhatakeyama@ywesee.com
# @config -- oddb.org -- 08.09.2006 -- hwyss@ywesee.com

require 'rclconf'

module ODDB
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
    'url_bag_sl_zip'      => 'http://bag.e-mediat.net/SL2007.Web.External/File.axd?file=XMLPublications.zip',
    'bsv_archives'        => '(?:PR|BSV_per_20)(0[3-8])[\d.]+(?:txt|xls)',
    'server_url'          => 'druby://localhost:10000',
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
    'mail_to'             => [],
    'testenvironment1'    => '',
    'testenvironment2'    => '',
    'flickr_api_key'       => '',
    'flickr_shared_secret' => '',
    'app_user_agent'       => '', # as Regexp
  }

  config = RCLConf::RCLConf.new(ARGV, defaults)
  config.load(config.config)
  @config = config
  def ODDB.config
    @config
  end
end
