#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::OdbaExporter::TestTable, TestLine -- oddb.org -- 08.12.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path('../../../src', File.dirname(__FILE__))
$: << File.expand_path('../../..', File.dirname(__FILE__))
$: << File.expand_path('../../../test', File.dirname(__FILE__))

require 'stub/odba'
require 'test/unit'
require 'flexmock'
require 'oddbdat'
require 'model/package'
require 'model/text'
require 'date'


# This definition is called in TestMCMTable
class String
  def src
    self + ".src"
  end
end

module ODBA
  class DbiStub
    def dbi_args
      ['dbi_args']
    end
  end
  class StorageStub
    def dbi
      DbiStub.new
    end
    def update_max_id(id)
      'update_max_id'
    end
  end
end
module ODDB
  module OdbaExporter
    DATE = Date.today.strftime("%Y%m%d%H%M%S")
    # Tests for *Line classes
    class TestLine < Test::Unit::TestCase
      Line::LENGTH = 3
      def setup
        @line = Line.new
      end
      def test_content
        assert_equal([], @line.content(nil))
        structure = {1=>"1", 2=>"2", 3=>"3"}
        assert_equal(["1", "2", "3"], @line.content(structure))
      end
      def test_empty?
        assert_equal(true, @line.empty?)
      end
      def test_structure
        assert_equal(nil, @line.structure)
      end
      def test_to_s
        assert_equal('', @line.to_s)
      end
    end
    class TestAcLine < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        @package = ODDB::Package.new('12')
        @registration = flexmock('registration') do |mock|
          mock.should_receive(:generic_type).and_return(:generic)
          #mock.should_receive(:registration_date).and_return(Date.today)
          mock.should_receive(:registration_date).and_return(Date.new(2011,2,3))
        end
        @package.sequence = flexmock('sequence') do |seq|
          seq.should_receive(:registration).and_return @registration
          seq.should_receive(:iksnr).and_return('12345')
        end
        @package.create_sl_entry 
        @package.sl_entry.limitation = 'limitation'
        @package.sl_entry.limitation_points = 5
        flexstub(@package).should_receive(:oid).and_return(123)
        flexstub(Date).should_receive(:"today.strftime").and_return('20110203000000')
        @acline = AcLine.new(@package)
      end
      def test_generic_code
        assert_equal('Y', @acline.generic_code(@registration))
      end
      def test_iks_date
        expected = '20110203'
        assert_equal(expected, @acline.iks_date(@registration))
      end
      def test_ikskey
        assert_equal('12345012', @acline.ikskey)
      end
      def test_inscode
        assert_equal('1', @acline.inscode)
      end
      def test_limitation
        assert_equal('Y', @acline.limitation)
      end
      def test_limitation_points
        assert_equal(5, @acline.limitation_points)
      end
      def test_structure
        expected = {
          1 =>"01",
          2 =>"20110203000000",
          3 =>"1",
          4 =>123,
          5 =>"4",
          7 =>"12345012",
          14=>nil,
          20=>"Y",
          22=>"20110203",
          29=>"3",
          32=>nil,
          39=>"1",
          40=>"Y",
          41=>5,
          47=>nil,
        }

        # test
        assert_equal(expected.sort, @acline.structure.sort)
      end
    end
    class TestAccompLine < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_structure
        package = ODDB::Package.new('12')
        flexstub(package).should_receive(:oid).and_return(123)
        registration = flexmock('registration') do |mock|
          mock.should_receive(:company).and_return(flexmock('compay') do |comp|
            comp.should_receive(:oid).and_return(111)
          end)
        end
        package.sequence = flexmock('sequence') do |seq|
          seq.should_receive(:registration).and_return registration
          seq.should_receive(:iksnr).and_return('12345')
        end
        flexstub(Date).should_receive(:"today.strftime").and_return('20110203000000')
        @accompline = AccompLine.new(package)
        expected = {
          1=>"19", 
          2=>"20110203000000", 
          3=>123, 
          4=>111,
          5=>"H", 
          6=>"4", 
        }
        assert_equal(expected.sort, @accompline.structure.sort)
      end
    end
    class TestAcLimLine < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_structure
        flexstub(Date).should_receive(:"today.strftime").and_return('20110203000000')
        @aclimline = AcLimLine.new(111, 222, 333)
        expected = {
          1=>"09", 
          2=>"20110203000000", 
          3=>111, 
          4=>333,
          5=>222, 
          6=>"4", 
        }
        assert_equal(expected.sort, @aclimline.structure.sort)
      end
    end
    class TestAcnamLine < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        @package = ODDB::Package.new('12')
        @package.sequence = flexmock('sequence') do |seq|
          seq.should_receive(:galenic_forms).and_return(['galenic_forms'])
          seq.should_receive(:dose).and_return(flexmock('dose') do |dose|
            dose.should_receive(:is_a?).and_return(true)
            dose.should_receive(:qty).and_return('qty')
            dose.should_receive(:unit).and_return('unit')
          end)
          seq.should_receive(:name).and_return('name')
          seq.should_receive(:name_base).and_return('name_base')
          seq.should_receive(:name_descr).and_return('name_descr')
        end
        flexstub(Date).should_receive(:"today.strftime").and_return('20110203000000')
      end
      def test_structure__package_parts_nil_case
        flexstub(@package) do |pack|
          pack.should_receive(:oid).and_return(123)
          pack.should_receive(:commercial_forms).and_return(['commercial_forms'])
          pack.should_receive(:"comparable_size.qty").and_return('comparable_size.qty')
          pack.should_receive(:parts).and_return([])
        end

        @acnamline = AcnamLine.new(@package)
        expected = {
          1=>"03",
          2=>"20110203000000",
          3=>"1",
          4=>123,
          5=>"D",
          6=>"4",
          7=>"name",
          8=>"name_base",
          9=>"name_descr",
          11=>"galenic_forms",
          12=>"qty",
          13=>"unit",
          16=>"",
          17=>"commercial_forms",
          18=>"comparable_size.qty",
          19=>"commercial_forms",
        }
        assert_equal(expected.sort, @acnamline.structure.sort)
      end
      def test_structure__package_parts_not_nil_case
        count = 0
        part = flexmock('part') do |mock|
          mock.should_receive(:measure).and_return(count+=1)
          mock.should_receive(:multi).and_return('multi')
        end
        parts = [part, part, part]
        flexstub(@package) do |pack|
          pack.should_receive(:oid).and_return(123)
          pack.should_receive(:commercial_forms).and_return(['commercial_forms'])
          pack.should_receive(:"comparable_size.qty").and_return('comparable_size.qty')
          pack.should_receive(:parts).and_return(parts)
        end

        @acnamline = AcnamLine.new(@package)
        expected = {
          1=>"03",
          2=>"20110203000000",
          3=>"1",
          4=>123,
          5=>"D",
          6=>"4",
          7=>"name",
          8=>"name_base",
          9=>"name_descr",
          11=>"galenic_forms",
          12=>"qty",
          13=>"unit",
          16=>"multi",
          17=>"commercial_forms",
          18=>"comparable_size.qty",
          19=>"commercial_forms",
        }
        assert_equal(expected.sort, @acnamline.structure.sort)
      end
    end
    class TestAcmedLine < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_structure
        flexstub(Date).should_receive(:"today.strftime").and_return('20110203000000')
        package = ODDB::Package.new('12')
        flexstub(package) do |pack|
          pack.should_receive(:oid).and_return(123)
          pack.should_receive(:fachinfo).and_return(flexmock('fachinfo') do |fach|
            fach.should_receive(:oid).and_return('fachinfo.oid')
          end)
        end
        package.sequence = flexmock('sequence') do |seq|
          seq.should_receive(:atc_class).and_return(flexmock('atc_class') do |atc|
            atc.should_receive(:code).and_return('atc.code')
          end)
          seq.should_receive(:galenic_forms).and_return(flexmock('galenic_forms') do |gal|
            gal.should_receive(:first).and_return(flexmock('galform') do |form|
              form.should_receive(:oid).and_return('galform.oid')
            end)
          end)
        end
                                      
        @acmedline = AcmedLine.new(package)
        expected = {
          1=>"02",
          2=>"20110203000000",
          3=>"1",
          4=>123,
          5=>"4",
          7=>"fachinfo.oid",
          10=>"atc.code",
          12=>"galform.oid",
        }
        assert_equal(expected.sort, @acmedline.structure.sort)
      end
    end
    class TestAcOddbLine < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_structure
        package = ODDB::Package.new('12')
        flexstub(package).should_receive(:oid).and_return(123)
        package.pharmacode = 223
        @acoddbline = AcOddbLine.new(package)
        expected = {
          1 => 123,
          2 => "223"
        }
        assert_equal(expected.sort, @acoddbline.structure.sort)
      end
    end
    class TestAcpricealgPublicLine < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        @package = ODDB::Package.new('12')
        @package.price_public = 123.45
        flexstub(@package).should_receive(:oid).and_return(123)
        flexstub(Date).should_receive(:"today.strftime").and_return('20110203000000')
        @acpriceline = AcpricealgPublicLine.new(@package)
      end
      def test_price_public_type
        assert_equal('PPUB', @acpriceline.price_public_type)
        @package.create_sl_entry
        assert_equal('PSL2', @acpriceline.price_public_type)
      end
      def test_structure
        expected = {
          1=>"07", 
          2=>"20110203000000", 
          3=>123, 
          4=>"PPUB",
          5=>"4", 
          6=>"123.45", 
        }
        assert_equal(expected.sort, @acpriceline.structure.sort)
      end
   end
    class TestAcpricealgExfactoryLine < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_structure
        package = ODDB::Package.new('12')
        flexstub(package).should_receive(:oid).and_return(123)
        package.price_exfactory = 123.45
        flexstub(Date).should_receive(:"today.strftime").and_return('20110203000000')
        @acpriceline = AcpricealgExfactoryLine.new(package)
        expected = {
          1=>"07", 
          2=>"20110203000000", 
          3=>123, 
          4=>"PSL1",
          5=>"4", 
          6=>"123.45", 
        }
        assert_equal(expected.sort, @acpriceline.structure.sort)
      end
    end
    class TestAcscLine < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_structure
        # test nil case
        package = ODDB::Package.new('12')
        @acscline = AcscLine.new(package, nil, 'count')
        assert_equal(nil, @acscline.structure)

        # test not nil case
        flexstub(package).should_receive(:oid).and_return(123)
        active_agent = flexmock('active_agent') do |act|
          act.should_receive(:dose).and_return(flexmock('dose') do |dose|
            dose.should_receive(:is_a?).and_return(true)
            dose.should_receive(:qty).and_return('qty')
            dose.should_receive(:unit).and_return('unit')
          end)
          act.should_receive(:substance).and_return(flexmock('oid') do |oid|
            oid.should_receive(:oid).and_return('oid')
          end)
        end
        flexstub(Date).should_receive(:"today.strftime").and_return('20110203000000')
        @acscline =AcscLine.new(package, active_agent, 223)

        expected = {
          1=>"41",
          2=>"20110203000000",
          3=>123,
          4=>223,
          5=>"4",
          6=>"oid",
          7=>"qty",
          8=>"unit",
          9=>"W",
        }
        assert_equal(expected.sort, @acscline.structure.sort)
      end
    end
    class TestAtcLine < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_structure
        # test nil case
        @atcline = AtcLine.new(nil)
        assert_equal(nil, @atcline.structure)

        # test not nil case
        atcclass = flexmock('atcclass') do |atc|
          atc.should_receive(:code).and_return('code')
          atc.should_receive(:description).and_return('description')
        end
        flexstub(Date).should_receive(:"today.strftime").and_return('20110203000000')
        @atcline = AtcLine.new(atcclass)
        expected = {
          1=>"11",
          2=>"20110203000000",
          3=>"8",
          4=>"code",
          5=>"D",
          6=>"4",
          7=>"description",
        }
        assert_equal(expected, @atcline.structure)
      end
    end
    class TestCompLine < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_structure
        company = flexmock('company') do |comp|
          comp.should_receive(:oid).and_return('oid')
          comp.should_receive(:ean13).and_return('ean13')
          comp.should_receive(:name).and_return('name')
          comp.should_receive(:address_email).and_return('address_email')
          comp.should_receive(:url).and_return('url')
          comp.should_receive(:address).and_return(flexmock('addr') do |addr|
            addr.should_receive(:address).and_return('address')
            addr.should_receive(:plz).and_return('plz')
            addr.should_receive(:city).and_return('city')
            addr.should_receive(:"fon.first").and_return('fon.first')
            addr.should_receive(:"fax.first").and_return('fax.first')
          end)
        end
        flexstub(Date).should_receive(:"today.strftime").and_return('20110203000000')
        @compline = CompLine.new(company)
        expected = {
          1=>"12",
          2=>"20110203000000",
          3=>"oid",
          4=>"4",
          5=>"ean13",
          7=>"name",
          8=>"address",
          9=>"CH",
          10=>"plz",
          11=>"city",
          13=>"fon.first",
          15=>"fax.first",
          16=>"address_email",
          17=>"url",
        }
        assert_equal(expected.sort, @compline.structure.sort)
      end
    end
    class TestEanLine < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        packclass = flexmock('package') do |pack|
          pack.should_receive(:new).and_return(flexmock do |mock|
            mock.should_receive(:oid).and_return('oid')
            mock.should_receive(:barcode).and_return('barcode')
          end)
        end
        @package = packclass.new
        flexstub(Date).should_receive(:"today.strftime").and_return('20110203000000')
      end
      def test_barcode
        @eanline = EanLine.new(@package)
        assert_equal('barcode', @eanline.barcode)
      end
      def test_structure
        @eanline = EanLine.new(@package)
        expected = {
          1=>"06", 
          2=>"20110203000000", 
          3=>"oid", 
          4=>"E13",
          5=>"barcode", 
          6=>"4", 
        }
        assert_equal(expected, @eanline.structure)
      end
    end
    class TestGalenicFormLine < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_structure
        galenic_form = flexmock('galenic_form') do |gal|
          gal.should_receive(:oid).and_return('oid')
          gal.should_receive(:to_s).and_return('to_s')
        end
        @galenicline = GalenicFormLine.new(galenic_form)
        expected = {
          1=>"11", 
          2=>DATE, 
          3=>"5", 
          4=>"oid",
          5=>"D", 
          6=>"4", 
          7=>"to_s", 
        }
        assert_equal(expected.sort, @galenicline.structure.sort)
      end
    end
    class TestScLine < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_structure
        package = ODDB::Package.new('12')
        substance = flexmock('substance') do |sub|
          sub.should_receive(:oid).and_return('oid')
        end
        flexstub(Date).should_receive(:"today.strftime").and_return('20110203000000')
        @scline = ScLine.new(package, substance)
        expected = {
          1=>"40",
          2=>"20110203000000",
          3=>"oid",
          4=>"L",
          5=>"4",
          6=>substance,
        }
        assert_equal(expected.sort, @scline.structure.sort)
      end
    end
    class TestLimitationLine < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_structure
        flexstub(Date).should_receive(:"today.strftime").and_return('20110203000000')
        @limitationline = LimitationLine.new('lim_oid')
        expected = {
          1=>"16", 
          2=>"20110203000000", 
          3=>"lim_oid",
          5=>"4", 
          6=>"COM", 
        }
        assert_equal(expected.sort, @limitationline.structure.sort)
      end
    end
    class TestLimTxtLine < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_structure
        flexstub(Date).should_receive(:"today.strftime").and_return('20110203000000')
        @limtxtline = LimTxtLine.new('lim_oid', 'language', 'txt')
        expected = {
          1=>"10", 
          2=>"20110203000000", 
          3=>"lim_oid", 
          4=>"language",
          5=>"4", 
          6=>"txt", 
        }
        assert_equal(expected.sort, @limtxtline.structure.sort)
      end
    end
    class TestMCMLine < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_structure
        flexstub(Date).should_receive(:"today.strftime").and_return('20110203000000')
        @mcmline = MCMLine.new('fi_oid', 'line_nr', 'language', 'text')
        expected = {
          1=>"31",
          7=>"text",
          2=>"20110203000000",
          3=>"fi_oid",
          4=>"L",
          5=>"line_nr",
          6=>"4",
        }
        assert_equal(expected.sort, @mcmline.structure.sort)
      end
    end

    # Tests for *Table classes
    class TestTable < Test::Unit::TestCase
      Table::FILENAME = 'table'
      def test_filename
        table = Table.new
        assert_equal('table', table.filename)
      end
    end
    class TestAcTable < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_lines
        flexstub(AcLine).should_receive(:new).and_return('acline')
        @actable = AcTable.new
        assert_equal(['acline'], @actable.lines('package'))
      end
    end
    class TestAccompTable < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_lines
        flexstub(AccompLine).should_receive(:new).and_return('accompline')
        @accomptable = AccompTable.new
        assert_equal(['accompline'], @accomptable.lines('package'))
      end
    end
    class TestAcLimTable < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_lines
        # test package.sl_entry == nil calse
        package = ODDB::Package.new('12')
        @aclimtable = AcLimTable.new
        assert_equal([], @aclimtable.lines(package))

        # test not nil case
        ## preparation
        package.create_sl_entry
        package.sl_entry.create_limitation_text
        paragraphs = [1,2]
        chap = flexmock('chap') do |chap|
          chap.should_receive(:paragraphs).and_return(flexmock('paragraphs') do |para|
            para.should_receive(:each_with_index).and_yield(paragraphs)
          end)
        end
        package.sl_entry.limitation_text.descriptions[0] = chap
        ## test 
        assert_kind_of(ODDB::OdbaExporter::AcLimLine, @aclimtable.lines(package).first)
      end
    end
    class TestAcmedTable < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_lines
        flexstub(AcmedLine).should_receive(:new).and_return('acmedline')
        @acmedtable = AcmedTable.new
        assert_equal(['acmedline'], @acmedtable.lines('package'))
      end
    end
    class TestAcnamTable < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_lines
        flexstub(AcnamLine).should_receive(:new).and_return('acnamline')
        @acnamtable = AcnamTable.new
        assert_equal(['acnamline'], @acnamtable.lines('package'))
      end
    end
    class TestAcOddbTable < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_lines
        # test package.pharmacode nil case
        package = ODDB::Package.new('12')
        @acoddbtable = AcOddbTable.new
        assert_equal([], @acoddbtable.lines(package))

        # test not nil case
        package.pharmacode = 123
        flexstub(AcOddbLine).should_receive(:new).and_return('acoddbline')
        assert_equal(['acoddbline'], @acoddbtable.lines(package))
      end
    end
    class TestAcpricealgTable < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_lines
        flexstub(AcpricealgPublicLine).should_receive(:new).and_return('acpricepublic')
        flexstub(AcpricealgExfactoryLine).should_receive(:new).and_return('acpriceexfactory')
        @acpricetable = AcpricealgTable.new 
        assert_equal(["acpricepublic", "acpriceexfactory"], @acpricetable.lines('package'))
      end
    end
    class TestAcscTable < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_lines
        active_agents = ['act']
        package = flexmock('package') do |pack|
          pack.should_receive(:active_agents).and_return(active_agents)
        end

        # test
        flexstub(AcscLine).should_receive(:new).with(package, 'act',  0).and_return('acscline')
        @acsctable = AcscTable.new
        assert_equal(['acscline'], @acsctable.lines(package))
      end
    end
    class TestLimitationTable < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_lines
        # test package.sl_entry nil case
        package = ODDB::Package.new('12')
        @limitationtable = LimitationTable.new
        assert_equal([], @limitationtable.lines(package))

        # test not nil case
        package.create_sl_entry
        package.sl_entry.create_limitation_text
        paragraphs = ['par']
        chap = flexmock('chap') do |cha|
          cha.should_receive(:paragraphs).and_return(paragraphs)
        end
        package.sl_entry.limitation_text.descriptions[0] = chap
        flexstub(package).should_receive(:oid).and_return(123)

        # test
        flexstub(LimitationLine).should_receive(:new).with(123000).and_return('limitationline')
        assert_equal(['limitationline'], @limitationtable.lines(package))
      end
    end
    class TestLimTxtTable < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_lines
        # test package.sl_entry nil case
        package = ODDB::Package.new('12')
        @limtxttable = LimTxtTable.new
        assert_equal([], @limtxttable.lines(package))

        # test not nil case
        package.create_sl_entry
        package.sl_entry.create_limitation_text
        flexstub(package).should_receive(:oid).and_return(123)
        paragraph  = flexmock('par') do |par|
          par.should_receive(:text).and_return('text')
        end
        paragraphs = [paragraph]
        chap = flexmock('chap') do |cha|
          cha.should_receive(:paragraphs).and_return(paragraphs)
        end
        package.sl_entry.limitation_text.descriptions['lang'] = chap

        # test
        flexstub(LimTxtLine).should_receive(:new).with(123000, 'L', 'text').and_return('limtxtline')
        assert_equal(['limtxtline'], @limtxttable.lines(package))
      end
    end
    class TestEanTable < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_lines
        flexstub(EanLine).should_receive(:new).and_return('eanline')
        @eantable = EanTable.new
        assert_equal(['eanline'], @eantable.lines('package'))
      end
    end
    # The following constants are necessary for TestMCMTable
    ODDB::Text::ImageLink = 'imagelink'
    #ODDB::Text::Table = 'table'
    SERVER_NAME = 'server_name/'
    class TestMCMTable < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        @mcmtable = MCMTable.new
      end
      def test_lines
        # test fi.description empty case
        fi = flexmock('fi') do |f|
          f.should_receive(:descriptions).and_return([])
        end
        assert_equal([], @mcmtable.lines(fi))

        # test not empty case
        flexstub(MCMLine).should_receive(:new).and_return('mcmline')
        chapter = flexmock('chapter') do |chap|
          chap.should_receive(:heading).and_return('')
          chap.should_receive(:sections).and_return([])
        end
        doc = flexmock('doc') do |d|
          d.should_receive(:each_chapter).and_yield(chapter)
        end
        fi = flexmock('fi') do |f|
          f.should_receive(:descriptions).and_return({'lang', doc})
          f.should_receive(:oid).and_return('oid')
        end
        assert_equal(['mcmline'], @mcmtable.lines(fi))
      end
      def test_format_lines__sections_empty
        chapter = flexmock('chapter') do |chap|
          chap.should_receive(:heading).and_return('')
          chap.should_receive(:sections).and_return([])
        end

        assert_equal('', @mcmtable.format_line(chapter))
      end
      def test_format_lines__sections_not_empty
        format = flexmock('format') do |form|
          form.should_receive(:italic?).and_return(true)
          form.should_receive(:range).and_return(0..7)
        end
        paragraph = flexmock('paragraph') do |par|
          par.should_receive(:text).and_return('par.text')
          par.should_receive(:formats).and_return([format])
          par.should_receive(:preformatted?).and_return(true)
        end
        section = flexmock('section') do |sec|
          sec.should_receive(:subheading).and_return('subhead')
          sec.should_receive(:paragraphs).and_return([paragraph])
        end
        chapter = flexmock('chapter') do |chap|
          chap.should_receive(:heading).and_return('head')
          chap.should_receive(:sections).and_return([section])
        end

        # test
        expected = "<BI>head<E><P><I>subhead<E><I>par.text<E><P>"
        assert_equal(expected, @mcmtable.format_line(chapter))
      end
      def test_format_lines__ImageLink
        section = flexmock('section') do |sec|
          sec.should_receive(:subheading).and_return('subhead')
          sec.should_receive(:paragraphs).and_return([ODDB::Text::ImageLink])
        end
        chapter = flexmock('chapter') do |chap|
          chap.should_receive(:heading).and_return('head')
          chap.should_receive(:sections).and_return([section])
        end

        # test
        expected = "<BI>head<E><P><I>subhead<E><IMG src='http://server_name/imagelink.src'/>"
        assert_equal(expected, @mcmtable.format_line(chapter))
      end
