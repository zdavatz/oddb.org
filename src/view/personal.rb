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
            link = HtmlGrid::Link.new(:logo, company, session, self)
            if (company.ean13 and !company.ean13.to_s.strip.empty?)
              link.set_attribute('title',
                @lookandfeel.lookup(:ean_code, company.ean13))
              link.href = @lookandfeel._event_url(:company, {:ean => company.ean13})
            else
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
