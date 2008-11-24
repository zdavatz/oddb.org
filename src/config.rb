#!/usr/bin/env ruby
# @config -- de.oddb.org -- 08.09.2006 -- hwyss@ywesee.com

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
    'url_bag_sl_zip'      => 'http://bag.e-mediat.net/SL2007.Web.External/File.axd?file=XMLPublications.zip',
  }

  config = RCLConf::RCLConf.new(ARGV, defaults)
  config.load(config.config)
  @config = config
  def ODDB.config
    @config
  end
end