=begin
      def test_format_lines__Table
        section = flexmock('section') do |sec|
          sec.should_receive(:subheading).and_return('subhead')
          sec.should_receive(:paragraphs).and_return([ODDB::Text::Table])
        end
        chapter = flexmock('chapter') do |chap|
          chap.should_receive(:heading).and_return('head')
          chap.should_receive(:sections).and_return([section])
        end

        # test
        expected = "<BI>head<E><P><I>subhead<E><N>table<E>"
        assert_equal(expected, @mcmtable.format_line(chapter))
      end
=end
    end
    # the followings are necessary for TestCodesTable
    AtcClass = 'atcclass'
    GalenicForm = 'galenicform'
    class TestCodesTable < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        flexstub(AtcLine).should_receive(:new).and_return('atcline')
        flexstub(GalenicFormLine).should_receive(:new).and_return('galenicformline')
        @codestable = CodesTable.new
      end
      def test_atclines
        assert_equal(['atcline'], @codestable.atclines('atcclass'))
      end
      def test_gallines
        assert_equal(['galenicformline'], @codestable.gallines('galform'))
      end
      def test_lines
        assert_equal(['atcline'], @codestable.lines(AtcClass))
        assert_equal(['galenicformline'], @codestable.lines(GalenicForm))
      end
    end
    class TestScTable < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_lines
        flexstub(ScLine).should_receive(:new).and_return('scline')
        @sctable = ScTable.new
        assert_equal(['scline'], @sctable.lines('substance'))
      end
    end
    class TestCompTable < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_lines
        flexstub(CompLine).should_receive(:new).and_return('compline')
        @comptable = CompTable.new
        assert_equal(['compline'], @comptable.lines('company'))
      end
    end
    class TestReadme < Test::Unit::TestCase
      def test_lines
        expected = <<-EOS
	oddbdat.tar.gz und oddbdat.zip enthalten die täglich aktualisierten Artikelstammdaten der ODDB. Die Daten werden von ywesee in das OddbDat-Format umgewandelt und allen gewünschten Systemlieferanten von Schweizer Spitälern zur Verfügung gestellt.

	Feedback bitte an zdavatz@ywesee.com

	-AC (Tabelle 1) - ODDB-Code
	-ACMED (Tabelle 2) - Weitere Produktinformationen
	-ACNAM (Tabelle 3) - Sprachen
	-ACBARCODE (Tabelle 6) - EAN-Artikelcode
	-ACPRICEALG (Tabelle 7) - Preise
	-ACLIM (Tabelle 9) - Limitationen
	-LIMTXT (Tabelle 10) - Limitationstexte
	-CODES (Tabelle 11) - Codebeschreibungen (ATC-Beschreibung, Galenische Form)
	-COMP (Tabelle 12) - Hersteller
	-LIMITATION (Tabelle 16) - Limitationen der SL
	-ACCOMP (Tabelle 19) - Verbindungstabelle zwischen AC und COMP
	-SC (Tabelle 40) - Substanzen
	-ACSC (Tabelle 41) - Verbindungstabelle zwischen AC und SC
	-ACODDB (Tabelle 99) - Verbindungstabelle zwischen ODDB-ID und Pharmacode

	Folgende Tabelle mit den Fachinformationen steht wegen ihrer Grösse separat als tar.gz- oder zip-Download zur Verfügung.

	-MCM (Tabelle 31)	- Fachinformationen

	Die Daten werden als oddbdat.tar.gz und oddbdat.zip auf unserem Server bereitgestellt - Vorzugsweise benutzen Sie einen der folgenden direkten Links.

	Ganze Packages (ohne Fachinformationen):
	http://www.oddb.org/resources/downloads/oddbdat.tar.gz
	http://www.oddb.org/resources/downloads/oddbdat.zip

	Nur Fachinformationen (sehr grosse Dateien):
	http://www.oddb.org/resources/downloads/s31x.tar.gz
	http://www.oddb.org/resources/downloads/s31x.zip


        EOS
        assert_equal(expected, Readme.new.lines)
      end
    end

  end
end

