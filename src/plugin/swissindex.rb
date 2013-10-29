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

	class SwissindexPharmaPlugin < SwissindexPlugin
		SWISSINDEX_PHARMA_SERVER = DRbObject.new(nil, ODDB::Swissindex::SwissindexPharma::URI)
    def update_package_trade_status(logging = false)
      Logging.flag = logging
      log_dir  = File.expand_path('../../log/oddb/debug', File.dirname(__FILE__))
      log_file = File.join(log_dir, 'update_package_trade_status.log')
      Logging.start(log_file) do |log|
        log.print "update_package_trade_status.log\n"
        log.print "out_of_trade_false_list, update_pharmacode_list, out_of_trade_true_list, delete_pharmacode_list, eancode, No./Total, Estimate time\n"
      end
      lang = 'DE'
      @out_of_trade_true_list  = []
      @out_of_trade_false_list = []
      @update_pharmacode_list  = []
      @delete_pharmacode_list  = []
      count = 1
      start_time = Time.now
      @total_packages = @app.packages.length
      SWISSINDEX_PHARMA_SERVER.session do |swissindex|
        if swissindex.download_all(lang)
          @app.each_package do |pack|
            # Process 1
            #   Check swissindex by eancode and then check if the package is out of trade (true) in ch.oddb,
            #   if so the package becomes in trade (false)
            # Process 2
            #   if the package does not have a pharmacode and there is a pharmacode found in swissindex,
            #   then put the pharmacode into ch.oddb
            #   We may have to cross-check the pharmacodes in the future
            # Process 3
            #   if there is no eancode in swissindex and the package is in trade in ch.oddb,
            #   then the package becomes out of trade (true) in ch.oddb
            # Process 4
            #   if there is no eancode in swissindex then delete the according pharmacode in ch.oddb
            pharmacode = swissindex.check_item(pack.barcode.to_s, :gtin, lang)
            case pharmacode
            when nil   # => not found in swissindex
              # Process 3
              unless pack.out_of_trade
                @out_of_trade_true_list << pack
              end
              # process 4
              if pharmacode = pack.pharmacode and !pack.sl_entry
                @delete_pharmacode_list << [pack, pharmacode]
              end
            when false # => status "I" (inactive)
              # Process 3
              unless pack.out_of_trade
                @out_of_trade_true_list << pack
              end
            else       # => found in swissindex
              # Process 1
              if pack.out_of_trade
                @out_of_trade_false_list << pack
              end
              # process 2
              if !pack.pharmacode or
                  pack.pharmacode != pharmacode
                @update_pharmacode_list << [pack, pharmacode]
              end
            end
            # for debug
            Logging.append(log_file) do |log|
              log.print @out_of_trade_false_list.length, ",", @update_pharmacode_list.length, ","
              log.print @out_of_trade_true_list.length, ",", @delete_pharmacode_list.length, "\t"
              log.print pack.barcode, "\t"
            end
            Logging.append_estimate_time(log_file, count, @total_packages)
            count += 1
          end
        else
          # NOTE
          # Nothing to do, if unexpected error is caused
          # See bag_xml_swissindex_pharmacode_download_all_error.log
        end
        swissindex.cleanup_items
      end
      # for debug
      log_file = File.join(log_dir, 'update_package_trade_status_list.log')
      Logging.start(log_file) do |log| 
        log.print "out_of_trade true list (Total: #{@out_of_trade_true_list.length})\n"
        log.print @out_of_trade_true_list.map{|x| x.barcode}.join("\n"), "\n"
        log.print "\n"
        log.print "out_of_trade false list (Total: #{@out_of_trade_false_list.length})\n"
        log.print @out_of_trade_false_list.map{|x| x.barcode}.join("\n"), "\n"
        log.print "\n"
        log.print "update_pharmacode_list (Total: #{@update_pharmacode_list.length})\n"
        log.print @update_pharmacode_list.map{|x, y| x.barcode.to_s + ", " + y.to_s}.join("\n"), "\n"
        log.print "\n"
        log.print "delete_pharmacode_list (Total: #{@delete_pharmacode_list.length})\n"
        log.print @delete_pharmacode_list.map{|x, y| x.barcode.to_s + ", " + y.to_s}.join("\n"), "\n"
      end
      # update part: out_of_trade flag
      #   Process1, in trade (false)    if there is a eancode or package is inactive in swissindex
      #   Process3, out of trade (true) if there is no eancode in swissindex
      update_out_of_trade
      # update part: pharmacode
      #   Process2, update pharmacode if the pharmacode is different from swissindex or empty
      #   Process4, delete pharmacode if there is no eancode in swissindex
      update_pharmacode
      return true
    end
    def update_out_of_trade
      # Process 1
      activated = []
      @out_of_trade_false_list.each do |pack|
        next unless pack and pack.pointer
        activated << @app.update(pack.pointer, {:out_of_trade => false, :refdata_override => false}, :refdata)
      end
      # Process 3
      inactivated = []
      @out_of_trade_true_list.each do |pack|
        next unless pack and pack.pointer
        inactivated << @app.update(pack.pointer, {:out_of_trade => true}, :refdata)
      end
      # for debug
      log_dir  = File.expand_path('../../log/oddb/debug', File.dirname(__FILE__))
      log_file = File.join(log_dir, 'update_out_of_trade.log')
      Logging.start(log_file) do |log|
        log.print "\nstart change out_of_trade flag (false) (Total: #{activated.length})\n"
        log.print activated.map{|x| x.barcode}.join("\n"), "\n"
        log.print "\nstart change out_of_trade flag (true) (Total: #{inactivated.length})\n"
        log.print inactivated.map{|x| x.barcode}.join("\n"), "\n"
      end
    end
    def update_pharmacode
      # Process 2
      updated = []
      @update_pharmacode_list.each do |pack, pharmacode|
        updated << @app.update(pack.pointer, {:pharmacode => pharmacode}, :bag)
      end
      # Process 4
      deleted = []
      @delete_pharmacode_list.each do |pack, pharmacode|
        deleted << @app.update(pack.pointer, {:pharmacode => nil}, :bag)
      end
      # for debug
      log_dir  = File.expand_path('../../log/oddb/debug', File.dirname(__FILE__))
      log_file = File.join(log_dir, 'update_pharmacode.log')
      Logging.start(log_file) do |log|
        log.print "\nupdate_pharmacode (Total: #{updated.length})\n"
        log.print updated.map{|x, y| x.barcode.to_s + ", " + y.to_s}.join("\n"), "\n"
        log.print "\ndelete_pharmacode (Total: #{deleted.length}\n"
        log.print deleted.map{|x, y| x.barcode.to_s + ", " + y.to_s}.join("\n"), "\n"
      end
    end
    def report
      lines = [
        "Checked #{@total_packages} packages",
        "Updated in trade     (out_of_trade:false): #{@out_of_trade_false_list.size} packages",
        "Updated out of trade (out_of_trade:true) : #{@out_of_trade_true_list.size} packages",
        "Updated pharmacode: #{@update_pharmacode_list.size} packages",
        "Deleted pharmacode: #{@delete_pharmacode_list.size} packages",
        nil
      ]
      lines.push "Updated in trade     (out_of_trade:false): #{@out_of_trade_false_list.size} packages"
      lines.push "Check swissindex by eancode and then check if the package is out of trade (true) in ch.oddb," 
      lines.push "if so the package becomes in trade (false)"
      @out_of_trade_false_list.each do |pack|
        lines.push sprintf("%13s: http://ch.oddb.org/de/gcc/drug/reg/%s/seq/%s/pack/%s", pack.barcode, pack.iksnr, pack.seqnr, pack.ikscd)
      end
      lines.push nil

      lines.push "Updated out of trade (out_of_trade:true) : #{@out_of_trade_true_list.size} packages"
      lines.push "If there is no eancode in swissindex and the package is in trade in ch.oddb,"
      lines.push "then the package becomes out of trade (true) in ch.oddb"
      @out_of_trade_true_list.each do |pack|
        lines.push sprintf("%13s: http://ch.oddb.org/de/gcc/drug/reg/%s/seq/%s/pack/%s", pack.barcode, pack.iksnr, pack.seqnr, pack.ikscd)
      end
      lines.push nil

      lines.push "Updated pharmacode: #{@update_pharmacode_list.size} packages"
      lines.push "If the package does not have a pharmacode and there is a pharmacode found in swissindex,"
      lines.push "then put the pharmacode into ch.oddb"
      @update_pharmacode_list.each do |pack, pharmacode|
        lines.push sprintf("%13s: http://ch.oddb.org/de/gcc/drug/reg/%s/seq/%s/pack/%s", pack.barcode, pack.iksnr, pack.seqnr, pack.ikscd)
      end
      lines.push nil

      lines.push "Deleted pharmacode: #{@delete_pharmacode_list.size} packages"
      lines.push "If there is no eancode in swissindex then delete the according pharmacode in ch.oddb"
      @delete_pharmacode_list.each do |pack, pharmacode|
        lines.push sprintf("%13s: http://ch.oddb.org/de/gcc/drug/reg/%s/seq/%s/pack/%s", pack.barcode, pack.iksnr, pack.seqnr, pack.ikscd)
      end
      lines.join("\n")
    end
    def load_ikskey(pharmacode)
      ikskey = nil
      SWISSINDEX_PHARMA_SERVER.session(ODDB::Swissindex::SwissindexPharma) do |swissindex|
        if item = swissindex.search_item(pharmacode, :get_by_pharmacode)
          if ean = item[:gtin]
            ikskey = ean.to_s[4,8]
          end
        end
      end
      return ikskey
    end
  end

  class SwissindexNonpharmaPlugin < SwissindexPlugin
		SWISSINDEX_NONPHARMA_SERVER = DRbObject.new(nil, ODDB::Swissindex::SwissindexNonpharma::URI)
    def migel_nonpharma(pharmacode_file, logging = false)
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

          SWISSINDEX_NONPHARMA_SERVER.session(ODDB::Swissindex::SwissindexNonpharma) do |swissindex|
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
      table =  []
      SWISSINDEX_NONPHARMA_SERVER.session(ODDB::Swissindex::SwissindexNonpharma) do |swissindex|
        table = swissindex.search_migel_table(migel_code, 'MiGelCode')
      end
      table
    end
    def search_item(pharmacode)
      item = {}
      SWISSINDEX_NONPHARMA_SERVER.session(ODDB::Swissindex::SwissindexNonpharma) do |swissindex|
        item = swissindex.search_item_with_swissindex_migel(pharmacode)
      end
      item
    end
	end # SwissindexNonpharma
end # ODDB
