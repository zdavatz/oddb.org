#!/usr/bin/env ruby
# TestSequence -- oddb -- 25.02.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/sequence'
require 'model/atcclass'
require 'model/substance'
require 'mock'

module ODDB
	class SequenceCommon
		attr_writer :packages, :active_agents
		attr_reader :patinfo_oid
		public :adjust_types
	end
end
class StubSequenceGalenicForm
	attr_reader :added, :removed
	def equivalent_to?(other)
		self==other
	end
	def add_sequence(seq)
		@added = seq
	end
	def remove_sequence(seq)
		@removed = seq
	end
end
class StubSequenceAtcClass
	attr_reader :state
	attr_accessor :sequences, :code
	def initialize
		@sequences = []
	end
	def add_sequence(sequence)
		@sequences.push(sequence)
		@state = :added
	end
	def remove_sequence(sequence)
		@state = :removed
	end	
end
class StubSequenceApp
	attr_writer :substances
	attr_reader :pointer, :values
	def initialize
		@atc = {}
		@substances = []
		@galforms = {}
	end
	def atc_class(atc)
		@atc[atc] ||= ODDB::AtcClass.new(atc)
	end
	def galenic_form(galform)
		@galforms[galform] ||= StubSequenceGalenicForm.new
	end
	def substance(key)
		@substances.first
	end
	def update(pointer, values)
		@pointer, @values = pointer, values
	end
end
class StubAcceptable
	attr_reader :accepted
	def accepted!(*args)
		@accepted = true
	end
end

