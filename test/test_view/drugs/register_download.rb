#!/usr/bin/env ruby
# ODDB::View::Drugs::TestRegisterDownload -- oddb.org -- 18.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'htmlgrid/pass'
require 'view/drugs/register_download'

module ODDB
  module View
    module Drugs
      class StubRegisterDownloadForm < RegisterDownloadForm
        def hash_insert_row(a,b,c)
        end
      end
    end
  end
end

module ODDB
  module View
    module Drugs

class TestRegisterDownloadForm < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url',
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
    @form    = ODDB::View::Drugs::StubRegisterDownloadForm.new(@model, @session)
  end
  def test_init
    flexmock(@session, :error? => true)
    assert_equal('processingerror', @form.init)
  end
  def test_hidden_fields
    flexmock(@lnf, 
             :flavor   => 'flavor',
             :language => 'language'
            )
    state = flexmock('state', 
                     :search_query => 'search_query',
                     :search_type  => 'search_type'
                    )
    flexmock(@session, 
             :state => state,
             :zone  => 'zone'
            )
    context = flexmock('context', :hidden => 'hidden')
    assert_equal('hiddenhiddenhiddenhiddenhiddenhiddenhidden', @form.hidden_fields(context))
  end
end

class TestRegisterInvoicedDownloadForm < Test::Unit::TestCase
  include FlexMock::TestCase
  def test_submit
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @form = ODDB::View::Drugs::RegisterInvoicedDownloadForm.new(@model, @session)
    assert_kind_of(HtmlGrid::Submit, @form.submit(@model, @session))
  end
end

class TestRegisterInvoicedDownloadComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url',
                        :disabled?  => nil,
                        :base_url   => 'base_url',
                        :format_price => 'format_price'
                       )
    user     = flexmock('user', :unique_email => 'unique_email')
    state    = flexmock('state', :currency => 'CHF')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :zone        => 'zone',
                        :user        => user,
                        :event       => 'event',
                        :state       => state,
                        :persistent_user_input => 'persistent_user_input'
                       )
    item     = flexmock('item', 
                        :quantity => 1,
                        :text     => 'text',
                        :vat      => 1.0,
                        :total_netto  => 1.23,
                        :total_brutto => 2.34
                       )
    @model   = flexmock('model', 
                        :items => [item],
                        :text  => 'text'
                       )
    @form = ODDB::View::Drugs::RegisterInvoicedDownloadComposite.new(@model, @session)
  end
  def test_invoice_descr
    assert_equal('lookup', @form.invoice_descr(@model))
  end
  def test_invoice_descr__before_15th
    today = Date.new(2011,2,3)
    today_bak = @form.instance_eval('@@today')
    @form.instance_eval('@@today = today')
    assert_equal('lookup', @form.invoice_descr(@model))
    @form.instance_eval('@@today = today_bak')
  end

end

    end # Drugs
  end # View
end # ODDB
