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
  
end

class TestFachinfoHpricotAlcaCDe < Test::Unit::TestCase
  MedicalName = 'Alca-C®'
  def setup
    @path = File.expand_path('data/html/de/alcac.fi.html', 
      File.dirname(__FILE__))
    @writer = FachinfoHpricot.new
    open(@path) { |fh| 
      @fachinfo = @writer.extract(Hpricot(fh), :fi, MedicalName)
    }
  end
  def test_fachinfo1
    assert_instance_of(FachinfoDocument, @fachinfo)
  end
  def test_name1
    assert_equal(MedicalName, @fachinfo.name.to_s)
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
    expected =  /1 Brausetablette enth.*lt: Carbasalatum calcicum 528.*mg corresp. Acidum Acetylsalicylicum 415.*mg, Acidum ascorbicum 250.*mg./
    assert_match(expected, paragraph.text)
    paragraph = section.paragraphs.at(2)

    expected =  /Hilfsstoffe: Saccharinum, Cyclamas, Aromatica, Color.: E.*120\./
    assert_match(expected, paragraph.text)
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

  Zyloric_Reg = 'Zyloric®'
  
  # Zyloric had a problem that the content of the fachinfo was mostly in italic
  class TestFachinfoHpricotZyloricDe < Test::Unit::TestCase
    
    def setup
      @path = File.expand_path('data/html/de/fi_Zyloric.de.html',  File.dirname(__FILE__))
      @writer = FachinfoHpricot.new
      open(@path) { |fh| 
        @writer.format =  :swissmedicinfo
        @fachinfo = @writer.extract(Hpricot(fh), :fi, Zyloric_Reg)
      }
    end
    
    def test_fachinfo2
      assert_instance_of(FachinfoDocument2001, @fachinfo)
    end 
    
    def test_name
      # fails as we find in the html 
      # <span class="s2"><span>Zyloric</span></span><sup class="s3"><span class="s4">&acirc;</span>/sup>
      assert_equal(Zyloric_Reg, @fachinfo.name.to_s)
      assert_equal("", @writer.title.to_s)
    end
    
    def test_content
      assert_nil(/span/.match(@fachinfo.indications.to_s))
      assert_nil(/italic/.match(@fachinfo.to_s))
      assert_nil(/span/.match(@fachinfo.to_s))
      assert_equal("Zulassungsnummer\n32917(Swissmedic)\n ", @fachinfo.iksnrs.to_s)
      assert_equal(["32917"], TextInfoPlugin::get_iksnrs_from_string(@fachinfo.iksnrs.to_s))
    end
    
    def test_galenic_form
      assert_equal("Galenische Form und Wirkstoffmenge pro Einheit\nTabletten zu 100 mg und 300 mg.\n ", @fachinfo.galenic_form.to_s)
    end   
    
   end
  
  # Zyloric had a problem that the content of the fachinfo was mostly in italic
  class TestFachinfoHpricotZyloricFr < Test::Unit::TestCase
    MedicalName = Zyloric_Reg
    def setup
      @path = File.expand_path('data/html/fr/fi_Zyloric.fr.html',  File.dirname(__FILE__))
      @writer = FachinfoHpricot.new
      open(@path) { |fh| 
        @writer.format =  :swissmedicinfo
        @fachinfo = @writer.extract(Hpricot(fh), :fi, MedicalName)
      }
    end
    
    def test_fachinfo2
      assert_instance_of(FachinfoDocument2001, @fachinfo)
    end 
    
    def test_name2
      assert_equal(Zyloric_Reg, @fachinfo.name.to_s) # is okay as found this in html Zyloric&reg;
    end
    
    def test_span
      assert_nil(/span/.match(@fachinfo.indications.to_s))
      assert_nil(/italic/.match(@fachinfo.to_s))
      assert_nil(/span/.match(@fachinfo.to_s))
    end

    def test_iksnrs
      assert_equal("Numéro d’autorisation\n32917 (Swissmedic).\n ", @fachinfo.iksnrs.to_s)
      assert_equal(["32917"], TextInfoPlugin::get_iksnrs_from_string(@fachinfo.iksnrs.to_s))
    end
    
    def test_galenic_form
      assert_equal("Forme galénique et quantité de principe actif par unité\nComprimés à 100 et 300 mg.\n ", @fachinfo.galenic_form.to_s)
    end
    
    def test_italic_absent
      File.open("fi_Zyloric.yaml", 'w+') { |fi| fi.puts @fachinfo.to_yaml }
      assert_nil(/- :italic/.match(@fachinfo.to_yaml))
    end
    
   end

  Styles_Streuli = 'p{margin-top:0pt;margin-right:0pt;margin-bottom:0pt;margin-left:0pt;}table{border-spacing:0pt;border-collapse:collapse;} table td{vertical-align:top;}.s2{font-family:Arial;font-size:14pt;font-weight:bold;}.s3{font-family:Arial;font-size:11.2pt;font-weight:bold;}.s4{line-height:150%;margin-right:113.3pt;}.s5{font-size:11pt;line-height:150%;margin-right:113.3pt;}.s6{font-family:Arial;font-size:11pt;font-weight:bold;}.s7{font-family:Arial;font-size:11pt;font-style:italic;}.s8{font-family:Arial;font-size:11pt;}.s9{font-family:Arial;font-size:8.8pt;}.s10{font-family:Arial;font-size:11pt;font-style:italic;text-decoration:line-through;}.s11{line-height:150%;margin-right:113.4pt;}.s12{font-size:11pt;line-height:150%;margin-right:113.4pt;}.s13{font-family:Arial;font-size:11pt;color:#000000;}.s14{font-family:Arial;font-size:9.5pt;}.s15{font-family:Arial;font-size:11pt;line-height:150%;margin-right:56.7pt;}.s16{line-height:150%;margin-right:56.7pt;}.s17{font-family:Times New Roman;font-size:8.8pt;}.
