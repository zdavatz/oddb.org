#!/usr/bin/env ruby
# FachinfoInvoicer -- oddb -- 28.04.2006 -- hwyss@ywesee.com

require 'plugin/info_invoicer'

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
          range.include?(item.time)
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
          report << sprintf("%s:\n  http://www.oddb.org/de/gcc/resolve/pointer/%s\n",
                        fi.name_base, fi.pointer) 
        }
        report << "\n"
      }
      (report.empty?) ? "Es wurden keine FI editiert" : report
    end
    def unique_name(item)
      item.pointer
    end
    def unique_name(item)
      item.item_pointer
    end
  end
end
