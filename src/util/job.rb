# encoding: utf-8
require 'drb'
require 'config'
require 'util/oddbapp'
require 'util/log'
require 'etc/db_connection'

module ODDB
  module Util
module Job
  LOG_ROOT = File.expand_path('log', PROJECT_ROOT)
  PID_FILE = File.expand_path('job.pid', LOG_ROOT)
  def Job.run opts={}, &block
    system = DRb::DRbObject.new(nil, ODDB.config.server_url)
    DRb.start_service
    begin
      if updater? and running_job[:pid]
        puts "Process #{running_job[:pid]} is running"
        # email notification
        log = Log.new(Date.today)
        log.report = [
          "Task: Job #{current_job[:basename]}",
          "Error: Job was halted (Duplicate Updater).",
          "Message: Previous Job #{running_job[:basename]} (pid: #{running_job[:pid]}) is running.",
          "",
          PID_FILE
        ].join("\n")
        log.notify("Duplicate Job: #{current_job[:basename]}")
      else
        if updater?
          File.open(PID_FILE, 'w') { |fh|
            fh << [Process.pid, current_job[:basename], Time.now].join(',')
          }
          puts "#{PID_FILE} is created"
        end
        ODBA.cache.setup
        ODBA.cache.clean_prefetched
        DRb.install_id_conv ODBA::DRbIdConv.new
        system.peer_cache ODBA.cache unless opts[:readonly] rescue Errno::ECONNREFUSED
        block.call ODDB::App.new(:auxiliary => true)
      end
    rescue Interrupt # C-c
      puts "Interrupted !!"
      puts "Please check #{PID_FILE}."
      puts
    ensure
      if updater? and !running_job[:pid]
        File.unlink(PID_FILE)
        puts "#{PID_FILE} is deleted"
        system.unpeer_cache ODBA.cache unless opts[:readonly]
      end
    end
  end
  def Job.current_job
    @current_job ||= {
      :pid      => Process.pid,
      :basename => File.basename($0),
      :time     => Time.now
    }
  end
  def Job.running_job
    unless @running_job
      @running_job = {}
      if File.exists?(PID_FILE)
        values = (File.read(PID_FILE) || '').split(',')
      else
        values =[]
      end
      if values.length == 3
        keys  = [:pid, :basename, :time]
        array = [keys, values].transpose.flatten
        @running_job = Hash[*array]
      end
    end
    @running_job
  end
  def Job.updater?
    current_job[:basename].match(/^update|^import/)
  end
end
  end
end
