#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::SwissindexPlugin -- oddb.org -- 07.04.2012 -- yasaka@ywesee.com
# ODDB::SwissindexPlugin -- oddb.org -- 28.12.2011 -- mhatakeyama@ywesee.com

require 'util/oddbconfig'
require 'plugin/plugin'
require 'util/persistence'
require 'drb'
require 'fileutils'
require 'ext/swissindex/src/swissindex'

module ODDB
  class SwissindexPlugin < Plugin
    class Logging
      @@flag = false
      def Logging.flag=(bool)
        @@flag = bool
      end
      def Logging.flag
        @@flag
      end
      def Logging.start(file)
        if @@flag
          @@start_time = Time.now
          FileUtils.mkdir_p(File.dirname(file))
          log_file = File.open(file, 'w')
          log_file.print "# ", Time.now, "\n"
          yield(log_file)
          log_file.close
        end
      end
      def Logging.append(file)
        if @@flag
          FileUtils.mkdir_p(File.dirname(file))
          log_file = File.open(file, 'a')
          yield(log_file)
          log_file.close
        end
      end
      def Logging.append_estimate_time(file, count, total)
        if @@flag && @@start_time
          FileUtils.mkdir_p(File.dirname(file))
          File.open(file, 'a') do |log|
            estimate = (Time.now - @@start_time) * total / count
            log.print count, " / ", total, "\t"
            em   = estimate/60
            eh   = em/60
            rest = estimate - (Time.now - @@start_time)
            rm   = rest/60
            rh   = rm/60
            log.print "Estimate total: "
            if eh > 1.0
              log.print "%.2f" % eh, " [h]"
            else
              log.print "%.2f" % em, " [m]"
            end
            log.print " It will be done in: "
            if rh > 1.0
              log.print "%.2f" % rh, " [h]\n"
            else
              log.print "%.2f" % rm, " [m]\n"
            end
          end
        end
      end
    end
  end

  class SwissindexMigelPlugin < SwissindexPlugin
		SWISSINDEX_MIGEL_SERVER = DRbObject.new(nil, ODDB::Swissindex::SwissindexMigel::URI)
    def migel_nonpharma(pharmacode_file, logging = false)
      raise  "Swissindex migel_nonpharma #{pharmacode_file} exist #{File.exist?(pharmacode_file)}"  unless File.exist?(pharmacode_file)
      return nil unless File.exist?(pharmacode_file)
      Logging.flag = logging
      log_dir  = File.expand_path('../../log/oddb/debug', File.dirname(__FILE__))
      log_file = File.join(log_dir, 'migel_nonpharma.log')
      Logging.start(log_file) do |log|
        log.print "migel_nonpharma log\n"
      end


      dir = File.expand_path('../../data/csv', File.dirname(__FILE__))
      FileUtils.mkdir_p dir
      @output_file = File.join(dir, 'swissindex_migel.csv')

      #
      # read pharmacode list
      #
      pharmacode_list = File.readlines(pharmacode_file).to_a.map{|line| line.chomp}
      pharmacode_list.delete("")

      #
      # output
      #
      open(@output_file, "w") do |f|
        f.print "position number;pharmacode;GTIN;datetime;status;stdate;lang;description;additional description;company name;company GLN;pharmpreis;ppub;faktor;pzr\n"
        count = 1
        pharmacode_list.each do |pharmacode|
          try_time = 0

          SWISSINDEX_MIGEL_SERVER.session(ODDB::Swissindex::SwissindexMigel) do |swissindex|
            no_company_data    = false
            no_swissindex_data = false
            migel_data = swissindex.search_migel(pharmacode)

            line = []
            line << swissindex.search_migel_position_number(pharmacode)
            line << pharmacode
            if item = swissindex.search_item(pharmacode)
              line << item[:gtin]
              line << item[:dt]
              line << item[:status]
              line << item[:stdate]
              line << item[:lang]
              line << item[:dscr]
              line << item[:addscr]
              if company = item[:comp]
                line << company[:name]
                line << company[:gln]
              else
                no_company_data = true
              end
            else
              no_swissindex_data = true
            end

            # support data by migel searched data
            if no_swissindex_data
              line.concat ['']*5
              unless migel_data.empty?
                line << migel_data[1]
                line << ''
                line << migel_data[2]
                line << ''
              else
                line.concat ['']*4
              end
            elsif no_company_data
              unless migel_data.empty?
                line << migel_data[2]
                line << ''
              else
                line.concat ['']*2
              end
            end
            if additional_data = migel_data[3..6]
              line.concat additional_data
            end
            f.print line.join(';'), "\n"
          end # SWISSINDEX.session

          Logging.append(log_file) do |log|
            log.print pharmacode, "\t"
          end
          Logging.append_estimate_time(log_file, count, pharmacode_list.length)
          count += 1

        end # pharmacode_list
      end # open
      return true
    end # migel_nonpharma
    def log_info
      hash = super
      if @output_file
        type = "text/csv"
        hash.store(:files, { @output_file => type })
      end
      hash
    end
    def report
      File.expand_path(@output_file)
    end
    def search_migel_table(migel_code)
      $stdout.sync
      $stdout.puts "SwissindexMigelPlugin.search_migel_table #{migel_code}"
      table =  []
      SWISSINDEX_MIGEL_SERVER.session(ODDB::Swissindex::SwissindexMigel) do |swissindex|
        table = swissindex.search_migel_table(migel_code, 'MiGelCode')
      end
      table
    end
    def search_item(pharmacode)
      $stdout.puts "pid #{Process.pid}: SwissindexMigelPlugin.search_item #{pharmacode}"
      item = {}
      SWISSINDEX_MIGEL_SERVER.session(ODDB::Swissindex::SwissindexMigel) do |swissindex|
        item = swissindex.search_item_with_swissindex_migel(pharmacode)
      end
      item
    end
	end # SwissindexMigel
end # ODDB