s18{font-
family:Arial;font-size:11pt;line-height:150%;margin-right:113.4pt;}'
  #  problem that the content of the fachinfo was mostly in italic
  class TestFachinfoHpricot58106De < Test::Unit::TestCase
    
    MedicInfoName = 'Finasterid Streuli® 5'

    def setup
      @path = File.expand_path('data/html/de/fi_58106.de.html',  File.dirname(__FILE__))      
      @writer = FachinfoHpricot.new
      @writer.format =  :swissmedicinfo
      open(@path) { |fh| 
        @fachinfo = @writer.extract(Hpricot(fh), :fi, MedicInfoName, Styles_Streuli)
      }
    end
    
    def test_fachinfo2
      assert_instance_of(FachinfoDocument2001, @fachinfo)
    end 
    
    def test_name2
      assert_equal(MedicInfoName, @fachinfo.name.to_s) # is okay as found this in html Streuli&reg;
    end
    
    def test_span
      assert_nil(/span/.match(@fachinfo.indications.to_s))
      assert_nil(/italic/.match(@fachinfo.to_s))
      assert_nil(/span/.match(@fachinfo.to_s))
    end

    def test_iksnrs
      assert_equal("Zulassungsnummer\n58’106(Swissmedic)\n ", @fachinfo.iksnrs.to_s)
      assert_equal(["58106"], TextInfoPlugin::get_iksnrs_from_string(@fachinfo.iksnrs.to_s))
    end
    
    def test_galenic_form
      assert_equal("Galenische Form und Wirkstoffmenge pro Einheit\nFilmtabletten zu 5 mg Finasterid.\n ", @fachinfo.galenic_form.to_s)
    end
    
    def test_italic_absent
      File.open("fi_58106.yaml", 'w+') { |fi| fi.puts @fachinfo.to_yaml }
      # puts "#{__LINE__}: found #{@fachinfo.to_yaml.scan(/- :italic/).size} occurrences of italic in yaml"
      occurrences = @fachinfo.to_yaml.scan(/- :italic/).size
      assert(occurrences <= 70, "Find more than 70 occurrences in yaml")
    end
    
  end

 #  problem that the content of the fachinfo was mostly in italic
  StylesXalos = 'p{margin-top:0pt;margin-right:0pt;margin-bottom:0pt;margin-left:0pt;}table{border-spacing:0pt;border-collapse:collapse;} table td{vertical-align:top;}.s2{font-family:Arial;font-size:14pt;font-weight:bold;}.s3{font-family:Arial;font-size:11.2pt;font-weight:bold;}.s4{line-height:150%;}.s5{font-family:Arial;font-size:11pt;line-height:150%;}.s6{font-family:Arial;font-size:11pt;font-style:italic;font-weight:bold;}.s7{font-family:Arial;font-size:11pt;font-style:italic;}.s8{font-family:Arial;font-size:11pt;}.s9{font-family:Arial;font-size:11pt;font-weight:normal;}.s10{line-height:150%;margin-top:6pt;}.s11{font-family:Arial;font-size:11pt;font-style:italic;font-weight:normal;}.s12{font-family:Arial;font-size:8.8pt;}.s13{font-family:Arial;font-size:8.8pt;font-weight:normal;}.s14{font-family:Arial;font-size:11pt;font-weight:bold;}'
  class TestFachinfoHpricot62439De < Test::Unit::TestCase
    MedicInfoName = 'Xalos®-Duo'
    def setup
      @path = File.expand_path('data/html/de/fi_62439.de.html',  File.dirname(__FILE__))     
      @writer = FachinfoHpricot.new
      open(@path) { |fh| 
        @writer.format =  :swissmedicinfo
        @fachinfo = @writer.extract(Hpricot(fh), :fi, MedicInfoName, StylesXalos)
      }
