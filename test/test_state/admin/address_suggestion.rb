#!/usr/bin/env ruby

# ODDB::State::Admin::TestAddressSuggestion -- oddb.org -- 09.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "htmlgrid/labeltext"
require "htmlgrid/errormessage"
require "htmlgrid/select"
require "view/privatetemplate"
require "state/admin/address_suggestion"
require "state/companies/init"
require "state/global"
require "state/admin/global"

require "state/hospitals/setpass"

module ODDB
  module State
    module Admin
      class TestAddressSuggestion < Minitest::Test
        def setup
          @lnf = flexmock("lookandfeel", lookup: "lookup")
          parent = flexmock("parent", email: "email")
          flexmock(parent, resolve: parent)
          pointer = flexmock("pointer",
            resolve: nil,
            parent: parent)
          @app = flexmock("app")
          hospital = flexmock("hospital", email: "email")
          @session = flexmock("session",
            lookandfeel: @lnf,
            get_address_parent: nil,
            app: @app,
            persistent_user_input: {},
            request_path: "request_path",
            search_hospital: hospital)
          address_instance = flexmock("address_instance", replace_with: "replace_with")
          @model = flexmock("model",
            address_pointer: pointer,
            address_instance: address_instance)
          @state = ODDB::State::Admin::AddressSuggestion.new(@session, @model)
        end

        def test_init
          assert_nil(@state.init)
        end

        def test_delete
          pointer = Persistence::Pointer.new
          flexmock(@app, delete: "delete")
          flexmock(@session, user_input: pointer)
          assert_equal(@state, @state.delete)
        end

        def test_zone
          @state.instance_eval('@zone = "zone"', __FILE__, __LINE__)
          assert_equal("zone", @state.zone)
        end

        def test_home_state__else
          @state.instance_eval('@zone = "zone"', __FILE__, __LINE__)
          assert_equal(ODDB::State::Admin::Init, @state.home_state)
        end

        def test_home_state__companies
          @state.instance_eval("@zone = :companies", __FILE__, __LINE__)
          assert_equal(ODDB::State::Companies::Init, @state.home_state)
        end

        def test_home_state__doctors
          @state.instance_eval("@zone = :doctors", __FILE__, __LINE__)
          assert_equal(ODDB::State::Doctors::Init, @state.home_state)
        end

        def test_home_state__hospitals
          @state.instance_eval("@zone = :hospitals", __FILE__, __LINE__)
          assert_equal(ODDB::State::Hospitals::Init, @state.home_state)
        end

        def test_zone_navigation__else
          assert_equal([], @state.zone_navigation)
        end

        def test_zone_navigation__companies
          @state.instance_eval("@zone = :companies", __FILE__, __LINE__)
          assert_equal([ODDB::State::Companies::CompanyList], @state.zone_navigation)
        end

        def test_zone_navigation__doctors
          @state.instance_eval("@zone = :doctors", __FILE__, __LINE__)
          assert_equal([], @state.zone_navigation)
        end

        def test_zone_navigation__hospitals
          @state.instance_eval("@zone = :hospitals", __FILE__, __LINE__)
          assert_equal([ODDB::State::Hospitals::HospitalList], @state.zone_navigation)
        end

        def test_accept
          flexmock(@app, update: "update")
          address = flexmock("address", replace_with: "replace_with")
          address_pointer = flexmock("address_pointer",
            resolve: nil,
            "creator.resolve": address,
            parent: "parent")
          suggestion = flexmock("suggestion", address_pointer: address_pointer)
          pointer = flexmock("pointer", resolve: suggestion)
          input = {name: "name", pointer: pointer}
          flexmock(@session,
            user_input: input,
            user: "user")
          flexmock(@model, pointer: "pointer")
          parent = flexmock("parent", pointer: "pointer", addresses: [address])
          active_address = flexmock("active_address", :email_suggestion= => nil)
          @state.instance_eval do
            @parent = parent
            @active_address = active_address
          end
          assert_equal(@state, @state.accept)
        end

        def test_accept__error
          input = {}
          flexmock(@session, user_input: input)
          assert_nil(@state.accept)
        end

        # The followings are testcases for a private method
        def test_select_zone__company
          flexmock(ODBA.cache, next_id: 123)
          parent = ODDB::Company.new
          assert_equal(:companies, @state.instance_eval("select_zone(parent)", __FILE__, __LINE__))
        end

        def test_select_zone__doctor
          flexmock(ODBA.cache, next_id: 123)
          parent = ODDB::Doctor.new
          assert_equal(:doctors, @state.instance_eval("select_zone(parent)", __FILE__, __LINE__))
        end

        def test_select_zone__hospital
          flexmock(ODBA.cache, next_id: 123)
          parent = ODDB::Hospital.new("ean13")
          assert_equal(:hospitals, @state.instance_eval("select_zone(parent)", __FILE__, __LINE__))
        end
      end
    end # Admin
  end # State
end # ODDB
