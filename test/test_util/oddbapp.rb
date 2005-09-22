#!/usr/bin/env ruby
# TestOddbApp -- oddb -- 15.11.2002 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'stub/oddbapp'
require 'digest/md5'
require 'util/persistence'
require 'model/substance'
require 'model/atcclass'
require 'model/orphan'
require 'model/galenicform'
require 'util/language'
require 'stub/odba'
require 'mock'
require 'util/oddbapp'

module Datastructure
	class CharTree
		attr_reader :children, :values
	end
	class SoundexTable
		attr_reader :hash
	end
end
=begin
module ODBA
	class StorageStub
		attr_accessor :next_id
	end
end
=end
module ODDB
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
		attr_accessor :packages, :active_agents
	end
	module Persistence
		include ODBA
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

class TestOddbApp < Test::Unit::TestCase
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
				:pass		=>	Digest::MD5::hexdigest('test'),
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
		def package_count
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
		dir = File.expand_path('../data/prevalence', File.dirname(__FILE__))
		ODBA.storage = Mock.new
		ODBA.storage.__next(:next_id){
			1
		}
		@app = ODDB::App.new
		ODBA.storage.__next(:next_id){
			2
		}
		ODBA.storage.__next(:next_id){
			3
		}
		ODBA.storage.__next(:next_id){
			4
		}
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
	def test_login
		assert_instance_of(ODDB::RootUser, @app.login(StubSession.new))
	end
	def test_fail_login
		assert_nil(@app.login(StubSession2.new))
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
			:dose					=>	[100, 'mg'],
			:atc_class		=>	'N02BA01',
			:galenic_form	=>	'Tabletten',
		}
		@app.update(pointer, values)
		seq = @app.registration('12345').sequence('01')
		assert_equal('Aspirin Cardio', seq.name)
		assert_equal(ODDB::Dose.new(100, 'mg'), seq.dose)
		assert_equal(@app.atc_class('N02BA01'), seq.atc_class)
		assert_equal(@app.galenic_form('Tabletten'), seq.galenic_form)
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
			'size'					=>	'20 x 1,7 g',
			'descr'					=>	nil,
			'ikscat'				=>	'A',
		}
		@app.update(pointer, values)
		package = @app.registration('12345').package(32)
		assert_equal('20 x 1,7 g', package.size)
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
			'en'							=>	'first_name',
			:connection_keys	=>	['connection_key'],
		}
		subs = @app.update(pointer.creator, descr)
		values = {
			:en	=>	'en_name',
			:de	=>	'de_name',			
		}
		@app.update(subs.pointer, values)
		assert_equal('en_name', subs.en)
		assert_equal(['connectionkey', 'firstname', 'enname', 'dename'].sort, 
			subs.connection_keys.sort)
		assert_equal('de_name', subs.de)
		assert_equal({subs.oid, subs}, @app.substances)
	end
	def test_create_active_agent
		pointer = ODDB::Persistence::Pointer.new(['registration', '12345'])
		reg = @app.create(pointer)
		pointer += ['sequence', '01']
		seq = @app.create(pointer)
		substpointer = ODDB::Persistence::Pointer.new(['substance', 'LEVOMENTHOLUM'])
		substance = @app.create(substpointer)
		seq.active_agents = []
		pointer += ['active_agent', 'LEVOMENTHOLUM']
		@app.create(pointer)
		assert_equal(1, seq.active_agents.size)
		agent = seq.active_agents.first
		assert_equal(ODDB::ActiveAgent, agent.class)
		assert_equal(ODDB::Substance, agent.substance.class)
		assert_equal('Levomentholum', agent.substance.name)
		assert_equal(@app.substance('LEVOMENTHOLUM'), agent.substance)
	end
	def test_update_active_agent
		pointer = ODDB::Persistence::Pointer.new(['registration', '12345'])
		reg = @app.create(pointer)
		pointer += ['sequence', '01']
		seq = @app.create(pointer)
		substpointer = ODDB::Persistence::Pointer.new(['substance', 'LEVOMENTHOLUM'])
		substance = @app.create(substpointer)
		#ODBA.cache_server.retrieve_from_index = [substance]
		pointer += ['active_agent', 'LEVOMENTHOLUM']
		agent = @app.create(pointer)
		values = {
			:dose	=>	[16, 'mg'],
		}
		@app.update(pointer, values)
		assert_equal(ODDB::Dose, agent.dose.class)
		assert_equal(16, agent.dose.qty)
		assert_equal('mg', agent.dose.unit)
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
		pointer = ODDB::Persistence::Pointer.new(['substance', 'subs_name'])
		substance = @app.create(pointer)
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
		pointer = ODDB::Persistence::Pointer.new(['substance', 'subs_name'])
		substance = @app.create(pointer)
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
		assert_nothing_raised {@app.delete_galenic_group('12345')}
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
		ODBA.cache_server.retrieve_from_index = atc_array
		assert_nil(@app.unique_atc_class('substance'))

		atc1 = Mock.new('ATC1')
		atc_array = [atc1]
		ODBA.cache_server.retrieve_from_index = atc_array
		assert_equal(atc1, @app.unique_atc_class('substance'))
		atc1.__verify

		atc2 = Mock.new('ATC2')
		atc_array = [atc1, atc2]
		ODBA.cache_server.retrieve_from_index = atc_array
		atc1.__next(:substances) { ['substance'] }
		atc2.__next(:substances) { ['substance'] }
		assert_nil(@app.unique_atc_class('substance'))
		atc1.__verify
		atc2.__verify

		atc_array = [atc1]
		ODBA.cache_server.retrieve_from_index = atc_array
		assert_equal(atc1, @app.unique_atc_class('substance'))
		atc1.__verify

		atc1.__next(:substances) { ['sub1', 'sub2'] }
		atc2.__next(:substances) { ['substance'] }
		atc_array = [atc1, atc2]
		ODBA.cache_server.retrieve_from_index = atc_array
		assert_equal(atc2, @app.unique_atc_class('substance'))
		atc1.__verify
		atc2.__verify

		ODBA.cache_server.retrieve_from_index = nil
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
	def test_create_incomplete_registration
		@app.incomplete_registrations = {}
		pointer = ODDB::Persistence::Pointer.new(:incomplete_registration)
		result = @app.create(pointer)	
		assert_instance_of(ODDB::IncompleteRegistration, result)
		assert_equal(1, @app.incomplete_registrations.size)
		oid = result.oid
		assert_equal(result, @app.incomplete_registration(oid))
		expected = ODDB::Persistence::Pointer.new([:incomplete_registration, oid])
		assert_equal(expected, result.pointer)
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
		substance = Mock.new('substance')
		@app.substances = { 'connection key' =>	substance }
		substance.__next(:has_connection_key?) { |key|
			assert_equal('valid key', key)
			true
		}
		result = @app.substance_by_connection_key('valid key')
		assert_equal(substance, result)
		substance.__next(:has_connection_key?) { |key|
			assert_equal('invalid key', key)
			false
		}
		result = @app.substance_by_connection_key('invalid key')
		assert_equal(nil, result)
		substance.__verify
	end
	def test_atcless_sequences
		reg = StubRegistration.new('12345')
		@app.registrations = {'12345'=>reg}
		atcless = @app.atcless_sequences
		assert_equal(1, atcless.size)
		assert_instance_of(StubSequence, atcless.first, 'atcless not flattened')
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
	def test_create_orphaned_patinfo
		pointer = ODDB::Persistence::Pointer.new([:orphaned_patinfo])
		assert_equal({}, @app.orphaned_patinfos)
		orph = @app.create(pointer)
		assert_instance_of(ODDB::OrphanedPatinfo, orph)
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
			'key'			=>	'12345',
			'meanings'=>	['iksnr'],
		}		
		orph = ODDB::OrphanedPatinfo.new
		@app.orphaned_patinfos = { 1 => orph }
		pointer = ODDB::Persistence::Pointer.new([:orphaned_patinfo, 1])
		orph.pointer = pointer
		@app.update(pointer, update_hash)
		assert_equal('12345', orph.key)
		assert_equal(['iksnr'], orph.meanings)
	end
	def test_doctor_by_origin
		docs = Mock.new('DoctorHash')
		doc1 = Mock.new('Doctor1')
		doc2 = Mock.new('Doctor2')
		doc3 = Mock.new('Doctor3')
		@app.doctors = docs
		docs.__next(:values) { 
			[ doc1, doc2, doc3, ]
		}
		doc1.__next(:record_match?) { |db, id| 
			puts "record-match doc 1"
			false
		}
		doc2.__next(:record_match?) { |db, id| 
			puts "record-match doc 2"
			true
		}
		assert_equal(doc2, @app.doctor_by_origin(:doc, 4567))
		doc1.__verify
		doc2.__verify
		doc3.__verify
	end
	def test_create_migel_group
		group = @app.create_migel_group('03')
		assert_instance_of(ODDB::Migel::Group, group)
		assert_equal(@app.migel_groups["03"], group)
		assert_equal({'03' => group}, @app.migel_groups)
		## getter-test
		assert_equal(group, @app.migel_group('03'))
	end
end
