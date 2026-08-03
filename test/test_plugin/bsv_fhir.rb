#!/usr/bin/env ruby

# TestBsvFhirPlugin -- oddb.org -- 2026
# Regression coverage for the SL-introduction (Kassenzulässigkeit) change-flag
# logic in BsvFhirPlugin#fix_flags_with_rss_logic_for.

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "stub/odba"
require "model/package"
require "util/money"
require "util/logfile"
require "plugin/bsv_fhir"
require "flexmock/minitest"

module ODDB
  class TestBsvFhirPluginFlags < Minitest::Test
    def teardown
      ODBA.storage = nil
      super # to clean up FlexMock
    end

    def setup
      @app = flexmock("app")
      @plugin = BsvFhirPlugin.new(@app)
      @listener = flexmock("preparations_listener")
      @plugin.instance_variable_set(:@preparations_listener, @listener)
      @pointer = flexmock("pointer")
    end

    # A valid_from inside the RSS window (today, which is always covered by the
    # range used by fix_flags_with_rss_logic_for).
    def in_range_time
      today = Date.today
      Time.local(today.year, today.month, today.day)
    end

    def public_price(amount, authority: :sl, valid_from: in_range_time)
      money = Util::Money.new(amount, :public, "CH")
      money.authority = authority
      money.valid_from = valid_from
      money
    end

    # Regression: the new price has already been unshifted to price_public(0) by
    # the time fix_flags_with_rss_logic_for runs, so "previous" must be read from
    # price_public(1). A brand-new SL entry (no prior price => price_public(1) is
    # nil) must be flagged :sl_entry so the med-drugs xls lists the new
    # Kassenzulässigkeit. Reading price_public(0) here (the old bug) would always
    # return the freshly stored price and never flag it.
    def test_flags_sl_entry_for_new_sl_price
      price = public_price(12.30)
      pack = flexmock("pack")
      pack.should_receive(:price_public).with(1).and_return(nil)
      pack.should_receive(:pointer).and_return(@pointer)
      @listener.should_receive(:flag_change).with(@pointer, :sl_entry).once
      @plugin.send(:fix_flags_with_rss_logic_for, pack, price, "12345")
    end

    def test_flags_price_cut_when_price_drops
      price = public_price(10.00)
      pack = flexmock("pack")
      pack.should_receive(:price_public).with(1).and_return(public_price(12.00))
      pack.should_receive(:data_origin).with(:price_public).and_return(:sl)
      pack.should_receive(:pointer).and_return(@pointer)
      @listener.should_receive(:flag_change).with(@pointer, :price_cut).once
      @plugin.send(:fix_flags_with_rss_logic_for, pack, price, "12345")
    end

    def test_flags_price_rise_when_price_increases
      price = public_price(15.00)
      pack = flexmock("pack")
      pack.should_receive(:price_public).with(1).and_return(public_price(12.00))
      pack.should_receive(:data_origin).with(:price_public).and_return(:sl)
      pack.should_receive(:pointer).and_return(@pointer)
      @listener.should_receive(:flag_change).with(@pointer, :price_rise).once
      @plugin.send(:fix_flags_with_rss_logic_for, pack, price, "12345")
    end

    def test_does_not_flag_new_entry_when_authority_not_sl
      price = public_price(12.30, authority: :bag)
      pack = flexmock("pack")
      pack.should_receive(:price_public).with(1).and_return(nil)
      @listener.should_receive(:flag_change).never
      @plugin.send(:fix_flags_with_rss_logic_for, pack, price, "12345")
    end

    def test_does_not_flag_when_valid_from_out_of_range
      price = public_price(12.30, valid_from: Time.local(2000, 1, 1))
      pack = flexmock("pack")
      @listener.should_receive(:flag_change).never
      @plugin.send(:fix_flags_with_rss_logic_for, pack, price, "12345")
    end

    def test_returns_without_error_when_price_nil
      pack = flexmock("pack")
      @listener.should_receive(:flag_change).never
      assert_nil(@plugin.send(:fix_flags_with_rss_logic_for, pack, nil, "12345"))
    end
  end

  # Until 2026 the limitation text was inlined as a `limitationText`
  # sub-extension. BAG moved it into a ClinicalUseDefinition resource referenced
  # by `limitationIndication`, and dropped `limitationText` from the export
  # entirely - so the old extractor silently skipped every limitation.
  class TestBsvFhirPluginLimitations < Minitest::Test
    def teardown
      ODBA.storage = nil
      super
    end

    def setup
      @plugin = BsvFhirPlugin.new(flexmock("app"))
    end

    def limitation_extension(subs)
      {
        "url" => "http://fhir.ch/ig/ch-epl/StructureDefinition/regulatedAuthorization-limitation",
        "extension" => subs
      }
    end

    def reg_auth(subs)
      {"indication" => [{"extension" => [limitation_extension(subs)]}]}
    end

    def clinical_use_def(id, text)
      {id => {
        "resourceType" => "ClinicalUseDefinition",
        "id" => id,
        "type" => "indication",
        "text" => {"div" => "<div xmlns=\"http://www.w3.org/1999/xhtml\">#{text}</div>"},
        "indication" => {"diseaseSymptomProcedure" => {"concept" => {"text" => text}}}
      }}
    end

    def first_section(lim_data)
      lim_data[:de].sections.first
    end

    def test_resolves_text_via_limitation_indication_reference
      ra = reg_auth([
        {"url" => "indicationCode", "valueString" => "22064.07"},
        {"url" => "limitationIndication",
         "valueReference" => {"reference" => "ClinicalUseDefinition/ABEVMY.07"}}
      ])
      cuds = clinical_use_def("ABEVMY.07", "Glioblastom Nach Kostengutsprache")
      lim_data = @plugin.send(:extract_limitation_data, ra, {}, [], :de, {}, cuds)
      refute_empty(lim_data, "limitation must be imported via the reference")
      sec = first_section(lim_data)
      assert_match(/Glioblastom Nach Kostengutsprache/, sec.paragraphs.map(&:to_s).join(" "))
    end

    # This is what makes the IndC code visible: View::Chapter renders subheadings.
    def test_indication_code_becomes_subheading
      ra = reg_auth([
        {"url" => "indicationCode", "valueString" => "22064.07"},
        {"url" => "limitationIndication",
         "valueReference" => {"reference" => "ClinicalUseDefinition/ABEVMY.07"}}
      ])
      cuds = clinical_use_def("ABEVMY.07", "Glioblastom")
      lim_data = @plugin.send(:extract_limitation_data, ra, {}, [], :de, {}, cuds)
      assert_equal("22064.07", first_section(lim_data).subheading.strip)
    end

    def test_imports_limitation_without_indication_code
      ra = reg_auth([
        {"url" => "limitationIndication",
         "valueReference" => {"reference" => "ClinicalUseDefinition/XYZ.01"}}
      ])
      cuds = clinical_use_def("XYZ.01", "Nur 1 Packung pro Patient.")
      lim_data = @plugin.send(:extract_limitation_data, ra, {}, [], :de, {}, cuds)
      refute_empty(lim_data)
      assert_equal("", first_section(lim_data).subheading.strip)
    end

    # Backward compatibility: if BAG ever re-adds the inline text, prefer it.
    def test_still_accepts_inline_limitation_text
      ra = reg_auth([{"url" => "limitationText", "valueString" => "Inline Limitation"}])
      lim_data = @plugin.send(:extract_limitation_data, ra, {}, [], :de, {}, nil)
      refute_empty(lim_data)
      assert_match(/Inline Limitation/, first_section(lim_data).paragraphs.map(&:to_s).join(" "))
    end

    def test_skips_when_referenced_resource_is_missing
      ra = reg_auth([
        {"url" => "limitationIndication",
         "valueReference" => {"reference" => "ClinicalUseDefinition/NOT_THERE"}}
      ])
      lim_data = @plugin.send(:extract_limitation_data, ra, {}, [], :de, {},
        clinical_use_def("OTHER.01", "irrelevant"))
      assert_empty(lim_data)
    end

    def test_falls_back_to_narrative_when_concept_text_missing
      cud = {"NARR.01" => {
        "resourceType" => "ClinicalUseDefinition",
        "id" => "NARR.01",
        "text" => {"div" => "<div xmlns=\"http://www.w3.org/1999/xhtml\">Nur   bei Erwachsenen</div>"}
      }}
      text = @plugin.send(:limitation_text_from_reference, "ClinicalUseDefinition/NARR.01", cud)
      assert_equal("Nur bei Erwachsenen", text)
    end

    def test_reference_helper_handles_missing_index
      assert_nil(@plugin.send(:limitation_text_from_reference, "ClinicalUseDefinition/X", nil))
      assert_nil(@plugin.send(:limitation_text_from_reference, "ClinicalUseDefinition/X", {}))
    end
  end
end
