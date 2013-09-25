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

class TestOddbApp <Minitest::Test
  include FlexMock::TestCase
	class StubCompany
		attr_accessor	:oid
		def initialize
			@registrations = []
			@cl_status = false
			super
		end
	end
	class StubSession
		def user_input(*keys)
			{
				:email	=>	'test@oddb.org',
				:pass	=>	Digest::MD5::hexdigest('test'),
			}
		end
	end
	class StubSession2
		def user_input(*keys)
			{}
		end
	end
	class StubSequence
		attr_reader :name_base, :name_descr, :atc_class
		def initialize(name_base, atc_class)
			@name_base = name_base
			@atc_class = atc_class
		end
		def name
			@name_base
		end
	end
	class StubAtcClass
		attr_reader :code
		def initialize(halb)
			@code = halb
		end
	end
	class StubAtcClassFactory
		class << self
			def atc(code)
				(@atc ||= {}).fetch(code) {
					@atc.store(code, StubAtcClass.new(code))
				}
			end
		end
	end
	class StubRegistration
		attr_reader :iksnr, :block_result
		def initialize(key=nil)
			@iksnr = key
		end
		def active_package_count
			3
		end
		def replace(registration)
		end
		def sequences
			{
				:foo	=>	StubSequence.new('blah', StubAtcClassFactory.atc('1')),
				:bar	=>	StubSequence.new('blahdiblah', StubAtcClassFactory.atc('2')),
				:rob	=>	StubSequence.new('frohbus', nil),
			}
		end
		def atcless_sequences
			[
				StubSequence.new('no_atc', nil)
			]
		end
		def each_package(&block)
			@block_result = block.call(@iksnr)
		end
	end
	class StubGalenicForm
		include ODDB::Language
		attr_reader :name
		def initialize(name)
			self.update_values({ 'de' => name })
			@name = name
		end
	end
	class StubGalenicGroup
		attr_writer :galenic_form
		attr_reader :block_result
		def each_galenic_form(&block)
			@block_result = block.call(@galenic_form)
		end
		def empty?
			@galenic_form.nil?
		end
		def get_galenic_form(description)
			@galenic_form
		end
	end
	class StubSubstance
		attr_reader :name
		def initialize(name, similar)
			@name = name
			@similar = similar
		end
		def <=>(other)
			@name.downcase <=> other.name.downcase
		end
	end
	class StubRegistration2
		attr_accessor :sequences, :pointer, :descriptions
		def initialize
			@descriptions = {}
		end
		def indication
			self
		end
	end
	class StubIndication
		include ODDB::Language
		def initialize
			@registrations = []
			super
		end
	end

	def setup
		ODDB::GalenicGroup.reset_oids
    ODBA.storage.reset_id
		dir = File.expand_path('../data/prevalence', File.dirname(__FILE__))
		@app = ODDB::App.new

    @session = flexmock('session') do |ses|
      ses.should_receive(:grant).once.with('name', 'key', 'item', 'expires')\
        .and_return('session')
      ses.should_receive(:entity_allowed?).once.with('email', 'action', 'key')\
        .and_return('session')
      ses.should_receive(:create_entity).once.with('email', 'pass')\
        .and_return('session')
      ses.should_receive(:get_entity_preference).once.with('name', 'key')\
        .and_return('session')
      ses.should_receive(:get_entity_preference).once.with('name', 'association')\
        .and_return('odba_id')
      ses.should_receive(:get_entity_preferences).once.with('name', 'keys')\
        .and_return('session')
      ses.should_receive(:get_entity_preferences).once.with('error', 'error')\
        .and_raise(Yus::YusError)
      ses.should_receive(:reset_entity_password).once.with('name', 'token', 'password')\
        .and_return('session')
      ses.should_receive(:set_entity_preference).once.with('name', 'key', 'value', 'domain')\
        .and_return('session')
    end
    flexmock(ODDB::App::YUS_SERVER) do |yus|
      yus.should_receive(:autosession).and_yield(@session)
    end
    flexstub(ODBA.storage) do |sto|
      sto.should_receive(:remove_dictionary)
      sto.should_receive(:generate_dictionary).once.with('language', 'locale', String)\
        .and_return('generate_dictionary')
      sto.should_receive(:generate_dictionary).once.with('french', 'fr_FR@euro', String)\
        .and_return('french_dictionary')
      sto.should_receive(:generate_dictionary).once.with('german', 'de_DE@euro', String)\
        .and_return('german_dictionary')
    end
	end
	def teardown
		ODBA.storage = nil
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
			:connection_keys	=>	['connection_key'],
		}
		subs = @app.update(pointer.creator, descr)
		values = {
			:en	=>	'en_name',
			:de	=>	'de_name',
		}
		@app.update(subs.pointer, values)
		assert_equal('En_name', subs.en)
		assert_equal(['connectionkey', 'firstname', 'enname', 'dename'].sort,
			subs.connection_keys.sort)
		assert_equal('De_name', subs.de)
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
	def test_create_cyp450
		@app.cyp450s.clear
		cyp450 = '1A2'
		assert_nil(@app.cyp450(cyp450))
		pointer = ODDB::Persistence::Pointer.new(['cyp450', '1A2'])
		created = @app.create(pointer)
		assert_equal(1, @app.cyp450s.size)
		assert_equal(ODDB::CyP450, created.class)
		result = @app.cyp450(cyp450)
		assert_equal(ODDB::CyP450, result.class)
	end
	def test_delete_cyp450
		@app.cyp450s.clear
		pointer = ODDB::Persistence::Pointer.new(['cyp450', '1A2'])
		created = @app.create(pointer)
		assert_equal(1, @app.cyp450s.size)
		@app.delete(pointer)
		assert_equal(0, @app.cyp450s.size)
	end
	def test_cyp450
		@app.cyp450s.clear
		cyp450 = '1A2'
		assert_nil(@app.cyp450(cyp450))
		pointer = ODDB::Persistence::Pointer.new(['cyp450', '1A2'])
		created = @app.create(pointer)
		result = @app.cyp450(cyp450)
		assert_equal(created, result)
	end
	def test_create_cyp450inhibitor
		pointer = ODDB::Persistence::Pointer.new(['cyp450', '1A2'])
		cyp450 = @app.create(pointer)
		pointer += ['cyp450inhibitor', 'foo_name']
		inh = @app.create(pointer)
		values = {
			:links		=>	'foo-links',
			:category	=>	'bar-category',
		}
		@app.update(inh.pointer, values)
		assert_equal('foo-links', inh.links)
		assert_equal('bar-category', inh.category)
		assert_equal('foo_name', inh.substance_name)
		assert_equal(1, cyp450.inhibitors.size)
		assert_equal(['foo_name'], cyp450.inhibitors.keys)
	end
	def test_delete_cyp450inhibitor
		pointer = ODDB::Persistence::Pointer.new(['cyp450', '1A2'])
		cyp450 = @app.create(pointer)
		pointer += ['cyp450inhibitor', 'foo_name']
		inh = @app.create(pointer)
		assert_equal(1, cyp450.inhibitors.size)
		@app.delete(pointer)
		assert_equal(0, cyp450.inhibitors.size)
	end
	def test_create_cyp450inducer
		pointer = ODDB::Persistence::Pointer.new(['cyp450', '1A2'])
		cyp450 = @app.create(pointer)
		pointer += ['cyp450inducer', 'foo_name']
		inh = @app.create(pointer)
		values = {
			:links		=>	'foo-links',
			:category	=>	'bar-category',
		}
		@app.update(inh.pointer, values)
		assert_equal('foo-links', inh.links)
		assert_equal('bar-category', inh.category)
		assert_equal('foo_name', inh.substance_name)
		assert_equal(1, cyp450.inducers.size)
		assert_equal(['foo_name'], cyp450.inducers.keys)
	end
	def test_delete_cyp450inducer
		pointer = ODDB::Persistence::Pointer.new(['cyp450', '1A2'])
		cyp450 = @app.create(pointer)
		pointer += ['cyp450inducer', 'foo_name']
		inh = @app.create(pointer)
		assert_equal(1, cyp450.inducers.size)
		@app.delete(pointer)
		assert_equal(0, cyp450.inducers.size)
	end
	def test_create_cyp450substrate
		pointer = ODDB::Persistence::Pointer.new('substance')
		substance = @app.create(pointer)
                substance.descriptions['lt'] = 'subst_name'
		pointer += [ :cyp450substrate, "cyp_id" ]
		inh = @app.create(pointer)
		values = {
			:links		=>	['foo-links'],
			:category	=>	'bar-category',
		}
		@app.update(inh.pointer, values)
		assert_equal(['foo-links'], inh.links)
		assert_equal('bar-category', inh.category)
		assert_equal(1, substance.substrate_connections.size)
	end
	def test_delete_cyp450substrate
		pointer = ODDB::Persistence::Pointer.new('substance')
		substance = @app.create(pointer)
                substance.descriptions['lt'] = 'subst_name'
		pointer += [ :cyp450substrate, "cyp_id" ]
		substr = @app.create(pointer)
		assert_equal(1, substance.substrate_connections.size)
		@app.delete(substr.pointer)
		assert_equal(0, substance.substrate_connections.size)
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
	def test_substance_by_connection_key
		substance = FlexMock.new('substance')
		@app.substances = { 'connection key' =>	substance }
		substance.should_receive(:has_connection_key?).with('valid key')\
                .times(1).and_return {
			true
		}
		result = @app.substance_by_connection_key('valid key')
		assert_equal(substance, result)
		substance.should_receive(:has_connection_key?).with('invalid key')\
                .times(1).and_return {
			false
		}
		result = @app.substance_by_connection_key('invalid key')
		assert_equal(nil, result)
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
	def test_create_migel_group
		group = @app.create_migel_group('03')
		assert_instance_of(ODDB::Migel::Group, group)
		assert_equal(@app.migel_groups["03"], group)
		assert_equal({'03' => group}, @app.migel_groups)
		## getter-test
		assert_equal(group, @app.migel_group('03'))
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
  def test_create_slate_name
    slate = flexmock('slate') do |sla|
      sla.should_receive(:oid)
    end
    flexmock(ODDB::Slate) do |sla|
      sla.should_receive(:new).and_return(slate)
    end
    assert_equal(slate, @app.create_slate(name))
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
  def test_each_atc_class
    assert_equal({}, @app.each_atc_class)
  end
  def test_each_migel_product
    subgroup = flexmock('subgroup') do |grp|
      grp.should_receive(:products).and_return({'product' => 'product'})
    end
    group = flexmock('group') do |grp|
      grp.should_receive(:subgroups).and_return({'subgroup' => subgroup})
    end
    @app.migel_groups = {'group' => group}
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
    assert_equal('product', @app.migel_product('1.2.3'))
  end
  def test_migel_product__error
    @app.migel_groups = {'1' => 'group'}
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
    #assert_equal(expected, @app.search_exact_indication('query', 'lang'))
    assert(same?(expected, @app.search_exact_indication('query', 'lang')))
  end
  def test_search_migel_alphabetical
    migelid = flexmock('migelid', 
                       :send => 'migelid search result',
                       :search_by_migel_code => 'search_by_migel_code'
                      )
    flexmock(ODDB::App::MIGEL_SERVER, :migelid => migelid)
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
    assert_equal('generate_dictionary', @app.generate_dictionary('language', 'locale'))
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
