#!/usr/bin/env ruby
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
gem 'minitest'
require 'minitest/autorun'
require 'stub/oddbapp'
require 'digest/md5'
require 'util/persistence'
require 'model/substance'
require 'model/atcclass'
require 'model/orphan'
require 'model/galenicform'
require 'util/language'
require 'flexmock'
require 'util/oddbapp'

class TestOddbApp <MiniTest::Unit::TestCase
  include FlexMock::TestCase

	def setup
		ODDB::GalenicGroup.reset_oids
    ODBA.storage.reset_id
		dir = File.expand_path('../data/prevalence', File.dirname(__FILE__))
		@app = ODDB::App.new

    @session = flexmock('session') do |ses|
      ses.should_receive(:grant).with('name', 'key', 'item', 'expires')\
        .and_return('session')
      ses.should_receive(:entity_allowed?).with('email', 'action', 'key')\
        .and_return('session')
      ses.should_receive(:create_entity).with('email', 'pass')\
        .and_return('session')
      ses.should_receive(:get_entity_preference).with('name', 'key')\
        .and_return('session')
      ses.should_receive(:get_entity_preference).with('name', 'association')\
        .and_return('odba_id')
      ses.should_receive(:get_entity_preferences).with('name', 'keys')\
        .and_return('session')
      ses.should_receive(:get_entity_preferences).with('error', 'error')\
        .and_raise(Yus::YusError)
      ses.should_receive(:reset_entity_password).with('name', 'token', 'password')\
        .and_return('session')
      ses.should_receive(:set_entity_preference).with('name', 'key', 'value', 'domain')\
        .and_return('session')
    end
    flexmock(ODDB::App::YUS_SERVER) do |yus|
      yus.should_receive(:autosession).and_yield(@session)
    end
    flexstub(ODBA.storage) do |sto|
      sto.should_receive(:remove_dictionary)
      sto.should_receive(:generate_dictionary).with('language', 'locale', String)\
        .and_return('generate_dictionary')
      sto.should_receive(:generate_dictionary).with('french', 'fr_FR@euro', String)\
        .and_return('french_dictionary')
      sto.should_receive(:generate_dictionary).with('german', 'de_DE@euro', String)\
        .and_return('german_dictionary')
    end
	end
	def teardown
		ODBA.storage = nil
    super
	end
	def test_galenic_group_initialized
		expected_pointer = ODDB::Persistence::Pointer.new([:galenic_group, 1])
		assert_equal(expected_pointer, @app.galenic_groups.values.first.pointer)
		assert_equal('Unbekannt', expected_pointer.resolve(@app).description)
	end
	def test_unknown_user
		assert_instance_of(ODDB::UnknownUser, @app.unknown_user)
	end
	def test_registration
		reg = StubRegistration.new('12345')
		@app.registrations = {'12345'=>reg}
		assert_equal(reg, @app.registration('12345'))
		assert_equal('12345', @app.registration('12345').iksnr)
		assert_nil(@app.registration('54321'))
	end
	def test_create_registration
		@app.registrations = {}
		pointer = ODDB::Persistence::Pointer.new(['registration', '12345'])
		result = @app.create(pointer)
		assert_equal(ODDB::Registration, result.class)
		assert_equal(1, @app.registrations.size)
		assert_equal(ODDB::Registration, @app.registrations['12345'].class)
		assert_equal(pointer, @app.registrations['12345'].pointer)
	end
	def test_update_registration
		pointer = ODDB::Persistence::Pointer.new(['registration', '12345'])
		@app.create(pointer)
		values = {
			:registration_date	=>	'12.04.2002',
		}
		@app.update(pointer, values)
		reg = @app.registrations['12345']
		assert_equal(Date.new(2002,4,12), reg.registration_date)
	end
	def test_create_sequence
		pointer = ODDB::Persistence::Pointer.new(['registration', '12345'])
		reg = @app.create(pointer)
		reg.sequences = {}
		pointer += ['sequence', '01']
		expected = [
			['registration', '12345']
		]
		assert_equal(expected, reg.pointer.directions)
		result = @app.create(pointer)
		assert_equal(expected, reg.pointer.directions)
		assert_equal(ODDB::Sequence, result.class)
		expected = [
			['registration', '12345'],
			['sequence', '01'],
		]
		result.pointer.directions
		seq = reg.sequence('01')
		assert_equal(seq, reg.sequence('01'))
	end
	def test_update_sequence
		pointer = ODDB::Persistence::Pointer.new(['registration', '12345'])
		reg = @app.create(pointer)
		pointer += ['sequence', '01']
		seq = @app.create(pointer)
		@app.atc_classes = { 'N02BA01' => ODDB::AtcClass.new('N02BA01') }
		grouppointer = ODDB::Persistence::Pointer.new(:galenic_group)
		galgroup = @app.create(grouppointer)
		galpointer = galgroup.pointer + [:galenic_form]
		@app.update(galpointer.creator, {:de => 'Tabletten'})
		values = {
			:name					=>	"Aspirin Cardio",
			:atc_class		=>	'N02BA01',
		}
		@app.update(pointer, values)
		seq = @app.registration('12345').sequence('01')
		assert_equal('Aspirin Cardio', seq.name)
		assert_equal(@app.atc_class('N02BA01'), seq.atc_class)
	end
	def test_create_package
		pointer = ODDB::Persistence::Pointer.new(['registration', '12345'])
		reg = @app.create(pointer)
		pointer += ['sequence', '01']
		seq = @app.create(pointer)
		seq.packages = {}
		pointer += ['package', '032']
		result = @app.create(pointer)
		assert_equal(ODDB::Package, result.class)
		package = seq.packages['032']
		assert_equal(package, seq.package('032'))
	end
	def test_create_patinfo
		pointer = ODDB::Persistence::Pointer.new(:patinfo)
		result = @app.create(pointer)
		assert_instance_of(ODDB::Patinfo, result)
		expected = {result.oid => result}
		assert_equal(expected, @app.patinfos)
	end
	def test_create_patinfo2
		pat1 = @app.create_patinfo
		pat2 = @app.create_patinfo
		expected = {pat1.oid=>pat1,
			    pat2.oid=>pat2,
							}
		assert_equal(expected,@app.patinfos)
		assert_equal(pat1.oid+1,pat2.oid)
	end
	def test_update_package
		pointer = ODDB::Persistence::Pointer.new(['registration', '12345'])
		reg = @app.create(pointer)
		pointer += ['sequence', '01']
		seq = @app.create(pointer)
		seq.packages = {}
		pointer += ['package', '032']
		result = @app.create(pointer)
		values = {
			'descr'					=>	nil,
			'ikscat'				=>	'A',
		}
		@app.update(pointer, values)
		package = @app.registration('12345').package(32)
		assert_equal(nil, package.descr)
		assert_equal('A', package.ikscat)
	end
	def test_galenic_form
		galenic_form = StubGalenicForm.new('Tabletten')
		group = StubGalenicGroup.new
		group.galenic_form = galenic_form
		@app.galenic_groups = { 2 => group }
		assert_equal(galenic_form, @app.galenic_form('Tabletten'))
	end
	def test_create_galenic_group
		@app.galenic_groups = {}
		pointer = ODDB::Persistence::Pointer.new([:galenic_group])
		galgroup = @app.create(pointer)
		assert_equal(galgroup.oid, @app.galenic_group(galgroup.oid).oid)
		assert_equal(1, @app.galenic_groups.size)
	end
	def test_create_substance
		@app.substances = {}
		substance = 'ACIDUM ACETYLSALICYLICUM'
		assert_nil(@app.substance(substance))
		pointer = ODDB::Persistence::Pointer.new(['substance', 'ACIDUM ACETYLSALICYLICUM'])
		created = @app.create(pointer)
		assert_equal(1, @app.substances.size)
		assert_equal(ODDB::Substance, created.class)
		result = @app.substance(created.oid)
		assert_equal(ODDB::Substance, result.class)
		assert_equal('Acidum Acetylsalicylicum', result.name)
	end
	def test_update_substance
		@app.substances = {}
		pointer = ODDB::Persistence::Pointer.new(:substance)
		descr = {
			'en'			=>	'first_name',
		}
		subs = @app.update(pointer.creator, descr)
		values = {
			:en	=>	'en_name',
			:de	=>	'de_name',
		}
		@app.update(subs.pointer, values)
		assert_equal('En_name', subs.en)
		assert_equal('De_name', subs.de)
    skip("Niklaus has no time to debug next assertion")
		assert_equal(subs, @app.substances)
	end
	def test_create_atc_class
		@app.atc_classes = {}
		pointer = ODDB::Persistence::Pointer.new(['atc_class', 'N02BA01'])
		atc = @app.create(pointer)
		assert_equal(ODDB::AtcClass, @app.atc_class('N02BA01').class)
		assert_equal(atc, @app.atc_class('N02BA01'))
	end
	def test_company
		company = ODDB::Company.new
		@app.companies = {company.oid => company}
		oid = @app.companies.keys.first
		assert_equal(company, @app.company(oid))
	end
	def test_doctor
		doctor = ODDB::Company.new
		@app.doctors = {doctor.oid => doctor}
		oid = @app.doctors.keys.first
		assert_equal(doctor, @app.doctor(oid))
	end
	def test_company_by_name1
		company1 = ODDB::Company.new
		company2 = ODDB::Company.new
		company1.name = 'ywesee'
		company2.name = 'hal'
		@app.companies = {
			company1.oid => company1,
			company2.oid => company2,
		}
		assert_equal(company1, @app.company_by_name('ywesee'))
	end
	def test_company_by_name2
		company1 = ODDB::Company.new
		company2 = ODDB::Company.new
		company1.name = 'ywesee'
		company2.name = 'hal'
		@app.companies = {
			company1.oid => company1,
			company2.oid => company2,
		}
		assert_equal(company2, @app.company_by_name('hal'))
	end
	def test_company_by_name3
		company1 = ODDB::Company.new
		company2 = ODDB::Company.new
		company1.name = 'ywesee'
		company2.name = 'hal'
		@app.companies = {
			company1.oid => company1,
			company2.oid => company2,
		}
		assert_equal(nil, @app.company_by_name('pear'))
	end
	def test_create_company
			@app.companies = {}
			@app.create_company
		oid = @app.companies.keys.first
		company = @app.companies.values.first
		assert_equal(ODDB::Company, @app.company(oid).class)
		assert_equal(company, @app.company(oid))
	end
	def test_create_doctor
			@app.doctors = {}
			@app.create_doctor
		oid = @app.doctors.keys.first
		doctor = @app.doctors.values.first
		puts @app.doctors.inspect
		assert_equal(ODDB::Doctor, @app.doctor(oid).class)
		assert_equal(doctor, @app.doctor(oid))
	end
	def test_delete_company
		company3 = @app.create_company
		@app.companies = {company3.oid => company3}
		company2 = @app.create_company
		company2.name = 'ywesee'
		company3.name = 'ehz'
		expected1 = {company2.oid => company2, company3.oid => company3}
		puts expected1.inspect
		assert_equal(expected1, @app.companies)
		@app.delete_company(company2.oid)
		expected2 = {company3.oid => company3}
		assert_equal(expected2, @app.companies)
	end
	def test_delete_doctor
		doctor2 = @app.create_doctor
		doctor3 = @app.create_doctor
	  doctor2.name = 'foobar'
	  doctor3.name = 'foobaz'
		expected1 = {doctor2.oid => doctor2, doctor3.oid => doctor3}
		assert_equal(expected1, @app.doctors)
		@app.delete_doctor(doctor2.oid)
		expected2 = {doctor3.oid => doctor3}
		assert_equal(expected2, @app.doctors)
	end
	def test_delete_galenic_group
		group = StubGalenicGroup.new
		@app.galenic_groups = {
			12345	=>	group,
		}
		group.galenic_form = StubGalenicForm.new('Tabletten')
		assert_equal(false, group.empty?)
		assert_raises(RuntimeError) { @app.delete_galenic_group('12345') }
		group.galenic_form = nil
		@app.delete_galenic_group('12345')
	end
	def test_generic_group
		pointer = ODDB::Persistence::Pointer.new(['registration', '12345'],
			['sequence', '01'], ['package', '032'])
		generic_group = ODDB::GenericGroup.new
		@app.generic_groups = { pointer => generic_group }
		assert_equal(generic_group, @app.generic_group(pointer))
	end
	def test_create_generic_group
		pointer = ODDB::Persistence::Pointer.new(['registration', '12345'])
		reg = @app.create(pointer)
		pointer += ['sequence', '01']
		seq = @app.create(pointer)
		seq.packages = {}
		pointer += ['package', '032']
		package = @app.create(pointer)
		@app.generic_groups = {}
		group_pointer = ODDB::Persistence::Pointer.new(['generic_group', pointer])
		generic_group = @app.create(group_pointer)
		assert_equal(generic_group, @app.generic_groups[pointer])
		assert_equal(group_pointer, generic_group.pointer)
	end
	def test_create_indication
		@app.indications = {}
		pointer = ODDB::Persistence::Pointer.new(:indication)
		result = @app.create(pointer)
		assert_instance_of(ODDB::Indication, result)
		assert_equal(1, @app.indications.size)
		oid = result.oid
		assert_equal(result, @app.indication(oid))
	end
	def test_update_indication
		@app.indications = {}
		pointer = ODDB::Persistence::Pointer.new(:indication)
		result = @app.create(pointer)
		values = {
			:la	=>	"Hypertonicum",
		}
		@app.update(result.pointer, values)
		assert_equal('Hypertonicum', result.la)
		assert_equal(result, @app.indication_by_text('Hypertonicum'))
		#assert_equal([result], @app.indication_index.fetch('hypertonicum'))
		values = {
			:la =>	"Coagulantium",
		}
		@app.update(result.pointer, values)
		assert_equal('Coagulantium', result.la)
		assert_equal(nil, @app.indication_by_text('Hypertonicum'))
		#assert_equal([], @app.indication_index.fetch('hypertonicum'))
		assert_equal(result, @app.indication_by_text('Coagulantium'))
		#assert_equal([result], @app.indication_index.fetch('coagulantium'))
	end
	def test_unique_atc_class
		atc_array = []
		ODBA.cache.retrieve_from_index = atc_array
		assert_nil(@app.unique_atc_class('substance'))

		atc1 = FlexMock.new('ATC1')
		atc_array = [atc1]
		ODBA.cache.retrieve_from_index = atc_array
		assert_equal(atc1, @app.unique_atc_class('substance'))

		atc2 = FlexMock.new('ATC2')
		atc_array = [atc1]
		ODBA.cache.retrieve_from_index = atc_array
		assert_equal(atc1, @app.unique_atc_class('substance'))
		ODBA.cache.retrieve_from_index = nil
	end
	def test_create_log_group
		@app.log_groups = {}
		pointer = ODDB::Persistence::Pointer.new([:log_group, :swissmedic_journal])
		group = @app.create(pointer)
		assert_instance_of(ODDB::LogGroup, group)
		assert_equal({:swissmedic_journal=>group}, @app.log_groups)
		assert_equal(pointer, group.pointer)
		group1 = @app.create(pointer)
		assert_equal(group, group1)
		assert_equal({:swissmedic_journal=>group}, @app.log_groups)
	end
	def test_substance
		substance = ODDB::Substance.new
		substance.descriptions[:de] = 'ACIDUM ACETYLSALICYLICUM'
		@app.substances = {substance.name.downcase => substance}
		assert_equal(substance, @app.substance('ACIDUM ACETYLSALICYLICUM') )
	end
	def test_substance2
		substance = ODDB::Substance.new
		@app.substances = {substance.oid => substance}
		assert_equal(substance, @app.substance(substance.oid) )
	end
	def test_each_package
		reg1 = StubRegistration.new(1)
		reg2 = StubRegistration.new(2)
		reg3 = StubRegistration.new(3)
		@app.registrations = {
			1 => reg1,
			2 => reg2,
			3 => reg3,
		}
		@app.each_package { |arg|
			arg*2
		}
		assert_equal(2,reg1.block_result)
		assert_equal(4,reg2.block_result)
		assert_equal(6,reg3.block_result)
	end
	def test_each_galenic_form
		galgroup1 = StubGalenicGroup.new
		galgroup2 = StubGalenicGroup.new
		galgroup3 = StubGalenicGroup.new
		galgroup1.galenic_form=1
		galgroup2.galenic_form=2
		galgroup3.galenic_form=3
		@app.galenic_groups = {
			1 => galgroup1,
			2 => galgroup2,
			3 => galgroup3,
		}
		@app.each_galenic_form { |arg|
			arg*2
		}
		assert_equal(2,galgroup1.block_result)
		assert_equal(4,galgroup2.block_result)
		assert_equal(6,galgroup3.block_result)
	end
	def test_package_count
		@app.registrations = {
			'reg1'	=>	StubRegistration.new,
			'reg2'	=>	StubRegistration.new,
			'reg3'	=>	StubRegistration.new,
		}
		@app.instance_variable_get('@system').instance_variable_set('@package_count', nil)
		count = @app.package_count
		assert_equal(9,count)
	end
