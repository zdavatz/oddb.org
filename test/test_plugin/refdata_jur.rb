#!/usr/bin/env ruby
$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'minitest/autorun'
require 'flexmock/minitest'
require 'stub/odba'
require 'util/oddbapp'
require 'plugin/refdata_jur'
require 'tempfile'

class TestRefdataJurPlugin <Minitest::Test
  Test_JUR__XML = File.join(ODDB::TEST_DATA_DIR, 'xml/refdata_jur.xml')
  def teardown
    ODBA.storage = nil
    super # to clean up FlexMock
  end
  def setup
    FileUtils.rm_rf(ODDB::WORK_DIR)
    @config  = flexmock('config',
             :empty_ids => nil,
             :pointer   => 'pointer'
            )
    @config  = flexmock('config')
    @companies = {}
    @hospitals = {}
    @app     = flexmock('app', # ODDB::App.new,
              :config => @config,
              :companies => @companies,
              :company_by_origin => @company,
              :pharmacies => @pharmacies,
              :hospitals => @hospitals,
              :update           => 'update',
            )
    @app.should_receive(:hospital_by_gln).with(any).and_return(nil).by_default
    @app.should_receive(:company_by_gln).with(any).and_return(nil).by_default
    @app.should_receive(:pharmacy_by_gln).with(any).and_return(nil).by_default
    @app.should_receive(:create_company).by_default.and_return do
      company = ODDB::Company.new
    end
    [7601001049048, 7601001049048, 7601002525954].each do |ean13|
      @app.should_receive(:create_hospital).with(ean13).by_default.and_return do
        hospital = ODDB::Hospital.new(ean13); 
        @hospitals[ean13] = hospital; 
        hospital
      end
    end
    @savon_mock = flexmock('savon_mock', Savon)
    @savon_client_mock = flexmock('savon_mock')
    @savon_response = flexmock('savon_response')
    @savon_response.should_receive(:success?).and_return(true).by_default
    @savon_response.should_receive(:to_xml).and_return(open(Test_JUR__XML).read).by_default
    @savon_client_mock.should_receive(:call).and_return(@savon_response).by_default
    @savon_mock.should_receive(:client).and_return(@savon_client_mock)
    @plugin = flexmock('refdata_partner_plugin', ODDB::Companies::RefdataJurPlugin.new(@app))
    @expected_created = { 7601002028127=>"ba_hospital_pharmacy Bethesda Spital AG",
                          7601002003117=>"ba_hospital_pharmacy Hôpital neuchâtelois Val-de-Travers",
                          7601002054799=>"ba_hospital_pharmacy Clinica Psichiatrica di Giorno",
                          7601001049048=>"ba_hospital HUG Hôpitaux Universitaires de Genève",
                          7601002525954=>"ba_hospital GZO Spital Wetzikon",
                          7601001367753=>"ba_public_pharmacy Amavita Apotheke Vorstadt",
                          7601001396371=>"ba_public_pharmacy Lindenapotheke Rupperswil",
                          7601001365346=>"ba_public_pharmacy Apotheke Drogerie Strättligen AG",
                          7601001397835=>"ba_pharma Sandoz AG",
                          7601001004092=>"ba_pharma Rivopharm SA"}

  end

  def test_update_7601001396371
    gln_linden = 7601001396371
    @plugin = flexmock('refdata_partner_plugin', ODDB::Companies::RefdataJurPlugin.new(@app, [gln_linden]))
    flexmock(@plugin, :get_latest_file => [true, Test_JUR__XML])
    flexmock(@plugin, :get_company_data => {})
    startTime = Time.now
    created, updated, deleted, skipped = @plugin.update
    diffTime = (Time.now - startTime).to_i
    assert_equal({7601001396371=>"ba_public_pharmacy Lindenapotheke Rupperswil"}, created)
    assert_equal({}, updated)
    assert_equal({}, deleted)
    assert_equal({}, skipped)
    linden = ODDB::Companies::RefdataJurPlugin.all_partners.first
    assert_equal(1, linden.addresses.size)
    first_address = linden.addresses.first
    assert_equal(ODDB::Address2, first_address.class)
    assert_equal([], first_address.fon)
    assert_equal('5102 Rupperswil', first_address.location)
    assert_equal('5102', first_address.plz)
    assert_equal('Rupperswil', first_address.city)
    assert_equal('4', first_address.number)
    assert_equal('Mitteldorf', first_address.street)
    assert_equal([], first_address.additional_lines)
    assert_nil(first_address.name)
    assert_equal(linden.business_area, ODDB::BA_type::BA_public_pharmacy, 'business_area should be set')
    # TODO: assert_equal(linden.narcotics, '6011 Verzeichnis a/b/c BetmVV-EDI')
  end

  def test_update_7601001397835
    gln_sandoz = 7601001397835
    @plugin = flexmock('refdata_partner_plugin', ODDB::Companies::RefdataJurPlugin.new(@app, [gln_sandoz]))
    flexmock(@plugin, :get_latest_file => [true, Test_JUR__XML])
    flexmock(@plugin, :get_company_data => {})
    created, updated, deleted, skipped = @plugin.update
    assert_equal(1, created.size)
    assert_equal(0, updated.size)
    assert_equal(0, deleted.size)
    sandoz = ODDB::Companies::RefdataJurPlugin.all_partners.first
    first_address = sandoz.addresses.first
    assert_equal(ODDB::Address2, first_address.class)
    assert_equal([], first_address.fon)
    assert_equal('4056 Basel', first_address.location)
    assert_equal('4056', first_address.plz)
    assert_equal('Basel', first_address.city)
    assert_equal('35', first_address.number)
    assert_equal('Lichtstrasse', first_address.street)
    assert_nil(first_address.name)
    assert_equal([], first_address.additional_lines)
  end

  def test_update_must_keep_telefon_and_fax
    gln_sandoz = 7601001397835
    fon_sandoz = '077 123 45 67'
    fax_sandoz = '077 123 45 99'
    sandoz = flexmock('sandoz', ODDB::Company.new)
    old_address = ODDB::Address2.new
    old_address.name    =  'Sandoz must be changed'
    old_address.address =  'must be changed 3555'
    old_address.location = '333 must be changed'
    old_address.fon = [fon_sandoz]
    old_address.fax = [fax_sandoz]
    old_address.revision = Date.parse('2016.01.01')
    sandoz.ean13 = gln_sandoz
    sandoz.addresses[0]= old_address
    @app.should_receive(:company_by_gln).with(gln_sandoz).and_return(sandoz)
    @app.should_receive(:delete_company).with('oid').never
    @plugin = flexmock('refdata_partner_plugin', ODDB::Companies::RefdataJurPlugin.new(@app, [gln_sandoz]))
    flexmock(@plugin, :get_latest_file => [true, Test_JUR__XML])
    flexmock(@plugin, :get_company_data => {})
    created, updated, deleted, skipped = @plugin.update
    sandoz = ODDB::Companies::RefdataJurPlugin.all_partners.first
    first_address = sandoz.addresses.first
    assert_equal(ODDB::Address2, first_address.class)
    assert_equal('Sandoz AG', sandoz.name)
    assert_equal('4056 Basel', first_address.location)
    assert_equal('4056', first_address.plz)
    assert_equal('Basel', first_address.city)
    assert_equal('35', first_address.number)
    assert_equal('Lichtstrasse', first_address.street)
    assert_equal([], first_address.additional_lines)
    assert_equal([fon_sandoz], first_address.fon)
    assert_equal([fax_sandoz], first_address.fax)
  end

  def test_create_hospital
    ean13 = 7601002525954
    wetzikon = flexmock('wetzikon', :oid => 'oid')
    @app.should_receive(:delete_company).with('oid').never
    @plugin = ODDB::Companies::RefdataJurPlugin.new(@app)
    flexmock(@plugin, :get_latest_file => [true, Test_JUR__XML])
    flexmock(@plugin, :get_company_data => {})
    flexmock(@plugin, :puts => nil)
    startTime = Time.now
    created, updated, deleted, skipped = @plugin.update
    diffTime = (Time.now - startTime).to_i
    assert_equal(2, @app.hospitals.size)
    new_hospital = @app.hospitals[ean13]
    assert_equal(1, new_hospital.addresses.size)
    assert_equal('Spitalstrasse 66', new_hospital.addresses.first.address)
    assert_equal('8623 Wetzikon ZH', new_hospital.addresses.first.location)
    assert_equal('GZO Spital Wetzikon', new_hospital.name)
    assert(created.keys.index(ean13.to_i))
  end

  def test_update_hospital_same_address
    genf = flexmock('genf', @app.create_hospital(7601001049048))
    genf.narcotics = narcotics = '6011 Verzeichnis a/b/c BetmVV-EDI'
    address = ODDB::Address2.new
    address.fon = ['022 3829932']
    address.fax = ['022 3829940']
    address.address = rue = 'rue Gabrielle-Perret-Gentil 4'
    address.location = location = '1205 Genève'
    address.name = name = "HUG Hôpitaux Universitaires de Genève"
    genf.addresses[0] = address
    @app.should_receive(:hospital_by_gln).with(any).and_return(genf)
    @plugin = ODDB::Companies::RefdataJurPlugin.new(@app, [7601001049048])
    flexmock(@plugin, :get_latest_file => [true, Test_JUR__XML])
    flexmock(@plugin, :get_company_data => {})
    startTime = Time.now
    created, updated, deleted, skipped = @plugin.update()
    diffTime = (Time.now - startTime).to_i
    assert_equal(1, @app.hospitals.size)
    assert_equal(1, @app.hospitals.values.first.addresses.size)
    assert_equal(rue, @app.hospitals.values.first.addresses.first.address)
    assert_equal(location, @app.hospitals.values.first.addresses.first.location)
    assert_equal(name, @app.hospitals.values.first.addresses.first.name)
    assert_equal({}, created)
    assert_equal({7601001049048=>{:name=>" => #{name}"}}, updated)
    assert_equal({}, deleted)
    assert_equal(0, skipped.size)
    assert_equal(narcotics, @app.hospitals.values.first.narcotics)
  end

  def test_update_hospital_different_address
    genf = flexmock('genf', @app.create_hospital(7601001049048))
    address = ODDB::Address2.new
    address.fon = ['022 3829932']
    address.fax = ['022 3829940']
    rue = 'rue Gabrielle-Perret-Gentil 4'
    address.address =  rue + 'changed'
    address.location = location = '1205 Genève'
    address.name = name = "HUG Hôpitaux Universitaires de Genève"
    genf.addresses[0] = address
    @app.should_receive(:hospital_by_gln).with(any).and_return(genf)
    @plugin = ODDB::Companies::RefdataJurPlugin.new(@app, [7601001049048])
    flexmock(@plugin, :get_latest_file => [true, Test_JUR__XML])
    flexmock(@plugin, :get_company_data => {})
    startTime = Time.now
    created, updated, deleted, skipped = @plugin.update()
    diffTime = (Time.now - startTime).to_i
    assert_equal(1, @app.hospitals.size)
    assert_equal(1, @app.hospitals.values.first.addresses.size)
    assert_equal(rue, @app.hospitals.values.first.addresses.first.address)
    assert_equal(location, @app.hospitals.values.first.addresses.first.location)
    assert_equal(name, @app.hospitals.values.first.addresses.first.name)
    assert_equal({}, created)
    assert_equal([7601001049048], updated.keys)
    assert_match(/address/, updated.values.to_s)
    assert_equal({}, deleted)
    assert_equal(0, skipped.size)
  end

  def test_update_all
    globofarm = flexmock('globofarm', :oid => 'oid', :name => 'name')
    @app.should_receive(:company_by_gln).with(7601001372689).and_return(globofarm)
    @app.should_receive(:company_by_gln).with(any).and_return(nil)
    @app.should_receive(:delete_company).with('oid').never
    @plugin = ODDB::Companies::RefdataJurPlugin.new(@app)
    flexmock(@plugin, :get_latest_file => [true, Test_JUR__XML])
    flexmock(@plugin, :get_company_data => {})
    startTime = Time.now
    created, updated, deleted, skipped = @plugin.update
    diffTime = (Time.now - startTime).to_i
    assert_equal(@expected_created, created)
    assert_equal({}, updated)
    assert_equal({7601001372689=>"name"}, deleted)
    assert_equal(3, skipped.size)
    assert_equal(3, @app.companies.select{|key, item| item.is_pharmacy? }.size)
    assert_equal(8, @app.companies.size)
    assert_equal(2, @app.hospitals.size)
  end

  def test_update_gtins_to_import_nil
    globofarm = flexmock('globofarm', :oid => 'oid', :name => 'name')
    @app.should_receive(:company_by_gln).with(7601001372689).and_return(globofarm)
    @app.should_receive(:company_by_gln).with(any).and_return(nil)
    @app.should_receive(:delete_company).with('oid').never
    @plugin = ODDB::Companies::RefdataJurPlugin.new(@app, nil)
    flexmock(@plugin, :get_latest_file => [true, Test_JUR__XML])
    flexmock(@plugin, :get_company_data => {})
    startTime = Time.now
    created, updated, deleted, skipped = @plugin.update
    diffTime = (Time.now - startTime).to_i
    assert_equal(@expected_created, created)
  end

  def test_update_report_empty
    @plugin = ODDB::Companies::RefdataJurPlugin.new(@app,[760100139999])
    flexmock(@plugin, :get_latest_file => [true, Test_JUR__XML])
    flexmock(@plugin, :get_company_data => {})
    created, updated, deleted, skipped = @plugin.update()
    assert_equal(0, created.size)
    assert_equal(0, updated.size)
    assert_equal(0, deleted.size)
    assert_equal(true, @plugin.report.empty?)
  end

  def test_get_latest_file
    latest = File.join(ODDB::WORK_DIR, "xml/refdata_jur_latest.xml")
    current  = File.join(ODDB::WORK_DIR, "xml/refdata_jur_#{Time.now.strftime('%Y.%m.%d')}.xml")
    FileUtils.rm_f(current) if File.exist?(current)
    FileUtils.rm_f(latest) if File.exist?(latest)
    @plugin = ODDB::Companies::RefdataJurPlugin.new(@app)
    res = @plugin.get_latest_file
    assert(res[0], 'needs_update must be true')
    assert(res[1].match(/latest/), 'filename must match latest')
    assert_equal(latest, res[1])
    assert(File.exist?(latest), 'companies_latest.xml must exist')
    assert(File.exist?(current), 'companies_with_timestamp.xml must exist')
    assert_equal(File.size(Test_JUR__XML), File.size(res[1]))
  end
end

# 7601001010857: {:name=>"Pharmacie Populaire Grosclaude => Officine Grosclaude", :narcotics=>"6011 Verzeichnis a/b/c BetmVV-EDI => ", 
         # "addresses"=>"-Officine Grosclaude,cours de Rive 2,1204 Genève,fon,fax\n
          # +Pharmacie Populaire Grosclaude,Cours de Rive 2,1204 Genève,fon,fax\n"}
# 7601001366442: {:name=>"Pharmacie Amavita Carl-Vogt => GaleniCare SA", :narcotics=>"6011 Verzeichnis a/b/c BetmVV-EDI => ", "addresses"=>"-GaleniCare SA,boulevard Carl-Vogt 18,1205 Genève,fon,fax\n+Pharmacie Amavita Carl-Vogt,Boulevard Carl-Vogt 18,1205 Genève,fon,fax\n"}
