#!/usr/bin/env ruby
# Odba::Exporter::TestCsvExporter -- oddb -- 26.08.2005 -- hwyss@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path('../../../src', File.dirname(__FILE__))
$: << File.expand_path('../../../test', File.dirname(__FILE__))

require 'test/unit'
require 'csv_exporter'
require 'model/analysis/group'
require 'model/doctor'
require 'stub/odba'
require 'model/limitationtext'

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
				@doc.specialities = ['Kardiologie', 'Psychokardiologie']
				@group = Analysis::Group.new('8600')
				@pos = @group.create_position('00')
				@pos.anonymousgroup = '9300'
				@pos.anonymouspos = '00'
				@pos.finding = 'n'
				@pos.descriptions['de'] = 'Test de'
				@pos.descriptions['fr'] = 'Teste fr'
				footnote = @pos.create_footnote
				footnote.descriptions.store('de', "Fussnote")
				footnote.descriptions.store('fr', "FRussnote")
				taxnote = @pos.create_taxnote
				taxnote.descriptions.store('de','Taxen')
				taxnote.descriptions.store('fr','Taxes')
				list_title = @pos.create_list_title
				list_title.descriptions.store('de', 'Titel')
				list_title.descriptions.store('fr', 'Titre')
				limitation_text = @pos.create_limitation_text
				limitation_text.descriptions.store('de','Limit')
				limitation_text.descriptions.store('fr','LimitFR')
				permissions = @pos.create_permissions
				perm1 = Analysis::Permission.new('teiliste','spital')
				perm2 = Analysis::Permission.new('list1','blabla')
				perm3 = Analysis::Permission.new('list1','blabla')
				permissions.descriptions.store('de', [perm1, perm2])	
				permissions.descriptions.store('fr', [perm3])
				@pos.taxpoints = 30
				@pos.lab_areas = ['C','I']
			end
			def test_dump_1
				expected = <<-CSV
7601000616715;1998;Herrn;Dr. med;Fabrice;Dami;false;at_work;"";"";Foobodenstrasse 1;1234;Neuchâtel;NE;fon1,fon2;"";amig@amig.ch;französisch;Kardiologie,Psychokardiologie
				CSV
				fh = ''
				CsvExporter.dump(CsvExporter::DOCTOR, @doc, fh)
				assert_equal(expected, fh)
			end
			def test_dump_2
				@addr.type = 'at_praxis'
				@doc.praxis = true
				expected = <<-CSV
7601000616715;1998;Herrn;Dr. med;Fabrice;Dami;true;at_praxis;"";"";Foobodenstrasse 1;1234;Neuchâtel;NE;fon1,fon2;"";amig@amig.ch;französisch;Kardiologie,Psychokardiologie
				CSV
				fh = ''
				CsvExporter.dump(CsvExporter::DOCTOR, @doc, fh)
				assert_equal(expected, fh)
			end
			def test_dump_3
				expected = <<-CSV
8600;00;9300.00;Test de;Teste fr;Fussnote;FRussnote;Taxen;Taxes;Limit;LimitFR;Titel;Titre;C,I;30;n;{teiliste}:{spital},{list1}:{blabla};{list1}:{blabla}
				CSV
				fh = ''
				CsvExporter.dump(CsvExporter::ANALYSIS, @pos, fh)
				#puts fh.inspect
				assert_equal(expected, fh)
			end
		end
	end
end
