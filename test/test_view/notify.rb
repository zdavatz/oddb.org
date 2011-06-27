#!/usr/bin/env ruby
# ODDB::View::TestNotify -- oddb.org -- 19.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/resulttemplate'
require 'view/notify'
require 'model/package'
require 'model/migel/product'
require 'view/migel/product'

module ODDB
  module View

class TestNotifyComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :_event_url => '_event_url',
                          :disabled?  => nil,
                          :base_url   => 'base_url'
                         )
    state      = flexmock('state', :passed_turing_test => 'passed_turing_test')
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :zone        => 'zone',
                          :state       => state,
                          :error       => 'error',
                          :warning?    => nil,
                          :error?      => nil
                         )
    item       = flexmock('item', :name => 'name')
    @model     = flexmock('model', 
                          :item => item,
                          :notify_recipient => ['notify_recipient']
                         )
    @composite = ODDB::View::NotifyComposite.new(@model, @session) 
  end
  def test_notify_title
    assert_equal('lookupname', @composite.notify_title(@model, @session))
  end
  def test_notify_title__zone_migel
    flexmock(@session, :zone => :migel)
    assert_equal('lookupname', @composite.notify_title(@model, @session))
  end
end

class TestNotifyInnerComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    generate_challenge = flexmock('generate_challenge', 
                                  :file => 'file',
                                  :id   => 'id'
                                 )
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :generate_challenge => generate_challenge,
                          :resource   => 'resource'
                         )
    state      = flexmock('state', :passed_turing_test => nil)
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :state       => state,
                          :error       => 'error',
                          :warning?    => nil,
                          :error?      => nil
                         )
    @model     = flexmock('model', :notify_recipient => ['notify_recipient'])
    @composite = ODDB::View::NotifyInnerComposite.new(@model, @session)
  end
  def test_init
    assert_nil(@composite.init)
  end
end

class TestNotifyMail < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf      = flexmock('lookandfeel', 
                         :lookup     => 'lookup',
                         :attributes => {},
                         :enabled?   => nil,
                         :disabled?  => nil,
                         :_event_url => '_event_url'
                        )
    @session  = flexmock('session', 
                         :lookandfeel => @lnf,
                         :error       => 'error'
                        )
    item      = flexmock('item', :name => 'name')
    @model    = flexmock('model', :item => item)
    @template = ODDB::View::NotifyMail.new(@model, @session)
  end
  def test_notify_item__package
    flexmock(ODBA.cache, :next_id => 123)
    package = ODDB::Package.new('ikscd')
    flexmock(package, :name_base => 'name_base')
    flexmock(@model, :item => package)
    assert_kind_of(ODDB::View::Drugs::PackageInnerComposite, @template.notify_item(@model))
  end
  def test_notify_item__migel_product
    flexmock(@session, :language => 'language')
    flexmock(ODBA.cache, :next_id => 123)
    product = ODDB::Migel::Product.new('code')
    flexmock(product, :language => 'language')
    group   = flexmock('group', 
                       :pointer  => 'pointer',
                       :language => 'language'
                      )
    product.subgroup = flexmock('subgroup', 
                                :migel_code => 'migel_code',
                                :group      => group,
                                :pointer    => 'pointer',
                                :language   => 'language'
                               )
    flexmock(@model, :item => product)
    assert_kind_of(ODDB::View::Migel::ProductInnerComposite, @template.notify_item(@model))
  end

end

  end # View
end # ODDB
