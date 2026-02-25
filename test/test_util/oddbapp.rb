#!/usr/bin/env ruby

# TestOddbApp -- oddb.org -- 09.04.2012 -- yasaka@ywesee.com
# TestOddbApp -- oddb.org -- 19.01.2012 -- mhatakeyama@ywesee.com
# TestOddbApp -- oddb.org -- 16.02.2011 -- mhatakeyama@ywesee.com, zdavatz@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "yaml"
require "stub/odba"
require "stub/config"

require "minitest/autorun"
require "stub/oddbapp"
require "digest/md5"
require "util/persistence"
require "model/substance"
require "model/atcclass"
require "model/orphan"
require "model/epha_interaction"
require "model/galenicform"
require "util/language"
require "flexmock/minitest"
require "util/oddbapp"
require "util/rack_interface"
require "util/workdir"

class TestOddbApp < Minitest::Test
  @@port_id ||= 19000
  def setup
    GC.start # start a garbage collection
    ODDB::GalenicGroup.reset_oids
    ODBA.storage.reset_id
    @app = ODDB::App.new(server_uri: "druby://localhost:#{@@port_id}", unknown_user: ODDB::UnknownUser.new)
    @@port_id += 1
    File.join(ODDB::PROJECT_ROOT, "data/prevalence")
    @rack_app = ODDB::Util::RackInterface.new(app: @app)

    @session = flexmock("session")
    flexmock(ODBA.storage) do |sto|
      sto.should_receive(:remove_dictionary).by_default
      sto.should_receive(:generate_dictionary).with("language")
        .and_return("generate_dictionary").by_default
      sto.should_receive(:generate_dictionary).with("french")
        .and_return("french_dictionary").by_default
      sto.should_receive(:generate_dictionary).with("german")
        .and_return("german_dictionary").by_default
    end
  end

  def teardown
    ODBA.storage = nil
    super
  end

  def test_create_minifi
    minifi = flexmock("minifi") do |mfi|
      mfi.should_receive(:oid)
    end
    flexmock(ODDB::MiniFi) do |mfi|
      mfi.should_receive(:new).and_return(minifi)
    end
    assert_equal(minifi, @app.create_minifi)
  end

  def test_create_narcotic
    narcotic = flexmock("narcotic") do |nar|
      nar.should_receive(:oid)
    end
    flexmock(ODDB::Narcotic2) do |nar|
      nar.should_receive(:new).and_return(narcotic)
    end
    assert_equal(narcotic, @app.create_narcotic)
  end

  def test_create_sponsor_flavor
    sponsor = flexmock("sponsor") do |spo|
      spo.should_receive(:oid)
    end
    flexmock(ODDB::Sponsor) do |spo|
      spo.should_receive(:new).and_return(sponsor)
    end
    assert_equal(sponsor, @app.create_sponsor("flavor"))
  end

  def test_create_index_therapeuticus_code
    index_therapeuticus = flexmock("index_therapeuticus") do |int|
      int.should_receive(:code)
    end
    flexmock(ODDB::IndexTherapeuticus) do |int|
      int.should_receive(:new).and_return(index_therapeuticus)
    end
    assert_equal(index_therapeuticus, @app.create_index_therapeuticus("code"))
  end

  def test_count_atc_ddd
    atc = flexmock("atc") do |atc|
      atc.should_receive(:has_ddd?).and_return(true)
    end
    @app.atc_classes = {"key" => atc}
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

  def test_pharmacy_count
    assert_equal(0, @app.pharmacy_count)
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
      app.should_receive(:system).and_return(@app.instance_eval("@system", __FILE__, __LINE__))
    end
    flexstub(@app.system) do |sys|
      sys.should_receive(:update)
    end
    package = flexmock("package") do |pac|
      pac.should_receive(:comform).and_return("possibility")
      pac.should_receive(:commercial_form=)
      pac.should_receive(:odba_store)
    end
    @registration = flexmock("registration") do |reg|
      reg.should_receive(:each_package).and_yield(package)
    end
    @app.registrations = {"12345" => @registration}
  end

  def test_create_commercial_forms
    setup_create_commercial_forms
    assert_equal({"12345" => @registration}, @app.create_commercial_forms)
  end

  def test_create_commercial_forms__commercial_form
    setup_create_commercial_forms
    flexstub(ODDB::CommercialForm) do |frm|
      frm.should_receive(:find_by_name).and_return("commercial_form")
    end
    @app.registrations = {"12345" => @registration}
    galenicform = flexmock("galenicform") do |gf|
      gf.should_receive(:description)
      gf.should_receive(:synonyms)
    end
    galenicgroup = flexmock("galenicgroup") do |gg|
      gg.should_receive(:get_galenic_form).and_return(galenicform)
    end
    @app.galenic_groups = {"12345" => galenicgroup}
    assert_equal({"12345" => @registration}, @app.create_commercial_forms)
  end

  def test_merge_commercial_forms
    source = flexmock("source") do |sou|
      sou.should_receive(:pointer)
    end
    target = flexmock("target") do |tar|
      tar.should_receive(:pointer)
    end
    command = flexmock("command") do |com|
      com.should_receive(:execute)
    end
    flexstub(ODDB::MergeCommand) do |klass|
      klass.should_receive(:new).and_return(command)
    end
    assert_nil(@app.merge_commercial_forms(source, target))
  end

  def test_merge_companies
    source = flexmock("source") do |sou|
      sou.should_receive(:pointer)
    end
    target = flexmock("target") do |tar|
      tar.should_receive(:pointer)
    end
    command = flexmock("command") do |com|
      com.should_receive(:execute)
    end
    flexstub(ODDB::MergeCommand) do |klass|
      klass.should_receive(:new).and_return(command)
    end
    assert_nil(@app.merge_companies(source, target))
  end

  def test_merge_galenic_forms
    source = flexmock("source") do |sou|
      sou.should_receive(:pointer)
    end
    target = flexmock("target") do |tar|
      tar.should_receive(:pointer)
    end
    command = flexmock("command") do |com|
      com.should_receive(:execute)
    end
    flexstub(ODDB::MergeCommand) do |klass|
      klass.should_receive(:new).and_return(command)
    end
    assert_nil(@app.merge_galenic_forms(source, target))
  end

  def test_merge_indications
    source = flexmock("source") do |sou|
      sou.should_receive(:pointer)
    end
    target = flexmock("target") do |tar|
      tar.should_receive(:pointer)
    end
    command = flexmock("command") do |com|
      com.should_receive(:execute)
    end
    flexstub(ODDB::MergeCommand) do |klass|
      klass.should_receive(:new).and_return(command)
    end
    assert_nil(@app.merge_indications(source, target))
  end

  def test_merge_substances
    source = flexmock("source") do |sou|
      sou.should_receive(:pointer)
    end
    target = flexmock("target") do |tar|
      tar.should_receive(:pointer)
    end
    command = flexmock("command") do |com|
      com.should_receive(:execute)
    end
    flexstub(ODDB::MergeCommand) do |klass|
      klass.should_receive(:new).and_return(command)
    end
    assert_nil(@app.merge_substances(source, target))
  end

  def test_delete_fachinfo
    @app.fachinfos = {"oid" => "fachinfo"}
    assert_equal("fachinfo", @app.delete_fachinfo("oid"))
  end

  def test_delete_indication
    @app.indications = {"oid" => "indication"}
    assert_equal("indication", @app.delete_indication("oid"))
  end

  def test_delete_index_therapeuticus
    @app.indices_therapeutici = {"oid" => "index_therapeuticus"}
    assert_equal("index_therapeuticus", @app.delete_index_therapeuticus("oid"))
  end

  def test_delete_invoice
    @app.invoices = {"oid" => "invoice"}
    assert_equal("invoice", @app.delete_invoice("oid"))
  end

  def test_delete_migel_group
    @app.migel_groups = {"code" => "migel_group"}
    skip("Niklaus has not time to mock migel_product")
    assert_equal("migel_group", @app.delete_migel_group("code"))
  end

  def test_delete_patinfo
    @app.patinfos = {"oid" => "patinfo"}
    assert_equal("patinfo", @app.delete_patinfo("oid"))
  end

  def test_delete_registration
    @app.registrations = {"oid" => "registration"}
    assert_equal("registration", @app.delete_registration("oid"))
  end

  def test_delete_commercial_form
    @app.commercial_forms = {"oid" => "commercial_form"}
    assert_equal("commercial_form", @app.delete_commercial_form("oid"))
  end

  def test_delete_atc_class
    @app.atc_classes = {"oid" => "atc_class"}
    assert_equal("atc_class", @app.delete_atc_class("oid"))
  end

  def test_delete_address_suggestion
    @app.address_suggestions = {"oid" => "address_suggestion"}
    assert_equal("address_suggestion", @app.delete_address_suggestion("oid"))
  end

  def test_delete_orphaned_fachinfo
    @app.orphaned_fachinfos = {123 => "orphaned_fachinfos"}
    assert_equal("orphaned_fachinfos", @app.delete_orphaned_fachinfo("123"))
  end

  def test_delete_minifi
    @app.minifis = {123 => "minifis"}
    assert_equal("minifis", @app.delete_minifi("123"))
  end

  def test_delete_substance
    @app.substances = {123 => "substance"}
    assert_equal("substance", @app.delete_substance("123"))
  end

  def test_delete_substance__downcase
    @app.substances = {"abc" => "substance"}
    assert_equal("substance", @app.delete_substance("abc"))
  end

  def setup_assign_effective_forms
    sequence = flexmock("sequence") do |seq|
      seq.should_receive(:delete_active_agent)
      seq.should_receive(:"active_agents.odba_isolated_store")
    end
    @substance = flexmock("substance") do |sub|
      sub.should_receive(:has_effective_form?).and_return(false)
      sub.should_receive(:name).and_return("name")
      sub.should_receive(:to_s).and_return("name")
      sub.should_receive(:effective_form=)
      sub.should_receive(:odba_store)
      sub.should_receive(:odba_delete)
      sub.should_receive(:sequences).and_return([sequence])
    end
    @app.substances = [@substance]
  end

  def test_assign_effective_forms__n
    def $stdin.readline
      "n"
    end
    setup_assign_effective_forms
    assert_nil(@app.assign_effective_forms)
  end

  def test_assign_effective_forms__S
    def $stdin.readline
      "S"
    end
    setup_assign_effective_forms
    assert_nil(@app.assign_effective_forms)
  end

  def test_assign_effective_forms__s
    def $stdin.readline
      "s"
    end
    setup_assign_effective_forms
    assert_nil(@app.assign_effective_forms)
  end

  def test_assign_effective_forms__q
    def $stdin.readline
      "q"
    end
    setup_assign_effective_forms
    assert_nil(@app.assign_effective_forms)
  end

  def test_assign_effective_forms__d
    def $stdin.readline
      "d"
    end
    setup_assign_effective_forms
    assert_nil(@app.assign_effective_forms)
  end

  def test_assign_effective_forms__other_name
    setup_assign_effective_forms
    flexstub(@app) do |app|
      app.should_receive(:system).and_return(@app.instance_eval("@system", __FILE__, __LINE__))
    end
    flexstub(@app.system) do |sys|
      sys.should_receive(:update).and_return(@substance)
    end

    def $stdin.readline
      "c abc"
    end
    assert_nil(@app.assign_effective_forms)
  end

  def test_assign_effective_forms__else
    def $stdin.readline
      "abc"
    end
    setup_assign_effective_forms
    flexstub(@app) do |app|
      app.should_receive(:system).and_return(@app.instance_eval("@system", __FILE__, __LINE__))
    end
    flexstub(@app.system) do |sys|
      sys.should_receive(:substance).and_return(@substance)
    end
    assert_nil(@app.assign_effective_forms)
  end

  def test_inject_poweruser
    flexstub(@app) do |app|
      app.should_receive(:system).and_return(@app.instance_eval("@system", __FILE__, __LINE__))
    end
    pointer = flexmock("pointer") do |poi|
      poi.should_receive(:creator)
    end
    flexstub(pointer) do |poi|
      poi.should_receive(:+).and_return(pointer)
    end
    flexstub(@app.system) do |sys|
      sys.should_receive(:update).and_return(flexmock("user_or_invoice") do |ui|
        ui.should_receive(:pointer).and_return(pointer)
        ui.should_receive(:payment_received!)
        ui.should_receive(:add_invoice)
        ui.should_receive(:odba_isolated_store).and_return("odba_isolated_store")
      end)
    end
    assert_equal("odba_isolated_store", @app.inject_poweruser("email", "pass", 10.0))
  end

  def test_rebuild_indices
    flexstub(ODBA.cache) do |cache|
      cache.should_receive(:indices).and_return([])
      cache.should_receive(:deferred_indices).and_return([])
      cache.should_receive(:create_index)
    end
    assert_nil(@app.rebuild_indices)
  end

  def test_accept_orphaned
    flexstub(@app) do |app|
      app.should_receive(:system).and_return(@app.instance_eval("@system", __FILE__, __LINE__))
    end
    flexstub(@app.system) do |sys|
      sys.should_receive(:execute_command)
    end
    assert_nil(@app.accept_orphaned("orphan", "pointer", :symbol))
  end

  def test_clean
    assert_nil(@app.clean)
  end

  def test_admin
    @app.users = {123 => "user"}
    assert_equal("user", @app.admin("123"))
  end

  def test_pharmacy
    assert_nil(@app.pharmacy("ean13"))
  end

  def test_hospital
    assert_nil(@app.hospital("ean13"))
  end

  def test_each_atc_class
    assert_equal(Enumerator, @app.each_atc_class.class)
    res = []
    @app.each_atc_class.each { |x| res << x }
    assert_equal([], res)
  end

  def test_each_migel_product
    subgroup = flexmock("subgroup") do |grp|
      grp.should_receive(:products).and_return({"product" => "product"})
    end
    group = flexmock("group") do |grp|
      grp.should_receive(:subgroups).and_return({"subgroup" => subgroup})
    end
    @app.migel_groups = {"group" => group}
    skip("Niklaus has not time to mock migel_product")
    assert_equal({"group" => group}, @app.each_migel_product {})
  end

  def test_migel_products
    subgroup = flexmock("subgroup") do |grp|
      grp.should_receive(:products).and_return({"product" => "product"})
    end
    group = flexmock("group") do |grp|
      grp.should_receive(:subgroups).and_return({"subgroup" => subgroup})
    end
    @app.migel_groups = {"group" => group}
    skip("Niklaus has not time to mock migel_product")
    assert_equal(["product"], @app.migel_products)
  end

  def test_migel_product
    subgroup = flexmock("subgroup") do |sub|
      sub.should_receive(:product).and_return("product")
    end
    group = flexmock("group") do |grp|
      grp.should_receive(:subgroup).and_return(subgroup)
    end
    @app.migel_groups = {"1" => group}
    skip("Niklaus has not time to mock migel_product")
    assert_equal("product", @app.migel_product("1.2.3"))
  end

  def test_migel_product__error
    @app.migel_groups = {"1" => "group"}
    skip("Niklaus has not time to mock migel_product")
    assert_nil(@app.migel_product("1.2.3"))
  end

  def test_index_therapeuticus
    @app.indices_therapeutici = {"code" => "index"}
    assert_equal("index", @app.index_therapeuticus("code"))
  end

  def test_feedback
    @app.feedbacks = {123 => "feedback"}
    assert_equal("feedback", @app.feedback("123"))
  end

  def test_invoice
    @app.invoices = {123 => "invoice"}
    assert_equal("invoice", @app.invoice("123"))
  end

  def test_narcotic
    @app.narcotics = {123 => "narcotics"}
    assert_equal("narcotics", @app.narcotic("123"))
  end

  def test_create_poweruser
    poweruser = flexmock("poweruser") do |pusr|
      pusr.should_receive(:oid)
    end
    flexstub(ODDB::PowerUser) do |usr|
      usr.should_receive(:new).and_return(poweruser)
    end
    @app.users = {}
    assert_equal(poweruser, @app.create_poweruser)
  end

  def test_create_user
    companyuser = flexmock("companyuser") do |usr|
      usr.should_receive(:oid)
    end
    flexstub(ODDB::CompanyUser) do |usr|
      usr.should_receive(:new).and_return(companyuser)
    end
    @app.users = {}
    assert_equal(companyuser, @app.create_user)
  end

  def test_each_sequence
    registration = flexmock("registration") do |reg|
      reg.should_receive(:each_sequence).and_yield
    end
    @app.registrations = {"1" => registration}
    assert_equal({"1" => registration}, @app.each_sequence {})
  end

  def test_fachinfos_by_name
    assert_equal([], @app.fachinfos_by_name("name", "lang"))
  end

  def test_package_by_ikskey
    registration = flexmock("registration") do |reg|
      reg.should_receive(:package).and_return("package")
    end
    @app.registrations = {"12345" => registration}
    assert_equal("package", @app.package_by_ikskey("12345678"))
  end

  def test__clean_odba_stubs_hash
    value = flexmock("val") do |val|
      val.should_receive(:"odba_instance.nil?").and_return(true)
    end
    assert_equal({}, @app._clean_odba_stubs_hash({"value" => value}))
  end

  def test__clean_odba_stubs_array
    value = flexmock("val") do |val|
      val.should_receive(:"odba_instance.nil?").and_return(true)
    end
    assert_equal([], @app._clean_odba_stubs_array([value]))
  end

  def test_clean_odba_stubs
    sequence = flexmock("sequence") do |seq|
      seq.should_receive(:packages).and_return({})
      seq.should_receive(:active_agents).and_return([])
    end
    registration = flexmock("registration") do |reg|
      reg.should_receive(:sequences).and_return({"key" => sequence})
    end
    @app.registrations = {"key" => registration}
    assert_equal({"key" => registration}, @app.clean_odba_stubs)
  end

  def test_yus_create_user
    # No-op after Swiyu migration
    assert_nil @app.yus_create_user("email", "pass")
  end

  def test_yus_grant
    # No-op after Swiyu migration
    assert_nil @app.yus_grant("name", "key", "item", "expires")
  end

  def test_yus_get_preference
    assert_nil @app.yus_get_preference("name", "key")
  end

  def test_yus_get_preferences
    assert_equal({}, @app.yus_get_preferences("name", "keys"))
  end

  def test_yus_get_preferences__error
    assert_equal({}, @app.yus_get_preferences("error", "error"))
  end

  def test_yus_model
    assert_nil @app.yus_model("name")
  end

  def test_yus_reset_password
    assert_nil @app.yus_reset_password("name", "token", "password")
  end

  def test_yus_set_preference
    assert_nil @app.yus_set_preference("name", "key", "value", "domain")
  end
end
