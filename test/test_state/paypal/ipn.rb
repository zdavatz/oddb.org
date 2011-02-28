#!/usr/bin/env ruby
# State::PayPal::TestIpn -- ODDB -- 29.04.2005 -- hwyss@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
#require 'state/paypal/ipn'
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
		lookandfeel.should_receive(:lookup).and_return { |key| key.to_s }
		item1 = FlexMock.new
		item1.should_receive(:quantity).and_return { 1 }
		item1.should_receive(:text).and_return { 'fshort' }
		item1.should_receive(:total_netto).and_return { 12 }
		item2 = FlexMock.new
		item2.should_receive(:quantity).and_return { 12 }
		item2.should_receive(:text).and_return { 'a_longer_filename' }
		item2.should_receive(:total_netto).and_return { 144 }
		invoice = FlexMock.new
		invoice.should_receive(:items).and_return { { 1 => item1, 2 => item2 } }
		invoice.should_receive(:total_netto).and_return { 156 }
		invoice.should_receive(:vat).and_return { 15.6 }
		invoice.should_receive(:total_brutto).and_return { 171.6 }
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
