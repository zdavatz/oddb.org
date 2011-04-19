#!/usr/bin/env ruby
# ODDB::View::Drugs::TestDDD -- oddb.org -- 19.04.2011 -- mhatakeyama@ywesee.com

#$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/drugs/ddd'


module ODDB
  module View
    module Drugs

class TestDDDComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :event       => 'event'
                       )
    @model   = flexmock('model', 
                        :guidelines => 'guidelines',
                        :ddds       => {'key' => 'ddd'},
                        :ddd_guidelines => 'ddd_guidelines',
                        :code       => 'code',
                        :en         => 'en'
                       )
    @composite = ODDB::View::Drugs::DDDComposite.new(@model, @session)
  end
  def test_init
    assert_equal({}, @composite.init)
  end
end

class TestDDDTree < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    atc_class  = flexmock('atc_class', 
                          :has_ddd?    => nil,
                          :parent_code => nil
                         )
    @app       = flexmock('app', :atc_class => atc_class)
    @lnf       = flexmock('lookandfeel', 
                          :lookup      => 'lookup',
                          :enabled?    => nil,
                          :attributes  => {}
                         )
    @session   = flexmock('session', 
                          :app         => @app,
                          :lookandfeel => @lnf,
                          :event       => 'event'
                         )
    @model_org  = flexmock('model', 
                          :parent_code => 'code',
                          :code        => 'code',
                          :en          => 'en',
                          :guidelines  => 'guidelines',
                          :ddds        => {'key' => 'ddd'},
                          :ddd_guidelines => 'ddd_guidelines'
                         )
 
    @composite = ODDB::View::Drugs::DDDTree.new(@model_org, @session)
  end
  def test_init
  end
  def test_init
    @composite.instance_eval('@model = @model_org')
    assert_equal({}, @composite.init)
  end
end

    end # Drugs
  end # View
end # ODDB
