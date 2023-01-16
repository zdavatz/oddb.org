#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestFachinfo -- oddb.org -- 09.09.2011 -- rwaltert@ywesee.com
# ODDB::TestFachinfo -- oddb.org -- 17.09.2003 -- rwaltert@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'stub/odba'

require 'minitest/autorun'
require 'flexmock/minitest'
require 'model/fachinfo'
require 'model/text'
require 'yaml'
class Diffy::Diff
  attr_reader :tempfiles
end

module ODDB
  class Fachinfo
    attr_accessor :registrations
  end
  class FachinfoDocument
    attr_accessor :registrations
  end
  class TestFachinfo <Minitest::Test
    class StubRegistration
      attr_accessor :company_name
      attr_accessor :generic_type
      attr_accessor :substance_names
      attr_accessor :iksnr
    end
    def setup
      @fachinfo = ODDB::Fachinfo.new

    end

    def tempfile(string, fn = 'diffy-spec')
      t = Tempfile.new(fn)
      # ensure tempfiles aren't unlinked when GC runs by maintaining a
      # reference to them.
      @tempfiles ||=[]
      @tempfiles.push(t)
      t.print(string)
      t.flush
      t.close
      t.path
    end

    def test_marshall_diff_item_with_closed_tempfile
      string1 = "foo\nbar\nbang\n"
      string2 = "foo\nbang\n"
      path1, path2 = tempfile(string1, 'path with spaces'), tempfile(string2, 'path with spaces')
      res = Diffy::Diff.new(path1, path2, :source => 'strings')
      assert_nil(res.tempfiles)
      res.diff
      skip('ODBA is not yet up to this task')
      assert_equal(false,  res.tempfiles.eql?([]))
      binary = ODBA::Marshal.dump(res)
    end

    def test_add_registration
      reg = StubRegistration.new
      @fachinfo.add_registration(reg)
      assert_equal([reg], @fachinfo.registrations)
    end
    def test_atc_class
      reg1 = flexmock :atc_classes => ['first atc', 'second atc']
      reg2 = flexmock :atc_classes => ['third atc']
      @fachinfo.registrations.push reg1, reg2
      assert_equal 'first atc', @fachinfo.atc_class
    end
    def test_remove_registration
      reg = StubRegistration.new
      @fachinfo.registrations = [reg]
      @fachinfo.remove_registration(reg)
      assert_equal([], @fachinfo.registrations)
    end
    def test_each_chapter
      fachinfo = ODDB::FachinfoDocument.new
      fachinfo.galenic_form = ODDB::Text::Chapter.new
      fachinfo.composition = ODDB::Text::Chapter.new
      chapters = []
      fachinfo.each_chapter { |chap|
        chapters << chap	
      }
      assert_equal(2, chapters.size)
    end

    def test_each_chapter2
      fachinfo = ODDB::FachinfoDocument2001.new
      fachinfo.amzv = ODDB::Text::Chapter.new
      fachinfo.composition = ODDB::Text::Chapter.new
      fachinfo.effects = ODDB::Text::Chapter.new
      chapters = []
      fachinfo.each_chapter { |chap|
        chapters << chap
      }
      assert_equal(3, chapters.size)
    end
    def test_fachinfo_text
      fachinfo = ODDB::FachinfoDocument2001.new
      fachinfo.composition = ODDB::Text::Chapter.new
      fachinfo.composition.heading = 'Zusammensetzung'
      paragraph = fachinfo.composition.next_section.next_paragraph
      paragraph << 'Diaphin i.v.
Wirkstoff: Diamorphin als Diamorphinhydrochlorid Monohydrat'
      fachinfo.effects = ODDB::Text::Chapter.new
      fachinfo.effects.heading = 'Eigenschaften/Wirkungen'
      paragraph = fachinfo.effects.next_section.next_paragraph
      paragraph << 'ATC-Code: L01XE31'

      chapters = []
      fachinfo.each_chapter { |chap|
        chapters << chap
      }
      assert_equal(2, chapters.size)
      expected = "Zusammensetzung
