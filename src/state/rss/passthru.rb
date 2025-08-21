#!/usr/bin/env ruby

# State:Rss::Passthru -- oddb.org -- 23.05.2007 -- hwyss@ywesee.com

require "state/global_predefine"
require "htmlgrid/passthru"

module ODDB
  module State
    module Rss
      class PassThru < Global
        VIEW = HtmlGrid::PassThru
        VOLATILE = true
        def initialize(session, channel)
          super
          @path = File.join(RSS_PATH, session.language, model)
          unless File.exist?(@path)
            SBSM.error("Could not find #{@path}")
            raise Errno::ENOENT
          end
        end

        def init
          @session.passthru(@path, "inline") if File.exist?(@path)
        end
      end
    end
  end
end
