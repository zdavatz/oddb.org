#!/usr/bin/env ruby
# encoding: utf-8
# encodnig: utf-8
# ODDB::Veiw::TestSuggestAddress -- oddb.org -- 08.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/suggest_address'

module ODDB
  module View

    class TestSuggestAddressForm <Minitest::Test
      include FlexMock::TestCase
      def setup
        @lnf      = flexmock('lookandfeel', 
                             :lookup     => 'lookup',
                             :attributes => {},
                             :base_url   => 'base_url'
                            )
        @session  = flexmock('session', 
                             :lookandfeel => @lnf,
                             :error       => 'error',
                             :warning?    => nil,
                             :error?      => nil
                            )
        @parent    = flexmock('parent')
        @fax       = flexmock('fax', :join =>'join')
        @fon       = flexmock('fon', :join =>'join')
        flexmock(@parent, :resolve => @parent)
        pointer   = flexmock('pointer', :parent => @parent)
        @model    = flexmock('model', 
                             :pointer => pointer,
                             :fon    =>  @fon,
                             :fax    =>  @fax,
                             :name    => 'name',
                            )
        @form     = ODDB::View::SuggestAddressForm.new(@model, @session)
      end
      def test_init
        assert_nil(@form.init)
      end
      def test_email_suggestion
        flexmock(@parent, :email => 'email')
        assert_kind_of(HtmlGrid::InputText, @form.email_suggestion(@model))
      end
    end

    class TestSuggestAddressComposite <Minitest::Test
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
        @parent    = flexmock('parent', :fullname => 'fullname')
        flexmock(@parent, :resolve => @parent)
        pointer    = flexmock('pointer', :parent => @parent)
        @fax       = flexmock('fax', :join =>'join')
        @fon       = flexmock('fon', :join =>'join')
        @model     = flexmock('model', 
                              :pointer => pointer,
                              :fon    =>  @fon,
                              :fax    =>  @fax,
                              :name    => 'name'
                             )
        @composite = ODDB::View::SuggestAddressComposite.new(@model, @session)
      end
      def test_fullname
        assert_equal('fullname', @composite.fullname(@model))
      end
    end

  end # View
end # ODDB
