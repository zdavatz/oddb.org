#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::TestPackage -- oddb.org -- 06.12.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'htmlgrid/select'
require 'view/admin/package'
require 'htmlgrid/textarea'

class TestCompositionSelect < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @session = flexmock('session')
    @model   = flexmock('model')
    @select  = ODDB::View::Admin::CompositionSelect.new('name', @model, @session)
  end
  def test_selection
    composition  = flexmock('composition')
    registration = flexmock('registration', :compositions => [composition])
    flexmock(@model,   
             :composition   => composition,
             :registration  => registration
            )
    flexmock(@session, :language => 'language')

    context = flexmock('context', :option => 'option')
    assert_equal(['option'], @select.selection(context))
  end
  def test_shorten
    expected = 'c'*57 + '...'
    assert_equal(expected, @select.shorten('c'*70))
  end
end

class TestParts < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lookandfeel = flexmock('lookandfeel',
                            :lookup     => 'lookup',
                            :attributes => {},
                            :event_url  => 'event_url'
                           )
    @model = flexmock('model',
                     :multi => 'multi',
                     :count => 'count',
                     :commercial_form => 'commercial_form',
                     :measure => 'measure',
                     :pointer => 'pointer',
                     :iksnr   => 'iksnr',
                     :seqnr   => 'seqnr',
                     :ikscd   => 'ikscd'
                     )
    state = flexmock('state', :model => @model)
    @session = flexmock('session',
                        :lookandfeel => @lookandfeel,
                        :state => state
                       )
    @parts = ODDB::View::Admin::Parts.new([@model], @session)
  end
  def test_input_text
    flexmock(@model, :key => 'key')
    keys = [:key]
    ODDB::View::Admin::Parts.input_text(*keys)
    assert_kind_of(HtmlGrid::Input, @parts.key(@model))
  end
  def test_delete
    parts = ODDB::View::Admin::Parts.new([@model, @model], @session)
    assert_kind_of(HtmlGrid::Link, parts.delete(@model))
  end
end

class TestPackageForm < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lookandfeel = flexmock('lookandfeel', 
                            :lookup       => 'lookup',
                            :attributes   => {},
                            :format_price => 'format_price',
                            :_event_url   => '_event_url'
                           )
    @session = flexmock('session', 
                        :lookandfeel => @lookandfeel,
                        :error       => 'error',
                        :warning?    => nil,
                        :error?     => nil
                       )
    sl_entry = flexmock('sl_entry', :pointer => 'pointer')
    package = flexmock('package',
                        :generic_group_factor => 2.5,
                        :ikskey => 'ikskey'
                      )
    @model   = flexmock('model', 
                        :out_of_trade => 'out_of_trade',
                        :generic_group_factor => 1,
                        :sl_entry => sl_entry,
                        :generic_group_comparables => [package],
                        :iksnr => 'iksnr',
                        :seqnr => 'seqnr',
                        :ikscd => 'ikscd'
                       )
    @form = ODDB::View::Admin::PackageForm.new(@model, @session)
  end
  def test_init
    assert_equal(nil, @form.init)
  end
  def test_sl_entry
    flexmock(@model, :sl_entry => nil)
    flexmock(@lookandfeel, :event_url => nil)
    assert_kind_of(HtmlGrid::Link, @form.sl_entry(@model, @session))
  end
  def test_generic_group
    assert_kind_of(HtmlGrid::Textarea, @form.generic_group(@model, @session))
  end
end

class TestPackageComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lookandfeel = flexmock('lookandfeel', 
                            :disabled?  => nil,
                            :enabled?   => nil,
                            :attributes => {},
                            :lookup     => 'lookup'
                           )
    @app     = flexmock('app')
    @session = flexmock('session', 
                        :app         => @app,
                        :lookandfeel => @lookandfeel,
                        :error       => 'error'
                       )
    parent   = flexmock('parent', :name => 'name')
    @model   = flexmock('model',
                        :parent => parent,
                        :size   => 'size',
                        :price_exfactory => 'price_exfactory',
                        :price_public    => 'price_public'
                       )
    @composite = ODDB::View::Admin::PackageComposite.new(@model, @session)
  end
  def test_package_name
    expected = 'name&nbsp;-&nbsp;size'
    assert_equal(expected, @composite.package_name(@model, @session))
  end
  def test_source
    flexmock(@model, :swissmedic_source => 'swissmedic_source')
    assert_kind_of(HtmlGrid::Value, @composite.source(@model, @session))
  end
end

class TestRootPackageComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lookandfeel = flexmock('lookandfeel',
                            :attributes   => {},
                            :lookup       => 'lookup',
                            :format_price => 'format_price',
                            :event_url    => 'event_url',
                            :_event_url   => '_event_url',
                            :base_url     => 'base_url'
                           )
    @app     = flexmock('app')
    state    = flexmock('state')
    @session = flexmock('session', 
                        :app         => @app,
                        :lookandfeel => @lookandfeel,
                        :error       => 'error',
                        :warning?    => nil,
                        :error?      => nil,
                        :state       => state
                       )
    parent   = flexmock('parent', :name => 'name')
    package  = flexmock('package',
                        :ikskey => 'ikskey',
                        :generic_group_factor => 2.5
                      )
    sl_entry = flexmock('sl_entry', :pointer => 'pointer')
    part     = flexmock('part', 
                        :multi   => 'multi',
                        :count   => 'count',
                        :measure => 'measure',
                        :commercial_form => 'commercial_form'
                       )
    @model   = flexmock('model',
                        :parent       => parent,
                        :size         => 'size',
                        :out_of_trade => 'out_of_trade',
                        :sl_entry     => sl_entry,
                        :parts        => [part],
                        :pointer      => 'pointer',
                        :generic_group_factor => 1,
                        :generic_group_comparables => [package],
                        :swissmedic_source => 'swissmedic_source',
                        :iksnr        => 'iksnr',
                        :seqnr        => 'seqnr',
                        :ikscd        => 'ikscd'
                       )
    flexmock(state, :model => @model)
    @composite = ODDB::View::Admin::RootPackageComposite.new(@model, @session)
  end
  def test_init
    expected = {
      "ACCEPT-CHARSET"=>"UTF-8",
      "NAME"=>"stdform",
      "METHOD"=>"POST",
      "ACTION"=>"base_url"
    }
    assert_equal(expected, @composite.init)
  end
end

class TestDeductiblePackageComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def test_source
    @lookandfeel = flexmock('lookandfeel', 
                            :attributes => {},
                            :disabled?  => nil,
                            :enabled?   => nil,
                            :lookup     => 'lookup',
                            :event_url  => 'event_url',
                            :base_url   => 'base_url'
                           )
    @app       = flexmock('app')
    state      = flexmock('state')
    @session   = flexmock('session',
                         :app   => @app,
                         :error => nil,
                         :state => state,
                         :lookandfeel => @lookandfeel
                         )
    parent     = flexmock('parent', :name => 'name')
    part       = flexmock('part',
                         :multi   => 'multi',
                         :count   => 'count',
                         :measure => 'measure',
                         :commercial_form => 'commercial_form'
                         )
    @model     = flexmock('model',
                         :parent   => parent,
                         :size     => 'size',
                         :parts    => [part],
                         :pointer  => 'pointer',
                         :sequence => 'sequence',
                         :price_public    => 'price_public',
                         :price_exfactory => 'price_exfactory',
                         :iksnr   => 'iksnr',
                         :seqnr   => 'seqnr',
                         :ikscd   => 'ikscd'
                         )
    flexmock(state, :model => @model)
    @composite = ODDB::View::Admin::DeductiblePackageComposite.new(@model, @session)
    assert_kind_of(HtmlGrid::Value, @composite.source(@model, @session))
  end
end
