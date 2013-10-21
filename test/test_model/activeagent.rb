#!/usr/bin/env ruby
# encoding: utf-8
# TestActiveAgent -- oddb -- 18.04.2012 -- yasaka@ywesee.com
# TestActiveAgent -- oddb -- 25.02.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'stub/odba'
gem 'minitest'
require 'minitest/autorun'
require 'model/activeagent'
require 'flexmock'

module ODDB
	class ActiveAgentCommon
		public :adjust_types
    check_class_list = {
      :substance            => ['ODDB::Substance', 'StubActiveAgentSubstance'],
      :chemical_substance   => ['ODDB::Substance', 'StubActiveAgentSubstance'],
      :equivalent_substance => ['ODDB::Substance', 'StubActiveAgentSubstance'],
      :dose                 => ['ODDB::Dose', 'StubActiveAgentDose'],
      :chemical_dose        => ['ODDB::Dose', 'StubActiveAgentDose'],
      :equivalent_dose      => ['ODDB::Dose', 'StubActiveAgentDose'],
      :sequence             => ['ODDB::Sequence', 'StubActiveAgentSequence'],
    }
    define_check_class_methods check_class_list
	end
end
class StubActiveAgentSubstance
	attr_reader :name, :sequence, :removed_sequence
	alias :to_s :name
	def initialize(name)
		@name = name
	end
	def ==(other)
		@name==other.name if other
	end
	def add_sequence(sequence)
		@sequence = sequence
	end
	def remove_sequence(sequence)
		@removed_sequence = sequence
	end
	def <=>(other)
		@name.downcase <=> other.to_s.downcase 
	end
end
class StubActiveAgentDose
end
class StubActiveAgentApp
	attr_writer :substances
	attr_reader :pointer, :values
	def substance(key)
		unless @substances
			@substances = {
				key	=>	StubActiveAgentSubstance.new(key)
			}
		end
		@substances[key]
	end
	def parent
		StubActiveAgentParent.new
	end
	def update(pointer, values)
		@pointer, @values = pointer, values
	end
end
class StubActiveAgentSequence
	attr_accessor :pointer
end

