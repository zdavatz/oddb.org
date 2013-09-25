#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::TestPatent -- oddb.org -- 20.04.2011 -- mhatakeyama@ywesee.com

#$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/admin/patent'

=begin
module ODDB
  module View
    module Admin
=end
class TestPatentInnerComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {}
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :error       => 'error'
                         )
    @model     = flexmock('model', 
                          :certificate_number => 'certificate_number',
                          :base_patent => 'base_patent'
                         )
    @composite = ODDB::View::Admin::PatentInnerComposite.new(@model, @session)
  end
  def test_base_patent_link
    assert_kind_of(HtmlGrid::Link, @composite.base_patent_link(@model, @session))
  end
end

class TestReadonlyPatentComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {}
                         )
    @app       = flexmock('app')
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :app   => @app,
                          :error => 'error'
                         )
    parent     = flexmock('parent', :name_base => 'name_base')
    @model     = flexmock('model', 
                          :parent      => parent,
                          :base_patent => 'base_patent',
                          :certificate_number => 'certificate_number'
                         )
    @composite = ODDB::View::Admin::ReadonlyPatentComposite.new(@model, @session)
  end
  def test_registration_name
    assert_equal('name_base&nbsp;-&nbsp;lookup', @composite.registration_name(@model, @session))
  end
end

class TestPatentComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :base_url   => 'base_url'
                         )
    @app       = flexmock('app')
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :app         => @app,
                          :error       => 'error',
                          :warning?    => nil,
                          :error?      => nil
                         )
    parent     = flexmock('parent', :name_base => 'name_base')
    @model     = flexmock('model', 
                          :parent      => parent,
                          :base_patent => 'base_patent',
                          :certificate_number => 'certificate_number'
                         )
    @composite = ODDB::View::Admin::PatentComposite.new(@model, @session)
  end
  def test_init
    assert_nil(@composite.init)
  end
end

=begin
    end # Admin
  end # View
end # ODDB

=end
