#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::TestPrescription -- oddb.org -- 06.08.2012 -- yasaka@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'state/drugs/prescription'

class StubPrescriptionSession
	attr_accessor :user_input, :persistent_user_input,
                :app, :event
	def initialize
		@user_input = {}
    @persistent_user_input = {}
	end
  def user_input(key)
    @user_input[key]
  end
  def set_user_input(key, value)
    @user_input[key] = value
  end
  def persistent_user_input(key)
    @persistent_user_input[key]
  end
  def set_persistent_user_input(key, value)
    @persistent_user_input[key] = value
  end
end
module ODDB
  module State
    module Drugs
class TestPrescription <Minitest::Test
  include FlexMock::TestCase
  def setup
    @session = StubPrescriptionSession.new
    @session.event = :rezept
    package      = flexmock('package', :class => Package)
    @session.app = flexmock('app', :package_by_ikskey => package)
    @model = flexmock('model', :pointer => 'pointer')
    @state = ODDB::State::Drugs::Prescription.new(@session, @model)
  end
  def teardown
    # clear input
    @session.user_input = {}
    @session.persistent_user_input = {}
  end
  def test_init
    fake_drug = {'1234567890123' => 'Fake Package'}
    @session.set_persistent_user_input(:drugs, fake_drug)
    assert_equal(fake_drug, @session.persistent_user_input(:drugs))
    @state.init
    assert_equal({}, @session.persistent_user_input(:drugs))
  end
  def export_csv
    assert_equal(PrescriptionCsvExport, @state.export_csv.class)
  end
  def test_check_model
    assert_equal(false, @state.respond_to?(:check_model))
    assert_equal(true, @state.private_methods.include?(:check_model))
  end
  def test_check_model_with_invalid_ean
    assert_equal(SBSM::ProcessingError, @state.send(:check_model).class)
    @session.set_user_input(:ean, '00000')
    assert_equal(SBSM::ProcessingError, @state.send(:check_model).class)
  end
  def test_check_model_with_valid_ean
    @session.set_user_input(:ean, '7680999999999')
    assert_equal(nil, @state.send(:check_model))
  end
  def test_package_for
    assert_equal(false, @state.respond_to?(:package_for))
    assert_equal(true, @state.private_methods.include?(:package_for))
  end
  def test_ajax_package_for_invalid_ean
    assert_equal(nil, @state.send(:package_for, '0'))
  end
  def test_package_for_valid_ean
    assert_equal(Package, @state.send(:package_for, '7680000000000').class)
  end
end
    end
  end
end
