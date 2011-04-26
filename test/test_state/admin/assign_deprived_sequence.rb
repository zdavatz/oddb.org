#!/usr/bin/env ruby
# ODDB::State::Admin::TestAssignDeprivedSequence -- oddb.org -- 26.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/admin/assign_deprived_sequence'
require 'state/admin/patinfo_preview'

module ODDB
	module State
		module Admin

class TestDeprivedSequenceFacade < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    registration = flexmock('registration')
    @sequence1   = flexmock('sequence1', :registration => registration)
    @sequence2   = flexmock('sequence2')
    flexmock(registration, :sequences => {'key' => @sequence2})
    @facade      = ODDB::State::Admin::AssignDeprivedSequence::DeprivedSequenceFacade.new(@sequence1)
  end
  def test_structural_ancestors
    flexmock(@sequence1, :structural_ancestors => 'structural_ancestors')
    assert_equal('structural_ancestors', @facade.structural_ancestors('app'))
  end
  def test_each
    @facade.each do |seq|
      assert_equal(@sequence2, seq)
    end
  end
  def test_empty
    assert_equal(false, @facade.empty?)
  end
  def test_name_base
    flexmock(@sequence1, :name_base => 'name_base')
    assert_equal('name_base', @facade.name_base)
  end
  def test_pointer
    flexmock(@sequence1, :pointer => 'pointer')
    assert_equal('pointer', @facade.pointer)
  end
  def test_sequence
    new_sequence  = flexmock('new_sequence')
    new_sequences = [new_sequence, @sequence]
    @facade.sequences = new_sequences
    expected = [new_sequence, nil]  # Why does the nil remain?
    assert_equal(expected, @facade.sequences)
  end
end

class TestAssignDeprivedSequence < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @sequence = flexmock('sequence')
    @app      = flexmock('app', :search_sequences => [@sequence])
    @session  = flexmock('session', 
                         :app    => @app
                        )
    registration = flexmock('registration', :sequences => {'key' => @sequence})
    @model    = flexmock('model', 
                         :registration => registration,
                         :name_base    => 'name_base'
                        )
    @state    = ODDB::State::Admin::AssignDeprivedSequence.new(@session, @model)
  end
  def test_named_sequences__name_size_less_3
    assert_equal([], @state.named_sequences('na'))
  end
  def test_named_sequences
    flexmock(@state, :allowed? => true)
    assert_equal([@sequence], @state.named_sequences('name'))
  end
  def test_named_sequences__sequence_size_more_50
    sequences = [@sequence] * 51
    flexmock(@app, :search_sequences => sequences)
    flexmock(@state, :allowed? => true)
    assert_equal(sequences[0,50], @state.named_sequences('name'))
  end
  def test_init
    flexmock(@state, :allowed? => true)
    expected = [@sequence]
    assert_equal(expected, @state.init)
  end
  def test_init__sequence_empty
    flexmock(@state, :allowed? => nil)
    expected = [@sequence]
    assert_equal(expected, @state.init)
  end
  def test_assign_deprived_sequence
    flexmock(@model, 
             :sequence => @sequence,
             :pointer  => 'pointer'
            )
    flexmock(@state, 
             :allowed?     => true,
             :unique_email => 'unique_email'
            )
    pointer = flexmock('pointer', :last_step => 'last_step')
    flexmock(@session, 
             :error?     => nil,
             :user_input => pointer
            )
    flexmock(@app, :update => 'update')
    assert_equal(nil, @state.assign_deprived_sequence)
  end
  def test_assign_deprived_sequence__pdf_patinfo
    flexmock(@model, 
             :sequence => @sequence,
             :pointer  => 'pointer'
            )
    flexmock(@state, 
             :allowed?     => true,
             :unique_email => 'unique_email'
            )
    pointer = flexmock('pointer', :last_step => [:pdf_patinfo])
    flexmock(@session, 
             :error?     => nil,
             :user_input => pointer,
             :resolve    => 'resolve'
            )
    flexmock(@app, :update => 'update')
    assert_equal(nil, @state.assign_deprived_sequence)
  end
  def test_assing_deprived_sequence__not_allowed
    flexmock(@model, :sequence => @sequence)
    flexmock(@state, :allowed? => false)
    assert_equal(@state, @state.assign_deprived_sequence)
  end
  def test_search_sequences
    flexmock(@session, :user_input => 'name')
    flexmock(@state, :allowed? => true)
    @state.init
    assert_equal(@state, @state.search_sequences)
  end
  def test_search_sequences__not_string_name
    flexmock(@session, :user_input => :name)
    flexmock(@state, :allowed? => true)
    @state.init
    assert_equal(@state, @state.search_sequences)
  end
  def test_shadow
    flexmock(@app, :update => 'update')
    flexmock(@state, 
             :allowed?     => true,
             :unique_email => 'unique_email'
            )
    flexmock(@model, :pointer => 'pointer')
    assert_equal(nil, @state.shadow)
  end
  def test_symbol
    assert_equal(:name_base, @state.symbol)
  end
  def test_preview
    flexmock(@session, :user_input => 'lang')
    flexmock(@model, :languages => {'lang' => 'doc'})
    assert_kind_of(ODDB::State::Admin::PatinfoPreview, @state.preview)
  end
  def test_preview__else
    flexmock(@session, :user_input => nil)
    assert_equal(@state, @state.preview)
  end
  def test__patinfo_deprived_sequences
    flexmock(@state, :patinfo_deprived_sequences => 'patinfo_deprived_sequences')
    previous = flexmock('previous', :direct_event => :patinfo_deprived_sequences)
    @state.instance_eval('@previous = previous')
    assert_equal('patinfo_deprived_sequences', @state._patinfo_deprived_sequences)
  end

end


		end # Admin
	end # State
end # ODDB
