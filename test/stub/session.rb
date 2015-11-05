#!/usr/bin/env ruby
# encoding: utf-8
# Stub: Session -- oddb -- 22.10.2002 -- hwyss@ywesee.com 

require 'util/session'
require 'flexmock'
module ODDB
  class StubApp
    attr_accessor :last_update, :currency, :unknown_user, :sponsor, :registrations
  end
  class StubSession < SBSM::Session
    attr_accessor :lookandfeel, :app, :flavor, :language, :request_path, :diff_info
    def choosen_fachinfo_diff
      return @diff_info || []
    end
    def default_language
      "de"
    end
    def disabled?
      false
    end
    def enabled?
      true
    end
    def http_protocol
      'http'
    end
    def server_name
      'test.oddb.org'
    end
    def user_agent
      'TEST'
    end
    def zone_navigation
      [:foo]
    end
  end
end