#      open(@path) { |fh| @fachinfo = @writer.extract(Hpricot(fh)) }
    end
    
    def test_fachinfo2
      assert_instance_of(FachinfoDocument2001, @fachinfo)
    end 
    
    def test_name2
      assert_equal(MedicInfoName, @fachinfo.name.to_s)
    end
    
    def test_span
      assert_nil(/span/.match(@fachinfo.indications.to_s))
      assert_nil(/italic/.match(@fachinfo.to_s))
      assert_nil(/span/.match(@fachinfo.to_s))
    end

    def test_iksnrs
      assert_equal("Zulassungsnummer\n62& rsquo;439(Swissmedic).\n ", @fachinfo.iksnrs.to_s)
      assert_equal(["62439"], TextInfoPlugin::get_iksnrs_from_string(@fachinfo.iksnrs.to_s))
    end
    
    def test_galenic_form
      assert_equal("Galenische Form und Wirkstoffmenge pro Einheit\nAugentropfen zu 50 µg Latanoprostum und 5,0 mg Timololum (entspricht 6,83 mg Timololi maleas) pro 1 ml. Ein Tropfen enthält etwa 1,5 µg Latanoprostum und 150 µg Timololum.\n ",
                   @fachinfo.galenic_form.to_s)
    end
    
    def test_italic_absent
      # File.open("fi_62439.yaml", 'w+') { |fi| fi.puts @fachinfo.to_yaml }
      # puts "#{__LINE__}: found #{@fachinfo.to_yaml.scan(/- :italic/).size} occurrences of italic in yaml"
      occurrences = @fachinfo.to_yaml.scan(/- :italic/).size
      assert(occurrences == 72, "Find exactly 72 occurrences of italic in yaml")
    end
    
  end
  
 #  problem that the content of the fachinfo was mostly in italic
  StylesBisoprolol = 'p{margin-top:0pt;margin-right:0pt;margin-bottom:0pt;margin-left:0pt;}table{border-spacing:0pt;border-collapse:collapse;} table td{vertical-align:top;}.s2{font-family:Arial;font-size:12pt;font-weight:bold;}.s3{line-height:150%;margin-top:24pt;}.s4{line-height:150%;}.s5{font-family:Arial;font-size:11pt;font-weight:bold;}.s6{line-height:150%;margin-top:10pt;}.s7{font-family:Arial;font-size:11pt;font-style:italic;}.s8{font-family:Arial;font-size:11pt;}.s9{font-family:Arial;font-size:11pt;font-style:italic;font-weight:normal;}.s10{line-height:150%;margin-top:6pt;}.s11{font-family:Arial;font-size:8.8pt;}.s12{font-family:Arial;font-size:11pt;font-style:italic;color:#000000;}.s13{font-family:Arial;font-size:11pt;font-weight:normal;}.s14{font-family:Arial;font-size:8.8pt;font-weight:normal;}.s15{font-family:Arial;font-size:11pt;font-style:normal;}'
  class TestFachinfoHpricot62111De < Test::Unit::TestCase
    Styles = ''
    MedicInfoName = 'Bisoprolol Axapharm'
    def setup
      @path = File.expand_path('data/html/de/fi_62111.de.html',  File.dirname(__FILE__))     
      @writer = FachinfoHpricot.new
      open(@path) { |fh| 
        @writer.format =  :swissmedicinfo
        @fachinfo = @writer.extract(Hpricot(fh), :fi, MedicInfoName, StylesBisoprolol)
      }