=begin
        def test_patinfo_count
                @app.registrations = {
                        'reg1'  =>      StubRegistration.new,
                        'reg2'  =>      StubRegistration.new,
                        'reg3'  =>      StubRegistration.new,
                }
                @app.instance_variable_get('@system').instance_variable_set('@patinfo_count', nil)
                count = @app.patinfo_count
                assert_equal(9,count)
        end
=end
	def test_last_medication_update
		@app.last_medication_update = Date.new(1977-07-07)
		@app.create(ODDB::Persistence::Pointer.new([:atc_class, 'A']))
		expected = Date.today
		result = @app.last_medication_update
		assert_equal(expected, result)
	end
	def test_last_medication_update2
		@app.last_medication_update = Date.new(1977-07-07)
		@app.create(ODDB::Persistence::Pointer.new([:generic_group, 'GNGRP']))
		expected = Date.new(1977-07-07)
		result = @app.last_medication_update
		assert_equal(expected, result)
	end
	def test_async
		foo = "bar"
		@app.async {
			sleep 0.5
			foo = "baz"
		}
		assert_equal("bar", foo)
		sleep 1
		assert_equal("baz", foo)
	end
	def test_fachinfo
		@app.fachinfos = { 1 => "foo", "1" =>	"bar"}
		assert_equal("foo", @app.fachinfo("1"))
		assert_equal("foo", @app.fachinfo(1))
        end
        def test_create_orphaned_fachinfo
                pointer = ODDB::Persistence::Pointer.new([:orphaned_fachinfo])
                assert_equal({}, @app.orphaned_fachinfos)
                orph = @app.create(pointer)
                assert_instance_of(ODDB::OrphanedTextInfo, orph)
                assert_equal({orph.oid => orph}, @app.orphaned_fachinfos)
        end
	def test_create_orphaned_patinfo
		pointer = ODDB::Persistence::Pointer.new([:orphaned_patinfo])
		assert_equal({}, @app.orphaned_patinfos)
		orph = @app.create(pointer)
		assert_instance_of(ODDB::OrphanedTextInfo, orph)
		assert_equal({orph.oid => orph}, @app.orphaned_patinfos)
	end
	def test_delete_orphan_patinfo
		@app.orphaned_patinfos = { 1 => "foo" }
		pointer = ODDB::Persistence::Pointer.new([:orphaned_patinfo, 1])
		@app.delete(pointer)
		assert_equal({}, @app.orphaned_patinfos)
	end
	def test_update_orphan_patinfo
		update_hash = {
			'key'	  =>	'12345',
			'de'      =>	'iksnr',
		}
		orph = ODDB::OrphanedTextInfo.new
		@app.orphaned_patinfos = { 1 => orph }
		pointer = ODDB::Persistence::Pointer.new([:orphaned_patinfo, 1])
		orph.pointer = pointer
		@app.update(pointer, update_hash)
		assert_equal('12345', orph.key)
		assert_equal({'de' => 'iksnr'}, orph.descriptions)
	end
	def test_doctor_by_origin
		docs = FlexMock.new('DoctorHash')
		doc1 = FlexMock.new('Doctor1')
		doc2 = FlexMock.new('Doctor2')
		doc3 = FlexMock.new('Doctor3')
		@app.doctors = docs
		docs.should_receive(:values).and_return {
			[ doc1, doc2, doc3, ]
		}
		doc1.should_receive(:record_match?).and_return { |db, id|
			puts "record-match doc 1"
			false
		}
		doc2.should_receive(:record_match?).and_return { |db, id|
			puts "record-match doc 2"
			true
		}
		assert_equal(doc2, @app.doctor_by_origin(:doc, 4567))
	end
  def test_doctor_by_origin__nil
		@app.doctors = {}
		assert_equal(nil, @app.doctor_by_origin(:doc, 4567))
  end
	def test_substance_by_smcd
		sub1 = FlexMock.new
		sub1.should_receive(:swissmedic_code).and_return { 'SMCD' }
		sub2 = FlexMock.new
		sub2.should_receive(:swissmedic_code).and_return {  }
		@app.substances = { 1 => sub1, 2 => sub2 }
		assert_equal(sub1, @app.substance_by_smcd('SMCD'))
		assert_nil(@app.substance_by_smcd('unknown'))
	end
  def test_login
    @yus ||= flexmock('yus')
    flexmock(ODDB::App::YUS_SERVER) do |yus|
      yus.should_receive(:login)
      yus.should_receive(:login_token)
    end
    flexmock(ODDB::YusUser) do |yus|
      yus.should_receive(:new).and_return(@yus)
    end
    assert_equal(@yus, @app.login('email','pass'))
  end
  def test_login_token
    @yus ||= flexmock('yus')
    flexmock(ODDB::App::YUS_SERVER) do |yus|
      yus.should_receive(:login)
      yus.should_receive(:login_token)
    end
    flexmock(ODDB::YusUser) do |yus|
      yus.should_receive(:new).and_return(@yus)
    end
    assert_equal(@yus.class, @app.login_token('email', 'token').class)
  end
  def test_logout
    flexmock(ODDB::App::YUS_SERVER) do |yus|
      yus.should_receive(:logout).and_return('logout')
    end
    assert_equal('logout', @app.logout('session'))
  end
  def test_reset
    assert_equal({}, @app.reset)
  end
  def test_peer_cache
    flexmock(ODBA) do |odba|
      odba.should_receive(:peer).once.with('cache').and_return('peer')
    end
    assert_equal('peer', @app.peer_cache('cache'))
  end
  def test_unpeer_cache
    flexmock(ODBA) do |odba|
      odba.should_receive(:unpeer).once.with('cache').and_return('unpeer')
    end
    assert_equal('unpeer', @app.unpeer_cache('cache'))
  end
  def test_ipn
    flexmock(ODDB::Util::Ipn) do |ipn|
      ipn.should_receive(:process).once.with('notification', ODDB::App)
    end
    assert_equal(nil, @app.ipn('notification'))
  end
  def test_yus_allowed?
    assert_equal('session', @app.yus_allowed?('email', 'action', 'key'))
  end
  def test_active_fachinfos
    registration = flexmock('registration') do |reg|
      reg.should_receive(:active?).and_return(true)
      reg.should_receive(:fachinfo).and_return(true)
      reg.should_receive(:pointer).and_return('registration')
    end
    @app.registrations = {'registration' => registration}
    assert_equal({'registration' => 1}, @app.active_fachinfos)
  end
  def test_active_pdf_patinfos
    sequence = flexmock('sequence') do |seq|
      seq.should_receive(:active_patinfo).and_return('active_patinfo')
    end
    registration = flexmock('registration') do |reg|
      reg.should_receive(:each_sequence).and_yield(sequence)
    end
    @app.registrations = {'1' => registration}
    assert_equal({"active_patinfo"=>1}, @app.active_pdf_patinfos)
  end
  def test_address_suggestion
    assert_equal(nil, @app.address_suggestion('12345'))
  end
  def test_analysis_group
    assert_equal(nil, @app.analysis_group(0))
  end
  def test_analysis_positions
    assert_equal([], @app.analysis_positions)
  end
  def test_create_analysis_group
    group = flexmock('group')
    flexmock(ODDB::Analysis::Group) do |grp|
      grp.should_receive(:new).and_return(group)
    end
    assert_equal(group, @app.create_analysis_group(0))
  end
  def test_create_commercial_form
    form = flexmock('form') do |frm|
      frm.should_receive(:oid)
    end
    flexmock(ODDB::CommercialForm) do |frm|
      frm.should_receive(:new).and_return(form)
    end
    assert_equal(form, @app.create_commercial_form)
  end
  def test_create_epha_interaction
    epha_interaction = flexmock('epha_interaction') do |epha|
      epha.should_receive(:oid)
    end
    flexmock(ODDB::EphaInteraction) do |epha|
      epha.should_receive(:new).and_return(epha_interaction)
    end
    assert_equal(epha_interaction, @app.create_epha_interaction('atc_code_self', 'atc_code_other'))
  end
  def test_create_hospital
    hospital = flexmock('hospital') do |hos|
      hos.should_receive(:oid)
    end
    flexmock(ODDB::Hospital) do |hos|
      hos.should_receive(:new).and_return(hospital)
    end
    assert_equal(hospital, @app.create_hospital(0))
  end
  def test_create_fachinfo
    fachinfo = flexmock('fachinfo') do |fi|
      fi.should_receive(:oid)
    end
    flexmock(ODDB::Fachinfo) do |fi|
      fi.should_receive(:new).and_return(fachinfo)
    end
    assert_equal(fachinfo, @app.create_fachinfo)

  end
  def test_create_feedback
    feedback = flexmock('feedback') do |fb|
      fb.should_receive(:oid)
    end
    flexmock(ODDB::Feedback) do |fb|
      fb.should_receive(:new).and_return(feedback)
    end
    assert_equal(feedback, @app.create_feedback)
  end
  def test_create_invoice
    invoice = flexmock('invoice') do |inv|
      inv.should_receive(:oid)
    end
    flexmock(ODDB::Invoice) do |inv|
      inv.should_receive(:new).and_return(invoice)
    end
    assert_equal(invoice, @app.create_invoice)
  end
  def test_create_address_suggestion
    address_suggestion = flexmock('address_suggestion') do |ads|
      ads.should_receive(:oid)
    end
    flexmock(ODDB::AddressSuggestion) do |ads|
      ads.should_receive(:new).and_return(address_suggestion)
    end
    assert_equal(address_suggestion, @app.create_address_suggestion)
  end
end
