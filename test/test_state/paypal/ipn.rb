#!/usr/bin/env ruby
# State::PayPal::TestIpn -- ODDB -- 29.04.2005 -- hwyss@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/paypal/ipn'
require 'flexmock'

module ODDB
	module State
		module PayPal
class Ipn 
	def initialize(*args)
		## disable init...
	end
end
class TestIpn < Test::Unit::TestCase
	def setup
		@state = Ipn.new
	end
	def test_format_invoice
		lookandfeel = FlexMock.new
		lookandfeel.mock_handle(:lookup) { |key| key.to_s }
		item1 = FlexMock.new
		item1.mock_handle(:quantity) { 1 }
		item1.mock_handle(:text) { 'fshort' }
		item1.mock_handle(:total_netto) { 12 }
		item2 = FlexMock.new
		item2.mock_handle(:quantity) { 12 }
		item2.mock_handle(:text) { 'a_longer_filename' }
		item2.mock_handle(:total_netto) { 144 }
		invoice = FlexMock.new
		invoice.mock_handle(:items) { { 1 => item1, 2 => item2 } }
		invoice.mock_handle(:total_netto) { 156 }
		invoice.mock_handle(:vat) { 15.6 }
		invoice.mock_handle(:total_brutto) { 171.6 }
		result = @state.format_invoice(invoice, lookandfeel)
		expected = <<-EOS
invoice_origin

==================================
 1 x fshort             EUR  12.00
12 x a_longer_filename  EUR 144.00
----------------------------------
     total_netto        EUR 156.00
----------------------------------
     vat                EUR  15.60
==================================
     total_brutto       EUR 171.60
==================================
		EOS
		assert_equal(expected, result, [expected, result].join("\n<->\n"))
	end
end
		end	
	end
end
