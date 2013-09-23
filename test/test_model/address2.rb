#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestAddress2 -- oddb.org -- 27.12.2011 -- mhatakeyama@ywesee.com
# ODDB::TestAddress2 -- oddb.org -- 28.07.2005 -- jlang@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'model/address'

module ODDB
	class TestAddress2 <Minitest::Test
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
		def test_street__5
			@address.address = 'Bakerstreet 221a'
			assert_equal('Bakerstreet', @address.street)
			assert_equal('221a', @address.number)
		end
		def test_street__2
			@address.address = '13, Champs Elysees'
			assert_equal('Champs Elysees', @address.street)
			assert_equal('13', @address.number)
		end
		def test_location__1
			@address.location = '8000 Zurich'
			assert_equal('8000', @address.plz)
			assert_equal('Zurich', @address.city)
		end
		def test_location__2
			@address.location = 'Zurich'
			assert_equal('Zurich', @address.city)
			assert_nil(@address.plz)
		end
		def test_location__3
			@address.location = 'CH-8006 Zurich'
			assert_equal('Zurich', @address.city)
			assert_equal('8006', @address.plz)
		end
		def test_location__4
			@address.location = '6330 Cham 2'
			assert_equal('Cham 2', @address.city)
			assert_equal('6330', @address.plz)
		end
    def test_location_canton
      @address.location = '6330 Cham 2'
      @address.canton = 'ZG'
      assert_equal('6330 Cham 2 (ZG)', @address.location_canton)
    end
		def test_lines__1
			@address.title = 'Herrn Dr. med.'
			@address.name = 'Werner Blaumacher'
			@address.additional_lines = ['Arztpraxis', 
			'Praxisgemeinschaft Steinfels']
			@address.address = 'Burgweg 28'
			@address.location = '8706 Meilen'

			expected = [
				'Herrn Dr. med.',
				'Werner Blaumacher',
				'Arztpraxis',
				'Praxisgemeinschaft Steinfels',
				'Burgweg 28',
				'8706 Meilen',
			]
			assert_equal(expected, @address.lines)
		end
		def test_lines__2
			@address.title = 'Herrn Dr. med.'
			@address.name = 'Werner Blaumacher'
			@address.additional_lines = ['Arztpraxis']
			@address.address = 'Burgweg 28'
			@address.location = '8706 Meilen'

			expected = [
				'Herrn Dr. med.',
				'Werner Blaumacher',
				'Arztpraxis',
				'Burgweg 28',
				'8706 Meilen',
			]
			assert_equal(expected, @address.lines)
		end
		def test_replace_with
			other = Address2.new
			other.title = 'Herrn Dr. med.'
			other.name = 'Werner Blaumacher'
			other.address = 'Schurmattstrasse 4b'
			other.location = '8706 Meilen'
			other.fon = ['041 154 32 64']
			other.fax = ['041 254 32 64']
			other.canton = 'SO'
			other.type = 'at_praxis'

			@address.name = 'Walter F. Hugentobler'
			@address.additional_lines = ['Arztpraxis', 
				'Praxisgemeinschaft Steinfels']
			@address.address = 'Burgweg 28'
			@address.location = '8706 Meilen'
			@address.fax = ['041 254 33 34']
			@address.type = 'at_work'

			@address.replace_with(other)

			assert_equal('Herrn Dr. med.', @address.title)
			assert_equal('Werner Blaumacher', @address.name)
			assert_equal([], @address.additional_lines)
			assert_equal('Schurmattstrasse 4b', @address.address)
			assert_equal('8706 Meilen', @address.location)
			assert_equal(['041 154 32 64'], @address.fon)
			assert_equal(['041 254 32 64'], @address.fax)
			assert_equal('SO', @address.canton)
			assert_equal('at_praxis', @address.type)
		end
    def test_search_terms
      @address.title = 'Herrn Dr. med.'
      @address.name = 'Werner Blaumacher'
      @address.additional_lines = [ 'Arztpraxis', 
      'Praxisgemeinschaft Steinfels' ]
      @address.address = 'Burgweg 28'
      @address.location = '8706 Meilen'
      expected = [
        'Werner Blaumacher',
        'Arztpraxis',
        'Praxisgemeinschaft Steinfels',
        'Burgweg 28',
        '8706 Meilen',
        'Meilen',
        '8706',
      ]
      assert_equal(expected, @address.search_terms)
    end
    def test_ydim_lines
      @address.title = 'Herrn Dr. med.'
      @address.name = 'Werner Blaumacher'
      @address.additional_lines = [ 'Arztpraxis', 
      'Praxisgemeinschaft Steinfels' ]
      @address.address = 'Burgweg 28'
      @address.location = '8706 Meilen'
      expected = [
        'Burgweg 28',
        'Arztpraxis',
        'Praxisgemeinschaft Steinfels',
      ]
      assert_equal(expected, @address.ydim_lines)
    end
    def test_compare
      @address.title = 'Herrn Dr. med.'
      @address.name = 'Werner Blaumacher'
      @address.additional_lines = [ 'Arztpraxis', 
        'Praxisgemeinschaft Steinfels' ]
      @address.address = 'Burweg 28'
      @address.location = '8706 Meilen'
      other = Address2.new
      other.title = 'Frau Dr. med.'
      other.name = 'Waltraud Hotzenkocherle'
      other.additional_lines = [ 'Arztpraxis', 
        'Praxisgemeinschaft Steinfels' ]
      other.address = 'Burgweg 28'
      other.location = '8706 Meilen'
      assert_equal([other, @address], [@address, other].sort)
    end
	end
  class TestAddressObserver <Minitest::Test
    class Observer
      include AddressObserver
      def initialize
        @addresses = []
      end
    end
    def setup
      @observer = Observer.new
      @address1 = @observer.create_address
      @address2 = @observer.create_address
    end
    def test_address
      assert_equal @address1, @observer.address(0)
      assert_equal @address2, @observer.address(1)
      assert_equal @address1, @observer.address('0')
      assert_equal @address2, @observer.address('1')
      assert_nil @observer.address(2)
      assert_nil @observer.address('2')
    end
    def test_address_item
      @address1.name = 'A Name'
      @address2.name = 'Another Name'
      @address2.address = 'The First Line'
      assert_equal 'A Name', @observer.address_item(:name, 0)
      assert_equal 'Another Name', @observer.address_item(:name, 1)
      assert_equal 'The First Line', @observer.address_item(:address, 1)
    end
    def test_ydim_address_lines
      @address2.title = 'Herrn Dr. med.'
      @address2.name = 'Werner Blaumacher'
      @address2.additional_lines = [ 'Arztpraxis', 
        'Praxisgemeinschaft Steinfels' ]
      @address2.address = 'Burgweg 28'
      @address2.location = '8706 Meilen'
      expected = [
        'Burgweg 28',
        'Arztpraxis',
        'Praxisgemeinschaft Steinfels',
      ]
      assert_equal(expected, @observer.ydim_address_lines(1))
    end
    def test_ydim_location
      @address2.title = 'Herrn Dr. med.'
      @address2.name = 'Werner Blaumacher'
      @address2.additional_lines = [ 'Arztpraxis', 
        'Praxisgemeinschaft Steinfels' ]
      @address2.address = 'Burgweg 28'
      @address2.location = '8706 Meilen'
      assert_equal('8706 Meilen', @observer.ydim_location(1))
    end
  end
end
