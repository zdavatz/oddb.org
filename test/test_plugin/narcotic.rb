#!/usr/bin/env ruby
# ODDB::TestNarcoticPlugin -- oddb -- 16.03.2011 -- mhatakeyama@ywesee.com
# ODDB::TestNarcoticPlugin -- oddb -- 03.11.2005 -- ffricker@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))
$: << File.expand_path('..', File.dirname(__FILE__))


require 'test/unit'
require 'plugin/narcotic'
require 'flexmock'
require 'mechanize'

module ODDB
	class TestNarcoticPlugin < Test::Unit::TestCase
    include FlexMock::TestCase
		def setup
			@app = flexmock('app')
			@plugin = NarcoticPlugin.new(@app)
		end
		def test_casrns
			row = ['NAME', nil, 'pcode', 'smcd']
			assert_equal(@plugin.casrns(row), [])
			row = ['NAME', '', 'pcode', 'smcd']
			assert_equal(@plugin.casrns(row), [])
			row = ['NAME', 'nil', 'pcode', 'smcd']
			assert_equal(@plugin.casrns(row), [])
			row = ['NAME', '11-11-11', 'pcode', 'smcd']
			assert_equal(['11-11-11'], @plugin.casrns(row))
		end
		def test_smcd
			row = ['NAME', 'casrn', 'pcode', '7680543210079']
			assert_equal('54321007', @plugin.smcd(row))
			row = ['NAME', 'casrn', 'pcode', nil]
			assert_nil(@plugin.smcd(row))
			row = ['NAME', 'casrn', 'pcode', ''] 
			assert_nil(@plugin.smcd(row))
			row = ['NAME', 'casrn', 'pcode', 'nil'] 
			assert_nil(@plugin.smcd(row))
		end
		def test_category
			row = ['NAME', 'casrn', 'pcode', 'eancode', 'company', 'c']
			assert_equal('c', @plugin.category(row))
			row = ['NAME', 'casrn', 'pcode', 'eancode', 'company', '']
			assert_equal('a', @plugin.category(row))
		end
		def test_report_text
			row = ['name','text1','text2','text3','text4']
			expected = "name\ntext1 | text2 | text3 | text4\n"
			assert_equal(expected, @plugin.report_text(row))
		end
		def test_update_narcotic
			row = ["Dextropropoxyphenhaltige","- - - - -","- - - - -",
				"- - - - -","- - - - -","c"]
      res = @plugin.update_narcotic(row, 'casrn', :de)
      assert_nil res
      expected = { "Dextropropoxyphen" => "Dextropropoxyphenhaltige" }
      assert_equal expected, @plugin.instance_variable_get('@narcotic_texts')
		end
    def test_update_narcotic__else
      narcotic = flexmock('narcotic', :pointer => 'pointer')
      flexmock(@app, 
               :update => 'update',
               :narcotic_by_casrn => narcotic
              )
      row = [0,1,2,3,4,'d']
      assert_equal('update', @plugin.update_narcotic(row, 'casrn', :de))
    end
    def test_update_narcotic__no_narcotic
      narcotic = flexmock('narcotic')
      flexmock(@app, 
               :update => 'update',
               :narcotic_by_casrn => nil,
               :narcotic_by_smcd  => nil
              )
      row = [0,1,2,3,4,'d']
      assert_equal('update', @plugin.update_narcotic(row, 'casrn', :de))
    end

		def test_narcotic_text
			text = "Codeinhaltige"
			assert_equal("Codein", @plugin.text2name(text, :de))
			text = "Les préparations contenant du dextropropoxyphène sont" 
			assert_equal("dextropropoxyphène", @plugin.text2name(text, :fr))
		end	
		def test_name
			row = ['Codein', 'casrn', 'pcode', '7680543210079']
			assert_equal('Codein', @plugin.name(row))
			row = [nil, 'casrn', 'pcode', '7680543210079']
			assert_equal('', @plugin.name(row))
		end
		def test_name_substance
			row = ['Codein (unter Vorbehalt von)', 'casrn', 'pcode', '7680543210079']
			assert_equal('Codein', @plugin.strip_name(row).at(0).strip)
			row = ['Codein-Oxid-H2O', 'casrn', 'pcode', '7680543210079']
			assert_equal('Codein-Oxid-H2O', @plugin.strip_name(row).at(0))
		end
    def test_update_package
      package = flexmock('package', 
                         :odba_store   => nil,
                         :add_narcotic => nil,
                         :pointer      => 'pointer'
                        )
      registration = flexmock('registration', :package => package)
      flexmock(@app, :registration => registration)
      narcs = {'123' => 'narc'}
      @plugin.instance_eval('@narcs = narcs')
      row = [0,'123',2,'7680123456789']
      assert_equal(nil, @plugin.update_package(row, 'language'))
    end
    def test_update_package__unknown_package
      flexmock(Package, :find_by_pharmacode => nil)
      registration = flexmock('registration', :package => nil)
      flexmock(@app, :registration => registration)
      narcs = {'123' => 'narc'}
      @plugin.instance_eval('@narcs = narcs')

      row = ['0','123', 'pcode', '7680123456789']
      expected = ["0\n123 | pcode | 7680123456789\n"]
      assert_equal(expected, @plugin.update_package(row, 'language'))
    end
    def test_update_package__unknown_registration
      flexmock(@app, :registration => nil)
      row = ['0']
      assert_equal(["0\n\n"], @plugin.update_package(row, 'language'))
    end
    def test_update_substance
      substance = flexmock('substance', :pointer => 'pointer')
      flexmock(@app, 
               :substance_by_smcd => substance,
               :update => nil
              )
      row = ['name ( voir )',1,2,'7680123456789']
      assert_equal(nil, @plugin.update_substance(row, 'casrn', 'narc', 'language'))
    end
    def test_update_substance__else
      substance = flexmock('substance', :pointer => 'pointer')
      flexmock(@app, 
               :update    => substance,
               :substance => nil,
               :substance_by_smcd => nil
              )
      row = ['name ( voir )',1,2,'7680123456789']
      assert_equal(substance, @plugin.update_substance(row, 'casrn', 'narc', 'language'))
    end
    def test_update_narcotic_texts
      flexmock(@app, :update => nil)
      narcotic_texts = {'name' => 'text'}
      @plugin.instance_eval('@narcotic_texts = narcotic_texts')
      pointer = flexmock('pointer', :creator => nil)
      flexmock(pointer, :+ => pointer)
      narcotic = flexmock('narcotic', :pointer => pointer)
      substance = flexmock('substance', 
                           :language => 'name',
                           :narcotic => narcotic
                          )
      reserve_substances = [substance]
      @plugin.instance_eval('@reserve_substances = reserve_substances')
      assert_equal({"name"=>"text"}, @plugin.update_narcotic_texts('language'))
    end
    def test_report
      expected = "Narcotics: 0\nNarcotics with CASRN: 0\nPackages with Narcotics: 0\nUnknown registrations: 0\nUnknown packages: 0\nCreated Substances: 0\nCreated Narcotics: 0\nCreated Narcotic Texts: 0\nRemoved Narcotics 0\n\n\nName\nCasrn | Pharmacode | Ean-Code | Company | Level\n\n\nUnknown registrations: 0\n\n\n\n\nUnknown packages: 0\nPackungen, die weder anhand des Swissmedic-Codes noch anhand des\nPharmacodes in der ODDB gefunden wurden. Kann auch ausser-Handel\nPackungen beinhalten.\nDiese Produkte werden in ch.oddb.org nicht angezeigt (zu wenig Informationen).\n\n\n\n\nNew substances: 0\n\n\n\n\nNew Narcotic Texts: 0\n\n\n\n\nRemoved Narcotics 0\n\n"
      assert_equal(expected, @plugin.report)
    end
    def test_report_text
      row = [nil, 'row', 'row']
      expected = " | row | row\n"
      assert_equal(expected, @plugin.report_text(row))
    end
    def test_text2name__error
      assert_raise(RuntimeError) do 
        @plugin.text2name('text', :jp)
      end
    end
    def test_prune_narcotics
      narcotic = flexmock('narcotic', 
                          :casrn           => 'casrn',
                          :category        => 'category'
                         )
      package  = flexmock('package', 
                          :narcotics       => [narcotic],
                          :pointer         => 0,
                          :include?        => nil,
                          :remove_narcotic => nil,
                          :name_base       => 'name_base',
                          :pharmacode      => 'pharmacode',
                          :barcode         => 'barcode',
                          :company_name    => 'company_name'
                         )
      @app.should_receive(:each_package).and_yield(package)
      updated_packages = [package]
      @plugin.instance_eval('@updated_packages = updated_packages')
      assert_equal(nil, @plugin.prune_narcotics)
    end
    def test_prune_narcotics__narcs_not_empty
      narcotic = flexmock('narcotic', 
                          :casrn           => 'casrn',
                          :category        => 'category',
                          :pointer         => nil
                         )
      package  = flexmock('package', 
                          :narcotics       => [narcotic],
                          :pointer         => 0,
                          :include?        => nil,
                          :remove_narcotic => nil,
                          :name_base       => 'name_base',
                          :pharmacode      => 'pharmacode',
                          :barcode         => 'barcode',
                          :company_name    => 'company_name'
                         )
      flexmock(@app) do |a|
        a.should_receive(:each_package).and_yield(package)
        a.should_receive(:narcotics).and_return({'oid' => narcotic})
        a.should_receive(:delete)
      end
      updated_packages = [package]
      @plugin.instance_eval('@updated_packages = updated_packages')
      narcs = ['narcs']
      @plugin.instance_eval('@narcs = narcs')
      expected = {"oid" => narcotic}
      assert_equal(expected, @plugin.prune_narcotics)
    end
    def test_process_row
      row = [0,1,2,'7680123456789']
      expected = [[0, 1, 2, "7680123456789"]]
      assert_equal(expected, @plugin.process_row(row, :de))
    end
    def test_process_row__not_switzerland
      narcotic  = flexmock('narcotic', :pointer => 'pointer')
      update    = flexmock('update', :oid => 'oid')
      substance = flexmock('substance', :pointer => 'pointer')
      flexmock(@app, 
               :update => update,
               :narcotic_by_casrn => narcotic,
               :substance_by_smcd => substance
              )
      row = [0,'1/2',2,'7611123456789']
      assert_equal(update, @plugin.process_row(row, :de))
    end

	end
end

class TestNarcoticHandler < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    callback = Proc.new{'callback'}
    @handler = ODDB::NarcoticHandler.new(callback)
  end
  def test_send_page
    line = ['name', 'casrn', 'third']
    @handler.instance_eval('@lines[0] = line')
    expected = [["name", nil, nil, nil, "casrn", nil]]
    assert_equal(expected, @handler.send_page)
  end
  def test_send_page__casrn_empty
    line = [' 1-2-3 ', '', 'third']
    @handler.instance_eval('@lines[0] = line')
    assert_equal([], @handler.send_page)
  end
  def test_send_page__match_third
    line = ['name', 'casrn', ' 1-2-3 ']
    @handler.instance_eval('@lines[0] = line')
    expected = [["name casrn", "1-2-3", nil, nil, nil, nil]]
    assert_equal(expected, @handler.send_page)
  end
  def test_send_page__compact_size_1
    line = ['name', 'casrn', 'third']
    @handler.instance_eval('@lines[0] = line')
    @handler.instance_eval('@lines[1] = line')
    expected = [
        ["name", nil, nil, nil, "casrn casrn", nil],
        ["name", nil, nil, nil, "casrn", nil]
    ]
    assert_equal(expected, @handler.send_page)
  end
end

