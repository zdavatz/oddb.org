#!/usr/bin/env ruby
# encoding: utf-8
# FiParse::TestPatinfoHpricot -- oddb -- 09.04.2012 -- yasaka@ywesee.com
# FiParse::TestPatinfoHpricot -- oddb -- 17.08.2006 -- hwyss@ywesee.com

require 'hpricot'

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path('../../../src', File.dirname(__FILE__))

require 'test/unit'
require 'fachinfo_hpricot'
require 'fiparse'
require 'plugin/text_info'

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
    @html = <<-HTML
      <div class="paragraph">
        <h2><a name="3300">Zusammensetzung</a></h2>
        <p class="spacing1"><span style="font-style:italic; ">Wirkstoffe:</span></p>
        <p class="spacing1">1 Brausetablette enthält: Carbasalatum calcicum 528 mg corresp. Acidum Acetylsalicylicum 415 mg, Acidum ascorbicum 250 mg.</p>
        <p class="noSpacing"><span style="font-style:italic; ">Hilfsstoffe: </span>Saccharinum, Cyclamas, Aromatica, Color.: E 120.</p>
      </div>
    HTML
    @code, @chapter = @writer.chapter(Hpricot(@html).at("div.paragraph"))
  end
  def test_heading
    assert_equal('3300', @code)
    assert_instance_of(ODDB::Text::Chapter, @chapter )
    assert_equal('Zusammensetzung', @chapter.heading)
  end
  
  def test_hilfstoffe
    section = @chapter.sections.first
    paragraph = section.paragraphs.at(2)
    expected =  /Hilfsstoffe: Saccharinum, Cyclamas, Aromatica, Color.: E.*120./
    assert_match(expected, paragraph.text)
  end
  
  def test_italic_style
    section = @chapter.sections.first
    paragraph = section.paragraphs.at(2)
    assert_equal(2, paragraph.formats.size)
    fmt = paragraph.formats.first
    assert_equal([:italic], fmt.values)
    assert_equal(0..11, fmt.range)
    fmt = paragraph.formats.last
    assert_equal([], fmt.values)
    assert_equal(12..-1, fmt.range)
  end
  
  def test_chapter
    assert_equal(1, @chapter.sections.size)
    section = @chapter.sections.first
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
    section = @chapter.sections.first
    paragraph = section.paragraphs.at(1)
    expected =  /1 Brausetablette enth.*lt: Carbasalatum calcicum 528.*mg corresp\. Acidum Acetylsalicylicum 415.*mg, Acidum ascorbicum 250.*mg\./
    assert_match(expected, paragraph.text)
    paragraph = section.paragraphs.at(2)
    assert_equal(2, paragraph.formats.size)
    fmt = paragraph.formats.first
    assert_equal([:italic], fmt.values)
    assert_equal(0..11, fmt.range)
    fmt = paragraph.formats.last
    assert_equal([], fmt.values)
    assert_equal(12..-1, fmt.range)
  end
  def test_identify_chapter__raises_unknown_chaptercode
    @writer = FachinfoHpricot.new
    assert_nil(@writer.identify_chapter('7800', nil)) # 7800 = Packungen
  end
  
  def test_Zulassungsnummer_isentress
    html = <<-HTML
<p class="s4" id="section17"><span class="s44"><span>Zulassungsnummer</span></span></p>
<p class="s4"><span class="s48"><span>58267</span></span><span class="s48"><span>, 62946</span></span><span class="s48"><span> (Swissmedic)</span></span></p>
<p class="s4">&nbsp;</p>
  HTML
    xpath = "p[@id^='section'"
    elem = Hpricot(html).at(xpath)
    assert("Zulassungsnummer",  elem.inner_text)
    assert("58267, 62946 (Swissmedic)", elem.next_sibling.inner_text)
    assert_nil(elem.at("div"))
    assert_nil(elem.at("p"))
  end
  
  def test_Zulassungsnummer_isentress_html
    isentress_html = <<-HTML
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
<?xml version="1.0" encoding="utf-8"?><html><body><div xmlns="http://www.w3.org/1999/xhtml">
<p class="s4" id="section17"><span class="s44"><span>Zulassungsnummer</span></span></p>
<p class="s4"><span class="s48"><span>58267</span></span><span class="s48"><span>, 62946</span></span><span class="s48"><span> (Swissmedic)</span></span></p>
</div></body></html>
HTML
    writer = FachinfoHpricot.new
    writer.format =  :swissmedicinfo
    fachinfo = writer.extract(Hpricot(isentress_html), :fi, 'Isentress')
    assert_equal('Zulassungsnummer', fachinfo.iksnrs.heading)    
    assert_equal("Zulassungsnummer\n58267, 62946 (Swissmedic)", fachinfo.iksnrs.to_s)    
  end
  
  def test_Zulassungsnummer_cipralex
    html = <<-HTML
  <div class="paragraph" id="Section7750">
    <div class="absTitle">Zulassungsnummer</div>
    <p class="noSpacing">55961, 56366, 62184 (Swissmedic).</p>
  </div>
  HTML
    elem = Hpricot(html).at("div.paragraph")
    assert("Zulassungsnummer",  elem.at("div").inner_text)
    assert_not_nil(elem.at("div"))
    assert_not_nil(elem.at("p"))
    assert("58267, 62946 (Swissmedic)", elem.at("p").inner_text)
  end
  
  def test_Zulassungsnummer_cipralex_html
    cipralex_html = <<-HTML
    <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
<html><body><div id="monographie">
  <div class="MonTitle">Cipralex&reg; Filmtabletten/Tropfen 10 mg/ml, 20 mg/ml<br>Cipralex MELTZ&reg; Schmelztabletten<br>
</div>
  <div class="ownerCompany">
    <div style="text-align: right;">LUNDBECK</div>
  </div>
  <div class="paragraph" id="Section7750">
    <div class="absTitle">Zulassungsnummer</div>
    <p class="noSpacing">55961, 56366, 62184 (Swissmedic).</p>
  </div>
</div></body></html>
HTML
    writer = FachinfoHpricot.new
    writer.format =  :swissmedicinfo
    fachinfo = writer.extract(Hpricot(cipralex_html), :fi, 'Cipralex Filmtabletten/Tropfen 10 mg/ml, 20 mg/ml<br>Cipralex MELTZ Schmelztabletten')
    assert_equal('Zulassungsnummer', fachinfo.iksnrs.heading)    
    assert_equal("Zulassungsnummer\n55961, 56366, 62184 (Swissmedic).", fachinfo.iksnrs.to_s)    
  end
  
end

class TestFachinfoHpricotAlcaCDe < Test::Unit::TestCase
  MedicalName = 'Alca-C®'
  def setup
    return if defined?(@@path)
    @@path = File.expand_path('data/html/de/alcac.fi.html', File.dirname(__FILE__))
    @@writer = FachinfoHpricot.new
    open(@@path) { |fh| 
      @@fachinfo = @@writer.extract(Hpricot(fh), :fi, MedicalName)
    }
    puts 8
    pp @@fachinfo
  end
  def test_fachinfo1
    assert_instance_of(FachinfoDocument, @@fachinfo)
  end
  def test_name1
    assert_equal(MedicalName, @@fachinfo.name.to_s)
  end
  def test_company1
    ## this is unused. Since it's part of the base-class TextinfoHpricot, let's test it.
    chapter = @@writer.company
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('NOVARTIS CONSUMER HEALTH', chapter.heading)
  end
  def test_galenic_form1
    chapter = @@fachinfo.galenic_form
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Antipyretikum/Analgetikum mit Vitamin C', chapter.heading)
    assert_equal(0, chapter.sections.size)
  end
  def test_amzv1
    assert_nil @@writer.amzv
  end
  def test_composition1
    chapter = @@fachinfo.composition
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
    expected =  /1 Brausetablette enth.*lt: Carbasalatum calcicum 528.*mg corresp. Acidum Acetylsalicylicum 415.*mg, Acidum ascorbicum 250.*mg./
    assert_match(expected, paragraph.text)
    paragraph = section.paragraphs.at(2)

    expected =  /Hilfsstoffe: Saccharinum, Cyclamas, Aromatica, Color.: E.*120\./
    assert_match(expected, paragraph.text)
  end
  def test_effects1
    chapter = @@fachinfo.effects
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Eigenschaften/Wirkungen', chapter.heading)
  end
  def test_kinetic1
    chapter = @@fachinfo.kinetic
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Pharmakokinetik', chapter.heading)
  end
  def test_indications1
    chapter = @@fachinfo.indications
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Indikationen/Anwendungsmöglichkeiten', chapter.heading)
  end
  def test_usage1
    chapter = @@fachinfo.usage
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Dosierung/Anwendung', chapter.heading)
  end
  def test_restrictions1
    chapter = @@fachinfo.restrictions
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Anwendungseinschränkungen', chapter.heading)
  end
  def test_unwanted_effects1
    chapter = @@fachinfo.unwanted_effects
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Unerwünschte Wirkungen', chapter.heading)
  end
  def test_interactions1
    chapter = @@fachinfo.interactions
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Interaktionen', chapter.heading)
  end
  def test_overdose1
    chapter = @@fachinfo.overdose
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Überdosierung', chapter.heading)
  end
  def test_other_advice1
    chapter = @@fachinfo.other_advice
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Sonstige Hinweise', chapter.heading)
  end
  def test_iksnrs1
    chapter = @@fachinfo.iksnrs
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('IKS-Nummern', chapter.heading)
  end
  def test_date1
    chapter = @@fachinfo.date
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Stand der Information', chapter.heading)
  end
end if false

  Zyloric_Reg = 'Zyloric®'
  
  # Zyloric had a problem that the content of the fachinfo was mostly in italic
  class TestFachinfoHpricot_32917_Zyloric_De < Test::Unit::TestCase
    
    def setup
      return if defined?(@@path)
      @@path = File.expand_path('data/html/de/fi_32917_zyloric.de.html',  File.dirname(__FILE__))
      @@writer = FachinfoHpricot.new
      open(@@path) { |fh| 
        
        @@fachinfo = @@writer.extract(Hpricot(fh), :fi, Zyloric_Reg)
      }
    end
    
    def test_fachinfo2
      assert_instance_of(FachinfoDocument2001, @@fachinfo)
    end 
    
    def test_name
      # fails as we find in the html 
      # <span class="s2"><span>Zyloric</span></span><sup class="s3"><span class="s4">&acirc;</span>/sup>
      assert_equal(Zyloric_Reg, @@fachinfo.name.to_s)
      assert_equal("", @@writer.title.to_s)
    end
    
    def test_content
      assert_nil(/span/.match(@@fachinfo.indications.to_s))
      assert_nil(/italic/.match(@@fachinfo.to_s))
      assert_nil(/span/.match(@@fachinfo.to_s))
      assert_equal("Zulassungsnummer\n32917 (Swissmedic)", @@fachinfo.iksnrs.to_s)
      assert_equal(["32917"], TextInfoPlugin::get_iksnrs_from_string(@@fachinfo.iksnrs.to_s))
    end
    
    def test_galenic_form
      assert_equal("Galenische Form und Wirkstoffmenge pro Einheit\nTabletten zu 100 mg und 300 mg .", @@fachinfo.galenic_form.to_s)
    end   
    
   end
  
  # Zyloric had a problem that the content of the fachinfo was mostly in italic
  class TestFachinfoHpricotZyloricFr < Test::Unit::TestCase
    MedicalName = Zyloric_Reg
    def setup
      return if defined?(@@path)
      @@path = File.expand_path('data/html/fr/fi_Zyloric.fr.html',  File.dirname(__FILE__))
      @@writer = FachinfoHpricot.new
      open(@@path) { |fh| 
        
        @@fachinfo = @@writer.extract(Hpricot(fh), :fi, MedicalName)
      }
    end
    
    def test_fachinfo2
      assert_instance_of(FachinfoDocument2001, @@fachinfo)
    end 
    
    def test_name2
      assert_equal(Zyloric_Reg, @@fachinfo.name.to_s) # is okay as found this in html Zyloric&reg;
    end
    
    def test_span
      assert_nil(/span/.match(@@fachinfo.indications.to_s))
      assert_nil(/italic/.match(@@fachinfo.to_s))
      assert_nil(/span/.match(@@fachinfo.to_s))
    end

    def test_iksnrs
      assert_equal("Numéro d’autorisation\n32917 (Swissmedic).", @@fachinfo.iksnrs.to_s)
      assert_equal(["32917"], TextInfoPlugin::get_iksnrs_from_string(@@fachinfo.iksnrs.to_s))
    end
    
    def test_galenic_form
      assert_equal("Forme galénique et quantité de principe actif par unité\nComprimés à 100 et 300 mg.", @@fachinfo.galenic_form.to_s)
    end
    
    def test_italic_absent
      File.open("fi_Zyloric.yaml", 'w+') { |fi| fi.puts @@fachinfo.to_yaml }
      assert_nil(/- :italic/.match(@@fachinfo.to_yaml))
    end
    
   end

  Styles_Streuli = 'p{margin-top:0pt;margin-right:0pt;margin-bottom:0pt;margin-left:0pt;}table{border-spacing:0pt;border-collapse:collapse;} table td{vertical-align:top;}.s2{font-family:Arial;font-size:14pt;font-weight:bold;}.s3{font-family:Arial;font-size:11.2pt;font-weight:bold;}.s4{line-height:150%;margin-right:113.3pt;}.s5{font-size:11pt;line-height:150%;margin-right:113.3pt;}.s6{font-family:Arial;font-size:11pt;font-weight:bold;}.s7{font-family:Arial;font-size:11pt;font-style:italic;}.s8{font-family:Arial;font-size:11pt;}.s9{font-family:Arial;font-size:8.8pt;}.s10{font-family:Arial;font-size:11pt;font-style:italic;text-decoration:line-through;}.s11{line-height:150%;margin-right:113.4pt;}.s12{font-size:11pt;line-height:150%;margin-right:113.4pt;}.s13{font-family:Arial;font-size:11pt;color:#000000;}.s14{font-family:Arial;font-size:9.5pt;}.s15{font-family:Arial;font-size:11pt;line-height:150%;margin-right:56.7pt;}.s16{line-height:150%;margin-right:56.7pt;}.s17{font-family:Times New Roman;font-size:8.8pt;}.
