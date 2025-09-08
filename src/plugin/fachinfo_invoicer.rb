#!/usr/bin/env ruby

# ODDB::FachinfoInvoicer -- oddb.org -- 17.11.2011 -- mhatakeyama@ywesee.com
# ODDB::FachinfoInvoicer -- oddb.org -- 28.04.2006 -- hwyss@ywesee.com

require "plugin/info_invoicer"
require "util/oddbconfig"

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
      super
    end

    def report
      report = super
      @companies.sort.each { |company_name, fachinfos|
        report << company_name << "\n"
        fachinfos.sort_by { |fi| fi.name_base }.each { |fi|
          if reg = fi.registrations.first
            report << sprintf("%s:\n  #{root_url}/de/gcc/fachinfo/reg/%s\n", fi.name_base, reg.iksnr)
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
