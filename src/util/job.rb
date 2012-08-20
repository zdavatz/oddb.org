# encoding: utf-8
require 'drb'
require 'config'
require 'util/oddbapp'
require 'etc/db_connection'

module ODDB
  module Util
module Job
  LOG_ROOT = File.expand_path('log', PROJECT_ROOT)
	PID_FILE = File.expand_path('job.pid', LOG_ROOT)
  def Job.run opts={}, &block
    pid = Job.running_pid
    job = File.basename($0)
    system = DRb::DRbObject.new(nil, ODDB.config.server_url)
    DRb.start_service
    begin
      if pid
        puts "Process #{pid} is running"
        # email notification
      else
        File.open(PID_FILE, 'w'){ |fh| fh << [Process.pid, job, Time.now].join(',') }
        puts "#{PID_FILE} is created"
        ODBA.cache.setup
        ODBA.cache.clean_prefetched
        DRb.install_id_conv ODBA::DRbIdConv.new
        system.peer_cache ODBA.cache unless opts[:readonly] rescue Errno::ECONNREFUSED
        block.call ODDB::App.new(:auxiliary => true)
      end
    ensure
      unless pid
        File.unlink(path)
        puts "#{PID_FILE} is deleted"
        system.unpeer_cache ODBA.cache unless opts[:readonly]
      end
    end
  end
  def Job.running_pid
    if File.exists?(PID_FILE)
      (File.read(PID_FILE) || '').split(',')[0]
    end
  end
end
  end
end
