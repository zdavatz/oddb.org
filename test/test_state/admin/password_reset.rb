#!/usr/bin/env ruby

# ODDB::State::Admin::TestPasswordReset -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "state/admin/password_reset"

module ODDB
  module State
    module Admin
      class TestPasswordReset < Minitest::Test
        def test_view
          # Password reset removed — authentication via Swiyu
          assert_equal(View::Search, ODDB::State::Admin::PasswordReset::VIEW)
        end
      end
    end # Admin
  end # State
end # ODDB
