#!/usr/bin/env ruby

# View::PayPal::Redirect -- ODDB -- 20.04.2005 -- hwyss@ywesee.com

require "htmlgrid/component"
require "util/oddbconfig"
require "config"
require "cgi"

module ODDB
  module View
    module PayPal
      class Redirect < HtmlGrid::Component
        def http_headers
          invoice = @model.oid
          names = @model.items.values.collect { |item|
            txt = item.text
            case txt
            when "unlimited access"
              "Unlimited Access to #{SERVER_NAME} for %i days" % item.quantity
            else
              txt
            end
          }.join(" ,")
          ret_url = @lookandfeel._event_url(:paypal_return,
            {invoice: invoice})
          url = "https://" << PAYPAL_SERVER << "/cgi-bin/webscr?" \
            << "business=#{PAYPAL_RECEIVER}&" \
            << "item_name=#{names}&item_number=#{invoice}&" \
            << "invoice=#{invoice}&custom=#{SERVER_NAME}&" \
            << "amount=#{sprintf("%3.2f", model.total_brutto)}&" \
            << "no_shipping=1&no_note=1&currency_code=CHF&" \
            << "return=#{ret_url}&" \
            << "cancel_return=#{@lookandfeel.base_url}&" \
            << "image_url=https://www.generika.cc/images/oddb_paypal.jpg"
          if (user = @session.user).is_a?(YusUser)
            add = "&email=#{user.email}&first_name=#{CGI.escape(user.name_first)}" \
              << "&last_name=#{CGI.escape(user.name_last)}&address1=#{CGI.escape(user.address || "")}" \
              << "&city=#{CGI.escape(user.city || "")}&zip=#{user.plz}" \
              << "&redirect_cmd=_xclick&cmd=_ext-enter"
            url << add
          else
            url << "&cmd=_xclick"
          end
          {
            "Location"	=>	url.encode("ASCII")
          }
        end

        def to_html(context)
          ""
        end
      end
    end
  end
end
