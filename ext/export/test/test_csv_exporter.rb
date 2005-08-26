#!/usr/bin/env ruby
# Odba::Exporter::TestCsvExporter -- oddb -- 26.08.2005 -- hwyss@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path('../../../src', File.dirname(__FILE__))
$: << File.expand_path('../../../test', File.dirname(__FILE__))

require 'test/unit'
require 'csv_exporter'
require 'model/doctor'
require 'stub/odba'

module ODDB
	module OdbaExporter
		class TestCsvExporter < Test::Unit::TestCase
			def setup
				@addr = Address2.new
				@addr.address = "Foobodenstrasse 1"
				@addr.type = 'at_work'
				@addr.location = "1234 Neuchâtel"
				@addr.canton = 'NE'
				@addr.fon = ['fon1', 'fon2']
				@addr.fax = []
				@doc = Doctor.new
				@doc.title = "Dr. med" 
				@doc.exam="1998"
				@doc.addresses=[@addr]
				@doc.salutation="Herrn"
				@doc.name="Dami"
				@doc.email="amig@amig.ch"
				@doc.ean13="7601000616715"
				@doc.language="franz\366sisch"
				@doc.firstname="Fabrice"
				@doc.praxis=false
			end
			def test_dump_1
				expected = <<-CSV
7601000616715;1998;Herrn;Dr. med;Fabrice;Dami;false;at_work;Foobodenstrasse 1;1234 Neuchâtel;NE;fon1,fon2;;amig@amig.ch;französisch
				CSV
				fh = ''
				CsvExporter.dump(CsvExporter::DOCTOR, @doc, fh)
				assert_equal(expected, fh)
			end
			def test_dump_2
				@addr.type = 'at_praxis'
				@doc.praxis = true
				expected = <<-CSV
7601000616715;1998;Herrn;Dr. med;Fabrice;Dami;true;at_praxis;Foobodenstrasse 1;1234 Neuchâtel;NE;fon1,fon2;;amig@amig.ch;französisch
				CSV
				fh = ''
				CsvExporter.dump(CsvExporter::DOCTOR, @doc, fh)
				assert_equal(expected, fh)
			end
		end
	end
end