class TestSequence < Test::Unit::TestCase
	class StubPatinfo
		attr_accessor :oid
		attr_reader :added, :removed
		def add_sequence(seq)
			@added = seq
		end
		def remove_sequence(seq)
			@removed = seq
		end
	end
	class StubActiveAgent
		attr_accessor :substance
	end
	def setup
		@seq = ODDB::Sequence.new(1)
	end
	def test_create_package
		@seq.packages = {}
		package = @seq.create_package('023')
		assert_equal(@seq, package.sequence)
		assert_equal(package, @seq.package(23))
		package = @seq.create_package(32)
		assert_equal(package, @seq.package('032'))
	end
	def test_initalize
		assert_equal('01', @seq.seqnr)
	end
	def test_name_writer
		@seq.name = "Aspirin, Tabletten"
		assert_equal("Aspirin, Tabletten", @seq.name)
		assert_equal("Aspirin", @seq.name_base)
		assert_equal("Tabletten", @seq.name_descr)
	end
	def test_galenic_form_writer
		assert_equal(nil, @seq.galenic_form)
		galform = StubSequenceGalenicForm.new
		@seq.galenic_form = galform
		assert_equal(@seq, galform.added)
		assert_equal(galform, @seq.galenic_form)
		other_galform = StubSequenceGalenicForm.new
		@seq.galenic_form = other_galform
		assert_equal(@seq, galform.removed)
		assert_equal(@seq, other_galform.added)
		seq = ODDB::IncompleteSequence.new(1)
		seq.galenic_form = galform
		assert_not_equal(seq, galform.added)
	end
	def test_atc_class_writer
		assert_nothing_raised { @seq.atc_class = nil }
		atc1 = StubSequenceAtcClass.new
		atc2 = StubSequenceAtcClass.new
		assert_nil(atc1.state)
		assert_nil(atc2.state)
		@seq.atc_class = atc1
		assert_equal(:added, atc1.state)
		assert_nil(atc2.state)
		assert_nothing_raised { @seq.atc_class = nil }
		assert_equal(:added, atc1.state)
		assert_nil(atc2.state)
		assert_equal(atc1, @seq.atc_class)
		@seq.atc_class = atc2
		assert_equal(:removed, atc1.state)
		assert_equal(:added, atc2.state)
		seq = ODDB::IncompleteSequence.new(1)
		seq.atc_class = atc1
		assert_equal(:removed, atc1.state)
	end
	def test_adjust_types
		values = {
			:name					=>	"Aspirin Cardio",
			:dose					=>	[100, 'mg'],
			:atc_class		=>	'N02BA01',
			:galenic_form	=>	'Tabletten',
		}
		app = StubSequenceApp.new
		expected = {
			:name					=>	"Aspirin Cardio",
			:dose					=>	ODDB::Dose.new(100, 'mg'),
			:atc_class		=>	app.atc_class('N02BA01'),
			:galenic_form	=>	app.galenic_form('Tabletten'),
		}
		assert_equal(expected, @seq.adjust_types(values, app))
	end
	def test_active_agent
		subst = ODDB::Substance.new
		active_agent = ODDB::ActiveAgent.new('LEVOMENTHOLUM')
		active_agent.substance = subst
		@seq.active_agents = [active_agent]
		assert_equal(active_agent, @seq.active_agent('LEVOMENTHOLUM'))
	end
	def test_active_agent2
		subst1 = ODDB::Substance.new
		subst2 = ODDB::Substance.new
		subst1.update_values(:lt => 'ACIDUM ACETYLSALICYLICUM')
		subst2.update_values(:lt => 'LEVOMENTHOLUM')
		active_agent1 = ODDB::ActiveAgent.new('')
		active_agent2 = ODDB::ActiveAgent.new('')
		active_agent1.substance = subst1
		active_agent2.substance = subst2
		@seq.active_agents = [active_agent1, active_agent2]
		assert_equal(active_agent1, @seq.active_agent('acidum acetylsalicylicum'))
		assert_equal(active_agent2, @seq.active_agent('levomentholum'))
	end
	def test_create_active_agent
		@seq.active_agents = []
		app = StubSequenceApp.new
		subst = ODDB::Substance.new
		app.substances = [subst]
		active_agent = @seq.create_active_agent('LEVOMENTHOLUM')
		assert_equal(ODDB::ActiveAgent,  @seq.active_agents.first.class)
		assert_equal(@seq, active_agent.sequence)
		active_agent.init(app)
		assert_equal([@seq], subst.sequences)
		assert_equal(subst, active_agent.substance)
	end
	def test_delete_active_agent
		active_agent = ODDB::ActiveAgent.new('LEVOMENTHOLUM')
		subst = ODDB::Substance.new
		active_agent.substance = subst
		@seq.active_agents = [active_agent]
		@seq.delete_active_agent('LEVOMENTHOLUM')
		assert_equal([], @seq.active_agents)
	end
	def test_match
		assert_nothing_raised{@seq.match('Aspirin')}
		assert_equal(nil, @seq.match('Aspirin'))
		@seq.name_base='Aspirin'
		assert_equal(MatchData, @seq.match('Aspirin').class)
		assert_equal(MatchData, @seq.match('aspirin').class)
	end
	def test_iksnr
		assert_respond_to(@seq, :iksnr)
	end
	def test_patinfo_writer
		patinfo1 = StubPatinfo.new
		patinfo1.oid = 4
		patinfo2 = StubPatinfo.new
		patinfo2.oid = 5
		@seq.patinfo = patinfo1
		assert_equal(@seq, patinfo1.added)
		assert_nil(patinfo1.removed)
		@seq.patinfo = patinfo2
		assert_equal(@seq, patinfo1.removed)
		assert_equal(@seq, patinfo2.added)
		assert_equal(@seq.patinfo_oid, 5)
		assert_nil(patinfo2.removed)
		@seq.patinfo = nil
		assert_equal(@seq, patinfo2.removed)
	end
	def test_comparables1
		atc = StubSequenceAtcClass.new
		@seq.atc_class = atc
		subst = ODDB::Substance.new
		active_agent = ODDB::ActiveAgent.new('LEVOMENTHOLUM')
		active_agent.substance = subst
		@seq.active_agents = [active_agent]
		@seq.galenic_form = StubSequenceGalenicForm.new
		comparable = ODDB::Sequence.new('02')
		comparable.atc_class = atc
		comparable.active_agents = [active_agent]
		comparable.galenic_form = @seq.galenic_form
		assert_equal([comparable], @seq.comparables)
	end
	def test_comparables2
		atc = StubSequenceAtcClass.new
		@seq.atc_class = atc
		subst = ODDB::Substance.new
		active_agent = ODDB::ActiveAgent.new('LEVOMENTHOLUM')
		active_agent.substance = subst
		@seq.active_agents = [active_agent]
		comparable = ODDB::Sequence.new('02')
		subst = ODDB::Substance.new
		active_agent = ODDB::ActiveAgent.new('ACIDUM ACETYLSALICYLICUM')
		active_agent.substance = subst
		comparable.active_agents = [active_agent]
		comparable.atc_class = atc
		assert_equal([], @seq.comparables)
	end
	def test_comparables3
		atc = StubSequenceAtcClass.new
		@seq.atc_class = atc
		subst1 = ODDB::Substance.new
		subst1.descriptions[:de] = 'CAPTOPRILUM'
		subst2 = ODDB::Substance.new
		subst2.descriptions[:de] = 'HYDROCHLOROTHIACIDUM'
		active_agent1 = ODDB::ActiveAgent.new('CAPTOPRILUM')
		active_agent2 = ODDB::ActiveAgent.new('HYDROCHLOROTHIACIDUM')
		active_agent1.substance = subst1
		active_agent2.substance = subst2
		@seq.active_agents = [active_agent1, active_agent2]
		@seq.galenic_form = StubSequenceGalenicForm.new
		comparable = ODDB::Sequence.new('02')
		comparable.active_agents = [active_agent2, active_agent1]
		comparable.atc_class = atc
		comparable.galenic_form = @seq.galenic_form
		assert_equal(true, @seq.comparable?(comparable))
		assert_equal([comparable], @seq.comparables)
	end
	def test_robust_adjust_types
		values = {
			:dose	=>	[123, 'fjdsfjdksah'],
		}
		result = {}
		assert_nothing_raised {
			result = @seq.adjust_types(values)
		}
		assert_equal(ODDB::Dose.new(123, nil), result[:dose])
	end
	def test_robust_adjust_types_fuzzy_retry
		values = {
			:dose	=>	[123, 'mgkKo'],
		}
		result = {}
		assert_nothing_raised {
			result = @seq.adjust_types(values)
		}
		assert_equal(ODDB::Dose.new(123, 'mg'), result[:dose])
	end
	def test_substances
		active_agent1 = StubActiveAgent.new
		active_agent2 = StubActiveAgent.new
		active_agent1.substance = "Subst1"
		active_agent2.substance = "Subst2"
		@seq.active_agents = [active_agent1, active_agent2]
		assert_equal(["Subst1", "Subst2"], @seq.substances)
	end
	def test_substance_names
		active_agent1 = StubActiveAgent.new
		active_agent2 = StubActiveAgent.new
		active_agent1.substance = "Subst1"
		active_agent2.substance = "Subst2"
		expected = ["Subst1", "Subst2"]
		@seq.active_agents = [active_agent1, active_agent2]
		assert_equal(expected, @seq.substance_names)
	end
	def test_checkout
		assert_nothing_raised {
			@seq.checkout
		}
		atc1 = StubSequenceAtcClass.new
		@seq.atc_class = atc1
		assert_equal(:added, atc1.state)
		@seq.checkout
		assert_equal(:removed, atc1.state)
		galform = StubSequenceGalenicForm.new
		@seq.galenic_form = galform
		assert_equal(@seq, galform.added)
		@seq.checkout
		assert_equal(@seq, galform.removed)
	end
	def test_composition_text
		subst = ODDB::Substance.new
		subst.descriptions['lt'] = 'Levomentholum'
		active_agent = ODDB::ActiveAgent.new('LEVOMENTHOLUM')
		active_agent.substance = subst
		@seq.active_agents = [active_agent]
		assert_equal('Levomentholum ', @seq.composition_text)
		text = "Foo, Bar, and some Levomentholum mixed in."
		@seq.composition_text = text
		assert_equal(text, @seq.composition_text)
	end
	def test_limitation_text_count
		mock1 = Mock.new("packet_mock1")
		mock2 = Mock.new("packet_mock2")
		mock3 = Mock.new("packet_mock3")
		hash = {
			:mock1 => mock1,
			:mock2 => mock2,
			:mock3 => mock3,
		}
		@seq.packages = hash
		mock1.__next(:sl_entry){ "entry"}
		mock2.__next(:sl_entry){}
		mock3.__next(:sl_entry){}
		text_count = @seq.limitation_text_count
		mock1.__verify
		mock2.__verify
		mock3.__verify
		assert_equal(1, text_count)
	end
end
class TestIncompleteSequence < Test::Unit::TestCase
	def setup
		@seq = ODDB::IncompleteSequence.new(1)
		@seq.name = 'Ponstan, Tabletten'
		@seq.dose = ODDB::Dose.new(10, 'mg')
		atc = StubSequenceAtcClass.new
		atc.code = 'A01BC23'
		@seq.atc_class = atc
	end
	def test_accepted
		app = StubSequenceApp.new
		ptr = ODDB::Persistence::Pointer.new()
		pack = StubAcceptable.new
		agent = StubAcceptable.new
		@seq.packages = {'01'	=>	pack}
		@seq.active_agents = [agent]
		@seq.accepted!(app, ptr)
		pointer = ptr + [:sequence, '01']
		assert_equal(pointer.creator, app.pointer)
		expected = {
			:atc_class=>"A01BC23",
			:name_base=>"Ponstan",
			:dose=>Quanty(10,'mg'),
			:name_descr=>"Tabletten",
		}
		assert_equal(expected, app.values)
		assert(pack.accepted)
		assert(agent.accepted)
	end
end