#      open(@path) { |fh| @fachinfo = @writer.extract(Hpricot(fh)) }
    end
    
    def test_fachinfo2
      assert_instance_of(FachinfoDocument2001, @fachinfo)
    end 
    
    def test_name2
      assert_equal(MedicInfoName, @fachinfo.name.to_s)
    end
    
    def test_span
      assert_nil(/span/.match(@fachinfo.indications.to_s))
      assert_nil(/italic/.match(@fachinfo.to_s))
      assert_nil(/span/.match(@fachinfo.to_s))
    end

    def test_iksnrs
      assert_equal("Zulassungsnummer\n62111 (Swissmedic).", @fachinfo.iksnrs.to_s)
      assert_equal(["62111"], TextInfoPlugin::get_iksnrs_from_string(@fachinfo.iksnrs.to_s))
    end
    
    def test_galenic_form
      assert_equal("Galenische Form und Wirkstoffmenge pro Einheit\nRunde, teilbare Filmtablette zu 2.5 mg, 5 mg und 10 mg.",
                   @fachinfo.galenic_form.to_s)
    end
    
    
    def test_italic_absent
      File.open("fi_62111.yaml", 'w+') { |fi| fi.puts @fachinfo.to_yaml }
      # puts "#{__LINE__}: found #{@fachinfo.to_yaml.scan(/- :italic/).size} occurrences of italic in yaml"
      occurrences = @fachinfo.to_yaml.scan(/- :italic/).size
      assert(occurrences == 79, "Find exactly 79 occurrences of italic in yaml")
    end
    
  end
  #  problem that the content of the fachinfo was mostly in italic
  StylesBisoprolol = 'p{margin-top:0pt;margin-right:0pt;margin-bottom:0pt;margin-left:0pt;}table{border-spacing:0pt;border-collapse:collapse;} table td{vertical-align:top;}.s2{font-family:Arial;font-size:12pt;font-weight:bold;}.s3{line-height:150%;margin-top:24pt;}.s4{line-height:150%;}.s5{font-family:Arial;font-size:11pt;font-weight:bold;}.s6{line-height:150%;margin-top:10pt;}.s7{font-family:Arial;font-size:11pt;font-style:italic;}.s8{font-family:Arial;font-size:11pt;}.s9{font-family:Arial;font-size:11pt;font-style:italic;font-weight:normal;}.s10{line-height:150%;margin-top:6pt;}.s11{font-family:Arial;font-size:8.8pt;}.s12{font-family:Arial;font-size:11pt;font-style:italic;color:#000000;}.s13{font-family:Arial;font-size:11pt;font-weight:normal;}.s14{font-family:Arial;font-size:8.8pt;font-weight:normal;}.s15{font-family:Arial;font-size:11pt;font-style:normal;}'
  class TestFachinfoHpricot62111De < Test::Unit::TestCase
    Styles = ''
    MedicInfoName = 'Bisoprolol Axapharm'
    def test_full_import
      opts = {:target=>:fi, :reparse=>true, :iksnrs=>["58107", "58106", "78656", "62111", "62439", "62223", "62728"], :companies=>[], :download=>false}
      names = {}
      names[:de] = File.expand_path('data/html/de/fi_62111.de.html',  File.dirname(__FILE__))
      type = 'fachinfo'
      textInfo = TextInfoPlugin.new(:swissmedicinfo, opts)
      res = textInfo.parse_and_update(names, type)
    end
    
    def test_some_more_swissmedic
      assert_equal(["61559", "61564", "61566", "61615", "61617", "61623"], TextInfoPlugin::get_iksnrs_from_string("61'559 - 61'564, 61'566 – 61'615, 61'617 - 61'623"))
    end
  end
  
  #  problem that the content of the fachinfo did not display correctly the firmenlogo  
  class TestFachinfo_62580_Novartis_Seebri< Test::Unit::TestCase
    MedicInfoName = ' Seebri Breezhaler'
    YamlName      = 'fi_62580.yaml'
    def setup
      @path = File.expand_path('data/html/de/fi_62580.de.html',  File.dirname(__FILE__))     
      @writer = FachinfoHpricot.new
      open(@path) { |fh| 
        @writer.format =  :swissmedicinfo
        @fachinfo = @writer.extract(Hpricot(fh), :fi, MedicInfoName)
      }
      File.open(YamlName, 'w+') { |fi| fi.puts @fachinfo.to_yaml }
    end
    
    def test_name2
      assert_equal(MedicInfoName, @fachinfo.name.to_s)
    end
    
    def test_firmenlogo
      assert(@fachinfo.galenic_form.to_s.index('Firmenlogo'))
      assert(@fachinfo.effects.to_s.index('(image)'), 'Wirkungen muss Bild enthalten')
      assert(@fachinfo.galenic_form.to_s.index('(image)'), 'galenic_form must have an image')
      assert(@fachinfo.to_yaml.index('/resources/images/fachinfo/de/_Seebri_Breezhaler_files/5.png'), 'Must have image nr 5')
      assert(@fachinfo.to_yaml.index('/resources/images/fachinfo/de/_Seebri_Breezhaler_files/4.png'), 'Must have image nr 4')
      assert(@fachinfo.to_yaml.index('/resources/images/fachinfo/de/_Seebri_Breezhaler_files/3.png'), 'Must have image nr 3')

      assert(@fachinfo.galenic_form.to_s.index('(image)'), 'Zusamensetzung muss Bild enthalten')
      assert(@fachinfo.to_yaml.index('/resources/images/fachinfo/de/_Seebri_Breezhaler_files/1.x-wmf'), 'Must have image nr 1')
    end

    def test_iksnrs
      assert_equal("Zulassungsnummer\n62580(Swissmedic)", @fachinfo.iksnrs.to_s)
      assert_equal(["62580"], TextInfoPlugin::get_iksnrs_from_string(@fachinfo.iksnrs.to_s))
    end    
  end
 
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
  end 
end