s18{font-
family:Arial;font-size:11pt;line-height:150%;margin-right:113.4pt;}'
  #  problem that the content of the fachinfo was mostly in italic
  class TestFachinfoHpricot_58106_Finasterid_De < Test::Unit::TestCase
    
    MedicInfoName = 'Finasterid Streuli® 5'

    def setup
      return if defined?(@@path)
      @@path = File.expand_path('data/html/de/fi_58106_finasterid.de.html',  File.dirname(__FILE__))      
      @@writer = FachinfoHpricot.new
      
      open(@@path) { |fh| 
        @@fachinfo = @@writer.extract(Hpricot(fh), :fi, MedicInfoName, Styles_Streuli)
      }
    end
    
    def test_fachinfo2
      assert_instance_of(FachinfoDocument2001, @@fachinfo)
    end 
    
    def test_name2
      assert_equal(MedicInfoName, @@fachinfo.name.to_s) # is okay as found this in html Streuli&reg;
    end
    
    def test_span
      assert_nil(/span/.match(@@fachinfo.indications.to_s))
      assert_nil(/italic/.match(@@fachinfo.indications.to_s))
    end

    def test_iksnrs
      assert_equal("Zulassungsnummer\n58’106 (Swissmedic)", @@fachinfo.iksnrs.to_s)
      assert_equal(["58106"], TextInfoPlugin::get_iksnrs_from_string(@@fachinfo.iksnrs.to_s))
    end
    
    def test_galenic_form
      assert_equal("Galenische Form und Wirkstoffmenge pro Einheit\nFilmtabletten zu 5 mg Finasterid.", @@fachinfo.galenic_form.to_s)
    end
    
    def test_italic_absent
      File.open("fi_58106.yaml", 'w+') { |fi| fi.puts @@fachinfo.to_yaml }
      # puts "#{__LINE__}: found #{@fachinfo.to_yaml.scan(/- :italic/).size} occurrences of italic in yaml"
      occurrences = @@fachinfo.to_yaml.scan(/- :italic/).size
      assert(occurrences <= 70, "Find more than 70 occurrences in yaml")
    end
    
  end

 #  problem that the content of the fachinfo was mostly in italic
  StylesXalos = 'p{margin-top:0pt;margin-right:0pt;margin-bottom:0pt;margin-left:0pt;}table{border-spacing:0pt;border-collapse:collapse;} table td{vertical-align:top;}.s2{font-family:Arial;font-size:14pt;font-weight:bold;}.s3{font-family:Arial;font-size:11.2pt;font-weight:bold;}.s4{line-height:150%;}.s5{font-family:Arial;font-size:11pt;line-height:150%;}.s6{font-family:Arial;font-size:11pt;font-style:italic;font-weight:bold;}.s7{font-family:Arial;font-size:11pt;font-style:italic;}.s8{font-family:Arial;font-size:11pt;}.s9{font-family:Arial;font-size:11pt;font-weight:normal;}.s10{line-height:150%;margin-top:6pt;}.s11{font-family:Arial;font-size:11pt;font-style:italic;font-weight:normal;}.s12{font-family:Arial;font-size:8.8pt;}.s13{font-family:Arial;font-size:8.8pt;font-weight:normal;}.s14{font-family:Arial;font-size:11pt;font-weight:bold;}'
  class TestFachinfoHpricot_62439_Xalos_Duo_De < Test::Unit::TestCase
    MedicInfoName = 'Xalos®-Duo'
    def setup
      return if defined?(@@path)
      @@path = File.expand_path('data/html/de/fi_62439_xalos_duo.de.html',  File.dirname(__FILE__))     
      @@writer = FachinfoHpricot.new
      open(@@path) { |fh| 
        
        @@fachinfo = @@writer.extract(Hpricot(fh), :fi, MedicInfoName, StylesXalos)
      }
#      open(@@path) { |fh| @@fachinfo = @@writer.extract(Hpricot(fh)) }
    end
    
    def test_fachinfo2
      assert_instance_of(FachinfoDocument2001, @@fachinfo)
    end 
    
    def test_name2
      assert_equal(MedicInfoName, @@fachinfo.name.to_s)
    end
    
    def test_span
      assert_nil(/span/.match(@@fachinfo.indications.to_s))
      assert_nil(/italic/.match(@@fachinfo.to_s))
      assert_nil(/span/.match(@@fachinfo.to_s))
    end

    def test_iksnrs
      assert_equal("Zulassungsnummer\n62’439 (Swissmedic).", @@fachinfo.iksnrs.to_s)
      assert_equal(["62439"], TextInfoPlugin::get_iksnrs_from_string(@@fachinfo.iksnrs.to_s))
    end
    
    def test_galenic_form
      assert_equal("Galenische Form und Wirkstoffmenge pro Einheit\nAugentropfen zu 50 µg Latanoprostum und 5,0 mg Timololum (entspricht 6,83 mg Timololi maleas) pro 1 ml. Ein Tropfen enthält etwa 1,5 µg Latanoprostum und 150 µg Timololum.",
                   @@fachinfo.galenic_form.to_s)
    end
    
    def test_italic_absent
      # File.open("fi_62439.yaml", 'w+') { |fi| fi.puts @@fachinfo.to_yaml }
      # puts "#{__LINE__}: found #{@fachinfo.to_yaml.scan(/- :italic/).size} occurrences of italic in yaml"
      occurrences = @@fachinfo.to_yaml.scan(/- :italic/).size
      assert(occurrences == 72, "Find exactly 72 occurrences of italic in yaml")
    end
    
  end
  
 #  problem that the content of the fachinfo was mostly in italic
  StylesBisoprolol = 'p{margin-top:0pt;margin-right:0pt;margin-bottom:0pt;margin-left:0pt;}table{border-spacing:0pt;border-collapse:collapse;} table td{vertical-align:top;}.s2{font-family:Arial;font-size:12pt;font-weight:bold;}.s3{line-height:150%;margin-top:24pt;}.s4{line-height:150%;}.s5{font-family:Arial;font-size:11pt;font-weight:bold;}.s6{line-height:150%;margin-top:10pt;}.s7{font-family:Arial;font-size:11pt;font-style:italic;}.s8{font-family:Arial;font-size:11pt;}.s9{font-family:Arial;font-size:11pt;font-style:italic;font-weight:normal;}.s10{line-height:150%;margin-top:6pt;}.s11{font-family:Arial;font-size:8.8pt;}.s12{font-family:Arial;font-size:11pt;font-style:italic;color:#000000;}.s13{font-family:Arial;font-size:11pt;font-weight:normal;}.s14{font-family:Arial;font-size:8.8pt;font-weight:normal;}.s15{font-family:Arial;font-size:11pt;font-style:normal;}'
  class TestFachinfoHpricot_62111_Bisoprolol_De < Test::Unit::TestCase
    Styles = ''
    MedicInfoName = 'Bisoprolol Axapharm'
    def setup
      return if defined?(@@path)
      @@path = File.expand_path('data/html/de/fi_62111_bisoprolol.de.html',  File.dirname(__FILE__))     
      @@writer = FachinfoHpricot.new
      open(@@path) { |fh| 
        
        @@fachinfo = @@writer.extract(Hpricot(fh), :fi, MedicInfoName, StylesBisoprolol)
      }
