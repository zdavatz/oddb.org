#!/usr/bin/env ruby

# ODDB::View::Pharmacies::TestPharmacy -- oddb.org -- 08.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "view/pharmacies/pharmacy"
require "htmlgrid/textarea"
require "model/company"

module ODDB
  module View
    module Pharmacies
      class TestPharmacyInnerComposite < Minitest::Test
        def setup
          @lnf = flexmock("lookandfeel",
            lookup: "lookup",
            attributes: {},
            _event_url: "_event_url")
          @session = flexmock("session", lookandfeel: @lnf,
            user_input: "user_input",
            pharmacy_by_gln: "pharmacy_by_gln")
          @address = flexmock("address",
            fon: ["fon"],
            fax: ["fax"],
            lines: ["line"],
            plz: "plz",
            city: "city",
            street: "street",
            number: "number",
            type: "type")
          @model = flexmock("model",
            addresses: [@address],
            business_area: "business_area",
            narcotics: "narcotics",
            pointer: "pointer",
            ean13: "ean13")
          @composite = ODDB::View::Pharmacies::PharmacyInnerComposite.new(@model, @session)
        end

        def test_mapsearch_format
          args = ["1", "2", "3"]
          assert_equal("1-2-3", @composite.mapsearch_format(*args))
        end

        def test_location
          flexmock(@address, location: "location")
          assert_equal("location", @composite.location(@model))
        end
      end

      class TestPharmacyForm < Minitest::Test
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
          @address = flexmock("address",
            fon: ["fon"],
            fax: ["fax"],
            lines: ["line"],
            plz: "plz",
            city: "city",
            street: "street",
            number: "number",
            type: "type")
          @model = flexmock("model",
            address: @address,
            addresses: [@address])
          @form = ODDB::View::Pharmacies::PharmacyForm.new(@model, @session)
        end

        def test_additional_lines
          assert_kind_of(HtmlGrid::Textarea, @form.additional_lines(@model))
        end
      end
    end # Pharmacies
  end # View
end # ODDB
