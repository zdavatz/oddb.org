#!/usr/bin/env ruby

# ODDB::View::Doctors::TestCenteredSearchForm -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "view/doctors/centeredsearchform"

module ODDB
  module View
    module Doctors
      class TestCenteredSearchComposite < Minitest::Test
        def setup
          @app = flexmock("app")
          @lnf = flexmock("lookandfeel",
            lookup: "lookup",
            attributes: {},
            _event_url: "_event_url",
            enabled?: nil,
            disabled?: nil,
            zones: ["zones"],
            base_url: "base_url",
            zone_navigation: ["zone_navigation"],
            direct_event: "direct_event")
          @session = flexmock("session",
            app: @app,
            lookandfeel: @lnf,
            doctor_count: 0,
            language: "de",
            zone: "zone",
            event: "event")
          @model = flexmock("model")
          @composite = ODDB::View::Doctors::CenteredSearchComposite.new(@model, @session)
        end

        def test_doctor_count
          assert_equal("0&nbsp;", @composite.doctor_count(@model, @session))
        end

        # Die Zahl zaehlt Aerzte mit aktiver Refdata-Registrierung, nicht
        # praktizierende Aerzte in der Schweiz - die Beschriftung sagt es und
        # verlinkt auf die Abfrageseite der Partner-refdatabase.
        def test_refdata_registration_links_to_the_partner_database
          link = @composite.refdata_registration(@model, @session)
          assert_equal("https://www.refdata.ch/de/partner/abfrage/partner-refdatabase-gln",
            link.href)
          assert_equal("_blank", link.attributes["target"],
            "der Verweis muss in einem neuen Reiter aufgehen")
          assert_equal("noopener noreferrer", link.attributes["rel"],
            "ohne noopener kommt die fremde Seite an window.opener")
        end

        def test_refdata_registration_in_french
          @session = flexmock("session", app: @app, lookandfeel: @lnf,
            doctor_count: 0, language: "fr", zone: "zone", event: "event")
          composite = ODDB::View::Doctors::CenteredSearchComposite.new(@model, @session)
          assert_equal("https://www.refdata.ch/fr/partenaires/requete/base-de-donnees-des-partenaires-gln",
            composite.refdata_registration(@model, @session).href)
        end

        # Refdata hat kein englisches Angebot.
        def test_refdata_registration_falls_back_to_the_german_page
          @session = flexmock("session", app: @app, lookandfeel: @lnf,
            doctor_count: 0, language: "en", zone: "zone", event: "event")
          composite = ODDB::View::Doctors::CenteredSearchComposite.new(@model, @session)
          assert_equal("https://www.refdata.ch/de/partner/abfrage/partner-refdatabase-gln",
            composite.refdata_registration(@model, @session).href)
        end
      end
    end # Doctors
  end # View
end # ODDB
