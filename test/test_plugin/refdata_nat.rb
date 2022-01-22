#!/usr/bin/env ruby
$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'minitest/autorun'
require 'flexmock/minitest'
require 'stub/odba'
require 'model/doctor'
require 'plugin/refdata_nat'
require 'tempfile'

class TestRefdataNatPlugin <Minitest::Test
  Test_NAT_XML = File.expand_path(File.join(__FILE__, '../../data/xml/refdata_nat.xml'))
  def teardown
    ODBA.storage = nil
    super # to clean up FlexMock
  end
  NR_SKIPPED = 3
  def setup
    FileUtils.rm_f(ODDB::Doctors::Doctors_XML)
    @config  = flexmock('config',
             :empty_ids => nil,
             :pointer   => 'pointer'
            )
    @config  = flexmock('config')
    @doctor = ODDB::Doctor.new
    @app     = flexmock('app',
              :config => @config,
              :create_doctor => @doctor,
              :doctors => [@doctor],
              :doctor_by_origin => @doctor,
              :update           => 'update',
            )
    @savon_mock = flexmock('savon_mock', Savon)
    @savon_client_mock = flexmock('savon_mock')
    @savon_response = flexmock('savon_response')
    @savon_response.should_receive(:success?).and_return(true).by_default
    @savon_response.should_receive(:to_xml).and_return(open(Test_NAT_XML).read).by_default
    @savon_client_mock.should_receive(:call).and_return(@savon_response).by_default
    @savon_mock.should_receive(:client).and_return(@savon_client_mock)
    @app.should_receive(:doctor_by_gln).and_return(nil).by_default
    @plugin = flexmock('refdata_doctor_plugin', ODDB::Doctors::RefdataNatPlugin.new(@app))
    @burgener_gln_id = 7601000115690
    @burgener_fullname = 'Roland Burgener'
  end
  def test_update_burgener
    @plugin = flexmock('refdata_doctor_plugin', ODDB::Doctors::RefdataNatPlugin.new(@app, [@burgener_gln_id]))
    flexmock(@plugin, :get_latest_file => [true, Test_NAT_XML])
    flexmock(@plugin, :get_doctor_data => {})
    startTime = Time.now
    created, updated, deleted, skipped = @plugin.update
    diffTime = (Time.now - startTime).to_i
    assert_equal({@burgener_gln_id=>@burgener_fullname}, created)
    assert_equal({}, updated, 'should have no updated')
    assert_equal({}, deleted, 'should have no deleted')
    assert_equal({}, skipped, 'should have no skipped')
    burgener = ODDB::Doctors::RefdataNatPlugin.all_doctors.first
    assert_equal('französisch', burgener.language)
    assert_equal(1, burgener.addresses.size)
    first_address = burgener.addresses.first
    assert_equal(ODDB::Address2, first_address.class)
    assert_equal('1941 Cries (Vollèges)', first_address.location)
    assert_equal('1941', first_address.plz)
    assert_equal('Cries (Vollèges)', first_address.city)
    assert_nil(first_address.address)
    assert_equal([], first_address.fon)
  end

  def test_update_Ramadani_utf8
    gtin2import = 7601000729446
    @plugin = flexmock('refdata_doctor_plugin', ODDB::Doctors::RefdataNatPlugin.new(@app, [gtin2import]))
    @ramadani_fullname = "With_no_UTF-Umlaut_"+[0xc3,0xa8,].pack("c*").force_encoding("US-ASCII")

    ramadani_from_app = flexmock('ramadani_from_app', ODDB::Doctor.new)
    ramadani_from_app.name = 'nameüüüü'
    non_utf_first_name = "non_utf_firstname" +[0xc3,0xa8,].pack("c*").force_encoding("US-ASCII")
    utf_first_name = "Mit Umlauten äüöèàéç" # from test/data/xml/refdata_nat.xml
    assert_equal('UTF-8', utf_first_name.encoding.to_s)
    ramadani_from_app.firstname = "firstname" +[0xc3,0xa8,0x99,0x99].pack("c*").force_encoding("US-ASCII")
    flexmock(@plugin, :get_latest_file => [true, Test_NAT_XML])
    flexmock(@plugin, :get_doctor_data => {})
    @app.should_receive(:doctor_by_gln).with(gtin2import).and_return(ramadani_from_app)
    @app.should_receive(:doctor_by_gln).with(any).and_return(nil)
    @app.should_receive(:delete_doctor).with('oid').never
    startTime = Time.now
    created, updated, deleted, skipped = @plugin.update
    diffTime = (Time.now - startTime).to_i
    assert_equal([gtin2import], updated.keys)
    ramadani = ODDB::Doctors::RefdataNatPlugin.all_doctors.first
    assert_equal('französisch', ramadani.language)
    assert_equal('Ramadani', ramadani.name)
    assert_equal(utf_first_name, ramadani.firstname)
  end

  def test_update_must_keep_telefon_and_fax
    fon_burgener = '077 123 45 67'
    fax_burgener = '076 123 45 99'
    burgener = flexmock('burgener', ODDB::Doctor.new)
    old_address1 = ODDB::Address2.new
    old_address1.name    =  'Sandoz must be changed'
    old_address1.address =  'avenue du Château de la Cour 4'
    old_address1.location = '1941 Cries (Vollèges)'
    old_address1.fon = [fon_burgener]
    old_address1.fax = [fax_burgener]
    old_address2 = ODDB::Address2.new
    old_address2.name    =  'Sandoz must be changed'
    old_address2.address =  'Some Dummy Address'  
    old_address2.location = '3960 Sierre VS'
    old_address2.fon = [fon_burgener.sub('077', '078')]
    old_address2.fax = [fax_burgener.sub('076', '079')]
    burgener.addresses[0] = old_address1
    burgener.addresses << old_address2
    @app.should_receive(:doctor_by_gln).with(@burgener_gln_id).and_return(burgener)
    @app.should_receive(:doctor_by_gln).with(any).and_return(nil)
    @app.should_receive(:delete_doctor).with('oid').never
    @plugin = flexmock('refdata_doctor_plugin', ODDB::Doctors::RefdataNatPlugin.new(@app, [@burgener_gln_id]))
    flexmock(@plugin, :get_latest_file => [true, Test_NAT_XML])
    flexmock(@plugin, :get_doctor_data => {})
    assert_equal(2, burgener.addresses.size)
    created, updated, deleted, skipped = @plugin.update
    result = ODDB::Doctors::RefdataNatPlugin.all_doctors.first
    assert_equal(2,  ODDB::Doctors::RefdataNatPlugin.all_doctors.first.addresses.size)
    first_address = result.addresses.first
    assert_equal('Burgener', result.name)
    assert_equal('Roland', result.firstname)
    assert_equal(ODDB::Address2, first_address.class)
    assert_equal('Roland Burgener', first_address.name)
    assert_equal('1941 Cries (Vollèges)', first_address.location)
    assert_equal('1941', first_address.plz)
    assert_equal('Cries (Vollèges)', first_address.city)
    assert_equal([], first_address.additional_lines)
    last_address = result.addresses.last
    assert_equal(ODDB::Address2, last_address.class)
    assert_equal('3960 Sierre VS', last_address.location)
    assert_equal('3960', last_address.plz)
    assert_equal('Sierre VS', last_address.city)
    assert_equal('Sandoz must be changed', last_address.name)
  end

  def test_update_must_change_telefon_and_fax_if_plz_differ
    fon_burgener = '077 123 45 67'
    fax_burgener = '076 123 45 99'
    burgener = flexmock('burgener', ODDB::Doctor.new)
    old_address1 = ODDB::Address2.new
    old_address1.name    =  'Sandoz must be changed'
    old_address1.address =  'avenue du Château de la Cour 4'
    old_address1.location = '3962 NotSierre'+[0xc3,0xa8,].pack("c*").force_encoding("US-ASCII")
    old_address1.fon = [fon_burgener]
    old_address1.fax = [fax_burgener]
    old_address2 = ODDB::Address2.new
    old_address2.name    =  'Sandoz must be changed'
    old_address2.address =  'must be changed 3555'
    old_address2.location = '8888 must be changed'
    old_address2.fon = [fon_burgener.sub('077', '078')]
    old_address2.fax = [fax_burgener.sub('076', '079')]
    @doctor.addresses[0] = old_address1
    @doctor.addresses << old_address2
    @app.should_receive(:doctor_by_gln).with(@burgener_gln_id).and_return(burgener)
    @app.should_receive(:doctor_by_gln).with(any).and_return(nil)
    @app.should_receive(:delete_doctor).with('oid').never
    @plugin = flexmock('refdata_doctor_plugin', ODDB::Doctors::RefdataNatPlugin.new(@app, [@burgener_gln_id]))
    flexmock(@plugin, :get_latest_file => [true, Test_NAT_XML])
    flexmock(@plugin, :get_doctor_data => {})
    created, updated, deleted, skipped = @plugin.update
    result = ODDB::Doctors::RefdataNatPlugin.all_doctors.first
    assert_equal(1,  ODDB::Doctors::RefdataNatPlugin.all_doctors.first.addresses.size)
    first_address = result.addresses.first
    assert_equal(ODDB::Address2, first_address.class)
    assert_equal('Roland Burgener', first_address.name)
    assert_equal('1941 Cries (Vollèges)', first_address.location)
    assert_equal('1941', first_address.plz)
    assert_equal('Cries (Vollèges)', first_address.city)
    assert_equal([], first_address.additional_lines)
  end

  def test_old_and_new_address_are_nil
    gln = 7601000729446
    ramadani = flexmock('Ramadani', ODDB::Doctor.new)
    @doctor.addresses.delete_at(0)
    @app.should_receive(:doctor_by_gln).with().and_return(gln)
    @app.should_receive(:doctor_by_gln).with(any).and_return(nil)
    @app.should_receive(:delete_doctor).with('oid').never
    @plugin = flexmock('refdata_doctor_plugin', ODDB::Doctors::RefdataNatPlugin.new(@app, [gln]))
    flexmock(@plugin, :get_latest_file => [true, Test_NAT_XML])
    flexmock(@plugin, :get_doctor_data => {})
    created, updated, deleted, skipped = @plugin.update
    assert_equal(0,  updated.size)
    result = ODDB::Doctors::RefdataNatPlugin.all_doctors.first
    assert_equal('Ramadani', result.name)
    assert_equal(1,  result.addresses.size)
  end

  def test_update_new_address_is_nil
    gln = 7601000729446
    ramadani = flexmock('Ramadani', ODDB::Doctor.new)
    old_address1 = ODDB::Address2.new
    old_address1.name    =  'Sandoz must be changed'
    old_address1.address =  'avenue du Château de la Cour 4'
    old_address1.location = '3960 Sierre'
    ramadani.name = 'Ramadani'
    ramadani.firstname = 'Naser'
    ramadani.language = 'französisch'    
    ramadani.addresses <<  old_address1 
    assert_equal(1,  ramadani.addresses.size)
    @app.should_receive(:doctor_by_gln).with(gln).and_return(ramadani)
    @app.should_receive(:delete_doctor).with('oid').never
    @plugin = flexmock('refdata_doctor_plugin', ODDB::Doctors::RefdataNatPlugin.new(@app, [gln]))
    flexmock(@plugin, :get_latest_file => [true, Test_NAT_XML])
    flexmock(@plugin, :get_doctor_data => {})
    assert_equal(1,  ramadani.addresses.size)
    created, updated, deleted, skipped = @plugin.update
    assert_equal(0,  created.size)
    assert_equal(1,  updated.size)
    assert_equal(0,  deleted.size)
    assert_equal(false, @plugin.report.empty?)
  end

  def test_update_all
    globofarm = flexmock('globofarm', :oid => 'oid')
    @app.should_receive(:doctor_by_gln).with(7601001372689).and_return(globofarm)
    @app.should_receive(:doctor_by_gln).with(any).and_return(nil)
    @app.should_receive(:delete_doctor).with('oid').never
    @plugin = ODDB::Doctors::RefdataNatPlugin.new(@app)
    flexmock(@plugin, :get_latest_file => [true, Test_NAT_XML])
    flexmock(@plugin, :get_doctor_data => {})
    flexmock(@plugin, :puts => nil)
    startTime = Time.now
    created, updated, deleted, skipped = @plugin.update
    diffTime = (Time.now - startTime).to_i
    assert_equal({@burgener_gln_id=>@burgener_fullname, 7601000729446=> "Mit Umlauten äüöèàéç Ramadani"}, created)
    assert_equal({}, updated)
    assert_equal({}, deleted)
    assert_equal(0, skipped.size)
  end

  def test_get_latest_file
    latest = File.expand_path(File.join(__FILE__, "../../../data/xml/refdata_nat_latest.xml"))
    current  = File.expand_path(File.join(__FILE__, "../../../data/xml/refdata_nat_#{Time.now.strftime('%Y.%m.%d')}.xml"))
    FileUtils.rm_f(current) if File.exist?(current)
    FileUtils.rm_f(latest) if File.exist?(latest)
    @plugin = ODDB::Doctors::RefdataNatPlugin.new(@app)
    res = @plugin.get_latest_file
    assert(res[0], 'needs_update must be true')
    assert(res[1].match(/latest/), 'filename must match latest')
    assert_equal(latest, res[1])
    assert(File.exist?(latest), 'doctors_latest.xml must exist')
    assert(File.exist?(current), 'doctors_with_timestamp.xml must exist')
    assert_equal(File.size(Test_NAT_XML), File.size(res[1]))
  end
end
