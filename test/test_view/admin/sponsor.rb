#!/usr/bin/env ruby

# ODDB::View::Admin::TestSponsor -- oddb.org -- 21.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "view/admin/sponsor"

module ODDB
  module View
    module Admin
      class TestSponsorForm < Minitest::Test
        def setup
          @lnf = flexmock("lookandfeel",
            lookup: "lookup",
            attributes: {},
            base_url: "base_url")
          @session = flexmock("session",
            lookandfeel: @lnf,
            error: "error",
            warning?: nil,
            error?: nil)
          @model = flexmock("model",
            emails: ["email"],
            url: "url")
          @form = ODDB::View::Admin::SponsorForm.new(@model, @session)
        end

        def test_init
          assert_nil(@form.init)
        end
      end
    end # Admin
  end # View
end # ODDB
