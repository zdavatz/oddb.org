#!/usr/bin/env ruby
# TestFiPDFExporter -- ODDB -- 18.02.2004 -- hwyss@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'plugin/fipdf'

module ODDB
	class TestFachinfoProxy < Test::Unit::TestCase
		class StubRegistration
			attr_accessor :generic_type
			attr_accessor :company_name
			attr_accessor		:sequences
			
			def initialize(generic_type = nil)
				@generic_type = generic_type
			end
		end
		class StubSequence
			attr_accessor :substances
		end
		class StubFachinfo
			attr_accessor :de
			def method_missing(symbol, *args)
				[self.class, symbol].join(':')
			end
		end
		class StubFachinfoDocument
			def method_missing(symbol, *args)
				[self.class, symbol].join(':')
			end
		end
		def setup
			@fachinfo = StubFachinfo.new
			@fachinfo_document = StubFachinfoDocument.new
			@fachinfo.de = @fachinfo_document
			@proxy = FiPDFExporter::FachinfoProxy.new(@fachinfo)
		end
		def test_undumpable
			assert_raises(TypeError) {
				Marshal.dump(@proxy)
			}
		end
		def test_dual_delegator
			fi_name = @fachinfo.class.to_s
			fi_doc_name = @fachinfo_document.class.to_s
			assert_equal("#{fi_name}:company_name", @proxy.company_name)
			assert_equal("#{fi_name}:generic_type", @proxy.generic_type)
			assert_equal("#{fi_name}:substance_names", @proxy.substance_names)
			assert_equal("#{fi_doc_name}:name", @proxy.name)
			assert_equal("#{fi_doc_name}:each_chapter", @proxy.each_chapter)
		end
	end
end
