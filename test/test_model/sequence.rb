#!/usr/bin/env ruby
# encoding: utf-8
# TestSequence -- oddb -- 18.04.2012 -- yasaka@ywesee.com
# TestSequence -- oddb -- 25.02.2003 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'stub/odba'
gem 'minitest'
require 'minitest/autorun'
require 'model/sequence'
require 'model/atcclass'
require 'model/registration'
require 'model/substance'
require 'util/searchterms'
require 'flexmock'

module ODDB
  class SequenceCommon
    attr_writer :packages
    attr_reader :patinfo_oid
    public :adjust_types
    check_accessor_list = {
      :registration       => ["ODDB::Registration", "FlexMock"],
      :atc_class          => ["ODDB::AtcClass", "StubSequenceAtcClass", "FlexMock"],
      :export_flag        => ["NilClass","FalseClass","TrueClass"],
      :patinfo            => ["ODDB::Patinfo", "TestSequence::StubPatinfo"],
      :pdf_patinfo        => "String",
      :atc_request_time   => "Time",
      :deactivate_patinfo => ["NilClass","Date"],
      :sequence_date      => ["NilClass", "Date"],
      :activate_patinfo   => ["NilClass","Date"],
      :composition_text   => "String",
      :dose               => ["NilClass","ODDB::Dose"],
      #:inactive_date     => "Date",
    }
    define_check_class_methods check_accessor_list
  end
end
class StubSequenceGalenicForm
  attr_reader :added, :removed
  def equivalent_to?(other)
    self==other
  end
  def add_sequence(seq)
    @added = seq
  end
  def remove_sequence(seq)
    @removed = seq
  end
end
class StubSequenceAtcClass
  attr_reader :state
  attr_accessor :sequences, :code
  def initialize
    @sequences = []
  end
  def add_sequence(sequence)
    @sequences.push(sequence)
    @state = :added
  end
  def remove_sequence(sequence)
    @state = :removed
  end
end
class StubSequenceApp
  attr_writer :substances
  attr_reader :pointer, :values
  def initialize
    @atc = {}
    @substances = []
    @galforms = {}
  end
  def atc_class(atc)
    @atc[atc] ||= ODDB::AtcClass.new(atc)
  end
  def galenic_form(galform)
    @galforms[galform] ||= StubSequenceGalenicForm.new
  end
  def sequence(key)
  end
  def substance(key)
    @substances.first
  end
  def update(pointer, values)
    @pointer, @values = pointer, values
  end
end
class StubAcceptable
  attr_reader :accepted
  def accepted!(*args)
    @accepted = true
  end
