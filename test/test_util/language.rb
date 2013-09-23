#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestLanguage -- oddb.org -- 20.06.2011 -- mhatakeyama@ywesee.com
# TestLanguage -- oddb.org -- 24.03.2003 -- mhuggler@ywesee.com 

#$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'util/language'
require 'odba'
require 'util/searchterms'

class Language
	attr_accessor :foo
	include ODDB::Language
	def Language.reset_oid
		@oid=0
	end
	def odba_id
	end
end

class TestLanguage <Minitest::Test
	def setup
		Language.reset_oid
		@obj = Language.new
	end
	def	test_update_values1
		values = {
			'de' => 'eine Beschreibung'
		}
		@obj.update_values(values)
		assert_equal(values, @obj.descriptions.to_hash)
	end
	def test_update_values2
		@obj.descriptions.store("de","eine Beschreibung")
		assert_equal({'de' => 'eine Beschreibung'}, @obj.descriptions.to_hash)
		values = {
			'de' => "eine andere Beschreibung"
		}
		@obj.update_values(values)
		assert_equal(values, @obj.descriptions.to_hash)
	end
	def test_update_values3
		@obj.foo = 'bar'
		@obj.descriptions.store("de","eine Beschreibung")
		values = {
			'de'	=>	"eine andere Beschreibung",
			:foo	=>	"baz",
		}
		@obj.update_values(values)
		assert_equal({'de'	=>	'eine andere Beschreibung'}, @obj.descriptions.to_hash)
		assert_equal('baz', @obj.foo)
	end
	def test_update_values_default_value
		values = {
			'de'	=>	'eine Beschreibung',
		}
		@obj.update_values(values)
		assert_equal('eine Beschreibung', @obj.description('de'))
		assert_equal('eine Beschreibung', @obj.description('fr'))
		assert_equal('eine Beschreibung', @obj.description)
		values = {
			'en'	=>	'a description',
		}
		@obj.update_values(values)
		assert_equal('eine Beschreibung', @obj.description('de'))
		assert_equal('eine Beschreibung', @obj.description('fr'))
		assert_equal('a description', @obj.description('en'))
		values = {
			'de'	=>	'eine andere Beschreibung',
		}
		@obj.update_values(values)
		assert_equal('eine andere Beschreibung', @obj.description('de'))
		assert_equal('eine andere Beschreibung', @obj.description('fr'))
		assert_equal('a description', @obj.description('en'))
		values = {
			'fr'	=>	'une description',
		}
		@obj.update_values(values)
		assert_equal('eine andere Beschreibung', @obj.description('de'))
		assert_equal('une description', @obj.description('fr'))
		assert_equal('a description', @obj.description('en'))
	end
	def test_method_missing
		@obj.descriptions.store("de","eine Beschreibung")
		assert_nothing_raised { @obj.de }
		assert_nothing_raised { @obj.description('de') }
		assert_equal('eine Beschreibung', @obj.de)
		assert_equal('eine Beschreibung', @obj.description('de'))
	end
	def test_respond_to
		@obj.descriptions.store("de","eine Beschreibung")
		assert_respond_to(@obj, :de)
		assert_respond_to(@obj, :fr)
	end
	def test_has_description
		values = {
			'de' => 'eine Beschreibung'
		}
		@obj.update_values(values)
		assert_equal(true, @obj.has_description?('eine Beschreibung'))	
		assert_equal(false, @obj.has_description?('eine andere Beschreibung'))
	end
	def test_init
		pointer = ODDB::Persistence::Pointer.new([:foo, 1], [:bar])
		@obj.pointer = pointer
		@obj.init(nil)
		expected = pointer.parent + [:bar, @obj.oid]
		assert_equal(expected, @obj.pointer)
		@obj.init(nil)
		expected = pointer.parent + [:bar, @obj.oid]
		assert_equal(expected, @obj.pointer)
	end
end
class TestDescriptions <Minitest::Test
	def setup
		@desc = ODDB::SimpleLanguage::Descriptions.new
		@desc['foo'] = 'bar'
	end
	def test_to_hash
		assert_equal({'foo'=>'bar'}, @desc.to_hash)
	end
end

module ODDB
  class StubSimpleLanguage
    include ODDB::SimpleLanguage
  end

  class TestDescriptions <Minitest::Test
    include FlexMock::TestCase
    def setup
      @descriptions = ODDB::SimpleLanguage::Descriptions.new
    end
    def test_first
      assert_equal('', @descriptions.first)
    end
  end

  class TestSimpleLanguage <Minitest::Test
    include FlexMock::TestCase
    def setup
      flexmock(ODBA.cache, :next_id => 123)
      @simplelanguage = ODDB::StubSimpleLanguage.new
    end
    def test_match
      assert_equal(false, @simplelanguage.match(/pattern/)) 
    end
    def test_method_missing
      assert_raise(NoMethodError) do 
        @simplelanguage.nomethod
      end
    end
    def test_search_text
      assert_equal('', @simplelanguage.search_text('de'))
    end
    def test_to_s
      assert_equal('', @simplelanguage.to_s)
    end
    def test_to_s__not_empty
      @simplelanguage.descriptions.store('key', 'value')
      skip("Don't know whether 'value' is the correct result")
      assert_equal('value', @simplelanguage.to_s)
    end
  end

  class StubLanguage
    include ODDB::Language
  end
  class TestLanguage <Minitest::Test
    include FlexMock::TestCase
    def setup
      flexmock(ODBA.cache, :next_id => 123)
      @language = ODDB::StubLanguage.new
    end
    def test_all_descriptions
      assert_equal([], @language.all_descriptions)
    end
    def test_synonyms
      @language.synonyms=['synonym']
      assert_equal(["synonym"], @language.synonyms)
    end
  end

end