#      open(@@path) { |fh| @@fachinfo = @@writer.extract(Hpricot(fh)) }
    end
    
    def test_fachinfo2
      assert_instance_of(FachinfoDocument2001, @@fachinfo)
    end 
    
    def test_name2
      assert_equal(MedicInfoName, @@fachinfo.name.to_s)
    end
    
    def test_span
      assert_nil(/span/.match(@@fachinfo.indications.to_s))
      assert_nil(/italic/.match(@@fachinfo.to_s))
      assert_nil(/span/.match(@@fachinfo.to_s))
    end

    def test_iksnrs
      assert_equal("Zulassungsnummer\n62111 (Swissmedic).", @@fachinfo.iksnrs.to_s)
      assert_equal(["62111"], TextInfoPlugin::get_iksnrs_from_string(@@fachinfo.iksnrs.to_s))
    end
    
    def test_galenic_form
      assert_equal("Galenische Form und Wirkstoffmenge pro Einheit\nRunde, teilbare Filmtablette zu 2.5 mg, 5 mg und 10 mg.",
                   @@fachinfo.galenic_form.to_s)
    end    
    
    def test_italic_absent
      File.open("fi_62111.yaml", 'w+') { |fi| fi.puts @@fachinfo.to_yaml }
      # puts "#{__LINE__}: found #{@fachinfo.to_yaml.scan(/- :italic/).size} occurrences of italic in yaml"
      occurrences = @@fachinfo.to_yaml.scan(/- :italic/).size
      assert(occurrences == 79, "Find exactly 79 occurrences of italic in yaml")
    end

    def test_some_more_swissmedic
      assert_equal(["61559", "61564", "61566", "61615", "61617", "61623"], TextInfoPlugin::get_iksnrs_from_string("61'559 - 61'564, 61'566 – 61'615, 61'617 - 61'623"))
    end
    
  end
  
  #  problem that the content of the fachinfo did not display correctly the firmenlogo  
  class TestFachinfo_62580_Novartis_Seebri< Test::Unit::TestCase
    MedicInfoName = ' Seebri Breezhaler'
    def setup
      return if defined?(@@path)
      @@path = File.expand_path('data/html/de/fi_62580_novartis_seebris.de.html',  File.dirname(__FILE__))     
      @@writer = FachinfoHpricot.new
      open(@@path) { |fh| 
        
        @@fachinfo = @@writer.extract(Hpricot(fh), :fi, MedicInfoName)
      }
    end
    
    def test_name2
      assert_equal(MedicInfoName, @@fachinfo.name.to_s)
    end
    
    def test_interactions
      assert_equal('Interaktionen', @@fachinfo.contra_indications.heading)
      assert(@@fachinfo.interactions.index('(1,10, 1,93)'))
    end
    
    def test_name2
      assert_equal(
"Zusammensetzung
Wirkstoff
Glycopyrronium als Glycopyrroniumbromid.
Hilfsstoffe
Lactose-Monohydrat., Magnesiumstearat.
Color: Gelborange S (E 110), excipiens pro capsula.",
      @@fachinfo.composition.to_s)
    end
    
    def test_firmenlogo
      assert(@@fachinfo.galenic_form.to_s.index('Firmenlogo'))
      assert(@@fachinfo.effects.to_s.index('(image)'), 'Wirkungen muss Bild enthalten')
      assert(@@fachinfo.galenic_form.to_s.index('(image)'), 'galenic_form must have an image')
      assert(@@fachinfo.to_yaml.index('/resources/images/fachinfo/de/_Seebri_Breezhaler_files/5.png'), 'Must have image nr 5')
      assert(@@fachinfo.to_yaml.index('/resources/images/fachinfo/de/_Seebri_Breezhaler_files/4.png'), 'Must have image nr 4')
      assert(@@fachinfo.to_yaml.index('/resources/images/fachinfo/de/_Seebri_Breezhaler_files/3.png'), 'Must have image nr 3')

      assert(@@fachinfo.galenic_form.to_s.index('(image)'), 'Zusamensetzung muss Bild enthalten')
      assert(@@fachinfo.to_yaml.index('/resources/images/fachinfo/de/_Seebri_Breezhaler_files/1.x-wmf'), 'Must have image nr 1')
    end

    def test_iksnrs
      assert_equal("Zulassungsnummer\n62580(Swissmedic)", @@fachinfo.iksnrs.to_s)
      assert_equal(["62580"], TextInfoPlugin::get_iksnrs_from_string(@@fachinfo.iksnrs.to_s))
    end    
  end if false
 
  class TestFachinfoHpricotStyle < Test::Unit::TestCase

      def test_styles
      italicStyles= TextinfoHpricot::get_italic_style(Styles_Streuli)
      assert(italicStyles.index('s7'))
      assert(italicStyles.index('s10'))    
      assert(italicStyles.size >= 2 )
    end

    def test_styles_2
      italicStyles= TextinfoHpricot::get_italic_style(StylesXalos)
      assert(italicStyles.index('s6'))
      assert(italicStyles.index('s7'))
      assert(italicStyles.index('s11'))
      assert(italicStyles.size == 3 )
    end
  end
   class TestFachinfoHpricot_62184_Cipralex_De < Test::Unit::TestCase
      
      Styles_Cipralex =           
          '.h1{font-size:22pt;font-family:Arial,Helvetica,Univers,"Zurich BT","sans-serif";font-weight:bolder;color:black;}.LabelText{font-family:Arial,"Helvetica Black","LB Helvetica Black","Univers Black",Zurich,"sans-serif";font-size:smaller;font-weight:bolder;color:Black;}.ErrorMessage{font-family:Arial,"Helvetica Black","LB Helvetica Black","Univers Black",Zurich,"sans-serif";font-size:small;color:Red;}.ErrorMessageSmall{font-family:Arial,"Helvetica Black","LB Helvetica Black","Univers Black",Zurich,"sans-serif";font-size:smaller;color:Red;}.ListText{font-family:"Arial Black","Helvetica Black","LB Helvetica Black","Univers Black","Zurich Blk BT","sans-serif";font-size:smaller;}.EmptyGridText{font-family:Arial,Helvetica,Univers,"Zurich BT","sans-serif";color:Red;}.CompanyDetail{font-family:Arial,Helvetica,Univers,"Zurich BT","sans-serif";font-size:smaller;}.ContentTitle{font-family:"Arial Black","Helvetica Black","LB Helvetica Black","Univers Black","Zurich Blk BT","sans-serif";color:#003366;}.CopyrightText{font-family:"Arial Black","Helvetica Black","LB Helvetica Black","Univers Black","Zurich Blk BT","sans-serif";font-size:smaller;color:#003366;}.BekanntmachungenText{font-family:Arial,"Helvetica Black","LB Helvetica Black","Univers Black",Zurich,"sans-serif";font-size:smaller;color:Black;}.BekanntmachungenTitel{font-family:Arial,"Helvetica Black","LB Helvetica Black","Univers Black",Zurich,"sans-serif";font-size:smaller;font-weight:bolder;color:Black;}.CookieWarning{font-family:Arial,"Helvetica Black","LB Helvetica Black","Univers Black",Zurich,"sans-serif";font-size:medium;font-weight:bolder;color:Red;}.HelpText{font-size:12pt;font-family:Arial,Helvetica,Univers,"Zurich BT","sans-serif";color:black;}.HelpTextBold{font-size:11pt;font-family:Arial,Helvetica,Univers,"Zurich BT","sans-serif";color:black;font-weight:bold;}.HelpTextSmall{font-size:11pt;font-family:Arial,Helvetica,Univers,"Zurich BT","sans-serif";color:black;}.HelpTextSmallBold{font-size:11pt;font-family:Arial,Helvetica,Univers,"Zurich BT","sans-serif";color:black;font-weight:bold;}.Zwischentitel{font-size:12pt;font-family:Arial,Helvetica,Univers,"Zurich BT","sans-serif";font-weight:bolder;color:black;}.AdobeAcrobatReaderText{font-family:Arial,Helvetica,Univers,"Zurich BT","sans-serif";font-size:x-small;}.Hyperlinks{font-family:Arial,"Helvetica Black","LB Helvetica Black","Univers Black",Zurich,"sans-serif";font-size:smaller;color:Blue;}#menue{z-index:1;position:fixed;left:0px;top:0px;}#monographie{margin-left:30px;margin-right:30px;margin-bottom:10px;font-family:"Verdana","Arial","Tahoma","Helvetica","Geneva","sans-serif";color:black;}#monographie .MonTitle{font-size:1.5em;font-weight:bold;margin-bottom:0.2em;}#monographie .absTitle{font-size:0.9em;font-weight:bold;font-style:italic;margin-bottom:0.0em;}#monographie .untertitel{font-size:0.9em;font-weight:normal;margin-top:0.5em;margin-bottom:0.0em;}#monographie .untertitel1{font-size:0.9em;font-weight:normal;font-style:italic;margin-top:0.2em;margin-bottom:0.0em;}#monographie .header{font-size:0.85em;font-weight:normal;color:#999999;text-align:left;margin-bottom:2em;visibility:hidden;display:none;}#monographie .footer{font-size:0.85em;font-weight:normal;color:#999999;margin-top:2.0em;border-top:#999999 1px solid;padding-top:0.5em;}#monographie div p{font-size:0.9em;}#monographie .paragraph{font-weight:normal;font-style:normal;margin-top:0.8em;}.noSpacing{margin-top:0em;margin-bottom:0em;}.spacing1{margin-top:0em;margin-bottom:0.25em;}.spacing2{margin-top:0em;margin-bottom:0.5em;}#monographie .ownerCompany{font-size:1em;font-style:italic;font-weight:bold;text-align:right;margin-bottom:1.0em;border-top:black 1px solid;border-bottom:black 1px solid;padding-top:0.2em;padding-bottom:0.2em;}#monographie .titleAdd{font-size:0.9em;font-weight:bold;font-style:italic;}#monographie .shortCharacteristic{font-size:1.1em;font-style:italic;}#monographie .indention1{margin-left:5em;}#monographie .indention2{margin-left:10em;}#monographie .indention3{margin-left:15em;}#monographie .box{font-size:.9em;font-weight:normal;font-style:normal;margin-top:5px;margin-bottom:5px;padding-top:5px;padding-bottom:6px;padding-left:5px;padding-right:5px;border-width:1px;border-color:Black;border-style:solid;}#monographie .image{margin-top:20px;margin-bottom:20px;}#monographie table{font-family:"Courier New","sans-serif";font-size:1.0em;margin-top:1.0em;margin-bottom:1.0em;border-top:solid 1px black;border-bottom:solid 1px black;}#monographie td{font-family:"Courier New","sans-serif";font-size:1.0em;}.rowSepBelow{border-bottom:solid 1px black;}.goUp{float:right;margin-right:-40px;}.tblArticles{border:solid 1pt #E5E7E8;vertical-align:top;text-align:left;border-spacing:0;width:100%;}.tblArticles .product{width:37%;font-size:small;vertical-align:top;border-top:solid 1pt #E5E7E8;border-right:solid 1pt #E5E7E8;}.tblArticles .productEmpty{width:37%;}.tblArticles .normal-right{border-right:solid 1pt #E5E7E8;border-top:solid 1pt #E5E7E8;width:15%;text-align:right;vertical-align:top;font-size:small;}.tblArticles .normal-center{border-right:solid 1pt #E5E7E8;border-top:solid 1pt #E5E7E8;width:10%;text-align:center;vertical-align:top;font-size:small;}.tblArticles .picture{width:15%;text-align:center;border-top:solid 1pt #E5E7E8;}.tblArticles .pictureEmpty{width:15%;border-top:solid 1pt #E5E7E8;}'

      MedicInfoName = 'Cipralex® Filmtabletten/Tropfen 10 mg/ml, 20 mg/mlCipralex MELTZ® Schmelztabletten'
      YamlName      = 'fi_62184.yaml'
      
      def setup
        return if defined?(@@path)
        @@path = File.expand_path('data/html/de/fi_62184_cipralex_de.html',  File.dirname(__FILE__))     
        @@writer = FachinfoHpricot.new
        
        open(@@path) { |fh| 
          @@fachinfo = @@writer.extract(Hpricot(fh), :fi, MedicInfoName, Styles_Cipralex)
        }
        File.open(YamlName, 'w+') { |fi| fi.puts @@fachinfo.to_yaml }
      end
      
      def test_detect_format
        assert_equal(:swissmedicinfo,  detect_format(IO.read(@@path)))
      end 
      
      def test_fachinfo2
        assert_instance_of(FachinfoDocument2001, @@fachinfo)
      end 
      
      def test_name2
        assert_equal(MedicInfoName, @@fachinfo.name.to_s) # is okay as found this in html Cipralex&reg;
      end
      
      def test_span
        assert_nil(/span/.match(@@fachinfo.indications.to_s))
        assert_nil(/italic/.match(@@fachinfo.to_s))
        assert_nil(/span/.match(@@fachinfo.to_s))
      end

      def test_iksnrs
        assert_equal("Zulassungsnummer\n55961, 56366, 62184 (Swissmedic).", @@fachinfo.iksnrs.to_s)
        assert_equal(["55961", "56366", "62184"], TextInfoPlugin::get_iksnrs_from_string(@@fachinfo.iksnrs.to_s))
      end 

      def test_zusammenssetzung
        assert_equal('Zusammensetzung', @@fachinfo.composition.heading)
        assert_equal("Wirkstoff
Filmtabletten, Tropfen: Escitalopramum ut escitaloprami oxalas.
Schmelztabletten: Escitalopramum.
Hilfsstoffe
Filmtabletten: Cellulosum microcristallinum, Silica colloidalis anhydrica, Talcum, Carmellosum natricum conexum, Magnesii stearas, Hypromellose, Macrogolum 400, Color: Titanii dioxidum (E171).
Schmelztabletten: Cellulosum microcristallinum, Hypromellosum, Copolymerum methacrylatis butylati basicum, Magnesii stearas, Mannitolum, Crospovidonum, Natrii hydrogencarbonas, Acidum citricum anhydricum, Aromatica, Sucralosum.
Tropfen (10 mg/ml): Natrii hydroxidum, Aqua.
Tropfen (20 mg/ml): Acidum Citricum anhydricum, Ethanolum, Natrii hydroxidum, Aqua, Antiox.: E310.", @@fachinfo.composition.to_s)
      end
      
      
      def test_galenic_form
        assert_equal("
Galenische Form und Wirkstoffmenge pro Einheit
Filmtabletten zu 5 mg, 10 mg, 15 mg und 20 mg Escitalopram
Aussehen der Filmtabletten
5 mg: rund, weiss; Aufdruck: EK
10 mg: oval, weiss, mit Bruchrille; Aufdruck: EL
15 mg: oval, weiss; mit Bruchrille; Aufdruck: EM
20 mg: oval, weiss; mit Bruchrille; Aufdruck: EN
Schmelztabletten zu 10 mg und 20 mg Escitalopram.
Aussehen der Schmelztabletten
10 mg: rund, weiss bis cremefarben, leicht gesprenkelt; Aufdruck ELO
20 mg: rund, weiss bis cremefarben, leicht gesprenkelt; Aufdruck ENO
Tropfen mit 10 mg/ml Escitalopram, 1 ml corresp. 20 Tropfen corresp. 10 mg Escitalopram.
Tropfen mit 20 mg/ml Escitalopram, 1 ml corresp. 20 Tropfen corresp. 20 mg Escitalopram und enthält 12% vol. Alkohol.
Aussehen und Geschmack der Tropflösung
Klare, farblos bis gelbliche Lösung von bitterem Geschmack.
", @@fachinfo.galenic_form.to_s)
      end
      
    end
    class TestFachinfoHpricot_58267_Isentres_De < Test::Unit::TestCase
      
      Styles_Isentresx = 'p{margin-top:0pt;margin-right:0pt;margin-bottom:0pt;margin-left:0pt;}table{border-spacing:0pt;border-collapse:collapse;} table td{vertical-align:top;}.s2{font-family:Arial;font-size:11pt;}.s3{line-height:150%;}.s4{font-family:Arial;font-size:12pt;font-weight:bold;}.s5{font-family:Arial;font-size:9.6pt;font-weight:bold;}.s6{font-size:11pt;line-height:150%;}.s7{font-family:Arial;font-size:11pt;font-weight:bold;color:#000000;}.s8{font-family:Arial;font-size:11pt;font-style:italic;color:#000000;}.s9{font-family:Arial;font-size:11pt;color:#000000;}.s10{font-family:Arial;font-size:8.8pt;color:#000000;}.s11{font-family:Arial;font-size:11pt;font-style:normal;font-weight:bold;}.s12{line-height:150%;text-align:left;}.s13{font-size:11pt;text-indent:0pt;line-height:150%;margin-right:0.6pt;margin-left:0pt;}.s14{margin-left:0pt;padding-top:0pt;padding-right:5.4pt;padding-bottom:0pt;padding-left:5.4pt;border-top-style:none;border-right-style:none;border-bottom-style:none;border-left-style:none;}.s15{font-family:Arial;font-size:11pt;font-style:italic;}.s16{text-indent:0pt;line-height:150%;margin-right:0.6pt;margin-left:0pt;}.s17{font-family:Arial;font-size:11pt;font-style:italic;font-weight:normal;}.s18{text-indent:-42.55pt;line-height:150%;margin-right:0.6pt;margin-left:42.55pt;}.s19{font-family:Arial;font-size:11pt;font-style:normal;font-weight:normal;}.s20{font-family:Arial;font-size:11pt;font-style:italic;font-weight:normal;color:#000000;}.s21{font-family:Arial;font-size:11pt;font-style:normal;font-weight:normal;color:#000000;}.s22{margin-left:-5.4pt;padding-top:0pt;padding-right:5.4pt;padding-bottom:0pt;padding-left:5.4pt;}.s23{font-family:Symbol;font-style:normal;font-weight:normal;text-align:left;margin-left:-18pt;width:-18pt;position:absolute;}.s24{line-height:150%;margin-left:21.3pt;}.s25{height:18pt;}.s26{vertical-align:bottom;margin-left:4.75pt;padding-top:0pt;padding-right:5.4pt;padding-bottom:0pt;padding-left:5.4pt;border-top-width:0.5pt;border-top-color:#000000;border-top-style:solid;border-right-width:0.5pt;border-right-color:#000000;border-right-style:solid;border-bottom-width:0.5pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-width:0.5pt;border-left-color:#000000;border-left-style:solid;background-color:#339966;}.s27{vertical-align:bottom;margin-left:4.75pt;padding-top:0pt;padding-right:5.4pt;padding-bottom:0pt;padding-left:5.4pt;border-top-style:none;border-right-style:none;border-bottom-style:none;border-left-style:none;}.s28{height:8.5pt;}.s29{text-align:center;}.s30{vertical-align:bottom;margin-left:4.75pt;padding-top:0pt;padding-right:5.4pt;padding-bottom:0pt;padding-left:5.4pt;border-top-width:0.5pt;border-top-color:#000000;border-top-style:solid;border-right-width:0.5pt;border-right-color:#000000;border-right-style:solid;border-bottom-width:1pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-width:0.5pt;border-left-color:#000000;border-left-style:solid;}.s31{vertical-align:middle;margin-left:4.75pt;padding-top:0pt;padding-right:5.4pt;padding-bottom:0pt;padding-left:5.4pt;border-top-width:0.5pt;border-top-color:#000000;border-top-style:solid;border-right-width:0.5pt;border-right-color:#000000;border-right-style:solid;border-bottom-style:none;border-left-style:none;}.s32{vertical-align:middle;margin-left:4.75pt;padding-top:0pt;padding-right:5.4pt;padding-bottom:0pt;padding-left:5.4pt;border-top-style:none;border-right-width:0.5pt;border-right-color:#000000;border-right-style:solid;border-bottom-width:1pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-style:none;}.s33{font-family:Arial;font-size:12pt;}.s34{vertical-align:middle;margin-left:4.75pt;padding-top:0pt;padding-right:5.4pt;padding-bottom:0pt;padding-left:5.4pt;border-top-style:none;border-right-width:0.5pt;border-right-color:#000000;border-right-style:solid;border-bottom-width:0.5pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-width:0.5pt;border-left-color:#000000;border-left-style:solid;}.s35{vertical-align:middle;margin-left:4.75pt;padding-top:0pt;padding-right:5.4pt;padding-bottom:0pt;padding-left:5.4pt;border-top-style:none;border-right-width:0.5pt;border-right-color:#000000;border-right-style:solid;border-bottom-width:0.5pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-style:none;}.s36{font-family:Arial;font-size:9.6pt;}.s37{vertical-align:middle;margin-left:4.75pt;padding-top:0pt;padding-right:5.4pt;padding-bottom:0pt;padding-left:5.4pt;border-top-style:none;border-right-style:none;border-bottom-style:none;border-left-style:none;}.s38{font-size:8pt;}.s39{font-family:Arial;font-size:6.4pt;}.s40{font-family:Arial;font-size:8pt;}.s41{margin-left:-0.65pt;padding-top:0pt;padding-right:5.4pt;padding-bottom:0pt;padding-left:5.4pt;}.s42{font-size:8pt;line-height:150%;}.s43{height:17.4pt;}.s44{margin-left:0pt;padding-top:0pt;padding-right:1.5pt;padding-bottom:0pt;padding-left:1.5pt;border-top-width:0.5pt;border-top-color:#000000;border-top-style:solid;border-right-style:none;border-bottom-width:0.25pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-width:0.5pt;border-left-color:#000000;border-left-style:solid;}.s45{margin-left:0pt;padding-top:0pt;padding-right:1.5pt;padding-bottom:0pt;padding-left:1.5pt;border-top-width:0.5pt;border-top-color:#000000;border-top-style:solid;border-right-width:0.5pt;border-right-color:#000000;border-right-style:solid;border-bottom-width:0.25pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-style:none;}.s46{font-family:Arial;font-size:12pt;color:#000000;}.s47{margin-left:0pt;padding-top:0pt;padding-right:1.5pt;padding-bottom:0pt;padding-left:1.5pt;border-top-width:0.25pt;border-top-color:#000000;border-top-style:solid;border-right-style:none;border-bottom-width:0.5pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-width:0.5pt;border-left-color:#000000;border-left-style:solid;}.s48{margin-left:0pt;padding-top:0pt;padding-right:1.5pt;padding-bottom:0pt;padding-left:1.5pt;border-top-width:0.25pt;border-top-color:#000000;border-top-style:solid;border-right-width:0.5pt;border-right-color:#000000;border-right-style:solid;border-bottom-width:0.5pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-style:none;}.s49{height:22.7pt;}.s50{font-family:Arial;font-size:12pt;font-weight:bold;color:#000000;}.s51{vertical-align:middle;margin-left:0pt;padding-top:0pt;padding-right:1.5pt;padding-bottom:0pt;padding-left:1.5pt;border-top-width:0.5pt;border-top-color:#000000;border-top-style:solid;border-right-width:0.75pt;border-right-color:#000000;border-right-style:solid;border-bottom-style:none;border-left-width:0.75pt;border-left-color:#000000;border-left-style:solid;}.s52{vertical-align:middle;margin-left:0pt;padding-top:0pt;padding-right:1.5pt;padding-bottom:0pt;padding-left:1.5pt;border-top-width:0.5pt;border-top-color:#000000;border-top-style:solid;border-right-style:none;border-bottom-width:0.25pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-width:0.75pt;border-left-color:#000000;border-left-style:solid;}.s53{margin-left:0pt;padding-top:0pt;padding-right:1.5pt;padding-bottom:0pt;padding-left:1.5pt;border-top-width:0.5pt;border-top-color:#000000;border-top-style:solid;border-right-width:0.75pt;border-right-color:#000000;border-right-style:solid;border-bottom-width:0.25pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-style:none;}.s54{height:15.3pt;}.s55{margin-left:0pt;padding-top:0pt;padding-right:1.5pt;padding-bottom:0pt;padding-left:1.5pt;border-top-style:none;border-right-width:0.75pt;border-right-color:#000000;border-right-style:solid;border-bottom-width:1.5pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-width:0.75pt;border-left-color:#000000;border-left-style:solid;}.s56{vertical-align:middle;margin-left:0pt;padding-top:0pt;padding-right:1.5pt;padding-bottom:0pt;padding-left:1.5pt;border-top-width:0.25pt;border-top-color:#000000;border-top-style:solid;border-right-width:0.75pt;border-right-color:#000000;border-right-style:solid;border-bottom-width:1.5pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-width:0.75pt;border-left-color:#000000;border-left-style:solid;}.s57{vertical-align:middle;margin-left:0pt;padding-top:0pt;padding-right:1.5pt;padding-bottom:0pt;padding-left:1.5pt;border-top-width:1.5pt;border-top-color:#000000;border-top-style:solid;border-right-width:0.75pt;border-right-color:#000000;border-right-style:solid;border-bottom-width:0.75pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-width:0.75pt;border-left-color:#000000;border-left-style:solid;}.s58{vertical-align:middle;margin-left:0pt;padding-top:0pt;padding-right:1.5pt;padding-bottom:0pt;padding-left:1.5pt;border-top-width:0.75pt;border-top-color:#000000;border-top-style:solid;border-right-width:0.75pt;border-right-color:#000000;border-right-style:solid;border-bottom-width:0.75pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-width:0.75pt;border-left-color:#000000;border-left-style:solid;}.s59{margin-left:-5.4pt;padding-top:0pt;padding-right:1.5pt;padding-bottom:0pt;padding-left:1.5pt;}</style><content><![CDATA[<?xml version="1.0" encoding="utf-8"?><div xmlns="http://www.w3.org/1999/xhtml"><p class="s3"><span class="s2"><span>Fachinformation</span></span></p><p class="s3">&nbsp;</p><p class="s3" id="section1"><span class="s4"><span>Iscador</span></span><sup class="s5"><span>&reg;</span></sup><span class="s4"><span> </span></span><span class="s4"><span>Ampullen (Injektionsl&ouml;sung)</span></span></p><p class="s6">&nbsp;</p><p><span class="s2"><span>Anthroposophisches Arzneimittel</span></span></p><p class="s6">&nbsp;</p><p class="s3" id="section2"><span class="s7"><span>Zusammensetzung</span></span></p><p class="s3"><span class="s8"><span>Wirkstoff:</span></
  span><span class="s9"><span> Fermentierter w&auml;ssriger Auszug aus Viscum album von verschiedenen Wirtsb&auml;umen. Bestimmte Sorten (siehe Tabelle 1) enthalten einen Metallsalzzusatz in der Konzentration von 10</span></span><sup class="s10"><span>&ndash;8</span></sup><span class="s9"><span> g pro 100 mg Frischpflanze.</span></span></p><p class="s3"><span class="s8"><span>Hilfsstoffe:</span></span><span class="s9"><span> Aqua ad injectabilia, Natrii chloridum.</span></span></p><p class="s6">&nbsp;</p><p class="s3" id="section3"><span class="s7"><span>Galenische Form und</span></span><span class="s7"><span> Wirkstoffmenge pro Einheit</span></span></p><p class="s3"><span class="s9"><span>Ampullen &agrave; 1 ml Injektionsl&ouml;sung. Die verschiedenen Konzentrationen werden mit dem Gehalt an Frischpflanzensubstanz in mg pro ml, also pro Ampulle, bezeichnet.</span></span></p><p class="s3"><span class="s8"><span>Lektingehalt:</span></span><span class="s9"><span> Der Gesamtlektingehalt von Iscador M spezifiziert und Iscador Qu spezifiziert ist definiert und wird mittels ELISA-Test mit Mistellektin II als Standard bestimmt.</span></span></p><p class="s6">&nbsp;</p><p class="s3"><span class="s11"><span>iscador</span>&nbsp;<span>1 mg</span>&nbsp;<span>2 mg</span>&nbsp;<span>5 mg</span></span></p><p class="s3"><span class="s2"><span>M spez.</span>&nbsp;<span>50 ng/ml</span>&nbsp;<span>100 ng/ml</span>&nbsp;<span>250 ng/ml</span></span></p><p class="s12"><span class="s2"><span>Qu spez.</span>&nbsp;<span>75 ng/ml</span>&nbsp;<span>150 ng/ml</span>&nbsp;<span>375 ng/ml</span></span></p><p class="s6">&nbsp;</p><p class="s3" id="section4"><span class="s7"><span>Indikationen / Anwendungsm&ouml;glichkeiten</span></span></p><p class="s3"><span class="s9"><span>Gem&auml;ss der anthroposophischen Menschen- und Naturerkenntnis als Zusatzbehandlung bei malignen Erkrankungen zur Verbesserung der Lebensqualit&auml;t und eventuell des Krankheitsverlaufes.</span></span></p><p class="s6">&nbsp;</p><p class="s3" id="section5"><span class="s7"><span>Dosierung / Anwendung</span></span></p><p class="s3"><span class="s9"><span>Soweit nicht anders verordnet, wird Iscador wie folgt angewendet: subkutane Injektionen 2 bis 3mal pro Woche. Kein Vermischen der Injektionsl&ouml;sung mit anderen Medikamenten.</span></span></p><p class="s6">&nbsp;</p><p class="s3"><span class="s8"><span>Lokalisation:</span></span><span class="s9"><span> Weitere Umgebung des Tumors. Nicht in Tumorgewebe oder bestrahlte Hautareale injizieren.</span></span></p><p class="s6">&nbsp;</p><p class="s3"><span class="s9"><span>Die Therapie gliedert sich grunds&auml;tzlich in zwei Phasen:</span></span></p><p class="s3"><span class="s8"><span>Einleitungsdosierung:</span></span><span class="s9"><span> Immer mit Serie 0 der vorgesehenen Iscador-Sorte beginnen. Ist Iscador M spezifiziert oder Iscador Qu spezifiziert vorgesehen, vorg&auml;ngig entsprechende Sorte &laquo;nicht spezifiziert&raquo; einsetzen.</span></span></p><p class="s3"><span class="s8"><span>Fortsetzungsdosierung:</span></span><span class="s9"><span> Je nach Reaktion bei Serie 0 kann die Dosierung unter Beobachtung der weiteren Reaktionen gesteigert werden.</span></span></p><p class="s6">&nbsp;</p><p class="s3"><span class="s8"><span>Verwendung von Serienpackungen:</span></span><span class="s9"><span> In der Regel bleibende Behandlung mit Serie I (Ampullenfolge gem&auml;ss Nummerierung in der Packung). Bei fehlender Reaktion evtl. Dosissteigerung auf Serie II. Nach 14 Injektionen wird eine Pause von einer Woche eingelegt.</span></span></p><p class="s3"><span class="s9"><span>Bei gutem Verlauf k&ouml;nnen die Pausen im zweiten Behandlungsjahr auf zwei, ab dem dritten Jahr evtl. auf drei bis vier Wochen verl&auml;ngert werden.</span></span></p><p class="s6">&nbsp;</p><p class="s3"><span class="s8"><span>Iscador M spezifiziert und Iscador Qu spezifiziert:</span></span><span class="s9"><span> Anwendung wie oben bei gleichbleibender Dosierung. Keine Pausen.</span></span></p><p class="s6">&nbsp;</p><p class="s3"><span class="s8"><span>Wahl der Iscador-Sorte:</span></span><span class="s9"><span> Basierend auf jahrzehntelanger Anwendung wird bei verschiedenen Lokalisationen des Prim&auml;rtumors folgende Sorte empfohlen:</span></span></p><p class="s6">&nbsp;</p><table class="s22"><colgroup><col style="width:2.82500in;" /><col style="width:1.75000in;" /><col style="width:1.87361in;" /></colgroup><tbody><tr><td class="s14"><p class="s13">&nbsp;</p></td><td class="s14"><p class="s16"><span class="s15"><span>M&auml;nner</span></span></p></td><td class="s14"><p class="s16"><span class="s15"><span>Frauen</span></span></p></td></tr><tr><td class="s14"><p class="s16"><span class="s15"><span>Verdauungstrakt</span></span></p></td><td class="s14"><p class="s13">&nbsp;</p></td><td class="s14"><p class="s13">&nbsp;</p></td></tr><tr><td class="s14"><p class="s16"><span class="s2"><span>Zunge, M</span></span><span class="s2"><span>undh&ouml;hle, Oesophagus</span></span></p></td><td class="s14"><p class="s16"><span class="s2"><span>Qu</span></span></p></td><td class="s14"><p class="s16"><span class="s2"><span>M</span></span></p></td></tr><tr><td class="s14"><p class="s16"><span class="s2"><span>Magen, Leber, Galle, Milz</span></span></p></td><td class="s14"><p class="s16"><span class="s2"><span>Qu c. Cu</span></span></p></td><td class="s14"><p class="s16"><span class="s2"><span>M c. Cu</span></span></p></td></tr><tr><td class="s14"><p class="s16"><span class="s2"><span>Pankreas</span></span></p></td><td class="s14"><p class="s16"><span class="s2"><span>Qu c. Cu</span></span></p></td><td class="s14"><p class="s16"><span class="s2"><span>M c. Cu</span></span></p></td></tr><tr><td class="s14"><p class="s16"><span class="s2"><span>D&uuml;nndarm, Dickdarm, Rectum</span></span></p></td><td class="s14"><p class="s16"><span class="s2"><span>Qu c. Hg</span></span></p></td><td class="s14"><p class="s16"><span class="s2"><span>M c. Hg</span></span></p></td></tr><tr><td class="s14"><p class="s18"><span class="s17"><span>Urogenitaltrakt</span></span></p></td><td class="s14"><p class="s13">&nbsp;</p></td><td class="s14"><p class="s13">&nbsp;</p></td></tr><tr><td class="s14"><p class="s18"><span class="s19"><span>Niere</span></span></p></td><td class="s14"><p class="s16"><span class="s2"><span>Qu c. Cu</span></span></p></td><td class="s14"><p class="s16"><span class="s2"><span>M c. Cu </span></span></p></td></tr><tr><td class="s14"><p class="s16"><span class="s19"><span>Blase</span></span></p></td><td class="s14"><p class="s16"><span class="s2"><span> </span></span><span class="s2"><span>Qu c. Arg./evtl. A</span></span></p></td><td class="s14"><p class="s16"><span class="s2"><span>M c. Arg.</span></span></p></td></tr><tr><td class="s14"><p class="s16"><span class="s19"><span>Prostata, Testis, Penis</span></span></p></td><td class="s14"><p class="s16"><span class="s2"><span>Qu. c. Arg.</span></span></p></td><td class="s14"><p class="s13">&nbsp;</p></td></tr><tr><td class="s14"><p class="s16"><span class="s19"><span>Uterus, Ovar, Vulva, Vagina</span></span></p></td><td class="s14"><p class="s13">&nbsp;</p></td><td class="s14"><p class="s16"><span class="s2"><span>M c. Arg.</span></span></p></td></tr><tr><td class="s14"><p class="s16"><span class="s17"><span>Mamma </span></span></p></td><td class="s14"><p class="s13">&nbsp;</p></td><td class="s14"><p class="s13">&nbsp;</p></td></tr><tr><td class="s14"><p class="s16"><span class="s19"><span>vor der Menopause</span></span></p></td><td class="s14"><p class="s13">&nbsp;</p></td><td class="s14"><p class="s16"><span class="s2"><span>M c. Arg.</span></span></p></td></tr><tr><td class="s14"><p class="s16"><span class="s19"><span>um die Menopause</span></span></p></td><td class="s14"><p class="s13">&nbsp;</p></td><td class="s14"><p class="s16"><span class="s2"><span>M c. Hg</span></span></p></td></tr><tr><td class="s14"><p class="s16"><span class="s19"><span>nach der Menopause</span></span></p></td><td class="s14"><p class="s13">&nbsp;</p></td><td class="s14"><p class="s16"><span class="s2"><span>P c. Hg</span></span></p></td></tr><tr><td class="s14"><p class="s3"><span class="s20"><span>Respirationstrakt</span></span></p></td><td class="s14"><p class="s13">&nbsp;</p></td><td class="s14"><p class="s13">&nbsp;</p></td></tr><tr><td class="s14"><p class="s3"><span class="s21"><span>Nasen- Rachenraum</span></span></p></td><td class="s14"><p class="s16"><span class="s2"><span>P</span></span></p></td><td class="s14"><p class="s16"><span class="s2"><span>P</span></span></p></td></tr><tr><td class="s14"><p class="s3"><span class="s21"><span>Schilddr&uuml;se, Kehlkopf</span></span></p></td><td class="s14"><p class="s16"><span class="s2"><span>Qu</span></span></p></td><td class="s14"><p class="s16"><span class="s2"><span>M</span></span></p></td></tr><tr><td class="s14"><p class="s3"><span class="s21"><span>Bronchien, Pleura</span></span></p></td><td class="s14"><p class="s16"><span class="s2"><span>U c. Hg/evtl. Qu c. Hg</span></span></p></td><td class="s14"><p class="s16"><span class="s2"><span>U c. Hg/evtl. </span></span><span class="s2"><span>M c. Hg</span></span></p></td></tr><tr><td class="s14"><p class="s3"><span class="s20"><span>Haut</span></span></p></td><td class="s14"><p class="s16"><span class="s2"><span>P oder P c. Hg</span></span></p></td><td class="s14"><p class="s16"><span class="s2"><span>P oder P c. Hg</span></span></p></td></tr></tbody></table><p class="s6">&nbsp;</p><p class="s3"><span class="s8"><span>Verwendung von Iscador spezifiziert:</span></span><span class="s9"><span> Bei allen Lokalisationen, insbesondere wenn eine gleichbleibende Immunmodulierung erzielt werden soll. Die Verwendung ist unabh&auml;ngig vom Geschlecht.</span></span></p><p class="s6">&nbsp;</p><p class="s3" id="section6"><span class="s7"><span>Kontraindikationen</span></span></p><p class="s3"><span class="s9"><span>Bei fieberhaften, entz&uuml;ndlichen Zust&auml;nden mit Temperaturen &uuml;ber 38&deg;C sollte die Iscador-Therapie unterbrochen werden. An den ersten Mensestagen sind Iscador-Injektionen nicht angezeigt. Bei bekannter Allergie auf Mistelzubereitungen 
  darf Iscador nicht angewendet werden.</span></span></p><p class="s6">&nbsp;</p><p class="s3" id="section7"><span class="s7"><span>Warnhinweise und</span></span><span class="s7"><span> Vorsichtsmassnahmen</span></span></p><p class="s3"><span class="s9"><span>Siehe Rubrik &laquo;Unerw&uuml;nschte Wirkungen&raquo;.</span></span></p><p class="s6">&nbsp;</p><p class="s3" id="section8"><span class="s7"><span>Interaktionen</span></span></p><p class="s3"><span class="s9"><span>Es sind keine Daten zu Interaktionen mit anderen Medikamenten vorhanden. Trotz langj&auml;hriger Anwendung von Iscador sind solche bisher nicht beschrieben worden.</span></span></p><p class="s6">&nbsp;</p><p class="s3" id="section9"><span class="s7"><span>Schwangerschaft / Stillzeit</span></span></p><p class="s3"><span class="s9"><span>Es liegen keine hinreichenden tierexperimentellen Studien zur Auswirkung auf Schwangerschaft, Embryonalentwicklung, Entwicklung des F&ouml;ten und/oder die postnatale Entwicklung vor. Das potentielle Risiko f&uuml;r den Menschen ist nicht bekannt.</span></span></p><p class="s3"><span class="s9"><span>W&auml;hrend der Schwangerschaft darf das Medikament nicht verabreicht werden, es sei denn, dies ist nach strenger Indikationsstellung eindeutig erforderlich.</span></span></p><p class="s6">&nbsp;</p><p class="s3" id="section10"><span class="s7"><span>Wirkung auf die Fahrt&uuml;chtigkeit und auf das Bedienen von Maschinen</span></span></p><p class="s3"><span class="s9"><span>Nicht zutreffend.</span></span></p><p class="s6">&nbsp;</p><p class="s3" id="section11"><span class="s7"><span>Unerw&uuml;nschte Wirkungen</span></span></p><p class="s3"><span class="s9"><span>Gelegentlich auftretende lokale entz&uuml;ndliche Reaktionen um die Injektionsstelle bis zu 5 cm Durchmesser sind unbedenklich. Bei selten beobachteten allgemeinallergischen Reaktionen nach einer Iscador-Injektion ist eine sofortige antiallergische Therapie durchzuf&uuml;hren. Bei intra</span></span><span class="s9"><span>craniellen und intraspinalen Tumoren k&ouml;nnen vereinzelt durch Aktivierung peritumoraler Entz&uuml;ndungsprozesse Hirndrucksymptome (Kopfschmerzen, Sehst&ouml;rungen, Stauungspapille usw.) auftreten und ein Absetzen von Iscador sowie eine anti&ouml;demat&ouml;se Therapie erfordern.</span></span></p><p class="s6">&nbsp;</p><p class="s3" id="section12"><span class="s7"><span>&Uuml;berdosierung</span></span></p><p class="s3"><span class="s9"><span>Die Symptome entsprechen denjenigen der unerw&uuml;nschten Wirkungen (siehe oben) und k&ouml;nnen eine symptomatische Therapie notwendig machen.</span></span></p><p class="s6">&nbsp;</p><p class="s3" id="section13"><span class="s7"><span>Eigenschaften / Wirkungen</span></span></p><p class="s3"><span class="s9"><span>ATC-Code: L01CZ</span></span></p><p class="s3"><span class="s9"><span>Bei langj&auml;hriger Anwendung von Iscador konnte bei einem Teil der Patienten folgendes beobachtet werden:</span></span></p><p class="s24"><span class="s23">·</span><span class="s9"><span>Hemmung des Tumorwachstums ohne Beeintr&auml;chtigung von gesundem Gewebe;</span></span></p><p class="s24"><span class="s23">·</span><span class="s9"><span>Steigerung der Abwehr- und Ordnungskr&auml;fte (Immunmodulation);</span></span></p><p class="s24"><span class="s23">·</span><span class="s9"><span>Linderung von Tumorschmerzen;</span></span></p><p class="s24"><span class="s23">·</span><span class="s9"><span>Verbesserung von Allgemeinbefinden und Leistungsf&auml;higkeit.</span></span></p><p class="s6">&nbsp;</p><p class="s3" id="section14"><span class="s7"><span>Pharmakokinetik</span></span></p><p class="s3"><span class="s9"><span>Untersuchungen zur Pharmakokinetik und Bioverf&uuml;gbarkeit wurden nicht durchgef&uuml;hrt.</span></span></p><p class="s6">&nbsp;</p><p class="s3" id="section15"><span class="s7"><span>Pr&auml;klinische Daten</span></span></p><p class="s3"><span class="s9"><span>Nicht vorhanden.</span></span></p><p class="s6">&nbsp;</p><p class="s3" id="section16"><span class="s7"><span>Sonstige Hinweise</span></span></p><p class="s3"><span class="s8"><span>Inkompatibilit&auml;ten: &nbsp;</span></span><span class="s9"><span>Iscador darf nicht mit anderen Arzneimitteln vermischt werden.</span></span></p><p class="s3"><span class="s8"><span>Lagerungshinweis: </span></span><span class="s9"><span>Iscador im K&uuml;hlschrank: bei 2&ndash;8&nbsp;C aufbewahren (eine K&uuml;hlkette ist nicht erforderlich).</span></span></p><p class="s3"><span class="s8"><span>Haltbarkeit: </span></span><span class="s9"><span>Das Arzneimittel darf nur bis zu dem auf dem Beh&auml;lter mit &laquo;EXP&raquo; bezeichneten Datum verwendet werden.</span></span></p><p class="s3"><span class="s8"><span>Farbe: </span></span><span class="s9"><span>Die Farbe der Injektionsl&ouml;sung wird durch die Menge des verwendeten Pflanzenauszuges bestimmt. Daher k&ouml;nnen die in einer Serienpackung zusammengestellten Ampullen verschiedener Konzentrationen Farbunterschiede aufweisen.</span></span></p><p class="s6">&nbsp;</p><p class="s3" id="section17"><span class="s7"><span>Zulassungs</span></span><span class="s7"><span>nummer</span></span></p><p class="s3"><span class="s9"><span>56</span></span><span class="s9"><span>829 (Swissmedic)</span></span></p><p class="s3"><span class="s9"><span>5</span></span><span class="s9"><span>6830 (Swissmedic)</span></span></p><p class="s3"><span class="s9"><span>56831 (Swissmedic) </span></span></p><p class="s3"><span class="s9"><span>56832 (Swissmedic) </span></span></p><p class="s3"><span class="s9"><span>56833 (Swissmedic)</span></span></p><p class="s6">&nbsp;</p><p class="s3" id="section18"><span class="s7"><span>Packungen</span></span></p><p class="s24"><span class="s23">·</span><span class="s9"><span>Einzelsorten &agrave; 7 Ampullen in einer </span></span><span class="s9"><span>Konzentration (siehe Tabelle 1) (A).</span></span></p><p class="s24"><span class="s23">·</span><span class="s9"><span>Klinikpackungen &agrave; 50 Ampullen in einer Konzentration (siehe Tabelle </span></span><span class="s9"><span>1) (A)</span></span><span class="s9"><span>.</span></span></p><p class="s24"><span class="s23">·</span><span class="s9"><span>Serienpackungen mit jeweils 2 &times; 7 Ampullen in drei verschiedenen Konzentrationsfolgen als Se</span></span><span class="s9"><span>rie 0, I, II (siehe Tabelle 2) (A).</span></span></p><p class="s6">&nbsp;</p><p class="s3" id="section19"><span class="s7"><span>Zulassungsinhaberin</span></span></p><p class="s3"><span class="s7"><span>Weleda AG</span></span><span class="s9"><span>, Arlesheim, Schweiz</span></span></p><p class="s6">&nbsp;</p><p class="s3" id="section20"><span class="s7"><span>Stand der Information</span></span></p><p class="s3"><span class="s9"><span>Oktober 2010</span></span></p><p class="s6">&nbsp;</p><p class="s3"><span class="s2"><span>00332886 / Index 6</span></span></p><p class="s6">&nbsp;</p><p class="s6">&nbsp;</p><table class="s41"><colgroup><col style="width:1.25139in;" /><col style="width:1.11458in;" /><col style="width:1.10764in;" /><col style="width:0.97639in;" /><col style="width:0.84514in;" /><col style="width:0.79375in;" /><col style="width:0.68819in;" /><col style="width:0.68819in;" /><col style="width:0.68819in;" /><col style="width:0.64861in;" /><col style="width:0.64861in;" /></colgroup><tbody><tr class="s25"><td colspan="11" class="s26"><p><span class="s4"><span>Iscador Einzelsorten und Klinikpackungen</span>&nbsp;<span>Tabelle 1</span></span></p></td></tr><tr class="s25"><td class="s27"><p>&nbsp;</p></td><td class="s27"><p>&nbsp;</p></td><td class="s27"><p>&nbsp;</p></td><td class="s27"><p>&nbsp;</p></td><td class="s27"><p>&nbsp;</p></td><td class="s27"><p>&nbsp;</p></td><td class="s27"><p>&nbsp;</p></td><td class="s27"><p>&nbsp;</p></td><td class="s27"><p>&nbsp;</p></td><td class="s27"><p>&nbsp;</p></td><td class="s27"><p>&nbsp;</p></td></tr><tr class="s28"><td class="s30" rowspan="2"><p class="s29"><span class="s4"><span>Wirtsbaum</span></span></p></td><td class="s30" rowspan="2"><p class="s29"><span class="s4"><span>Sorte</span></span></p></td><td colspan="9" class="s31"><p class="s29"><span class="s4"><span>St&auml;rke</span></span></p></td></tr><tr class="s28"><td class="s32"><p class="s29"><span class="s4"><span>0,0001mg</span></span></p></td><td class="s32"><p class="s29"><span class="s4"><span>0,001mg</span></span></p></td><td class="s32"><p class="s29"><span class="s4"><span>0,01mg</span></span></p></td><td class="s32"><p class="s29"><span class="s4"><span>0,1mg</span></span></p></td><td class="s32"><p class="s29"><span class="s4"><span>1mg</span></span></p></td><td class="s32"><p class="s29"><span class="s4"><span>2mg</span></span></p></td><td class="s32"><p class="s29"><span class="s4"><span>5mg</span></span></p></td><td class="s32"><p class="s29"><span class="s4"><span>10mg</span></span></p></td><td class="s32"><p class="s29"><span class="s4"><span>20mg</span></span></p></td></tr><tr class="s25"><td class="s34" rowspan="5"><p class="s29"><span class="s33"><span>Malus</span></span></p></td><td class="s35"><p><span class="s33"><span>M</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X </span></span><span class="s33"><span> &nbsp;&nbsp;</span></span><span class="s33"><span>▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;</span></span><span class="s33"><span>▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td></tr><tr class="s25"><td class="s35"><p><span class="s33"><span>M c. Arg</span></span><sup class="s36"><span>1</span></sup></p></td><td class="s35"><p 
class="
  s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td></tr><tr class="s25"><td class="s35"><p><span class="s33"><span>M c. Cu</span></span><sup class="s36"><span>2</span></sup></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td></tr><tr class="s25"><td class="s35"><p><span class="s33"><span>M c. Hg</span></span><sup class="s36"><span>3</span></sup></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td></tr><tr class="s25"><td class="s35"><p><span class="s33"><span>M spez.</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td></tr><tr class="s25"><td class="s34" rowspan="5"><p class="s29"><span class="s33"><span>Quercus</span></span></p></td><td class="s35"><p><span class="s33"><span>Qu</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td></tr><tr class="s25"><td class="s35"><p><span class="s33"><span>Qu c. Arg</span></span><sup class="s36"><span>1</span></sup></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td></tr><tr class="s25"><td class="s35"><p><span class="s33"><span>Qu c. Cu</span></span><sup class="s36"><span>2</span></sup></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td></tr><tr class="s25"><td class="s35"><p><span class="s33"><span>Qu c. Hg</span></span><sup class="s36"><span>3</span></sup></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td></tr><tr class="s25"><td class="s35"><p><span class="s33"><span>Qu spez.</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td></tr><tr class="s25"><td class="s34" rowspan="2"><p class="s29"><span class="s33"><span>Pinus</span></span></p></td><td class="s35"><p><span class="s33"><span>P</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td></tr><tr class="s25"><td class="s35"><p><span class="s33"><span>P c. Hg</span></span><sup class="s36"><span>3</span></sup></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X &nbsp;&nbsp;▲</span></span></p></td></tr><tr class="s25"><td class="s34"><p class="s29"><span class="s33"><span>Abies</span></span></p></td><td class="s35"><p><span class="s33"><span>A</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span 
  class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td></tr><tr class="s25"><td class="s34"><p class="s29"><span class="s33"><span>Ulmus</span></span></p></td><td class="s35"><p><span class="s33"><span>U c. Hg</span></span><sup class="s36"><span>3</span></sup></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>&nbsp;</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td><td class="s35"><p class="s29"><span class="s33"><span>X</span></span></p></td></tr><tr class="s25"><td class="s37"><p>&nbsp;</p></td><td class="s37"><p>&nbsp;</p></td><td class="s37"><p>&nbsp;</p></td><td class="s37"><p>&nbsp;</p></td><td class="s37"><p>&nbsp;</p></td><td class="s37"><p>&nbsp;</p></td><td class="s37"><p>&nbsp;</p></td><td class="s37"><p>&nbsp;</p></td><td class="s37"><p>&nbsp;</p></td><td class="s37"><p>&nbsp;</p></td><td class="s37"><p>&nbsp;</p></td></tr><tr class="s25"><td class="s37"><p class="s38">&nbsp;</p></td><td colspan="2" class="s37"><p><sup class="s39"><span>1 </span></sup><span class="s40"><span>als Silbercarbonat</span></span></p></td><td class="s37"><p class="s38">&nbsp;</p></td><td class="s37"><p class="s38">&nbsp;</p></td><td colspan="4" class="s37"><p><span class="s40"><span>X </span></span><span class="s40"><span> </span></span><span class="s40"><span>als Einzelsorte erh&auml;ltlich</span></span></p></td><td class="s37"><p class="s38">&nbsp;</p></td><td class="s37"><p class="s38">&nbsp;</p></td></tr><tr class="s25"><td class="s37"><p class="s38">&nbsp;</p></td><td colspan="2" class="s37"><p><sup class="s39"><span>2</span></sup><span class="s40"><span> als Kupfercarbonat</span></span></p></td><td class="s37"><p class="s38">&nbsp;</p></td><td class="s37"><p class="s38">&nbsp;</p></td><td colspan="4" class="s37"><p><span class="s40"><span>▲ als Klinikpackung erh&auml;ltlich</span></span></p></td><td class="s37"><p class="s38">&nbsp;</p></td><td class="s37"><p class="s38">&nbsp;</p></td></tr><tr class="s25"><td class="s37"><p class="s38">&nbsp;</p></td><td colspan="2" class="s37"><p><sup class="s39"><span>3</span></sup><span class="s40"><span> als Quecksilbersulfat</span></span></p></td><td class="s37"><p class="s38">&nbsp;</p></td><td class="s37"><p class="s38">&nbsp;</p></td><td class="s37"><p class="s38">&nbsp;</p></td><td class="s37"><p class="s38">&nbsp;</p></td><td class="s37"><p class="s38">&nbsp;</p></td><td class="s37"><p class="s38">&nbsp;</p></td><td class="s37"><p class="s38">&nbsp;</p></td><td class="s37"><p class="s38">&nbsp;</p></td></tr></tbody></table><p class="s42">&nbsp;</p><p class="s3"><span class="s33"><br /></span></p><p class="s3">&nbsp;</p><table class="s59"><colgroup><col style="width:1.25972in;" /><col style="width:0.87708in;" /><col style="width:0.87639in;" /><col style="width:0.87708in;" /><col style="width:0.87639in;" /><col style="width:0.87639in;" /></colgroup><tbody><tr class="s43"><td colspan="5" class="s44"><p><span class="s4"><span>Iscador Serienpackungen </span></span></p></td><td class="s45"><p class="s29"><span class="s4"><span>Tabelle 2</span></span></p></td></tr><tr class="s43"><td colspan="5" class="s47"><p><span class="s46"><span>Alle Sorten (ausser Iscador M spezifiziert und Qu spezifiziert) erh&auml;ltlich:</span></span></p></td><td class="s48"><p class="s29">&nbsp;</p></td></tr><tr class="s49"><td class="s51"><p class="s29"><span class="s50"><span>Serie</span></span></p></td><td colspan="4" class="s52"><p class="s29"><span class="s50"><span>Konzentrationen</span></span></p></td><td class="s53"><p>&nbsp;</p></td></tr><tr class="s54"><td class="s55"><p>&nbsp;</p></td><td class="s56"><p class="s29"><span class="s50"><span>0,01mg</span></span></p></td><td class="s56"><p class="s29"><span class="s50"><span>0,1mg</span></span></p></td><td class="s56"><p class="s29"><span class="s50"><span>1mg</span></span></p></td><td class="s56"><p class="s29"><span class="s50"><span>10mg</span></span></p></td><td class="s56"><p class="s29"><span class="s50"><span>20mg</span></span></p></td></tr><tr class="s43"><td class="s57"><p class="s29"><span class="s46"><span>0</span></span></p></td><td class="s57"><p class="s29"><span class="s46"><span>2 x 2</span></span></p></td><td class="s57"><p class="s29"><span class="s46"><span>2 x 2</span></span></p></td><td class="s57"><p class="s29"><span class="s46"><span>2 x 3</span></span></p></td><td class="s57"><p class="s29">&nbsp;</p></td><td class="s57"><p class="s29">&nbsp;</p></td></tr><tr class="s43"><td class="s58"><p class="s29"><span class="s46"><span>I</span></span></p></td><td class="s58"><p class="s29">&nbsp;</p></td><td class="s58"><p class="s29"><span class="s46"><span>2 x 2</span></span></p></td><td class="s58"><p class="s29"><span class="s46"><span>2 x 2</span></span></p></td><td class="s58"><p class="s29"><span class="s46"><span>2 x 3</span></span></p></td><td class="s58"><p class="s29">&nbsp;</p></td></tr><tr class="s43"><td class="s58"><p class="s29"><span class="s46"><span>II</span></span></p></td><td class="s58"><p class="s29">&nbsp;</p></td><td class="s58"><p class="s29">&nbsp;</p></td><td class="s58"><p class="s29"><span class="s46"><span>2 x 2</span></span></p></td><td class="s58"><p class="s29"><span class="s46"><span>2 x 2</span></span></p></td><td class="s58"><p class="s29"><span class="s46"><span>2 x 3</span></span></p></td></tr></tbody></table><p class="s3">&nbsp;</p><p class="s3">&nbsp;</p><p class="s3">&nbsp;</p><p class="s42">&nbsp;</p><p class="s3">&nbsp;</p><p class="s6">&nbsp;</p></div>]]></content><sections><section id="section1"><title>Iscador® Ampullen (Injektionslösung)</title></section><section id="section2"><title>Zusammensetzung</title></section><section id="section3"><title>Galenische Form und Wirkstoffmenge pro Einheit</title></section><section id="section4"><title>Indikationen / Anwendungsmöglichkeiten</title></section><section id="section5"><title>Dosierung / Anwendung</title></section><section id="section6"><title>Kontraindikationen</title></section><section id="section7"><title>Warnhinweise und Vorsichtsmassnahmen</title></section><section id="section8"><title>Interaktionen</title></section><section id="section9"><title>Schwangerschaft / Stillzeit</title></section><section id="section10"><title>Wirkung auf die Fahrtüchtigkeit und auf das Bedienen von Maschinen</title></section><section id="section11"><title>Unerwünschte Wirkungen</title></section><section id="section12"><title>Überdosierung</title></section><section id="section13"><title>Eigenschaften / Wirkungen</title></section><section id="section14"><title>Pharmakokinetik</title></section><section id="section15"><title>Präklinische Daten</title></section><section id="section16"><title>Sonstige Hinweise</title></section><section id="section17"><title>Zulassungsnummer</title></section><section id="section18"><title>Packungen</title></section><section id="section19"><title>Zulassungsinhaberin</title></section><section id="section20"><title>Stand der Information</title></section></sections></medicalInformation><medicalInformation type="fi" version="1" lang="de" safetyRelevant="false"><title>Isentress®</title><authHolder>MSD Merck Sharp &amp;#038; Dohme AG</authHolder><atcCode>J05AX08</atcCode><substances>Raltegravir</substances><authNrs>58267</authNrs><style>.h1{font-size:22pt;font-family:Arial,Helvetica,Univers,"Zurich BT","sans-serif";font-weight:bolder;color:black;}.LabelText{font-family:Arial,"Helvetica Black","LB Helvetica Black","Univers Black",Zurich,"sans-serif";font-size:smaller;font-weight:bolder;color:Black;}.ErrorMessage{font-family:Arial,"Helvetica Black","LB Helvetica Black","Univers Black",Zurich,"sans-serif";font-size:small;color:Red;}.ErrorMessageSmall{font-family:Arial,"Helvetica Black","LB Helvetica Black","Univers Black",Zurich,"sans-serif";font-size:smaller;color:Red;}.ListText{font-family:"Arial Black","Helvetica Black","LB Helvetica Black","Univers Black","Zurich Blk BT","sans-serif";font-size:smaller;}.EmptyGridText{font-family:Arial,Helvetica,Univers,"Zurich BT","sans-serif";color:Red;}.CompanyDetail{font-family:Arial,Helvetica,Univers,"Zurich BT","sans-serif";font-size:smaller;}.ContentTitle{font-family:"Arial Black","Helvetica Black","LB Helvetica Black","Univers Black","Zurich Blk BT","sans-serif";color:#003366;}.CopyrightText{font-family:"Arial Black","Helvetica Black","LB Helvetica Black","Univers Black","Zurich Blk BT","sans-serif";font-size:smaller;color:#003366;}.BekanntmachungenText{font-family:Arial,"Helvetica Black","LB Helvetica Black","Univers Black",Zurich,"sans-serif";font-size:smaller;color:Black;}.BekanntmachungenTitel{font-family:Arial,"Helvetica Black","LB Helvetica Black","Univers Black",Zurich,"sans-serif";font-size:smaller;font-weight:bolder;color:Black;}.CookieWarning{font-family:Arial,"Helvetica Black","LB Helvetica Black","Univers Black",Zurich,"sans-serif";font-size:medium;font-weight:bolder;color:Red;}.HelpText{font-size:12pt;font-family:Arial,Helvetica,Univers,"Zurich BT","sans-serif";color:black;}.HelpTextBold{font-size:11pt;font-family:Arial,Helvetica,Univers,"Zurich BT","sans-serif";color:black;font-weight:bold;}.HelpTextSmall{font-size:11pt;font-family:Arial,Helvetica,Univers,"Zurich BT","sans-serif";color:black;}.HelpTextSmallBold{font-size:11pt;font-family:Arial,Helvetica,Univers,"Zurich BT","sans-serif";
  color:black;font-weight:bold;}.Zwischentitel{font-size:12pt;font-family:Arial,Helvetica,Univers,"Zurich BT","sans-serif";font-weight:bolder;color:black;}.AdobeAcrobatReaderText{font-family:Arial,Helvetica,Univers,"Zurich BT","sans-serif";font-size:x-small;}.Hyperlinks{font-family:Arial,"Helvetica Black","LB Helvetica Black","Univers Black",Zurich,"sans-serif";font-size:smaller;color:Blue;}#menue{z-index:1;position:fixed;left:0px;top:0px;}#monographie{margin-left:30px;margin-right:30px;margin-bottom:10px;font-family:"Verdana","Arial","Tahoma","Helvetica","Geneva","sans-serif";color:black;}#monographie .MonTitle{font-size:1.5em;font-weight:bold;margin-bottom:0.2em;}#monographie .absTitle{font-size:0.9em;font-weight:bold;font-style:italic;margin-bottom:0.0em;}#monographie .untertitel{font-size:0.9em;font-weight:normal;margin-top:0.5em;margin-bottom:0.0em;}#monographie .untertitel1{font-size:0.9em;font-weight:normal;font-style:italic;margin-top:0.2em;margin-bottom:0.0em;}#monographie .header{font-size:0.85em;font-weight:normal;color:#999999;text-align:left;margin-bottom:2em;visibility:hidden;display:none;}#monographie .footer{font-size:0.85em;font-weight:normal;color:#999999;margin-top:2.0em;border-top:#999999 1px solid;padding-top:0.5em;}#monographie div p{font-size:0.9em;}#monographie .paragraph{font-weight:normal;font-style:normal;margin-top:0.8em;}.noSpacing{margin-top:0em;margin-bottom:0em;}.spacing1{margin-top:0em;margin-bottom:0.25em;}.spacing2{margin-top:0em;margin-bottom:0.5em;}#monographie .ownerCompany{font-size:1em;font-style:italic;font-weight:bold;text-align:right;margin-bottom:1.0em;border-top:black 1px solid;border-bottom:black 1px solid;padding-top:0.2em;padding-bottom:0.2em;}#monographie .titleAdd{font-size:0.9em;font-weight:bold;font-style:italic;}#monographie .shortCharacteristic{font-size:1.1em;font-style:italic;}#monographie .indention1{margin-left:5em;}#monographie .indention2{margin-left:10em;}#monographie .indention3{margin-left:15em;}#monographie .box{font-size:.9em;font-weight:normal;font-style:normal;margin-top:5px;margin-bottom:5px;padding-top:5px;padding-bottom:6px;padding-left:5px;padding-right:5px;border-width:1px;border-color:Black;border-style:solid;}#monographie .image{margin-top:20px;margin-bottom:20px;}#monographie table{font-family:"Courier New","sans-serif";font-size:1.0em;margin-top:1.0em;margin-bottom:1.0em;border-top:solid 1px black;border-bottom:solid 1px black;}#monographie td{font-family:"Courier New","sans-serif";font-size:1.0em;}.rowSepBelow{border-bottom:solid 1px black;}.goUp{float:right;margin-right:-40px;}.tblArticles{border:solid 1pt #E5E7E8;vertical-align:top;text-align:left;border-spacing:0;width:100%;}.tblArticles .product{width:37%;font-size:small;vertical-align:top;border-top:solid 1pt #E5E7E8;border-right:solid 1pt #E5E7E8;}.tblArticles .productEmpty{width:37%;}.tblArticles .normal-right{border-right:solid 1pt #E5E7E8;border-top:solid 1pt #E5E7E8;width:15%;text-align:right;vertical-align:top;font-size:small;}.tblArticles .normal-center{border-right:solid 1pt #E5E7E8;border-top:solid 1pt #E5E7E8;width:10%;text-align:center;vertical-align:top;font-size:small;}.tblArticles .picture{width:15%;text-align:center;border-top:solid 1pt #E5E7E8;}.tblArticles .pictureEmpty{width:15%;border-top:solid 1pt #E5E7E8;}'

  Styles_Isentres = 'p{margin-top:0pt;margin-right:0pt;margin-bottom:0pt;margin-left:0pt;}table{border-spacing:0pt;border-collapse:collapse;} table td{vertical-align:top;}.s2{font-family:Arial;font-size:11pt;}.s3{line-height:150%;}.s4{font-family:Arial;font-size:12pt;font-weight:bold;}.s5{font-family:Arial;font-size:9.6pt;font-weight:bold;}.s6{font-size:11pt;line-height:150%;}.s7{font-family:Arial;font-size:11pt;font-weight:bold;color:#000000;}.s8{font-family:Arial;font-size:11pt;font-style:italic;color:#000000;}.s9{font-family:Arial;font-size:11pt;color:#000000;}.s10{font-family:Arial;font-size:8.8pt;color:#000000;}.s11{font-family:Arial;font-size:11pt;font-style:normal;font-weight:bold;}.s12{line-height:150%;text-align:left;}.s13{font-size:11pt;text-indent:0pt;line-height:150%;margin-right:0.6pt;margin-left:0pt;}.s14{margin-left:0pt;padding-top:0pt;padding-right:5.4pt;padding-bottom:0pt;padding-left:5.4pt;border-top-style:none;border-right-style:none;border-bottom-style:none;border-left-style:none;}.s15{font-family:Arial;font-size:11pt;font-style:italic;}.s16{text-indent:0pt;line-height:150%;margin-right:0.6pt;margin-left:0pt;}.s17{font-family:Arial;font-size:11pt;font-style:italic;font-weight:normal;}.s18{text-indent:-42.55pt;line-height:150%;margin-right:0.6pt;margin-left:42.55pt;}.s19{font-family:Arial;font-size:11pt;font-style:normal;font-weight:normal;}.s20{font-family:Arial;font-size:11pt;font-style:italic;font-weight:normal;color:#000000;}.s21{font-family:Arial;font-size:11pt;font-style:normal;font-weight:normal;color:#000000;}.s22{margin-left:-5.4pt;padding-top:0pt;padding-right:5.4pt;padding-bottom:0pt;padding-left:5.4pt;}.s23{font-family:Symbol;font-style:normal;font-weight:normal;text-align:left;margin-left:-18pt;width:-18pt;position:absolute;}.s24{line-height:150%;margin-left:21.3pt;}.s25{height:18pt;}.s26{vertical-align:bottom;margin-left:4.75pt;padding-top:0pt;padding-right:5.4pt;padding-bottom:0pt;padding-left:5.4pt;border-top-width:0.5pt;border-top-color:#000000;border-top-style:solid;border-right-width:0.5pt;border-right-color:#000000;border-right-style:solid;border-bottom-width:0.5pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-width:0.5pt;border-left-color:#000000;border-left-style:solid;background-color:#339966;}.s27{vertical-align:bottom;margin-left:4.75pt;padding-top:0pt;padding-right:5.4pt;padding-bottom:0pt;padding-left:5.4pt;border-top-style:none;border-right-style:none;border-bottom-style:none;border-left-style:none;}.s28{height:8.5pt;}.s29{text-align:center;}.s30{vertical-align:bottom;margin-left:4.75pt;padding-top:0pt;padding-right:5.4pt;padding-bottom:0pt;padding-left:5.4pt;border-top-width:0.5pt;border-top-color:#000000;border-top-style:solid;border-right-width:0.5pt;border-right-color:#000000;border-right-style:solid;border-bottom-width:1pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-width:0.5pt;border-left-color:#000000;border-left-style:solid;}.s31{vertical-align:middle;margin-left:4.75pt;padding-top:0pt;padding-right:5.4pt;padding-bottom:0pt;padding-left:5.4pt;border-top-width:0.5pt;border-top-color:#000000;border-top-style:solid;border-right-width:0.5pt;border-right-color:#000000;border-right-style:solid;border-bottom-style:none;border-left-style:none;}.s32{vertical-align:middle;margin-left:4.75pt;padding-top:0pt;padding-right:5.4pt;padding-bottom:0pt;padding-left:5.4pt;border-top-style:none;border-right-width:0.5pt;border-right-color:#000000;border-right-style:solid;border-bottom-width:1pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-style:none;}.s33{font-family:Arial;font-size:12pt;}.s34{vertical-align:middle;margin-left:4.75pt;padding-top:0pt;padding-right:5.4pt;padding-bottom:0pt;padding-left:5.4pt;border-top-style:none;border-right-width:0.5pt;border-right-color:#000000;border-right-style:solid;border-bottom-width:0.5pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-width:0.5pt;border-left-color:#000000;border-left-style:solid;}.s35{vertical-align:middle;margin-left:4.75pt;padding-top:0pt;padding-right:5.4pt;padding-bottom:0pt;padding-left:5.4pt;border-top-style:none;border-right-width:0.5pt;border-right-color:#000000;border-right-style:solid;border-bottom-width:0.5pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-style:none;}.s36{font-family:Arial;font-size:9.6pt;}.s37{vertical-align:middle;margin-left:4.75pt;padding-top:0pt;padding-right:5.4pt;padding-bottom:0pt;padding-left:5.4pt;border-top-style:none;border-right-style:none;border-bottom-style:none;border-left-style:none;}.s38{font-size:8pt;}.s39{font-family:Arial;font-size:6.4pt;}.s40{font-family:Arial;font-size:8pt;}.s41{margin-left:-0.65pt;padding-top:0pt;padding-right:5.4pt;padding-bottom:0pt;padding-left:5.4pt;}.s42{font-size:8pt;line-height:150%;}.s43{height:17.4pt;}.s44{margin-left:0pt;padding-top:0pt;padding-right:1.5pt;padding-bottom:0pt;padding-left:1.5pt;border-top-width:0.5pt;border-top-color:#000000;border-top-style:solid;border-right-style:none;border-bottom-width:0.25pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-width:0.5pt;border-left-color:#000000;border-left-style:solid;}.s45{margin-left:0pt;padding-top:0pt;padding-right:1.5pt;padding-bottom:0pt;padding-left:1.5pt;border-top-width:0.5pt;border-top-color:#000000;border-top-style:solid;border-right-width:0.5pt;border-right-color:#000000;border-right-style:solid;border-bottom-width:0.25pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-style:none;}.s46{font-family:Arial;font-size:12pt;color:#000000;}.s47{margin-left:0pt;padding-top:0pt;padding-right:1.5pt;padding-bottom:0pt;padding-left:1.5pt;border-top-width:0.25pt;border-top-color:#000000;border-top-style:solid;border-right-style:none;border-bottom-width:0.5pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-width:0.5pt;border-left-color:#000000;border-left-style:solid;}.s48{margin-left:0pt;padding-top:0pt;padding-right:1.5pt;padding-bottom:0pt;padding-left:1.5pt;border-top-width:0.25pt;border-top-color:#000000;border-top-style:solid;border-right-width:0.5pt;border-right-color:#000000;border-right-style:solid;border-bottom-width:0.5pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-style:none;}.s49{height:22.7pt;}.s50{font-family:Arial;font-size:12pt;font-weight:bold;color:#000000;}.s51{vertical-align:middle;margin-left:0pt;padding-top:0pt;padding-right:1.5pt;padding-bottom:0pt;padding-left:1.5pt;border-top-width:0.5pt;border-top-color:#000000;border-top-style:solid;border-right-width:0.75pt;border-right-color:#000000;border-right-style:solid;border-bottom-style:none;border-left-width:0.75pt;border-left-color:#000000;border-left-style:solid;}.s52{vertical-align:middle;margin-left:0pt;padding-top:0pt;padding-right:1.5pt;padding-bottom:0pt;padding-left:1.5pt;border-top-width:0.5pt;border-top-color:#000000;border-top-style:solid;border-right-style:none;border-bottom-width:0.25pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-width:0.75pt;border-left-color:#000000;border-left-style:solid;}.s53{margin-left:0pt;padding-top:0pt;padding-right:1.5pt;padding-bottom:0pt;padding-left:1.5pt;border-top-width:0.5pt;border-top-color:#000000;border-top-style:solid;border-right-width:0.75pt;border-right-color:#000000;border-right-style:solid;border-bottom-width:0.25pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-style:none;}.s54{height:15.3pt;}.s55{margin-left:0pt;padding-top:0pt;padding-right:1.5pt;padding-bottom:0pt;padding-left:1.5pt;border-top-style:none;border-right-width:0.75pt;border-right-color:#000000;border-right-style:solid;border-bottom-width:1.5pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-width:0.75pt;border-left-color:#000000;border-left-style:solid;}.s56{vertical-align:middle;margin-left:0pt;padding-top:0pt;padding-right:1.5pt;padding-bottom:0pt;padding-left:1.5pt;border-top-width:0.25pt;border-top-color:#000000;border-top-style:solid;border-right-width:0.75pt;border-right-color:#000000;border-right-style:solid;border-bottom-width:1.5pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-width:0.75pt;border-left-color:#000000;border-left-style:solid;}.s57{vertical-align:middle;margin-left:0pt;padding-top:0pt;padding-right:1.5pt;padding-bottom:0pt;padding-left:1.5pt;border-top-width:1.5pt;border-top-color:#000000;border-top-style:solid;border-right-width:0.75pt;border-right-color:#000000;border-right-style:solid;border-bottom-width:0.75pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-width:0.75pt;border-left-color:#000000;border-left-style:solid;}.s58{vertical-align:middle;margin-left:0pt;padding-top:0pt;padding-right:1.5pt;padding-bottom:0pt;padding-left:1.5pt;border-top-width:0.75pt;border-top-color:#000000;border-top-style:solid;border-right-width:0.75pt;border-right-color:#000000;border-right-style:solid;border-bottom-width:0.75pt;border-bottom-color:#000000;border-bottom-style:solid;border-left-width:0.75pt;border-left-color:#000000;border-left-style:solid;}.s59{margin-left:-5.4pt;padding-top:0pt;padding-right:1.5pt;padding-bottom:0pt;padding-left:1.5pt;}'
  MedicInfoName = 'Isentres® Filmtabletten/Tropfen 10 mg/ml, 20 mg/mlIsentres MELTZ® Schmelztabletten'
      YamlName      = 'fi_58267_isentres_de.yaml'
      
      def setup
        return if defined?(@@path)
        @@path = File.expand_path('data/html/de/fi_58267_isentres_de.html',  File.dirname(__FILE__))     
        @@writer = FachinfoHpricot.new
        
        open(@@path) { |fh| 
          @@fachinfo = @@writer.extract(Hpricot(fh), :fi, MedicInfoName, Styles_Isentres)
        }
      end
      
      def test_fachinfo2
        assert_instance_of(FachinfoDocument2001, @@fachinfo)
      end
      
      def test_name2
        assert_equal(MedicInfoName, @@fachinfo.name.to_s) # is okay as found this in html Isentres&reg;
      end
      
      def test_interactions
        assert_equal('Interaktionen', @@fachinfo.interactions.heading)
        assert(@@fachinfo.interactions.to_s.index('(1,10, 1,93)'), 'format of number in table (Isentress: Omeprazole, Einzeldosis) should be 1,10, 1,93)')
      end
      
      def test_galenic_form
        assert_equal('Galenische Form und Wirkstoffmenge pro Einheit', @@fachinfo.galenic_form.heading)
        assert_equal(
"Galenische Form und Wirkstoffmenge pro Einheit
Eine Filmtablette enthält 400 mg Raltegravir als Raltegravir-Kalium.
Eine Kautablette enthält 100 mg (mit Bruchrille) oder 25 mg Raltegravir als Raltegravir-Kalium.",  
                     @@fachinfo.galenic_form.to_s)
      end
      def test_composition_isentres
        assert_equal('Zusammensetzung', @@fachinfo.composition.heading)

        assert_equal("Zusammensetzung
Wirkstoff: Raltegravir
Hilfsstoffe:
Filmtablette:
Kern:   mikrokristalline Cellulose, Lactose-Monohydrat, wasserfreies Calciumhydrogenphosphat, Hypromellose 2208, Poloxamer 407 (enthält 0,01% butyliertes Hydroxytoluol als Antioxidationsmittel, E 321),   Natriumstearylfumarat, Magnesiumstearat.
Filmüberzug:  Polyvinylalkohol, Titandioxid, Polyethylenglykol 3350,
Talkum, rotes  Eisenoxid und schwarzes Eisenoxid.
Kautablette: Hydroxypropylcellulose, Sucralose, Saccharin-Natrium, Natriumzitratdihydrat, Mannitol, rotes Eisenoxid (nur bei 100 mg Dosierung), gelbes Eisenoxid, Monoammoniumglycyrrhizinat, Sorbitol, Fructose, natürliche und künstliche Aromen (Orange, Banane, und Maskierung, die Aspartam enthält), Crospovidon, Magnesiumstearat, Natriumstearylfumarat, Ethylcellulose 20 cP, Ammoniumhydroxid, mittelkettige Triglyceride, Ölsäure, Hypromellose 2910/6 cP, Macrogol/PEG 400.", 
                     @@fachinfo.composition.to_s)
      end                                                                                                                                                                                                                                                    
      def test_iksnrs
        assert_equal(["58267", "62946"], TextInfoPlugin::get_iksnrs_from_string(@@fachinfo.iksnrs.to_s))
        assert_equal("Zulassungsnummer\n58267, 62946 (Swissmedic)", @@fachinfo.iksnrs.to_s)
     end 
    end
  end 
end
