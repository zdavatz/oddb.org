#!/usr/bin/env ruby
# encoding: utf-8

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'stub/odba'

require 'minitest/autorun'
require 'model/package'
require 'model/atcclass'
require 'flexmock/minitest'
require 'model/registration'
require 'model/fachinfo'
begin  require 'debug'; rescue LoadError; end # ignore error when debug cannot be loaded (for Jenkins-CI)
module ODDB
  class PackageCommon
    check_accessor_list = {
      :sequence                 => ["ODDB::Sequence", "StubPackageSequence", "FlexMock"],
      :ikscat                   => "String",
      :generic_group            => "ODDB::GenericGroup",
      :sl_generic_type          => "Symbol",
      :price_exfactory          => "ODDB::Util::Money",
      :price_public             => "ODDB::Util::Money",
      :pretty_dose              => ["ODDB::Dose", "String"],
      :market_date              => "Date",
      :medwin_ikscd             => "String",
      :out_of_trade             => ["TrueClass","NilClass","FalseClass"],
      :refdata_override         => ["TrueClass","NilClass","FalseClass"],
      :deductible               => ["Symbol","String"],
      :lppv                     => ["TrueClass","NilClass","FalseClass"],
      :disable                  => ["TrueClass","NilClass","FalseClass"],
      :swissmedic_source        => "Hash",
      :descr                    => "String",
      :preview_with_market_date => ["TrueClass","NilClass","FalseClass"],
      :generic_group_factor     => ["NilClass,Float","Fixnum"],
      :photo_link               => ["NilClass","String"],
      :disable_ddd_price        => ["TrueClass","NilClass","FalseClass"],
      :ddd_dose                 => ["ODDB::Dose", "String"],
      :sl_entry                 => "ODDB::SlEntry",
      :deductible_m             => "String",
      :bm_flag                  => ["TrueClass","NilClass","FalseClass"],
      :mail_order_prices        => "Array",
    }
    define_check_class_methods check_accessor_list
    def debug_only_set_parts_to_stub  # for test_create_part_when_parts_are_nil
      @parts =ODBA::CacheStub.new
    end
  end
  class Package < PackageCommon
    public :adjust_types
  end
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
  attr_accessor :dose, :basename, :patinfo
  attr_accessor :comparables
  attr_accessor :active_packages, :registration, :composition
  def initialize
    @active_packages = []
  end
  def public_packages
    @active_packages
  end
  def iksnr
    '12345'
  end
  def compositions
    [ 'comp1', 'comp2']
  end
