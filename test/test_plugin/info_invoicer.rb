#!/usr/bin/env ruby
# encoding: utf-8
# TestInvoicer -- oddb.org -- 22.03.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'plugin/info_invoicer'
require 'date'
require 'model/invoice'
require 'yus/entity'

class TestInfoInvoicer <Minitest::Test
  include FlexMock::TestCase
  def setup
    @app      = flexmock('app')
    @invoicer = ODDB::InfoInvoicer.new(@app)
  end
  def test_run
    # This is nothing but a testcase which filfulls the test coverage.
    # send_daily-invoices and send_annual_invoices methods are
    # tested below independetly from this test-case.
    flexmock(@invoicer,
             :send_daily_invoices  => nil,
             :send_annual_invoices => 'send_annual_invoices'
            )
    assert_equal('send_annual_invoices', @invoicer.run(Date.new(2011,2,3)))
  end
  def test_pointer_resolved
    pointer = flexmock('pointer')
    flexmock(pointer, :resolve => 'resolve')
    assert_equal('resolve', @invoicer.pointer_resolved(pointer))
  end
  def test_parent_item_class
    assert_equal(Object, @invoicer.parent_item_class)
  end
  def test_actimve_companies
    company  = flexmock('company')
    sequence = flexmock('sequence', 
                        :is_a?   => true,
                        :company => company
                       )
    pointer  = flexmock('pointer')
    flexmock(pointer, :resolve => sequence)
    item     = flexmock('item', 
                        :type         => :annual_fee,
                        :item_pointer => pointer
                       )
    invoice  = flexmock('invoice', :items => {'key' => item})
    flexmock(@app, :invoices => {'key' => invoice})
    expected = [company]
    assert_equal(expected, @invoicer.active_companies)
  end
  def test_adjust_annual_fee
    item    = flexmock('item',
                       :type => :annual_fee,
                       :time => Time.local(2011,2,3),
                       :data => {},
                       :quantity=    => nil,
                       :expiry_time= => nil
                      )
    company = flexmock('company',
                       :invoice_date => Date.today,
                       :limit_invoice_duration => nil
                      )
    assert_equal([item], @invoicer.adjust_annual_fee(company, [item]))
  end
  def test_adjust_company_fee
    item    = flexmock('item', 
                       :type   => :annual_fee,
                       :price= => nil
                      )
    company = flexmock('company', :price => 123)
    expected = [item]
    assert_equal(expected, @invoicer.adjust_company_fee(company, [item]))
  end
  def test_adjust_overlap_fee
    item = flexmock('item',
                    :type         => nil,
                    :expiry_time  => Time.local(2011,2,3),
                    :expiry_time= => nil,
                    :quantity=    => nil
                   )
    assert_equal([item], @invoicer.adjust_overlap_fee(Date.new(2010,2,3), [item]))
  end
  def test_adjust_overlap_fee__annual_fee
    item = flexmock('item',
                    :type         => :annual_fee,
                    :expiry_time  => Time.local(2011,2,3),
                    :expiry_time= => nil,
                    :quantity=    => nil,
                    :data         => {}
                   )
    assert_equal([item], @invoicer.adjust_overlap_fee(Date.new(2010,2,3), [item]))
  end
  def test_slate_items
    item  = flexmock('item', :time => 'time')
    slate = flexmock('slate', :items => {'key' => item})
    flexmock(@app, :slate => slate)
    assert_equal([item], @invoicer.slate_items)
  end
  def test_annual_items
    item  = flexmock('item', 
                     :time => 'time',
                     :type => :annual_fee
                    )
    slate = flexmock('slate', :items => {'key' => item})
    flexmock(@app, :slate => slate)

    active_infos = flexmock('active_infos', :delete => nil)
    flexmock(@invoicer, 
             :active_infos => active_infos,
             :unique_name  => nil
            )
    assert_equal([], @invoicer.annual_items)
  end
  def test_all_items
    item  = flexmock('item', 
                     :time => 'time',
                     :type => :annual_fee
                    )
    slate = flexmock('slate', :items => {'key' => item})
    flexmock(@app, :slate => slate)


    active_infos = flexmock('active_infos', :delete => nil)
    flexmock(@invoicer, 
             :active_infos => active_infos,
             :unique_name  => nil
            )
    assert_equal([], @invoicer.all_items)
  end
  def test_html_items
    assert_equal([], @invoicer.html_items('day'))
  end
  def test_neighborhood_unique_names
    assert_equal([], @invoicer.neighborhood_unique_names('item'))
  end
  def test_filter_paid__annual_fee
    item = flexmock('item', 
                    :time     => 'time',
                    :expired? => false,
                    :type     => :annual_fee
                   )
    invoice  = flexmock('invoice',
                        :items => {'key' => item}
                       )
    flexmock(@app, :invoices => {'key' => invoice})
    flexmock(@invoicer, :unique_name => 'unique_name')
    assert_equal([item], @invoicer.filter_paid([item], Date.new(2011,2,3)))
  end
  def test_filter_paid__processing
    item = flexmock('item', 
                    :time     => 'time',
                    :expired? => false,
                    :type     => :processing
                   )
    invoice  = flexmock('invoice',
                        :items => {'key' => item}
                       )
    flexmock(@app, :invoices => {'key' => invoice})
    flexmock(@invoicer, :unique_name => 'unique_name')
    assert_equal([item], @invoicer.filter_paid([item], Date.new(2011,2,3)))
  end
  def test_group_by_company
    company  = flexmock('company')
    sequence = flexmock('sequence', 
                        :name => 'name',
                        :company => company
                       )
    pointer  = flexmock('pointer', :resolve => sequence)
    item     = flexmock('item', 
                        :item_pointer => pointer,
                        :data         => {},
                        :time         => 'time',
                        :type         => nil
                       )
    invoice  = flexmock('invoice', :items => {'key' => item})
    flexmock(@app, :invoices => {'key' => invoice})
    flexmock(@invoicer, :activation_fee => 'price')
    result = @invoicer.group_by_company([item])
    assert_equal(company, result.keys[0])
    assert_equal(item, result.values[0][1])
    assert_kind_of(ODDB::AbstractInvoiceItem, result.values[0][0])
  end
  def test_recent_items
    item  = flexmock('item', 
                     :time => 'time',
                     :type => :annual_fee
                    )
    slate = flexmock('slate', :items => {'key1' => item, 'key2' => item})
    flexmock(@app, :slate => slate)
    active_infos = flexmock('active_infos', :delete => 'delete')
    flexmock(@invoicer, 
             :active_infos => active_infos,
             :unique_name  => 'unique_name'
            )
    assert_equal([], @invoicer.recent_items(Date.new(2011,2,3)))
  end
  def test_recent_items__processing
    item  = flexmock('item', 
                     :time => Time.local(2011,2,4),
                     :type => :processing
                    )

    slate = flexmock('slate', :items => {'key1' => item, 'key2' => item})
    flexmock(@app, :slate => slate)
    active_infos = flexmock('active_infos', :delete => nil)
    flexmock(@invoicer, 
             :active_infos => active_infos,
             :unique_name  => 'unique_name'
            )
    assert_equal([], @invoicer.recent_items(Range.new(Date.new(2011,2,3), Date.new(2011,3,3))))
  end
  def test_send_daily_invoices
    # Memo
    # This send_daily_invoices methos uses some method which are defined in both invoicer.rb
    # and info_invoicer.rb. That is why this is an integrative test-case.
    # Actually, the methods which are defined in invoicer.rb and this info_invoicer.rb should not
    # be replaced by flexmock.  This should be fixed in the near future.
    active_infos = flexmock('active_infos', :delete => 'delete')
    pointer  = flexmock('pointer', :to_yus_privilege => 'to_yus_privilege')
    data     = flexmock('data', :update => 'update')
    item     = flexmock('item',
                        :type         => :annual_fee,
                        :time         => Date.new(2011,2,3),
                        :expired?     => false,
                        :item_pointer => pointer,
                        :values       => nil,
                        :price=       => nil,
                        :data         => data,
                        :quantity=    => nil,
                        :expiry_time= => nil
                       )
    flexmock(item, :dup => item)
    invoice  = flexmock('invoice', :items => {'key' => item})
    slate    = flexmock('slate', :items => {'key1' => item, 'key2' => item})
    company  = flexmock('company', 
                        :invoice_disabled? => false,
                        :contact_email     => 'contact_email',
                        :name              => 'name',
                        :price             => 123,
                        :invoice_date      => Date.new(2011,3,4),
                        :invoice_email     => 'invoice_email',
                        :limit_invoice_duration => 'limit_invoice_duration'
                       )
    update   = flexmock('update', :pointer => pointer)
    flexmock(pointer, 
             :+       => pointer,
             :dup     => pointer,
             :creator => nil
            )
    flexmock(@invoicer, 
             :unique_name      => 'unique_name',
             :active_infos     => active_infos,
             :invoices         => {'key' => invoice},
             :activation_fee   => 'price',
             :group_by_company => {company => [item]},
             :ensure_yus_user  => nil,
             :send_invoice     => 'ydim_id'
            )
    flexmock(@app, 
             :slate    => slate,
             :invoices => {'key' => invoice},
             :yus_create_user => nil,
             :update   => update
            )
    assert_equal(nil, @invoicer.send_daily_invoices(Date.new(2011,2,3)))
  end
  def test_send_daily_invoices__no_groups
    active_infos = flexmock('active_infos', :delete => 'delete')
    pointer  = flexmock('pointer')
    item     = flexmock('item',
                        :time         => 'time',
                        :type         => :annual_fee,
                        :expired?     => false,
                        :item_pointer => pointer
                       )
    invoice  = flexmock('invoice', :items => {'key' => item})
    slate    = flexmock('slate', :items => {'key1' => item, 'key2' => item})
    flexmock(@invoicer, 
             :unique_name     => 'unique_name',
             :active_infos    => active_infos,
             :invoices        => {'key' => invoice},
             :activation_fee  => 'price'
            )
    flexmock(@app, 
             :slate    => slate,
             :invoices => {'key' => invoice}
            )
    assert_equal(nil, @invoicer.send_daily_invoices(Date.new(2011,2,3)))
  end
  def test_send_annual_invoices
    # Memo
    # This is also an integrative test as the test_send_daily_invoices above.
    active_infos = flexmock('active_infos', :delete => 'delete')
    pointer  = flexmock('pointer', :to_yus_privilege => 'to_yus_privilege')
    data     = flexmock('data', :update => 'update')
    item     = flexmock('item',
                        :type         => :annual_fee,
                        :time         => Date.new(2011,2,3),
                        :expired?     => false,
                        :item_pointer => pointer,
                        :values       => nil,
                        :price=       => nil,
                        :data         => data,
                        :quantity=    => nil,
                        :expiry_time= => nil,
                        :odba_store   => 'odba_store'
                       )
    flexmock(item, :dup => item)
    invoice  = flexmock('invoice', :items => {'key' => item})
    slate    = flexmock('slate', :items => {'key1' => item, 'key2' => item})
    company  = flexmock('company', 
                        :invoice_disabled? => true,
                        :contact_email     => 'contact_email',
                        :name              => 'name',
                        :price             => 123,
                        :invoice_date      => Date.new(2011,2,3),
                        :invoice_email     => 'invoice_email',
                        :limit_invoice_duration => 'limit_invoice_duration',
                        :invoice_dates     => {},
                        :odba_store        => nil
                       )
    update   = flexmock('update', :pointer => pointer)
    flexmock(pointer, 
             :+       => pointer,
             :dup     => pointer,
             :creator => nil
            )
    flexmock(@invoicer, 
             :unique_name      => 'unique_name',
             :active_infos     => active_infos,
             :invoices         => {'key' => invoice},
             :activation_fee   => 'price',
             :group_by_company => {company => [item]},
             :ensure_yus_user  => nil,
             :send_invoice     => 'ydim_id'
            )
    flexmock(@app, 
             :slate    => slate,
             :invoices => {'key' => invoice},
             :yus_create_user => nil,
             :update   => update
            )
    assert_equal({company => [item]}, @invoicer.send_annual_invoices(Date.new(2011,2,3)))
  end
  def test_send_annual_invoices__company_contact_email
    # Memo
    # This is also an integrative test as the test_send_daily_invoices above.
    active_infos = flexmock('active_infos', :delete => 'delete')
    pointer  = flexmock('pointer', :to_yus_privilege => 'to_yus_privilege')
    data     = flexmock('data', :update => 'update')
    item     = flexmock('item',
                        :type         => :annual_fee,
                        :time         => Date.new(2011,2,3),
                        :expired?     => false,
                        :item_pointer => pointer,
                        :values       => nil,
                        :price=       => nil,
                        :data         => data,
                        :quantity=    => nil,
                        :expiry_time= => nil,
                        :expiry_time  => Date.new(2011,3,4),
                        :odba_store   => 'odba_store'
                       )
    flexmock(item, :dup => item)
    invoice  = flexmock('invoice', :items => {'key' => item})
    slate    = flexmock('slate', :items => {'key1' => item, 'key2' => item})
    company  = flexmock('company', 
                        :invoice_disabled? => false,
                        :contact_email     => 'contact_email',
                        :name              => 'company_name',
                        :price             => 123,
                        :invoice_date      => nil,
                        :invoice_email     => 'invoice_email',
                        :limit_invoice_duration => 'limit_invoice_duration',
                        :invoice_dates     => {},
                        :odba_store        => nil
                       )
    update   = flexmock('update', :pointer => pointer)
    flexmock(pointer, 
             :+       => pointer,
             :dup     => pointer,
             :creator => nil
            )
    flexmock(@invoicer, 
             :unique_name      => 'unique_name',
             :active_infos     => active_infos,
             :invoices         => {'key' => invoice},
             :activation_fee   => 'price',
             :group_by_company => {company => [item]},
             :ensure_yus_user  => 'ensure_yus_user',
             :send_invoice     => 'ydim_id'
            )
    flexmock(@app, 
             :slate    => slate,
             :invoices => {'key' => invoice},
             :yus_create_user => nil,
             :update   => update
            )
    #assert_equal({company => [item]}, @invoicer.send_annual_invoices(Date.new(2011,2,3), 'company_name'))
    assert_equal({company => [item]}, @invoicer.send_annual_invoices(Date.new(2011,2,3)))
  end
  def test_send_annual_invoices__company_name
    # Memo
    # This is also an integrative test as the test_send_daily_invoices above.
    active_infos = flexmock('active_infos', :delete => 'delete')
    pointer  = flexmock('pointer', :to_yus_privilege => 'to_yus_privilege')
    data     = flexmock('data', :update => 'update')
    item     = flexmock('item',
                        :type         => :annual_fee,
                        :time         => Date.new(2011,2,3),
                        :expired?     => false,
                        :item_pointer => pointer,
                        :values       => nil,
                        :price=       => nil,
                        :data         => data,
                        :quantity=    => nil,
                        :expiry_time= => nil,
                        :expiry_time  => Date.new(2011,3,4),
                        :odba_store   => 'odba_store'
                       )
    flexmock(item, :dup => item)
    invoice  = flexmock('invoice', :items => {'key' => item})
    slate    = flexmock('slate', :items => {'key1' => item, 'key2' => item})
    company  = flexmock('company', 
                        :invoice_disabled? => false,
                        :contact_email     => 'contact_email',
                        :name              => 'company_name',
                        :price             => 123,
                        :invoice_date      => Date.new(2011,3,4),
                        :invoice_email     => 'invoice_email',
                        :limit_invoice_duration => 'limit_invoice_duration',
                        :invoice_dates     => {},
                        :odba_store        => nil
                       )
    update   = flexmock('update', :pointer => pointer)
    flexmock(pointer, 
             :+       => pointer,
             :dup     => pointer,
             :creator => nil
            )
    flexmock(@invoicer, 
             :unique_name      => 'unique_name',
             :active_infos     => active_infos,
             :invoices         => {'key' => invoice},
             :activation_fee   => 'price',
             :group_by_company => {company => [item]},
             :ensure_yus_user  => 'ensure_yus_user',
             :send_invoice     => 'ydim_id'
            )
    flexmock(@app, 
             :slate    => slate,
             :invoices => {'key' => invoice},
             :yus_create_user => nil,
             :update   => update
            )
    assert_equal({company => [item]}, @invoicer.send_annual_invoices(Date.new(2011,2,3), 'company_name'))
  end
  def test_send_annual_invoices__invoice_date_one_year_later
    # Memo
    # This is also an integrative test as the test_send_daily_invoices above.
    active_infos = flexmock('active_infos', :delete => 'delete')
    pointer  = flexmock('pointer', :to_yus_privilege => 'to_yus_privilege')
    data     = flexmock('data', :update => 'update')
    item     = flexmock('item',
                        :type         => :annual_fee,
                        :time         => Date.new(2011,2,3),
                        :expired?     => false,
                        :item_pointer => pointer,
                        :values       => nil,
                        :price=       => nil,
                        :data         => data,
                        :quantity=    => nil,
                        :expiry_time= => nil,
                        :expiry_time  => Date.new(2011,3,4),
                        :odba_store   => 'odba_store'
                       )
    flexmock(item, :dup => item)
    invoice  = flexmock('invoice', :items => {'key' => item})
    slate    = flexmock('slate', :items => {'key1' => item, 'key2' => item})
    company  = flexmock('company', 
                        :invoice_disabled? => false,
                        :contact_email     => 'contact_email',
                        :name              => 'company_name',
                        :price             => 123,
                        :invoice_date      => Date.new(2012,2,3),
                        :invoice_email     => 'invoice_email',
                        :limit_invoice_duration => 'limit_invoice_duration',
                        :invoice_dates     => {},
                        :odba_store        => nil
                       )
    update   = flexmock('update', :pointer => pointer)
    flexmock(pointer, 
             :+       => pointer,
             :dup     => pointer,
             :creator => nil
            )
    flexmock(@invoicer, 
             :unique_name      => 'unique_name',
             :active_infos     => active_infos,
             :invoices         => {'key' => invoice},
             :activation_fee   => 'price',
             :group_by_company => {company => [item]},
             :ensure_yus_user  => 'ensure_yus_user',
             :send_invoice     => 'ydim_id'
            )
    flexmock(@app, 
             :slate    => slate,
             :invoices => {'key' => invoice},
             :yus_create_user => nil,
             :update   => update
            )
    assert_equal({company => [item]}, @invoicer.send_annual_invoices(Date.new(2011,2,3)))
  end



end

