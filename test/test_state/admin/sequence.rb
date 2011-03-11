#!/usr/bin/env ruby
# State::Admin::TestSequence -- oddb.org -- 11.03.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/admin/sequence'

class TestResellerSequence < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @session = flexmock('session')
    @model = flexmock('model')
    @sequence = ODDB::State::Admin::ResellerSequence.new(@session, @model)
  end
  def test_ssign_patinfo
    flexmock(@model, :has_patinfo? => true)
    assert_kind_of(ODDB::State::Admin::AssignPatinfo, @sequence.assign_patinfo)
  end
  def test_assign_patinfo__else
    flexmock(@model, :has_patinfo? => false)
    assert_kind_of(ODDB::State::Admin::AssignDeprivedSequence, @sequence.assign_patinfo)
  end
=begin
  def test_get_patinfo_input__html_upload
    flexmock(@session) do |s|
      s.should_receive(:user_input).once.with(:html_upload)
    end
    assert_equal(@sequence, @sequence.get_patinfo_input({}))
  end
=end
  def test_get_patinfo_input__patinfo_delete
    flexmock(@session) do |s|
      s.should_receive(:user_input).once.with(:html_upload)
      s.should_receive(:user_input).once.with(:patinfo_upload)
      s.should_receive(:user_input).once.with(:patinfo).and_return('delete')
    end
    assert_equal(@sequence, @sequence.get_patinfo_input({}))
  end
  def test_get_patinfo_input__nothing
    flexmock(@session, :user_input => nil)
    assert_equal(@sequence, @sequence.get_patinfo_input({}))
  end
  def test_parse_patinfo__error
    assert_equal(nil, @sequence.parse_patinfo('src'))
  end

end
