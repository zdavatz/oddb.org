#!/usr/bin/env ruby

# ODDB::View::Interactions::TestCenteredSearchForm -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))
$: << File.expand_path("../..", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "view/interactions/centeredsearchform"
require "view/interactions/interaction_chooser"
require "stub/cgi"
require "stub/oddbapp"

module ODDB
  module View
    class Session
      DEFAULT_FLAVOR = "gcc" unless defined?(DEFAULT_FLAVOR)
    end

    module Interactions
      class TestCenteredSearchComposite < Minitest::Test
        def setup
          @app = flexmock("app",
            package_count: 0,
            substance_count: 0,
            registrations: [])
          @lnf = flexmock("lookandfeel",
            lookup: "lookup",
            attributes: {},
            enabled?: nil,
            _event_url: "_event_url",
            disabled?: nil,
            zones: ["zones"],
            base_url: "base_url",
            direct_event: "direct_event",
            zone_navigation: ["zone_navigation"])
          @session = flexmock("session",
            lookandfeel: @lnf,
            app: @app,
            zone: "zone",
            search_form: "search_form",
            flavor: "flavor",
            event: "event",
            persistent_user_input: [],
            request_path: "de/gcc/ean/7680651330010",
            user_input: "user_input",
            choosen_drugs: [7680651330010],
            create_search_url: "create_search_url")
          @model = flexmock("model")
          @model.should_receive(:atc_class).and_return(nil).by_default
          @composite = ODDB::View::Interactions::CenteredSearchComposite.new(@model, @session)
        end

        def test_substance_count
          assert_equal("0&nbsp;", @composite.substance_count(@model, @session))
        end

        def test_init_no_interactions
          @composite = ODDB::View::Interactions::InteractionChooserDrug.new(@model, @session)
          expected = '<TABLE cellspacing="0" class="composite"><TR><TD>&nbsp;</TD></TR></TABLE>'
          result = @composite.to_html(CGI.new)
          assert_equal(expected, result)
        end

        def test_init_with_interactions
          atc_class = flexmock("atc_class", StubAtcClass.new("test_class"))
          @model.should_receive(:atc_class).and_return(atc_class)
          @composite = ODDB::View::Interactions::InteractionChooserDrug.new(@model, @session)
          get_mock = flexmock("get_interactions", EphaInteractions)
          tst_pattern = "an_interaction"
          get_mock.should_receive(:get_interactions).and_return(tst_pattern)
          assert_equal(tst_pattern, EphaInteractions.get_interactions(0, 1))
          skip("Too much work to mock a package")
          assert(@model.is_a?(ODDB::Package))
          expected = '<TABLE cellspacing="0" class="composite"#{tst_pattern}><TR><TD>&nbsp;</TD></TR></TABLE>'
          result = @composite.to_html(CGI.new)
          assert_equal(expected, result)
        end
      end
    end # Interactions
  end # View
end # ODDB
