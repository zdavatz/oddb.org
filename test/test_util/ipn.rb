#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Util::TestIpn -- oddb.org -- 04.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))
$: << File.expand_path("..", File.dirname(__FILE__))
require 'pp'
gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'util/ipn'
require 'util/session'
require 'tempfile'
require 'tmail'
require 'stub/config'

module ODDB
  module Util
    module Ipn

class TestIpn <Minitest::Test
  include FlexMock::TestCase

  def test_lookandfeel_stub
    assert_kind_of(ODDB::LookandfeelBase, ODDB::Util::Ipn.lookandfeel_stub)
  end
  def test_send_notification
    smtp = flexmock('smtp', :sendmail => 'sendmail')
    flexmock(Net::SMTP) do |s|
      s.should_receive(:start).and_yield(smtp)
    end
    tmail = flexmock('tmail') do |m|
      m.should_receive(:set_content_type)
      m.should_receive(:to=)
      m.should_receive(:from=)
      m.should_receive(:date=)
      m.should_receive(:[]=)
      m.should_receive(:encoded)
    end
    flexmock(TMail::Mail, :new => tmail)
    invoice = flexmock('invoice', :yus_name => 'yus_name')
    config = flexmock('config', 
                      :smtp_server   => nil,
                      :smtp_port     => nil,
                      :smtp_domain   => nil,
                      :smtp_user     => nil,
                      :smtp_pass     => nil,
                      :smtp_authtype => nil
                     )
    flexmock(ODDB::Util::Ipn) do |i|
      i.should_receive(:config).and_return(config)
    end
    result  = ODDB::Util::Ipn.send_notification(invoice) do
      'send_notification'
    end
    assert_equal('sendmail', result)
  end
  def test_send_notification__error
    smtp = flexmock('smtp', :sendmail => 'sendmail')
    flexmock(Net::SMTP) do |s|
      s.should_receive(:start).and_yield(smtp)
    end
    tmail = flexmock('tmail') do |m|
      m.should_receive(:set_content_type)
      m.should_receive(:to=)
      m.should_receive(:from=)
      m.should_receive(:date=)
      m.should_receive(:[]=)
      m.should_receive(:encoded)
    end
    flexmock(TMail::Mail, :new => tmail)
    invoice = flexmock('invoice', :yus_name => 'yus_name')
    $stdout = Tempfile.new('tempfile')
    result  = ODDB::Util::Ipn.send_notification(invoice) do
      'send_notification'
    end
    assert_equal(nil, result)
    $stdout = STDOUT
  end
  def test_send_notification__nil
    invoice = flexmock('invoice', :yus_name => nil)
    assert_equal(nil, ODDB::Util::Ipn.send_notification(invoice){})
  end
  def test_send_poweruser_notification
    smtp = flexmock('smtp', :sendmail => 'sendmail')
    flexmock(Net::SMTP) do |s|
      s.should_receive(:start).and_yield(smtp)
    end
    outgoing = flexmock('outgoing') do |m|
      m.should_receive(:set_content_type)
      m.should_receive(:to=)
      m.should_receive(:from=)
      m.should_receive(:date=)
      m.should_receive(:[]=)
      m.should_receive(:encoded)
      m.should_receive(:subject=)
      m.should_receive(:body=).and_return('body')
    end
    flexmock(TMail::Mail, :new => outgoing)
    item    = flexmock('item', :duration => 1)
    invoice = flexmock('invoice', 
                       :yus_name     => 'yus_name',
                       :item_by_text => item
                      )
    config  = flexmock('config', 
                      :smtp_server   => nil,
                      :smtp_port     => nil,
                      :smtp_domain   => nil,
                      :smtp_user     => nil,
                      :smtp_pass     => nil,
                      :smtp_authtype => nil
                     )
    flexmock(ODDB::Util::Ipn) do |i|
      i.should_receive(:config).and_return(config)
    end

    oddb_bak = $oddb
    $oddb    = flexmock('oddb', :yus_get_preference => 'yus_get_preference')
    assert_equal('sendmail', ODDB::Util::Ipn.send_poweruser_notification(invoice))
    $oddb    = oddb_bak
  end
  def test_send_download_seller_notification
    smtp = flexmock('smtp', :sendmail => 'sendmail')
    flexmock(Net::SMTP) do |s|
      s.should_receive(:start).and_yield(smtp)
    end

    item     = flexmock('itema',
                        :quantity    => 1,
                        :text        => 'text',
                        :total_netto => 2.345
                       )
 
    invoice  = flexmock('invoice', 
                        :yus_name     => 'yus_name',
                        :items        => {'key' => item},
                        :total_netto  => 2.345, 
                        :vat          => 6.789,
                        :total_brutto => 3.456
                       )
    config  = flexmock('config', 
                      :mail_from     => nil,
                      :smtp_server   => nil,
                      :smtp_port     => nil,
                      :smtp_domain   => nil,
                      :smtp_user     => nil,
                      :smtp_pass     => nil,
                      :smtp_authtype => nil
                     )

