#!/usr/bin/env ruby
# ODDB::TestNarcoticPlugin -- oddb -- 03.11.2005 -- ffricker@ywesee.com

$: << File.expand_path('../../src', 
File.dirname(__FILE__))
$: << File.expand_path('..', File.dirname(__FILE__))


require 'test/unit'
require 'plugin/narcotic'
require 'flexmock'

module ODDB
	class TestNarcoticPlugin < Test::Unit::TestCase
		def setup
			@app = FlexMock.new
			@plugin = NarcoticPlugin.new(@app)
		end
		def test_casrns
			row = ['NAME', nil, 'pcode', 'smcd']
			assert_equal(@plugin.casrns(row), [])
			row = ['NAME', '', 'pcode', 'smcd']
			assert_equal(@plugin.casrns(row), [])
			row = ['NAME', 'nil', 'pcode', 'smcd']
			assert_equal(@plugin.casrns(row), [nil])
			row = ['NAME', '11-11-11', 'pcode', 'smcd']
			assert_equal(['11-11-11'], @plugin.casrns(row))
		end
		def test_smcd
			row = ['NAME', 'casrn', 'pcode', '7680543210079']
			assert_equal('54321007', @plugin.smcd(row))
			row = ['NAME', 'casrn', 'pcode', nil]
			assert_nil(@plugin.smcd(row))
			row = ['NAME', 'casrn', 'pcode', ''] 
			assert_nil(@plugin.smcd(row))
			row = ['NAME', 'casrn', 'pcode', 'nil'] 
			assert_nil(@plugin.smcd(row))
		end
		def test_category
			row = ['NAME', 'casrn', 'pcode', 'eancode', 'company', 'c']
			assert_equal('c', @plugin.category(row))
			row = ['NAME', 'casrn', 'pcode', 'eancode', 'company', '']
			assert_nil(@plugin.category(row))
		end
		def test_report_text
			row = ['name','text1','text2','text3','text4']
			expected = "name\ntext1 | text2 | text3 | text4\n"
			assert_equal(expected, @plugin.report_text(row))
			row = [nil,nil,nil,nil,nil]
			expected = "Error! Entry has no name!"
			assert_equal(expected, @plugin.report_text(row))
		end
		def test_update_narcotic
			row = ["Dextropropoxyphenhaltige","- - - - -","- - - - -",
				"- - - - -","- - - - -","c"]
			assert_equal("Dextropropoxyphenhaltige",
									 @plugin.update_narcotic(row, "111-111",  :de))
		end
		def test_narcotic_text
			text = "Codeinhaltige"
			assert_equal("Codein", @plugin.text2name(text, :de))
			text = "Les préparations contenant du dextropropoxyphène sont" 
			assert_equal("dextropropoxyphène", @plugin.text2name(text, :fr))
		end	
		def test_name
			row = ['Codein', 'casrn', 'pcode', '7680543210079']
			assert_equal('Codein', @plugin.name(row))
			row = [nil, 'casrn', 'pcode', '7680543210079']
			assert_equal('', @plugin.name(row))
		end
		def test_name_substance
			row = ['Codein (unter Vorbehalt von)', 'casrn', 'pcode', '7680543210079']
			assert_equal('Codein', @plugin.strip_name(row).at(0).strip)
			row = ['Codein-Oxid-H2O', 'casrn', 'pcode', '7680543210079']
			assert_equal('Codein-Oxid-H2O', @plugin.strip_name(row).at(0))
		end
	end
end
