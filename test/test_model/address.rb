#!/usr/bin/env ruby
# TestAddress -- oddb -- 24.02.2003 -- jlang@ywesee.com, usenguel@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/address'

module ODDB
	class TestAddress < Test::Unit::TestCase
		def setup
			@address = ODDB::Address.new
		end
		def test_search_terms__prof
			@address.lines = [
				'Egregio Prof.',
				'Monsieur le Professeur',
				'Claudio Marone',
				'Studio medico',
				'Christoph Profos',
				'Ospedale San Giovanni',
				'6500 Bellinzona' 
			]
			expected = [
				'Claudio Marone',
				'Studio medico',
				'Christoph Profos',
				'Ospedale San Giovanni',
				'6500 Bellinzona' 
			]
			assert_equal(expected, @address.lines_without_title)
		end
		def test_search_terms__dr
			@address.lines = [
				'Herr Dr. med.',
				'Herrn Dr. med.',
				'Frau Dr. med',
				'6500 Bellinzona' 
			]
			expected = [
				'6500 Bellinzona' 
			]
			assert_equal(expected, @address.lines_without_title)
		end
	end
end
