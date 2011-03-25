#!/usr/bin/env ruby
# ODDB::TestYdimPlugin -- oddb.org -- 23.03.2011 -- mhatakeyama@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'plugin/ydim'
require 'iconv'
require 'tempfile'
require 'model/hospital'
require 'model/company'
require 'date'
require 'model/registration'

class TestDebitorFacade < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @yus_model = flexmock('yus_model')
    @app       = flexmock('app', 
                          :yus_model => @yus_model,
                          :yus_get_preference => 'yus_get_preference',
                          :yus_set_preference => 'yus_set_preference'
                         )
    @facade    = ODDB::YdimPlugin::DebitorFacade.new('email', @app)
  end
  def test_ydim_id
    assert_equal('id', @facade.ydim_id='id')
    assert_equal('yus_get_preference', @facade.ydim_id)
  end
  def test_ydim_id__debitor
    flexmock(@yus_model, 
             :ydim_id=   => nil,
             :odba_store => 'odba_store'
            )
    assert_equal('id', @facade.ydim_id='id')
    assert_equal('yus_get_preference', @facade.ydim_id)
  end
  def test_equal
    assert_equal(false, @facade === @facade)
    assert_equal(true, @facade === @facade.instance_eval('@debitor'))
  end
  def test_missing_method
    flexmock(@yus_model, :hogehoge => 'hogehoge')
    assert_equal('hogehoge', @facade.hogehoge)
  end
  def stderr_null
    require 'tempfile'
    $stderr = Tempfile.open('stderr')
    yield
    $stderr.close
    $stderr = STDERR
  end
  def replace_constant(constant, temp)
    stderr_null do
      keep = eval constant
      eval "#{constant} = temp"
      yield
      eval "#{constant} = keep"
    end
  end
=begin
  def test_missing_method__iconv_error
    icon = flexmock('iconv') do |i|
      i.should_receive(:iconv).and_raise(Iconv::IllegalSequence)
    end
    replace_constant('ODDB::YdimPlugin::ICONV', icon) do 
      assert_equal('', @facade.hogehoge)
    end
  end
=end
end

