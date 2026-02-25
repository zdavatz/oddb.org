#!/usr/bin/env ruby

# ODDB::State::Admin::TestPasswordLost -- oddb.org -- 28.06.2011 -- mhatakeyama@ywesee.com
# Password reset removed — authentication via Swiyu

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "state/admin/password_lost"

module ODDB
  module State
    module Admin
      class TestPasswordLost < Minitest::Test
        def setup
          @session = flexmock("session")
          @model = flexmock("model")
          @state = ODDB::State::Admin::PasswordLost.new(@session, @model)
        end

        def test_view
          assert_equal View::Search, ODDB::State::Admin::PasswordLost::VIEW
        end
      end
    end
  end
end
