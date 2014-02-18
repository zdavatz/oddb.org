# #!/usr/bin/env ruby
# encoding: utf-8
# TestOddbApp -- oddb.org -- 09.04.2012 -- yasaka@ywesee.com
# TestOddbApp -- oddb.org -- 19.01.2012 -- mhatakeyama@ywesee.com
# TestOddbApp -- oddb.org -- 16.02.2011 -- mhatakeyama@ywesee.com, zdavatz@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'syck'
require 'yaml'
YAML::ENGINE.yamler = 'syck'
require 'stub/odba'
require 'stub/config'
gem 'minitest'
require 'minitest/autorun'
require 'stub/oddbapp'
require 'digest/md5'
require 'util/persistence'
require 'model/substance'
require 'model/atcclass'
require 'model/orphan'
require 'model/epha_interaction'
require 'model/medical_product'
require 'model/galenicform'
require 'util/language'
require 'flexmock'
require 'util/oddbapp'
module DRb
  class DRbObject
    def respond_to?(msg_id, *args)
      case msg_id
      when :_dump
        true
      when :marshal_dump
        false
      else
        true
    #                                method_missing(:respond_to?, msg_id)
      end
    end
  end
end

module ODDB
  module Admin
    class Subsystem; end
  end
  class PowerUser; end
  class CompanyUser; end
	class RootUser
		def initialize
			@oid = 0
			@unique_email = 'test@oddb.org'
			@pass_hash = Digest::MD5::hexdigest('test')
			@pointer = Pointer.new([:user, 0])
		end
	end
	class Registration
		attr_writer :sequences
	end
	class Sequence
		attr_accessor :packages
	end
	module Persistence
		class Pointer
			public :directions
		end
	end
	class GalenicGroup
		attr_accessor :galenic_forms
		def GalenicGroup::reset_oids
			@oid = 0
		end
	end
end

class TestOddbApp <MiniTest::Unit::TestCase
  include FlexMock::TestCase
	def setup
#    @drb = flexmock(DRb::DRbObject, :new => server)
		ODDB::GalenicGroup.reset_oids
    ODBA.storage.reset_id
		dir = File.expand_path('../data/prevalence', File.dirname(__FILE__))
		@app = ODDB::App.new

    @session = flexmock('session') do |ses|
      ses.should_receive(:grant).with('name', 'key', 'item', 'expires')\
        .and_return('session').by_default
      ses.should_receive(:entity_allowed?).with('email', 'action', 'key')\
        .and_return('session').by_default
      ses.should_receive(:create_entity).with('email', 'pass')\
        .and_return('session').by_default
      ses.should_receive(:get_entity_preference).with('name', 'key')\
        .and_return('session').by_default
      ses.should_receive(:get_entity_preference).with('name', 'association')\
        .and_return('odba_id').by_default
      ses.should_receive(:get_entity_preferences).with('name', 'keys')\
        .and_return('session').by_default
      ses.should_receive(:get_entity_preferences).with('error', 'error')\
        .and_raise(Yus::YusError).by_default
      ses.should_receive(:reset_entity_password).with('name', 'token', 'password')\
        .and_return('session').by_default
      ses.should_receive(:set_entity_preference).with('name', 'key', 'value', 'domain')\
        .and_return('session').by_default
    end
    flexmock(ODDB::App::YUS_SERVER) do |yus|
      yus.should_receive(:autosession).and_yield(@session).by_default
    end
    flexmock(ODBA.storage) do |sto|
      sto.should_receive(:remove_dictionary).by_default
      sto.should_receive(:generate_dictionary).with('language')\
        .and_return('generate_dictionary').by_default
      sto.should_receive(:generate_dictionary).with('french')\
        .and_return('french_dictionary').by_default
      sto.should_receive(:generate_dictionary).with('german')\
        .and_return('german_dictionary').by_default
    end
	end
	def teardown
		ODBA.storage = nil
    super
	end
  def test_create_minifi
    minifi = flexmock('minifi') do |mfi|
      mfi.should_receive(:oid)
    end
    flexmock(ODDB::MiniFi) do |mfi|
      mfi.should_receive(:new).and_return(minifi)
    end
    assert_equal(minifi, @app.create_minifi)
  end
  def test_create_narcotic
    narcotic = flexmock('narcotic') do |nar|
      nar.should_receive(:oid)
    end
    flexmock(ODDB::Narcotic2) do |nar|
      nar.should_receive(:new).and_return(narcotic)
    end
    assert_equal(narcotic, @app.create_narcotic)
  end
  def test_create_sponsor_flavor
    sponsor = flexmock('sponsor') do |spo|
      spo.should_receive(:oid)
    end
    flexmock(ODDB::Sponsor) do |spo|
      spo.should_receive(:new).and_return(sponsor)
    end
    assert_equal(sponsor, @app.create_sponsor('flavor'))
  end
  def test_create_index_therapeuticus_code
      index_therapeuticus = flexmock('index_therapeuticus') do |int|
        int.should_receive(:code)
      end
      flexmock(ODDB::IndexTherapeuticus) do |int|
        int.should_receive(:new).and_return(index_therapeuticus)
      end
      assert_equal(index_therapeuticus, @app.create_index_therapeuticus('code'))
  end
  def same?(o1, o2)