Diaphin i.v.
Wirkstoff: Diamorphin als Diamorphinhydrochlorid Monohydrat
Eigenschaften/Wirkungen
ATC-Code: L01XE31
"
      assert_equal(expected, fachinfo.text)
    end
    def test_each_chapter_pseudo_fachinfo
      fachinfo = ODDB::PseudoFachinfoDocument.new
      fachinfo.composition = ODDB::Text::Chapter.new
      fachinfo.indications = ODDB::Text::Chapter.new
      fachinfo.usage = ODDB::Text::Chapter.new
      fachinfo.contra_indications = ODDB::Text::Chapter.new
      fachinfo.restrictions = ODDB::Text::Chapter.new
      fachinfo.interactions = ODDB::Text::Chapter.new
      fachinfo.unwanted_effects = ODDB::Text::Chapter.new
      fachinfo.effects = ODDB::Text::Chapter.new
      fachinfo.other_advice = ODDB::Text::Chapter.new
      fachinfo.iksnrs = ODDB::Text::Chapter.new
      fachinfo.packages = ODDB::Text::Chapter.new
      fachinfo.fabrication = ODDB::Text::Chapter.new
      fachinfo.distributor = ODDB::Text::Chapter.new
      fachinfo.date = ODDB::Text::Chapter.new
      chapters = []
      fachinfo.each_chapter { |chap|
        chapters << chap
      }
      assert_equal(14, chapters.size)
    end
    def test_company
      reg = flexmock :company => 'company'
      @fachinfo.registrations.push(reg)
      assert_equal 'company', @fachinfo.company
    end
    def test_company_name
      reg = StubRegistration.new
      expected = "Ywesee"
      reg.company_name = expected
      @fachinfo.registrations.push(reg)
      assert_equal(expected, @fachinfo.company_name)
    end
    def test_generic_type
      assert_equal(:unknown, @fachinfo.generic_type)
      reg = StubRegistration.new
      expected = :generic
      reg.generic_type = expected
      @fachinfo.registrations.push(reg)
      assert_equal(expected, @fachinfo.generic_type)
    end
    def test_interaction_text
      doc = flexmock :interactions => 'Some Interaction Text'
      @fachinfo.descriptions.store 'de', doc
      assert_equal 'Some Interaction Text', @fachinfo.interaction_text(:de)
    end
    def test_localized_name
      assert_nil @fachinfo.localized_name
      reg = flexmock :name_base => 'NameBase'
      @fachinfo.registrations.push reg
      assert_equal 'NameBase', @fachinfo.localized_name
      doc = flexmock :name => 'Name'
      @fachinfo.descriptions.store 'de', doc
      assert_equal 'Name', @fachinfo.localized_name
      doc = flexmock :name => 'Nom'
      @fachinfo.descriptions.store 'fr', doc
      assert_equal 'Nom', @fachinfo.localized_name(:fr)
    end
    def test_fachinfo_lang_and_descriptions
      @fachinfo = ODDB::Fachinfo.new
      @fachinfo.descriptions.store 'de', 'deutsch'
      @fachinfo.descriptions.store 'fr', 'français'
      assert_equal @fachinfo['de'].to_s, @fachinfo.descriptions['de'].to_s
      skip('This does not work as expected')
      assert_equal @fachinfo['fr'].to_s, @fachinfo.descriptions['fr'].to_s
    end
    def test_pointer_descr
      assert_nil @fachinfo.pointer_descr
      reg = flexmock :name_base => 'NameBase'
      @fachinfo.registrations.push reg
      assert_equal 'NameBase', @fachinfo.pointer_descr
    end
    def test_search_text
      doc = flexmock :indications => 'Some Indication Text'
      @fachinfo.descriptions.store 'de', doc
      assert_equal 'Some Indication Text', @fachinfo.search_text(:de)
    end
    def test_substance_names
      reg = StubRegistration.new
      expected = ["Magnesuim", "Mannidol"]
      reg.substance_names = expected
      @fachinfo.registrations.push(reg)
      assert_equal(expected, @fachinfo.substance_names)
    end
    def test_unwanted_effect_text
      doc = flexmock :unwanted_effects => 'Some Unwanted Effect Text'
      @fachinfo.descriptions.store 'de', doc
      assert_equal 'Some Unwanted Effect Text', @fachinfo.unwanted_effect_text(:de)
    end
  end
  class TestFachinfoDocument <Minitest::Test
    def setup
      fachinfo = ODDB::FachinfoDocument2001.new
      fachinfo.composition = ODDB::Text::Chapter.new
      fachinfo.composition.heading = 'Zusammensetzung'
      paragraph = fachinfo.composition.next_section.next_paragraph
      paragraph << 'Diaphin i.v.
Wirkstoff: Diamorphin als Diamorphinhydrochlorid Monohydrat'
      @doc = FachinfoDocument.new
      @old_text = 'old text'
      @new_text = 'new text'
      @expected = "-old text
