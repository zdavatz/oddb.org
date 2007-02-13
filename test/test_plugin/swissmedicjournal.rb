#!/usr/bin/env ruby
# TestSmjPlugin -- oddb -- 30.04.2003 -- benfay@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'plugin/swissmedicjournal'

class Object
  @@today = Date.today
end
module ODDB
	class SwissmedicJournalPlugin
		public :accept_galenic_form?, :update_registration, :deactivate_registration
		public :update_sequence, :update_active_agents, :update_sequences
		public :update_packages, :update_company, :prune_sequences, :prune_packages
		attr_reader :incomplete_pointers, :registration_pointers
	end

	class TestSmjPlugin < Test::Unit::TestCase
		class StubIndication
			attr_accessor :pointer, :sequences #(stub anomaly)
			def initialize(text)
				@text = text
				@sequences = {}
			end
			def has_description?(text)
				@text == text
			end
		end
		class StubApp
			attr_reader :pointers, :values, :create_pointer, :delete_pointer
			attr_accessor :companies, :sequence, :substances, :indications
			attr_writer :galenic_forms 
			def initialize
				@pointers = []
				@values = []
			end
			def atcless_sequences
				[]
			end
			def update(pointer, values)
				@pointers << pointer
				@values << values
				indication = StubIndication.new(values[:default])
				indication.pointer = pointer
				indication
			end
			def company_by_name(string)
				(@companies ||= {})[string]
			end
			def create(pointer)
				@create_pointer = pointer
			end
			def galenic_form(key)
				(@galenic_forms ||= {})[key]
			end
			def delete(pointer)
				@delete_pointer = pointer
			end
			def substance(key)
				(@substances ||= {})[key]
			end
			def indication_by_text(text)
				(@indications||=[]).select { |indication| 
					indication.has_description?(text)
				}.first
			end
		end
		class StubCompany
			attr_reader :name
			attr_accessor :address, :plz, :location, :pointer
			def initialize(name)
				@name = name
			end
		end
		class StubSmjRegistration
			attr_accessor :flags, :valid_until, :indication, :pointer
			attr_accessor :exportvalue, :incomplete, :last_update, :iksnr
			attr_accessor :company, :date, :sequences, :src, :indexth, :seqnr, :ikscat
			attr_writer :products
			def initialize
				@company = StubCompany.new('Bayer')
				@indication = 'Heuschnupfen'
				@last_update = Date.new(2003,1,1)
				@iksnr = '12345'
			end
			def products
				@products ||= {}
			end
			def incomplete?
				@incomplete ||= false
			end
		end
		class StubSequence
			attr_accessor :most_precise_galform, :galform_latin, :packages, 
				:galenic_form, :active_agents, :composition, :seqnr, 
				:most_precise_dose, :most_precise_unit, :name_base, :name_dose, 
				:name_descr, :galform_name, :pointer, :atc_class, 
        :most_precise_comform
			def initialize
				@most_precise_galform = 'Kapseln'
				@seqnr = '01'
				@most_precise_dose = 20
				@most_precise_unit = '%'
				@name_base = 'Intralipid 20%'
				@name_dose = '20%'
				@name_descr = nil
				@galform_name = 'Kapseln'
				@galform_latin = 'CAPSULA'
				@packages = []
			end
		end
		class StubComposition
			attr_writer :active_agents
			def active_agents
				@active_agents ||= []
			end
		end
		class StubActiveAgent
			attr_accessor :pointer, :substance
		end
		class StubSmjActiveAgent
			attr_accessor :substance, :dose, :chemical, :equivalent,
				:special, :spagyric
		end
		class StubDose
			attr_reader :qty, :unit
			def initialize(qty, unit)
				@qty, @unit = qty, unit
			end
		end
		class StubPackage
			attr_accessor :package_size, :ikscat, :ikscd, :description
		end

		def setup
			@app = FlexMock.new
			@app.mock_handle(:registration) {}
			@plugin = ODDB::SwissmedicJournalPlugin.new(@app)
		end
		def test_update
			assert_respond_to(@plugin, :update)
		end
		def test_update_fail
			assert_equal(false, @plugin.update(Date.new(2100)))
		end
		def test_update_registration1
			reg = StubSmjRegistration.new
			reg.flags = [:new]
			ind_pointer = ODDB::Persistence::Pointer.new([:indication, 1])
			indication = StubIndication.new('Heuschnupfen')
			indication.pointer = ind_pointer
			company = StubCompany.new('Bayer')
			company.pointer = :foobar_pointer
			@app.mock_handle(:indication_by_text) { indication }
			@app.mock_handle(:company_by_name) { company }
			expected = {
				:registration_date	=>	Date.new(2003,1,1),
				:company						=>	:foobar_pointer,
				:indication					=>	ind_pointer,
				:export_flag				=>	false,
				:source							=>	nil,
				:index_therapeuticus =>  nil,
        :ikscat             =>  nil,
        :renewal_flag       =>  false,
			}
			registration = FlexMock.new
			@app.mock_handle(:update) { |pointer, values| 
				case @app.mock_count(:update)
				when 1 # update the company
					company
				when 2 # update the registration
					assert_equal(expected, values)
					assert_instance_of(Persistence::Pointer, values[:indication])
					registration
				end
			}
			pointer = Persistence::Pointer.new([:registration, '12345'])
			registration.mock_handle(:sequences) { {} }
			registration.mock_handle(:pointer) { pointer }
			@plugin.update_registration(reg)
			assert_equal({pointer => [:new]}, @plugin.change_flags) 
		end
		def test_update_registration2 ## new indication
			reg = StubSmjRegistration.new
			reg.flags = [:ikscat]
			reg.valid_until = Date.new(2004,1,1)
			company = StubCompany.new('Bayer')
			company.pointer = :pointer
			@app.mock_handle(:indication_by_text) { nil }
			ind_pointer = ODDB::Persistence::Pointer.new([:indication, 123])
			expected = {
				:revision_date	=>	Date.new(2003,1,1),
				:expiration_date=>	Date.new(2004,1,1),
				:company				=>	:pointer,
				:indication			=>	ind_pointer,
				:export_flag		=>	false,
				:source					=>	nil,
				:index_therapeuticus =>  nil,
        :ikscat             =>  nil,
        :renewal_flag       =>  false,
			}
			## update indication
			indication = FlexMock.new
			indication.mock_handle(:pointer) { 
				ind_pointer
			}
			registration = FlexMock.new
			pointer = Persistence::Pointer.new([:registration, '12345'])
			registration.mock_handle(:sequences) { {} }
			registration.mock_handle(:pointer) { pointer }
			@app.mock_handle(:update) { |pointer, values| 
				case @app.mock_count(:update)
				when 1 # update the indication
					assert_equal({:la=>'Heuschnupfen'}, values)
					indication
				when 2 # update the company
					company
				when 3 # update the registration
					assert_equal(expected, values)
					assert_instance_of(Persistence::Pointer, values[:indication])
					registration
				end
			}
			@app.mock_handle(:company_by_name) { company }
			@plugin.update_registration(reg)
		end
		def test_update_registration_robust
			reg = StubSmjRegistration.new
			reg.company = nil
			reg.indication = nil
			reg.last_update = nil
			reg.iksnr = nil
			reg.flags = []
			expected = { 
				:revision_date	=>	nil,
				:export_flag		=>	false,
				:source					=>	nil,
				:index_therapeuticus =>  nil,
        :ikscat             =>  nil,
        :renewal_flag       =>  false,
			}
			registration = FlexMock.new
			@app.mock_handle(:update) { |pointer, values|
				assert_equal(expected, values)
				registration
			}
			pointer = Persistence::Pointer.new([:registration, '12345'])
			registration.mock_handle(:sequences) { {} }
			registration.mock_handle(:pointer) { pointer }
			registration.mock_handle(:pointer) { pointer }
			@plugin.update_registration(reg)
		end
