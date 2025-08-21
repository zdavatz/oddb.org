#!/usr/bin/env ruby

# ODDB::View::Personal -- oddb.org -- 13.07.2012 -- yasaka@ywesee.com
# ODDB::View::Personal -- oddb.org -- 01.07.2011 -- mahatakeyama@ywesee.com
# ODDB::View::Personal -- oddb.org -- 24.05.2005 -- jlang@ywesee.com, usenguel@ywesee.com

require "htmlgrid/div"
require "htmlgrid/composite"
require "htmlgrid/link"
require "model/user"
require "view/google_ad_sense"
require "view/sponsorlogo"

module ODDB
  module View
    module Personal
      # Return text div like Willkommen oddb_logged_in_user, else an empty div
      # Goes to navigationfoot
      def personal(model, session)
        div = HtmlGrid::Div.new(model, session, self)
        div.css_class = "personal"
        user = session.user
        if user.is_a?(ODDB::YusUser)
          fullname = [user.name_first, user.name_last].compact.join(" ")
          if fullname.strip.empty?
            fullname = user.name
          end
          div.value = @lookandfeel.lookup(:welcome, fullname)
        else
          div.value = "&nbsp;"
        end
        div
      end

      def is_at_home
        splits = @session.request_path.dup.sub(/^\//, "").split("/")
        splits.size < 3 || splits[2].eql?("home") || splits[2].eql?("self")
      end

      def sponsor_or_logo
        res = nil
        user = @session.user
        @session.request_path.dup.sub(/^\//, "").split("/")
        if user.is_a?(ODDB::YusUser)
          res = if (company = @session.app.yus_model(user.name)) and company.logo_filename
            if is_at_home
              nil
            else
              :company
            end
          end
        else
          res = :sponsor_logo if (spons = @session.sponsor) && spons.valid?
          res = if is_at_home
            nil
          else
            @lookandfeel.enabled?(:google_adsense) ? :google_adsense : nil
          end
        end
        # puts "sponsor_or_logo for #{user} with #{@session.request_path} is #{res.inspect}"
        res
      end

      # Returns company logo (if present) for a logged in ODDB user, else an empty div
      def personal_logo(model, session)
        div = HtmlGrid::Div.new(model, session, self)
        div.css_class = "personal_logo"
        case sponsor_or_logo
        when :company
          user = session.user
          company = @session.app.yus_model(user.name) and logo_filename = company.logo_filename
          if company.url and !company.url.empty?
            div = HtmlGrid::HttpLink.new(:url, company, session, self)
            div.set_attribute("title", company.url)
          else
            div = HtmlGrid::Link.new(:logo, company, session, self)
            div.set_attribute("href",
              @lookandfeel.resource_global(:company_logo, logo_filename))
          end
          div.set_attribute("target", "_blank")
          div.value = View::CompanyLogo.new(company, session, self)
        when :sponsor_logo
          div.value = View::SponsorLogo.new(@session.sponsor, session, self)
        when :google_adsense
          return ad_sense(model, session, "search_result")
        else
          return ad_sense(model, session, "post_search") if session.request_method.eql?("POST")
          div.value = "&nbsp;" # this should never be visible
        end
        div
      end
    end
  end
end
