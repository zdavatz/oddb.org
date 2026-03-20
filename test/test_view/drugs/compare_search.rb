#!/usr/bin/env ruby

# ODDB::View::Drugs::TestCompareSearch -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "view/drugs/centeredsearchform"
require "view/drugs/compare_search"

module ODDB
  module View
    module Drugs
      class TestCompareSearchForm < Minitest::Test
        def setup
          @container = flexmock("container", additional_javascripts: [])
          @lnf = flexmock("lookandfeel",
            lookup: "lookup",
            direct_event: "direct_event",
            _event_url: "_event_url",
            enabled?: nil,
            attributes: {},
            base_url: "base_url")
          @session = flexmock("session",
            lookandfeel: @lnf,
            persistent_user_input: "persistent_user_input",
            flavor: "flavor")
          @model = flexmock("model")
          @form = ODDB::View::Drugs::CompareSearchForm.new(@model, @session, @container)
        end

        def test_init
          result = @form.init
          assert_kind_of(Array, result)
          # The autocomplete JS now uses vanilla JS with fetch() instead of Dojo
          js_text = result.join
          assert_match(/show_progressbar/, js_text, "must contain progressbar JS")
          assert_match(/DOMContentLoaded/, js_text, "must contain vanilla JS autocomplete")
          assert_match(/fetchMatches/, js_text, "must contain fetch-based autocomplete")
        end
      end
    end # Drugs
  end # View
end # ODDB