=begin
    #result1.atc_classes   == result2.atc_classes   and\
    result1.atc_classes.size == result2.atc_classes.size  and\
    result1.search_type      == result2.search_type   and\
    result1.display_limit    == result2.display_limit and\
    result1.relevance        == result2.relevance     and\
    result1.search_query     == result2.search_query
=end
    h1 = {}
    h2 = {}
=begin
    p o1
    p o2
    gets
=end
    if o1.instance_variables.sort == o2.instance_variables.sort
      o1.instance_variables.each do |v|
        if v.to_s == '@atc_classes' # actually atc_classes should also be checked
          h1[v.to_sym] = o1.atc_classes.size
          h2[v.to_sym] = o2.atc_classes.size
        else
          h1[v.to_sym] = o1.instance_variable_get(v)
          h2[v.to_sym] = o2.instance_variable_get(v)
        end
      end
    else
      return false
    end
    return (h1 == h2)
  end
  def test_search_oddb
    expected = ODDB::SearchResult.new
    expected.atc_classes = []
    expected.search_type=:unwanted_effect
    #assert_equal(expected, @app.search_oddb('query', 'lang'))
    assert(same?(expected, @app.search_oddb('query', 'lang')))
  end
  def test_search_oddb__atc_class
    expected = ODDB::SearchResult.new
    expected.atc_classes = ['atc']
    expected.search_type=:atcless
    expected.search_query = 'atcless'
    expected.exact = true
    #assert_equal(expected, @app.search_oddb('atcless', 'lang'))
    assert(same?(expected, @app.search_oddb('atcless', 'lang')))
  end
  def test_search_oddb__iksnr
    reg = flexmock('registration') do |reg|
      reg.should_receive(:sequences).and_return({})
    end
    @app.registrations = {'12345'=>reg}
    expected = ODDB::SearchResult.new
    expected.atc_classes = ['atc']
    expected.search_type=:iksnr
    expected.search_query = '12345'
    expected.exact = true
    #assert_equal(expected, @app.search_oddb('12345', 'lang'))
    assert(same?(expected, @app.search_oddb('12345', 'lang')))
  end
  def test_search_oddb__pharmacode
    package = flexmock('package') do |pac|
      pac.should_receive(:"sequence.seqnr")
      pac.should_receive(:registration)
      pac.should_receive(:ikscd)
    end
    flexstub(ODDB::Package) do |pac|
      pac.should_receive(:find_by_pharmacode).and_return(package)
    end
    expected = ODDB::SearchResult.new
    expected.atc_classes = ['atc']
    expected.search_type=:pharmacode
    expected.search_query = '123456'
    expected.exact = true

    #assert_equal(expected, @app.search_oddb('123456', 'lang'))
    assert(same?(expected, @app.search_oddb('123456', 'lang')))
  end
  def test_count_atc_ddd
    atc = flexmock('atc') do |atc|
      atc.should_receive(:has_ddd?).and_return(true)
    end
    @app.atc_classes = {'key' => atc}
    assert_equal(1, @app.count_atc_ddd)
  end
  def test_atc_ddd_count
    assert_equal(0, @app.atc_ddd_count)
  end
  def test_count_limitation_text_count
    assert_equal(0, @app.limitation_text_count)
  end
  def test_migel_count
    skip("Niklaus does not know how to mock MIGEL_SERVER")
    assert_equal(0, @app.migel_count)
  end
  def test_patinfo_count
    assert_equal(0, @app.patinfo_count)
  end
  def test_recent_registration_count
    assert_equal(0, @app.recent_registration_count)
  end
  def test_company_count
    assert_equal(0, @app.company_count)
  end
  def test_count_vaccines
    assert_equal(0, @app.count_vaccines)
  end
  def test_analysis_count
    assert_equal(0, @app.analysis_count)
  end
  def test_epha_interaction_count
    assert_equal(0, @app.epha_interaction_count)
  end
  def test_medical_product_count
    assert_equal(0, @app.medical_product_count)
  end
  def test_hospital_count
    assert_equal(0, @app.hospital_count)
  end
  def test_doctor_count
    assert_equal(0, @app.doctor_count)
  end
  def test_fachinfo_count
    assert_equal(0, @app.fachinfo_count)
  end
  def test_narcotics_count
    assert_equal(0, @app.narcotics_count)
  end
  def test_substance_count
    assert_equal(0, @app.substance_count)
  end
  def test_vaccine_count
    assert_equal(0, @app.vaccine_count)
  end
  def setup_create_commercial_forms
    flexstub(@app) do |app|
      app.should_receive(:system).and_return(@app.instance_eval('@system'))
    end
    flexstub(@app.system) do |sys|
      sys.should_receive(:update)
    end
    package = flexmock('package') do |pac|
      pac.should_receive(:comform).and_return('possibility')
      pac.should_receive(:commercial_form=)
      pac.should_receive(:odba_store)
    end
    @registration = flexmock('registration') do |reg|
      reg.should_receive(:each_package).and_yield(package)
    end
    @app.registrations = {'12345' => @registration}
  end
  def test_create_commercial_forms
    setup_create_commercial_forms
    assert_equal({'12345' => @registration}, @app.create_commercial_forms)
  end
  def test_create_commercial_forms__commercial_form
    setup_create_commercial_forms
    flexstub(ODDB::CommercialForm) do |frm|
      frm.should_receive(:find_by_name).and_return('commercial_form')
    end
    @app.registrations = {'12345' => @registration}
    galenicform = flexmock('galenicform') do |gf|
      gf.should_receive(:description)
      gf.should_receive(:synonyms)
    end
    galenicgroup = flexmock('galenicgroup') do |gg|
      gg.should_receive(:get_galenic_form).and_return(galenicform)
    end
    @app.galenic_groups = {'12345'=> galenicgroup}
    assert_equal({'12345' => @registration}, @app.create_commercial_forms)
  end
  def test_merge_commercial_forms
    source = flexmock('source') do |sou|
      sou.should_receive(:pointer)
    end
    target = flexmock('target') do |tar|
      tar.should_receive(:pointer)
    end
    command = flexmock('command') do |com|
        com.should_receive(:execute)
    end
    flexstub(ODDB::MergeCommand) do |klass|
      klass.should_receive(:new).and_return(command)
    end
    assert_equal(nil, @app.merge_commercial_forms(source, target))
  end
  def test_merge_companies
    source = flexmock('source') do |sou|
      sou.should_receive(:pointer)
    end
    target = flexmock('target') do |tar|
      tar.should_receive(:pointer)
    end
    command = flexmock('command') do |com|
      com.should_receive(:execute)
    end
    flexstub(ODDB::MergeCommand) do |klass|
      klass.should_receive(:new).and_return(command)
    end
    assert_equal(nil, @app.merge_companies(source, target))
  end
  def test_merge_galenic_forms
    source = flexmock('source') do |sou|
      sou.should_receive(:pointer)
    end
    target = flexmock('target') do |tar|
      tar.should_receive(:pointer)
    end
    command = flexmock('command') do |com|
      com.should_receive(:execute)
    end
    flexstub(ODDB::MergeCommand) do |klass|
      klass.should_receive(:new).and_return(command)
    end
    assert_equal(nil, @app.merge_galenic_forms(source, target))
  end
  def test_merge_indications
    source = flexmock('source') do |sou|
      sou.should_receive(:pointer)
    end
    target = flexmock('target') do |tar|
      tar.should_receive(:pointer)
    end
    command = flexmock('command') do |com|
      com.should_receive(:execute)
    end
    flexstub(ODDB::MergeCommand) do |klass|
      klass.should_receive(:new).and_return(command)
    end
    assert_equal(nil, @app.merge_indications(source, target))
    end
  def test_merge_substances
    source = flexmock('source') do |sou|
      sou.should_receive(:pointer)
    end
    target = flexmock('target') do |tar|
      tar.should_receive(:pointer)
    end
    command = flexmock('command') do |com|
      com.should_receive(:execute)
    end
    flexstub(ODDB::MergeCommand) do |klass|
      klass.should_receive(:new).and_return(command)
    end
    assert_equal(nil, @app.merge_substances(source, target))
  end
  def test_delete_all_epha_interactions
    @app.create_epha_interaction('atc_code_self', 'atc_code_other')
    assert_equal(1,  @app.epha_interactions.size)
    @app.delete_all_epha_interactions
    assert_equal(0,  @app.epha_interactions.size)
  end
  def test_delete_fachinfo
    @app.fachinfos = {'oid' => 'fachinfo'}
    assert_equal('fachinfo', @app.delete_fachinfo('oid'))
  end
  def test_delete_indication
    @app.indications = {'oid' => 'indication'}
    assert_equal('indication', @app.delete_indication('oid'))
  end
  def test_delete_index_therapeuticus
    @app.indices_therapeutici = {'oid' => 'index_therapeuticus'}
    assert_equal('index_therapeuticus', @app.delete_index_therapeuticus('oid'))
  end
  def test_delete_invoice
    @app.invoices = {'oid' => 'invoice'}
    assert_equal('invoice', @app.delete_invoice('oid'))
  end
  def test_delete_migel_group
    @app.migel_groups = {'code' => 'migel_group'}
    skip("Niklaus has not time to mock migel_product")
    assert_equal('migel_group', @app.delete_migel_group('code'))
  end
  def test_delete_patinfo
    @app.patinfos = {'oid' => 'patinfo'}
    assert_equal('patinfo', @app.delete_patinfo('oid'))
  end
  def test_delete_registration
    @app.registrations = {'oid' => 'registration'}
    assert_equal('registration', @app.delete_registration('oid'))
  end
  def test_delete_commercial_form
    @app.commercial_forms = {'oid' => 'commercial_form'}
    assert_equal('commercial_form', @app.delete_commercial_form('oid'))
  end
  def test_delete_atc_class
    @app.atc_classes = {'oid' => 'atc_class'}
    assert_equal('atc_class', @app.delete_atc_class('oid'))
  end
  def test_delete_address_suggestion
    @app.address_suggestions = {'oid' => 'address_suggestion'}
    assert_equal('address_suggestion', @app.delete_address_suggestion('oid'))
  end
  def test_delete_orphaned_fachinfo
    @app.orphaned_fachinfos = {123 => 'orphaned_fachinfos'}
    assert_equal('orphaned_fachinfos', @app.delete_orphaned_fachinfo('123'))
  end
  def test_delete_minifi
    @app.minifis = {123 => 'minifis'}
    assert_equal('minifis', @app.delete_minifi('123'))
  end
  def test_delete_substance
    @app.substances = {123 => 'substance'}
    assert_equal('substance', @app.delete_substance('123'))
  end
  def test_delete_substance__downcase
    @app.substances = {'abc' => 'substance'}
    assert_equal('substance', @app.delete_substance('abc'))
  end
  def setup_assign_effective_forms
    sequence = flexmock('sequence') do |seq|
      seq.should_receive(:delete_active_agent)
      seq.should_receive(:"active_agents.odba_isolated_store")
    end
    @substance = flexmock('substance') do |sub|
      sub.should_receive(:has_effective_form?).and_return(false)
      sub.should_receive(:name).and_return('name')
      sub.should_receive(:to_s).and_return('name')
      sub.should_receive(:effective_form=)
      sub.should_receive(:odba_store)
      sub.should_receive(:odba_delete)
      sub.should_receive(:sequences).and_return([sequence])
    end
    @app.substances = [@substance]
  end
  def test_assign_effective_forms__n
    def $stdin.readline
      'n'
    end
    setup_assign_effective_forms
    assert_equal(nil, @app.assign_effective_forms)
  end
  def test_assign_effective_forms__S
    def $stdin.readline
      'S'
    end
    setup_assign_effective_forms
    assert_equal(nil, @app.assign_effective_forms)
  end
  def test_assign_effective_forms__s
    def $stdin.readline
      's'
    end
    setup_assign_effective_forms
    assert_equal(nil, @app.assign_effective_forms)
  end
  def test_assign_effective_forms__q
    def $stdin.readline
      'q'
    end
    setup_assign_effective_forms
    assert_equal(nil, @app.assign_effective_forms)
  end
  def test_assign_effective_forms__d
    def $stdin.readline
      'd'
    end
    setup_assign_effective_forms
    assert_equal(nil, @app.assign_effective_forms)
  end
  def test_assign_effective_forms__other_name
    setup_assign_effective_forms
    flexstub(@app) do |app|
      app.should_receive(:system).and_return(@app.instance_eval('@system'))
    end
    flexstub(@app.system) do |sys|
      sys.should_receive(:update).and_return(@substance)
    end

    def $stdin.readline
      'c abc'
    end
    assert_equal(nil, @app.assign_effective_forms)
  end
  def test_assign_effective_forms__else
    def $stdin.readline
      'abc'
    end
    setup_assign_effective_forms
    flexstub(@app) do |app|
      app.should_receive(:system).and_return(@app.instance_eval('@system'))
    end
    flexstub(@app.system) do |sys|
      sys.should_receive(:substance).and_return(@substance)
    end
    assert_equal(nil, @app.assign_effective_forms)
  end
  def test_inject_poweruser
    flexstub(@app) do |app|
      app.should_receive(:system).and_return(@app.instance_eval('@system'))
    end
    pointer = flexmock('pointer') do |poi|
      poi.should_receive(:creator)
    end
    flexstub(pointer) do |poi|
      poi.should_receive(:"+").and_return(pointer)
    end
    flexstub(@app.system) do |sys|
      sys.should_receive(:update).and_return(flexmock('user_or_invoice') do |ui|
        ui.should_receive(:pointer).and_return(pointer)
        ui.should_receive(:payment_received!)
        ui.should_receive(:add_invoice)
        ui.should_receive(:odba_isolated_store).and_return('odba_isolated_store')
      end)
    end
    assert_equal('odba_isolated_store', @app.inject_poweruser('email', 'pass', 10.0))
  end
  def test_rebuild_indices
    flexstub(ODBA.cache) do |cache|
      cache.should_receive(:indices).and_return([])
      cache.should_receive(:create_index)
    end
    assert_equal(nil, @app.rebuild_indices)
  end
  def test_accept_orphaned
    flexstub(@app) do |app|
      app.should_receive(:system).and_return(@app.instance_eval('@system'))
    end
    flexstub(@app.system) do |sys|
      sys.should_receive(:execute_command)
    end
    assert_equal(nil, @app.accept_orphaned('orphan', 'pointer', :symbol))
  end
  def test_clean
    assert_equal(nil, @app.clean)
  end
  def test_admin
    @app.users = {123 => 'user'}
    assert_equal('user', @app.admin('123'))
  end
  def test_currencies
    assert_equal([], @app.currencies)
  end
  def test_hospital
    assert_equal(nil, @app.hospital('ean13'))
  end
  def test_get_epha_interaction
    assert_equal(nil, @app.get_epha_interaction('atc_code_self', 'atc_code_other'))
  end
  def test_get_medical_product
    assert_equal(nil, @app.get_medical_product('no_such_medical'))
  end
  def test_each_atc_class
    assert_equal(Enumerator, @app.each_atc_class.class)
    res = []
    @app.each_atc_class.each{ |x| res << x }
    assert_equal( [], res)                             
  end
  def test_each_migel_product
    subgroup = flexmock('subgroup') do |grp|
      grp.should_receive(:products).and_return({'product' => 'product'})
    end
    group = flexmock('group') do |grp|
      grp.should_receive(:subgroups).and_return({'subgroup' => subgroup})
    end
    @app.migel_groups = {'group' => group}
    skip("Niklaus has not time to mock migel_product")
    assert_equal({'group' => group}, @app.each_migel_product{})
  end
  def test_migel_products
    subgroup = flexmock('subgroup') do |grp|
      grp.should_receive(:products).and_return({'product' => 'product'})
    end
    group = flexmock('group') do |grp|
      grp.should_receive(:subgroups).and_return({'subgroup' => subgroup})
    end
    @app.migel_groups = {'group' => group}
    skip("Niklaus has not time to mock migel_product")
    assert_equal(['product'], @app.migel_products)
  end
  def test_migel_product
    subgroup = flexmock('subgroup') do |sub|
      sub.should_receive(:product).and_return('product')
    end
    group = flexmock('group') do |grp|
      grp.should_receive(:subgroup).and_return(subgroup)
    end
    @app.migel_groups = {'1' => group}
    skip("Niklaus has not time to mock migel_product")
    assert_equal('product', @app.migel_product('1.2.3'))
  end
  def test_migel_product__error
    @app.migel_groups = {'1' => 'group'}
    skip("Niklaus has not time to mock migel_product")
    assert_equal(nil, @app.migel_product('1.2.3'))
  end
  def test_index_therapeuticus
    @app.indices_therapeutici = {'code' => 'index'}
    assert_equal('index', @app.index_therapeuticus('code'))
  end
  def test_feedback
    @app.feedbacks = {123 => 'feedback'}
    assert_equal('feedback', @app.feedback('123'))
  end
  def test_invoice
    @app.invoices = {123 => 'invoice'}
    assert_equal('invoice', @app.invoice('123'))
  end
  def test_narcotic
    @app.narcotics = {123 => 'narcotics'}
    assert_equal('narcotics', @app.narcotic('123'))
  end
  def test_create_poweruser
    poweruser = flexmock('poweruser') do |pusr|
      pusr.should_receive(:oid)
    end
    flexstub(ODDB::PowerUser) do |usr|
      usr.should_receive(:new).and_return(poweruser)
    end
    @app.users = {}
    assert_equal(poweruser, @app.create_poweruser)
  end
  def test_create_user
    companyuser = flexmock('companyuser') do |usr|
      usr.should_receive(:oid)
    end
    flexstub(ODDB::CompanyUser) do |usr|
      usr.should_receive(:new).and_return(companyuser)
    end
    @app.users = {}
    assert_equal(companyuser, @app.create_user)
  end
  def test_each_sequence
    registration = flexmock('registration') do |reg|
      reg.should_receive(:each_sequence).and_yield
    end
    @app.registrations = {'1' => registration}
    assert_equal({'1' => registration}, @app.each_sequence{})
  end
  def test_fachinfos_by_name
    assert_equal([], @app.fachinfos_by_name('name', 'lang'))
  end
  def test_package_by_ikskey
    registration = flexmock('registration') do |reg|
      reg.should_receive(:package).and_return('package')
    end
    @app.registrations = {'12345' => registration}
    assert_equal('package', @app.package_by_ikskey('12345678'))
  end
  def test__clean_odba_stubs_hash
    value = flexmock('val') do |val|
      val.should_receive(:"odba_instance.nil?").and_return(true)
    end
    assert_equal({}, @app._clean_odba_stubs_hash({'value' => value}))
  end
  def test__clean_odba_stubs_array
    value = flexmock('val') do |val|
      val.should_receive(:"odba_instance.nil?").and_return(true)
    end
    assert_equal([], @app._clean_odba_stubs_array([value]))
  end
  def test_clean_odba_stubs
    sequence = flexmock('sequence') do |seq|
      seq.should_receive(:packages).and_return({})
      seq.should_receive(:active_agents).and_return([])
    end
    registration = flexmock('registration') do |reg|
      reg.should_receive(:sequences).and_return({'key' => sequence})
    end
    @app.registrations = {'key' => registration}
    assert_equal({'key' => registration}, @app.clean_odba_stubs)
  end
  def test_yus_create_user
    @yus ||= flexmock('yus')
    flexmock(ODDB::App::YUS_SERVER) do |yus|
      yus.should_receive(:login)
      yus.should_receive(:login_token)
    end
    flexmock(ODDB::YusUser) do |yus|
      yus.should_receive(:new).and_return(@yus)
    end
    #assert_equal(@yus, @app.yus_create_user('email', 'pass'))
    assert_equal(@yus.class, @app.yus_create_user('email', 'pass').class)
  end
  def test_yus_grant
    assert_equal('session', @app.yus_grant('name', 'key', 'item', 'expires'))
  end
  def test_yus_get_preference
    assert_equal('session', @app.yus_get_preference('name', 'key'))
  end
  def test_yus_get_preferences
    assert_equal('session', @app.yus_get_preferences('name', 'keys'))
  end
  def test_yus_get_preferences__error
    assert_equal({}, @app.yus_get_preferences('error', 'error'))
  end
  def test_yus_model
    flexstub(ODBA.cache) do |cache|
      cache.should_receive(:fetch).once.with('odba_id', nil).and_return('yus_model')
    end
    assert_equal('yus_model', @app.yus_model('name'))
  end
  def test_yus_reset_password
    assert_equal('session', @app.yus_reset_password('name', 'token', 'password'))
  end
  def test_yus_set_preference
    assert_equal('session', @app.yus_set_preference('name', 'key', 'value', 'domain'))
  end
  def test_multilinguify_analysis
    flexstub(@app) do |app|
      app.should_receive(:system).and_return(@app.instance_eval('@system'))
    end
    flexstub(@app.system) do |sys|
      sys.should_receive(:update)
    end
    pointer = flexmock('pointer') do |ptr|
      ptr.should_receive(:creator)
    end
    flexstub(pointer) do |ptr|
      ptr.should_receive(:+).and_return(pointer)
    end
    position = flexmock('position') do |pos|
      pos.should_receive(:description).and_return('description')
      pos.should_receive(:pointer).and_return(pointer)
      pos.should_receive(:footnote).and_return('footnote')
      pos.should_receive(:list_title).and_return('list_title')
      pos.should_receive(:taxnote).and_return('taxnote')
      pos.should_receive(:permissions).and_return('permissions')
      pos.should_receive(:odba_store).and_return('odba_store')
    end
    position.instance_variable_set('@limitation', 'limitation')
    group = flexmock('group') do |grp|
      grp.should_receive(:positions).and_return({'key'=>position})
    end
    @app.analysis_groups = {'key'=>group}
    assert_equal([position], @app.multilinguify_analysis)
  end
  def test_search_doctors
    assert_equal([], @app.search_doctors('key'))
  end
  def test_search_companies
    assert_equal([], @app.search_companies('key'))
  end
  def test_search_exact_company
    expected = ODDB::SearchResult.new
    expected.atc_classes = []
    expected.search_type = :company
    #assert_equal(expected, @app.search_exact_company('query'))
    assert(same?(expected, @app.search_exact_company('query')))
  end
  def test_search_exact_indication
    expected = ODDB::SearchResult.new
    expected.atc_classes = []
    expected.search_type = :indication
    expected.exact = true
    assert(same?(expected, @app.search_exact_indication('query')))
  end
  def test_search_migel_alphabetical
    migelid = flexmock('migelid', 
                       :send => 'migelid search result',
                       :search_by_migel_code => 'search_by_migel_code'
                      )
    flexmock(ODDB::App::MIGEL_SERVER, :migelid => migelid)
    skip("Niklaus has not time to mock migel_product")
    assert_equal('migelid search result', @app.search_migel_alphabetical('query', 'lang'))
  end
  def test_search_migel_products
    flexmock(ODDB::App::MIGEL_SERVER, :search_migel_migelid => 'search_migel_migelid')
    assert_equal('search_migel_migelid', @app.search_migel_products('query', 'lang'))
  end
  def test_search_migel_products__migel_code
    migelid = flexmock('migelid', :search_by_migel_code => 'search_by_migel_code')
    flexmock(ODDB::App::MIGEL_SERVER, :migelid => migelid)
    assert_equal('search_by_migel_code', @app.search_migel_products('123456789', 'lang'))
  end
  def test_search_migel_subgroup
    migel_code = '123456789'
    subgroup = flexmock('subgroup', :find_by_migel_code => 'find_by_migel_code')
    flexmock(ODDB::App::MIGEL_SERVER, :subgroup => subgroup)
    assert_equal('find_by_migel_code', @app.search_migel_subgroup(migel_code))
  end
  def test_search_migel_limitation
    flexmock(ODDB::App::MIGEL_SERVER, :search_limitation => 'search_limitation')
    assert_equal('search_limitation', @app.search_migel_limitation('query'))
  end
  def test_search_migel_items_by_migel_code
    flexmock(ODDB::App::MIGEL_SERVER, :search_migel_product_by_migel_code => 'search_migel_product_by_migel_code')
    assert_equal('search_migel_product_by_migel_code', @app.search_migel_items_by_migel_code('123456789'))
  end
  def test_search_migel_items_by_migel_code_with_dots
    flexmock(ODDB::App::MIGEL_SERVER, :search_migel_product_by_migel_code => 'search_migel_product_by_migel_code')
    assert_equal('search_migel_product_by_migel_code', @app.search_migel_items_by_migel_code('12.34.56.78.9'))
  end

  def test_search_migel_items
    flexmock(ODDB::App::MIGEL_SERVER, :search_migel_product => 'search_migel_product')
    assert_equal('search_migel_product', @app.search_migel_items('query', 'lang'))
  end

  def test_search_narcotics
    assert_equal([], @app.search_narcotics('query', 'lang'))
  end
  def test_search_patinfos
    assert_equal([], @app.search_patinfos('query'))
  end
  def test_search_vaccines
    assert_equal([], @app.search_vaccines('query'))
  end
  def test__search_exact_classified_result
    sequence = flexmock('sequence') do |seq|
      seq.should_receive(:atc_class)
    end
    expected = ODDB::SearchResult.new
    expected.atc_classes = ['atc']
    expected.search_type = :unknown
    #assert_equal(expected, @app._search_exact_classified_result([sequence]))
    assert(same?(expected, @app._search_exact_classified_result([sequence])))
  end
  def test_search_sequences
    assert_equal([], @app.search_sequences('query'))
  end
  def test_search_exact_sequence
    expected = ODDB::SearchResult.new
    expected.atc_classes = []
    expected.search_type = :sequence
    #assert_equal(expected, @app.search_exact_sequence('query'))
    assert(same?(expected, @app.search_exact_sequence('query')))
  end
  def test_search_exact_substance
    expected = ODDB::SearchResult.new
    expected.atc_classes = []
    expected.search_type = :substance
    #assert_equal(expected, @app.search_exact_substance('query'))
    assert(same?(expected, @app.search_exact_substance('query')))
  end
  def test_search_epha_interactions
    assert_equal([], @app.search_epha_interactions('key'))
  end
  def test_search_medical_products
    assert_equal([], @app.search_medical_products('key'))
  end
  def test_search_hospitals
    assert_equal([], @app.search_hospitals('key'))
  end
  def test_search_indications
    assert_equal([], @app.search_indications('query'))
  end
  def test_search_interactions
    assert_equal([], @app.search_interactions('query'))
  end
  def test_search_substances
    assert_equal([], @app.search_substances('query'))
  end
  def test_sequences
    registration = flexmock('registration') do |reg|
      reg.should_receive(:sequences).and_return({'key' => 'sequence'})
    end
    @app.registrations = {'key' => registration}
    assert_equal(['sequence'], @app.sequences)
  end
  def test_slate
    @app.slates = {'name' => 'slate'}
    assert_equal('slate', @app.slate('name'))
  end
  def test_sorted_fachinfos
    assert_equal([], @app.sorted_fachinfos)
  end
  def test_sorted_feedbacks
    assert_equal([], @app.sorted_feedbacks)
  end
  def test_sorted_minifis
    assert_equal([], @app.sorted_minifis)
  end
  def test_run_random_updater 
    # this test-case is meaningless at the moment
    flexstub(ODDB::Updater) do |klass|
      klass.should_receive(:new).and_return(flexmock('updater') do |up|
        up.should_receive(:run_random)
      end)
    end
    flexstub(@app) do |app|
      app.should_receive(:sleep)
    end
    thread = @app.run_random_updater
    sleep(0.5)
    thread.kill
    assert(true)
  end
  def test_grant_download
    flexstub(@app) do |app|
      app.should_receive(:system).and_return(@app.instance_eval('@system'))
    end
    itp = flexmock('itp') do |itp|
      itp.should_receive(:+).and_return(itp)
      itp.should_receive(:creator)
    end
    inv = flexmock('inv') do |inv|
      inv.should_receive(:pointer).and_return(itp)
      inv.should_receive(:payment_received!)
      inv.should_receive(:odba_store)
      inv.should_receive(:oid).and_return('oid')
    end
    flexstub(@app.system) do |sys|
      sys.should_receive(:update).and_return(inv)
    end
    expected = "http://#{ODDB::SERVER_NAME}/de/gcc/download/invoice/oid/email/email/filename/filename"
    assert_equal(expected, @app.grant_download('email', 'filename', 'price'))
  end
  def test_update_feedback_rss_feed
    flexstub(@app) do |app|
      app.should_receive(:async).and_yield
    end
    assert_equal(nil, @app.update_feedback_rss_feed)
  end
  def test_update_feedback_rss_feed__error
    flexstub(@app) do |app|
      app.should_receive(:async).and_yield
    end
    flexstub(ODDB::Plugin) do |plg|
      plg.should_receive(:new).and_raise(StandardError)
    end
    assert_equal(nil, @app.update_feedback_rss_feed)
  end
  def test_replace_fachinfo
    assert_equal(nil, @app.replace_fachinfo('iksnr', 'pointer'))
  end
  def test_generate_dictionary
    assert_equal('generate_dictionary', @app.generate_dictionary('language'))
  end
  def test_generate_french_dictionary
    assert_equal('french_dictionary', @app.generate_french_dictionary)
  end
  def test_generate_german_dictionary
    assert_equal('german_dictionary', @app.generate_german_dictionary)
  end
  def test_generate_dictionaries
    assert_equal('german_dictionary', @app.generate_dictionaries)
  end
  def test_admin_subsystem
    flexstub(ODDB::Admin::Subsystem) do |sys|
      sys.should_receive(:new).and_return('admin_subsystem')
    end
    assert_equal('admin_subsystem', @app.admin_subsystem)
  end
  def test_search_analysis
    assert_equal([], @app.search_analysis('key', 'en'))
  end
  def test_search_analysis_alphabetical
    assert_equal([], @app.search_analysis_alphabetical('query', 'en'))
  end
  def test_resolve
    pointer = flexmock('pointer') do |ptr|
      ptr.should_receive(:resolve).and_return('resolve')
    end
    assert_equal('resolve', @app.resolve(pointer))
  end
  def test_refactor_addresses
    company = hospital = doctor = flexmock('mock') do |mock|
      mock.should_receive(:refactor_addresses)
      mock.should_receive(:odba_store)
    end
    @app.doctors   = {'key' => doctor}
    @app.hospitals = {'key' => hospital}
    @app.companies = {'key' => company}
    assert_equal($stdout.flush, @app.refactor_addresses)
  end
  def test_commercial_form
    @app.commercial_forms = {123 => 'commercial_form'}
    assert_equal('commercial_form', @app.commercial_form('123'))
  end
  def test_commercial_form_by_name
    assert_equal(nil, @app.commercial_form_by_name('name'))
  end
  def test_config
    expected = ODDB::Config.new
    expected.pointer = ODDB::Persistence::Pointer.new(:config)
    #assert(same?(expected ,@app.config))
    assert_equal(expected.class, @app.config('arg').class) # actually the instances should be compared
  end
  def test_count_limitation_texts
    registration = flexmock('registration') do |reg|
      reg.should_receive(:limitation_text_count).and_return(123)
    end
    @app.registrations = {'key' => registration}
    assert_equal(123, @app.count_limitation_texts)
  end
  def test_sorted_patented_registrations
    patent = flexmock('patent') do |pat|
      pat.should_receive(:expiry_date).and_return(true)
    end
    registration = flexmock('registration') do |reg|
      reg.should_receive(:patent).and_return(patent)
    end
    @app.registrations = {'key' => registration}
    assert_equal([registration], @app.sorted_patented_registrations)
  end
  def test_sponsor
    @app.sponsors = {'flavor' => 'sponsor'}
    assert_equal('sponsor', @app.sponsor('flavor'))
  end
  def test_user
    @app.users = {'oid' => 'user'}
    assert_equal('user', @app.user('oid'))
  end
  def test_user_by_email
    user = flexmock('user') do |usr|
      usr.should_receive(:unique_email).and_return('email')
    end
    @app.users = {'oid' => user}
    assert_equal(user, @app.user_by_email('email'))
  end
  def test__admin
    assert_kind_of(Thread, @app._admin('"src"', 'result'))
  end
  def test__admin__str200
    assert_kind_of(Thread, @app._admin('"a"*201', 'result'))
  end
  def test_count_recent_registrations
    flags = [:new]
    log = flexmock('log') do |log|
      log.should_receive(:change_flags).and_return({'ptr' => flags})
    end
    group = flexmock('group') do |grp|
      grp.should_receive(:latest).and_return(log)
    end
    @app.log_groups = {:swissmedic => group}
    assert_equal(1, @app.count_recent_registrations)
  end
  def test_count_vaccines
    registration = flexmock('registration') do |reg|
      reg.should_receive(:vaccine).and_return(true)
      reg.should_receive(:active_package_count).and_return(123)
    end
    @app.registrations = {'key' => registration}
    assert_equal(123, @app.count_vaccines)
  end
  def test_clean_invoices
    flexstub(@app) do |app|
      app.should_receive(:system).and_return(@app.instance_eval('@system'))
    end
    flexstub(@app.system) do |sys|
      sys.should_receive(:delete)
    end
    invoice = flexmock('invoice') do |inv|
      inv.should_receive(:odba_instance_nil?)
      inv.should_receive(:deletable?).and_return(true)
      inv.should_receive(:pointer)
    end
    @app.invoices = {'oid' => invoice}
    assert_equal(nil, @app.clean_invoices)
  end
  def test_set_all_export_flag_registration
    flexstub(@app) do |app|
      app.should_receive(:system).and_return(@app.instance_eval('@system'))
    end
    registration = flexmock('registration', :pointer => 'pointer')
    flexstub(@app.system) do |sys|
      sys.should_receive(:each_registration).and_yield(registration)
      sys.should_receive(:update).and_return('update')
    end
    assert_equal('update', @app.set_all_export_flag_registration(true))
  end
  def test_set_all_export_flag_sequence
    flexstub(@app) do |app|
      app.should_receive(:system).and_return(@app.instance_eval('@system'))
    end
    sequence = flexmock('sequence', :pointer => 'pointer')
    flexstub(@app.system) do |sys|
      sys.should_receive(:each_sequence).and_yield(sequence)
      sys.should_receive(:update).and_return('update')
    end
    assert_equal('update', @app.set_all_export_flag_sequence(true))
  end
end
