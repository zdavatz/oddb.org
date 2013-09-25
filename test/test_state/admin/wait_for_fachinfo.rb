#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestWaitForFachinfo- oddb.org -- 21.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'state/admin/wait_for_fachinfo'

module ODDB
	module State
		module Admin

class TestModel <Minitest::Test
  include FlexMock::TestCase
  def setup
    @model = ODDB::State::Admin::WaitForFachinfo::Model.new
  end
  def test_structural_ancestors
    @model.instance_eval('@registration = "registration"')
    assert_equal(['registration'], @model.structural_ancestors)
  end
  def test_pointer_descr
    assert_equal(:fachinfo, @model.pointer_descr)
  end
end

class TestWaitForFachinfo <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @state   = ODDB::State::Admin::WaitForFachinfo.new(@session, @model)
  end
  def test_init
    assert_equal(0, @state.init)
  end
  def test_wait
    @state.init
    assert_equal(@state, @state.wait)
    assert_equal(@state, @state.wait)
    assert_equal(@state, @state.wait)
    assert_equal(@state, @state.wait)
    assert_equal(@state, @state.wait)
  end
  def test_wait__document
    document = flexmock('document')
    @state.instance_eval('@document = document')
    assert_kind_of(ODDB::State::Admin::FachinfoConfirm, @state.wait)
  end
  def test_wait__else
    assert_nil(@state.wait)
  end
  def test_signal_done
    flexmock(Log).new_instances do |log|
      log.should_receive(:report=)
      log.should_receive(:files=)
      log.should_receive(:notify).and_return('notify')
    end
    flexmock(@model, :iksnr => 'iksnr')
    user = flexmock('user', 
                    :name => 'name',
                    :name_first => 'name_first',
                    :name_last  => 'name_last'
                   )
    flexmock(@session, :user => user)
    assert_equal(false, @state.signal_done('document', 'path', @model, 'mimetype', 'language', 'link'))
  end
  def test_signal_done__fachinfodocument
    flexmock(Log).new_instances do |log|
      log.should_receive(:report=)
      log.should_receive(:files=)
      log.should_receive(:notify).and_return('notify')
    end
    flexmock(@model, :iksnr => 'iksnr')
    user = flexmock('user', 
                    :name => 'name',
                    :name_first => 'name_first',
                    :name_last  => 'name_last'
                   )
    flexmock(@session, :user => user)
    document = flexmock('document', :is_a? => true)
    assert_equal(false, @state.signal_done(document, 'path', @model, 'mimetype', 'language', 'link'))
  end
  def test_signal_done__exception
    flexmock(Log).new_instances do |log|
      log.should_receive(:report=)
      log.should_receive(:files=)
      log.should_receive(:notify).and_return('notify')
    end
    flexmock(@model, :iksnr => 'iksnr')
    user = flexmock('user', 
                    :name => 'name',
                    :name_first => 'name_first',
                    :name_last  => 'name_last'
                   )
    flexmock(@session, :user => user)
    document = flexmock('document') do |doc|
      doc.should_receive(:is_a?).with(FachinfoDocument).once.and_return(false)
      doc.should_receive(:is_a?).with(Exception).once.and_return(true)
      doc.should_receive(:message).and_return('message')
      doc.should_receive(:backtrace).and_return(['backtrace'])
    end
    assert_equal(false, @state.signal_done(document, 'path', @model, 'mimetype', 'language', 'link'))
  end

end

		end # Admin
	end # State
end # ODDB
