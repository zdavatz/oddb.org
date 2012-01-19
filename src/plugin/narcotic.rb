#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::NarcoticPlugin -- oddb.org -- 19.01.2012 -- mhatakeyama@ywesee.com
# ODDB::NarcoticPlugin -- oddb.org -- 03.11.2005 -- ffricker@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'plugin/plugin'
require 'model/package'
require 'spreadsheet'

module ODDB
	class NarcoticPlugin < Plugin
    MEDDATA_SERVER = DRbObject.new(nil, MEDDATA_URI)
		def initialize(app)
			super(app)
		end
    def report
      [
        "Updated packages Narcotic flag(true): #{@update_bm_flag}",
        "Updated packages Category(A+): #{@update_ikscat}",
      ].join("\n")
    end
    def update_from_xls(path, lang='de')
      if File.exists?(path)
        @update_bm_flag = 0
        @update_ikscat  = 0
        workbook = Spreadsheet.open(path)
        workbook.worksheet(0).each do |row|
          iksnr = ikscd = ikscat = nil
          if row[5] and items = row[5].split(/\s/)
            iksnr = items[2]
            ikscd = items[3]
          end
          if reg = @app.registration(iksnr) and pac = reg.package(ikscd)
            # update package
            values = {}
            unless pac.bm_flag
              values.store(:bm_flag, true)
              @update_bm_flag += 1
            end
            if row[8] == 'A+' and ikscat = row[8] and pac.ikscat != ikscat
              values.store(:ikscat, ikscat)
              @update_ikscat += 1
            end
            @app.update(pac.pointer, values, :narcotic)

            # update narcotics
            values = {
              :ikskey  => iksnr + ikscd,
              :package => pac
            }
            values.store(lang.to_sym, pac.name_base)
            pointer = if narc = @app.narcotic_by_ikskey(pac.ikskey)
                        narc.pointer
                      else
                        Persistence::Pointer.new(:narcotic).creator
                      end
            @app.update(pointer, values, :swissmedic)
          end
        end
      end
    end
	end
end
