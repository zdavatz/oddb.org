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
			expected = "ae a a a ae a Ae A A A Ae A"
			assert_equal(expected, Text::Soundex.prepare(input))
			input = "ç Ç"
			expected = "c C"
			assert_equal(expected, Text::Soundex.prepare(input))
			input = "ë é è ê Ë É È Ê"
			expected = "e e e e E E E E"
			assert_equal(expected, Text::Soundex.prepare(input))
			input = "ï í ì î Ï Í Ì Î"
			expected = "i i i i I I I I"
			assert_equal(expected, Text::Soundex.prepare(input))
			input = "ö ó ò ô õ ø Ö Ó Ò Ô Õ Ø"
			expected = "oe o o o o o Oe O O O O Oe"
			assert_equal(expected, Text::Soundex.prepare(input))
			input = "ü ú ù û Ü Ú Ù Û"
			expected = "ue u u u Ue U U U"
			assert_equal(expected, Text::Soundex.prepare(input))
			input = "þ ß ð"
			expected = "f ss d"
			assert_equal(expected, Text::Soundex.prepare(input))
			input = "(+)-alpha-Tocopheroli Acetas"
			expected = "+alphaTocopheroli Acetas"
			assert_equal(expected, Text::Soundex.prepare(input))
		end
		def test_soundex
			assert_not_nil(Text::Soundex.soundex('essigsäure'))
		end
	end
end
