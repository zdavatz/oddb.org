#!/usr/bin/env ruby
# encoding: utf-8
#TestGalenicForm - oddb - 25.02.2003 - hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'stub/odba'
gem 'minitest'
require 'minitest/autorun'
require	'flexmock'
require 'model/galenicform'

module ODDB
  class GalenicForm
    attr_writer :sequences
    public :adjust_types, :sequences
  end
  class TestGalenicForm <Minitest::Test
    include FlexMock::TestCase
    class StubGroup
      attr_reader :add_called, :remove_called
      def add(form)
        @add_called = form
      end
      def remove(form)
        @remove_called = form
      end
      def pointer
        [:parent]
      end
    end
    class StubApp
      def initialize
        @galenic_groups = {}
        @galenic_forms = {}
      end
      def galenic_group(oid)
        @galenic_groups[oid] ||= StubGroup.new
      end
    end
    class StubSequence
      attr_reader :compositions
      include ODDB::Persistence
      def initialize
        @compositions = []
      end
      def galenic_form=(galform)
        if(@galform.respond_to?(:remove_sequence))
          @galform.remove_sequence(self)
        end
        galform.add_sequence(self)
        @galform = galform
      end
    end

    def setup
      @galform = ODDB::GalenicForm.new
      @galform.update_values('de'=>'Tabletten')
    end
    def teardown
      ODBA.storage = nil
    end
    def test_adjust_types
      app = StubApp.new
      group = app.galenic_group(2)
      pointer = ODDB::Persistence::Pointer.new([:galenic_group, 2])
      values = {
        :de							=>	'Augensalbe',
        :galenic_group	=>	pointer,
      }
      expected = {
        :de							=>	'Augensalbe',
        :galenic_group	=>	group,
      }
      result = @galform.adjust_types(values, app)
      assert_equal(expected, result)
    end
    def test_compare
      galform = ODDB::GalenicForm.new
      galform.update_values('de'=>'Suspension')
      assert_nothing_raised { galform <=> @galform }
      assert(@galform > galform, 'Tabletten was not > Suspension')
    end
    def test_equivalent_to
      group1 = StubGroup.new
      @galform.galenic_group = group1
      galform = ODDB::GalenicForm.new
      assert_not_equal(@galform, galform)
      assert(!@galform.equivalent_to?(galform), "The GalenicForms should not be equivalent")
      galform.galenic_group = group1
      assert_not_equal(@galform, galform)
      assert(@galform.equivalent_to?(galform), "The GalenicForms should be equivalent")
      assert(galform.equivalent_to?(@galform), "The GalenicForms should be equivalent")
      galform.galenic_group = StubGroup.new
      assert_not_equal(@galform, galform)
      assert(!@galform.equivalent_to?(galform), "The GalenicForms should not be equivalent")
    end
    def test_galenic_group_writer
      group1 = StubGroup.new
      assert_nil(group1.add_called)
      @galform.galenic_group = group1
      assert_equal(group1, @galform.galenic_group)
      assert_equal(@galform, group1.add_called)
      assert_equal([:parent, :galenic_form, @galform.oid], @galform.pointer)
      assert_nil(group1.remove_called)
      group2 = StubGroup.new
      @galform.galenic_group = group2
      assert_equal(@galform, group1.remove_called)
      assert_equal(@galform, group2.add_called)
    end
    def test_init
      pointer = ODDB::Persistence::Pointer.new([:galenic_group, 1], [:galenic_form])
      @galform.pointer = pointer
      @galform.init(nil)
      expected = pointer.parent + [:galenic_form, @galform.oid]
      assert_equal(expected, @galform.pointer)
    end
    def test_merge
      other = GalenicForm.new
      other.update_values('de'=>'Filmtabletten')
      comp1 = flexmock :galenic_form => other, :odba_isolated_store => true
      comp2 = flexmock :galenic_form => 'something-else'
      seq1 = flexmock :compositions => [comp1]
      seq2 = flexmock :compositions => [comp2]
      other.sequences.push seq1, seq2
      comp1.should_receive(:galenic_form=).with(@galform).times(1).and_return do
        assert true
      end
      @galform.merge(other)
      assert_equal ['Filmtabletten'], @galform.synonyms
    end
    def test_remove_sequence1
      a = StubSequence.new
      b = StubSequence.new
      c = StubSequence.new
      @galform.sequences = [a, b, c]
      @galform.remove_sequence(b)
      assert_equal([a, c], @galform.sequences)
    end
    def test_remove_sequence2
      a = StubSequence.new
      b = StubSequence.new
      c = StubSequence.new
      @galform.sequences = [a, b, c]
      @galform.sequences.dup.each { |seq|
        @galform.remove_sequence(seq)
      }
      assert_equal(0, @galform.sequences.size)
    end
    def test_route_of_administration
      assert_nil @galform.route_of_administration
      @galform.instance_variable_set '@galenic_group',
                                     flexmock(:route_of_administration => 'O')
      assert_equal 'O', @galform.route_of_administration
    end
    def test_sequence_count
      a = StubSequence.new
      b = StubSequence.new
      c = StubSequence.new
      assert_equal(0, @galform.sequence_count)
      @galform.add_sequence(a)
      assert_equal(1, @galform.sequence_count)
      @galform.add_sequence(b)
      assert_equal(2, @galform.sequence_count)
      @galform.remove_sequence(a)
      assert_equal(1, @galform.sequence_count)
      @galform.remove_sequence(b)
      assert_equal(0, @galform.sequence_count)
      @galform.remove_sequence(c)
      assert_equal(0, @galform.sequence_count)
    end
    def test_update_values
      assert_equal({'de'=>'Tabletten'}, @galform.descriptions.to_hash)	
      @galform.update_values(:de => 'Filmtabletten')
      assert_equal({'de'=>'Filmtabletten'}, @galform.descriptions.to_hash)	
    end
  end
end
