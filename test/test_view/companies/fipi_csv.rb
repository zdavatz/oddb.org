#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Companies::TestFiPiCsv -- oddb.org -- 23.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/companies/fipi_csv.rb'


module ODDB
  module View
    module Companies

class TestFiPiCsv <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', :lookup => 'lookup')
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :language    => 'language'
                         )
    @package   = flexmock('package', :key => 'key')
    @model     = flexmock('model', 
                          :name => 'name',
                          :fi_count => 0,
                          :pi_count => 0,
                          :packages => [@package]
                         )
    @component = ODDB::View::Companies::FiPiCsv.new(@model, @session)
  end
  def test_http_headers
    expected = {
       "Content-Disposition"=>"attachment;filename=name.csv",
       "Content-Type"=>"text/csv"
    }
    assert_equal(expected, @component.http_headers)
  end
  def test_to_csv
    expected = "lookup;0\nlookup;0\nlookup\nkey\n"
    assert_equal(expected, @component.to_csv(['key']))
  end
  def test_to_csv__keys
    flexmock(@component, :key => 'item')
    expected = "lookup;0\nlookup;0\nlookup\nitem\n"
    assert_equal(expected, @component.to_csv(['key']))
  end
  class StubSimpleLanguage
    include SimpleLanguage
    def language
      'language'
    end
  end
  def test_to_csv__simplelanguage
    flexmock(ODBA.cache, :next_id => 123)
    flexmock(@component, :key => StubSimpleLanguage.new)
    expected = "lookup;0\nlookup;0\nlookup\nlanguage\n"
    assert_equal(expected, @component.to_csv(['key']))
  end
  def test_to_csv__htmlgridvalue
    flexmock(@component, :key => HtmlGrid::Value.new('name', @model, @session))
    expected = "lookup;0\nlookup;0\nlookup\n\"\"\n"
    assert_equal(expected, @component.to_csv(['key']))
  end
  def test_to_html
    commercial_form = flexmock('commercial_form', :language => 'language')
    part = flexmock('part', 
                    :multi => 'multi',
                    :count => 'count',
                    :measure => 'measure',
                    :commercial_form => commercial_form
                   )
    fachinfo = flexmock('fachinfo', 
                        :iksnrs => ['iksnr'],
                        :descriptions => {'key' => 'description'}
                       )
    patinfo  = flexmock('patinfo', :descriptions => {})
    flexmock(@package, 
             :name_base    => 'name_base',
             :galenic_form => 'galenic_form',
             :dose => 'dose',
             :commercial_forms => ['commercial_form'],
             :parts => [part],
             :barcode => 'barcode',
             :fachinfo => fachinfo,
             :patinfo  => patinfo
            )
    expected = "lookup;0\nlookup;0\nlookup;lookup;lookup;lookup;lookup;lookup;lookup;lookup;lookup;lookup\nname_base;galenic_form;dose;\"language &agrave; measure\";barcode;iksnr;\"\";\"\";\"\";\"\"\n"
    assert_equal(expected, @component.to_html('context'))
  end

end


    end # Companies
  end # View
end # ODDB
