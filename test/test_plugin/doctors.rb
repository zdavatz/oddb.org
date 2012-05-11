#!/usr/bin/env ruby
# encoding: utf-8
# TestDoctorPlugin -- oddb.org -- 11.05.2012 -- yasaka@ywesee.com
# TestDoctorPlugin -- oddb.org -- 23.03.2011 -- mhatakeyama@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test-unit'
require 'flexmock'
require 'plugin/doctors'
require 'tempfile'

class TestDoctorPlugin < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @config = flexmock('config')
    @app    = flexmock('app', :config => @config)
    @plugin = ODDB::Doctors::DoctorPlugin.new(@app)
  end
  def test_restore
    doctor = flexmock('doctor', :pointer => 'pointer')
    flexmock(@app, 
             :doctor_by_origin => doctor,
             :update           => 'update'
            )
    flexmock(@plugin, :get_doctor_data => {})
    assert_equal('update', @plugin.restore('doc_id'))
  end
  def test_update
    doctor = flexmock('doctor', :pointer => 'pointer')
    flexmock(@app, 
             :doctor_by_origin => doctor,
             :update           => 'update'
            )
    flexmock(@config, 
             :empty_ids => nil,
             :pointer   => 'pointer'
            )
    flexmock(@plugin, :get_doctor_data => {})
    flexmock(@plugin, :puts => nil)
    assert_equal(5000, @plugin.update)
  end
  def test_update__no_doctor
    doctor = flexmock('doctor', :pointer => 'pointer')
    flexmock(@app, 
             :doctor_by_origin => doctor,
             :update           => 'update',
             :delete           => 'delete'
            )
    flexmock(@config, 
             :empty_ids => nil,
             :pointer   => 'pointer'
            )
    flexmock(@plugin, :get_doctor_data => nil)
    flexmock(@plugin, :puts => nil)
    assert_equal(5000, @plugin.update)
  end
  def test_store_doctor
    doctor = flexmock('doctor', :pointer => 'pointer')
    flexmock(@app, 
             :doctor_by_origin => doctor,
             :update           => 'update'
            )
    hash = {:ean13 => '123', :praxis => 'Ja', :specialities => 'value'}
    assert_equal('update', @plugin.store_doctor('doc_id', hash))
  end
  def test_store_doctor__else
    flexmock(@app, 
             :doctor_by_origin => nil,
             :update           => 'update'
            )
    hash = {}
    assert_equal('update', @plugin.store_doctor('doc_id', hash))
  end
  def test_prepare_addresses
    addrs = [
      {:lines => 'value', :fax => 'fax', :fon => 'fon'},
      {:lines => 'value', :fax => 'fax', :fon => 'fon'}
    ]
    hash = {:addresses => addrs}
    assert_kind_of(ODDB::Address, @plugin.prepare_addresses(hash)[0])
  end

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
  def stderr_null
    require 'tempfile'
    $stderr = Tempfile.open('stderr')
    yield
    $stderr.close
    $stderr = STDERR
  end
  def replace_constant(constant, temp)
    stderr_null do
      keep = eval constant
      eval "#{constant} = temp"
      yield
      eval "#{constant} = keep"
    end
  end
  def test_get_doctor_data
    parser = flexmock('parser', :doc_data_add_ean => 'doc_data_add_ean')
    replace_constant('ODDB::Doctors::DoctorPlugin::PARSER', parser) do 
      assert_equal('doc_data_add_ean', @plugin.get_doctor_data('doc_id'))
    end
  end
  def test_get_doctor_data__error
    parser = flexmock('parser') do |p|
      p.should_receive(:doc_data_add_ean).and_raise(Errno::EINTR)
    end
    flexmock(@plugin, :puts => nil)
    replace_constant('ODDB::Doctors::DoctorPlugin::PARSER', parser) do
      assert_equal(nil, @plugin.get_doctor_data('doc_id'))
    end
  end
  def test_fix_doctors
    praxis_address = flexmock('praxis_address', :city => 'city')
    doctor1  = flexmock('doctor1', 
                       :name           => 'name1',
                       :firstname      => 'firstname',
                       :praxis_address => praxis_address,
                       :ean13=         => nil,
                       :odba_store     => 'odba_store'
                      )
    doctor2  = flexmock('doctor2', 
                       :name           => 'name2',
                       :firstname      => 'firstname2',
                       :praxis_address => praxis_address,
                       :ean13=         => nil,
                       :odba_store     => 'odba_store'
                      )
    doctor3  = flexmock('doctor3', 
                       :name           => 'name1',
                       :firstname      => 'firstname',
                       :praxis_address => praxis_address,
                       :ean13=         => nil,
                       :odba_store     => 'odba_store'
                      )

    res     = flexmock('res', :values => ['name1', 'firstname1', 'city'])
    meddata = flexmock('meddata') do |m|
      m.should_receive(:search).and_return([res])
      m.should_receive(:detail).and_return({:ean13 => 'ean13'})
    end
    server  = flexmock('server') do |s|
      s.should_receive(:session).and_yield(meddata)
    end
    replace_constant('ODDB::Doctors::DoctorPlugin::MEDDATA_SERVER', server) do
      assert_equal([doctor1, doctor2, doctor3], @plugin.fix_doctors('ambiguous', [doctor1, doctor2, doctor3]))
    end
  end
  def test_fix_doctors__ambiguous
    praxis_address = flexmock('praxis_address', :city => 'city')
    doctor1  = flexmock('doctor1', 
                       :name           => 'name1',
                       :firstname      => 'firstname',
                       :praxis_address => praxis_address,
                       :ean13=         => nil,
                       :odba_store     => 'odba_store'
                      )
    doctor2  = flexmock('doctor2', 
                       :name           => 'name2',
                       :firstname      => 'firstname2',
                       :praxis_address => praxis_address,
                       :ean13=         => nil,
                       :odba_store     => 'odba_store'
                      )
    doctor3  = flexmock('doctor3', 
                       :name           => 'name1',
                       :firstname      => 'firstname',
                       :praxis_address => praxis_address,
                       :ean13=         => nil,
                       :odba_store     => 'odba_store'
                      )

    res     = flexmock('res', :values => ['name1', 'firstname1', 'city'])
    meddata = flexmock('meddata') do |m|
      m.should_receive(:search).and_return([res,res])
      m.should_receive(:detail).and_return({:ean13 => 'ean13'})
    end
    server  = flexmock('server') do |s|
      s.should_receive(:session).and_yield(meddata)
    end
    replace_constant('ODDB::Doctors::DoctorPlugin::MEDDATA_SERVER', server) do
      assert_equal([doctor1, doctor2, doctor3], @plugin.fix_doctors('ambiguous', [doctor1, doctor2, doctor3]))
    end
  end
  def test_fix_doctors__runtime_error
    praxis_address = flexmock('praxis_address', :city => 'city')
    doctor  = flexmock('doctor1', 
                       :name           => 'name1',
                       :firstname      => 'firstname',
                       :praxis_address => praxis_address,
                       :ean13=         => nil,
                       :odba_store     => 'odba_store'
                      )
    res     = flexmock('res', :values => ['name1', 'firstname1', 'city'])
    meddata = flexmock('meddata') do |m|
      m.should_receive(:search).and_raise(RuntimeError)
      m.should_receive(:detail).and_return({:ean13 => 'ean13'})
    end
    server  = flexmock('server') do |s|
      s.should_receive(:session).and_yield(meddata)
    end
    flexmock(@plugin, :puts => nil)
    replace_constant('ODDB::Doctors::DoctorPlugin::MEDDATA_SERVER', server) do
      assert_equal([doctor], @plugin.fix_doctors('ambiguous', [doctor]))
    end
  end
  def test_fix_duplicate_eans
    doctor = flexmock('doctor', :ean13 => 'ean13')
    flexmock(@app, :doctors => {'id1' => doctor, 'id2' => doctor})
    flexmock(@plugin, :fix_doctors => 'fix_doctors')
    expected = {'ean13' => [doctor, doctor]}
    assert_equal(expected, @plugin.fix_duplicate_eans)
  end
end
