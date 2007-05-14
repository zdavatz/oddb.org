#!/usr/bin/env ruby
# View::Drugs::Search -- oddb -- 24.10.2002 -- hwyss@ywesee.com 

require 'view/publictemplate'
require 'view/drugs/centeredsearchform'
require 'view/welcomehead'
require 'view/custom/head'

module ODDB
	module View
		module Drugs
class Search < View::PublicTemplate
	include View::Custom::Head
	CONTENT = View::Drugs::GoogleAdSenseComposite
	CSS_CLASS = 'composite'
	HEAD = View::WelcomeHead
  def other_html_headers(context)
    headers = super 
    @session.valid_values(:channel).each { |channel|
      url = @lookandfeel._event_url(:rss, :channel => channel)
      headers << context.link(:href => url, :type => "application/rss+xml",
                              :title => channel, :rel => "alternate")
    }
    headers
  end
end
		end
	end
end