end
class TestPackage <Minitest::Test
  DDD_PRICE_NIL = 'not calculated'
  def setup
    @package = ODDB::Package.new('12')
    @package.sequence = StubPackageSequence.new
    ddd_td_o = ODDB::AtcClass::DDD.new('0')
    ddd_td_o.dose = ODDB::Dose.new(5 , 'mg')
    ddd_td_pdepot = ODDB::AtcClass::DDD.new('Pdepot')
    ddd_td_pdepot.dose = ODDB::Dose.new(2.7 , 'mg')
    @N05AX08 = flexmock('N05AX08', :has_ddd? => true,
                    :ddds => { 'O' => ddd_td_o, 'Pdepot' => ddd_td_pdepot,},
                    :code => 'N05AX08')
  end
  def test_add_shortage_info_gtin_mismatch
    new_shortage_info = OpenStruct.new
    new_shortage_info.gtin = '1234567890123'
    assert_raises(RuntimeError) { @package.update_shortage_list(new_shortage_info) }
  end
  def test_add_shortage_info
    new_shortage_info = OpenStruct.new
    new_shortage_info.gtin = '7680123450123'
    new_shortage_info.shortage_state = 'shortage_state'
    new_shortage_info.shortage_last_update = '2016-01-16'
    new_shortage_info.shortage_delivery_date =  '2016-05-16'
    new_shortage_info.shortage_link = 'shortage_link'
    @package = flexmock(@package, 'testPackage')
    @package.should_receive(:odba_store).at_least.once
    @package.update_shortage_list(new_shortage_info)
    assert_equal('2016-01-16', @package.shortage_last_update.to_s)
    assert_equal('2016-05-16', @package.shortage_delivery_date.to_s)
    assert_equal('shortage_link', @package.shortage_link)
    assert_equal('shortage_state', @package.shortage_state)
  end
  def test_no_longer_in_shortage_list
    @package.shortage_info = 'info'
    @package.shortage_last_update= Date.today-30
    @package.shortage_delivery_date = 'offen'
    @package.shortage_link = 'url'
    @package = flexmock(@package, 'testPackage')
    @package.should_receive(:odba_store).at_least.once
    @package.no_longer_in_shortage_list
    assert_nil(@package.shortage_state)
    assert_nil(@package.shortage_last_update)
    assert_nil(@package.shortage_delivery_date)
    assert_nil(@package.shortage_link)
  end

  def test_add_nomarketing_info_gtin_mismatch
    new_nomarketing_info = OpenStruct.new
    new_nomarketing_info.gtin = '1234567890123'
    assert_raises(RuntimeError) { @package.update_nomarketing_list(new_nomarketing_info) }
  end
  def test_add_nomarketing_info_delivery_and_nomarketing_nil
    new_nomarketing_info = OpenStruct.new
    new_nomarketing_info.gtin = @package.barcode
    assert_raises(RuntimeError) { @package.update_nomarketing_list(new_nomarketing_info) }
  end
  def test_add_nomarketing_info
    new_nomarketing_info = OpenStruct.new
    new_nomarketing_info.gtin = '7680123450123'
    new_nomarketing_info.nodelivery_since = '2016-02-16'
    new_nomarketing_info.nomarketing_since = '2016-01-16'
    new_nomarketing_info.nomarketing_date =  '2016-05-16'
    @package = flexmock(@package, 'testPackage')
    @package.should_receive(:odba_store).at_least.once
    @package.update_nomarketing_list(new_nomarketing_info)
    assert_equal('2016-01-16', @package.nomarketing_since.to_s)
    assert_equal('2016-05-16', @package.nomarketing_date.to_s)
    assert_equal('2016-02-16', @package.nodelivery_since)
  end
  def test_no_longer_in_nomarketing_list
    @package.nomarketing_since= Date.today-30
    @package.nomarketing_date = Date.today-60
    @package.nodelivery_since = nil
    @package = flexmock(@package, 'testPackage')
    @package.should_receive(:odba_store).at_least.once
    @package.no_longer_in_nomarketing_list
    assert_nil(@package.nodelivery_since)
    assert_nil(@package.nomarketing_date)
    assert_nil(@package.nomarketing_since)
  end

  def create_test_package(iksnr: , ikscd: , price_public: , ddd_dose: , atc_code: ,
                          pack_dose: ,
                          excipiens: nil,
                          composition_text: nil,
                          parts: [],
                          galenic_group: 'Tabletten',
                          route_of_administration: nil)
    @seq = flexmock('seq_01', ODDB::Sequence.new('01'))
    @seq.should_receive(:pointer).and_return("#{iksnr}/#{01}/#{ikscd}")
    @package = @seq.create_package(sprintf("%03i", ikscd))
    @package.price_public = ODDB::Util::Money.new(price_public, 'CHF')
    @ddd_o = ODDB::AtcClass::DDD.new('O')
    @ddd_o.dose = ddd_dose
    @atc = flexmock('atc_class', :has_ddd? => true, :ddds => {'O' => @ddd_o,}, :code => atc_code)
    @excipiens = flexmock('excipiens', :to_s => excipiens)
    @composition = flexmock 'composition', :excipiens => @excipiens
    @active_agent = ODDB::ActiveAgent.new(atc_code)
    @active_agent.dose = pack_dose
    @seq.should_receive(:route_of_administration).and_return(route_of_administration).by_default
    @seq.should_receive(:iksnr).and_return(sprintf("%05i", iksnr))
    @seq.should_receive(:atc_class).and_return(@atc).by_default
    @seq.should_receive(:dose).and_return(pack_dose).by_default
    @seq.should_receive(:compositions).and_return([@composition]).by_default
    @seq.should_receive(:composition_text).and_return(composition_text).by_default
    @seq.should_receive(:active_agents).and_return([@active_agent]).by_default
    @seq.should_receive(:galenic_group).and_return(galenic_group).by_default
    @seq.should_receive(:longevity).and_return(nil).by_default
    parts.each{|part| @package.parts.push part}
  end
  def test_initialize
    assert_equal('012', @package.ikscd)
    refute_nil(@package.oid)
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
      :price_exfactory=>	ODDB::Util::Money.new(12.34),
      :price_public		=>	ODDB::Util::Money.new(15),
      :pretty_dose    =>  ODDB::Dose.new(10, 'mg'),
      :ddd_dose       =>  [20, 'mg'],
    }
    expected = {
      :size						=>	'20 x 1,7 g',
      :descr					=>	nil,
      :ikscat					=>	'A',
      :generic_group	=>	'generic-group',
      :price_exfactory=>	ODDB::Util::Money.new(12.34),
      :price_public		=>	ODDB::Util::Money.new(15),
      :pretty_dose    =>  ODDB::Dose.new(10, 'mg'),
      :ddd_dose       =>  ODDB::Dose.new(20, 'mg'),
    }
    assert_equal(expected, @package.adjust_types(values, app))
  end
  def test_barcode
    assert_equal('7680123450123', @package.barcode)
  end
  def test_patinfo_via_sequence
    seq = StubPackageSequence.new
    assert_equal(nil.object_id, @package.patinfo.object_id)
    seq.patinfo = ODDB::Patinfo.new
    saved_id =seq.patinfo.object_id
    @package.sequence = seq
    assert_equal(saved_id, @package.patinfo.object_id)
  end
  def test_patinfo_self
    seq = flexmock('sequence')
    seq.should_receive.once(:patinfo).and_return('patinfo_from_sequence')
    @package.sequence = seq
    @package.patinfo = 'patinfo_self'
    assert_equal('patinfo_self', @package.patinfo)
    assert_equal(true, @package.has_patinfo?)
  end
  def test_checkout
    group = flexmock 'generic group'
    group.should_receive(:remove_package).with(@package).times(1).and_return do
      assert true
    end
    @package.instance_variable_set '@generic_group', group
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
    assert_equal ['comp1', 'comp2'], @package.compositions
  end
  def test_comparable_size
    part1 = flexmock :comparable_size => ODDB::Dose.new(5, 'ml')
    part2 = flexmock :comparable_size => ODDB::Dose.new(10, 'ml')
    @package.parts.push part1, part2
    assert_equal ODDB::Dose.new(15, 'ml'), @package.comparable_size
  end
  def test_comparable_size__robust
    part1 = flexmock :comparable_size => ODDB::Dose.new(5, 'ml')
    part2 = flexmock :comparable_size => ODDB::Dose.new(10, 'mg')
    @package.parts.push part1, part2
    assert_equal ODDB::Dose.new(15, ''), @package.comparable_size
  end
  def test_comparable_size__empty
    assert_equal [], @package.parts
    assert_equal ODDB::Dose.new(0, ''), @package.comparable_size
  end
  def test_comparable?
    part1 = flexmock :comparable_size => ODDB::Dose.new(5, 'ml')
    part2 = flexmock :comparable_size => ODDB::Dose.new(10, 'ml')
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
  def test_comparable__error
    pack = flexmock('pack')
    flexmock(pack).should_receive(:comparable_size).and_raise(RuntimeError)
    assert_equal(false, @package.comparable?('bottom', 'top', pack))
  end

  def test_comparable_failcase
    part1 = flexmock :comparable_size => ODDB::Dose.new(5, 'ml')
    part2 = flexmock :comparable_size => ODDB::Dose.new(10, 'ml')
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
    assert_instance_of ODDB::Part, part
    assert_equal [part], @package.parts
    assert_equal @package, part.package
  end
  def test_create_part_when_parts_are_nil
    @package.debug_only_set_parts_to_stub
    assert_instance_of ODBA::CacheStub, @package.parts
    part = @package.create_part
    assert_instance_of ODDB::Part, part
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
    create_test_package(iksnr: 99001, ikscd: 1, price_public:10,
                        ddd_dose:ODDB::Dose.new(20, 'mg'),
                        pack_dose: ODDB::Dose.new(10, 'mg'),
                        atc_code: 'A03AX13',
                        galenic_group: 'Sachets'
                        )
    part = flexmock :comparable_size => ODDB::Dose.new(10, 'Tabletten')
    @package.parts.push part
    assert_equal ODDB::Util::Money.new(2, 'CHF'), @package.ddd_price
  end
  def test_ddd_price_99000_longevity
    create_test_package(iksnr: 99002, ikscd: 1, price_public:10,
                        ddd_dose:ODDB::Dose.new(20, 'mg'),
                        pack_dose: ODDB::Dose.new(20, 'mg'),
                        atc_code: 'A03AX13',
                        galenic_group: 'Tabletten'
                        )
    @package.sequence.longevity = 1
    part = flexmock('part_1',
                    :comparable_size => ODDB::Dose.new(10, 'Tabletten'),
                    :count => 10,
                    :multi => 1,
                   )
    @package.parts.push part
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(13, variant)
    assert_equal ODDB::Util::Money.new(1.00, 'CHF').to_s, @package.ddd_price.to_s
    assert_equal('10.00 / 10  / 1.0', calc)

    @seq.should_receive(:longevity).and_return(2)
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(14, variant)
    assert_equal('10.00 / ( 10 x 1 ) x ( 20 mg / 20 mg ) / 2.0', calc)
    assert_equal ODDB::Util::Money.new(0.5, 'CHF').to_s, @package.ddd_price.to_s
  end
  def test_ddd_dafalgan_kinder
    # Tageskosten für Dafalgan Kinder
    # Tagesdosis  3 g Publikumspreis  1.40 CHF
    # Stärke  250 mg  Packungsgrösse  12 Sachet(s)
    # Berechnung  ( 3 g / 250 mg ) x ( 1.40 / 12 Sachet(s) ) = 1.40 CHF / Tag
    create_test_package(iksnr: 51231, ikscd: 031, price_public: 1.40,
                        ddd_dose: ODDB::Dose.new(3, 'g'),
                        pack_dose: ODDB::Dose.new(250, 'mg'),
                        atc_code: 'A03AX13',
                        galenic_group: 'Sachets'
                        )
    part = flexmock :comparable_size => ODDB::Dose.new(12, 'Sachet(s)')
    @package.parts.push part
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(4, variant)
    assert_equal ODDB::Util::Money.new(1.40, 'CHF').to_s, @package.ddd_price.to_s
    assert_equal('1.40 / 12  x 250 mg / 3 g / 1.0', calc)
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
  def test_delete_sl_entry__sl_entry
    flexmock(@package, :sl_entry => nil)
    registration = flexmock('registration',
                            :packages => [@package],
                            :generic_type= => nil,
                            :odba_isolated_store => 'odba_isolated_store'
                           )
    @package.sequence.registration = registration
    assert_nil(@package.delete_sl_entry)
    assert_nil(@package.sl_entry)
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
    @package.parts.push flexmock(:comparable_size => ODDB::Dose.new(5, 'ml'))
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
    seqptr = ODDB::Persistence::Pointer.new [:sequence => 'scd']
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
    price1 = ODDB::Util::Money.new 10
    price1.valid_from = Time.now - 3600
    price2 = ODDB::Util::Money.new 20
    @package.price_public = price1
    @package.price_public = price2
    assert_equal price2, @package.price(:public)
    assert_equal price1, @package.price(:public, Time.now - 20)
    assert_equal price2, @package.price(:public, 0)
    assert_equal price1, @package.price(:public, 1)
  end
  def test_price_diff
    values = {:price_exfactory => 12.34}
    expected = {:price_exfactory => ODDB::Util::Money.new(12.34)}
    assert_equal(expected, @package.diff(values))
    @package.price_exfactory = ODDB::Util::Money.new(12.34)
    assert_equal({}, @package.diff(values))
    values = {:price_exfactory => "12.34"}
    assert_equal({}, @package.diff(values))
    values = {:price_exfactory => 43.21}
    expected = {:price_exfactory => ODDB::Util::Money.new(43.21)}
    assert_equal(expected, @package.diff(values))
    ## rounding errors:
    @package.price_exfactory = ODDB::Util::Money.new(43.21)
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
  def test_respond_to_name_base
    assert_respond_to(@package, :name_base)
  end
  def test_size
    @package.parts.push flexmock(:size => '10 Tabletten'),
                        flexmock(:size => '5 Tabletten')
    assert_equal '10 Tabletten + 5 Tabletten', @package.size
  end
  def test_sortable
    other = ODDB::Package.new '015'
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
  def test_ddd_Emend_iksnr_56359
    create_test_package(iksnr: 56359, ikscd: 21, price_public: 103.4,
                        ddd_dose: ODDB::Dose.new(95 , 'mg'),
                        pack_dose:  ODDB::Dose.new(125, 'mg'),
                        atc_code: 'C01DA02',
                        )
    part = ODDB::Part.new
    part.count = 3
    part.multi = 1
    part.addition = 0
    part.measure = ODDB::Dose.new(125, 'mg')
    @package.parts.push part
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(13, variant)
    assert_equal ODDB::Util::Money.new(34.47, 'CHF').to_s, price.to_s
    assert_equal('103.40 / 375 mg / 1.0', calc)
  end
  def test_ddd_Pradaxa_iksnr_61385
    create_test_package(iksnr: 61385, ikscd: 7, price_public: 112.50,
                        ddd_dose: ODDB::Dose.new(0.22 , 'g'),
                        pack_dose: ODDB::Dose.new(110, 'mg'),
                        atc_code: 'B01AE07',
                        excipiens: 'Excipiens pro Capsula',
                        galenic_group: 'Kapseln')
    part = ODDB::Part.new
    part.count = 60
    part.multi = 1
    part.addition = 0
    part.measure = nil
    @package.parts.push part
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(31, variant)
    assert_equal ODDB::Util::Money.new(3.75, 'CHF').to_s, price ? price.to_s : DDD_PRICE_NIL
    assert_equal('112.50 x ( 0.22 g / ( 110 mg x 60 ))', calc)
  end
  def test_ddd_Nitroglycerin_iksnr_36830
    create_test_package(iksnr: 36830, ikscd: 18, price_public: 7.4,
                  ddd_dose: ODDB::Dose.new(5 , 'mg'),
                  pack_dose: ODDB::Dose.new(0.8, 'mg'),
                  atc_code: 'C01DA02'
                  )
    part = ODDB::Part.new
    part.count = 30
    part.multi = 1
    part.addition = 0
    part.measure = nil
    @package.parts.push part
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(14, variant)
    assert_equal(ODDB::Util::Money.new(1.54, 'CHF').to_s, price ? price.to_s : DDD_PRICE_NIL, 'This is double because we use "0"')
    assert_equal('7.40 / ( 30 x 1 ) x ( 5 mg / 0.8 mg ) / 1.0', calc)
    skip("Here we cannot distinguish between 2.5   mg  oral aerosol and 5   mg  O, Therefore we use the '0'")
    assert_equal ODDB::Util::Money.new(0.77, 'CHF').to_s, price ? price.to_s : DDD_PRICE_NIL
    #   new_info 36830;018;823902;Nitroglycerin Streuli, Kaukapseln;C01DA02;O,SL,TD,oral aerosol;O;5 mg;0.8 mg;;Kautabletten;7.40;1.54
    # Still incorrect price       1.54        0.77 old_price       1.54  for  823902 Nitroglycerin Streuli, Kaukapseln
    # WHO   5   mg  O
    #     2.5   mg  oral aerosol
    #     2.5   mg  SL
    #       5   mg  TD
  end
  def test_ddd_Estradot_iksnr_55976
    create_test_package(iksnr: 55976, ikscd: 17, price_public: 18.65,
                        ddd_dose: ODDB::Dose.new(3 , 'mg'),
                        pack_dose: ODDB::Dose.new(390, "µg"),
                        atc_code: 'G03CA03',
                        excipiens: 'Excipiens ad Praeparationem pro 2.5 Cm², cum Liberatione 25 µg/24 H',
                        composition_text: 'composition_text',
                        galenic_group: 'Pflaster/Transdermale Systeme')
    ddd_td_gel = ODDB::AtcClass::DDD.new('TDgel')
    ddd_td_gel.dose = ODDB::Dose.new(1 , 'mg')
    ddd_td_patch = ODDB::AtcClass::DDD.new('TDpatch refer to amount delivered per 24 hours')
    ddd_td_patch.dose = ODDB::Dose.new(50 , 'mcg')
    atc = flexmock 'atc2', :has_ddd? => true,
                    :ddds => {
                      'O' => @ddd_o,
                      'TDgel' => ddd_td_gel,
                      'TDpatch refer to amount delivered per 24 hours' => ddd_td_patch,
                    },
                    :code => 'G03CA03'
    @seq.should_receive(:atc_class).and_return(atc)
    part = ODDB::Part.new
    part.count = 8
    part.multi = 1
    part.addition = 0
    part.measure = nil
    @package.parts.push part
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(10, variant)
    assert_equal ODDB::Util::Money.new(1.17, 'CHF').to_s, price ? price.to_s : DDD_PRICE_NIL
    assert_equal('18.65 / 8 / (50 ug /  25 ug)', calc)
    #    new_info 55976;017;2635412;Estradot 25, Transdermales Pflaster;G03CA03;N,O,P,R,V,TD,TDgel,Pdepot long duration,Pdepot short duration,TDpatch refer to amount delivered per 24 hours,VVaginal ring refers to amount delivered per 24 hours,VVaginal ring refers to amount delivered per 24 hours *;O;2 mg;390 µg;roa_TD;Transdermales Pflaster;18.65;11.96
    #Still incorrect price      11.96        1.33 old_price      11.96  for 2635412 Estradot 25, Transdermales Pflaster
    # WHO for G03CA03   estradiol   0.3   mg  N
    # 2     mg  O
    # 1     mg  P   depot short duration
    # 0.3   mg  P   depot long duration
    # 5     mg  R
    # 50    mcg   TD  patch refer to amount delivered per 24 hours
    # 1     mg  TD  gel
    # 25    mcg   V
    # 7.5   mcg   V   vaginal ring refers to amount delivered per 24 hours
    assert_equal ODDB::Util::Money.new(1.17, 'CHF').to_s, price ? price.to_s : DDD_PRICE_NIL
    # Test again with a different rate
    excipiens = flexmock 'excipiens', :description => "Excipiens ad Praeparationem pro 2.5 Cm², cum Liberatione 0.005 mg/h"
    composition = flexmock 'composition', :excipiens => excipiens
    seq2 = flexmock 'seq2', :atc_class => atc,
                   :galenic_group => 'Pflaster/Transdermale Systeme', #galenic_forms.first = 'Transdermales Pflaster'
                   :dose => ODDB::Dose.new(390, "µg"),
                   :active_agents => [],
                   :pointer => 'pointer',
                   :compositions => [composition],
                   :composition_text => 'composition_text',
                   :longevity => nil
    @package.sequence = seq2
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(4, variant)
    # We just wanted to receive a different price. No real example!
    assert_equal ODDB::Util::Money.new(17.93, 'CHF').to_s, price ? price.to_s : DDD_PRICE_NIL
    assert_equal('18.65 / 8  x 390 µg / 3 mg / 1.0', calc)
  end
  def test_cum_liberation
    allowed_failures = [
      # belong to 54704 Estalis which has no WHO DDD therefore no more work is needed.
          'Excipiens Ad Praeparationem pro 16 Cm² Cum Liberatione 50 µg Et 170 µg/24 H',
          'Excipiens Ad Praeparationem pro 16 Cm² Cum Liberatione 50 µg Et 250 µg/24 H',
          'Excipiens Ad Praeparationem pro 20 Cm² Cum Liberatione 150 µg Et 20 µg/24 H',
          'Excipiens Ad Praeparationem pro 9 Cm² Cum Liberatione 50 µg Et 140 µg/24 H',
      ]
    test_cases = [
          'Excipiens Ad Praeparationem pro 10.5 Cm² Cum Liberatione 25 µg/h',
          'Excipiens Ad Praeparationem pro 10 Cm² Cum Liberatione 100 µg/24 H',
          'Excipiens Ad Praeparationem pro 10 Cm², Cum Liberatione 2 Mg/24h',
          'Excipiens Ad Praeparationem pro 10 Cm² Cum Liberatione 9.5 Mg/24h',
          'Excipiens Ad Praeparationem pro 21 Cm² Cum Liberatione 50 µg/h',
          'Excipiens Ad Praeparationem pro 22.50 Cm² Cum Liberatione 25 Mg/16h',
          'Excipiens Ad Praeparationem pro 39 Cm² Cum Liberatione 3.9mg/24h',
          'Excipiens pro Praeparatione Cum Liberatione 20 µg/24 H',
          'Excipiens pro Praeparatione, Cum Liberatione 20 µg/24 H',
    ]
    test_cases.each do |excipiens|
       m = ODDB::Package::CUM_LIBERATION_REGEXP.match(excipiens.downcase)
       assert(m[1])
       value = Unit.new(m[1])
       assert(value.compatible?(Unit.new('1g/24h')))
    end
    allowed_failures.each do |excipiens|
       m = ODDB::Package::CUM_LIBERATION_REGEXP.match(excipiens.downcase)
       assert_nil(m)
    end
  end
  def test_ad_granulatum
    allowed_failures = [ # the have no unit
        'Ad Granulatum',
        'Excipiens Ad Granulatum',
        'Excipiens Ad Granulatum, pro Charta',
        'Excipiens Ad Granulatum pro Vitro',
      ]
    test_cases = [
        'Excipiens Ad Granulatum Corresp. Solutio Reconstituta 5 Ml',
        'Excipiens Ad Granulatum Corresp. Suspensio Reconstituta 0.5 Ml',
        'Excipiens Ad Granulatum Corresp. Suspensio Reconstituta 5 Ml',
        'Excipiens Ad Granulatum Corresp., Suspensio Reconstituta 60 Ml',
        'Excipiens Ad Granulatum pro 0.5 G',
        'Excipiens Ad Granulatum pro 10 G',
        'Excipiens Ad Granulatum pro 1 G',
        'Excipiens Ad Granulatum pro 240 Mg',
        'Excipiens Ad Granulatum pro 3 G',
        'Excipiens Ad Granulatum pro Charta 1.5 G',
        'Excipiens Ad Granulatum, pro Charta 1.8 G',
        'Excipiens Ad Granulatum pro Charta 4.74 G',
        'Excipiens Ad Granulatum pro Charta 950 Mg',
        'Q.s. Ad Granulatum pro 1 G',
    ]
    test_cases.each do |excipiens|
       m = ODDB::Package::AD_GRANULATUM_REGEXP.match(excipiens.downcase)
       assert(m[1])
       value = Unit.new(m[1])
       # binding.break if /mg\/24h/.match excipiens
       # puts "#{value} #{m[1]} aus #{excipiens}"
       assert(value.compatible?(Unit.new('1g')) || value.compatible?(Unit.new('1l')))
    end
    allowed_failures.each do |excipiens|
       m = ODDB::Package::AD_GRANULATUM_REGEXP.match(excipiens.downcase)
       assert_nil(m)
    end
  end
  def test_ddd_Colosan_iksnr_43319
    create_test_package(iksnr: 43319, ikscd: 78, price_public: 12.35,
                    ddd_dose: ODDB::Dose.new(8 , 'g'),
                    pack_dose: ODDB::Dose.new(875, "mg"),
                    atc_code: 'G03CA03',
                    excipiens: 'Excipiens ad Granulatum pro 1 G',
                    composition_text: 'composition_text',
                    galenic_group: 'Lösbar zur Einnahme')
    part = ODDB::Part.new
    part.count = 1
    part.multi = 1
    part.addition = 0
    part.measure = ODDB::Dose.new(200, 'g')
    @package.parts.push part
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(20, variant)
    assert_equal ODDB::Util::Money.new(0.56, 'CHF').to_s, price ? price.to_s : DDD_PRICE_NIL
    assert_equal('12.35 / 200 g x (7/8 / 8 g)', calc)
  end
  def test_ddd_Arlevert_iksnr_59285
   create_test_package(iksnr: 59285, ikscd: 1, price_public: 16.45,
                        ddd_dose: ODDB::Dose.new(90 , 'mg'),
                        pack_dose: ODDB::Dose.new(60, "mg"),
                        atc_code: 'N07CA02',
                        excipiens: '"Excipiens Pro Compresso',
                        galenic_group: 'Tabletten')
    cinnarizinum = ODDB::ActiveAgent.new('Cinnarizinum')
    cinnarizinum.dose = ODDB::Dose.new(20, 'mg')
    dimenhydrinatum = ODDB::ActiveAgent.new('Dimenhydrinatum')
    dimenhydrinatum.dose = ODDB::Dose.new(60, 'mg')
    @seq.should_receive(:active_agents).and_return([cinnarizinum, dimenhydrinatum])
    part = ODDB::Part.new
    part.count = 20
    part.multi = 1
    part.addition = 0
    part.measure = nil
    @package.parts.push part

    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(30, variant)
    assert_equal ODDB::Util::Money.new(3.7, 'CHF').to_s, price ? price.to_s : DDD_PRICE_NIL
    assert_equal('16.45 x ( 90 mg / ( 20 mg x 20 )', calc)
  end
  def test_ddd_Dekane_iksnr_47693
    create_test_package(iksnr: 47693, ikscd: 47, price_public: 27.35,
                ddd_dose: ODDB::Dose.new(1.5 , 'g'),
                pack_dose:  ODDB::Dose.new(286.8, "mg"),
                atc_code: 'N03AG01',
                excipiens: ' excipiens pro compresso obducto')
    part = ODDB::Part.new
    part.count = 100
    part.multi = 1
    part.addition = 0
    part.measure = nil
    @package.parts.push part

    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(14, variant)
    assert_equal ODDB::Util::Money.new(1.43, 'CHF').to_s, price ? price.to_s : DDD_PRICE_NIL
    assert_equal('27.35 / ( 100 x 1 ) x ( 1.5 g / 286.8 mg ) / 1.0', calc)
  end
  def test_ddd_Mucilar_iksnr_39474
    create_test_package(iksnr: 39474, ikscd: 26, price_public: 19.65,
                ddd_dose: ODDB::Dose.new(7 , 'g'),
                pack_dose:  ODDB::Dose.new(4.5, "g"),
                atc_code: 'A06AC01',
                excipiens: 'Excipiens ad Pulverem',
                composition_text: 'psyllii testa 4.5 g, glucosum monohydricum 4.4 g, aromatica, excipiens ad pulverem pro 9 g',
                galenic_group: 'Tabletten')
    psylli_testa = ODDB::ActiveAgent.new('Psyllii Testa')
    psylli_testa.dose = ODDB::Dose.new(4.5, 'mg')
    @seq.should_receive(:active_agents).and_return([psylli_testa])
    part = ODDB::Part.new
    part.count = 1
    part.multi = 1
    part.addition = 0
    part.measure = ODDB::Dose.new(400, 'g')
    @package.parts.push part
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(32, variant)
    assert_equal ODDB::Util::Money.new(0.69, 'CHF').to_s, price ? price.to_s : DDD_PRICE_NIL
    assert_equal('19.65 / ( ( 400 g / ( 7 g /  4.5 g / 9 g ) )', calc)
  end
  def test_ddd_Laxipeg_iksnr_62765
    create_test_package(iksnr: 62765, ikscd: 1, price_public: 18.45,
                        ddd_dose: ODDB::Dose.new(9.736, "g"),
                        pack_dose: ODDB::Dose.new(10, 'g'),
                        atc_code: 'A06AD15',
                        excipiens: 'Excipiens ad Pulverem',
                        composition_text: 'macrogolum 4000 9.736 g, acesulfamum kalicum, aromatica, excipiens ad pulverem pro 10 g.')
    part = ODDB::Part.new
    part.count = 1
    part.multi = 20
    part.addition = 0
    part.measure = ODDB::Dose.new(10, 'g')
    @package.parts.push part
    @seq.should_receive(:active_agents).and_return([@active_agent, @active_agent])
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(32, variant)
    assert_equal ODDB::Util::Money.new(0.90, 'CHF').to_s, price ? price.to_s : DDD_PRICE_NIL
    assert_equal('18.45 / ( ( 200 g / ( 9.736 g /  10 g / 10 g ) )', calc)
  end
  def test_ddd_Disflatyl_iksnr_52051
    create_test_package(iksnr: 52051, ikscd: 10, price_public: 6.45,
                        ddd_dose: ODDB::Dose.new(0.5 , 'g'),
                        pack_dose: ODDB::Dose.new(40, 'mg / ml'),
                        atc_code: 'A03AX13',
                        excipiens: 'Excipiens ad Solutionem',
                        composition_text: 'simeticonum 40 mg, arom.: vanillinum et alia, saccharinum natricum, conserv.: E 210, E 211, excipiens ad solutionem pro 1 ml',
                        galenic_group: 'Tropfen'
                        )
    part = ODDB::Part.new
    part.count = 1
    part.multi = 1
    part.addition = 0
    part.measure = ODDB::Dose.new('30','ml')
    @package.parts.push part
    assert_equal('ml', @package.parts.first.measure.unit)
    assert_equal(30, @package.parts.first.measure.qty)
    assert_equal('30 ml', @package.parts.first.size)
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(1, variant)
    assert_equal('6.45 x 0.5 g / ( 40 mg/ml x 30 ml )', calc)
    assert_equal ODDB::Util::Money.new(2.69, 'CHF').to_s, price.to_s
  end
  def test_ddd_Ursofalk_iksnr_54634
    create_test_package(iksnr: 54634, ikscd: 21, price_public: 59.15,
                        ddd_dose:ODDB::Dose.new(0.75 , 'g'),
                        pack_dose:  ODDB::Dose.new(250, 'mg'),
                        atc_code: 'A05AA02',
                        excipiens: 'Excipiens ad Suspensionem pro 5 Ml',
                        composition_text: 'acidum ursodeoxycholicum 250 mg, natrii cyclamas, aromatica, conserv.: E 210, excipiens ad suspensionem pro 5 ml.',
                        galenic_group: 'suspension'
                        )
    part = ODDB::Part.new
    part.count = 1
    part.multi = 1
    part.addition = 0
    part.measure = ODDB::Dose.new(250, 'ml')
    @package.parts.push part
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(2, variant)
    assert_equal ODDB::Util::Money.new(3.55, 'CHF').to_s, price.to_s
    assert_equal('59.15 / ( 0.75 g / 5 ml / ( 0.75 g / 250 ml) )', calc)
  end

  def test_ddd_Risperdal_iksnr_56092
    create_test_package(iksnr: 56092, ikscd: 3, price_public: 257.30, # On ODDB the current PP is 258.79 as per 08.12.2016
                        ddd_dose: ODDB::Dose.new(5 , 'mg'),
                        pack_dose: ODDB::Dose.new(37.5, 'mg'),
                        atc_code: @N05AX08.code,
                        excipiens: '  Aqua Ad Iniectabilia Q.s. Ad Solutionem',
                        route_of_administration: 'roa_P',
                        composition_text: 'Praeparatio sicca: risperidonum 25 mg, copoly(dl-lactidum-glycolidum).
Solvens: carmellosum natricum, polysorbatum 20, dinatrii phosphas dihydricus, acidum citricum anhydricum, natrii chloridum, aqua ad iniectabilia q.s. ad solutionem pro 2 ml, pro vase, in suspensione recenter reconstituta.',
                        galenic_group: 'Injektion/Infusion'
                        )
    @seq.should_receive(:atc_class).and_return(@N05AX08)
    composition1 = flexmock('composition1', :excipiens => nil)
    composition2 = flexmock('composition2', :excipiens => 'Aqua Ad Iniectabilia Q.s. Ad Solutionem')
    @seq.should_receive(:compositions).and_return([composition1, composition2])
    # @seq.compositions = [composition1, composition2]
    part = ODDB::Part.new
    part.count = 1
    part.multi = 1
    part.addition = 0
    part.measure = ODDB::Dose.new('30','ml')
    @package.parts.push part
    assert_equal('ml', @package.parts.first.measure.unit)
    assert_equal(30, @package.parts.first.measure.qty)
    assert_equal('30 ml', @package.parts.first.size)
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(-3, variant)
    assert_equal('xxx', calc)
    assert_equal(ODDB::Util::Money.new(18.53, 'CHF').to_s, (price ? price.to_s : DDD_PRICE_NIL))
  end

  def test_ddd_Risperdal_iksnr_58467
    create_test_package(iksnr: 58467, ikscd: 1, price_public: 28.75,
                        ddd_dose: ODDB::Dose.new(5 , 'mg'),
                        pack_dose: ODDB::Dose.new(30, 'ml'),
                        atc_code: @N05AX08.code,
                        excipiens: 'Excipiens ad Solutionem',
                        composition_text: 'risperidonum 1 mg, conserv.: E 210, excipiens ad solutionem pro 1 ml.',
                        galenic_group: 'Injektion/Infusion'
                        )
    @seq.should_receive(:atc_class).and_return(@N05AX08)
    part = ODDB::Part.new
    part.count = 1
    part.multi = 1
    part.addition = 0
    part.measure = ODDB::Dose.new('30','ml')
    @package.parts.push part
    assert_equal('ml', @package.parts.first.measure.unit)
    assert_equal(30, @package.parts.first.measure.qty)
    assert_equal('30 ml', @package.parts.first.size)
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(34, variant)
    assert_equal(ODDB::Util::Money.new(28.75, 'CHF').to_s, (price ? price.to_s : DDD_PRICE_NIL))
    assert_equal('28.75 / ( 30 ml / 30 ml )', calc)
  end
  def test_ddd_Risperdal_iksnr_56092
    # ATC code    Name       DDD    U   Adm.R   Note
    #  N05AX08   risperidone   5   mg  O
    #                        2.7   mg  P   depot
    # 56092 02 003
    # 2569514 RISPERDAL CONSTA Inj Susp 37.5 mg Inj kit N05AX08 257.30  43.31 18.53 24.78 134%
    create_test_package(iksnr: 56092, ikscd: 3, price_public: 257.30, # On ODDB the current PP is 258.79 as per 08.12.2016
                        ddd_dose: ODDB::Dose.new(5 , 'mg'),
                        pack_dose: ODDB::Dose.new(37.5, 'mg'),
                        atc_code: @N05AX08.code,
                        excipiens: '  Aqua Ad Iniectabilia Q.s. Ad Solutionem',
                        route_of_administration: 'roa_P',
                        composition_text: 'Praeparatio sicca: risperidonum 25 mg, copoly(dl-lactidum-glycolidum).
Solvens: carmellosum natricum, polysorbatum 20, dinatrii phosphas dihydricus, acidum citricum anhydricum, natrii chloridum, aqua ad iniectabilia q.s. ad solutionem pro 2 ml, pro vase, in suspensione recenter reconstituta.',
                        galenic_group: 'Injektion/Infusion'
                        )
    @seq.should_receive(:atc_class).and_return(@N05AX08)
    composition1 = flexmock('composition1', :excipiens => nil)
    composition2 = flexmock('composition2', :excipiens => 'Aqua Ad Iniectabilia Q.s. Ad Solutionem')
    @seq.should_receive(:compositions).and_return([composition1, composition2])
    # @seq.compositions = [composition1, composition2]
    part = ODDB::Part.new
    part.count = 1
    part.multi = 1
    part.addition = 0
    part.measure = ODDB::Dose.new('30','ml')
    @package.parts.push part
    assert_equal('ml', @package.parts.first.measure.unit)
    assert_equal(30, @package.parts.first.measure.qty)
    assert_equal('30 ml', @package.parts.first.size)
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(33, variant)
    assert_equal(ODDB::Util::Money.new(18.53, 'CHF').to_s, (price ? price.to_s : DDD_PRICE_NIL))
    assert_equal('257.30 / (37.5 mg / 2.7 mg)', calc)
  end
  def test_ddd_Fludex_iksnr_53975
    create_test_package(iksnr: 53975, ikscd: 11, price_public: 17.90  ,
                        ddd_dose: ODDB::Dose.new(2.5 , 'mg'),
                        pack_dose: ODDB::Dose.new(1.5, 'mg'),
                        atc_code: 'C03BA11', # C03BA11    indapamide  2.5   mg  O
                        excipiens: 'Excipiens pro Compresso Obducto.',
                        composition_text: 'indapamidum 1.5 mg, excipiens pro compresso obducto.',
                        galenic_group: 'Retard-Tabletten'
                        )
    part = ODDB::Part.new
    part.count = 30
    part.multi = 1
    part.addition = 0
    part.measure = nil
    @package.parts.push part
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(14, variant)
    skip("Don't know how to distiguish tablets where the FI says daily, but exact daily dose is something greater")
    assert_equal(ODDB::Util::Money.new(0.60, 'CHF').to_s, (price ? price.to_s : DDD_PRICE_NIL))
    assert_equal('17.90 / 30  / 1.0', calc)
    # Expected: "0.60"
    # Actual: "0.99"

  end
  def test_ddd_Symfona_iksnr_63137
    create_test_package(iksnr: 63137, ikscd: 1, price_public: 58.70,
                        pack_dose: ODDB::Dose.new(240, 'mg'),
                        atc_code: 'N06DX02',
                        ddd_dose: ODDB::Dose.new(0.12, 'g'),
                        excipiens: 'Excipiens Pro Compresso',
                        composition_text: 'ginkgo bilobae extractum acetonicum siccum 240 mg corresp. flavonglycosida ginkgo 52.8-64.8 mg et terpenlactona ginkgo 13.0-15.8 mg, DER: 35-67:1, excipiens pro compresso.',
                        galenic_group: 'Tabletten'
                        )
    part = ODDB::Part.new
    part.count = 30
    part.multi = 1
    part.addition = 0
    part.measure = nil
    @package.parts.push part
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(-3, variant)
    assert_equal('xxx', calc)
    skip('WHO recommends only 0.12 g whereas the FI recommonds one tablet of 204 mg/day')
    assert_equal(ODDB::Util::Money.new(0.98, 'CHF').to_s, (price ? price.to_s : DDD_PRICE_NIL))
  end
  def test_ddd_Symfona_iksnr_63137
    create_test_package(iksnr: 63137, ikscd: 1, price_public: 58.70,
                        pack_dose: ODDB::Dose.new(240, 'mg'),
                        atc_code: 'N06DX02',
                        ddd_dose: ODDB::Dose.new(0.12, 'g'),
                        excipiens: 'Excipiens Pro Compresso',
                        composition_text: 'ginkgo bilobae extractum acetonicum siccum 240 mg corresp. flavonglycosida ginkgo 52.8-64.8 mg et terpenlactona ginkgo 13.0-15.8 mg, DER: 35-67:1, excipiens pro compresso.',
                        galenic_group: 'Tabletten'
                        )
    part = ODDB::Part.new
    part.count = 30
    part.multi = 1
    part.addition = 0
    part.measure = nil
    @package.parts.push part
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(13, variant)
    assert_equal('58.70 / 30  / 1.0', calc)
    skip('WHO recommends only 0.12 g whereas the FI recommonds one tablet of 204 mg/day')
    assert_equal(ODDB::Util::Money.new(0.98, 'CHF').to_s, (price ? price.to_s : DDD_PRICE_NIL))
  end
  def test_ddd_Symfona_iksnr_54499
    create_test_package(iksnr: 54499, ikscd: 19, price_public: 123.90,
                        pack_dose: ODDB::Dose.new(100, 'mg'),
                        galenic_group: 'Injektion/Infusion',
                        atc_code: 'B01AB06', # Key ["Panti Xa"]
                        # WHO: B01AB06   nadroparin  2.85  TU  P   anti Xa,   thousand units
                        ddd_dose: ODDB::Dose.new(2.85, 'TU'),
                        excipiens: 'Excipiens',
                        composition_text: 'nadroparinum calcicum ca. 100 mg corresp. 11400 U.I., aqua ad iniectabilia q.s. ad solutionem pro 0.6 ml.',
                        )
    part = ODDB::Part.new
    part.count = 10
    part.multi = 1
    part.addition = 0
    part.measure = nil
    @package.parts.push part
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(41, variant)
    assert_equal(ODDB::Util::Money.new(3.10, 'CHF').to_s, (price ? price.to_s : DDD_PRICE_NIL))
    assert_equal('123.90 /  10 / 1 / ( 11400 / 2850.0)', calc)
  end
  def test_ddd_Champix_iksnr_57736
    create_test_package(iksnr: 57736, ikscd: 9, price_public: 121.35,
                  ddd_dose: ODDB::Dose.new(2 , 'mg'),
                  pack_dose: ODDB::Dose.new(1.5, 'mg'),
                  atc_code: 'N07BA03',
                  excipiens: 'Excipiens pro Compresso Obducto',
                  composition_text: ' I) 0.5 mg: vareniclinum 0.5 mg ut vareniclini tartras, excipiens pro compresso obducto.
II) 1 mg: vareniclinum 1 mg ut vareniclini tartras, color.: E 132, excipiens pro compresso obducto.'
                  )