=begin  -- 09/2005: do not accept incomplete Registrations.
		def test_update_incomplete_anyway_if_has_iksnr
			reg = StubSmjRegistration.new
			reg.flags = [:ikscat]
			reg.valid_until = Date.new(2004,1,1)
			reg.incomplete = true
			company = StubCompany.new('Bayer')
			company.pointer = :pointer
			ind_pointer = ODDB::Persistence::Pointer.new([:indication, 1])
			indication = StubIndication.new('Heuschnupfen')
			indication.pointer = ind_pointer
			@app.mock_handle(:indication_by_text) { indication }
			@app.mock_handle(:company_by_name) { company }
			expected = {
				:revision_date	=>	Date.new(2003,1,1),
				:expiration_date=>	Date.new(2004,1,1),
				:company				=>	:pointer,
				:indication			=>	ind_pointer,
				:export_flag		=>	nil,
				:source					=>	nil,
			}
			registration = FlexMock.new
			pointer = Persistence::Pointer.new([:registration, '12345'])
			registration.mock_handle(:sequences) { {} }
			registration.mock_handle(:pointer) { pointer }
			@app.mock_handle(:update) { |pointer, values| 
				case @app.mock_count(:update)
				when 1 # update the company
					company
				when 2 # update the registration
					assert_equal(expected, values)
					assert_instance_of(Persistence::Pointer, values[:indication])
					registration
				end
			}
			@plugin.update_registration(reg)
		end
