$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'stub/odba'
require 'test/unit'
require 'model/package'
require 'flexmock'

module ODDB
  class Package
    public :adjust_types
  end
  class StubPackageApp
    attr_writer :generic_groups
    attr_reader :pointer, :values
    def initialize
      @generic_groups = {}
    end
    def generic_group(key)
      @generic_groups[key]
    end
    def update(pointer, values)
      @pointer, @values = pointer, values
    end
  end
  class StubPackageGenericGroup
    attr_reader :package, :removed
    def add_package(package)
      @package = package
    end
    def remove_package(package)
      @removed = true
    end
  end
  class StubPackageSequence
    attr_accessor :dose, :basename
    attr_accessor :comparables
    attr_accessor :active_packages, :registration
    def initialize
      @active_packages = []
    end
    def public_packages
      @active_packages
    end
    def iksnr
      '12345'
    end
  end
  class TestPackage < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @package = ODDB::Package.new('12')
      @package.sequence = StubPackageSequence.new
    end
    def test_initialize
      assert_equal('012', @package.ikscd)
      assert_not_nil(@package.oid)
    end
    def test_active
      assert_equal(true, @package.active?)
      @package.out_of_trade = true
      assert_equal(true, @package.active?)
      @package.refdata_override = true
      assert_equal(true, @package.active?)
      @package.market_date = Date.today + 1
      assert_equal(false, @package.active?)
      @package.market_date = Date.today
      assert_equal(true, @package.active?)
    end
    def test_active_agents
      @package.parts.push flexmock(:active_agents => ['act1', 'act2']),
                          flexmock(:active_agents => ['act3'])
      assert_equal %w{act1 act2 act3}, @package.active_agents
    end
    def test_adjust_types
      app = flexmock 'app'
      pointer = flexmock 'pointer'
      pointer.should_receive(:resolve).with(app).times(1).and_return 'generic-group'
      values = {
        :size						=>	'20 x 1,7 g',
        :descr					=>	nil,
        :ikscat					=>	'A',
        :generic_group	=>	pointer,
        :price_exfactory=>	Util::Money.new(12.34),
        :price_public		=>	Util::Money.new(15),
        :pretty_dose    =>  Dose.new(10, 'mg'),
        :ddd_dose       =>  [20, 'mg'],
      }
      expected = {
        :size						=>	'20 x 1,7 g',
        :descr					=>	nil,
        :ikscat					=>	'A',
        :generic_group	=>	'generic-group',
        :price_exfactory=>	Util::Money.new(12.34),
        :price_public		=>	Util::Money.new(15),
        :pretty_dose    =>  Dose.new(10, 'mg'),
        :ddd_dose       =>  Dose.new(20, 'mg'),
      }
      assert_equal(expected, @package.adjust_types(values, app))
    end
    def test_barcode
      assert_equal('7680123450123', @package.barcode)
    end
    def test_checkout
      group = flexmock 'generic group'
      group.should_receive(:remove_package).with(@package).times(1).and_return do
        assert true
      end
      @package.instance_variable_set '@generic_group', group
      narc1 = flexmock 'narcotic1'
      narc1.should_receive(:remove_package).with(@package).times(1).and_return do
        assert true
      end
      narc2 = flexmock 'narcotic2'
      narc2.should_receive(:remove_package).with(@package).times(1).and_return do
        assert true
      end
      @package.narcotics.push narc1, narc2
      part1 = flexmock 'part1'
      part1.should_receive(:checkout).times(1).and_return do
        assert true
      end
      part1.should_receive(:odba_delete).times(1).and_return do
        assert true
      end
      part2 = flexmock 'part1'
      part2.should_receive(:checkout).times(1).and_return do assert true end
      part2.should_receive(:odba_delete).times(1).and_return do assert true end
      @package.parts.push part1, part2
      slentry = flexmock 'sl entry'
      slentry.should_receive(:checkout).times(1).and_return do assert true end
      slentry.should_receive(:odba_delete).times(1).and_return do assert true end
      @package.instance_variable_set '@sl_entry', slentry
      @package.checkout
    end
    def test_commercial_forms
      part1 = flexmock :commercial_form => 'cf1'
      part2 = flexmock :commercial_form => 'cf2'
      @package.parts.push part1, part2
      assert_equal %w{cf1 cf2}, @package.commercial_forms
    end
    def test_company_name
      @package.sequence = nil
      assert_nil @package.company_name
      comp = flexmock :name => 'Company Name'
      seq = flexmock :company => comp
      @package.sequence = seq
      assert_equal 'Company Name', @package.company_name
    end
    def test_compositions
      part1 = flexmock :composition => 'comp1'
      part2 = flexmock :composition => 'comp2'
      @package.parts.push part1, part2
      assert_equal %w{comp1 comp2}, @package.compositions
    end
    def test_comparable_size
      part1 = flexmock :comparable_size => Dose.new(5, 'ml')
      part2 = flexmock :comparable_size => Dose.new(10, 'ml')
      @package.parts.push part1, part2
      assert_equal Dose.new(15, 'ml'), @package.comparable_size
    end
    def test_comparable_size__robust
      part1 = flexmock :comparable_size => Dose.new(5, 'ml')
      part2 = flexmock :comparable_size => Dose.new(10, 'mg')
      @package.parts.push part1, part2
      assert_equal Dose.new(15, ''), @package.comparable_size
    end
    def test_comparable_size__empty
      assert_equal [], @package.parts
      assert_equal Dose.new(0, ''), @package.comparable_size
    end
    def test_comparable?
      part1 = flexmock :comparable_size => Dose.new(5, 'ml')
      part2 = flexmock :comparable_size => Dose.new(10, 'ml')
      @package.parts.push part1, part2

      pack = ODDB::Package.new('98')
      pack.parts.push part1, part2
      seq = StubPackageSequence.new
      seq.basename = "abc"
      pack.sequence = seq

      top = @package.comparable_size * 1.25
      bottom = @package.comparable_size * 0.75
      assert(@package.comparable?(bottom, top, pack))
    end
    def test_comparable_failcase
      part1 = flexmock :comparable_size => Dose.new(5, 'ml')
      part2 = flexmock :comparable_size => Dose.new(10, 'ml')
      @package.parts.push part1, part2

      pack = ODDB::Package.new('98')
      pack.parts.push part1, part2

      top = @package.comparable_size * 1.25
      bottom = @package.comparable_size * 0.75
      # pack.basename == nil => this will be returned false
      assert_equal(false, @package.comparable?(bottom, top, pack))
    end
    def test_comparables1
      seq = StubPackageSequence.new
      seq.basename = "abc"
      pack = ODDB::Package.new('98')
      pack.sequence = seq
      part = ODDB::Part.new
      part.size = '12 Tabletten'
      pack.parts.push part
      seq.active_packages = [pack]
      @package.sequence.comparables = [seq]
      part = ODDB::Part.new
      part.size = '15 Tabletten'

      @package.parts.push part
      assert_equal([pack], @package.comparables)
    end
    def test_comparables2
      seq = StubPackageSequence.new
      pack = ODDB::Package.new('98')
      part = ODDB::Part.new
      part.size = '12 Tabletten'
      pack.parts.push part
      seq.active_packages = [pack]
      @package.sequence.comparables = [seq]
      part = ODDB::Part.new
      part.size = '200 Tabletten'
      @package.parts.push part
      assert_equal([], @package.comparables)
    end
    def test_comparables3
      seq = StubPackageSequence.new
      seq.basename = "abc"
      seqpack = ODDB::Package.new('97')
      seqpack.sequence = seq
      part = ODDB::Part.new
      part.size = '12 Tabletten'
      seqpack.parts.push part
      pack = ODDB::Package.new('98')
      pack.sequence = seq
      part = ODDB::Part.new
      part.size = '12 Tabletten'
      pack.parts.push part
      seq.active_packages = [pack]
      @package.sequence.comparables = [seq]
      @package.sequence.active_packages = [seqpack, @package]
      part = ODDB::Part.new
      part.size = '15 Tabletten'
      @package.parts.push part
      assert_equal([pack, seqpack], @package.comparables)
    end
    def test_create_part
      assert_equal [], @package.parts
      part = @package.create_part
      assert_instance_of Part, part
      assert_equal [part], @package.parts
      assert_equal @package, part.package
    end
    def test_create_sl_entry
      assert_nil(@package.sl_entry)
      @package.create_sl_entry
      assert_equal(ODDB::SlEntry, @package.sl_entry.class)
    end
    def test_ddd
      @package.sequence = nil
      assert_nil @package.ddd
      atc = flexmock :has_ddd? => true, :ddds => { 'P' => 'PDDD', 'O' => 'ODDD' }
      seq = flexmock :atc_class => atc
      @package.sequence = seq
      assert_equal 'ODDD', @package.ddd
    end
    def test_ddd_price
      group = flexmock 'galenic_group'
      group.should_receive(:match).and_return(true)
      ddd = flexmock :dose => Dose.new(20, 'mg')
      atc = flexmock :has_ddd? => true, :ddds => { 'O' => ddd }
      seq = flexmock :atc_class => atc, :galenic_group => group,
                     :dose => Dose.new(10, 'mg'), :longevity => nil
      @package.price_public = Util::Money.new(10, 'CHF')
      @package.sequence = seq
      part = flexmock :comparable_size => Dose.new(10, 'Tabletten')
      @package.parts.push part
      assert_equal Util::Money.new(2, 'CHF'), @package.ddd_price
    end
    def test_ddd_price__longevity
      group = flexmock 'galenic_group'
      group.should_receive(:match).and_return(true)
      ddd = flexmock :dose => Dose.new(20, 'mg')
      atc = flexmock :has_ddd? => true, :ddds => { 'O' => ddd }
      seq = flexmock :atc_class => atc, :galenic_group => group,
                     :dose => Dose.new(20, 'mg'), :longevity => 2
      @package.price_public = Util::Money.new(10, 'CHF')
      @package.sequence = seq
      part = flexmock :comparable_size => Dose.new(10, 'Tabletten')
      @package.parts.push part
      assert_equal Util::Money.new(1, 'CHF'), @package.ddd_price
    end
    def test_delete_part
      part = flexmock(:oid => 4)
      @package.parts.push part
      @package.delete_part 1
      assert_equal [part], @package.parts
      @package.delete_part 4
      assert_equal [], @package.parts
    end
    def test_delete_sl_entry
      @package.instance_variable_set '@sl_entry', flexmock('slentry')
      reg = flexmock :packages => [@package]
      reg.should_receive(:generic_type=).with(nil).and_return do assert true end
      reg.should_receive(:odba_isolated_store).and_return do assert true end
      @package.deductible = 'deductible'
      @package.delete_sl_entry
      assert_nil @package.sl_entry
      assert_nil @package.deductible
    end
    def test_feedback
      fb1 = flexmock :oid => 12
      fb2 = flexmock :oid => 16
      @package.feedbacks.push fb1, fb2
      assert_equal(fb1, @package.feedback(12))
      assert_equal(fb2, @package.feedback('16'))
      assert_nil(@package.feedback(1))
    end
    def test_generic_group
      assert_respond_to(@package, :generic_group)
    end
    def test_generic_group_writer
      generic_group = StubPackageGenericGroup.new
      assert_nil(generic_group.package)
      @package.generic_group = generic_group
      assert_equal(@package, generic_group.package)
      assert_nil(generic_group.removed)
      @package.generic_group = nil
      assert_equal(true, generic_group.removed)
    end
    def test_generic_group_comparables
      group = flexmock :packages => [ 'other', @package, 'third' ]
      @package.instance_variable_set '@generic_group', group
      assert_equal ['other', 'third'], @package.generic_group_comparables
    end
    def test_good_result
      @package.sequence = flexmock :basename => 'Something or Other'
      assert_equal true, @package.good_result?('Something')
      assert_equal false, @package.good_result?('Other')
    end
    def test_has_generic
      assert_equal false, @package.has_generic?
      @package.sequence = flexmock :comparables => [], :public_packages => []
      @package.instance_variable_set '@generic_type', :original
      @package.parts.push flexmock(:comparable_size => Dose.new(5, 'ml'))
      assert_equal false, @package.has_generic?
      group = flexmock :packages => [ 'other', @package, 'third' ]
      @package.instance_variable_set '@generic_group', group
      assert_equal true, @package.has_generic?
      @package.instance_variable_set '@generic_type', :generic
      assert_equal false, @package.has_generic?
    end
    def test_has_price
      assert_equal false, @package.has_price?
      @package.price_public = 10
      assert_equal true, @package.has_price?
    end
    def test_has_price_history
      assert_equal false, @package.has_price_history?
      @package.price_public = 10
      assert_equal false, @package.has_price_history?
      @package.price_public = 20
      assert_equal true, @package.has_price_history?
    end
    def test_ikscd_writer
      @package.out_of_trade = true
      part = flexmock 'part'
      part.should_receive(:fix_pointers).times(1).and_return do assert true end
      @package.parts.push part
      pacs = {'012' => @package }
      seqptr = Persistence::Pointer.new [:sequence => 'scd']
      seq = flexmock :packages => pacs, :pointer => seqptr
      @package.sequence = seq
      slentry = flexmock 'slentry'
      slentry.should_receive(:pointer=)\
        .with(seqptr + [:package, '015'] + :sl_entry).times(1).and_return do
        assert true
      end
      slentry.should_receive(:odba_store).times(1).and_return do assert true end
      @package.instance_variable_set '@sl_entry', slentry
      @package.ikscd = '015'
      assert_equal({'015' => @package}, pacs)
      assert_equal false, @package.out_of_trade
      assert_equal seqptr + [:package, '015'], @package.pointer
    end
    def test_iksnr
      assert_respond_to(@package, :iksnr)
      assert_equal('12345', @package.iksnr)
    end
    def test_ikskey
      result = @package.ikskey()
      assert_equal('12345012', result)	
    end
    def test_limitation
      assert_nil @package.limitation
      @package.instance_variable_set '@sl_entry', flexmock(:limitation => 'lim')
      assert_equal 'lim', @package.limitation
    end
    def test_limitation_text
      assert_nil @package.limitation_text
      @package.instance_variable_set '@sl_entry', flexmock(:limitation_text => 'lt')
      assert_equal 'lt', @package.limitation_text
    end
    def test_localized_name
      seq = flexmock 'sequence'
      seq.should_receive(:localized_name).with(:de).and_return 'Deutsch'
      seq.should_receive(:localized_name).with(:fr).and_return 'Françaix'
      @package.sequence = seq
      assert_equal 'Deutsch', @package.localized_name(:de)
      assert_equal 'Françaix', @package.localized_name(:fr)
    end
    def test_most_precise_dose
      assert_nil @package.most_precise_dose
      @package.sequence.dose = 'sequence-dose'
      assert_equal 'sequence-dose', @package.most_precise_dose
      @package.ddd_dose = 'ddd-dose'
      assert_equal 'ddd-dose', @package.most_precise_dose
      @package.pretty_dose = 'pretty-dose'
      assert_equal 'pretty-dose', @package.most_precise_dose
    end
    def test_name_with_size
      @package.sequence = flexmock :name_base => 'Name'
      @package.parts.push flexmock(:size => '10 Tablette(n)')
      assert_equal 'Name, 10 Tablette(n)', @package.name_with_size
    end
    def test_narcotic
      assert_equal false, @package.narcotic?
      @package.narcotics.push flexmock(:category => 'b')
      assert_equal false, @package.narcotic?
      @package.narcotics.push flexmock(:category => 'a')
      assert_equal true, @package.narcotic?
    end
    def test_pharmacode_writer
      assert_nil @package.pharmacode
      @package.pharmacode = '12345'
      assert_equal '12345', @package.pharmacode
      @package.pharmacode = 98765
      assert_equal '98765', @package.pharmacode
      @package.pharmacode = nil
      assert_nil @package.pharmacode
    end
    def test_part
      assert_nil @package.part(3)
      part1 = flexmock :oid => 3
      @package.parts.push part1
      assert_equal part1, @package.part(3)
      assert_nil @package.part(8)
      part2 = flexmock :oid => 7
      @package.parts.push part2
      assert_nil @package.part(8)
      assert_equal part2, @package.part(7)
    end
    def test_preview
      assert_nil @package.preview?
      @package.preview_with_market_date = true
      assert_nil @package.preview?
      @package.market_date = @@today
      assert_equal false, @package.preview?
      @package.market_date = @@today + 1
      assert_equal true, @package.preview?
      @package.preview_with_market_date = nil
      assert_nil @package.preview?
    end
    def test_price
      price1 = Util::Money.new 10
      price1.valid_from = Time.now - 3600
      price2 = Util::Money.new 20
      @package.price_public = price1
      @package.price_public = price2
      assert_equal price2, @package.price(:public)
      assert_equal price1, @package.price(:public, Time.now - 20)
      assert_equal price2, @package.price(:public, 0)
      assert_equal price1, @package.price(:public, 1)
    end
    def test_price_diff
      values = {:price_exfactory => 12.34}
      expected = {:price_exfactory => Util::Money.new(12.34)}
      assert_equal(expected, @package.diff(values))
      @package.price_exfactory = Util::Money.new(12.34)
      assert_equal({}, @package.diff(values))
      values = {:price_exfactory => "12.34"}
      assert_equal({}, @package.diff(values))
      values = {:price_exfactory => 43.21}
      expected = {:price_exfactory => Util::Money.new(43.21)}
      assert_equal(expected, @package.diff(values))
      ## rounding errors:
      @package.price_exfactory = Util::Money.new(43.21)
      values = {:price_exfactory => 43.210000000000000000345}
      assert_equal({}, @package.diff(values))
      values = {:price_exfactory => 43.209999999999999999995}
      assert_equal({}, @package.diff(values))
    end
    def test_public
      inactive = flexmock 'registration'
      inactive.should_receive(:active?).and_return false
      @package.sequence.registration = inactive
      assert_equal(true, @package.public?)
      @package.out_of_trade = true
      assert_equal(false, @package.public?)
      @package.refdata_override = true
      assert_equal(true, @package.public?)
      @package.market_date = Date.today + 1
      assert_equal(false, @package.public?)
      @package.market_date = Date.today
      assert_equal(true, @package.public?)
    end
    def test_registration_data
      reg = flexmock :source => 'source'
      seq = flexmock :registration => reg
      assert_nil @package.source
      @package.sequence = seq
      assert_equal 'source', @package.source
    end
    def test_remove_narcotic
      narc = flexmock 'narcotic'
      narc.should_receive(:remove_package).with(@package).times(1).and_return do
        assert true
      end
      @package.narcotics.push narc
      @package.remove_narcotic narc
      assert_equal [], @package.narcotics
    end
    def test_respond_to_name_base
      assert_respond_to(@package, :name_base)
    end
    def test_size
      @package.parts.push flexmock(:size => '10 Tabletten'),
                          flexmock(:size => '5 Tabletten')
      assert_equal '10 Tabletten + 5 Tabletten', @package.size
    end
    def test_sortable
      other = Package.new '015'
      other.sequence = StubPackageSequence.new
      other.sequence.basename = 'A Name'
      @package.sequence.basename = 'Another Name'
      assert_equal [other, @package], [@package, other].sort
      @package.sequence.basename = 'A Name'
      assert_equal [@package, other], [@package, other].sort
      other.sequence.dose = 20
      @package.sequence.dose = 10
      assert_equal [@package, other], [other, @package].sort
      other.sequence.dose = 10
      assert_equal [@package, other], [@package, other].sort
      @package.parts.push flexmock(:comparable_size => 20)
      other.parts.push flexmock(:comparable_size => 10)
      assert_equal [other, @package], [@package, other].sort
    end
    def test_substances
      act1 = flexmock :substance => 'sub1'
      act2 = flexmock :substance => 'sub2'
      act3 = flexmock :substance => 'sub3'
      @package.parts.push flexmock(:active_agents => [act1, act2]),
                          flexmock(:active_agents => [act3])
      assert_equal %w{sub1 sub2 sub3}, @package.substances
    end
  end
end
