#!/usr/bin/env ruby
# ODDB::View::Companies::TestMergeCompanies -- oddb.org -- 28.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/companies/mergecompanies'


module ODDB
  module View
    module Companies

class TestMergeCompaniesForm < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :warning?    => nil,
                        :error?      => nil
                       )
    @model   = flexmock('model')
    @form    = ODDB::View::Companies::MergeCompaniesForm.new(@model, @session)
  end
  def test_init
    assert_equal(nil, @form.init)
  end
end

class TestMergeCompaniesComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :base_url   => 'base_url'
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :error       => 'error',
                          :warning?    => nil,
                          :error?      => nil
                         )
    @model     = flexmock('model', :registration_count => 0)
    @composite = ODDB::View::Companies::MergeCompaniesComposite.new(@model, @session)
  end
  def test_merge_companies
    assert_equal('lookup', @composite.merge_companies(@model, @session))
  end
end

    end # Companies
  end # View
end # ODDB