module ODDB
  class TestYdimPlugin < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @facade = flexmock('facade')
      @app    = flexmock('app')
      @plugin = YdimPlugin.new(@app)
    end
    def test_debitor_id
      flexmock(@facade, :ydim_id => 'ydim_id')
      assert_equal('ydim_id', @plugin.debitor_id(@facade))
    end
    def test_debitor_id__identify_debitor
      debitor = flexmock('debitor', :unique_id => 'unique_id')
      client  = flexmock('client', :search_debitors => [debitor])
      server  = flexmock('server', 
                         :logout => 'logout',
                         :login  => client
                        )
      flexmock(DRb::DRbObject, :new => server)
      flexmock(@facade, 
               :ydim_id  => nil,
               :ydim_id= => 'ydim_id',
               :fullname => 'fullname',
               :force_new_ydim_debitor => nil
              )
      assert_equal('unique_id', @plugin.debitor_id(@facade))
    end
    def test_debitor_id__create_debitor
      debitor = flexmock('debitor', 
                         :name=              => nil,
                         :salutation=        => nil,
                         :contact=           => nil,
                         :location=          => nil,
                         :email=             => nil,
                         :debitor_type=      => nil,
                         :address_lines=     => nil,
                         :contact_firstname= => nil,
                         :odba_store         => 'odba_store',
                         :unique_id          => 'unique_id'
                        )
      client  = flexmock('client', :create_debitor => debitor)
      server  = flexmock('server', 
                         :logout => 'logout',
                         :login  => client
                        )
      flexmock(DRb::DRbObject, :new => server)
      flexmock(@facade, 
               :ydim_id    => nil,
               :fullname   => 'fullname',
               :name_first => 'name_first',
               :name_last  => 'name_last',
               :ydim_id=   => 'ydim_id',
               :contact    => 'contact',
               :salutation => 'salutation',
               :invoice_email          => 'invoice_email',
               :ydim_location          => 'ydim_location',
               :ydim_address_lines     => 'ydim_address_lines',
               :force_new_ydim_debitor => true
              )
      assert_equal('unique_id', @plugin.debitor_id(@facade))
    end
    def test_ydim_connect
      server = flexmock('server', 
                        :logout => 'logout',
                        :login  => 'login'
                       )
      flexmock(DRb::DRbObject, :new => server)
      @plugin.ydim_connect do |client|
        assert_kind_of(YDIM::Client, client)

      end
    end
    def test_identify_debitor
      debitor = flexmock('debitor', :unique_id => 'unique_id')
      client  = flexmock('client', :search_debitors => [debitor])
      server  = flexmock('server', 
                         :logout => 'logout',
                         :login  => client
                        )
      flexmock(DRb::DRbObject, :new => server)
      flexmock(@facade, 
               :fullname => 'fullname',
               :ydim_id= => 'ydim_id'
              )
      assert_equal(debitor, @plugin.identify_debitor(@facade))
    end
    def test_create_debitor
      debitor = flexmock('debitor', 
                         :name=              => nil,
                         :salutation=        => nil,
                         :contact=           => nil,
                         :location=          => nil,
                         :email=             => nil,
                         :debitor_type=      => nil,
                         :address_lines=     => nil,
                         :contact_firstname= => nil,
                         :odba_store         => 'odba_store',
                         :unique_id          => 'unique_id'
                        )
      client  = flexmock('client', :create_debitor => debitor)
      server  = flexmock('server', 
                         :logout => 'logout',
                         :login  => client
                        )
      flexmock(DRb::DRbObject, :new => server)
      flexmock(@facade, 
               :fullname   => 'fullname',
               :name_first => 'name_first',
               :name_last  => 'name_last',
               :ydim_id=   => 'ydim_id',
               :contact    => 'contact',
               :salutation => 'salutation',
               :invoice_email      => 'invoice_email',
               :ydim_location      => 'ydim_location',
               :ydim_address_lines => 'ydim_address_lines'
              )

      assert_equal(debitor, @plugin.create_debitor(@facade))
    end
    def test_create_debitor__oddb_hospital
      debitor = flexmock('debitor', 
                         :name=              => nil,
                         :salutation=        => nil,
                         :contact=           => nil,
                         :location=          => nil,
                         :email=             => nil,
                         :debitor_type=      => nil,
                         :address_lines=     => nil,
                         :contact_firstname= => nil,
                         :odba_store         => 'odba_store',
                         :unique_id          => 'unique_id'
                        )
      client  = flexmock('client', :create_debitor => debitor)
      server  = flexmock('server', 
                         :logout => 'logout',
                         :login  => client
                        )
      flexmock(DRb::DRbObject, :new => server)
      hospital = ODDB::Hospital.new('ean13')
      facade  = flexmock(hospital, 
                :fullname   => 'fullname',
                :name_first => 'name_first',
                :name_last  => 'name_last',
                :ydim_id=   => 'ydim_id',
                :contact    => 'contact',
                :salutation => 'salutation',
                :invoice_email      => 'invoice_email',
                :ydim_location      => 'ydim_location',
                :ydim_address_lines => 'ydim_address_lines'
               )

      assert_equal(debitor, @plugin.create_debitor(facade))
    end
    def test_create_debitor__oddb_company
      debitor = flexmock('debitor', 
                         :name=              => nil,
                         :salutation=        => nil,
                         :contact=           => nil,
                         :location=          => nil,
                         :email=             => nil,
                         :debitor_type=      => nil,
                         :address_lines=     => nil,
                         :contact_firstname= => nil,
                         :odba_store         => 'odba_store',
                         :unique_id          => 'unique_id'
                        )
      client  = flexmock('client', :create_debitor => debitor)
      server  = flexmock('server', 
                         :logout => 'logout',
                         :login  => client
                        )
      flexmock(DRb::DRbObject, :new => server)
      flexmock(ODBA.cache, :next_id => 123)
      company = ODDB::Company.new
      facade  = flexmock(company, 
                :fullname   => 'fullname',
                :name_first => 'name_first',
                :name_last  => 'name_last',
                :ydim_id=   => 'ydim_id',
                :contact    => 'contact',
                :salutation => 'salutation',
                :invoice_email      => 'invoice_email',
                :ydim_location      => 'ydim_location',
                :ydim_address_lines => 'ydim_address_lines'
               )

      assert_equal(debitor, @plugin.create_debitor(facade))
    end
    def test_create_debitor__facade_business_area
      debitor = flexmock('debitor', 
                         :name=              => nil,
                         :salutation=        => nil,
                         :contact=           => nil,
                         :location=          => nil,
                         :email=             => nil,
                         :debitor_type=      => nil,
                         :address_lines=     => nil,
                         :contact_firstname= => nil,
                         :odba_store         => 'odba_store',
                         :unique_id          => 'unique_id'
                        )
      client  = flexmock('client', :create_debitor => debitor)
      server  = flexmock('server', 
                         :logout => 'logout',
                         :login  => client
                        )
      flexmock(DRb::DRbObject, :new => server)
      flexmock(ODBA.cache, :next_id => 123)
      company = ODDB::Company.new
      facade  = flexmock(company, 
                :fullname   => 'fullname',
                :name_first => 'name_first',
                :name_last  => 'name_last',
                :ydim_id=   => 'ydim_id',
                :contact    => 'contact',
                :salutation => 'salutation',
                :invoice_email      => 'invoice_email',
                :ydim_location      => 'ydim_location',
                :ydim_address_lines => 'ydim_address_lines',
                :business_area      => 'business_are'
               )

      assert_equal(debitor, @plugin.create_debitor(facade))
    end
    def test_item_name
      item = flexmock('item', :data => {:name => 'name'})
      assert_equal('name', @plugin.item_name(item))
    end
    def test_item_name__empty
      item = flexmock('item', 
                      :data         => {:name => ''},
                      :item_pointer => 'pointer'
                     )
      assert_equal(nil, @plugin.item_name(item))
    end
    def test_item_text__last_day
      data = {
        :name => 'name',
        :days => 123,
        :first_valid_date => Date.new(2011,1,2),
        :last_valid_date  => Date.new(2011,2,1)
      }
      item = flexmock('item', 
                      :data => data,
                      :text => 'text',
                      :time => Time.local(2011,2,3)
                     )
      expected = "text\nname\n02.01.2011 - 01.02.2011\n123 Tage"
      assert_equal(expected, @plugin.item_text(item))
    end
    def test_item_text__one_year
      data = {
        :name => 'name',
        :days => 123,
        :first_valid_date => Date.new(2010,1,2),
        :last_valid_date  => Date.new(2011,2,1)
      }
      item = flexmock('item', 
                      :data => data,
                      :text => 'text',
                      :time => Time.local(2011,2,3)
                     )
      expected = /text\nname\n02.01.2010 - 01.02.2011\n123 Tage\nDiese Rechnungsposition wird in der n.*chsten Jahresrechnung _nicht_ vorkommen.\nDie n.*chste Jahresrechnung wird am 01.02.2010 versandt.\n/
      assert_match(expected, @plugin.item_text(item))
    end
    def test_sort_items
      data = {
        :name => 'name',
        :days => 123,
        :first_valid_date => Date.new(2011,1,2),
        :last_valid_date  => Date.new(2011,2,1)
      }
      item = flexmock('item', 
                      :data => data,
                      :text => 'text',
                      :type => 'type',
                      :time => Time.local(2011,2,3)
                     )
      assert_equal([item], @plugin.sort_items([item]))
    end
    def test_latin1__string
      assert_equal('text', @plugin.latin1('text'))
    end
    def test_latin1__hash
      assert_equal({"key"=>"value"}, @plugin.latin1({'key' => 'value'}))
    end
    def test_latin1__else
      text = flexmock('text')
      assert_equal(text, @plugin.latin1(text))
    end
    def test_send_invoice
      client = flexmock('client', :send_invoice => 'send_invoice')
      server = flexmock('server', 
                        :logout => 'logout',
                        :login  => client
                       )
      flexmock(DRb::DRbObject, :new => server)
      assert_equal('send_invoice', @plugin.send_invoice('ydim_invoice_id'))
    end
    def test_invoice_date
      item = flexmock('item', :time => Time.local(2011,2,3))
      expected = Date.new(2011,2,3)
      assert_equal(expected, @plugin.invoice_date([item]))
    end
    def test_invoice_description
      pointer = flexmock('pointer', :resolve => 'resolve')
      item    = flexmock('item', 
                         :time => Time.local(2011,2,3),
                         :type => :annual_fee,
                         :item_pointer => pointer
                        )
      expected = '1 x Patinfo-Upload 2011/2012'
      assert_equal(expected, @plugin.invoice_description([item], Date.new(2011,2,3)))
    end
    def test_invoice_description__poweruser
      pointer = flexmock('pointer', :resolve => 'resolve')
      item    = flexmock('item', 
                         :time => Time.local(2011,2,3),
                         :type => :poweruser,
                         :item_pointer => pointer,
                         :expiry_time => Time.local(2011,3,4)
                        )
      expected = 'PowerUser 03.02.2011 - 04.03.2011'
      assert_equal(expected, @plugin.invoice_description([item], Date.new(2011,2,3)))
    end
    def test_invoice_description__csv_export
      pointer = flexmock('pointer', :resolve => 'resolve')
      item    = flexmock('item', 
                         :time => Time.local(2011,2,3),
                         :type => :csv_export,
                         :item_pointer => pointer
                        )
      expected = '1 x CSV-Download 02/2011'
      assert_equal(expected, @plugin.invoice_description([item], Date.new(2011,2,3)))
    end
    def test_invoice_description__download
      pointer = flexmock('pointer', :resolve => 'resolve')
      item    = flexmock('item', 
                         :time => Time.local(2011,2,3),
                         :type => :download,
                         :item_pointer => pointer
                        )
      expected = '1 x Download 03.02.2011'
      assert_equal(expected, @plugin.invoice_description([item], Date.new(2011,2,3)))
    end
    def test_invoice_description__index
      pointer = flexmock('pointer', :resolve => 'resolve')
      item    = flexmock('item', 
                         :time => Time.local(2011,2,3),
                         :type => :index,
                         :item_pointer => pointer
                        )
      expected = 'Firmenverzeichnis 2011/2012'
      assert_equal(expected, @plugin.invoice_description([item], Date.new(2011,2,3)))
    end
    def test_invoice_description__lookandfeel
      pointer = flexmock('pointer', :resolve => 'resolve')
      item    = flexmock('item', 
                         :time => Time.local(2011,2,3),
                         :type => :lookandfeel,
                         :item_pointer => pointer
                        )
      expected = 'Lookandfeel-Integration 2011/2012'
      assert_equal(expected, @plugin.invoice_description([item], Date.new(2011,2,3)))
    end
    def test_inject_from_items
      invoice    = flexmock('invoice', 
                            :description=    => nil,
                            :date=           => nil,
                            :currency=       => nil,
                            :payment_period= => nil,
                            :unique_id       => 'unique_id'
                           ) 
      client     = flexmock('client', 
                            :create_invoice => invoice,
                            :add_items      => nil
                           )

      server     = flexmock('server', 
                            :logout => 'logout',
                            :login  => client
                           )
      flexmock(DRb::DRbObject, :new => server)
      pointer    = flexmock('pointer', :resolve => 'resolve')
      item       = flexmock('item',
                            :time      => Time.local(2011,2,3),
                            :text      => 'text',
                            :data      => 'data',
                            :type      => 'type',
                            :quantity  => 1.0,
                            :ydim_data => 'ydim_data',
                            :item_pointer => pointer
                           ) 
      yus_model  = flexmock('yus_model')
      flexmock(@app, 
               :yus_model => yus_model,
               :yus_get_preference => 'yus_get_preference'
              )
      date       = Date.new(2011,2,3)
      assert_equal(invoice, @plugin.inject_from_items(date, 'email', [item]))
    end
    def test_inject__ydim_id
      invoice = flexmock('invoice', :ydim_id => 'ydim_id')
      client  = flexmock('client', :invoice => 'invoice')
      server  = flexmock('server', 
                         :logout => 'logout',
                         :login  => client
                        )
      flexmock(DRb::DRbObject, :new => server)
      assert_equal('invoice', @plugin.inject(invoice))
    end
    def test_inject__yus_name
      pointer    = flexmock('pointer', :resolve => 'resolve')
      item       = flexmock('item',
                            :time      => Time.local(2011,2,3),
                            :text      => 'text',
                            :data      => 'data',
                            :type      => 'type',
                            :quantity  => 1.0,
                            :ydim_data => 'ydim_data',
                            :item_pointer => pointer
                           ) 
      invoice    = flexmock('invoice', 
                            :description=    => nil,
                            :date=           => nil,
                            :currency=       => nil,
                            :payment_period= => nil,
                            :unique_id       => 'unique_id',
                            :yus_name        => 'yus_name',
                            :ydim_id         => nil,
                            :ydim_id=        => nil,
                            :items           => {'key' => item},
                            :currency        => 'currency',
                            :odba_store      => 'odba_store',
                            :payment_received? => nil,
                            :payment_received= => nil
                           ) 
      client     = flexmock('client', 
                            :create_invoice => invoice,
                            :add_items      => nil
                           )

      server     = flexmock('server', 
                            :logout => 'logout',
                            :login  => client
                           )
      flexmock(DRb::DRbObject, :new => server)
      yus_model  = flexmock('yus_model')
      flexmock(@app, 
               :yus_model => yus_model,
               :yus_get_preference => 'yus_get_preference'
              )
      date       = Date.new(2011,2,3)

      assert_equal('odba_store', @plugin.inject(invoice))
    end
  end
end

