#!/usr/bin/env ruby

# ODDB::Invoicer -- ydpm -- 27.06.2011 -- mhatakeyama@ywesee.com
# ODDB::Invoicer -- ydpm -- 12.12.2005 -- hwyss@ywesee.com

require "date"
require "plugin/plugin"
require "util/today"
require "util/oddbconfig"

module ODDB
  class Invoicer < Plugin
    def create_invoice(email, items)
      pointer = Persistence::Pointer.new(:invoice)
      values = {
        yus_name: email,
        keep_if_unpaid: true
      }
      invoice = @app.update(pointer.creator, values)
      pointer = invoice.pointer + [:item]
      items.each { |item|
        @app.update(pointer.dup.creator, item.values)
      }
    end

    def ensure_yus_user(comp_or_hosp)
      comp_or_hosp.invoice_email
    end

    def rp2fr(price)
      price.to_f / 100.0
    end
  end
end
