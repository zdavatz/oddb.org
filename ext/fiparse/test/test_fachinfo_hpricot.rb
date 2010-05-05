#!/usr/bin/env ruby
# FiParse::TestPatinfoHpricot -- oddb -- 17.08.2006 -- hwyss@ywesee.com

require 'hpricot'

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path('../../../src', File.dirname(__FILE__))

require 'test/unit'
require 'fachinfo_hpricot'

module ODDB
	class FachinfoDocument
		def odba_id
			1
		end
	end
  module FiParse
class TestFachinfoHpricot < Test::Unit::TestCase
  def setup
    @writer = FachinfoHpricot.new
  end
  def test_chapter
    html = <<-HTML
      <div class="paragraph">
        <h2><a name="3300">Zusammensetzung</a></h2>
        <p class="spacing1"><span style="font-style:italic; ">Wirkstoffe:</span></p>
        <p class="spacing1">1 Brausetablette enthält: Carbasalatum calcicum 528 mg corresp. Acidum Acetylsalicylicum 415 mg, Acidum ascorbicum 250 mg.</p>
        <p class="noSpacing"><span style="font-style:italic; ">Hilfsstoffe: </span>Saccharinum, Cyclamas, Aromatica, Color.: E 120.</p>
      </div>
    HTML
    code, chapter = @writer.chapter(Hpricot(html).at("div.paragraph"))
    assert_equal('3300', code)
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Zusammensetzung', chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_equal("", section.subheading)
    assert_equal(3, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected =  "Wirkstoffe:"
    assert_equal(2, paragraph.formats.size)
    fmt = paragraph.formats.first
    assert_equal([:italic], fmt.values)
    assert_equal(0..10, fmt.range)
    fmt = paragraph.formats.last
    assert_equal([], fmt.values)
    assert_equal(11..-1, fmt.range)
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(1)
    expected =  "1 Brausetablette enthält: Carbasalatum calcicum 528 mg corresp. Acidum Acetylsalicylicum 415 mg, Acidum ascorbicum 250 mg."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(2)
    assert_equal(2, paragraph.formats.size)
    fmt = paragraph.formats.first
    assert_equal([:italic], fmt.values)
    assert_equal(0..11, fmt.range)
    fmt = paragraph.formats.last
    assert_equal([], fmt.values)
    assert_equal(12..-1, fmt.range)
    expected =  "Hilfsstoffe: Saccharinum, Cyclamas, Aromatica, Color.: E 120."
    assert_equal(expected, paragraph.text)
  end
  def test_identify_chapter__raises_unknown_chaptercode
    assert_raises(RuntimeError) { 
      @writer.identify_chapter('7800', nil)
    }
  end
end
class TestFachinfoHpricotAlcaCDe < Test::Unit::TestCase
  def setup
    @path = File.expand_path('data/html/de/alcac.fi.html', 
      File.dirname(__FILE__))
    @writer = FachinfoHpricot.new
    open(@path) { |fh| 
      @fachinfo = @writer.extract(Hpricot(fh))
    }
  end
  def test_fachinfo1
    assert_instance_of(FachinfoDocument, @fachinfo)
  end
  def test_name1
    assert_equal('Alca-C®', @fachinfo.name)
  end
  def test_company1
    ## this is unused. Since it's part of the base-class TextinfoHpricot, let's test it.
    chapter = @writer.company
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('NOVARTIS CONSUMER HEALTH', chapter.heading)
  end
  def test_galenic_form1
    chapter = @fachinfo.galenic_form
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Antipyretikum/Analgetikum mit Vitamin C', chapter.heading)
    assert_equal(0, chapter.sections.size)
  end
  def test_amzv1
    assert_nil @writer.amzv
  end
  def test_composition1
    chapter = @fachinfo.composition
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Zusammensetzung', chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_equal("", section.subheading)
    assert_equal(3, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected =  "Wirkstoffe:"
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(1)
    expected =  "1 Brausetablette enthält: Carbasalatum calcicum 528 mg corresp. Acidum Acetylsalicylicum 415 mg, Acidum ascorbicum 250 mg."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(2)
    expected =  "Hilfsstoffe: Saccharinum, Cyclamas, Aromatica, Color.: E 120."
    assert_equal(expected, paragraph.text)
  end
  def test_effects1
    chapter = @fachinfo.effects
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Eigenschaften/Wirkungen', chapter.heading)
  end
  def test_kinetic1
    chapter = @fachinfo.kinetic
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Pharmakokinetik', chapter.heading)
  end
  def test_indications1
    chapter = @fachinfo.indications
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Indikationen/Anwendungsmöglichkeiten', chapter.heading)
  end
  def test_usage1
    chapter = @fachinfo.usage
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Dosierung/Anwendung', chapter.heading)
  end
  def test_restrictions1
    chapter = @fachinfo.restrictions
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Anwendungseinschränkungen', chapter.heading)
  end
  def test_unwanted_effects1
    chapter = @fachinfo.unwanted_effects
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Unerwünschte Wirkungen', chapter.heading)
  end
  def test_interactions1
    chapter = @fachinfo.interactions
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Interaktionen', chapter.heading)
  end
  def test_overdose1
    chapter = @fachinfo.overdose
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Überdosierung', chapter.heading)
  end
  def test_other_advice1
    chapter = @fachinfo.other_advice
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Sonstige Hinweise', chapter.heading)
  end
  def test_iksnrs1
    chapter = @fachinfo.iksnrs
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('IKS-Nummern', chapter.heading)
  end
  def test_date1
    chapter = @fachinfo.date
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Stand der Information', chapter.heading)
  end
end
class TestFachinfoHpricotPonstanDe < Test::Unit::TestCase
  def setup
    @path = File.expand_path('data/html/de/ponstan.fi.html', 
      File.dirname(__FILE__))
    @writer = FachinfoHpricot.new
    open(@path) { |fh| 
      @fachinfo = @writer.extract(Hpricot(fh))
    }
  end
  def test_fachinfo2
    assert_instance_of(FachinfoDocument2001, @fachinfo)
  end
  def test_name2
    assert_equal('Ponstan®', @fachinfo.name)
  end
  def test_amzv2
    chapter = @fachinfo.amzv
    assert_instance_of Text::Chapter, chapter
    assert_equal 'AMZV', chapter.heading
  end
  def test_company2
    ## this is unused. Since it's part of the base-class TextinfoHpricot, let's test it.
    chapter = @writer.company
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('PFIZER', chapter.heading)
  end
  def test_composition2
    chapter = @fachinfo.composition
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Zusammensetzung', chapter.heading)
    assert_equal(2, chapter.sections.size)
    section = chapter.sections.first
    assert_equal("", section.subheading)
    assert_equal(1, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected =  "Wirkstoff: Mefenaminsäure."
    assert_equal(expected, paragraph.text)
    section = chapter.sections.last
    assert_equal "Hilfsstoffe\n", section.subheading
    assert_equal(4, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected =  "Filmtabletten: Vanillinum, Excipiens pro compresso obducto."
    assert_equal(expected, paragraph.text)
  end
  def test_galenic_form2
    chapter = @fachinfo.galenic_form
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Galenische Form und Wirkstoffmenge pro Einheit', chapter.heading)
  end
  def test_indications2
    chapter = @fachinfo.indications
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Indikationen/Anwendungsmöglichkeiten', chapter.heading)
  end
  def test_usage2
    chapter = @fachinfo.usage
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Dosierung/Anwendung', chapter.heading)
  end
  def test_contra_indications2
    chapter = @fachinfo.contra_indications
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Kontraindikationen', chapter.heading)
  end
  def test_restrictions2
    chapter = @fachinfo.restrictions
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Warnhinweise und Vorsichtsmassnahmen', chapter.heading)
  end
  def test_interactions2
    chapter = @fachinfo.interactions
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Interaktionen', chapter.heading)
  end
  def test_pregnancy2
    chapter = @fachinfo.pregnancy
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Schwangerschaft/Stillzeit', chapter.heading)
  end
  def test_driving_ability2
    chapter = @fachinfo.driving_ability
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Wirkung auf die Fahrtüchtigkeit und auf das Bedienen von Maschinen',
                 chapter.heading)
  end
  def test_unwanted_effects2
    chapter = @fachinfo.unwanted_effects
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Unerwünschte Wirkungen', chapter.heading)
  end
  def test_overdose2
    chapter = @fachinfo.overdose
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Überdosierung', chapter.heading)
  end
  def test_effects2
    chapter = @fachinfo.effects
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Eigenschaften/Wirkungen', chapter.heading)
  end
  def test_kinetic2
    chapter = @fachinfo.kinetic
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Pharmakokinetik', chapter.heading)
  end
  def test_preclinic2
    chapter = @fachinfo.preclinic
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Präklinische Daten', chapter.heading)
  end
  def test_other_advice2
    chapter = @fachinfo.other_advice
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Sonstige Hinweise', chapter.heading)
  end
  def test_iksnrs2
    chapter = @fachinfo.iksnrs
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Zulassungsnummer', chapter.heading)
  end
  def test_registration_owner2
    chapter = @fachinfo.registration_owner
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Zulassungsinhaberin', chapter.heading)
  end
  def test_date2
    chapter = @writer.date
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Stand der Information', chapter.heading)
  end
end
  end
end
