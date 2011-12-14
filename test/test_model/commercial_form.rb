#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestCommercialForm -- oddb.org -- 01.07.2003 -- hwyss@ywesee.com 

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'model/commercial_form'

module ODDB
  class TestCommercialForm < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      flexmock(ODBA.cache, :next_id => 123)
      @form = ODDB::CommercialForm.new
      pointer = flexmock('pointer', :append => 'append')
      @form.instance_eval('@pointer = pointer')
    end
    def test_init
      app = flexmock('app')
      assert_equal('append', @form.init(app))
    end
    def test_merge
      part    = flexmock('part', :commercial_form => 'commercial_form')
      package = flexmock('package', 
                         :parts => [part],
                         :odba_isolated_store => 'odba_isolated_store'
                        )
      other = flexmock('other', 
                       :packages => [package],
                       :all_descriptions => ['all_description']
                      )
      assert_equal(["all_description"], @form.merge(other))
    end
    def test_merge__commercial_form
      part    = flexmock('part')
      package = flexmock('package', 
                         :parts => [part],
                         :odba_isolated_store => 'odba_isolated_store'
                        )
      other = flexmock('other', 
                       :packages => [package],
                       :all_descriptions => ['all_description']
                      )
      flexmock(part, 
               :commercial_form  => other,
               :commercial_form= => nil,
               :odba_isolated_store => 'odba_isolated_store'
              )
      assert_equal(["all_description"], @form.merge(other))
    end

  end

end # ODDB
