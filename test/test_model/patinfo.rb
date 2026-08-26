#!/usr/bin/env ruby

# TestPatinfo -- oddb -- 25.02.2011 -- mhatakeyama@ywesee.com
# TestPatinfo -- oddb -- 29.10.2003 -- rwaltert@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "stub/odba"

require "minitest/autorun"
require "flexmock/minitest"
require "model/patinfo"
require "util/today"

module ODDB
  class Patinfo
    attr_accessor :sequences, :descriptions
  end
end

class TestPatinfo < Minitest::Test
  class StubSequence < ODBA::StorageStub
    include ODDB::Persistence
    def patinfo=(patinfo)
      if @patinfo.respond_to?(:remove_sequence)
        @patinfo.remove_sequence(self)
      end
      patinfo.add_sequence(self)
      @patinfo = patinfo
    end
  end

  def setup
    @patinfo = ODDB::Patinfo.new
  end

  def test_add_sequence
    @patinfo.sequences = []
    prod = StubSequence.new
    @patinfo.add_sequence(prod)
    assert_equal([prod], @patinfo.sequences)
  end

  def test_company_name
    assert_nil @patinfo.company_name
    @patinfo.sequences.push flexmock(company_name: "Company Name")
    assert_equal "Company Name", @patinfo.company_name
  end

  def test_name_base
    assert_nil @patinfo.name_base
    @patinfo.sequences.push flexmock(name_base: "Company Name")
    assert_equal "Company Name", @patinfo.name_base
  end

  def test_remove_sequence
    prod = StubSequence.new
    @patinfo.sequences = [prod]
    @patinfo.remove_sequence(prod)
    assert_equal([], @patinfo.sequences)
  end

  def test_odba_store
    @patinfo.descriptions = []
    assert_equal(@patinfo, @patinfo.odba_store)
  end
end

class TestPatinfoDocument < Minitest::Test
  def test_to_s1
    doc = ODDB::PatinfoDocument.new
    doc.name = "name"
    doc.company = "company"
    doc.galenic_form = "galenic_form"
    doc.effects = "effects"
    doc.purpose = "purpose"
    doc.amendments = "amendments"
    doc.contra_indications = "contra_indications"
    doc.precautions = "precautions"
    doc.pregnancy = "pregnancy"
    doc.usage = "usage"
    doc.unwanted_effects = "unwanted_effects"
    doc.general_advice = "general_advice"
    doc.other_advice = "other_advice"
    doc.composition = "composition"
    doc.packages = "packages"
    doc.distribution = "distribution"
    doc.date = "date"
    doc.iksnrs = "iksnrs"
    expected = <<~EOS
      name
      galenic_form
      effects
      purpose
      amendments
      contra_indications
      precautions
      pregnancy
      usage
      unwanted_effects
      general_advice
      other_advice
      composition
      packages
      distribution
      iksnrs
      company
      date
    EOS
    assert_equal(expected.strip, doc.to_s)
  end

  def test_to_s2
    doc = ODDB::PatinfoDocument.new
    doc.name = "name"
    doc.company = "company"
    doc.galenic_form = "galenic_form"
    doc.effects = "effects"
    doc.contra_indications = "contra_indications"
    doc.precautions = "precautions"
    doc.unwanted_effects = "unwanted_effects"
    doc.general_advice = "general_advice"
    doc.packages = "packages"
    doc.date = "date"
    doc.iksnrs = "iksnrs"
    expected = <<~EOS
      name
      galenic_form
      effects
      contra_indications
      precautions
      unwanted_effects
      general_advice
      packages
      iksnrs
      company
      date
    EOS
    assert_equal(expected.strip, doc.to_s)
  end

  def test_chapter_names
    doc = ODDB::PatinfoDocument.new
    expected = [:name, :galenic_form, :effects, :purpose,
      :amendments, :contra_indications, :precautions, :pregnancy,
      :usage, :unwanted_effects, :general_advice, :other_advice,
      :composition, :packages, :distribution, :fabrication, :iksnrs, :company, :date]
    assert_equal expected, doc.chapter_names
  end

  def test_add_change_log_item
    saved_language = ENV["LANGUAGE"]
    ENV["LANGUAGE"] = "C"
    doc = ODDB::PatinfoDocument.new
    doc.add_change_log_item("old text", "new text")
    item = doc.change_log[0]
    assert_instance_of ODDB::PatinfoDocument::ChangeLogItem, item
    assert_equal [item], doc.change_log
    assert_equal @@today, item.time
    assert_instance_of Diffy::Diff, item.diff
    expected = "-old text
\\ No newline at end of file
+new text
\\ No newline at end of file
"
    assert_equal expected, item.diff.to_s
    assert_equal @@today.to_s, item.time.to_s
  ensure
    ENV["LANGUAGE"] = saved_language
  end

  # Ein Eintrag, dessen diff.to_s stolpert, darf die uebrigen nicht mitreissen.
  #
  # Bis August 2026 stand im rescue von add_change_log_item
  # "@change_log = [item]" - die Dublettenpruefung warf bei einem Fehler das
  # gesamte Aenderungsprotokoll weg und ersetzte es durch den einen neuen
  # Eintrag. Alles Vorherige blieb in der Datenbank liegen, erreichbar war es
  # nicht mehr: 26293 von 55993 PatinfoDocument::ChangeLogItems.
  class TestPatinfoDocumentChangeLog < Minitest::Test
    def setup
      @document = ODDB::PatinfoDocument.new
    end

    # Ein Eintrag, der beim Vergleichen wirft - so verhaelt sich ein Diffy,
    # dessen Text die Kodierung sprengt.
    def kaputt
      item = ODDB::PatinfoDocument::ChangeLogItem.new
      item.time = Date.new(2020, 1, 1)
      diff = Object.new
      def diff.to_s
        raise Encoding::UndefinedConversionError, "kaputt"
      end
      item.diff = diff
      item
    end

    def heil(day)
      item = ODDB::PatinfoDocument::ChangeLogItem.new
      item.time = Date.new(2021, 1, day)
      item.diff = "diff #{day}"
      item
    end

    def test_keeps_the_history_when_the_duplicate_check_fails
      @document.change_log = [heil(1), kaputt, heil(2)]
      @document.add_change_log_item("alt", "neu", Date.new(2026, 8, 26))
      assert_equal(4, @document.change_log.size,
        "die drei bestehenden Eintraege muessen bleiben, der neue dazukommen")
    end

    def test_still_skips_a_real_duplicate
      @document.change_log = []
      @document.add_change_log_item("alt", "neu", Date.new(2026, 8, 26))
      @document.add_change_log_item("alt", "neu", Date.new(2026, 8, 26))
      assert_equal(1, @document.change_log.size,
        "derselbe Diff darf nicht zweimal drinstehen")
    end

    def test_ignores_a_change_that_is_none
      @document.change_log = [heil(1)]
      @document.add_change_log_item("gleich", "gleich")
      assert_equal(1, @document.change_log.size)
    end
  end
end
