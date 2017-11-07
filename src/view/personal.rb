#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Personal -- oddb.org -- 13.07.2012 -- yasaka@ywesee.com
# ODDB::View::Personal -- oddb.org -- 01.07.2011 -- mahatakeyama@ywesee.com
# ODDB::View::Personal -- oddb.org -- 24.05.2005 -- jlang@ywesee.com, usenguel@ywesee.com

require 'htmlgrid/div'
require 'htmlgrid/link'
require 'model/user'
require 'view/sponsorlogo'

module ODDB
  module View
    module Personal
      # Return text div like Willkommen oddb_logged_in_user, else an empty div
      def personal(model, session)
        div = HtmlGrid::Div.new(model, session, self)
        div.css_class = 'personal'
        user = session.user
        if (user.is_a?(ODDB::YusUser))
          fullname = [user.name_first, user.name_last].compact.join(' ')
          if(fullname.strip.empty?)
            fullname = user.name
          end
          div.value = @lookandfeel.lookup(:welcome, fullname)
        else
          div.value = '&nbsp;'
        end
        div
      end
      # Returns company logo (if presnt) for a logged in ODDB user, else an empty div
      def personal_logo(model, session)
        user = session.user
        div = HtmlGrid::Div.new(model, session, self)
        div.css_class = 'personal_logo'
        if(user.is_a?(ODDB::YusUser))
          if company = @session.app.yus_model(user.name) and
             logo_filename = company.logo_filename
            if (company.url and !company.url.empty?)
		          div = HtmlGrid::HttpLink.new(:url, company, session, self)
              div.set_attribute('title', company.url)
            else
              div = HtmlGrid::Link.new(:logo, company, session, self)
              div.set_attribute('href',
                @lookandfeel.resource_global(:company_logo, logo_filename))
            end
            div.set_attribute('target', '_blank')
            div.value = View::CompanyLogo.new(company, session, self)
          end
        else
          div.value = '&nbsp;'
        end
        div
      end
    end
  end
end
