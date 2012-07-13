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
      def welcome(model, session)
        parts = []
        user = session.user
        div = HtmlGrid::Div.new(model, session, self)
        div.css_class = 'personal'
        if(user.is_a?(ODDB::YusUser))
          if company = @session.app.yus_model(user.name) and
             logo_filename = company.logo_filename
            if (company.url and !company.url.empty?)
		          link = HtmlGrid::HttpLink.new(:url, company, session, self)
              link.set_attribute('title', company.url)
            else
              link = HtmlGrid::Link.new(:logo, company, session, self)
              link.set_attribute('href',
                @lookandfeel.resource_global(:company_logo, logo_filename))
            end
            link.set_attribute('target', '_blank')
            link.value = View::CompanyLogo.new(company, session, self)
            parts.push link
          end
          fullname = [user.name_first, user.name_last].compact.join(' ')
          if(fullname.strip.empty?)
            fullname = user.name
          end
          div.value = @lookandfeel.lookup(:welcome, fullname)
          parts.push div
        end
        parts
      end
    end
  end
end
