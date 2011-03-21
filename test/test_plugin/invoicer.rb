#!/usr/bin/env ruby
# TestInvoicer -- oddb.org -- 21.03.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'plugin/invoicer'
require 'util/persistence'
require 'yus/entity'
require 'plugin/ydim'
require 'util/log'
require 'util/today'

class TestInvoicer < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app      = flexmock('app')
    @invoicer = ODDB::Invoicer.new(@app)
  end
  def test_create_invoice
    pointer = flexmock('pointer')
    flexmock(pointer, 
             :+       => pointer,
             :dup     => pointer,
             :creator => nil
            )

    invoice = flexmock('invoice', :pointer => pointer)
    flexmock(@app,
             :update => invoice
            )
    flexmock(ODDB::Persistence::Pointer).new_instances do |p|
      p.should_receive(:creator)
    end
    item = {'key' => 'value'}
    assert_equal([item], @invoicer.create_invoice('email', [item], 'ydim_id'))
  end
  def test_ensure_yus_user
    flexmock(@app) do |a|
      a.should_receive(:yus_create_user).and_raise(Yus::YusError)
    end
    pointer      = flexmock('pointer', :to_yus_privilege => 'to_yus_privilege')
    comp_or_hosp = flexmock('comp_or_hosp', :invoice_email => 'invoice_email')
    assert_equal('invoice_email', @invoicer.ensure_yus_user(comp_or_hosp))
  end
  def test_ensure_yus_user__error
    flexmock(@app,
             :yus_create_user => nil,
             :yus_grant       => nil,
             :yus_set_preference => nil
            )
    pointer      = flexmock('pointer', :to_yus_privilege => 'to_yus_privilege')
    comp_or_hosp = flexmock('comp_or_hosp', 
                            :invoice_email => 'invoice_email',
                            :pointer       => pointer
                           )
    assert_equal('invoice_email', @invoicer.ensure_yus_user(comp_or_hosp))
  end
  def test_resend_invoice
    flexmock(ODDB::YdimPlugin).new_instances do |y|
      y.should_receive(:send_invoice).and_return('send_invoice')
    end
    invoice = flexmock('invoice', :ydim_id => 'ydim_id')
    assert_equal('send_invoice', @invoicer.resend_invoice(invoice, Time.local(2011,2,3)))
  end
  def test_rp2fr
    assert_in_delta(1.234, @invoicer.rp2fr(123.4), 0.01)
  end
  def test_send_invoice
    ydim_inv = flexmock('ydim_inv', :unique_id => 'ydim_id')
    flexmock(ODDB::YdimPlugin).new_instances do |y|
      y.should_receive(:inject_from_items).and_return(ydim_inv)
      y.should_receive(:send_invoice).and_return('send_invoice')
    end
    assert_equal('ydim_id', @invoicer.send_invoice('date', 'mail', 'items'))
  end
  def test_send_invoice__error
    flexmock(ODDB::YdimPlugin).new_instances do |y|
      y.should_receive(:inject_from_items).and_raise(StandardError)
    end
    flexmock(ODDB::Log).new_instances do |l|
      l.should_receive(:report)
      l.should_receive(:notify).and_return('notify')
    end
    def @invoicer.subject; end
    assert_equal(nil, @invoicer.send_invoice('date', 'mail', ['item']))
  end


end