end
class TestSequence <Minitest::Test
  include FlexMock::TestCase
  class StubPatinfo
    attr_accessor :oid
    attr_reader :added, :removed
    def add_sequence(seq)
      @added = seq
    end
    def remove_sequence(seq)
      @removed = seq
    end
  end
  class StubActiveAgent
    attr_accessor :substance
  end
  def setup
    @active_registration = ODDB::Registration.new(1)
    @seq = ODDB::Sequence.new(1)
    @seq.pointer = ODDB::Persistence::Pointer.new([:sequence, 1])
  end
  def test_active
    @seq.registration = flexmock("ODDB::Registration", :active? => false)
    assert_equal false, @seq.active?
    @seq.registration = @active_registration
    assert_equal true, @seq.active?
    @seq.inactive_date = @@two_years_ago
    assert_equal false, @seq.active?
    @seq.inactive_date = @@two_years_ago + 1
    assert_equal true, @seq.active?
    @seq.registration = flexmock :active? => true, :company => 'company',
                                 :may_violate_patent? => true
    seq = flexmock :patent_protected? => true, :company => 'other',
                   :active_agents => []
    @seq.atc_class = flexmock :sequences => [seq]
    assert_equal false, @seq.active?
  end
  def test_active_packages
    pac1 = flexmock :active? => true
    pac2 = flexmock :active? => false
    @seq.packages.update '001' => pac1, '002' => pac2
    assert_equal [], @seq.active_packages
    @seq.registration = @active_registration
    assert_equal [pac1], @seq.active_packages
  end
  def test_active_package_count
    pac1 = flexmock :active? => true
    pac2 = flexmock :active? => false
    @seq.packages.update '001' => pac1, '002' => pac2
    assert_equal 0, @seq.active_package_count
    @seq.registration = @active_registration
    assert_equal 1, @seq.active_package_count
  end
  def test_active_patinfo
    assert_nil @seq.active_patinfo
    @seq.pdf_patinfo = 'path-to.pdf'
    assert_nil @seq.active_patinfo
    @seq.registration = @active_registration
    assert_equal 'path-to.pdf', @seq.active_patinfo
    @seq.deactivate_patinfo = @@today
    assert_equal false, @seq.active_patinfo
  end
  def test_active_agents
    assert_equal [], @seq.active_agents
    @seq.compositions.push flexmock(:active_agents => ['act1', 'act2']),
                           flexmock(:active_agents => ['act3'])
    assert_equal ['act1', 'act2', 'act3'], @seq.active_agents
  end
  def test_adjust_types
    values = {
      :galenic_form =>  ODDB::Persistence::Pointer.new([:galenic_form, 'Tabletten']),
      :name					=>	"Aspirin Cardio",
      :dose					=>	[100, 'mg'],
      :atc_class		=>	'N02BA01',
    }
    app = StubSequenceApp.new
    expected = {
      :galenic_form =>  app.galenic_form('Tabletten'),
      :name					=>	"Aspirin Cardio",
      :dose					=>	ODDB::Dose.new(100, 'mg'),
      :atc_class		=>	app.atc_class('N02BA01'),
    }
    assert_equal(expected, @seq.adjust_types(values, app))
  end
  def test_adjust_types__2
    values = {
      :galenic_form =>  ODDB::Persistence::Pointer.new([:galenic_form, 'Tabletten']),
      :name					=>	"Aspirin Cardio",
      :dose					=>	ODDB::Dose.new(100, 'mg'),
      :atc_class		=>	'N02BA01',
      :inactive_date=> '10.11.2010',
    }
    app = StubSequenceApp.new
    expected = {
      :galenic_form =>  app.galenic_form('Tabletten'),
      :name					=>	"Aspirin Cardio",
      :dose					=>	ODDB::Dose.new(100, 'mg'),
      :atc_class		=>	app.atc_class('N02BA01'),
      :inactive_date=> Date.new(2010,11,10),
    }
    assert_equal(expected, @seq.adjust_types(values, app))
  end
  def test_atc_class_writer
    @seq.atc_class = nil
    atc1 = StubSequenceAtcClass.new
    atc2 = StubSequenceAtcClass.new
    assert_nil(atc1.state)
    assert_nil(atc2.state)
    @seq.atc_class = atc1
    assert_equal(:added, atc1.state)
    assert_nil(atc2.state)
    @seq.atc_class = nil
    assert_equal(:added, atc1.state)
    assert_nil(atc2.state)
    assert_equal(atc1, @seq.atc_class)
    @seq.atc_class = atc2
    assert_equal(:removed, atc1.state)
    assert_equal(:added, atc2.state)
  end
  def test_basename
    assert_nil @seq.basename
    @seq.name_base = 'Some Product'
    assert_equal 'Some Product', @seq.basename
    @seq.name_base = 'Some Product 50 mg'
    ## should possibly be stripped?
    assert_equal 'Some Product ', @seq.basename
    @seq.name_base = '4N Product 50 mg'
    assert_equal '4N Product ', @seq.basename
  end
  def test_checkout
    atc = flexmock 'atc'
    atc.should_receive(:respond_to?).with(:remove_sequence).and_return true
    atc.should_receive(:remove_sequence).with(@seq).times(1).and_return do
      assert true
    end
    @seq.instance_variable_set '@atc_class', atc
    patinfo = flexmock 'patinfo'
    patinfo.should_receive(:respond_to?).with(:remove_sequence).and_return true
    patinfo.should_receive(:remove_sequence).with(@seq).times(1).and_return do
      assert true
    end
    @seq.instance_variable_set '@patinfo', patinfo
    pac = flexmock 'package'
    pac.should_receive(:checkout).times(1).and_return do
      assert true
    end
    pac.should_receive(:odba_delete).times(1).and_return do
      assert true
    end
    @seq.packages.store '001', pac
    comp = flexmock 'composition'
    comp.should_receive(:checkout).times(1).and_return do
      assert true
    end
    comp.should_receive(:odba_delete).times(1).and_return do
      assert true
    end
    @seq.compositions.push comp
    @seq.checkout
  end
  def test_comparables
    assert_equal [], @seq.comparables
    seq1 = flexmock 'seq1', :compositions => [], :active? => true
    seq2 = flexmock 'seq2', :compositions => ['different'], :active? => true
    atc = flexmock :sequences => [seq1, seq2]
    @seq.instance_variable_set('@atc_class', atc)
    assert_equal [seq1], @seq.comparables
  end
  def test_comparables1
    reg = flexmock
    reg.should_receive(:active?).and_return { true }
    reg.should_receive(:may_violate_patent?).and_return { false }
    @seq.registration = reg
    atc = StubSequenceAtcClass.new
    @seq.atc_class = atc
    comp = ODDB::Composition.new
    subst = ODDB::Substance.new
    subst.descriptions.store 'lt', 'LEVOMENTHOLUM'
    active_agent = ODDB::ActiveAgent.new('LEVOMENTHOLUM')
    active_agent.substance = subst
    active_agent.composition = comp
    @seq.compositions.push comp
    comp.galenic_form = StubSequenceGalenicForm.new
    comparable = ODDB::Sequence.new('02')
    comparable.registration = reg
    comparable.atc_class = atc
    comparable.compositions.push comp
    assert_equal([comparable], @seq.comparables)
  end
  def test_comparables2
    reg = flexmock
    reg.should_receive(:active?).and_return { true }
    reg.should_receive(:may_violate_patent?).and_return { false }
    @seq.registration = reg
    atc = StubSequenceAtcClass.new
    @seq.atc_class = atc
    comp = ODDB::Composition.new
    subst = ODDB::Substance.new
    subst.descriptions.store 'lt', 'LEVOMENTHOLUM'
    active_agent = ODDB::ActiveAgent.new('LEVOMENTHOLUM')
    active_agent.substance = subst
    active_agent.composition = comp
    @seq.compositions.push comp
    comp.galenic_form = StubSequenceGalenicForm.new
    comparable = ODDB::Sequence.new('02')
    comparable.registration = reg
    comparable.atc_class = atc
    comp = ODDB::Composition.new
    subst = ODDB::Substance.new
    subst.descriptions.store 'lt', 'ACIDUM ACETYLSALICYLICUM'
    active_agent = ODDB::ActiveAgent.new('ACIDUM ACETYLSALICYLICUM')
    active_agent.substance = subst
    active_agent.composition = comp
    comparable.compositions.push comp
    assert_equal([], @seq.comparables)
  end
  def test_comparables3
    reg = flexmock
    reg.should_receive(:active?).and_return { true }
    reg.should_receive(:may_violate_patent?).and_return { false }
    @seq.registration = reg
    atc = StubSequenceAtcClass.new
    @seq.atc_class = atc
    comp = ODDB::Composition.new
    subst1 = ODDB::Substance.new
    subst1.descriptions[:de] = 'CAPTOPRILUM'
    subst2 = ODDB::Substance.new
    subst2.descriptions[:de] = 'HYDROCHLOROTHIACIDUM'
    active_agent1 = ODDB::ActiveAgent.new('CAPTOPRILUM')
    active_agent2 = ODDB::ActiveAgent.new('HYDROCHLOROTHIACIDUM')
    active_agent1.substance = subst1
    active_agent2.substance = subst2
    active_agent1.composition = comp
    active_agent2.composition = comp
    @seq.compositions.push comp
    comp.galenic_form = StubSequenceGalenicForm.new
    comparable = ODDB::Sequence.new('02')
    comparable.registration = reg
    comparable.atc_class = atc
    comparable.compositions.push comp
    assert_equal([comparable], @seq.comparables)
  end
  def test_comparable
    assert_equal false, @seq.comparable?(@seq)
    seq = flexmock :compositions => [], :active? => true
    assert_equal true, @seq.comparable?(seq)
  end
  def test_composition
    comp1 = flexmock(:oid => 3)
    comp2 = flexmock(:oid => 5)
    @seq.compositions.push comp1, comp2
    assert_equal comp2, @seq.composition(5)
  end
  def test_composition_text
    pac = flexmock :swissmedic_source => {:composition => 'composition'}
    @seq.packages.store '001', pac
    assert_equal 'composition', @seq.composition_text
    @seq.composition_text = 'composition text'
    assert_equal 'composition text', @seq.composition_text
  end
  def test_create_composition
    comp1 = @seq.create_composition
    assert_instance_of ODDB::Composition, comp1
    assert_equal [comp1], @seq.compositions
    comp2 = @seq.create_composition
    assert_instance_of ODDB::Composition, comp2
    assert_equal [comp1, comp2], @seq.compositions
  end
  def test_create_package
    @seq.packages = {}
    package = @seq.create_package('023')
    assert_equal(@seq, package.sequence)
    assert_equal(package, @seq.package(23))
    package = @seq.create_package(32)
    assert_equal(package, @seq.package('032'))
  end
  def test_delete_composition
    @seq.compositions.push flexmock(:oid => 3)
    @seq.delete_composition 3
    assert_equal [], @seq.compositions
  end
  def test_delete_package
    @seq.packages.store '003', 'package'
    @seq.delete_package '003'
    assert_equal({}, @seq.packages)
  end
  def test_dose
    @seq.compositions.push flexmock(:doses => [ODDB::Dose.new(10, 'mg'), ODDB::Dose.new(10, 'mg')]),
                           flexmock(:doses => [ODDB::Dose.new(20, 'mg')])
    assert_equal ODDB::Dose.new(40, 'mg'), @seq.dose
  end
  def test_doses
    @seq.compositions.push flexmock(:doses => [ODDB::Dose.new(10, 'mg'), ODDB::Dose.new(10, 'mg')]),
                           flexmock(:doses => [ODDB::Dose.new(20, 'mg')])
    assert_equal [ODDB::Dose.new(10, 'mg'), ODDB::Dose.new(10, 'mg'), ODDB::Dose.new(20, 'mg')],
                 @seq.doses
  end
  def test_each
    res = []
    @seq.packages.update '003' => 'package1', '005' => 'package2'
    @seq.each_package do |pac| res.push pac end
    assert_equal %w{package1 package2}, res.sort
  end
  def test_factored_compositions
    @seq.compositions.push 2.0, 4.0
    assert_equal [5.0, 10.0], @seq.factored_compositions(2.5)
  end
  def test_fix_pointers
    reg = flexmock :pointer => ODDB::Persistence::Pointer.new([:registration, '12345'])
    @seq.registration = reg
    pac1 = flexmock 'package'
    pac1.should_receive(:fix_pointers).times(1).and_return do
      assert true
    end
    @seq.packages.store '003', pac1
    comp1 = flexmock 'composition'
    comp1.should_receive(:fix_pointers).times(1).and_return do
      assert true
    end
    @seq.compositions.push comp1
    @seq.fix_pointers
  end
  def test_galenic_group
    comp1 = flexmock :galenic_group => 'group1'
    comp2 = flexmock :galenic_group => nil
    comp3 = flexmock :galenic_group => 'group2'
    comp4 = flexmock :galenic_group => 'group1'
    @seq.compositions.push comp1, comp2, comp4
    assert_equal 'group1', @seq.galenic_group
    @seq.compositions.push comp3
    assert_nil @seq.galenic_group
  end
  def test_galenic_groups
    comp1 = flexmock :galenic_group => 'group1'
    comp2 = flexmock :galenic_group => nil
    comp3 = flexmock :galenic_group => 'group2'
    comp4 = flexmock :galenic_group => 'group1'
    @seq.compositions.push comp1, comp2, comp3, comp4
    assert_equal ['group1', 'group2'], @seq.galenic_groups
  end
  def test_galenic_forms
    comp1 = flexmock :galenic_form => 'form1'
    comp2 = flexmock :galenic_form => nil
    comp3 = flexmock :galenic_form => 'form2'
    comp4 = flexmock :galenic_form => 'form1'
    @seq.compositions.push comp1, comp2, comp3, comp4
    assert_equal ['form1', 'form2'], @seq.galenic_forms
  end
  def test_has_patinfo
    comp1 = flexmock :disable_patinfo => false
    @seq.registration = flexmock :company => comp1
    assert_equal false, @seq.has_patinfo?
    @seq.pdf_patinfo = 'path-to.pdf'
    assert_equal true, @seq.has_patinfo?
    comp2 = flexmock :disable_patinfo => true
    @seq.registration = flexmock :company => comp2
    assert_equal false, @seq.has_patinfo?
    @seq.registration = flexmock :company => comp1
    @seq.deactivate_patinfo = @@today
    assert_equal false, @seq.has_patinfo?
  end
  def test_has_public_packages
    @seq.packages.store '002', flexmock(:public? => false)
    assert_equal false, @seq.has_public_packages?
    @seq.packages.store '005', flexmock(:public? => true)
    assert_equal true, @seq.has_public_packages?
  end
  def test_iksnr
    assert_respond_to(@seq, :iksnr)
  end
  def test_indication
    assert_nil @seq.indication
    @seq.registration = flexmock :indication => 'registration indication'
    assert_equal 'registration indication', @seq.indication
    @seq.instance_variable_set '@indication', 'sequence indication'
    assert_equal 'sequence indication', @seq.indication
  end
  def test_indication_writer
    ind = flexmock 'indication'
    ind.should_receive(:add_sequence).with(@seq).times(1).and_return do
      assert true
    end
    @seq.indication = ind
  end
  def test_initalize
    assert_equal('01', @seq.seqnr)
  end
  def test_limitation_text
    assert_nil @seq.limitation_text
    @seq.packages.update '001' => flexmock(:limitation_text => nil),
                         '002' => flexmock(:limitation_text => 'text')
    assert_equal 'text', @seq.limitation_text
  end
  def test_limitation_text_count
    mock1 = flexmock("packet_mock1")
    mock2 = flexmock("packet_mock2")
    mock3 = flexmock("packet_mock3")
    hash = {
      :mock1 => mock1,
      :mock2 => mock2,
      :mock3 => mock3,
    }
    @seq.packages = hash
    mock1.should_receive(:limitation_text).once.with().and_return('entry')
    mock2.should_receive(:limitation_text).once.with()
    mock3.should_receive(:limitation_text).once.with()
    text_count = @seq.limitation_text_count
    assert_equal(1, text_count)
  end
  def test_localized_name
    @seq.name_base = 'Product'
    @seq.name_descr = 'Description'
    assert_equal 'Product, Description', @seq.localized_name(:de)
    assert_equal 'Product, Description', @seq.localized_name(:fr)
  end
  def test_longevity_writer
    @seq.longevity = nil
    assert_nil @seq.longevity
    @seq.longevity = 5
    assert_equal 5, @seq.longevity
    @seq.longevity = 1
    assert_nil @seq.longevity
  end
  def test_match
    @seq.match('Aspirin')
    assert_equal(nil, @seq.match('Aspirin'))
    @seq.name_base='Aspirin'
    assert_equal(MatchData, @seq.match('Aspirin').class)
    assert_equal(MatchData, @seq.match('aspirin').class)
  end
  def test_name_writer
    @seq.name = "Aspirin, Tabletten"
    assert_equal("Aspirin, Tabletten", @seq.name)
    assert_equal("Aspirin", @seq.name_base)
    assert_equal("Tabletten", @seq.name_descr)
  end
  def test_out_of_trade
    assert_equal true, @seq.out_of_trade
    @seq.packages.store '002', flexmock(:out_of_trade => false)
    assert_equal false, @seq.out_of_trade
    @seq.packages.store '003', flexmock(:out_of_trade => true)
    assert_equal false, @seq.out_of_trade
    @seq.packages.store '002', flexmock(:out_of_trade => true)
    assert_equal true, @seq.out_of_trade
  end
  def test_patinfo_writer
    patinfo1 = StubPatinfo.new
    patinfo1.oid = 4
    patinfo2 = StubPatinfo.new
    patinfo2.oid = 5
    @seq.patinfo = patinfo1
    assert_equal(@seq, patinfo1.added)
    assert_nil(patinfo1.removed)
    @seq.patinfo = patinfo2
    assert_equal(@seq, patinfo1.removed)
    assert_equal(@seq, patinfo2.added)
    assert_equal(@seq.patinfo.oid, 5)
    assert_nil(patinfo2.removed)
    @seq.patinfo = nil
    assert_equal(@seq, patinfo2.removed)
  end
  def test_public
    @seq.registration = flexmock :public? => true, :active? => true
    assert_equal true, @seq.public?
    @seq.export_flag = true
    assert_equal false, @seq.public?
    @seq.export_flag = false
    @seq.registration = flexmock :public? => false, :active? => true
    assert_equal false, @seq.public?
    @seq.registration = flexmock :public? => true, :active? => false
    assert_equal false, @seq.public?
  end
  def test_public_packages
    @seq.registration = flexmock :public? => true, :active? => true
    pac1 = flexmock(:public? => true)
    @seq.packages.store '002', pac1
    @seq.packages.store '003', flexmock(:public? => false)
    assert_equal [pac1], @seq.public_packages
    @seq.export_flag = true
    assert_equal [], @seq.public_packages
  end
  def test_public_package_count
    @seq.registration = flexmock :public? => true, :active? => true
    @seq.packages.store '002', flexmock(:public? => true)
    @seq.packages.store '003', flexmock(:public? => false)
    assert_equal 1, @seq.public_package_count
    @seq.export_flag = true
    assert_equal 0, @seq.public_package_count
  end
  def test_robust_adjust_types
    values = {
      :dose	=>	[123, 'fjdsfjdksah'],
    }
    result = {}
    result = @seq.adjust_types(values)
    assert_equal(ODDB::Dose.new(123, nil), result[:dose])
  end
  def test_robust_adjust_types_fuzzy_retry
    values = {
      :dose	=>	[123, 'mgkKo'],
    }
    result = {}
    result = @seq.adjust_types(values)
    assert_equal(ODDB::Dose.new(123, 'mg'), result[:dose])
  end
  def test_route_of_administration
    assert_nil @seq.route_of_administration
    @seq.compositions.push flexmock(:route_of_administration => 'O'),
                           flexmock(:route_of_administration => nil),
                           flexmock(:route_of_administration => 'O')
    assert_equal 'O', @seq.route_of_administration
    @seq.compositions.push flexmock(:route_of_administration => 'P')
    assert_nil @seq.route_of_administration
  end
  def test_seqnr_writer
    reg = flexmock 'registration',
                   :sequences => {'01' => @seq},
                   :pointer => ODDB::Persistence::Pointer.new([:registration, '12345'])
    reg.should_receive(:sequence).with('02').and_return do
      assert true
      nil
    end
    @seq.registration = reg
    @seq.seqnr = '02'
    assert_equal({'02' => @seq}, reg.sequences)
  end
  def test_substances
    active_agent1 = StubActiveAgent.new
    active_agent2 = StubActiveAgent.new
    active_agent1.substance = "Subst1"
    active_agent2.substance = "Subst2"
    comp = ODDB::Composition.new
    comp.active_agents.push active_agent1, active_agent2
    @seq.compositions.push comp
    assert_equal(["Subst1", "Subst2"], @seq.substances)
  end
  def test_substance_names
    active_agent1 = StubActiveAgent.new
    active_agent2 = StubActiveAgent.new
    active_agent1.substance = "Subst1"
    active_agent2.substance = "Subst2"
    comp = ODDB::Composition.new
    comp.active_agents.push active_agent1, active_agent2
    @seq.compositions.push comp
    expected = ["Subst1", "Subst2"]
    assert_equal(expected, @seq.substance_names)
  end
  def test_search_terms
    expected = [
      'Similasan', 'Kava',
      'KavaKava', 'Kava Kava',
      'Similasan Kava',
      'Similasan KavaKava',
      'Similasan Kava Kava',
    ]
    @seq.name = 'Similasan Kava-Kava'
    assert_equal(expected, @seq.search_terms)
  end
  def test_violates_patent
    act = flexmock :substance => 'Substance', :chemical_substance => nil
    comp = flexmock :active_agents => [act]
    seq = flexmock :active_agents => [act]
    @seq.compositions.push comp
    assert_equal true, @seq._violates_patent?(seq)
    @seq.compositions.clear
    assert_equal false, @seq._violates_patent?(seq)
  end
end
