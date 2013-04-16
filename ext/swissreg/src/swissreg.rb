#!/usr/bin/env ruby
# Swissreg -- oddb.org -- 16.04.2013 -- yasaka@ywesee.com
# Swissreg -- oddb.org -- 04.05.2006 -- hwyss@ywesee.com

require 'session'

module ODDB
  module Swissreg
    def Swissreg.search(iksnr)
      session = Session.new
      session.get_result_list(iksnr).collect { |url, id, state, param|
        res = {}
        retries = 2
        begin
          sleep(1)
          res = session.detail(url, id, state, param)
        rescue
          if(retries > 0)
            retries -= 1
            retry
          else
            raise
          end
        end
        res
      }
    end
    def Swissreg.detail(path)
      session = Session.new
      session.get_detail(path)
    end
  end
end
