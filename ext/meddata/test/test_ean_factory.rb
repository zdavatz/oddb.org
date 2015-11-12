#!/usr/bin/env ruby
# -- oddb -- 07.02.2005 -- jlang@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path('../../../src', File.dirname(__FILE__))

require 'ean_factory'
gem 'minitest'
require 'minitest/autorun'

module ODDB
	module MedData
		class EanFactoryTest <Minitest::Test
			def test_next
				factory = EanFactory.new('7601001')
				assert_equal('7601001', factory.next)
				assert_equal('7601002', factory.next)
				assert_equal('7601003', factory.next)
			end
			def test_clarify
				factory = EanFactory.new('7601001', 10)
				assert_equal('7601001', factory.next)
				assert_equal('76010010', factory.clarify)
				assert_equal('760100100', factory.clarify)
				## add checksum
				assert_equal('7601001001', factory.clarify)
				## call next
				assert_equal('760100101', factory.clarify)
			end
			def test_clarify__next_level
				factory = EanFactory.new('7601001')
				assert_equal('7601001', factory.next)
				assert_equal('76010010', factory.clarify)
				8.times { factory.next }
				assert_equal('76010019', factory.next)
				assert_equal('7601002', factory.next)
			end
		end
	end
end
