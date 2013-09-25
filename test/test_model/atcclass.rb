#!/usr/bin/env ruby
# encoding: utf-8
# TestAtcClass -- oddb -- 25.02.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'stub/odba'
require 'model/atcclass'
require 'model/dose'

module ODDB
	class AtcClass
		attr_accessor :sequences, :ddd_guidelines, :guidelines
	end
end

class TestAtcClass <Minitest::Test
  include FlexMock::TestCase
	class StubSequence
		attr_accessor :substances
		def packages
			{
				:p1	=>	'Package1',
				:p2	=>	'Package2',
				:p3	=>	'Package3',
				:p4	=>	'Package4',
			}
		end
	end
	
	def setup
		@atc_class = ODDB::AtcClass.new('N02BA01')
	end
	def test_initialize
		assert_equal('N02BA01', @atc_class.code)
	end
  def test_active_packages
    seq1 = flexmock 'sequence1'
    seq2 = flexmock 'sequence2'
    seq1.should_receive(:public_packages).and_return ['package1', 'package2']
    seq2.should_receive(:public_packages).and_return ['package3']
    @atc_class.sequences.push seq1, seq2
    assert_equal ['package1', 'package2', 'package3'], @atc_class.active_packages
  end
	def test_add_sequence
		@atc_class.sequences = []
		prod = StubSequence.new
		@atc_class.add_sequence(prod)
		assert_equal([prod], @atc_class.sequences)
	end
	def test_remove_sequence
		prod = StubSequence.new
		@atc_class.sequences = [prod]
		@atc_class.remove_sequence(prod)
		assert_equal([], @atc_class.sequences)
	end
	def test_packages
		@atc_class.sequences = [
			StubSequence.new,
			StubSequence.new,
			StubSequence.new,
			StubSequence.new,
		]
		packages = @atc_class.packages
		assert_equal(16, packages.size)
	end
  def test_package_count
    seq1 = flexmock 'sequence1'
    seq2 = flexmock 'sequence2'
    seq1.should_receive(:public_package_count).and_return 2
    seq2.should_receive(:public_package_count).and_return 1
    @atc_class.sequences.push seq1, seq2
    assert_equal 3, @atc_class.package_count
  end
	def test_update_values1
		@atc_class.descriptions.update_values({'de'=>'eine Beschreibung'})
		assert_equal('eine Beschreibung', @atc_class.description('de'))
	end
	def test_update_description2
		values = {
			'de' =>	'eine Beschreibung',
		}
		@atc_class.update_values(values)
		assert_equal(values['de'], @atc_class.description('de'))
		values = {
			'de' =>	'eine andere Beschreibung',
		}
		pointer = ODDB::Persistence::Pointer.new()
		pointer.issue_update(@atc_class, values)
		assert_equal(values['de'], @atc_class.description('de'))
	end
  def test_checkout
    seq1 = flexmock 'sequence1'
    seq2 = flexmock 'sequence2'
    seq1.should_receive(:atc_class=).with(nil).times(1).and_return do
      @atc_class.sequences.delete(seq1)
      assert true
    end
    seq2.should_receive(:atc_class=).with(nil).times(1).and_return do
      @atc_class.sequences.delete(seq2)
      assert true
    end
    @atc_class.sequences.push seq1, seq2
    @atc_class.checkout
    assert_equal [], @atc_class.sequences
  end
  def test_company_filter_search
    seq1 = flexmock 'sequence1'
    seq2 = flexmock 'sequence2'
    seq1.should_receive(:company).and_return 'company1'
    seq2.should_receive(:company).and_return 'company2'
    @atc_class.sequences.push seq1, seq2
    filtered = @atc_class.company_filter_search('company1')
    assert_instance_of ODDB::AtcClass, filtered
    assert_equal [seq1], filtered.sequences
  end
	def test_create_guidelines
		pointer = ODDB::Persistence::Pointer.new([:atc_class, "A"])
		document = @atc_class.create_guidelines
		assert_instance_of(ODDB::Text::Document, document)
		assert_equal(document, @atc_class.guidelines)
	end
	def test_create_ddd_guidelines
		pointer = ODDB::Persistence::Pointer.new([:atc_class, "A"])
		document = @atc_class.create_ddd_guidelines
		assert_instance_of(ODDB::Text::Document, document)
		assert_equal(document, @atc_class.ddd_guidelines)
	end
	def test_create_ddd
		pointer = ODDB::Persistence::Pointer.new([:atc_class, "A"])
		ddd = @atc_class.create_ddd('O')
		assert_instance_of(ODDB::AtcClass::DDD, ddd)
		assert_equal(ddd, @atc_class.ddd('O'))
	end
	def test_parent_code
		assert_equal('N02BA', @atc_class.parent_code)
		level4 = ODDB::AtcClass.new('N02BA')
		assert_equal('N02B', level4.parent_code)
		level3 = ODDB::AtcClass.new('N02B')
		assert_equal('N02', level3.parent_code)
		level2 = ODDB::AtcClass.new('N02')
		assert_equal('N', level2.parent_code)
		level1 = ODDB::AtcClass.new('N')
		assert_equal(nil, level1.parent_code)
	end
	def test_has_ddd
		assert_equal(false, @atc_class.has_ddd?)
		@atc_class.ddds.store('O', :ddd)
		assert_equal(true, @atc_class.has_ddd?)
		@atc_class.ddds.delete('O')
		assert_equal(false, @atc_class.has_ddd?)
		@atc_class.ddd_guidelines = :foo
		assert_equal(true, @atc_class.has_ddd?)
		@atc_class.ddd_guidelines = nil
		assert_equal(false, @atc_class.has_ddd?)
		@atc_class.guidelines = :foo
		assert_equal(true, @atc_class.has_ddd?)
		@atc_class.guidelines = nil
		assert_equal(false, @atc_class.has_ddd?)
	end
	def test_substances__1
		seq1 = StubSequence.new
		seq1.substances = ['amlodipin']
		seq2 = StubSequence.new
		seq2.substances = ['amlodipin']
		@atc_class.sequences = [seq1, seq2]
		assert_equal(['amlodipin'], @atc_class.substances)
	end
	def test_substances__2
		seq1 = StubSequence.new
		seq1.substances = ['amlodipin']
		seq2 = StubSequence.new
		seq2.substances = ['acidum mefenamicum']
		@atc_class.sequences = [seq1, seq2]
		assert_equal(['amlodipin', 'acidum mefenamicum'], 
			@atc_class.substances)
	end
  def test_delete_ddd
    pointer = ODDB::Persistence::Pointer.new([:atc_class, "A"])
    ddd = @atc_class.create_ddd('O')
    assert_equal(ddd, @atc_class.ddd('O'))
    @atc_class.delete_ddd('P')
    assert_equal(ddd, @atc_class.ddd('O'))
    @atc_class.delete_ddd('O')
    assert_nil @atc_class.ddd('O')
  end
  def test_pointer_descr
    @atc_class.update_values :de => 'Description'
    assert_equal 'Description (N02BA01)', @atc_class.pointer_descr
  end
