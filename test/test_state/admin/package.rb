#!/usr/bin/env ruby
# ODDB::State::Admin::TestPackage -- oddb.org -- 04.05.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/admin/package'
require 'flexmock'
require 'state/global'
require 'model/commercial_form'

module ODDB
  module State
    module Admin

class TestPackage < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @session = flexmock('session')
    @model   = flexmock('model')
    @state   = ODDB::State::Admin::Package.new(@session, @model)
  end
  def test_check_model
    flexmock(@model, :pointer => 'pointer')
    flexmock(@session, :user_input => 'pointer')
    flexmock(@state, :allowed? => true)
    assert_equal(nil, @state.check_model)
  end
  def test_check_model__e_state_expired
    flexmock(@model, :pointer => 'pointer')
    flexmock(@session, :user_input => 'xxx')
    flexmock(@state, :allowed? => true)
    assert_kind_of(SBSM::ProcessingError, @state.check_model)
  end
  def test_check_model__e_not_allowed
    flexmock(@model, :pointer => 'pointer')
    flexmock(@session, :user_input => 'pointer')
    flexmock(@state, :allowed? => false)
    assert_kind_of(SBSM::ProcessingError, @state.check_model)
  end
  def test_ajax_create_part
    pointer = flexmock('pointer')
    flexmock(pointer, :+ => pointer)
    flexmock(@model, 
             :pointer      => pointer,
             :parts        => [],
             :registration => 'registration'
            )
    flexmock(@session, :user_input => pointer)
    flexmock(@state, :allowed? => true)

    assert_kind_of(ODDB::State::Admin::AjaxParts, @state.ajax_create_part)
  end
  def test_ajax_delete_part
    input = {:part => 123, :pointer => 'pointer'}
    value = flexmock('value', :pointer => nil)
    flexmock(@model, 
             :pointer => input,
             :parts   => {123 => value}
            )
    flexmock(@session, 
             :user_input   => input,
             :"app.delete" => nil
            )
    flexmock(@state, :allowed? => true)

    assert_kind_of(ODDB::State::Admin::AjaxParts, @state.ajax_delete_part)
  end
  def test_delete
    flexmock(@session, :"app.delete" => nil)
    pointer  = flexmock('pointer', :skeleton => [:company])
    sequence = flexmock('sequence', :pointer => pointer)
    flexmock(@model, 
             :parent  => sequence,
             :pointer => pointer
            )
    assert_kind_of(ODDB::State::Companies::Company, @state.delete)
  end
  def test_update_parts
    part   = flexmock('part', :pointer => 'pointer')
    flexmock(@session, 
             :"app.update" => 'update',
             :user         => 'user'
            )
    composition  = flexmock('composition', :pointer => 'pointer')
    registration = flexmock('registration', :compositions => [composition])
    flexmock(@model, 
             :parts   => [part],
             :pointer => 'pointer',
             :registration => registration
            )
    counts = {'0' => '123'}
    #input  = {:count => counts, :composition => {'0' => '0'}, :commercial_form => {'0' => 'name'}}
    input  = {:count => counts, :composition => {'0' => '0'}}
    assert_equal(counts, @state.update_parts(input))
  end
  def test_update_parts__comfirms
    part   = flexmock('part', :pointer => 'pointer')
    flexmock(@session, 
             :"app.update" => 'update',
             :user         => 'user'
            )
    composition  = flexmock('composition', :pointer => 'pointer')
    registration = flexmock('registration', :compositions => [composition])
    flexmock(@model, 
             :parts   => [part],
             :pointer => 'pointer',
             :registration => registration
            )
    confirm = flexmock('confirm', :pointer => 'pointer')
    flexmock(ODDB::CommercialForm, :find_by_name => confirm)
    counts = {'0' => '123'}
    input  = {:count => counts, :composition => {'0' => '0'}, :commercial_form => {'0' => 'name'}}
    assert_equal(counts, @state.update_parts(input))
  end
  def test_update_parts__name_empty
    part   = flexmock('part', :pointer => 'pointer')
    flexmock(@session, 
             :"app.update" => 'update',
             :user         => 'user'
            )
    composition  = flexmock('composition', :pointer => 'pointer')
    registration = flexmock('registration', :compositions => [composition])
    flexmock(@model, 
             :parts   => [part],
             :pointer => 'pointer',
             :registration => registration
            )
    counts = {'0' => '123'}
    input  = {:count => counts, :composition => {'0' => '0'}, :commercial_form => {'0' => ''}}
    assert_equal(counts, @state.update_parts(input))
  end
  def test_update_parts__confirms_else
    part   = flexmock('part', :pointer => 'pointer')
    flexmock(@session, 
             :"app.update" => 'update',
             :user         => 'user'
            )
    composition  = flexmock('composition', :pointer => 'pointer')
    registration = flexmock('registration', :compositions => [composition])
    flexmock(@model, 
             :parts   => [part],
             :pointer => 'pointer',
             :registration => registration
            )
    flexmock(ODDB::CommercialForm, :find_by_name => nil)
    counts = {'0' => '123'}
    input  = {:count => counts, :composition => {'0' => '0'}, :commercial_form => {'0' => 'name'}}
    assert_equal(counts, @state.update_parts(input))
  end
  def test_update
    parent  = flexmock('parent', :package => nil)
    package = flexmock('package', :pointer => 'pointer')
    generic_group = flexmock('generic_group', 
                             :pointer  => 'pointer',
                             :packages => [package]
                            )
    flexmock(@model, 
             :parent        => parent,
             :ikscd         => 'ikscd',
             :ikscd=        => nil,
             :pointer       => 'pointer',
             :galenic_form  => 'galenic_form',
             :generic_group => generic_group
            ) 
    @app = flexmock('app', :update => @model)
    flexmock(@session, 
             :user_input => 'ikscode',
             :app        => @app,
             :user       => 'user'
            )
    assert_kind_of(ODDB::State::Admin::Package, @state.update)
  end
  def test_update__price
    parent  = flexmock('parent', :package => nil)
    package = flexmock('package', :pointer => 'pointer')
    generic_group = flexmock('generic_group', 
                             :pointer  => 'pointer',
                             :packages => [package]
                            )
    flexmock(@model, 
             :parent        => parent,
             :ikscd         => 'ikscd',
             :ikscd=        => nil,
             :pointer       => 'pointer',
             :galenic_form  => 'galenic_form',
             :generic_group => generic_group
            ) 
    @app = flexmock('app', :update => @model)
    flexmock(@session, 
             :app        => @app,
             :user       => 'user'
            )
		keys = [
      :ddd_dose,
			:deductible,
			:descr,
      :disable,
      :disable_ddd_price,
			:ikscat,
			:market_date,
      :pharmacode,
			:pretty_dose,
      :preview_with_market_date,
			:price_exfactory,
			:price_public,
      :photo_link,
			:refdata_override,
			:lppv,
		]
    user_input = {:price_public => 'price_public'}
    flexmock(@session) do |s|
      s.should_receive(:user_input).with(:ikscd).and_return('ikscode')
      s.should_receive(:user_input).with(*keys).and_return(user_input)
      s.should_receive(:user_input).with_any_args.and_return('user_input')
    end
    assert_kind_of(ODDB::State::Admin::Package, @state.update)
  end
  def test_update__group_nil
    parent  = flexmock('parent', :package => nil)
    package = flexmock('package', :pointer => 'pointer')
    generic_group = flexmock('generic_group', 
                             :pointer  => 'pointer',
                             :packages => [package]
                            )
    flexmock(@model, 
             :parent        => parent,
             :ikscd         => 'ikscd',
             :ikscd=        => nil,
             :pointer       => 'pointer',
             :galenic_form  => 'galenic_form',
             :generic_group => nil
            ) 
    @app = flexmock('app', :update => @model)
    flexmock(@session, 
             :user_input => 'ikscode',
             :app        => @app,
             :user       => 'user',
             :create     => generic_group
            )
    assert_kind_of(ODDB::State::Admin::Package, @state.update)
  end
  def test_update__group_scan
    parent  = flexmock('parent', :package => nil)
    package = flexmock('package', :pointer => 'pointer')
    generic_group = flexmock('generic_group', 
                             :pointer  => 'pointer',
                             :packages => [package]
                            )
    flexmock(@model, 
             :parent        => parent,
             :ikscd         => 'ikscd',
             :ikscd=        => nil,
             :pointer       => 'pointer',
             :galenic_form  => 'galenic_form',
             :generic_group => generic_group
            ) 
    @app = flexmock('app', :update => @model)
    flexmock(@session, 
             :app        => @app,
             :user       => 'user',
             :package_by_ikskey => package
            )
    flexmock(@session) do |s|
      s.should_receive(:user_input).with(:generic_group).and_return('12345678 12 x')
      s.should_receive(:user_input).with_any_args.and_return('ikscode')
    end
    assert_kind_of(ODDB::State::Admin::Package, @state.update)
  end

  def test_update__create_item
    parent  = flexmock('parent', :package => nil)
    package = flexmock('package', :pointer => 'pointer')
    generic_group = flexmock('generic_group', 
                             :pointer  => 'pointer',
                             :packages => [package]
                            )
    flexmock(@model, 
             :parent        => parent,
             :ikscd         => 'ikscd',
             :ikscd=        => nil,
             :pointer       => 'pointer',
             :galenic_form  => 'galenic_form',
             :generic_group => generic_group,
             :is_a?         => true,
             :append        => nil,
             :carry         => nil
            ) 
    @app = flexmock('app', 
                    :update => @model,
                    :create => @model
                   )
    flexmock(@session, 
             :user_input => 'ikscode',
             :app        => @app,
             :user       => 'user'
            )
    assert_kind_of(ODDB::State::Admin::Package, @state.update)
  end
  def test_update__runtime_error
    parent  = flexmock('parent', :package => nil)
    package = flexmock('package', :pointer => 'pointer')
    generic_group = flexmock('generic_group', 
                             :pointer  => 'pointer',
                             :packages => [package]
                            )
    flexmock(@model, 
             :parent        => parent,
             :ikscd         => 'ikscd',
             :ikscd=        => nil,
             :pointer       => 'pointer',
             :galenic_form  => 'galenic_form',
             :generic_group => generic_group
            ) 
    @app = flexmock('app', :update => @model)
    flexmock(@session, 
             :app        => @app,
             :user       => 'user'
            )
    flexmock(@session) do |s|
      s.should_receive(:user_input).with(:ikscd).and_return(RuntimeError.new)
    end
    assert_kind_of(ODDB::State::Admin::Package, @state.update)
  end
  def test_update__e_missing_ikscd
    parent  = flexmock('parent', :package => nil)
    package = flexmock('package', :pointer => 'pointer')
    generic_group = flexmock('generic_group', 
                             :pointer  => 'pointer',
                             :packages => [package]
                            )
    flexmock(@model, 
             :parent        => parent,
             :ikscd         => 'ikscd',
             :ikscd=        => nil,
             :pointer       => 'pointer',
             :galenic_form  => 'galenic_form',
             :generic_group => generic_group
            ) 
    @app = flexmock('app', :update => @model)
    flexmock(@session, 
             :user_input => '',
             :app        => @app,
             :user       => 'user'
            )
    assert_kind_of(ODDB::State::Admin::Package, @state.update)
  end
  def test_update__e_dupulicate_ikscd
    package = flexmock('package', :pointer => 'pointer')
    parent  = flexmock('parent', :package => package)
    generic_group = flexmock('generic_group', 
                             :pointer  => 'pointer',
                             :packages => [package]
                            )
    flexmock(@model, 
             :parent        => parent,
             :ikscd         => 'ikscd',
             :ikscd=        => nil,
             :pointer       => 'pointer',
             :galenic_form  => 'galenic_form',
             :generic_group => generic_group
            ) 
    @app = flexmock('app', :update => @model)
    flexmock(@session, 
             :user_input => 'ikscode',
             :app        => @app,
             :user       => 'user'
            )
    assert_kind_of(ODDB::State::Admin::Package, @state.update)
  end
  def test_update__error_create_item
    parent  = flexmock('parent', :package => nil)
    package = flexmock('package', :pointer => 'pointer')
    generic_group = flexmock('generic_group', 
                             :pointer  => 'pointer',
                             :packages => [package]
                            )
    flexmock(@model, 
             :parent        => parent,
             :ikscd         => 'ikscd',
             :ikscd=        => nil,
             :pointer       => 'pointer',
             :galenic_form  => 'galenic_form',
             :generic_group => generic_group,
             :is_a?         => true,
             :carry         => nil
            ) 
    @app = flexmock('app', :update => @model)
    flexmock(@session, 
             :user_input => '',
             :app        => @app,
             :user       => 'user'
            )
    assert_kind_of(ODDB::State::Admin::Package, @state.update)
  end

  def test_new_item
    flexmock(@model, :pointer => [])
    assert_kind_of(ODDB::State::Admin::SlEntry, @state.new_item)
  end
