#!/usr/bin/env ruby

# ODDB::View::Drugs::TestPatinfo -- oddb.org -- 09.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../..", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "stub/odba"
require "minitest/autorun"
require "flexmock/minitest"
require "model/activeagent"
require "model/text"
require "view/drugs/patinfo"

module ODDB
  module View
    module Drugs
      class TestPatinfoInnerComposite < Minitest::Test
        def setup
          @lnf = flexmock("lookandfeel", lookup: "lookup")
          @session = flexmock("session", lookandfeel: @lnf)
          @model = flexmock("model", empty?: false, chapter_names: ["chapter_names"])
          @composite = ODDB::View::Drugs::PatinfoInnerComposite.new(@model, @session)
        end

        def test_init
          chapter = ["chapter"]
          flexmock(@model, galenic_form: chapter)
          assert_equal([], @composite.init)
        end
      end

      class TestPatinfoComposite < Minitest::Test
        def setup
          @lnf = flexmock("lookandfeel",
            lookup: "lookup",
            attributes: {},
            _event_url: "_event_url")
          state = flexmock("state", allowed?: "allowed?")
          @session = flexmock("session",
            lookandfeel: @lnf,
            request_path: "request_path",
            language: "language",
            state: state,
            user_input: "user_input")
          language = flexmock("language", empty?: false, name: "name", chapter_names: ["chapter_names"], change_log: [])
          registration = flexmock("registration", iksnr: "iksnr")
          sequence = flexmock("sequence",
            registration: registration,
            seqnr: "seqnr")
          pointer = flexmock("pointer", skeleton: "skeleton")
          @model = flexmock("model",
            language: language,
            pointer: pointer,
            sequences: [sequence])
          @composite = ODDB::View::Drugs::PatinfoComposite.new(@model, @session)
        end

        def test_document
          skip("Class is ODDB::View::Chapter. is this correct?")
          assert_kind_of(ODDB::View::Drugs::PatinfoInnerComposite, @composite.document(@model, @session))
        end

        def test_document_composite
          model = ODDB::PatinfoDocument2001.new
          language = flexmock("language", empty?: false, name: "name", chapter_names: ["chapter_names"], change_log: [])
          registration = flexmock("registration", iksnr: "iksnr")
          sequence = flexmock("sequence",
            registration: registration,
            seqnr: "seqnr")
          pointer = flexmock("pointer", skeleton: "skeleton")
          flexmock(model,
            language: language,
            pointer: pointer,
            sequences: [sequence])
          composite = ODDB::View::Drugs::PatinfoComposite.new(model, @session)
          skip("avoid undefined method `document_composite'")
          assert_kind_of(ODDB::View::Drugs::PatinfoInnerComposite, composite.document_composite(model, @session))
        end
      end

      # Regression coverage for the four crash sites in this file, together
      # 1440 of the 500s on ch.oddb.org in August 2026. All of them are the
      # same underlying problem: an ODBA reference that does not resolve to the
      # class it is declared as - or is simply nil.
      class TestPatinfoBrokenReferences < Minitest::Test
        def teardown
          ODBA.storage = nil
          super
        end

        def setup
          @lnf = flexmock("lookandfeel")
          @lnf.should_receive(:lookup).and_return("fallback")
        end

        def chooser_link(document, name)
          link = ODDB::View::Drugs::PiChapterChooserLink.allocate
          link.instance_variable_set(:@document, document)
          link.instance_variable_set(:@name, name)
          link.instance_variable_set(:@lookandfeel, @lnf)
          link
        end

        def test_chapter_title_uses_the_chapter_heading
          chapter = ODDB::Text::Chapter.new
          chapter.heading = "Unerwünschte Wirkungen"
          document = flexmock("document", unwanted_effects: chapter)
          assert_equal("Unerwünschte Wirkungen",
            chooser_link(document, :unwanted_effects).chapter_title)
        end

        def test_chapter_title_falls_back_to_the_subheading
          chapter = ODDB::Text::Chapter.new
          chapter.heading = ""
          section = chapter.next_section
          section.subheading = "Untertitel"
          document = flexmock("document", usage: chapter)
          assert_equal("Untertitel", chooser_link(document, :usage).chapter_title)
        end

        # The production case: ODBA::Stub#is_a? answers true from the *declared*
        # class without resolving, so the old guard passed and #heading blew up.
        def test_chapter_title_survives_a_stub_that_lies_about_its_class
          liar = flexmock("stub")
          liar.should_receive(:is_a?).with(ODDB::Text::Chapter).and_return(true)
          document = flexmock("document", company: liar)
          assert_equal("fallback", chooser_link(document, :company).chapter_title)
        end

        def test_chapter_title_falls_back_when_document_lacks_the_chapter
          document = flexmock("document")
          assert_equal("fallback", chooser_link(document, :date).chapter_title)
        end

        def test_change_log_size_counts_a_real_change_log
          document = flexmock("document", change_log: [1, 2, 3])
          assert_equal(3, Drugs.change_log_size(document))
        end

        # "undefined method 'size' for an instance of ODDB::PatinfoDocument"
        def test_change_log_size_is_zero_for_a_mis_referenced_change_log
          document = flexmock("document", change_log: ODDB::PatinfoDocument.new)
          assert_equal(0, Drugs.change_log_size(document))
        end

        def test_change_log_size_is_zero_when_resolving_raises
          document = flexmock("document")
          document.should_receive(:change_log).and_raise(ODBA::OdbaError)
          assert_equal(0, Drugs.change_log_size(document))
        end

        def preview
          composite = ODDB::View::Drugs::PatinfoPreviewComposite.allocate
          composite.instance_variable_set(:@lookandfeel, @lnf)
          composite
        end

        def test_patinfo_name_for_a_normal_model
          model = flexmock("model", empty?: false, name: "Aspirin")
          assert_equal("fallback", preview.patinfo_name(model, nil))
        end

        def test_patinfo_name_skips_an_empty_model
          model = flexmock("model", empty?: true, name: "Aspirin")
          assert_nil(preview.patinfo_name(model, nil))
        end

        # `unless model&.empty?` let nil through - nil is falsy, so the guard
        # passed and nil.name raised.
        def test_patinfo_name_survives_a_nil_model
          assert_nil(preview.patinfo_name(nil, nil))
        end

        # ActiveAgent, Package, Part, ODBA::Index, Array and Hash all showed up
        # here in production; none of them answer both #empty? and #name.
        def test_patinfo_name_survives_a_mis_referenced_model
          assert_nil(preview.patinfo_name(ODDB::ActiveAgent.new("Acidum"), nil))
          assert_nil(preview.patinfo_name([], nil))
        end

        def chooser
          chooser = ODDB::View::Drugs::PiChapterChooser.allocate
          chooser.instance_variable_set(:@lookandfeel, @lnf)
          chooser
        end

        def test_display_names_returns_the_chapter_names
          document = flexmock("document", empty?: nil, chapter_names: [:usage, :date])
          assert_equal([:usage, :date], chooser.display_names(document))
        end

        def test_display_names_is_empty_for_an_empty_document
          document = flexmock("document", empty?: true, chapter_names: [:usage])
          assert_equal([], chooser.display_names(document))
        end

        # `document&.empty?` is nil for a nil document, so the guard passed and
        # nil.chapter_names raised. Only reachable since patinfo_name stopped
        # raising first on the same pages.
        def test_display_names_survives_a_nil_document
          assert_equal([], chooser.display_names(nil))
        end

        def test_display_names_survives_a_mis_referenced_document
          assert_equal([], chooser.display_names(ODDB::ActiveAgent.new("Acidum")))
        end

        # Same trap in PatinfoInnerComposite#init: a nil model reached
        # nil.chapter_names. Constructing the composite runs init.
        def test_inner_composite_survives_a_nil_model
          session = flexmock("session", lookandfeel: @lnf)
          composite = ODDB::View::Drugs::PatinfoInnerComposite.new(nil, session)
          assert_empty(composite.send(:components))
        end

        def test_get_args_without_packages_degrades_instead_of_raising
          sequence = flexmock("sequence", packages: {})
          registration = flexmock("registration", sequence: sequence)
          app = flexmock("app", registration: registration)
          session = flexmock("session", app: app, request_path: "de/gcc/patinfo/reg/12345/seq/01")
          assert_equal([:reg, "12345", :seq, "01"], Drugs.get_args(nil, session))
        end

        def test_get_args_for_an_unknown_registration_degrades
          app = flexmock("app", registration: nil)
          session = flexmock("session", app: app, request_path: "de/gcc/patinfo/reg/99999/seq/01")
          assert_equal([:reg, "99999", :seq, "01"], Drugs.get_args(nil, session))
        end

        def test_get_args_still_resolves_the_package_when_there_is_one
          package = flexmock("package", ikscd: "007")
          sequence = flexmock("sequence", packages: {"007" => package})
          registration = flexmock("registration", sequence: sequence)
          app = flexmock("app", registration: registration)
          session = flexmock("session", app: app, request_path: "de/gcc/patinfo/reg/12345/seq/01")
          assert_equal([:reg, "12345", :seq, "01", :pack, "007"], Drugs.get_args(nil, session))
        end
      end
    end # Drugs
  end # View
end # ODDB
