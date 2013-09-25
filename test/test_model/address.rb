#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestAddress -- oddb.org -- 07.07.2011 -- mhatakeyama@ywesee.com 
# ODDB::TestAddress -- oddb.org -- 24.02.2003 -- jlang@ywesee.com, usenguel@ywesee.com 

$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'model/address'

module ODDB
	class TestAddress <Minitest::Test
    include FlexMock::TestCase
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
		def test_street__1
			@address.lines = [
				'Herrn Dr. med.',
				'Rolf Hugentobler',
				'Arztpraxis',
				'Stichweg 8',
				'5024 Kuettigen',
			]
			assert_equal('Stichweg', @address.street)
			assert_equal('8', @address.number)
		end
		def test_street__2
			@address.lines = [
				'Ospedale San Giovanni',
				'6500 Bellinzona' 
			]
			assert_equal('Ospedale San Giovanni', @address.street)
			assert_nil(@address.number)
		end
		def test_street__3
			@address.lines = [
				'Herrn Dr. med.',
				'Johannes Andreas Blum',
				'Arztpraxis',
				'Schweiz. Tropeninstitut Basel',
				'Socinstr. 57, Postfach',
				'4002 Basel',
			]
			assert_equal('Socinstr.', @address.street)
			assert_equal('57', @address.number)
		end
		def test_street__4
			@address.lines = [
				'Madame le Docteur',
				'Verena Schweizer-Rohrer',
				'Cabinet medical',
				'4, rte d\'Arnier',
				'1092 Belmont-Lausanne',
			]
			assert_equal('rte d\'Arnier', @address.street)
			assert_equal('4', @address.number)
		end
		def test_street__5
			@address.lines = [
				'Herrn Dr. med.',
				'Bernhard Hugentobler',
				'Arztpraxis',
				'Muhlernstr. 244A',
				'3098 Schliern b. Koenitz',
			]
			assert_equal('Muhlernstr.', @address.street)
			assert_equal('244A', @address.number)
		end
		def test_street__5_lines_hack
			@address.lines = [
				'Herrn Dr. med.',
				'Bernhard Hugentobler',
				'Arztpraxis',
				'Muhlernstr. 244A',
				'3098 Schliern b. Koenitz',
				'',
			]
			assert_equal('Muhlernstr.', @address.street)
			assert_equal('244A', @address.number)
		end
		def test_plz_city
			@address.lines = [
				'Herrn Dr. med.',
				'Bernhard Hugentobler',
				'Arztpraxis',
				'Muhlernstr. 244A',
				'3098 Schliern b. Koenitz',
			]
			assert_equal('Schliern b. Koenitz', @address.city)
			assert_equal('3098', @address.plz)
		end
		def test_plz_city_lines_hack
			@address.lines = [
				'Herrn Dr. med.',
				'Bernhard Hugentobler',
				'Arztpraxis',
				'Muhlernstr. 244A',
				'3098 Schliern b. Koenitz',
				'',
			]
			assert_equal('Schliern b. Koenitz', @address.city)
			assert_equal('3098', @address.plz)
		end
    def test_search_terms
      expected = []
      assert_equal expected, @address.search_terms
    end
    def test_compare
      address = ODDB::Address.new
      assert_equal(0, @address <=> address)
      address.lines = ['line']
      assert_equal(-1, @address <=> address)
      @address.lines = ['line','line']
      assert_equal(1, @address <=> address)
    end
	end
  class TestAddress2 <Minitest::Test
    include FlexMock::TestCase
    def setup
      @address = ODDB::Address2.new
    end
    def test_city
      @address.location = 'location'
      assert_equal('location', @address.city)
    end
    def test_replace_with
      other = ODDB::Address2.new
      other.name = 'name'
      @address.replace_with(other)
      assert_equal('name', @address.name)
    end
    def test_location_canton
      @address.location = 'location'
      assert_equal('location', @address.location_canton)
      @address.canton = 'canton'
      assert_equal('location (canton)', @address.location_canton)
    end
    def test_lines_without_title
      @address.location = 'location'
      @address.name = 'name'
      @address.address = 'address'
      expected = ["name", "address", "location"]
      assert_equal(expected, @address.lines_without_title)
    end
    def test_lines
      @address.title = 'title'
      @address.location = 'location'
      @address.name = 'name'
      @address.address = 'address'
      expected = ["title", "name", "address", "location"]
      assert_equal(expected, @address.lines)
    end
    def test_number
      @address.address = '12345, '
      assert_equal('12345', @address.number)
    end
    def test_plz
      @address.location = '1234location5678'
      assert_equal('1234', @address.plz)
    end
    def test_search_terms
      assert_equal([], @address.search_terms)
    end
    def test_street
      @address.address = 'street, 123'
      assert_equal('street', @address.street)
    end
    def test_ydim_lines
      @address.address = 'address'
      @address.additional_lines = ['line']
      expected = ["address", "line"]
      assert_equal(expected, @address.ydim_lines)
    end
    def test_compare
      address = ODDB::Address2.new
      lines1 = []
      lines2 = []
      flexmock(@address, :lines => lines2)
      flexmock(address, :lines => lines1)
      assert_equal(0, @address <=> address)
    end
  end
  class StubAddressObserver
    include AddressObserver
  end
  class TestAddressObserver <Minitest::Test
    include FlexMock::TestCase
    def setup
      @observer = ODDB::StubAddressObserver.new
    end
    def test_address
      @observer.addresses = ['address']
      assert_equal('address', @observer.address(0))
    end
    def test_address_item
      address = flexmock('address', :key => 'key')
      @observer.addresses = [address]
      assert_equal('key', @observer.address_item(:key, 0))
    end
    def test_create_address
      @observer.addresses = []
      assert_kind_of(ODDB::Address2, @observer.create_address)
    end
    def test_ydim_address_lines
      address = flexmock('address', :ydim_lines => 'ydim_lines')
      @observer.addresses = [address]
      assert_equal('ydim_lines', @observer.ydim_address_lines)
    end
    def test_ydim_location
      address = flexmock('address', :location => 'location')
      @observer.addresses = [address]
      assert_equal('location', @observer.ydim_location)
    end
  end
  class TestAddressSuggestion <Minitest::Test
    include FlexMock::TestCase
    def setup
      flexmock(ODBA.cache, :next_id => 123)
      @suggestion = ODDB::AddressSuggestion.new
    end
    def test_init
      pointer = flexmock('pointer', :append => 'append')
      @suggestion.instance_eval('@pointer = pointer')
      assert_equal('append', @suggestion.init)
    end
  end
end # ODDB
