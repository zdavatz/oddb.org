#!/usr/bin/env ruby
# Util::Server -- de.ODDB.org -- 01.09.2006 -- hwyss@ywesee.com

require 'config'
require 'sbsm/app'

module ODDB
  module Util
    class RackInterface < SBSM::RackInterface
      ENABLE_ADMIN = true
      SESSION = ODDB::Session
      VALIDATOR = ODDB::Validator
      def initialize(app:,
                     auth: nil,
                     validator: VALIDATOR)
        @app = app
        super(app: app,
              session_class: SESSION,
              unknown_user: ODDB::UnknownUser.new,
              validator: validator,
              cookie_name: 'oddb.org'
              )
      end
    end
  end
end
