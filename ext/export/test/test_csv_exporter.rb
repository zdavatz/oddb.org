#!/usr/bin/env ruby
# encoding: utf-8
# Odba::Exporter::TestCsvExporter -- oddb.org -- 08.12.2012 -- mhatakeyama@ywesee.com
# Odba::Exporter::TestCsvExporter -- oddb.org -- 26.08.2005 -- hwyss@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path('../../../src', File.dirname(__FILE__))
$: << File.expand_path('../../../test', File.dirname(__FILE__))


require 'minitest/autorun'
require 'odba_exporter'
require 'model/analysis/group'
require 'model/doctor'
require 'stub/odba'
require 'model/limitationtext'
require 'flexmock/minitest'
require 'tempfile'

module ODDB
	module OdbaExporter
		class TestCsvExporter <Minitest::Test
			def setup
        dbi = flexmock('dbi', :dbi_args => ['dbi_args'])
        flexmock(ODBA.storage, 
                 :dbi => dbi,
                 :update_max_id => 'update_max_id'
                )
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
				@doc.language="französisch"
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
7601000616715;1998;Herrn;Dr. med;Fabrice;Dami;false;at_work;\"\";\"\";Foobodenstrasse 1;1234;Neuchâtel;NE;fon1,fon2;\"\";amig@amig.ch;französisch;Kardiologie,Psychokardiologie
				CSV
				fh = Tempfile.new('foo')
				CsvExporter.dump(CsvExporter::DOCTOR, @doc, fh)
        assert_equal(expected, IO.read(fh))
			end
			def test_dump_2
				@addr.type = 'at_praxis'
				@doc.praxis = true
				expected = <<-CSV
7601000616715;1998;Herrn;Dr. med;Fabrice;Dami;true;at_praxis;\"\";\"\";Foobodenstrasse 1;1234;Neuchâtel;NE;fon1,fon2;\"\";amig@amig.ch;französisch;Kardiologie,Psychokardiologie
				CSV
				fh = Tempfile.new('foo')
				CsvExporter.dump(CsvExporter::DOCTOR, @doc, fh)
        assert_equal(expected, IO.read(fh))
			end
			def test_dump_3
				expected = <<-CSV
8600;00;9300.00;Test de;Teste fr;Fussnote;FRussnote;Taxen;Taxes;Limit;LimitFR;Titel;Titre;C,I;30;n;{teiliste}:{spital},{list1}:{blabla};{list1}:{blabla}
				CSV
				fh = Tempfile.new('foo')
				CsvExporter.dump(CsvExporter::ANALYSIS, @pos, fh)
				assert_equal(expected, IO.read(fh))
			end
      def test_compress_many_with_one_file
        expected = <<-CSV
8600;00;9300.00;Test de;Teste fr;Fussnote;FRussnote;Taxen;Taxes;Limit;LimitFR;Titel;Titre;C,I;30;n;{teiliste}:{spital},{list1}:{blabla};{list1}:{blabla}
        CSV
        fh = Tempfile.new('foo')
        CsvExporter.dump(CsvExporter::ANALYSIS, @pos, fh)
        assert_equal(expected, IO.read(fh))
        export_dir = File.join(File.dirname(fh.path), 'export')
        out_name = 'test_tar'
        FileUtils.rm_rf(export_dir) if File.exist?(export_dir)
        OdbaExporter.compress_many(export_dir, out_name, [fh.path])
        assert_equal(true, File.exist?(export_dir))
        assert(File.exist?(out_name + '.zip'))
        assert(File.exist?(out_name + '.tar.gz'))
        assert(File.size(out_name + '.zip') > 100)
        assert(File.size(out_name + '.tar.gz') > 100)
        system("rm -rf #{export_dir}") # FileUtils.rm_f(export_dir) did not work
        assert_equal(false, File.exist?(export_dir))
      end

      def test_compress_many_with_several_files
        expected1 = 'Some dumy content for my first file, which should be at least 100 chars long'
        expected2 = 'Some dumy content for my second file, which should be at least 100 chars long'
        fh1 = Tempfile.new('file_1')
        File.open(fh1.path, 'w+') {|f| f.write expected1}
        assert_equal(expected1, IO.read(fh1))
        fh2 = Tempfile.new('file_2')
        File.open(fh2.path, 'w+') {|f| f.write expected2}
        assert_equal(expected2, IO.read(fh2))

        export_dir = File.join(File.dirname(fh1.path), 'export')
        out_name = 'test_tar'
        FileUtils.rm_rf(export_dir) if File.exist?(export_dir)
        OdbaExporter.compress_many(export_dir, out_name, [fh1.path, fh2.path])
        assert_equal(true, File.exist?(export_dir))
        assert(File.exist?(out_name + '.zip'))
        assert(File.exist?(out_name + '.tar.gz'))
        assert(File.size(out_name + '.zip') > 100)
        assert(File.size(out_name + '.tar.gz') > 100)
        # TODO: Check content of zip and tar file

        system("rm -rf #{export_dir}") # FileUtils.rm_f(export_dir) did not work
        assert_equal(false, File.exist?(export_dir))
      end
		end
	end
end
