#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::FachinfoInvoicer -- oddb.org -- 17.11.2011 -- mhatakeyama@ywesee.com
# ODDB::FachinfoInvoicer -- oddb.org -- 28.04.2006 -- hwyss@ywesee.com

require 'plugin/info_invoicer'
require 'util/oddbconfig'

module ODDB
  class FachinfoInvoicer < InfoInvoicer
    def initialize(*args)
      @infotype = :fachinfo
      @companies = {}
      super
    end
    def activation_fee
      FI_UPLOAD_PRICES[:activation]
    end
    def active_infos
      @app.active_fachinfos
    end
    def parent_item_class
      Registration
    end
    def run(day = @@today)
      report_edited_fachinfos(day - 1)
      super
    end
    def report_edited_fachinfos(day1)
      day2 = day1 + 1
      time1 = Time.local(day1.year, day1.month, day1.day)
      time2 = Time.local(day2.year, day2.month, day2.day)
      range = (time1...time2)
      modified = @app.fachinfos.values.select { |fi| 
        fi.change_log.reverse.any? { |item|
          #range.include?(item.time)
          range.cover?(item.time)
        }
      }
      modified.each { |fi|
        (@companies[fi.company_name] ||= []).push(fi)
      }
    end
    def report
      report = super
      @companies.sort.each { |company_name, fachinfos|
        report << company_name << "\n"
        fachinfos.sort_by { |fi| fi.name_base }.each { |fi|
          if reg = fi.registrations.first
            report << sprintf("%s:\n  http://#{SERVER_NAME}/de/gcc/fachinfo/reg/%s\n", fi.name_base, reg.iksnr)
          end
        }
        report << "\n"
      }
      !report.empty? && report
    end
    def unique_name(item)
      item.item_pointer
    end
  end
end
