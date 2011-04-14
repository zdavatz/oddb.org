#!/usr/bin/env ruby
# ODDB::View::User::TestDownloadExport -- oddb.org -- 14.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../../', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'htmlgrid/list'
require 'htmlgrid/pass'
require 'view/user/register_download'

module ODDB
  module View
    module User
      class StubRegisterDownloadForm < RegisterDownloadForm
        def hash_insert_row(a,b,c)
        end
      end
    end
  end
end

module ODDB
  module View
    module User

class TestRegisterDownloadForm < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :attributes => {},
                        :_event_url => '_event_url',
                        :lookup     => 'lookup',
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :logged_in?  => nil,
                        :user        => 'user',
                        :error       => 'error',
                        :error?      => nil
                       )
    @model   = flexmock('model')
    @form    = ODDB::View::User::StubRegisterDownloadForm.new(@model, @session)
  end
  def test_init
    assert_nil(@form.init)
  end
  def test_init__session_error
    flexmock(@session) do |s|
      s.should_receive(:error?).and_return(true)
    end
    form = ODDB::View::User::StubRegisterDownloadForm.new(@model, @session)
    assert_kind_of(ODDB::View::User::StubRegisterDownloadForm, form)
  end
  def test_hidden_fields
    flexmock(@session, 
             :state      => 'state',
             :zone       => 'zone',
             :user_input => 'user_input'
            )
    flexmock(@lnf, 
             :flavor => 'flavor',
             :language => 'language'
            )
    context = flexmock('context', :hidden => 'hidden')
    assert_equal('hiddenhiddenhiddenhiddenhiddenhiddenhidden', @form.hidden_fields(context))
  end
end

class TestRegisterDownloadComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def test_register_download_form
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :_event_url => '_event_url',
                          :disabled?  => nil,
                          :base_url   => 'base_url',
                          :format_price => 1.23
                         )
    state      = flexmock('state', :currency => 'CHF')
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :zone        => 'zone',
                          :persistent_user_input => 'persistent_user_input',
                          :logged_in?  => true,
                          :event       => 'event',
                          :state       => state,
                          :user        => 'user'
                         )
    item       = flexmock('item', 
                          :quantity => 1.0,
                          :text     => 'text',
                          :total_netto => 12.34,
                          :vat      => 2.0,
                          :total_brutto => 1.234
                         )
    @model     = flexmock('model', :items => [item])
    flexmock(RegisterDownloadForm, :new => 'register_download_form')
    @composite = ODDB::View::User::RegisterDownloadComposite.new(@model, @session)
    assert_equal('register_download_form', @composite.register_download_form(@model))
  end
end

    end # User
  end # View
end # ODDB
