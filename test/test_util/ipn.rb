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
require 'mail'
require 'stub/config'

module ODDB
  module Util
    module Ipn

class TestIpn <Minitest::Test
  include FlexMock::TestCase
  YUS_NAME ='yus_name'
  MAIL_FROM = [ ODDB::Util::EmailTestAddressFrom ]
  SUBJECT_DOWNLOAD = 'Datendownload von ODDB.org'
  ADMIN_TO = ["zdavatz@ywesee.com", "zdavatz@ywesee.com", "mhatakeyama@ywesee.com"]
  SUBJECT_POWERUSER = "Power-User bei ODDB.org"
  def setup
    Util.configure_mail :test
    Util.clear_sent_mails
  end

  def check_sent_one_mail(subject, nrMsg = 1, to = [YUS_NAME])
    puts "check_sent_one_mail #{subject}" if $VERBOSE
    mails_sent = Util.sent_mails
    assert_equal(nrMsg, mails_sent.size)
    mail = mails_sent.first
    assert_equal(to, mail.to)
    assert_equal(subject,mail.subject)
    assert_equal(MAIL_FROM, mail.from)
  end
  def test_lookandfeel_stub
    assert_kind_of(ODDB::LookandfeelBase, ODDB::Util::Ipn.lookandfeel_stub)
  end
  def test_send_notification
    invoice = flexmock('invoice', :yus_name => YUS_NAME)
    result  = ODDB::Util::Ipn.send_notification(invoice)
    check_sent_one_mail(SUBJECT_DOWNLOAD)
  end
  def test_send_notification__nil
    invoice = flexmock('invoice', :yus_name => nil)
    assert_equal(nil, ODDB::Util::Ipn.send_notification(invoice){})
  end
  def test_send_poweruser_notification
    item    = flexmock('item', :duration => 1)
    invoice = flexmock('invoice',
                       :yus_name     => YUS_NAME,
                       :item_by_text => item
                      )
    oddb_bak = $oddb
    $oddb    = flexmock('oddb', :yus_get_preference => 'yus_get_preference')
    ODDB::Util::Ipn.send_poweruser_notification(invoice)
    $oddb    = oddb_bak
    check_sent_one_mail(SUBJECT_DOWNLOAD, 1, [YUS_NAME])
  end
  def test_send_download_seller_notification
    item     = flexmock('itema',
                        :quantity    => 1,
                        :text        => 'text',
                        :total_netto => 2.345
                       )
 
    invoice  = flexmock('invoice', 
                        :yus_name     => YUS_NAME,
                        :items        => {'key' => item},
                        :total_netto  => 2.345, 
                        :vat          => 6.789,
                        :total_brutto => 3.456
                       )
    oddb_bak = $oddb
    $oddb    = flexmock('oddb', :yus_get_preference => 'yus_get_preference')
    ODDB::Util::Ipn.send_download_seller_notification(invoice)
    $oddb    = oddb_bak
    check_sent_one_mail(SUBJECT_DOWNLOAD, 1 ,ADMIN_TO)
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
    assert_equal(0, Util.sent_mails.size)
  end
  def test_send_download_seller_notification__error
    invoice  = flexmock('invoice', :yus_name => nil)

    oddb_bak = $oddb
    $oddb    = flexmock('oddb', :yus_get_preference => 'yus_get_preference')
    assert_equal(nil, ODDB::Util::Ipn.send_download_seller_notification(invoice))
    $oddb    = oddb_bak
    assert_equal(0, Util.sent_mails.size)
  end

  def test_send_download_notification
    item    = flexmock('item', 
                           :quantity    => 1,
                           :text        => 'text',
                           :total_netto => 2.345
                          )
    invoice = flexmock('invoice', 
                       :yus_name     => YUS_NAME,
                       :oid          => 'oid',
                       :items        => {'key' => item},
                       :total_netto  => 2.345, 
                       :vat          => 6.789,
                       :total_brutto => 3.456
                      )
    oddb_bak = $oddb
    $oddb    = flexmock('oddb', :yus_get_preference => 'yus_get_preference')
    ODDB::Util::Ipn.send_download_notification(invoice)
    $oddb    = oddb_bak
    check_sent_one_mail(SUBJECT_DOWNLOAD)
  end
	
  def test_send_download_notification__protocol
    item    = flexmock('item', 
                           :quantity    => 1,
                           :text        => 'text',
                           :total_netto => 2.345
                          )
    invoice = flexmock('invoice', 
                       :yus_name     => YUS_NAME,
                       :oid          => 'oid',
                       :items        => {'key' => item},
                       :total_netto  => 2.345, 
                       :vat          => 6.789,
                       :total_brutto => 3.456,
                      )
    oddb_bak = $oddb
    $oddb    = flexmock('oddb', :yus_get_preference => 'yus_get_preference')
    result = ODDB::Util::Ipn.send_download_notification(invoice)
    $oddb    = oddb_bak
    assert(result)
    check_sent_one_mail(SUBJECT_DOWNLOAD)
  end
	def test_process_invoice__poweruser
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
                       :yus_name          => YUS_NAME,
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
    flexmock(ODDB::YdimPlugin).new_instances do |y|
      y.should_receive(:inject)
    end

    oddb_bak = $oddb
    $oddb    = flexmock('oddb', :yus_get_preference => 'yus_get_preference')
    assert_equal([:poweruser], ODDB::Util::Ipn.process_invoice(invoice, system))
    $oddb    = oddb_bak
  end
  def test_process_invoice__download
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
                       :yus_name          => YUS_NAME,
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
    flexmock(ODDB::YdimPlugin).new_instances do |y|
      y.should_receive(:inject)
    end

    oddb_bak = $oddb
    $oddb    = flexmock('oddb', :yus_get_preference => 'yus_get_preference')
    assert_equal([:download], ODDB::Util::Ipn.process_invoice(invoice, system))
    $oddb    = oddb_bak
    check_sent_one_mail(SUBJECT_DOWNLOAD, 2)
  end
  def test_process
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
                       :yus_name          => YUS_NAME,
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
    result = ODDB::Util::Ipn.process(notification, system)
    $oddb    = oddb_bak
    assert_equal(invoice, result)
  end
  def test_process__complete_false
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
                       :yus_name          => YUS_NAME,
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