=begin
    flexmock(ODDB::Util::Ipn) do |i|
      i.should_receive(:config).and_return(config)
    end
=end
    flexmock(ODDB) do |i|
      i.should_receive(:config).and_return(config)
    end

    oddb_bak = $oddb
    $oddb    = flexmock('oddb', :yus_get_preference => 'yus_get_preference')
    assert_equal('sendmail', ODDB::Util::Ipn.send_download_seller_notification(invoice))
    $oddb    = oddb_bak
  end
  def test_send_download_seller_notification__nil
    invoice  = flexmock('invoice') do |i|
      i.should_receive(:yus_name).and_raise(StandardError)
    end

    oddb_bak = $oddb
    $oddb    = flexmock('oddb', :yus_get_preference => 'yus_get_preference')
    $stdout  = Tempfile.new('tempfile')
    assert_equal(nil, ODDB::Util::Ipn.send_download_seller_notification(invoice))
    $oddb    = oddb_bak
    $stdout  = STDOUT
  end
  def test_send_download_seller_notification__error
    invoice  = flexmock('invoice', :yus_name => nil)

    oddb_bak = $oddb
    $oddb    = flexmock('oddb', :yus_get_preference => 'yus_get_preference')
    assert_equal(nil, ODDB::Util::Ipn.send_download_seller_notification(invoice))
    $oddb    = oddb_bak
  end
  def test_send_download_notification
    smtp = flexmock('smtp', :sendmail => 'sendmail')
    flexmock(Net::SMTP) do |s|
      s.should_receive(:start).and_yield(smtp)
    end
    outgoing = flexmock('outgoing') do |m|
      m.should_receive(:set_content_type)
      m.should_receive(:to=)
      m.should_receive(:from=)
      m.should_receive(:date=)
      m.should_receive(:[]=)
      m.should_receive(:encoded)
      m.should_receive(:subject=)
      m.should_receive(:body=)
    end
    flexmock(TMail::Mail, :new => outgoing)
    item    = flexmock('item', 
                           :quantity    => 1,
                           :text        => 'text',
                           :total_netto => 2.345
                          )
    invoice = flexmock('invoice', 
                       :yus_name     => 'yus_name',
                       :oid          => 'oid',
                       :items        => {'key' => item},
                       :total_netto  => 2.345, 
                       :vat          => 6.789,
                       :total_brutto => 3.456
                      )

    config  = flexmock('config', 
                      :smtp_server   => nil,
                      :smtp_port     => nil,
                      :smtp_domain   => nil,
                      :smtp_user     => nil,
                      :smtp_pass     => nil,
                      :smtp_authtype => nil
                     )
    flexmock(ODDB::Util::Ipn) do |i|
      i.should_receive(:config).and_return(config)
    end

    oddb_bak = $oddb
    $oddb    = flexmock('oddb', :yus_get_preference => 'yus_get_preference')
    assert_equal('sendmail', ODDB::Util::Ipn.send_download_notification(invoice))
    $oddb    = oddb_bak
  end
  def test_send_download_notification__protocol
    smtp = flexmock('smtp', :sendmail => 'sendmail')
    flexmock(Net::SMTP) do |s|
      s.should_receive(:start).and_yield(smtp)
    end
    outgoing = flexmock('outgoing') do |m|
      m.should_receive(:set_content_type)
      m.should_receive(:to=)
      m.should_receive(:from=)
      m.should_receive(:date=)
      m.should_receive(:[]=)
      m.should_receive(:encoded)
      m.should_receive(:subject=)
      m.should_receive(:body=)
    end
    flexmock(TMail::Mail, :new => outgoing)
    item    = flexmock('item', 
                           :quantity    => 1,
                           :text        => 'text',
                           :total_netto => 2.345
                          )
    invoice = flexmock('invoice', 
                       :yus_name     => 'yus_name',
                       :oid          => 'oid',
                       :items        => {'key' => item},
                       :total_netto  => 2.345, 
                       :vat          => 6.789,
                       :total_brutto => 3.456
                      )

    config  = flexmock('config', 
                      :smtp_server   => nil,
                      :smtp_port     => nil,
                      :smtp_domain   => nil,
                      :smtp_user     => nil,
                      :smtp_pass     => nil,
                      :smtp_authtype => nil
                     )
    flexmock(ODDB::Util::Ipn) do |i|
      i.should_receive(:config).and_return(config)
    end
    flexmock(DOWNLOAD_PROTOCOLS, :find => 'protocol')

    oddb_bak = $oddb
    $oddb    = flexmock('oddb', :yus_get_preference => 'yus_get_preference')
    assert_equal('sendmail', ODDB::Util::Ipn.send_download_notification(invoice))
    $oddb    = oddb_bak
  end
  def test_process_invoice__poweruser
    smtp = flexmock('smtp', :sendmail => 'sendmail')
    flexmock(Net::SMTP) do |s|
      s.should_receive(:start).and_yield(smtp)
    end
    outgoing = flexmock('outgoing') do |m|
      m.should_receive(:set_content_type)
      m.should_receive(:to=)
      m.should_receive(:from=)
      m.should_receive(:date=)
      m.should_receive(:[]=)
      m.should_receive(:encoded)
      m.should_receive(:subject=)
      m.should_receive(:body=).and_return('body')
    end
    flexmock(TMail::Mail, :new => outgoing)

    system  = flexmock('system', 
                       :yus_set_preference => nil,
                       :yus_grant          => nil
                      )
    item    = flexmock('item', 
                       :quantity    => 1,
                       :text        => 'text',
                       :total_netto => 2.345,
                       :type        => :poweruser,
                       :duration    => 1,
                       :expiry_time => nil
                      )
    invoice = flexmock('invoice', 
                       :payment_received! => nil,
                       :yus_name          => 'yus_name',
                       :items             => {'key' => item},
                       :max_duration      => 'max_duration',
                       :item_by_text      => item,
                       :ydim_id           => 'ydim_id',
                       :types             => [:poweruser],
                       :total_netto       => 2.345, 
                       :vat               => 6.789,
                       :total_brutto      => 3.456,
                       :oid               => 'oid'

                      )
    config  = flexmock('config', 
                      :smtp_server   => nil,
                      :smtp_port     => nil,
                      :smtp_domain   => nil,
                      :smtp_user     => nil,
                      :smtp_pass     => nil,
                      :smtp_authtype => nil
                     )
    flexmock(ODDB::Util::Ipn) do |i|
      i.should_receive(:config).and_return(config)
    end
    flexmock(ODDB::YdimPlugin).new_instances do |y|
      y.should_receive(:inject)
    end

    oddb_bak = $oddb
    $oddb    = flexmock('oddb', :yus_get_preference => 'yus_get_preference')
    assert_equal([:poweruser], ODDB::Util::Ipn.process_invoice(invoice, system))
    $oddb    = oddb_bak
  end
  def test_process_invoice__download
    smtp = flexmock('smtp', :sendmail => 'sendmail')
    flexmock(Net::SMTP) do |s|
      s.should_receive(:start).and_yield(smtp)
    end
    outgoing = flexmock('outgoing') do |m|
      m.should_receive(:set_content_type)
      m.should_receive(:to=)
      m.should_receive(:from=)
      m.should_receive(:date=)
      m.should_receive(:[]=)
      m.should_receive(:encoded)
      m.should_receive(:subject=)
      m.should_receive(:body=).and_return('body')
    end
    flexmock(TMail::Mail, :new => outgoing)

    system  = flexmock('system', 
                       :yus_set_preference => nil,
                       :yus_grant          => nil
                      )
    item    = flexmock('item', 
                       :quantity    => 1,
                       :text        => 'text',
                       :total_netto => 2.345,
                       :type        => :download,
                       :duration    => 1,
                       :expiry_time => nil
                      )
    invoice = flexmock('invoice', 
                       :payment_received! => nil,
                       :yus_name          => 'yus_name',
                       :items             => {'key' => item},
                       :max_duration      => 'max_duration',
                       :item_by_text      => item,
                       :ydim_id           => 'ydim_id',
                       :types             => [:download],
                       :total_netto       => 2.345, 
                       :vat               => 6.789,
                       :total_brutto      => 3.456,
                       :oid               => 'oid'

                      )
    config  = flexmock('config', 
                      :smtp_server   => nil,
                      :smtp_port     => nil,
                      :smtp_domain   => nil,
                      :smtp_user     => nil,
                      :smtp_pass     => nil,
                      :smtp_authtype => nil
                     )
    flexmock(ODDB::Util::Ipn) do |i|
      i.should_receive(:config).and_return(config)
    end
    flexmock(ODDB::YdimPlugin).new_instances do |y|
      y.should_receive(:inject)
    end

    oddb_bak = $oddb
    $oddb    = flexmock('oddb', :yus_get_preference => 'yus_get_preference')
    assert_equal([:download], ODDB::Util::Ipn.process_invoice(invoice, system))
    $oddb    = oddb_bak
  end
  def test_process
    smtp = flexmock('smtp', :sendmail => 'sendmail')
    flexmock(Net::SMTP) do |s|
      s.should_receive(:start).and_yield(smtp)
    end
    outgoing = flexmock('outgoing') do |m|
      m.should_receive(:set_content_type)
      m.should_receive(:to=)
      m.should_receive(:from=)
      m.should_receive(:date=)
      m.should_receive(:[]=)
      m.should_receive(:encoded)
      m.should_receive(:subject=)
      m.should_receive(:body=).and_return('body')
    end
    flexmock(TMail::Mail, :new => outgoing)

    item    = flexmock('item', 
                       :quantity    => 1,
                       :text        => 'text',
                       :total_netto => 2.345,
                       :type        => :poweruser,
                       :duration    => 1,
                       :expiry_time => nil
                      )
    invoice = flexmock('invoice', 
                       :payment_received! => nil,
                       :yus_name          => 'yus_name',
                       :items             => {'key' => item},
                       :max_duration      => 'max_duration',
                       :item_by_text      => item,
                       :ydim_id           => 'ydim_id',
                       :types             => [:poweruser],
                       :total_netto       => 2.345, 
                       :vat               => 6.789,
                       :total_brutto      => 3.456,
                       :oid               => 'oid',
                       :odba_store        => nil

                      )
    config  = flexmock('config', 
                      :smtp_server   => nil,
                      :smtp_port     => nil,
                      :smtp_domain   => nil,
                      :smtp_user     => nil,
                      :smtp_pass     => nil,
                      :smtp_authtype => nil
                     )
    flexmock(ODDB::Util::Ipn) do |i|
      i.should_receive(:config).and_return(config)
    end
    flexmock(ODDB::YdimPlugin).new_instances do |y|
      y.should_receive(:inject)
    end

    system  = flexmock('system', 
                       :yus_set_preference => nil,
                       :yus_grant          => nil,
                       :invoice            => invoice
                      )
    notification = flexmock('notification', 
                            :complete?  => true,
                            :params     => {'invoice' => '123'}
                           )
    oddb_bak = $oddb
    $oddb    = flexmock('oddb', :yus_get_preference => 'yus_get_preference')
    assert_equal(invoice, ODDB::Util::Ipn.process(notification, system))
    $oddb    = oddb_bak
  end
  def test_process__complete_false
    smtp = flexmock('smtp', :sendmail => 'sendmail')
    flexmock(Net::SMTP) do |s|
      s.should_receive(:start).and_yield(smtp)
    end
    outgoing = flexmock('outgoing') do |m|
      m.should_receive(:set_content_type)
      m.should_receive(:to=)
      m.should_receive(:from=)
      m.should_receive(:date=)
      m.should_receive(:[]=)
      m.should_receive(:encoded)
      m.should_receive(:subject=)
      m.should_receive(:body=).and_return('body')
    end
    flexmock(TMail::Mail, :new => outgoing)

    item    = flexmock('item', 
                       :quantity    => 1,
                       :text        => 'text',
                       :total_netto => 2.345,
                       :type        => :poweruser,
                       :duration    => 1,
                       :expiry_time => nil
                      )
    invoice = flexmock('invoice', 
                       :payment_received! => nil,
                       :yus_name          => 'yus_name',
                       :items             => {'key' => item},
                       :max_duration      => 'max_duration',
                       :item_by_text      => item,
                       :ydim_id           => 'ydim_id',
                       :types             => [:poweruser],
                       :total_netto       => 2.345, 
                       :vat               => 6.789,
                       :total_brutto      => 3.456,
                       :oid               => 'oid',
                       :odba_store        => nil,
                       :ipn=              => nil

                      )
    config  = flexmock('config', 
                      :smtp_server   => nil,
                      :smtp_port     => nil,
                      :smtp_domain   => nil,
                      :smtp_user     => nil,
                      :smtp_pass     => nil,
                      :smtp_authtype => nil
                     )
    flexmock(ODDB::Util::Ipn) do |i|
      i.should_receive(:config).and_return(config)
    end
    flexmock(ODDB::YdimPlugin).new_instances do |y|
      y.should_receive(:inject)
    end

    system  = flexmock('system', 
                       :yus_set_preference => nil,
                       :yus_grant          => nil,
                       :invoice            => invoice
                      )
    notification = flexmock('notification', 
                            :complete?  => false,
                            :params     => {'invoice' => '123'}
                           )
    oddb_bak = $oddb
    $oddb    = flexmock('oddb', :yus_get_preference => 'yus_get_preference')
    assert_equal(invoice, ODDB::Util::Ipn.process(notification, system))
    $oddb    = oddb_bak
  end

  def test_format_invoice
    lookandfeel = flexmock('lookandfeel', :lookup => 'lookup')
    item        = flexmock('item', 
                           :quantity    => 1,
                           :text        => 'text',
                           :total_netto => 2.345
                          )
    invoice     = flexmock('invoice', 
                           :items        => {'key' => item},
                           :total_netto  => 2.345, 
                           :vat          => 6.789,
                           :total_brutto => 3.456
                          )
    expected = "lookup\n\n" +
               "====================\n" +
               "1 x text    EUR 2.35\n" +
               "--------------------\n" +
               "    lookup  EUR 2.35\n" +
               "--------------------\n" +
               "    lookup  EUR 6.79\n" +
               "====================\n" +
               "    lookup  EUR 3.46\n" +
               "====================\n"
    assert_equal(expected, ODDB::Util::Ipn.format_invoice(invoice, lookandfeel))
  end
  def test_format_line
    data  = ['data1', 'data2', 'data3']
    sizes = [1,2,3]
    expected = "data1 data2  EUR data3"
    assert_equal(expected, ODDB::Util::Ipn.format_line(sizes, data))
  end
  def test_yus
    oddb_bak = $oddb
    $oddb = flexmock('oddb', :yus_get_preference => 'yus_get_preference')
    assert_equal('yus_get_preference', ODDB::Util::Ipn.yus('recipient', 'key'))
    $oddb = oddb_bak
  end
end

    end # Ipn
  end # Util
end # ODDB

