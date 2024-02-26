#!/usr/bin/env ruby
# encoding: utf-8
# CssTemplate -- oddb -- 28.07.2003 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'util/csstemplate'
require 'util/workdir'

module ODDB
	class CssTemplate
		remove_const :RESOURCE_PATH
		remove_const :TEMPLATE
		remove_const :DEFAULT
		remove_const :FLAVORS
		RESOURCE_PATH = File.join(ODDB::TEST_DATA_DIR, 'css/')
		TEMPLATE = File.join(ODDB::TEST_DATA_DIR, 'css/template.css')

		DEFAULT = {
			:bar_bg					=>	'white',
			:bar_txt_color	=>	'black',
			:bar_link_color	=>	'gold',
		}
		FLAVORS = {
			:foo	=>	{
				:bar_bg					=>	'black',
				:bar_txt_color	=>	'white',
		},
		}
	end
end

class TestCssTemplate <Minitest::Test
	TEST_CSS_DIRECTORY = File.join(ODDB::TEST_DATA_DIR, 'css/foo')

	def setup
		@foo	=	{
			:bar_bg					=>	'black',
			:bar_txt_color	=>	'white',
		}
	end
	def teardown
		File.delete(TEST_CSS_DIRECTORY + '/oddb.css') if File.exist?(TEST_CSS_DIRECTORY + '/oddb.css')
	end
	def test_resolve
		var = 'bar_bg'
		result = ODDB::CssTemplate.resolve(var, @foo)
		expected = 'black'
		assert_equal(expected, result)
	end
	def test_resolve_default
		var = 'bar_link_color'
		result = ODDB::CssTemplate.resolve(var, @foo)
		expected = 'gold'
		assert_equal(expected, result)
	end
	def test_substitute
		src = '$foobar'	
		assert_raises(RuntimeError){
			ODDB::CssTemplate.substitute(src, @foo)
		}
	end
	def test_substitute2
		src = '$bar_bg'	
		assert_equal('black', ODDB::CssTemplate.substitute(src, @foo))
	end
	def test_substitute3
		src = 'bar_bg'	
		assert_equal('bar_bg', ODDB::CssTemplate.substitute(src, @foo))
	end
	def test_substitute4
		src = <<-EOS 
			background-color: $bar_bg;
			link-color: $bar_link_color;
		EOS
		expected = <<-EOS 
			background-color: black;
			link-color: gold;
		EOS
		assert_equal(expected, ODDB::CssTemplate.substitute(src, @foo))
	end
	def test_write_css
		res = ODDB::CssTemplate.write_css
		tst_css = File.join(TEST_CSS_DIRECTORY, '/oddb.css')
		assert(File.exist?(tst_css), "File #{tst_css} must exist")
	end
end
