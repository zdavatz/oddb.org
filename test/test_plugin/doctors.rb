#!/usr/bin/env ruby
# TestDoctorPlugin -- oddb.org -- 23.03.2011 -- mhatakeyama@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'plugin/doctors'

class TestDoctorPlugin < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @config = flexmock('config')
    @app    = flexmock('app', :config => @config)
    @plugin = ODDB::Doctors::DoctorPlugin.new(@app)
  end
=begin
  def test_restore
    assert_equal('', @plugin.restore)
  end
  def test_get_doctor_data
    assert_equal('', @plugin.get_doctor_data('doc_id'))
  end
=end
  def test_delete_doctor
    doc = flexmock('doc', :pointer => 'pointer')
    flexmock(@app, 
             :doctor_by_origin => doc,
             :delete           => nil
            )
    assert_equal(1, @plugin.delete_doctor('doc_id'))
  end
  def test_report
    flexmock(@app, :"doctors.size" => 'doctors.size')
    expected = "Doctors update \n\nNumber of doctors: doctors.size\nNew doctors: 0\nDeleted doctors: 0\n"
    assert_equal(expected, @plugin.report)
  end
  def test_merge_address
    target = {:symbol => 'value1'}
    source = {:symbol => 'value2'}
    symbol = :symbol
    assert_equal(nil, @plugin.merge_address(target, source, symbol))
    expected = {:symbol => ['value1', 'value2']}
    assert_equal(expected, target)
  end
  def test_merge_addresses
    addrs = [
      {:lines => 'value', :fax => 'fax', :fon => 'fon'},
      {:lines => 'value', :fax => 'fax', :fon => 'fon'}
    ]
    expected = [{:lines=>"value", :fax=>["fax"], :fon=>["fon"]}]
    assert_equal(expected, @plugin.merge_addresses(addrs))
  end
  def test_store_empty_ids
    flexmock(@config, :pointer => 'pointer')
    flexmock(@app, :update => 'update')
    assert_equal('update', @plugin.store_empty_ids('ids'))
  end
end
