#!/usr/bin/env ruby
# encoding: utf-8
# State::Http404 -- oddb.org -- 22.05.2007 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/http_404'

module ODDB
  module State
    class Http404 < Global
      VOLATILE = true
      VIEW = View::Http404
      def http_headers
        headers = super
        headers.store('Status', '404')
        path = @previous.request_path if(@previous)
        path ||= @session.lookandfeel._event_url(:home)
        headers.store('Refresh', "10;url=%s" % path)
        headers
      end
    end
  end
end