# ch.oddb> $package.parts.first.size
#-> 11 + 42 Tablette(n) à 0.5 mg
    @active_agent_0_5_mg = ODDB::ActiveAgent.new('N07BA03')
    @active_agent_0_5_mg.dose = ODDB::Dose.new(0.5, 'mg')
    @active_agent_1_0_mg = ODDB::ActiveAgent.new('N07BA03')
    @active_agent_1_0_mg.dose = ODDB::Dose.new(1, 'mg')
    @seq.should_receive(:active_agents).and_return([@active_agent_0_5_mg, @active_agent_1_0_mg])
    part_1 = ODDB::Part.new
    part_1.count = 42
    part_1.multi = 1
    part_1.addition = 0
    part_1.measure = ODDB::Dose.new('0.5','mg')
    @package.parts.push part_1
    part_2 = ODDB::Part.new
    part_2.count = 42
    part_2.multi = 1
    part_2.addition = 0
    part_2.measure = ODDB::Dose.new('1.0','mg')
    @package.parts.push part_2
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(14, variant)
    assert_equal('121.35 / ( 42 x 1 ) x ( 2 mg / 1.5 mg ) / 1.0', calc)
    skip('Champix should return 5.11 as it contains 42 times 0.5 and 1 mg')
    assert_equal ODDB::Util::Money.new(5.11, 'CHF').to_s, price ? price.to_s : DDD_PRICE_NIL
  end
  def test_ddd_Recormon_iksnr_54766
    create_test_package(iksnr: 54766, ikscd: 76, price_public: 738.50,
                        pack_dose: ODDB::Dose.new(10000, 'UI'),
                        galenic_group: 'Injektion/Infusion',
                        atc_code: 'B03XA01', # B03XA01    erythropoietin  1   TU  P
                        ddd_dose: ODDB::Dose.new(1, 'TU'),
                        excipiens: 'Pro Praeparatione aus Gentechnisch Verändertem mais Hergestellt',
                        composition_text: %(Praeparatio cryodesiccata: epoetinum beta ADNr 10000 U.I., ureum, natrii chloridum, polysorbatum 20, natrii phosphates, calcii chloridum dihydricum, glycinum, leucinum, isoleucinum, threoninum, acidum glutamicum, phenylalaninum, pro praeparatione aus gentechnisch verändertem Mais hergestellt.
Solvens: aqua ad iniectabilia 0.6 ml, pro vase.)
                        )
    @active_agent = ODDB::ActiveAgent.new('B03XA01')
    @active_agent.dose = ODDB::Dose.new(10000,  'UI')
    @seq.should_receive(:active_agents).and_return([@active_agent])
    part = ODDB::Part.new
    part.size = '6 Spritze(n)'
    part.count = 6
    part.multi = 1
    part.addition = 0
    part.measure = nil
    @package.parts.push part
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(41, variant)
    assert_equal(ODDB::Util::Money.new(12.31, 'CHF').to_s, (price ? price.to_s : DDD_PRICE_NIL))
    assert_equal('738.50 /  6 / 1 / ( 10000 / 1000)', calc)
  end

  def test_ddd_Betaferon_iksnr_53225
    create_test_package(iksnr: 53225, ikscd: 47, price_public: 738.50,
                        pack_dose: ODDB::Dose.new(0.3, 'mg'),
                        galenic_group: 'Injektion/Infusion',
                        atc_code: 'L03AB08', #     L03AB08    interferon beta-1b  4   MU  P
                        ddd_dose: ODDB::Dose.new(4, 'MU'),
                        excipiens: 'Pro Vitro',
                        composition_text: %(Praeparatio cryodesiccata: interferonum beta-1b ADNr 0.3 mg corresp. 9.6 Mio U.I., albuminum humanum, mannitolum, pro vitro.
Solvens: natrii chloridum, aqua ad iniectabilia q.s. ad solutionem pro 1.2 ml.
Solutio reconstituta: interferonum beta-1b ADNr 0.25 mg/ml corresp. 8 Mio U.I./ml.)
                        )
    part = ODDB::Part.new
    part.size = 'Kombipackung(en)'
    part.count = 1
    part.multi = 1
    part.addition = 0
    part.measure = nil
    @package.parts.push part
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_nil(price)
    assert_nil(@package.ddd_price)
    assert_equal(4, variant)
    assert_equal('738.50 / 1  x 0.3 mg / 4 MU / 1.0', calc)
  end

  def test_ddd_Humatrope_iksnr_53052
    create_test_package(iksnr: 53052, ikscd: 53, price_public: 693.95,
                        pack_dose: ODDB::Dose.new(12, 'mg'),
                        galenic_group: 'Injektion/Infusion',
                        atc_code: 'H01AC01', # H01AC01    somatropin  2   U   P
                        ddd_dose: ODDB::Dose.new(2, 'U'),
                        excipiens: 'Pro Vitro',
                        composition_text: %(Praeparatio cryodesiccata: somatropinum ADNr 12 mg, glycinum, mannitolum, natrii phosphates, pro vitro.
Solvens: glycerolum, conserv.: metacresolum 3 mg, aqua ad iniectabilia q.s. ad solutionem pro 1 ml.)
                        )

    # agents first.dose = 12 mg
    part = ODDB::Part.new
    part.size = 'Kombipackung(en)'
    part.count = 1
    part.multi = 1
    part.addition = 0
    part.measure = nil
    @package.parts.push part
    price, calc, variant =  @package.ddd_price_calc_variant
    # we cannot compare the WHO DDD and the dose
    assert_nil(price)
    assert_nil(@package.ddd_price)
    assert_equal(4, variant)
    assert_equal('693.95 / 1  x 12 mg / 2 U / 1.0', calc)
  end
  def test_ddd_InsulinNovonordisk_iksnr_62260
    create_test_package(iksnr: 62260, ikscd: 53, price_public:72.40,
                        pack_dose: ODDB::Dose.new(100, 'UI/ml'),
                        galenic_group: 'Injektion/Infusion',
                        atc_code: 'A10AB05', # A10AB05    insulin aspart  40  U   P
                        ddd_dose: ODDB::Dose.new(40, 'U'),
                        excipiens: 'Aqua Ad Iniectabilia Q.s. Ad Solutionem',
                        composition_text: %(insulinum aspartum 100 U.I., glycerolum, zincum ut zinci chloridum, natrii phosphates, natrii chloridum, conserv.: phenolum 1.5 mg, metacresolum 1.72 mg, aqua ad iniectabilia q.s. ad solutionem pro 1 ml.)
                        )
    part = ODDB::Part.new
    part.size = 'Kombipackung(en)'
    part.count = 1
    part.multi = 5
    part.addition = 0
    part.measure = ODDB::Dose.new(3, 'ml')
    @package.parts.push part
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(53, variant)
    assert_equal(ODDB::Util::Money.new(1.93, 'CHF').to_s, (price ? price.to_s : DDD_PRICE_NIL))
    assert_equal('72.40 /  1 / 5 / ( 300/1 / 40)', calc)
  end
  def test_ddd_Heparin_iksnr_46240
    create_test_package(iksnr: 46240, ikscd: 30, price_public:22.00,
                        pack_dose: ODDB::Dose.new(1000, 'UI/ml'),
                        galenic_group: 'Injektion/Infusion',
                        atc_code: 'B01AB01', # B01AB01    heparin   10  TU  P
                        ddd_dose: ODDB::Dose.new(10, 'TU'),
                        excipiens: 'Aqua Ad Iniectabilia Q.s. Ad Solutionem',
                        composition_text: %(heparinum natricum 1000 U.I., aqua ad iniectabilia q.s. ad solutionem pro 1 ml.)
                        )
    part = ODDB::Part.new
    part.count = 1
    part.multi = 1
    part.addition = 0
    part.measure = ODDB::Dose.new(20, 'ml')
    @package.parts.push part
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(51, variant)
    # 10 TU = 22.00, 20ml*1000 UI/ml= 20000 UI = 20 TU, -> 10TU=11 Fr.
    assert_equal(ODDB::Util::Money.new(11.00, 'CHF').to_s, (price ? price.to_s : DDD_PRICE_NIL))
    assert_equal('22.00 /  1 / 1 / ( 20000/1 / 10000)', calc)
  end
  def test_ddd_Urokinase_iksnr_46240
    create_test_package(iksnr: 46240, ikscd: 66, price_public: 219.15,
                        pack_dose: ODDB::Dose.new(500000, 'UI'),
                        galenic_group: 'Injektion/Infusion',
                        atc_code: 'B01AD04', # B01AD04    urokinase   3   MU  P
                        ddd_dose: ODDB::Dose.new(3, 'MU'),
                        excipiens: 'Pro Vitro',
                        composition_text: %(Praeparatio cryodesiccata: urokinasum 500000 U.I., natrii phosphates, dinatrii phosphas dodecahydricus, natrii dihydrogenophosphas dihydricus, albuminum humanum, pro vitro.)
                        )
    part = ODDB::Part.new
    part.count = 1
    part.multi = 1
    part.addition = 0
    part.measure = nil
    @package.parts.push part
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_nil(@package.ddd_price)
    assert_equal(42, variant)
    # assert_equal(ODDB::Util::Money.new(1314.90, 'CHF').to_s, (price ? price.to_s : DDD_PRICE_NIL))
    assert_equal('', price.to_s)
    # assert_equal('219.15 /  1 / 1 / ( 500000 / 3000000)', calc)
    assert_equal('Infinity', calc)
  end
  def test_ddd_Arcoxia_iksnr_56079
    # check also :!registration,51795!sequence,01!package,040.: Aspirin Cardio 100, Filmtabletten Could not convert 1 tablet
    create_test_package(iksnr: 56079, ikscd: 65, price_public: 39.65,
                        pack_dose: ODDB::Dose.new(30, 'mg'),
                        galenic_group: 'tablet',
                        atc_code: 'M01AH05', # M01AH05    etoricoxib  60  mg  O
                        ddd_dose: ODDB::Dose.new(60, 'mg'),
                        excipiens: 'Pro Vitro',
                        composition_text: %(
                        etoricoxibum 30 mg, color.: E 132.
excipiens pro compresso obducto.
)
                        )
    part = ODDB::Part.new
    part.count = 28
    part.multi = 1
    part.addition = 0
    part.measure = ODDB::Dose.new(30, 'mg')
    @package.parts.push part
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(14, variant)
    assert_equal(ODDB::Util::Money.new(2.83, 'CHF').to_s, (price ? price.to_s : DDD_PRICE_NIL))
    assert_equal('39.65 / ( 28 x 1 ) x ( 60 mg / 30 mg ) / 1.0', calc)
  end

  def test_dose_mio_UI_per_ml
    # :!registration,59055!sequence,01!package,001.: Binocrit 1000 IE/0,5 ml, Injektionslösung in Fertigspritzen Could not convert 1000U.I. / 0.5ml
    res = @package.quanty_to_unit('1000U.I. / 0.5ml')
    expected = Unit.new(1000, 'UI / ml')
    assert(expected.compatible?(res))
  end
  def test_dose_mio_UI
    # :!registration,36631!sequence,02!package,067.: Penicillin Spirig HC 1 Mio U.I., Filmtabletten Could not convert 1 Mio UI
    res = @package.quanty_to_unit('1 Mio UI')
    expected = Unit.new(1000*1000, 'UI')
    assert(expected.compatible?(res))
    assert_equal(res, expected)
  end
  def test_dose_mio_UI_ml
    # :!registration,51035!sequence,06!package,186.: Neupogen Amgen 30, Fertigspritzen Could not convert 30Mio. U. / 0.5ml
    res = @package.quanty_to_unit('30Mio. U. / 0.5ml')
    expected = Unit.new(60, 'MU/ml')
    assert(expected.compatible?(res))
    assert_equal(res, expected)
  end
  def test_dose_1400_IE
    # :!registration,47473!sequence,02!package,055.: Miacalcic mite 100, Nasalspray Could not convert 1400 IE
    res = @package.quanty_to_unit('1400 IE')
    expected = Unit.new(1400, 'U')
    assert(expected.compatible?(res))
    assert_equal(res, expected)
  end

  def test_ddd_Collu_Blache_iksnr_36030
    skip('this package should never have a dose of mg/ml/ml after parsing!')
    create_test_package(iksnr: 36030, ikscd: 11, price_public: 10.20,
                        pack_dose: ODDB::Dose.new(0.6, 'mg/ml/ml'),
                        galenic_group: 'Buccal-/Dentalprodukte',
                        atc_code: 'R02AA05', # R02AA05    chlorhexidine   30  mg  O
                        ddd_dose: ODDB::Dose.new(30, 'mg'),
                        excipiens: 'Excipiens ad Solutionem',
                        composition_text: 'chlorhexidini digluconas 0.5 mg/ml corresp. chlorhexidini digluconas 0.11 mg pro dosi, oxybuprocaini hydrochloridum 0.10 mg/ml corresp. oxybuprocaini hydrochloridum 0.022 mg pro dosi, aromatica, saccharinum natricum, excipiens ad solutionem pro 1 ml.'
                        )
    part = ODDB::Part.new
    part.count = 28
    part.multi = 1
    part.addition = 0
    part.measure = ODDB::Dose.new(50, 'ml')
    @package.parts.push part
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(14, variant)
    assert_equal(ODDB::Util::Money.new(2.83, 'CHF').to_s, (price ? price.to_s : DDD_PRICE_NIL))
    assert_equal('39.65 / 28 x ( 60 mg / 30 mg ) / 1.0', calc)
  end
  def test_ddd_Cardio_Spirig_iksnr_66097
    create_test_package(iksnr: 66097, ikscd: 11, price_public: 6.90,
                        pack_dose: ODDB::Dose.new(100, 'mg'),
                        galenic_group: 'Retard-Tabletten',
                        atc_code: 'B01AC06', # B01AC06    acetylsalicylic acid  1   tablet  O   Independent of strength
                        route_of_administration: 'roa_0',
                        ddd_dose: ODDB::Dose.new(30, 'mg'),
                        excipiens: 'Excipiens pro Compresso Obducto.',
                        composition_text: 'acidum acetylsalicylicum 100 mg, excipiens pro compresso obducto.'
                        )
    @ddd_o = ODDB::AtcClass::DDD.new('OIndependent of strength')
    @ddd_o.dose = ODDB::Dose.new(30, 'mg')
    @atc = flexmock('atc_class', :has_ddd? => true, :ddds => {'OIndependent of strength' => @ddd_o,}, :code => 'B01AC06')
    @seq.should_receive(:atc_class).and_return(@atc)
    # OIndependent of strength
    part = ODDB::Part.new
    part.count = 30
    part.multi = 1
    part.addition = 0
    part.measure = nil
    @package.parts.push part
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(price,  @package.ddd_price)
    assert_equal(50, variant)
    assert_equal(ODDB::Util::Money.new(0.23, 'CHF').to_s, (price ? price.to_s : DDD_PRICE_NIL))
    assert_equal('6.90 /  30 / 1', calc)
  end
  def test_ddd_Tramal_Retard_iksnr_53683
    create_test_package(iksnr: 53683, ikscd: 10, price_public: 8.05,
                        pack_dose: ODDB::Dose.new(100, 'mg'),
                        galenic_group: 'Retard-Tabletten',
                        atc_code: 'N02AX02', # N02AX02    tramadol  0.3   g   O
#    0.3   g   P
#    0.3   g   R
                        route_of_administration: 'roa_0',
                        ddd_dose: ODDB::Dose.new(0.3, 'g'),
                        excipiens: 'Excipiens pro Compresso Obducto.',
                        composition_text: 'tramadoli hydrochloridum 100 mg, excipiens pro compresso obducto.'
                        )
    # OIndependent of strength
    part = ODDB::Part.new
    part.count = 10
    part.multi = 1
    part.addition = 0
    part.measure = nil
    @package.parts.push part
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(ODDB::Util::Money.new(2.42, 'CHF').to_s, (price ? price.to_s : DDD_PRICE_NIL))
    assert_equal('8.05 / ( 10 x 1 ) x ( 0.3 g / 100 mg ) / 1.0', calc)
    assert_equal(14, variant)
    assert_equal(price,  @package.ddd_price)
  end
  def test_ddd_Tibolon_iksnr_65334
    create_test_package(iksnr: 65334, ikscd: 2, price_public: 65.00,
                        pack_dose: ODDB::Dose.new(2.5, 'mg'),
                        galenic_group: 'Tabletten',
                        atc_code: 'G03CX01', # G03CX01    tibolone  2.5   mg  O
                        route_of_administration: 'roa_0',
                        ddd_dose: ODDB::Dose.new(2.5, 'mg'),
                        excipiens: 'Excipiens Pro Compresso',
                        composition_text: 'Tablette: tibolonum 2.5 mg, excipiens pro compresso.'
                        )
    part = ODDB::Part.new
    part.count = 28
    part.multi = 3
    part.addition = 0
    part.measure = nil
    @package.parts.push part
    price, calc, variant =  @package.ddd_price_calc_variant
    assert_equal(14, variant)
    assert_equal('65.00 / ( 28 x 3 ) x ( 2.5 mg / 2.5 mg ) / 1.0', calc)
    assert_equal(ODDB::Util::Money.new(0.77, 'CHF').to_s, (price ? price.to_s : DDD_PRICE_NIL))
    assert_equal(price,  @package.ddd_price)
  end
  def test_ddd_Alendronat_iksnr_58215
    # FI says Wochentabletten: 70 mg Alendronat als Alendronat Natriumtrihydrat 91,37 mg.
    create_test_package(iksnr: 58215, ikscd: 3, price_public: 34.25,
                        pack_dose: ODDB::Dose.new(70, 'mg'),
                        galenic_group: 'Tabletten',
                        atc_code: 'M05BA04', # M05BA04    alendronic acid   10  mg  O
                        ddd_dose: ODDB::Dose.new(10, 'mg'),
                        excipiens: 'Excipiens Pro Compresso',
                        composition_text: 'acidum alendronicum 70 mg ut natrii alendronas trihydricus, excipiens pro compresso.'
                        )
    fachinfo = flexmock('fi', ODDB::FachinfoDocument2001.new);
    descriptions = flexmock('descriptions');
    fachinfo.should_receive(:descriptions).and_return{ { 'de' => descriptions }}
    descriptions.should_receive(:usage).and_return('Die empfohlene Dosierung beträgt eine Wochentablette (70 mg) pro Woche.')
    alendronat =flexmock('package_alendronat', @package)
    alendronat.should_receive(:fachinfo).and_return(fachinfo)
    # @package.should_receive.once(:fachinfo).and_return(fi)
    # @seq.should_receive.once(:fachinfo).and_return(fi)
    part = ODDB::Part.new
    part.count = 4
    part.multi = 1
    part.addition = 0
    part.measure = nil
    alendronat.parts.push part
    price, calc, variant =  alendronat.ddd_price_calc_variant
    assert_equal(ODDB::Util::Money.new(1.22, 'CHF').to_s, (price ? price.to_s : DDD_PRICE_NIL))
    assert_equal(15, variant)
    assert_equal(price,  alendronat.ddd_price)
    assert_equal('34.25 / ( 4 x 1 ) / 7', calc)
  end