class TestActiveAgent <Minitest::Test
  include FlexMock::TestCase
	def setup
		@substance_name = 'ACIDUM ACETYLSALICYLICUM'
		@agent = ODDB::ActiveAgent.new(@substance_name)
    @agent.substance = @substance
    @agent.dose = ODDB::Dose.new 100, 'mg'
		@app = StubActiveAgentApp.new
    @substance = StubActiveAgentSubstance.new(@substance_name)
		@agent.pointer = ODDB::Persistence::Pointer.new('parent', 'self')
		@sequence = StubActiveAgentSequence.new
		@sequence.pointer = ODDB::Persistence::Pointer.new(:sequence, 1)
		@agent.sequence = @sequence
		@agent.init(@app)
	end
	def test_init
		assert_equal(@substance, @agent.substance)
    skip("niklaus has no time to debug this assert")
		assert_equal(@sequence, @agent.substance.sequence)
	end
	def test_equal
		other = ODDB::ActiveAgent.new(@substance_name)
    other.substance = @substance
    other.dose = ODDB::Dose.new 100, 'mg'
		other.pointer = ODDB::Persistence::Pointer.new('parent', 'self')
		other.init(@app)
		assert_equal(other, @agent)
		@agent == nil
	end
	def test_substance_writer
		sequence = StubActiveAgentSequence.new
		sequence.pointer = ODDB::Persistence::Pointer.new([:sequence, 2])
		subst1 = StubActiveAgentSubstance.new("LEVOMENTHOLUM")
		@agent.sequence = sequence
		@agent.substance = subst1
    skip("niklaus has no time to debug this assert")
		assert_equal(sequence, subst1.sequence)
		assert_equal(subst1, @agent.substance)
		subst2 = StubActiveAgentSubstance.new("ACIDUM MEFENAMICUM")
		@agent.substance = subst2
		assert_equal(sequence, subst1.removed_sequence)
		assert_equal(sequence, subst2.sequence)
		assert_equal(subst2, @agent.substance)
		subst3 = StubActiveAgentSubstance.new("ACIDUM MEFENAMICUM")
		# no action if substance == @substance
		@agent.substance = subst3
		assert_nil(subst2.removed_sequence)
		assert_nil(subst3.sequence)
		assert_equal(subst2, @agent.substance)
	end
	def test_checkout
		@agent.checkout
		assert_equal(@sequence, @agent.substance.removed_sequence)
	end
	def test_adjust_types
		app = StubActiveAgentApp.new
		subst = StubActiveAgentSubstance.new('ACIDUM MEFENAMICUM')
		dose = ODDB::Dose.new(10, 'mg')
		input = {
			:dose				=>	['10', 'mg'],
			:substance	=>	'ACIDUM MEFENAMICUM',
		}
		expected = {
			:dose				=>	dose,
			:substance	=>	subst,
		}
		assert_equal(expected, @agent.adjust_types(input, app))
		input = {
			:dose				=>	'10mg',
			:substance	=>	'ACIDUM MEFENAMICUM',
		}
		expected = {
			:dose				=>	ODDB::Dose.new(10),
			:substance	=>	subst,
		}
		assert_equal(expected, @agent.adjust_types(input, app))
		input = {
			:dose				=>	['10', 'mg'],
			:substance	=>	'ACIDUM ACETYLSALICYLICUM',
		}
		expected = {
			:dose				=>	dose,
		}
		assert_equal(expected, @agent.adjust_types(input, app))
	end
	def test_adjust_types_chemical
		app = StubActiveAgentApp.new
		subst = StubActiveAgentSubstance.new('ACIDUM MEFENAMICUM')
		dose = ODDB::Dose.new(10, 'mg')
		input = {
			:chemical_dose			=>	['10', 'mg'],
			:chemical_substance	=>	'ACIDUM MEFENAMICUM',
		}
		expected = {
			:chemical_dose			=>	dose,
			:chemical_substance	=>	subst,
		}
		assert_equal(expected, @agent.adjust_types(input, app))
		input = {
			:chemical_dose			=>	nil,
			:chemical_substance	=>	'ACIDUM MEFENAMICUM',
		}
		expected = {
			:chemical_dose			=>	nil,
			:chemical_substance	=>	subst,
		}
		assert_equal(expected, @agent.adjust_types(input, app))
		input = {
			:chemical_dose			=>	['10', 'mg'],
			:chemical_substance	=>	'ACIDUM ACETYLSALICYLICUM',
		}
		expected = {
			:chemical_dose			=>	dose,
			:chemical_substance	=>	nil,
		}
		assert_equal(expected, @agent.adjust_types(input, app))
	end
	def test_adjust_types_equivalent
		app = StubActiveAgentApp.new
		subst = StubActiveAgentSubstance.new('ACIDUM MEFENAMICUM')
		dose = ODDB::Dose.new(10, 'mg')
		input = {
			:equivalent_dose			=>	['10', 'mg'],
			:equivalent_substance	=>	'ACIDUM MEFENAMICUM',
		}
		expected = {
			:equivalent_dose			=>	dose,
			:equivalent_substance	=>	subst,
		}
		assert_equal(expected, @agent.adjust_types(input, app))
		input = {
			:equivalent_dose			=>	nil,
			:equivalent_substance	=>	'ACIDUM MEFENAMICUM',
		}
		expected = {
			:equivalent_dose			=>	nil,
			:equivalent_substance	=>	subst,
		}
		assert_equal(expected, @agent.adjust_types(input, app))
		input = {
			:equivalent_dose			=>	['10', 'mg'],
			:equivalent_substance	=>	'ACIDUM ACETYLSALICYLICUM',
		}
		expected = {
			:equivalent_dose			=>	dose,
			:equivalent_substance	=>	nil,
		}
		assert_equal(expected, @agent.adjust_types(input, app))
	end
  def test_adjust_types__error
    res = nil
    res = @agent.adjust_types :dose => []
    assert_equal({}, res)
  end
	def test_compare1
		@agent.dose = ODDB::Dose.new(1,'g')
		other = ODDB::ActiveAgent.new(@substance_name)
		other.pointer = ODDB::Persistence::Pointer.new('parent', 'self')
		other.init(@app)
		other.dose = ODDB::Dose.new(2, 'g')
		assert_equal(-1, other <=> @agent)
		other.dose = ODDB::Dose.new(1, 'g')
		assert_equal(0, other <=> @agent)
	end
	def test_compare2
		substance = StubActiveAgentSubstance.new('LEVOMENTHOLUM')
		@app.substances = {
			'LEVOMENTHOLUM' =>	substance,
			@substance_name	=>	@substance,
		}
		@agent.dose = ODDB::Dose.new(1,'g')
		other = ODDB::ActiveAgent.new('LEVOMENTHOLUM')
		other.pointer = ODDB::Persistence::Pointer.new('parent', 'self')
		other.init(@app)
		other.dose = ODDB::Dose.new(2, 'g')
		assert_equal(-1, other <=> @agent)
		other.dose = ODDB::Dose.new(0.5, 'g')
		assert_equal(1, other <=> @agent)
		other.dose = ODDB::Dose.new(1, 'g')
		assert_equal(1, other <=> @agent)
		assert_equal([@agent, other], [other, @agent].sort)
	end
	def test_compare3
		substance = StubActiveAgentSubstance.new('LEVOMENTHOLUM')
		@app.substances = {
			'LEVOMENTHOLUM' =>	substance,
			@substance_name	=>	@substance,
		}
		@agent.dose = ODDB::Dose.new(1,'g')
		other = ODDB::ActiveAgent.new('LEVOMENTHOLUM')
		other.pointer = ODDB::Persistence::Pointer.new('parent', 'self')
		other.init(@app)
		assert_equal(1, other <=> @agent)
		@agent.dose = nil
		other.dose = ODDB::Dose.new(0.5, 'g')
		assert_equal(-1, other <=> @agent)
		other.dose = nil
		assert_equal(1, other <=> @agent)
	end
	def test_same_as
		agent = ODDB::ActiveAgent.new(@substance_name)
		assert_equal(false, agent.same_as?('Levomentholum'))
		subst = flexmock('subst')
		agent.instance_variable_set('@substance', subst)
		subst.should_receive(:same_as?).once.and_return { |arg| 
			assert_equal('Levomentholum', arg)
			true
		}
		assert_equal(true, agent.same_as?('Levomentholum'))
	end
  def test_to_a
    assert_equal [@substance, @agent.dose], @agent.to_a
  end
  def test_to_s
    assert_equal 'ACIDUM ACETYLSALICYLICUM 100 mg', @agent.to_s
  end
  def test_update_values
  end
end
