require 'drb'
require 'config'
require 'util/oddbapp'
require 'etc/db_connection'

module ODDB
  module Util
module Job
  def Job.run opts={}, &block
    system = DRb::DRbObject.new(nil, ODDB.config.server_url)
    DRb.start_service
    begin
      ODBA.cache.setup
      ODBA.cache.clean_prefetched
      DRb.install_id_conv ODBA::DRbIdConv.new
      system.peer_cache ODBA.cache unless opts[:readonly]
      block.call ODDB::App.new
    ensure
      system.unpeer_cache ODBA.cache unless opts[:readonly]
    end
  end
end
  end
end