end

class TestCompanyPackage < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @session = flexmock('session')
    @model   = flexmock('model')
    @state   = ODDB::State::Admin::CompanyPackage.new(@session, @model)
  end
  def test_init
    flexmock(@session, :allowed? => nil)
    assert_equal(ODDB::View::Admin::Package, @state.init)
  end
  def test_delete
    flexmock(@session, 
             :allowed? => true,
             :"app.delete" => nil
            )
    pointer  = flexmock('pointer', :skeleton => [:company])
    sequence = flexmock('sequence', :pointer => pointer)
    flexmock(@model, 
             :parent  => sequence,
             :pointer => pointer
            )
    assert_kind_of(ODDB::State::Companies::Company, @state.delete)
  end
  def test_new_item
    flexmock(@session, :allowed? => true)
    flexmock(@model, :pointer => [])
    assert_kind_of(ODDB::State::Admin::SlEntry, @state.new_item)
  end
  def test_update
    parent  = flexmock('parent', :package => nil)
    package = flexmock('package', :pointer => 'pointer')
    generic_group = flexmock('generic_group', 
                             :pointer  => 'pointer',
                             :packages => [package]
                            )
    flexmock(@model, 
             :parent        => parent,
             :ikscd         => 'ikscd',
             :ikscd=        => nil,
             :pointer       => 'pointer',
             :galenic_form  => 'galenic_form',
             :generic_group => generic_group
            ) 
    @app = flexmock('app', :update => @model)
    flexmock(@session, 
             :user_input => 'ikscode',
             :app        => @app,
             :user       => 'user',
             :allowed? => true
            )
    assert_kind_of(ODDB::State::Admin::CompanyPackage, @state.update)
  end
end

class TestDeductiblePackage < Test::Unit::TestCase
  include FlexMock::TestCase
  def test_update
    @session = flexmock('session', 
                        :user_input   => 'user_input',
                        :"app.update" => nil
                       )
    @model   = flexmock('model')
    @state   = ODDB::State::Admin::DeductiblePackage.new(@session, @model)
    assert_equal(@state, @state.update)
  end
end
    end # Admin
  end # State
end # ODDB
