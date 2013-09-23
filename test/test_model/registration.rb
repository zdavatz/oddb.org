# encoding: utf-8
# TestRegistration -- oddb.org -- 18.04.2012 -- yasaka@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'stub/odba'
gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'model/registration'

module ODDB
  class RegistrationCommon
    attr_accessor :sequences
    attr_reader :replaced, :fachinfo_oid
    public :adjust_types
    check_accessor_list = {
      :generic_type            => ["Symbol", "String"],
      :complementary_type      => "Symbol",
      :registration_date       => ["DateTime","Date"],
      :export_flag             => ["FalseClass","NilClass","TrueClass"],
      :company                 => ["ODDB::Company"],
      :revision_date           => "Date",
      :indication              => "ODDB::Indication",
      :expiration_date         => "Date",
      :inactive_date           => "Date",
      :manual_inactive_date    => "Date",
      :deactivate_fachinfo     => "Date",
      :activate_fachinfo       => "Date",
      :market_date             => "Date",
      :fachinfo                => "ODDB::Fachinfo",
      :source                  => "String",
      :ikscat                  => "String",
      :renewal_flag            => ["NilClass","FalseClass","TrueClass"],
      :renewal_flag_swissmedic => ["NilClass","FalseClass","TrueClass"],
      :index_therapeuticus     => "String",
      :comarketing_with        => ["ODDB::Registration", "String"],
      :vaccine                 => ["TrueClass","NilClass","FalseClass"],
      :ignore_patent           => ["NilClass","TrueClass","FalseClass"],
      :parallel_import         => ["NilClass","TrueClass","FalseClass"],
      :minifi                  => "ODDB::MiniFi",
      :product_group           => "String",
      :production_science      => "String",
      :ith_swissmedic          => "String",
      :keep_generic_type       => ["NilClass","TrueClass","FalseClass"],
    }
    define_check_class_methods check_accessor_list
  end
  module Persistence
    class Pointer
      attr_reader :directions
    end
  end
end
class StubRegistrationSequence
  attr_reader :seqnr, :accepted, :block_result
  attr_accessor :registration, :atc_class, :name, :substance_names
  def initialize(key)
    @seqnr = key
  end
  def accepted!(*args)
    @accepted = true
  end
  def acceptable?
    @atc_class && @name
  end
  def each_package (&block)
    @block_result = block.call(@seqnr)
  end
  def package_count
    4
  end
end
class StubRegistrationCompany
  attr_reader :name, :registrations
  def initialize(name)
    @name = name
    @registrations = []
  end
  def oid
    1
  end
  def add_registration(registration)
    @registrations.push(registration)
  end
  def remove_registration(registration)
    @registrations.delete_if { |reg| reg == registration }
  end
end
class StubRegistrationApp
  attr_reader :pointer, :values, :delete_pointer
  def initialize
    @companies = {}
  end
  def company(name)
    @companies[name] ||= StubRegistrationCompany.new(name)
  end
  def update(pointer, values)
    @pointer, @values = pointer, values
  end
  def delete(pointer)
    @delete_pointer = pointer
  end
end
class StubRegistrationIndication
  attr_reader :added, :removed
  attr_accessor :oid
  def add_registration(reg)
    @added = reg
  end
  def remove_registration(reg)
    @removed = reg
  end
end
class StubRegistrationPatinfo
  attr_reader :added, :removed
  def add_registration(reg)
    @added = reg
  end
  def remove_registration(reg)
    @removed = reg
  end