# Luveris reg/55430/seq/01   Praeparatio cryodesiccata: lutropinum alfa 3.7 µg, saccharum, dinatrii phosphas dihydricus, natrii dihydrogenophosphas monohydricus, polysorbatum 20, methioninum, nitrogenium, pro vitro.
# Solvens: aqua ad iniectabilia 1 ml.
# WHO has G03GA07   lutropin alfa   75  U   P
# FI:  Eine Durchstechflasche mit Pulver enthält 3,7 µg Lutropin alfa, damit mindestens 75 IE entnommen werden können.

# Xeplion
# WHO: N05AX13    paliperidone  6   mg  O
#    2.5   mg  P   depot Expressed as paliperidone
# paliperidonum 25 mg ut paliperidoni palmitas, polysorbatum 20, macrogolum 4000, acidum citricum monohydricum, dinatrii phosphas anhydricus, natrii dihydrogenophosphas monohydricus, aqua ad iniectabilia q.s. ad suspensionem pro 0.25 ml.
# FI Bei Xeplion (Paliperidonpalmitat) Retardsuspension zur intramuskulären Injektion handelt es sich um eine weisse bis cremefarbige Suspension in Fertigspritzen.
#Mismatch of expected_price in ["65334", "002"]: 2.32 != 0.77 diff 201.30%
#   65334002;65334;2;6215115;Tibolon-Mepha, Tabletten;G03CX01;O;O;2.5 mg;2.5 mg;roa_O;Tabletten;65.00;2.32;84;1;Stk;2.5;mg;Tibolon;1;2.5;mg;O;DDD-WHO;84;0.77

   bin_admin_snippet = %(
$package = registration('58215').package('003')
$package.seqnr
$package.price_public.to_s
$package.galenic_group
$package.dose
$package.route_of_administration
$package.longevity
$package.parts.size
$package.atc_class
$package.atc_class.code
$package.atc_class.ddds.keys
$package.atc_class.ddds.values.first.dose
$package.atc_class.ddds.values.last.dose
$package.parts.size
$package.parts.first.size
$package.parts.first.addition
$package.parts.first.count
$package.parts.first.multi
$package.parts.first.measure
$package.parts.first.measure.class
$package.active_agents.size
$package.active_agents.first
$package.active_agents.first.dose
$package.compositions.first.corresp
$package.compositions.first.excipiens
$package.sequence.composition_text

 )
end
