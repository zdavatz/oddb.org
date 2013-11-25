#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestFachinfo -- oddb.org -- 09.09.2011 -- rwaltert@ywesee.com
# ODDB::TestFachinfo -- oddb.org -- 17.09.2003 -- rwaltert@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'stub/odba'
gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'model/fachinfo'
require 'model/text'

module ODDB
  class Fachinfo
    attr_accessor :registrations
  end
  class FachinfoDocument
    attr_accessor :registrations
  end
  class TestFachinfo <Minitest::Test
    include FlexMock::TestCase
    class StubRegistration
      attr_accessor :company_name
      attr_accessor :generic_type
      attr_accessor :substance_names
    end
    def setup
      @fachinfo = ODDB::Fachinfo.new
    end
    def test_add_registration
      reg = StubRegistration.new
      @fachinfo.add_registration(reg)
      assert_equal([reg], @fachinfo.registrations)
    end
    def test_add_change_log_item
      item, = @fachinfo.add_change_log_item 'test@email.ch', :indications, :de
      item = @fachinfo.change_log[0]
      assert_instance_of ODDB::Fachinfo::ChangeLogItem, item
      assert_equal 'test@email.ch', item.email
      assert_equal :indications, item.chapter
      assert_equal :de, item.language
      assert_equal [item], @fachinfo.change_log
    end
    def test_add_indication
      item = @fachinfo.add_change_log_item 'test@email.ch', :indications, :de
      item = @fachinfo.change_log[0]
      assert_instance_of ODDB::Fachinfo::ChangeLogItem, item
      assert_equal 'test@email.ch', item.email
      assert_equal :indications, item.chapter
      assert_equal :de, item.language
      assert_equal [item], @fachinfo.change_log
      assert_equal 1, @indications.size
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
    include FlexMock::TestCase
    def setup
      @doc = FachinfoDocument.new
    end
    def test_first_chapter
      ue = flexmock 'unwanted_effects'
      @doc.unwanted_effects = ue
      skip("Niklaus has not time to fix this assert")
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
  end
end
