#!/usr/bin/env ruby
# TestLanguage -- oddb -- 24.03.2003 -- mhuggler@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'util/language'

class StubLanguage
	attr_accessor :foo
	include ODDB::Language
	def StubLanguage.reset_oid
		@oid=0
	end
end

class TestLanguage < Test::Unit::TestCase
	def setup
		StubLanguage.reset_oid
		@obj = StubLanguage.new
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
class TestDescriptions < Test::Unit::TestCase
	def setup
		@desc = ODDB::SimpleLanguage::Descriptions.new
		@desc['foo'] = 'bar'
	end
	def test_to_hash
		assert_equal({'foo'=>'bar'}, @desc.to_hash)
	end
end
