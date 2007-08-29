#!/usr/bin/env ruby
# OdbaExporter::PatentXls -- oddb.org -- 28.08.2007 -- hwyss@ywesee.com

require 'util/oddbapp'
require 'spreadsheet/excel'

module ODDB
  module OdbaExporter
    class PatentXls
      def initialize(path)
        @workbook = Spreadsheet::Excel.new(path)
        @fmt_title = Format.new(:bold=>true)
        @workbook.add_format(@fmt_title)
        @worksheet = @workbook.add_worksheet("Patentablauf")
        columns = [
          'Bezeichnung', 
          'Swissmedic-Nr.', 'Registrierungsdatum Swissmedic', 
          'ESZ-Nr.', 'Anmeldedatum', 'Publikationsdatum', 'Erteilungsdatum', 
          'Schutzdauerbeginn', 'Ablaufdatum', 'Löschdatum',
          'Grund-Patent-Nr.', 'Schutzbeginn Grund-Patent', 'Direktlink',
        ]
        @worksheet.write(0, 0, columns, @fmt_title)
        @rows = 1
      end
      def close
        @workbook.close
      end
      def date(date)
        if(date)
          date.strftime('%d.%m.%Y')
        end
      end
      def export(odba_ids)
        url_base = "http://ch.oddb.org/de/gcc/resolve/pointer/"
        odba_ids.each { |id|
          reg = ODBA.cache.fetch(id)
          pat = reg.patent
          row = [
            reg.name_base[/^.\D+/], reg.iksnr, date(reg.registration_date),
            pat.certificate_number, date(pat.registration_date), 
            date(pat.publication_date), date(pat.issue_date), 
            date(pat.protection_date), date(pat.expiry_date), 
            date(pat.deletion_date),
            pat.base_patent, date(pat.base_patent_date),
          ]
          @worksheet.write(@rows, 0, row)
          if(pac = reg.active_packages.sort_by { |pac| pac.ikscd }.first)
            @worksheet.write_url(@rows, row.size, url_base + pac.pointer.to_s)
          end
          @rows += 1
        }
        @rows
      end
    end
  end
end
