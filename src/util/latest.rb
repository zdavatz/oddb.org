#!/usr/bin/env ruby
# encoding: utf-8

require 'util/today'
require 'util/logfile'
require 'mechanize'

module ODDB
  class Latest
    def self.log(msg)
      $stdout.puts    "#{Time.now}: Latest #{msg}" # unless defined?(Minitest)
      $stdout.flush
      LogFile.append('oddb/debug', " Latest #{msg}", Time.now)
    end

    # get_latest_file
    # returns name of downloaded if it has been already downloaded today and its size
    # is different from the latest downloaded file.
    def self.get_latest_file(latest, download_url, agent = Mechanize.new, must_unzip = false)
      file_today = latest.sub('latest', @@today.strftime("%Y.%m.%d"))
      file_yesterday = latest.sub('latest', (@@today.to_date-1).strftime("%Y.%m.%d"))
      if File.exist?(file_today) and File.exists?(file_yesterday) and File.size(file_yesterday) == File.size(file_today)
        FileUtils.rm_f(file_yesterday, {:verbose => false})
      end

      if File.exist?(file_today) and File.exists?(latest) and File.size(latest) == File.size(file_today)
        Latest.log "found #{file_today} and same size as latest #{File.size(file_today)} bytes."
        return false
      else
        file = agent.get(download_url)
        download = file.is_a?(String) ? file : file.body # if open-uri is used somewhere, download is String
        File.open(file_today, 'w+') { |f| f.write download }
        if(!File.exist?(latest) or File.size(file_today) != File.size(latest))
          File.open(latest, 'w+') { |f| f.write download }
          Latest.log "saved (#{download.size} bytes) as #{file_today} and #{latest}"
          return latest
        else
          Latest.log "copy file_today #{file_today} #{File.exist?(file_today)} to #{latest}"
          FileUtils.cp(file_today, latest, {:verbose => false})
          return false
        end
      end
      latest
    end
  end
end
