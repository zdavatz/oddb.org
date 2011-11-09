#!/usr/bin/env ruby
# encodnig: utf-8
# ODDB::Veiw::TestSuggestAddress -- oddb.org -- 08.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/suggest_address'

module ODDB
  module View

    class TestSuggestAddressForm < Test::Unit::TestCase
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
        flexmock(@parent, :resolve => @parent)
        pointer   = flexmock('pointer', :parent => @parent)
        @model    = flexmock('model', 
                             :pointer => pointer,
                             :name    => 'name'
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

    class TestSuggestAddressComposite < Test::Unit::TestCase
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
        @model     = flexmock('model', 
                              :pointer => pointer,
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
