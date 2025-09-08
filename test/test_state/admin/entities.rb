#!/usr/bin/env ruby

# ODDB::State::Admin::TestEntities -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "state/admin/entities"

module ODDB
  module State
    module Admin
      class TestEntities < Minitest::Test
        def setup
          @lnf = flexmock("lookandfeel", lookup: "lookup")
          @model = flexmock("model")
          user = flexmock("user", entities: @model)
          @session = flexmock("session",
            lookandfeel: @lnf,
            user: user)
          @state = ODDB::State::Admin::Entities.new(@session, @model)
        end

        def test_init
          assert_equal(@model, @state.init)
        end
      end
    end # Admin
  end # State
end # ODDB