end
class TestRegistration <Minitest::Test
  include FlexMock::TestCase
  def setup
    @registration = ODDB::Registration.new('12345')
  end
  def test_active
    assert_equal(true, @registration.active?)
    @registration.inactive_date = (Date.today >> 1)
    assert_equal(true, @registration.active?)
    @registration.inactive_date = Date.today 
    assert_equal(false, @registration.active?)
  end
  def test_active__renewal
    assert_equal(true, @registration.active?)
    @registration.expiration_date = @@two_years_ago - 1 
    assert_equal(nil, @registration.active?)
    @registration.renewal_flag = true
    assert_equal(true, @registration.active?)
  end
  def test_active_packages
    seq1 = flexmock :active_packages => ['pac1', 'pac2']
    seq2 = flexmock :active_packages => ['pac3']
    @registration.sequences.update '01' => seq1, '02' => seq2
    assert_equal %w{pac1 pac2 pac3}, @registration.active_packages
    @registration.expiration_date = @@two_years_ago
    assert_equal [], @registration.active_packages
  end
  def test_active_package_count
    seq1 = flexmock :active_package_count => 2
    seq2 = flexmock :active_package_count => 1
    @registration.sequences.update '01' => seq1, '02' => seq2
    assert_equal 3, @registration.active_package_count
    @registration.expiration_date = @@two_years_ago
    assert_equal 0, @registration.active_package_count
  end
  def test_adjust_types1
    values = {
      :registration_date	=>	nil,
      :revision_date			=>	nil,
      :expiration_date		=>	nil,
      :inactive_date			=>	nil,
      :market_date				=>	nil,
    }
    expected = {
      :registration_date	=>	nil,
      :revision_date			=>	nil,
      :expiration_date		=>	nil,
      :inactive_date			=>	nil,
      :market_date				=>	nil,
    }
    assert_equal(expected, @registration.adjust_types(values))
  end
  def test_adjust_types2
    @registration.registration_date = Date.new(2002,1,1)
    values = {
      :registration_date	=>	'2002-02-02',
      :revision_date			=>	Date.new(2003,1,30),
      :expiration_date		=>	'2004-12-20',
      :inactive_date			=>	'2004-12-20',
    }
    expected = {
      :registration_date	=>	Date.new(2002,2,2),
      :revision_date			=>	Date.new(2003,1,30),
      :expiration_date		=>	Date.new(2004,12,20),
      :inactive_date			=>	Date.new(2004,12,20),
    }
    assert_equal(expected, @registration.adjust_types(values))
  end
  def test_atcless_sequences
    seq1 = StubRegistrationSequence.new('01')
    seq2 = StubRegistrationSequence.new('02')
    seq2.atc_class = 'foo'
    @registration.sequences = {
      '01'	=>	seq1,
      '02'	=>	seq2,
    }
    expected = [ seq1 ]
    assert_equal(expected, @registration.atcless_sequences)
  end
  def test_atc_classes
    seq1 = flexmock :atc_class => 'atc1'
    seq2 = flexmock :atc_class => 'atc2'
    seq3 = flexmock :atc_class => nil
    seq4 = flexmock :atc_class => 'atc1'
    @registration.sequences.update '01' => seq1, '02' => seq2,
                                   '03' => seq3, '04' => seq4
    assert_equal %w{atc1 atc2}, @registration.atc_classes
  end
  def test_checkout
    seq1 = flexmock('Sequence1')
    seq2 = flexmock('Sequence2')
    sequences = {
      "01"	=>	seq1,
      "02"	=>	seq2,
    }
    @registration.instance_variable_set('@sequences', sequences)
    seq1.should_receive(:checkout).and_return { 
      assert(true)	
    }
    seq1.should_receive(:odba_delete).and_return { 
      assert(true)	
    }
    seq2.should_receive(:checkout).and_return { 
      assert(true)	
    }
    seq2.should_receive(:odba_delete).and_return { 
      assert(true)	
    }
    @registration.checkout
  end
  def test_company_name
    assert_nil @registration.company_name
    @registration.company = flexmock :name => 'Company Name'
    assert_equal 'Company Name', @registration.company_name
  end
  def test_complementary_type
    assert_nil @registration.complementary_type
    @registration.company = flexmock :complementary_type => :original
    assert_equal :original, @registration.complementary_type
    @registration.complementary_type = :generic
    assert_equal :generic, @registration.complementary_type
  end
  def test_compositions
    seq1 = flexmock :compositions => ['cmp1', 'cmp2']
    seq2 = flexmock :compositions => ['cmp3']
    @registration.sequences.update '01' => seq1, '02' => seq2
    assert_equal %w{cmp1 cmp2 cmp3}, @registration.compositions
  end
  def test_create_patent
    assert_nil @registration.patent
    @registration.create_patent
    assert_instance_of ODDB::Patent, @registration.patent
  end
  def test_create_sequence
    @registration.sequences = {}
    seq = @registration.create_sequence('01')
    assert_equal(seq, @registration.sequences['01'])
    assert_equal(@registration, seq.registration)
    seq1 = @registration.create_sequence(2)
    assert_equal(seq1, @registration.sequences['02'])
  end
  def test_delete_patent
    @registration.instance_variable_set '@patent', 'A Patent'
    @registration.delete_patent
    assert_nil @registration.patent
  end
  def test_diff
    values = {
      :registration_date	=>	'12.04.2002',
      :generic_type			=>	:generic,
    }
    expected = {
      :registration_date	=>	Date.new(2002,4,12),
      :generic_type			=>	:generic,
    }
    diff = @registration.diff(values)
    assert_equal(expected, diff)
    @registration.update_values(diff)
    assert_equal({}, @registration.diff(values))
  end
  def test_each_package
    seq1 = StubRegistrationSequence.new(1)
    seq2 = StubRegistrationSequence.new(2)
    seq3 = StubRegistrationSequence.new(3)
    @registration.sequences = {
      1 => seq1,
      2 => seq2,
      3 => seq3,
    }
    @registration.each_package { |seq|
      seq*seq
    }
    assert_equal(1, seq1.block_result)
    assert_equal(4, seq2.block_result)
    assert_equal(9, seq3.block_result)
  end
  def test_fachinfo_writer
    fachinfo1 = StubRegistrationIndication.new
    fachinfo1.oid = 2
    fachinfo2 = StubRegistrationIndication.new
    fachinfo2.oid = 3
    @registration.fachinfo = fachinfo1
    assert_equal(@registration, fachinfo1.added)
    assert_nil(fachinfo1.removed)
    @registration.fachinfo = fachinfo2
    assert_equal(@registration, fachinfo1.removed)
    assert_equal(@registration, fachinfo2.added)
    assert_equal(@registration.fachinfo.oid, 3)
    assert_nil(fachinfo2.removed)
    @registration.fachinfo = nil
    assert_equal(@registration, fachinfo2.removed)
  end
  def test_generic_type
    company = flexmock "company"
    @registration.company = company 
    company.should_receive(:generic_type).and_return { "complementary" }	
    assert_equal("complementary", @registration.generic_type)
    @registration.generic_type = "generic"
    assert_equal("generic", @registration.generic_type)
  end
  def test_iksnr
    assert_respond_to(@registration, :iksnr)
    assert_equal('12345', @registration.iksnr)
  end
  def test_indication_writer
    indication1 = StubRegistrationIndication.new
    indication2 = StubRegistrationIndication.new
    @registration.indication = indication1
    assert_equal(indication1, @registration.indication)
    assert_equal(@registration, indication1.added)
    assert_nil(indication1.removed)
    @registration.indication = indication2
    assert_equal(@registration, indication1.removed)
    assert_equal(@registration, indication2.added)
    assert_nil(indication2.removed)
    @registration.indication = nil
    assert_equal(@registration, indication2.removed)
  end
  def test_limitation_text_count
    seq1 = flexmock :limitation_text_count => 2
    seq2 = flexmock :limitation_text_count => 1
    @registration.sequences.update '01' => seq1, '02' => seq2
    assert_equal 3, @registration.limitation_text_count
  end
  def test_localized_name
    @registration.sequences = {}
    assert_nothing_raised { @registration.localized_name(:de) }
    seq = flexmock :name_base => 'A Name'
    seq.should_receive(:localized_name).with(:de).and_return 'Localized Name'
    @registration.sequences.update '02' => seq
    assert_equal 'Localized Name', @registration.localized_name(:de)
  end
  def test_may_violate_patent
    assert_equal nil, @registration.may_violate_patent?
    @registration.registration_date = @@today
    assert_equal true, @registration.may_violate_patent?
    @registration.registration_date = @@one_year_ago
    assert_equal false, @registration.may_violate_patent?
    @registration.registration_date = @@one_year_ago + 1
    assert_equal true, @registration.may_violate_patent?
    @registration.comarketing_with = 'something'
    assert_equal false, @registration.may_violate_patent?
    @registration.comarketing_with = nil
    @registration.generic_type = :original
    assert_equal false, @registration.may_violate_patent?
    @registration.generic_type = :generic
    assert_equal true, @registration.may_violate_patent?
  end
  def test_name_base
    @registration.sequences = {}
    assert_nothing_raised { @registration.name_base }
    seq = flexmock :name_base => 'A Name'
    @registration.sequences.store '02', seq
    assert_equal 'A Name', @registration.name_base
  end
  def test_original
    assert_equal false, @registration.original?
    @registration.generic_type = :original
    assert_equal true, @registration.original?
    @registration.generic_type = :generic
    assert_equal false, @registration.original?
  end
  def test_out_of_trade
    assert_equal true, @registration.out_of_trade
    seq1 = flexmock :out_of_trade => true
    @registration.sequences.store '01', seq1
    assert_equal true, @registration.out_of_trade
    seq2 = flexmock :out_of_trade => false
    @registration.sequences.store '02', seq2
    assert_equal false, @registration.out_of_trade

    seq2 = flexmock :out_of_trade => false
  end
  def test_package_count
    @registration.sequences = {
      'seq1'	=>	StubRegistrationSequence.new(1),
      'seq2'	=>	StubRegistrationSequence.new(2),
      'seq3'	=>	StubRegistrationSequence.new(3),
    }
    result = @registration.package_count
    assert_equal(12, result)
  end
  def test_package
    assert_nil @registration.package('001')
    seq1 = flexmock 'sequence'
    seq1.should_receive(:package).with('001').and_return 'package'
    @registration.sequences.store '01', seq1
    assert_equal 'package', @registration.package('001')
    seq1.should_receive(:package).with('002').and_return nil
    assert_nil @registration.package('002')
  end
  def test_packages
    seq1 = flexmock :packages => {'001' => 'pac1', '002' => 'pac2'}
    seq2 = flexmock :packages => {'003' => 'pac3'}
    @registration.sequences.update '01' => seq1, '02' => seq2
    assert_equal %w{pac1 pac2 pac3}, @registration.packages
    @registration.expiration_date = @@two_years_ago
    assert_equal %w{pac1 pac2 pac3}, @registration.packages
  end
  def test_patent_protected
    assert_equal nil, @registration.patent_protected?
    pat1 = flexmock :protected? => false
    @registration.instance_variable_set '@patent', pat1
    assert_equal false, @registration.patent_protected?
    pat2 = flexmock :protected? => true
    @registration.instance_variable_set '@patent', pat2
    assert_equal true, @registration.patent_protected?
  end
  def test_public
    assert_equal true, @registration.public?
    @registration.export_flag = true
    assert_equal false, @registration.public?
  end
  def test_public_package_count
    seq1 = flexmock :public_package_count => 2
    seq2 = flexmock :public_package_count => 1
    @registration.sequences.update '01' => seq1, '02' => seq2
    assert_equal 3, @registration.public_package_count
    @registration.expiration_date = @@two_years_ago
    assert_equal 0, @registration.public_package_count
  end
  def test_sequence
    seq = StubRegistrationSequence.new('01')
    @registration.sequences = {'01'=>seq }
    assert_equal(seq, @registration.sequence('01'))
  end
  def test_substance_names
    sequence = StubRegistrationSequence.new(1)
    expected = ["Milch", "Rahm"]
    sequence.substance_names = expected
    @registration.sequences = {
      '3434' => sequence,
    }
    assert_equal(expected, @registration.substance_names)
  end
  def test_update_values
    assert_nil(@registration.registration_date)
    values = {
      :registration_date	=>	'12.04.2002',
      :company						=>	'Bayer (Schweiz) AG',
      :generic_type				=>	:generic,
    }
    app = StubRegistrationApp.new
    @registration.update_values(@registration.diff(values, app))
    assert_equal(Date.new(2002,4,12), @registration.registration_date)
    company = @registration.company
    assert_equal(app.company('Bayer (Schweiz) AG'), company)
    assert_equal(:generic, @registration.generic_type)
    assert_equal(@registration, company.registrations.first)
    values[:company] = 'Jansen Cilag AG'
    @registration.update_values(@registration.diff(values, app))
    assert_equal([], company.registrations)
  end
end