=end
		def test_prune_sequences
			seq1 = StubSequence.new
			seq2 = StubSequence.new
			seq1.pointer = 'seq1'
			seq2.pointer = 'seq2'
			pointer = ODDB::Persistence::Pointer.new()
			registration = StubSmjRegistration.new
			registration.pointer = pointer
			registration.sequences = {'01'=>seq1, '02'=>seq2}
			smj_registration = StubSmjRegistration.new
			smj_registration.products = {'02'=>seq2}
			@app.mock_handle(:delete) { |ptr|
				assert_equal(seq1.pointer, ptr)
			}
			@plugin.prune_sequences(smj_registration, registration)	
			smj_registration.products = {'01'=>seq1}
			@app.mock_handle(:delete) { |ptr|
				assert_equal(seq2.pointer, ptr)
			}
			@plugin.prune_sequences(smj_registration, registration)	
		end
		def test_update_sequence
			pointer = ODDB::Persistence::Pointer.new
			seq = StubSequence.new
			seq.composition = StubComposition.new
			@app.mock_handle(:sequence) { seq }
			expected = {
				:name_base		=>	'Intralipid 20%',
				:name_descr		=>	'Kapseln',
				:dose					=>	[20, '%'],
				:galenic_form	=>	'Kapseln',
			}
			seq.atc_class = 'not_nil'
			@app.mock_handle(:update) { |pointer, values|
				assert_equal(expected, values)
				seq
			}
			@app.mock_handle(:galenic_form) { 'Kapseln' }
			assert(@app.respond_to?(:sequence))
			@plugin.update_sequence(seq, pointer)
		end
		def test_update_sequence__find_atc_class
			pointer = ODDB::Persistence::Pointer.new
			seq = StubSequence.new
			seq.composition = StubComposition.new
			@app.mock_handle(:sequence) { seq }
			expected = {
				:name_base		=>	'Intralipid 20%',
				:name_descr		=>	'Kapseln',
				:dose					=>	[20, '%'],
				:galenic_form	=>	'Kapseln',
			}
			atc = FlexMock.new
			atc.mock_handle(:code) { 'ATCCLSS' }
			@app.mock_handle(:unique_atc_class) { 
				atc
			}
			agent = FlexMock.new
			agent.mock_handle(:substance) { 'a_substance' }
			sequence = FlexMock.new
			reg = FlexMock.new
			reg.mock_handle(:sequences) { { '01' => sequence }}
			sequence.mock_handle(:registration) { reg }
			sequence.mock_handle(:atc_class) { nil }
			sequence.mock_handle(:active_agents) { [agent] } 
			sequence.mock_handle(:pointer) {}
			@app.mock_handle(:update) { |pointer, values|
				case @app.mock_count(:update)
				when 1
					assert_equal(expected, values)
					sequence
				when 2
					assert_equal({:atc_class=>'ATCCLSS'}, values)
					sequence
				end
			}
			@app.mock_handle(:galenic_form) { 'Kapseln' }
			assert(@app.respond_to?(:sequence))
			@plugin.update_sequence(seq, pointer)
		end
		def test_update_sequence_robust
			pointer = ODDB::Persistence::Pointer.new
			seq = StubSequence.new
			seq.most_precise_galform = nil
			seq.most_precise_dose = nil
			seq.most_precise_unit = nil
			seq.name_base = nil
			seq.name_dose = nil
			seq.name_descr = nil
			seq.galform_name = nil
			seq.galform_latin = nil
			seq.packages = nil
			seq.atc_class = 'not_nil'
			expected = {}
			@app.mock_handle(:update) { |pointer, values|
				assert_equal(expected, values)
				seq
			}
			@plugin.update_sequence(seq, pointer)
			creator = ODDB::Persistence::Pointer.new([:create, (pointer + [:sequence, '01'])])
		end
		def test_accept_galenic_form1
			# Szenarien:
			# - most_precise_galform = Kapseln (== galform_name)
			# - most_precise_galform = CAPSULA (== galform_latin)
			# -> log_eintrag für galform_latin
			# 
			# - Sequenz existiert noch nicht
			# -> galform kann übernommen werden 
			#
			# - Sequenz bereits existent
			# - Sequenz hat noch keine Galenische Form
			# -> galform kann übernommen werden 
			# - Sequenz hat schon eine Galenische Form
			# -> nur übernehmen, wenn (==galform_name) und Galform bereits bekannt
			#
			# - Galform bereits bekannt
			# - Galform noch nicht bekannt
			# -> muss erstellt werden, falls übernahme durch sequenz
			
			# Frage 1: soll die galenische Form übernommen werden?
			# Frage 2: wurde eine neue galenische Form erstellt?
			
			@app.mock_handle(:sequence) { nil }
			@app.mock_handle(:galenic_form) { nil }
			ptr = Persistence::Pointer.new([:galenic_group, 1],
				[:galenic_form])
			@app.mock_handle(:update) { |pointer, values| 
				assert_equal(ptr.creator, pointer)
			}
			smj_seq = StubSequence.new
			pointer = Persistence::Pointer.new(:sequence)
			test = @plugin.accept_galenic_form?(pointer, smj_seq)
			assert_equal(true, test)
		end
		def test_accept_galenic_form2
			@app.mock_handle(:sequence) { StubSequence.new }
			@app.mock_handle(:galenic_form) { 'Kapseln' }
			smj_seq = StubSequence.new
			pointer = Persistence::Pointer.new(:sequence)
			test = @plugin.accept_galenic_form?(pointer, smj_seq)
			assert_equal(true, test)
		end
		def test_accept_galenic_form3
			sequence = StubSequence.new
			sequence.galenic_form = 'Kapseln'
			@app.mock_handle(:sequence) { sequence }
			@app.mock_handle(:galenic_form) { 'Kapseln' }
			smj_seq = StubSequence.new
			smj_seq.most_precise_galform = 'CAPSULA'
			pointer = Persistence::Pointer.new(:sequence)
			test = @plugin.accept_galenic_form?(pointer, smj_seq)
			assert_equal(false, test)
		end
		def test_accept_galenic_form4
			sequence = StubSequence.new
			sequence.galenic_form = 'Kapseln'
			@app.mock_handle(:sequence) { sequence }
			@app.mock_handle(:galenic_form) { }
			smj_seq = StubSequence.new
			pointer = ODDB::Persistence::Pointer.new(:sequence)
			test = @plugin.accept_galenic_form?(pointer, smj_seq)
			assert_equal(false, test)
		end
		def test_accept_galenic_form5
			sequence = StubSequence.new
			sequence.galenic_form = 'Kapseln'
			@app.mock_handle(:sequence) { sequence }
			@app.mock_handle(:galenic_form) { 'Kapseln' }
			smj_seq = StubSequence.new
			pointer = ODDB::Persistence::Pointer.new(:sequence)
			test = @plugin.accept_galenic_form?(pointer, smj_seq)
			assert_equal(true, test)
		end
		def test_update_active_agents1
			sequence = StubSequence.new
			@app.mock_handle(:sequence) { sequence }
			active_agent = StubActiveAgent.new
			active_agent.pointer = 'boo'
			sequence.active_agents = [
				active_agent
			]
			pointer = ODDB::Persistence::Pointer.new(:sequence)
			composition = StubComposition.new
			composition.active_agents = []
			@app.mock_handle(:delete) { |pointer|
				flunk "should not delete if composition is empty!"
			}
			assert_nothing_raised { 
				@plugin.update_active_agents(composition, pointer)
			}
		end
		def test_update_active_agents2
			sequence = StubSequence.new
			@app.mock_handle(:sequence) { sequence }
			active_agent = StubActiveAgent.new
			active_agent.pointer = 'boo'
			sequence.active_agents = [
				active_agent
			]
			pointer = Persistence::Pointer.new(:sequence)
			composition = StubComposition.new
			smj_agent = StubSmjActiveAgent.new
			smj_agent.substance = "FLUCLOXACILLINUM"
			smj_agent.dose = StubDose.new("500", "mg")
			composition.active_agents = [ smj_agent ]
			@app.mock_handle(:delete) { |del_ptr|
				assert_equal('boo', del_ptr)
			}
			@app.mock_handle(:substance) { }
			substance_pointer = Persistence::Pointer.new([:substance, 
				"FLUCLOXACILLINUM"])
			@app.mock_handle(:create) { |ptr|
				assert_equal(substance_pointer, ptr)
			}
			agent_ptr = pointer + [:active_agent, 'FLUCLOXACILLINUM']
			expected = {
				:dose									=>	["500", "mg"],
				:spagyric_dose				=>	nil,
				:spagyric_type				=>	nil,
			}
			@app.mock_handle(:update) { |ptr, values|
				assert_equal(agent_ptr.creator, ptr)
				assert_equal(expected, values)
			}
			assert_nothing_raised { 
				@plugin.update_active_agents(composition, pointer)
			}
		end
		def test_update_active_agents3
			sequence = StubSequence.new
			@app.mock_handle(:sequence) { sequence }
			active_agent = StubActiveAgent.new
			active_agent.pointer = 'boo'
			sequence.active_agents = [
				active_agent
			]
			@app.mock_handle(:substance) { |name|
				/FLUCLO/.match(name)
			}
			pointer = ODDB::Persistence::Pointer.new(:sequence)
			substance_pointer = Persistence::Pointer.new([:substance, 
				"RUSCOGENINA"])
			@app.mock_handle(:create) { |ptr|
				assert_equal(substance_pointer, ptr)
			}
			@app.mock_handle(:delete) { |ptr|
				assert_equal('boo', ptr)
			}
			expected = {
				:dose									=>	["500", "mg"],
				:chemical_substance		=>	"FLUCLOXACILLINUM NATRICUM",
				:chemical_dose				=>	["500", "mg"],
				:equivalent_substance	=>	"RUSCOGENINA",
				:equivalent_dose			=>	["0.5", "mg"],
				:spagyric_dose				=>	nil,
				:spagyric_type				=>	nil,
			}
			@app.mock_handle(:update) { |ptr, values|
				assert_equal(expected, values)
			}
			agent_pointer = pointer + [:active_agent, "FLUCLOXACILLINUM"]
			composition = StubComposition.new
			smj_agent = StubSmjActiveAgent.new
			smj_agent.substance = "FLUCLOXACILLINUM"
			smj_agent.dose = StubDose.new("500", "mg")
			smj_chemical = smj_agent.dup
			smj_chemical.substance = "FLUCLOXACILLINUM NATRICUM"
			smj_agent.chemical = smj_chemical
			smj_equivalent = StubSmjActiveAgent.new
			smj_equivalent.substance = "RUSCOGENINA"
			smj_equivalent.dose = StubDose.new("0.5", "mg")
			smj_agent.equivalent = smj_equivalent
			composition.active_agents = [ smj_agent ]
			assert_nothing_raised {
				@plugin.update_active_agents(composition, pointer)
			}
		end
		def test_update_packages
			pointer = ODDB::Persistence::Pointer.new(:sequence)
			sequence = StubSequence.new
			sequence.pointer = pointer
			package_pointer = pointer + [:package, "007"]
			smj_package = StubPackage.new
			smj_package.package_size = '12 Tabletten'
			smj_package.ikscat = 'B'
			smj_package.ikscd = '007'
			packages = [
				smj_package
			]
			expected = {
				:size		=>	'12 Tabletten',
				:ikscat	=>	'B',
			}
			@app.mock_handle(:update) { |ptr, values|
				assert_equal(package_pointer.creator, ptr)
				assert_equal(expected, values)
			}
			@plugin.update_packages(packages, sequence, [])
		end
		def test_update_packages__new
			pointer = ODDB::Persistence::Pointer.new(:sequence)
			sequence = StubSequence.new
			sequence.pointer = pointer
			package_pointer = pointer + [:package, "007"]
			smj_package = StubPackage.new
			smj_package.package_size = '12 Tabletten'
			smj_package.ikscat = 'B'
			smj_package.ikscd = '007'
			packages = [
				smj_package
			]
			expected = {
				:size							=>	'12 Tabletten',
				:ikscat						=>	'B',
				:refdata_override => true,
			}
			@app.mock_handle(:update) { |ptr, values|
				assert_equal(package_pointer.creator, ptr)
				assert_equal(expected, values)
			}
			@plugin.update_packages(packages, sequence, [:new])
		end
		def test_update_company
			# Szenarien
			# a Company noch nicht vollständig Registriert
			# b Adressänderung
			# c Änderung Firmennamen
			# -> Company-Profil ergänzen
			#
			# d Änderung Zulassungsinhaber
			# -> Aus alter Company entfernen, Neue erstellen, registrieren
			#
			# Indizien 
			# Company-Flag gesetzt?
			# a) nein
			# b,c,d) ja
			#
			# Company-Name anders als in ODDB?
			#	a,b) nein (solange noch kein Company-Interface)
			#	c,d) ja
			#
			#	=> update_company verwendet grundsätzlich einen Create-Pointer, 
			#	   da kein Zuverlässiger Weg besteht, eine reine Namensänderung 
			#	   zu identifizieren. Der Fall c) wird wie d) behandelt. Leere
			#	   Companies müssen noch irgendwie gelöscht werden.
			
			smj_company = StubCompany.new('Bausch & Lomb Swiss AG')
			smj_company.address = 'Sumpfstrasse 3'
			smj_company.plz = '6312'
			smj_company.location = 'Steinhausen'
			pointer = Persistence::Pointer.new([:company])
			@app.mock_handle(:company_by_name) { |name|
				nil
			}
			@app.mock_handle(:update) { |ptr, values|
				assert_equal(pointer.creator, ptr)
				assert_equal(2, values.size)
				assert_equal('Bausch & Lomb Swiss AG', values[:name])
				addrs = values[:addresses]
				assert_equal(1, addrs.size)
				addr = addrs.first
				assert_equal('Sumpfstrasse 3', addr.address)
				assert_equal('6312 Steinhausen', addr.location)
			}
			@plugin.update_company(smj_company)
		end
		def test_deactivate_registration1
			existing = FlexMock.new
			@app.mock_handle(:registration) { existing }
			existing.mock_handle(:inactive_date) { }
			reg = StubSmjRegistration.new
			date = reg.date = Date.new(1975,8,21)
			expected = {
				:inactive_date	=>	date,
			}
			pointer = Persistence::Pointer.new([:registration, '12345'])
			@app.mock_handle(:update) { |ptr, values|
				assert_equal(expected, values)
				assert_equal(pointer, ptr)
			}
			@plugin.deactivate_registration(reg)	
		end
		def test_deactivate_registration2
			existing = FlexMock.new
			@app.mock_handle(:registration) { existing }
			existing.mock_handle(:inactive_date) { }
			reg = StubSmjRegistration.new
			expected = {
				:inactive_date	=>	Date.today,
			}
			pointer = Persistence::Pointer.new([:registration, '12345'])
			@app.mock_handle(:update) { |ptr, values|
				assert_equal(expected, values)
				assert_equal(pointer, ptr)
			}
			@plugin.deactivate_registration(reg)	
		end
		def test_log_info
			@app.mock_handle(:atcless_sequences) { [] }
			info = @plugin.log_info
			[:pointers, :report, :change_flags, :recipients].each { |key|
				assert(info.include?(key))
			}
		end
	end
end
