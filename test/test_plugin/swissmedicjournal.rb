#!/usr/bin/env ruby
# TestSmjPlugin -- oddb -- 30.04.2003 -- benfay@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'plugin/swissmedicjournal'

module ODDB
	class SwissmedicJournalPlugin
		public :accept_galenic_form?, :update_registration, :deactivate_registration
		public :update_sequence, :update_active_agents, :update_sequences
		public :update_packages, :update_company, :prune_sequences, :prune_packages
		attr_reader :incomplete_pointers, :registration_pointers
	end
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
		attr_accessor :company, :date, :sequences, :src
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
		attr_accessor :most_precise_galform, :galform_latin, :packages
		attr_accessor :galenic_form, :active_agents, :composition
		attr_accessor :seqnr, :most_precise_dose, :most_precise_unit
		attr_accessor :name_base, :name_dose, :name_descr, :galform_name, :pointer
		def initialize
			@most_precise_galform = 'Kapseln'
			@seqnr = '01'
			@most_precise_dose = 20
			@most_precise_unit = '%'
			@name_base = 'Intralipid'
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
		attr_accessor :pointer
	end
	class StubSmjActiveAgent
		attr_accessor :substance, :dose, :chemical, :equivalent
	end
	class StubDose
		attr_reader :qty, :unit
		def initialize(qty, unit)
			@qty, @unit = qty, unit
		end
	end
	class StubPackage
		attr_accessor :package_size, :ikscat, :ikscd
	end

	def setup
		@app = StubApp.new
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
		company = StubCompany.new('Bayer')
		company.pointer = :foobar_pointer
		@app.companies = {'Bayer'=>company}
		indication_pointer = ODDB::Persistence::Pointer.new([:indication, 1])
		indication = StubIndication.new('Heuschnupfen')
		indication.pointer = indication_pointer
		@app.indications = [indication]
		expected = {
			:registration_date	=>	Date.new(2003,1,1),
			:company						=>	:foobar_pointer,
			:indication					=>	indication_pointer,
			:export_flag				=>	nil,
			:source							=>	nil,
		}
		@plugin.update_registration(reg)
		pointer = ODDB::Persistence::Pointer.new([:registration, '12345'])
		assert_instance_of(ODDB::Persistence::Pointer, @app.values.last[:indication])
		assert_equal(expected, @app.values.last)
		res_pointer  = @app.pointers.last
		assert_equal(pointer.creator, res_pointer)
		# expected key is creator (Stubism)
		assert_equal({res_pointer => [:new]}, @plugin.change_flags) 
	end
	def test_update_registration2
		reg = StubSmjRegistration.new
		reg.flags = [:ikscat]
		reg.valid_until = Date.new(2004,1,1)
		company = StubCompany.new('Bayer')
		company.pointer = :pointer
		@app.companies = {'Bayer'=>company}
		@app.indications = []
		indication_pointer = ODDB::Persistence::Pointer.new(:indication)
		expected = {
			:revision_date	=>	Date.new(2003,1,1),
			:expiration_date=>	Date.new(2004,1,1),
			:company				=>	:pointer,
			:indication			=>	indication_pointer.creator,
			:export_flag		=>	nil,
			:source					=>	nil,
		}
		@plugin.update_registration(reg)
		assert_equal(indication_pointer.creator, @app.pointers.first)
		assert_equal({:la=>'Heuschnupfen'}, @app.values.first)
		assert_equal(expected, @app.values.last)
	end
	def test_update_registration_robust
		reg = StubSmjRegistration.new
		reg.company = nil
		reg.indication = nil
		reg.last_update = nil
		reg.iksnr = nil
		@plugin.update_registration(reg)
		expected = { 
			:revision_date	=>	nil,
			:export_flag		=>	nil,
			:source					=>	nil,
		}
		assert_equal(expected, @app.values.last)
	end
	def test_update_incomplete_anyway_if_has_iksnr
		reg = StubSmjRegistration.new
		reg.flags = [:ikscat]
		reg.valid_until = Date.new(2004,1,1)
		reg.incomplete = true
		company = StubCompany.new('Bayer')
		company.pointer = :pointer
		@app.companies = {'Bayer'=>company}
		@app.indications = []
		indication_pointer = ODDB::Persistence::Pointer.new(:indication)
		expected = {
			:revision_date	=>	Date.new(2003,1,1),
			:expiration_date=>	Date.new(2004,1,1),
			:company				=>	:pointer,
			:indication			=>	indication_pointer.creator,
			:export_flag		=>	nil,
			:source					=>	nil,
		}
		@plugin.update_registration(reg)
		assert_equal(indication_pointer.creator, @app.pointers.first)
		assert_equal({:la=>'Heuschnupfen'}, @app.values.first)
		assert_equal(expected, @app.values.last)
	end
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
		@plugin.prune_sequences(smj_registration, registration)	
		assert_equal(seq1.pointer, @app.delete_pointer)
		smj_registration.products = {'01'=>seq1}
		@plugin.prune_sequences(smj_registration, registration)	
		assert_equal(seq2.pointer, @app.delete_pointer)
	end
	def test_update_sequence
		pointer = ODDB::Persistence::Pointer.new
		seq = StubSequence.new
		seq.composition = StubComposition.new
		@plugin.update_sequence(seq, pointer)
		expected = {
			:name_base		=>	'Intralipid 20%',
			:name_descr		=>	'Kapseln',
			:dose					=>	[20, '%'],
			:galenic_form	=>	'Kapseln',
		}
		creator = ODDB::Persistence::Pointer.new([:create, (pointer + [:sequence, '01'])])
		assert_equal(creator, @app.pointers.at(1))
		assert_equal(expected, @app.values.at(1))
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
		@plugin.update_sequence(seq, pointer)
		expected = {}
		creator = ODDB::Persistence::Pointer.new([:create, (pointer + [:sequence, '01'])])
		assert_equal(creator, @app.pointers.first)
		assert_equal(expected, @app.values.first)
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
		
		smj_seq = StubSequence.new
		pointer = ODDB::Persistence::Pointer.new(:sequence)
		test = @plugin.accept_galenic_form?(pointer, smj_seq)
		assert_equal(true, test)
		pointer = ODDB::Persistence::Pointer.new([:galenic_group, 1],[:galenic_form])
		create_pointer = ODDB::Persistence::Pointer.new([:create, pointer])
		assert_not_nil(@app.pointers.last)
		assert_equal(create_pointer, @app.pointers.last)
	end
	def test_accept_galenic_form2
		@app.sequence = StubSequence.new
		@app.galenic_forms = {'Kapseln'=>'Kapseln'}
		assert_not_nil(@app.galenic_form('Kapseln'))
		smj_seq = StubSequence.new
		pointer = ODDB::Persistence::Pointer.new(:sequence)
		test = @plugin.accept_galenic_form?(pointer, smj_seq)
		assert_equal(true, test)
		assert_nil(@app.create_pointer)
	end
	def test_accept_galenic_form3
		@app.sequence = StubSequence.new
		@app.sequence.galenic_form = 'Kapseln'
		assert_not_nil(@app.sequence.galenic_form)
		smj_seq = StubSequence.new
		smj_seq.most_precise_galform = 'CAPSULA'
		assert_equal('CAPSULA', smj_seq.most_precise_galform) 
		pointer = ODDB::Persistence::Pointer.new(:sequence)
		test = @plugin.accept_galenic_form?(pointer, smj_seq)
		assert_equal(false, test)
	end
	def test_accept_galenic_form4
		@app.sequence = StubSequence.new
		@app.sequence.galenic_form = 'Kapseln'
		assert_not_nil(@app.sequence.galenic_form)
		smj_seq = StubSequence.new
		pointer = ODDB::Persistence::Pointer.new(:sequence)
		test = @plugin.accept_galenic_form?(pointer, smj_seq)
		assert_equal(false, test)
	end
	def test_accept_galenic_form5
		@app.sequence = StubSequence.new
		@app.galenic_forms = {'Kapseln'=>'Kapseln'}
		assert_not_nil(@app.galenic_form('Kapseln'))
		@app.sequence.galenic_form = 'Kapseln'
		assert_not_nil(@app.sequence.galenic_form)
		smj_seq = StubSequence.new
		pointer = ODDB::Persistence::Pointer.new(:sequence)
		test = @plugin.accept_galenic_form?(pointer, smj_seq)
		assert_equal(true, test)
	end
	def test_update_active_agents1
		@app.sequence = StubSequence.new
		active_agent = StubActiveAgent.new
		active_agent.pointer = 'boo'
		@app.sequence.active_agents = [
			active_agent
		]
		pointer = ODDB::Persistence::Pointer.new(:sequence)
		composition = StubComposition.new
		composition.active_agents = []
		@plugin.update_active_agents(composition, pointer)
		assert_nil(@app.delete_pointer)
	end
	def test_update_active_agents2
		@app.sequence = StubSequence.new
		active_agent = StubActiveAgent.new
		active_agent.pointer = 'boo'
		@app.sequence.active_agents = [
			active_agent
		]
		pointer = ODDB::Persistence::Pointer.new(:sequence)
		composition = StubComposition.new
		smj_agent = StubSmjActiveAgent.new
		smj_agent.substance = "FLUCLOXACILLINUM"
		smj_agent.dose = StubDose.new("500", "mg")
		composition.active_agents = [ smj_agent ]
		assert_nothing_raised {
			@plugin.update_active_agents(composition, pointer)
		}
		assert_equal('boo', @app.delete_pointer)
		agent_pointer = pointer + [:active_agent, "FLUCLOXACILLINUM"]
		substance_pointer = ODDB::Persistence::Pointer.new([:substance, "FLUCLOXACILLINUM"])
		assert_not_nil(@app.create_pointer)
		assert_equal(substance_pointer, @app.create_pointer)
		create_pointer = ODDB::Persistence::Pointer.new([:create, agent_pointer])
		assert_not_nil(@app.pointers.first)
		assert_equal(create_pointer, @app.pointers.first)
		expected = {
			:dose									=>	["500", "mg"],
		}
		assert_equal(expected, @app.values.first)
	end
	def test_update_active_agents3
		@app.sequence = StubSequence.new
		active_agent = StubActiveAgent.new
		active_agent.pointer = 'boo'
		@app.sequence.active_agents = [
			active_agent
		]
		@app.substances = {
			"FLUCLOXACILLINUM"						=>	true,
			"FLUCLOXACILLINUM NATRICUM"	=>	true,
		}
		pointer = ODDB::Persistence::Pointer.new(:sequence)
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
		@plugin.update_active_agents(composition, pointer)
		assert_equal('boo', @app.delete_pointer)
		agent_pointer = pointer + [:active_agent, "FLUCLOXACILLINUM"]
		# was equivalent substance newly created?
		substance_pointer = ODDB::Persistence::Pointer.new([:substance, "RUSCOGENINA"])
		assert_not_nil(@app.create_pointer)
		assert_equal(substance_pointer, @app.create_pointer)
		create_pointer = ODDB::Persistence::Pointer.new([:create, agent_pointer])
		assert_not_nil(@app.pointers.first)
		assert_equal(create_pointer, @app.pointers.first)
		expected = {
			:dose									=>	["500", "mg"],
			:chemical_substance		=>	"FLUCLOXACILLINUM NATRICUM",
			:chemical_dose				=>	["500", "mg"],
			:equivalent_substance	=>	"RUSCOGENINA",
			:equivalent_dose			=>	["0.5", "mg"],
		}
		assert_equal(expected, @app.values.first)
	end
	def test_update_packages
		pointer = ODDB::Persistence::Pointer.new(:sequence)
		sequence = StubSequence.new
		sequence.pointer = pointer
		package_pointer = pointer + [:package, "007"]
		create_pointer = ODDB::Persistence::Pointer.new([:create, package_pointer])
		smj_package = StubPackage.new
		smj_package.package_size = '12 Tabletten'
		smj_package.ikscat = 'B'
		smj_package.ikscd = '007'
		packages = [
			smj_package
		]
		@plugin.update_packages(packages, sequence)
		assert_not_nil(@app.pointers.first)
		assert_equal(create_pointer, @app.pointers.first)
		expected = {
			:size		=>	'12 Tabletten',
			:ikscat	=>	'B',
		}
		assert_equal(expected, @app.values.first)
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
		pointer = ODDB::Persistence::Pointer.new([:company])
		creator = ODDB::Persistence::Pointer.new([:create, pointer])
		@plugin.update_company(smj_company)
		expected = {
			:address	=>	'Sumpfstrasse 3',
			:plz			=>	'6312',
			:location	=>	'Steinhausen',
			:name			=>	'Bausch & Lomb Swiss AG',
		}
		assert_not_nil(@app.pointers.first)
		assert_equal(creator, @app.pointers.first)
		assert_equal(expected, @app.values.first)
	end
	def test_deactivate_registration1
		reg = StubSmjRegistration.new
		date = reg.date = Date.new(1975,8,21)
		@plugin.deactivate_registration(reg)	
		expected = {
			:inactive_date	=>	date,
		}
		pointer = ODDB::Persistence::Pointer.new([:registration, '12345'])
		assert_equal(expected, @app.values.last)
		assert_equal(pointer, @app.pointers.last)
	end
	def test_deactivate_registration2
		reg = StubSmjRegistration.new
		@plugin.deactivate_registration(reg)	
		expected = {
			:inactive_date	=>	Date.today,
		}
		pointer = ODDB::Persistence::Pointer.new([:registration, '12345'])
		assert_equal(expected, @app.values.last)
		assert_equal(pointer, @app.pointers.last)
	end
	def test_report
		expected = [
			'ODDB::SwissmedicJournalPlugin - Report ',
			'Updated Registrations: 0',
			'Incomplete Registrations: 0',
			'Deactivated Registrations: 0',
			'Incomplete Deactivations: 0',
			'Pruned Sequences: 0',
			'Pruned Packages: 0',
			'Total Sequences without ATC-Class: 0',
			nil,
			'Updated Registrations: 0',
			'Incomplete Registrations: 0',
			'Deactivated Registrations: 0',
			'Incomplete Deactivations: 0',
			'Total Sequences without ATC-Class: 0',
		].join("\n")
		assert_equal(expected, @plugin.report)
	end
	def test_log_info
		info = @plugin.log_info
		[:pointers, :report, :change_flags, :recipients].each { |key|
			assert(info.include?(key))
		}
	end
end
