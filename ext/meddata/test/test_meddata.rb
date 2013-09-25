#!/usr/bin/env ruby
# ODDB::TestMedData -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com
# ODDB::MedDataTest -- oddb.org -- 26.11.2004 -- jlang@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))
$: << File.expand_path("../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'meddata'

module ODDB
	class TestMedData <Minitest::Test
    include FlexMock::TestCase
		def test__dispatch
			str = MedData::Result
			instance = str.new('bar', 'baz')
			assert_equal('bar', instance.values)
			assert_equal('baz', instance.ctl)
		end
    def test_session
      ODDB::MedData.session do |search_type|
        assert_kind_of(ODDB::MedData::DRbSession, search_type)
      end
    end
	end
end
