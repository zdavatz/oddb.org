#!/usr/bin/env ruby
# encoding: utf-8
# TestOddbApp -- oddb.org -- 09.04.2012 -- yasaka@ywesee.com
# TestOddbApp -- oddb.org -- 19.01.2012 -- mhatakeyama@ywesee.com
# TestOddbApp -- oddb.org -- 16.02.2011 -- mhatakeyama@ywesee.com, zdavatz@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

begin
  require 'pry'
rescue LoadError
  # ignore error when pry cannot be loaded (for Jenkins-CI)
end

require 'syck'
require 'stub/odba'
require 'stub/config'

require 'minitest/autorun'
require 'digest/md5'
require 'util/persistence'
require 'model/substance'
require 'model/atcclass'
require 'model/orphan'
require 'model/epha_interaction'
require 'model/galenicform'
require 'util/language'
require 'flexmock/minitest'
require 'util/oddbapp'
require 'stub/oddbapp'

class TestOddbApp3 <MiniTest::Unit::TestCase
  def setup
#    @drb = flexmock(DRb::DRbObject, :new => server)
    ODDB::GalenicGroup.reset_oids
    ODBA.storage.reset_id
    dir = File.expand_path('../data/prevalence', File.dirname(__FILE__))
    @app = ODDB::App.new(server_uri: 'druby://localhost:20003')

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
  def same?(o1, o2)
    h1 = {}
    h2 = {}
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
    expected.search_type=:sequence
    expected.exact = true
    expected.search_query = "query"
    expected.error_limit = 500
    assert(same?(expected, @app.search_oddb('query', 'lang')))
  end
  def test_search_by_unwanted_effect
    expected = ODDB::SearchResult.new
    expected.atc_classes = []
    expected.search_type=:unwanted_effect
    assert(same?(expected, @app.search_by_unwanted_effect('query', 'lang')))
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
      seq.should_receive(:active?).and_return(true)
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
    assert(same?(expected, @app.search_exact_sequence('query')))
  end
  def test_search_combined
    expected = ODDB::SearchResult.new
    expected.atc_classes = []
    expected.search_type = :combined
    result = @app.search_combined('query', 'lang')
    expected.exact = true
    expected.search_query = "query"
    expected.error_limit = 500
    assert(same?(expected, result), "Result #{result.inspect} should match #{expected.inspect}" )
  end
  def test_search_exact_substance
    expected = ODDB::SearchResult.new
    expected.atc_classes = []
    expected.search_type = :substance
    assert(same?(expected, @app.search_exact_substance('query')))
  end
  def test_search_pharmacies
    assert_equal([], @app.search_pharmacies('key'))
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
    assert_nil(@app.update_feedback_rss_feed)
  end
  def test_update_feedback_rss_feed__error
    flexstub(@app) do |app|
      app.should_receive(:async).and_yield
    end
    flexstub(ODDB::Plugin) do |plg|
      plg.should_receive(:new).and_raise(StandardError)
    end
    assert_nil(@app.update_feedback_rss_feed)
  end
  def test_replace_fachinfo
    assert_nil(@app.replace_fachinfo('iksnr', 'pointer'))
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
  def test_commercial_form
    @app.commercial_forms = {123 => 'commercial_form'}
    assert_equal('commercial_form', @app.commercial_form('123'))
  end
  def test_commercial_form_by_name
    assert_nil(@app.commercial_form_by_name('name'))
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
    assert_nil(@app.clean_invoices)
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
  def test_package_by_ean13
    drug_2 = flexmock('drug_2') do |reg|
      reg.should_receive(:package).and_return('package_1234567890')
    end
    drug_1 = flexmock('drug_1') do |reg|
      reg.should_receive(:package).and_return('package_12345')
    end
    @app.registrations = {  '12345' => drug_1,
                          '1234567890' => drug_2,}
    assert_equal('package_12345',   @app.package_by_ean13('7680123456789'))
    assert_equal('package_1234567890', @app.package_by_ean13('7612345678900'))
  end

  def test_get_epha_interaction
    assert_nil(@app.get_epha_interaction('atc_code_self', 'atc_code_other'))
  end

  def test_epha_interaction
    @@datadir = File.expand_path '../data/csv/', File.dirname(__FILE__)
    @@vardir = File.expand_path '../var', File.dirname(__FILE__)
    assert(File.directory?(@@datadir), "Directory #{@@datadir} must exist")
    FileUtils.mkdir_p @@vardir
    ODDB.config.data_dir = @@vardir
    ODDB.config.log_dir = @@vardir
    @fileName = File.join(@@datadir, 'epha_interactions_de_utf8-example.csv')
    @latest = @fileName.sub('.csv', '-latest.csv')
    FileUtils.rm(@latest) if File.exists?(@latest)
    @agent = flexmock(Mechanize.new)
    @agent.should_receive(:get).and_return(IO.read(@fileName))
    @plugin = ODDB::EphaInteractionPlugin.new(@app, {})
    assert(@plugin.update(@agent, @fileName))
    code_0 = 'C09CA01'
    code_1 = 'C07AB02'
    atc_class_0 = flexmock('atc_class_0') do |reg|
      reg.should_receive(:code).and_return(code_0)
    end
    atc_class_1 = flexmock('atc_class_1') do |reg|
      reg.should_receive(:code).and_return(code_1)
    end

    drug_0 = flexmock('drug_0') do |reg|
      reg.should_receive(:package).and_return('pack_drug_0')
      reg.should_receive(:atc_class).and_return(atc_class_0)
    end
    drug_1 = flexmock('drug_1') do |reg|
      reg.should_receive(:package).and_return('pack_drug_1')
      reg.should_receive(:atc_class).and_return(atc_class_1)
    end
    @app.registrations = {  '1111' => drug_0, '2222' => drug_1,}
    drugs              = {  '1111' => drug_0, '2222' => drug_1,}
    res_1 = @app.get_epha_interaction(code_1, drugs)
    assert_nil(res_1)
    res_2 = @app.get_epha_interaction(code_0, code_1)
  end
end
