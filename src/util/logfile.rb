#!/usr/bin/env ruby
# encoding: utf-8
# LogFile -- ODDB -- 21.10.2003 -- hwyss@ywesee.com

require 'util/oddbconfig'
require 'date'
require 'fileutils'
require 'fcntl'

module ODDB
	module LogFile
		LOG_ROOT = File.join(PROJECT_ROOT, 'log')
		def append(key, line, time=Time.now.utc)
			file = filename(key, time)
			dir = File.dirname(file)
			FileUtils.mkdir_p(dir)
			timestr = time.strftime('%Y-%m-%d %H:%M:%S %Z')
			File.open(file, 'a') { |fh| fh << [timestr, line, "\n"].join if fh.respond_to?(:<<) }
			LogFile.debug(line)
		end
		def filename(key, time)
			path = [
				key,
				time.year,
				sprintf('%02i', time.month) + '.log',
			].join('/')
			File.expand_path(path, LOG_ROOT)
		end
		def read(key, time)
			begin
				File.read(filename(key, time))
			rescue(StandardError)
				''
			end
		end
    def debug(msg)
      msg = /util\/log/.match(caller[0]) ?"#{caller[1]}: #{msg}" : "#{caller[0]}: #{msg}"
      unless ENV['GITHUB_SHA']
        begin
          $stdout.puts Time.now.to_s + ': ' + msg; $stdout.flush
        rescue IOError
          # ignore this error
          0
        end
      end
      return if defined?(Minitest)
      if not defined?(@@debugLog) or not @@debugLog
        name = LogFile.filename('oddb/debug', Time.now)
        FileUtils.makedirs(File.dirname(name))
        @@debugLog = File.open(name, 'a+')
        @@debugLog.sync = true
      end
      @@debugLog.puts("#{Time.now}: #{msg}")
      @@debugLog.flush
    end
		module_function :append
		module_function :filename
		module_function :read
    module_function :debug
	end
end
