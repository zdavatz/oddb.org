#!/usr/bin/env ruby
# TestSoundex -- ODDB -- 15.10.2004 -- hwyss@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'util/soundex'

module ODDB
	class TestSoundex < Test::Unit::TestCase
		def test_prepare
			assert_equal('essigsaeure', Text::Soundex.prepare('essigsäure'))
			input = "ä á à â æ ã Ä Á À Â Æ Ã"
			expected = "ae a a a ae a ae a a a ae a"
			assert_equal(expected, Text::Soundex.prepare(input))
			input = "ç Ç"
			expected = "c c"
			assert_equal(expected, Text::Soundex.prepare(input))
			input = "ë é è ê Ë É È Ê"
			expected = "e e e e e e e e"
			assert_equal(expected, Text::Soundex.prepare(input))
			input = "ï í ì î Ï Í Ì Î"
			expected = "i i i i i i i i"
			assert_equal(expected, Text::Soundex.prepare(input))
			input = "ö ó ò ô õ ø Ö Ó Ò Ô Õ Ø"
			expected = "oe o o o o o oe o o o o o"
			assert_equal(expected, Text::Soundex.prepare(input))
			input = "ü ú ù û Ü Ú Ù Û"
			expected = "ue u u u ue u u u"
			assert_equal(expected, Text::Soundex.prepare(input))
			input = "þ ß ð"
			expected = "p s d"
			assert_equal(expected, Text::Soundex.prepare(input))
			input = "(+)-alpha-Tocopheroli Acetas"
			expected = "alpha Tocopheroli Acetas"
			assert_equal(expected, Text::Soundex.prepare(input))
		end
		def test_soundex
			assert_not_nil(Text::Soundex.soundex('essigsäure'))
		end
	end
end