end
class TestDDD <Minitest::Test
	def test_equals1
		ddd = ODDB::AtcClass::DDD.new('O')
		ddd.dose = ODDB::Dose.new(1, 'g')
		compare = {
			:administration_route => 'O',
			:dose => ODDB::Dose.new(1, 'g')
		}
		assert_equal(true, ddd == compare)
		compare = {
			:administration_route => 'P',
			:dose => ODDB::Dose.new(1, 'g')
		}
		assert_equal(false, ddd == compare)
		compare = {
			:administration_route => 'O',
			:dose => ODDB::Dose.new(2, 'g')
		}
		assert_equal(false, ddd == compare)
	end
	def test_equals2
		ddd = ODDB::AtcClass::DDD.new('O')
		ddd.dose = ODDB::Dose.new(1, 'g')
		compare = ODDB::AtcClass::DDD.new('O')
		compare.dose = ODDB::Dose.new(1, 'g')
		assert_equal(true, ddd == compare)
		compare.dose = ODDB::Dose.new(2, 'g')
		assert_equal(false, ddd == compare)
		ddd = ODDB::AtcClass::DDD.new('P')
		compare.dose = ODDB::Dose.new(1, 'g')
		assert_equal(false, ddd == compare)
	end
	def test_equals3
		ddd = ODDB::AtcClass::DDD.new('O')
		ddd.dose = ODDB::Dose.new(1, 'g')
		assert_equal(false, ddd == 'something else entirely')
	end
end