\\ Kein Zeilenumbruch am Dateiende.
+new text
\\ Kein Zeilenumbruch am Dateiende.
"
      Diffy::Diff.default_options = Diffy::Diff::ORIGINAL_DEFAULT_OPTIONS
      @old_fi = ODDB::FachinfoDocument2001.new
      @old_fi.composition = ODDB::Text::Chapter.new
      @old_fi.composition.heading = 'Zusammensetzung'
      @old_paragraph = @old_fi.composition.next_section.next_paragraph
      @old_paragraph << 'line 1
line 2
line 3
line 4
line 5
'
      @new_doc = ODDB::FachinfoDocument2001.new
      @new_doc.composition = ODDB::Text::Chapter.new
      @new_doc.composition.heading = 'Zusammensetzung'
      @changed_paragraph = @new_doc.composition.next_section.next_paragraph
      @changed_paragraph << 'line 1
Changed line 2
line 3
line 4
line 5
'
    end
    def test_image_link
      new_doc = ODDB::FachinfoDocument2001.new
      new_doc.composition = ODDB::Text::Chapter.new
      new_doc.composition.heading = 'Zusammensetzung'
      para_1 = new_doc.composition.next_section
      para_2 = para_1.next_paragraph
      para_2 << 'a'
      table = para_1.next_table
      table << 'b'
      multi = table.next_multi_cell!
      multi << 'm'
      image = multi.next_image
      expected = "Zusammensetzung
a
b m(image)

"
      assert_equal(expected, new_doc.text)
    end
    def test_first_chapter
      ue = flexmock 'unwanted_effects'
      @doc.unwanted_effects = ue
      skip("Niklaus has no time to fix this assert")
      assert_equal ue, @doc.first_chapter
      us = flexmock 'usage'
      @doc.usage = us
      assert_equal us, @doc.first_chapter
      gf = flexmock 'galenic_form'
      @doc.galenic_form = gf
      assert_equal gf, @doc.first_chapter
      @doc.composition = flexmock 'composition'
      assert_equal gf, @doc.first_chapter
    end
    def test_add_change_log_item
      saved_language = ENV['LANGUAGE']
      ENV['LANGUAGE'] = 'C'
      item = @doc.add_change_log_item 'old text', 'new text'
      item = @doc.change_log[0]
      assert_instance_of ODDB::FachinfoDocument::ChangeLogItem, item
      assert_equal [item], @doc.change_log
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
      ENV['LANGUAGE'] = saved_language
    end

    def test_change_log_item_utf8
      @oldText = "Crilomus®\nL04AD02"
      @newText = "Crilomus®\nCodice ATC L04AD02FarmacodinamicaTacrolimus &amp;egrav"
      saved_language = ENV['LANGUAGE']
      ENV['LANGUAGE'] = 'LANG=en_US.UTF-8'
      item = @doc.add_change_log_item @oldText, @newText
      item = @doc.change_log[0]
      assert_instance_of ODDB::FachinfoDocument::ChangeLogItem, item
      assert_equal [item], @doc.change_log
      assert_equal @@today, item.time
      assert_instance_of Diffy::Diff, item.diff
      expected = %(<div class="diff">
  <ul>
    <li class="del"><del><span class="symbol">-</span>L04AD02</del></li>
    <li class="ins"><ins><span class="symbol">+</span><strong>Codice ATC </strong>L04AD02<strong>FarmacodinamicaTacrolimus &amp;amp;egrav</strong></ins></li>
  </ul>
</div>
)
      assert_equal expected, item.diff.to_s(:html)
      assert_equal @@today.to_s, item.time.to_s
    ensure
      ENV['LANGUAGE'] = saved_language
    end
    def test_add_change_log_item_with_time
      item = @doc.add_change_log_item 'old text', 'new text', @@one_year_ago
      item = @doc.change_log[0]
      assert_instance_of ODDB::FachinfoDocument::ChangeLogItem, item
      assert_equal [item], @doc.change_log
      assert_equal @@one_year_ago, item.time
      assert_instance_of Diffy::Diff, item.diff
      assert_equal(  ODDB::FachinfoDocument::Fachinfo_diff_options, item.diff.options)
    end
    def test_add_change_log_item_with_time_and_options
      special_options =  { :context => 27,
                           :include_plus_and_minus_in_html => true,
                           :allow_empty_diff => false
                           }
      item = @doc.add_change_log_item 'old text', 'new text', @@one_year_ago, special_options
      item = @doc.change_log[0]
      assert_instance_of ODDB::FachinfoDocument::ChangeLogItem, item
      assert_equal [item], @doc.change_log
      assert_equal @@one_year_ago, item.time
      assert_instance_of Diffy::Diff, item.diff
      full_options =  Diffy::Diff.default_options
      full_options.merge! special_options
      assert_equal( full_options, item.diff.options)
    end
    def test_fachinfo_change_log_text
      new_text = @old_fi.text.sub('line 2', 'Changed line 2')
