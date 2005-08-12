#!/usr/bin/env ruby
# TestAddress2 -- oddb -- 28.07.2005 -- jlang@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/address'


module ODDB
	class TestAddress2 < Test::Unit::TestCase
		def setup
			@address = Address2.new
		end
		def test_street__0
			assert_nothing_raised { @address.street }
			assert_nothing_raised { @address.number }
		end
		def test_street__1
			@address.address = 'Winterthurerstrasse 52'
			assert_equal('Winterthurerstrasse', @address.street)
			assert_equal('52', @address.number)
		end
		def test_street__2
			@address.address = '13, Champs Elysees'
			assert_equal('Champs Elysees', @address.street)
			assert_equal('13', @address.number)
		end
		def test_street__3
			@address.address = '13 Champs Elysees'
			assert_equal('Champs Elysees', @address.street)
			assert_equal('13', @address.number)
		end
		def test_street__4
			@address.address = 'Champs Elysees'
			assert_nil(@address.number)
		end
		def test_location__1
			@address.location = '8000 Zürich'
			assert_equal('8000', @address.plz)
			assert_equal('Zürich', @address.city)
		end
		def test_location__2
			@address.location = 'Zürich 8000'
			assert_equal('Zürich', @address.city)
			assert_equal('8000', @address.plz)
		end
		def test_location__3
			@address.location = 'Zürich'
			assert_equal('Zürich', @address.city)
			assert_nil(@address.plz)
		end
		def test_location__3
			@address.location = 'CH-8006 Zürich'
			assert_equal('Zürich', @address.city)
			assert_equal('8006', @address.plz)
		end
		def test_lines__1
			@address.title = 'Herrn Dr. med.'
			@address.name = 'Walter Hugentobler'
			@address.additional_lines = ['Arztpraxis', 
			'Praxisgemeinschaft Wasserfels']
			@address.address = 'Burgrain 37'
			@address.location = '8706 Meilen'

			exspected = [
				'Herrn Dr. med.',
				'Walter Hugentobler',
				'Arztpraxis',
				'Praxisgemeinschaft Wasserfels',
				'Burgrain 37',
				'8706 Meilen',
			]
			assert_equal(exspected, @address.lines)
		end
		def test_lines__2
			@address.title = 'Herrn Dr. med.'
			@address.name = 'Walter Hugentobler'
			@address.additional_lines = ['Arztpraxis']
			@address.address = 'Burgrain 37'
			@address.location = '8706 Meilen'

			exspected = [
				'Herrn Dr. med.',
				'Walter Hugentobler',
				'Arztpraxis',
				'Burgrain 37',
				'8706 Meilen',
			]
			assert_equal(exspected, @address.lines)
		end
		def test_replace_with
			other = Address2.new
			other.title = 'Herrn Dr. med.'
			other.name = 'Walter Hugentobler'
			other.address = 'Schürmattstrasse 4b'
			other.location = '8706 Meilen'
			other.fon = ['041 154 32 64']
			other.fax = ['041 254 32 64']
			other.canton = 'SO'
			other.type = 'at_praxis'

			@address.name = 'Walter F. Hugentobler'
			@address.additional_lines = ['Arztpraxis', 
				'Praxisgemeinschaft Wasserfels']
			@address.address = 'Burgrain 37'
			@address.location = '8706 Meilen'
			@address.fax = ['041 254 33 34']
			@address.type = 'at_work'

			@address.replace_with(other)

			assert_equal('Herrn Dr. med.', @address.title)
			assert_equal('Walter Hugentobler', @address.name)
			assert_equal([], @address.additional_lines)
			assert_equal('Schürmattstrasse 4b', @address.address)
			assert_equal('8706 Meilen', @address.location)
			assert_equal(['041 154 32 64'], @address.fon)
			assert_equal(['041 254 32 64'], @address.fax)
			assert_equal('SO', @address.canton)
			assert_equal('at_praxis', @address.type)
		end
	end
end