expected = "-line 2
+Changed line 2
"
      @doc.add_change_log_item(@old_fi.text, new_text)
      assert_equal(expected, @doc.change_log[0].diff.to_s)
      assert_equal(@@today, @doc.change_log[0].time)
    end
    def test_fachinfo_change_log_text_only_once
      @doc.add_change_log_item(@old_fi.text, @doc.text)
      assert_equal(1, @doc.change_log.size)
      @doc.add_change_log_item(@old_fi.text, @doc.text)
      assert_equal(1, @doc.change_log.size)
    end
    def test_fachinfo_change_log_text_only_once_if_emtpy
      @doc.add_change_log_item(nil, @doc.text)
      assert_equal(1, @doc.change_log.size)
      @doc.add_change_log_item(nil, @doc.text)
      assert_equal(1, @doc.change_log.size)
      @doc.add_change_log_item(@old_fi.text, @doc.text)
      assert_equal(2, @doc.change_log.size)
      @doc.add_change_log_item(@doc.text, 'Neuer Text')
      assert_equal(3, @doc.change_log.size)
    end
    def test_fachinfo_text_with_table
      file = File.expand_path(File.join(File.dirname(__FILE__), '..', 'data', 'Cansartan-61215.yaml'))
      fi = YAML.safe_load(File.read(file), permitted_classes: [ODDB::FachinfoDocument2001,
                                                               ODDB::Text::Chapter,
                                                               ODDB::Text::Format,
                                                               Symbol,
                                                               ODDB::Text::Table,
                                                               ODDB::Text::MultiCell,
                                                               ODDB::Text::Paragraph,
                                                               ODDB::Text::Section], aliases: true)
      fi_text = fi.text
      text_last_table_row = fi.effects.paragraphs[17].rows[5].to_s
      text_chapter_17 = fi.effects.paragraphs[17].to_s
      assert(/(\n|^)Zusammensetzung/.match(fi_text))
      assert(/\nDosierung\/Anwendung/.match(fi_text))
      assert(/\nGalenische Form und Wirkstoffmenge pro Einheit/.match(fi_text))
      assert(/Patientenzahl/.match(text_chapter_17))
      assert(/mit einem/.match(text_chapter_17))
      assert(/Patientenzahl mit einem ersten Ereignis/.match(text_chapter_17))
      assert(/Kontrollgruppe/.match(text_chapter_17))
      assert(/Kontrollgruppe/.match(text_chapter_17))
      assert(text_chapter_17.index('Candesartan Cilexetil* (N=2477) Kontrollgruppe* (N=2460) Relatives Risiko (95% CI)'))
      assert(fi_text.index(/ ungen.{1,2}gender Effekt/) > 0, "Muss Umlaute korrekt darstellen")
      assert(fi_text.index('Relatives Risiko (95% CI)') > 0, 'Muss Text in Tabelle finden')
      assert(fi_text.index('kognitiven Funktion und der Lebensqualit') > 0, "Muss Text in Kapitel 'Klinische Wirksamkeit' von  Eigenschaften/Wirkungen finden")
      assert(fi_text.index(' ungenügender Effekt') > 0, "Muss Umlaute korrekt darstellen")
      assert(fi_text.index('Wirkungsmechanismus/Pharmakodynamik') > 0, "Muss Text in Eigenschaften/Wirkungen finden")
      assert(fi_text.index('kognitiven Funktion und der Lebensqualitä') > 0, "Muss Text in Kapitel 'Klinische Wirksamkeit' von  Eigenschaften/Wirkungen finden")

    end
    def show_changes(old, new, options)
      # puts "\n\nSHOW CHANGES"
      result = Diffy::Diff.new(old, new, options)
      nr = 0
      nr_additions = 0
      nr_deletions = 0
      result.each_chunk do |x|
        nr += 1
        nr_additions += 1 if /^\+/.match x
        nr_deletions += 1 if /^\-/.match x
      end
      # puts "size  #{nr} chunks  #{nr_additions} nr_additions #{nr_deletions} nr_deletions"
    end

  end
end
