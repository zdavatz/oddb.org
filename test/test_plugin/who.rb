#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::WhoPluginTest -- oddb.org -- 12.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'flexmock/minitest'
require 'stub/odba'
require 'stub/oddbapp'
require 'plugin/who'
begin
require 'pry'
rescue LoadError
end

module ODDB
  class WhoPlugin < Plugin
    class TestCodeHandler <Minitest::Test
      def setup
        @handler = ODDB::WhoPlugin::CodeHandler.new
      end
      def teardown
        super
      end
      def test_push
        expected = ["A", "B", "C", "D", "G", "H", "J", "L", "M", "N", "P", "R", "S", "V", "code"]
        assert_equal(expected, @handler.push('code'))
      end
      def test_shift
        assert_equal('A', @handler.shift)
      end
    end
  end

  class TestWhoPlugin <Minitest::Test
    def teardown
      super
    end
    def setup
      @datadir = File.expand_path '../data/html/who', File.dirname(__FILE__)
      mechanize = Mechanize.new
      path = File.join @datadir, 'atc_ddd.html'
      mechanize_get = mechanize.get('file://' + path)
      @agent  = flexmock('agent')
      @agent.should_receive(:get).and_return do |args|
        mechanize.get('file://' + path)
      end
      @app = flexmock('app', ODDB::App.new)
      @plugin = ODDB::WhoPlugin.new(@app)
      @code2tst = 'N05AX08'
      @atc = @app.create_atc_class(@code2tst)
      @atc.pointer = Persistence::Pointer.new([:atc_class, @atc.code.to_sym])
    end
    def test_capitalize_all
      assert_equal('Str', @plugin.capitalize_all('str'))
    end
    def test_extract_text
      child = flexmock('child', :element? => nil)
      node  = flexmock('node', 
                       :children   => [child],
                       :inner_html => 'html'
                      )
      assert_equal('html', @plugin.extract_text(node))
    end
    def test_import_atc
      pointer   = flexmock('pointer', :creator => 'creator')
      atc_class = flexmock('atc_class', :pointer => pointer)
      flexmock(@app, 
               :atc_class => atc_class,
               :update    => 'update'
              )
      link = flexmock('link', :inner_text => 'inner_text', :split => ['split'])
      assert_equal('update', @plugin.import_atc('code', link))
    end
    def test_import_atc__no_atc_class
      flexmock(@app, 
               :atc_class => nil,
               :update    => 'update'
              )
      link = flexmock('link', :inner_text => 'inner_text', :split => ['split'])
      assert_equal('update', @plugin.import_atc('code', link))
    end
    def test_import_ddd_guidelines
      flexmock(@app, :update => 'update')
      ddd_guidelines = flexmock('ddd_guidelines', :en => 'en')
      pointer = flexmock('pointer', :creator => 'creator')
      flexmock(pointer, :+ => pointer)
      atc   = flexmock('atc', 
                       :ddd_guidelines => ddd_guidelines,
                       :pointer        => pointer
                      )
      child = flexmock('child', :element? => nil)
      node  = flexmock('node', 
                       :children   => [child],
                       :inner_html => 'html'
                      )
      table = flexmock('table') do |t|
        t.should_receive(:/).and_return([node]) # /
      end
      assert_equal(true, @plugin.import_ddd_guidelines(atc, table))
    end
    def test_import_guidelines
      flexmock(@app, :update => 'update')
      ddd_guidelines = flexmock('ddd_guidelines', :en => 'en')
      pointer = flexmock('pointer', :creator => 'creator')
      flexmock(pointer, :+ => pointer)
      atc   = flexmock('atc', 
                       :ddd_guidelines => ddd_guidelines,
                       :pointer        => pointer,
                       :guidelines     => nil
                      )
      child = flexmock('child', :element? => nil)
      table = flexmock('table', :name => nil)
      node  = flexmock('node', 
                       :children   => [child],
                       :inner_html => 'html',
                       :name       => 'p',
                       :next_sibling => table
                      )
      link = flexmock('link', :parent => node)
 
      assert_equal(true, @plugin.import_guidelines(atc, link))
    end
    def test_import_guidelines__import_ddd_guidelines
      flexmock(@app, :update => 'update')
      ddd_guidelines = flexmock('ddd_guidelines', :en => 'en')
      pointer = flexmock('pointer', :creator => 'creator')
      flexmock(pointer, :+ => pointer)
      atc   = flexmock('atc', 
                       :ddd_guidelines => ddd_guidelines,
                       :pointer        => pointer,
                       :guidelines     => nil
                      )
      child = flexmock('child', :element? => nil)
      table = flexmock('table', 
                       :name => 'table',
                       :[]   => '#cccccc'
                      )
      node  = flexmock('node', 
                       :children   => [child],
                       :inner_html => 'html',
                       :name       => 'p',
                       :next_sibling => table
                      )
      flexmock(table, :/ => [node]) # /
      link = flexmock('link', :parent => node)
 
      assert_equal(true, @plugin.import_guidelines(atc, link))
    end
    def test_import_ddds
      flexmock(@app, :update => 'update')
      child = flexmock('child', :element? => nil)
      code  = flexmock('code', :children   => [child], :inner_html => '')
      link  = flexmock('link', :children   => [child], :inner_html => 'link')
      dose  = flexmock('dose', :children   => [child], :inner_html => 'dose')
      unit  = flexmock('unit', :children   => [child], :inner_html => 'unit')
      adm   = flexmock('adm', :children   => [child], :inner_html => 'adm')
      comment  = flexmock('comment', :children   => [child], :inner_html => 'comment')

      row = flexmock('row', 
                     :children => [code, link, dose, unit, adm, comment],
                     :next_sibling => nil
                    )
      assert_nil(@plugin.import_ddds(@atc, row))
    end
    def test_import_ddds__atc_pointer
      flexmock(@app, :update => 'update')
      child = flexmock('child', :element? => nil)
      code  = flexmock('code', :children   => [child], :inner_html => '')
      link  = flexmock('link', :children   => [child], :inner_html => 'link')
      dose  = flexmock('dose', :children   => [child], :inner_html => 'dose')
      unit  = flexmock('unit', :children   => [child], :inner_html => 'unit')
      adm   = flexmock('adm', :children   => [child], :inner_html => 'adm')
      comment  = flexmock('comment', :children   => [child], :inner_html => 'comment')

      row = flexmock('row', 
                     :children => [code, link, dose, unit, adm, comment],
                     :next_sibling => nil
                    )
      pointer = flexmock('pointer', :creator => 'creator')
      flexmock(pointer, :+ => pointer)
      assert_nil(@plugin.import_ddds(@atc, row))
    end
    def test_import_code
      pointer = flexmock('pointer', :creator => 'creator')
      flexmock(pointer, :+ => pointer)
      atc = flexmock('atc', 
                     :ddds => {},
                     :guidelines => nil,
                     :pointer    => pointer
                    )
      flexmock(@app, :update => atc)
      flexmock(@app, :atc_class => atc)
      assert_equal(0, @plugin.import_code(@agent, 'A'))
    end
    def test_report
      expected = "Imported   0 ATC-Codes\nCreated    0 English descriptions\nUpdated    0 Guidelines\nUpdated    0 DDD-Guidelines\nRepaired   0 wrong sequences\n"
      assert_equal(expected, @plugin.report)
    end
    def test_import
      pointer = flexmock('pointer', :creator => 'creator')
      flexmock(pointer, :+ => pointer)
      atc = flexmock('atc',
                     :guidelines => nil,
                     :pointer    => pointer
                    )
      a_hash = Hash.new
      atc_hash = flexmock(a_hash, 'my_atc_hash', :keys => a_hash.keys,
                          :each => a_hash.each,
                          :odba_store => 'odba_store',)
      atc_classes = flexmock('atc_classes', :odba_store => 'odba_store',
                             :keys => atc_hash.keys,
                             :each => atc_hash.each,
                             )
      flexmock(@app, :update => atc)
      flexmock(@app, :atc_class => atc, :atc_classes => atc_hash)
      expected = "Imported  31 ATC-Codes\nCreated    0 English descriptions\nUpdated    1 Guidelines\nUpdated    0 DDD-Guidelines\nRepaired   0 wrong sequences\n"
      assert_equal(expected, @plugin.import(@agent))
    end
    def test_import_repairs
      @app    = flexmock('appxx')
      @plugin = ODDB::WhoPlugin.new(@app)
      pointer = flexmock('pointer', :creator => 'creator')
      flexmock(pointer, :+ => pointer)
      atc = flexmock('atc',
                     :guidelines => nil,
                     :pointer    => pointer
                    )
      @a_hash = Hash.new
      atc_hash = flexmock(@a_hash, 'my_atc_hash',
                          :keys => @a_hash.keys,
                          :each => @a_hash.each,
                          :odba_store => 'odba_store',)
      atc_hash.should_receive(:[]=).and_return { |key, value| @a_hash[key] = value; puts @a_hash.inspect }
      atc_classes = flexmock(atc_hash, :odba_store => 'odba_store', :each => atc_hash.each)
      flexmock(@app, :update => atc)
      atc_class = flexmock('atc_class', :repair_needed? => true,
                          :odba_store => 'odba_store',
                          :pointer => pointer)
      atc_class14 = flexmock('atc_class14', :repair_needed? => true,
                          :odba_store => 'odba_store',
                          :pointer => pointer)
      flexmock(@app, :atc_classes => atc_classes)
      @app.should_receive(:atc_class).and_return { atc_class }
      result = @plugin.import(@agent)
      m = /Created\s+(\d+)\s+English/.match(result)
      assert_equal(0, m[1].to_i)
      assert_match('Imported  31 ATC-Codes', result)
      assert_match("Updated    1 Guidelines\n", result)
      skip "Don't know how to stub wrong sequences"
      assert_match("Repaired   1 wrong sequences\n", result)
    end
    def test_import_new_atc_code
      pointer = flexmock('pointer', :creator => 'creator')
      flexmock(pointer, :+ => pointer)
      atc_hash = Hash.new
      atc_classes = flexmock(atc_hash, :odba_store => 'odba_store', :each => atc_hash.each)
      flexmock(@app, :update => @atc)
      flexmock(@app, :atc_classes => atc_classes)
      @app.should_receive(:atc_class).and_return {|arg| atc_hash[arg] }
      expected = "Imported  31 ATC-Codes\nCreated    0 English descriptions\nUpdated    1 Guidelines\nUpdated    0 DDD-Guidelines\nRepaired   0 wrong sequences\n"
      result = @plugin.import(@agent)
      m = /Created\s+(\d+)\s+English/.match(result)
      assert(m[1].to_i > 0)
    end
    def test_import_delete_ddd_roa_P
      @app.atc_classes
      atc = @app.atc_class(@code2tst) || @app.create_atc_class(@code2tst)
      @app.atc_class(@code2tst).create_ddd('0')
      @app.atc_class(@code2tst).ddds['0'].dose = Quanty.new(5, 'mg')
      @app.atc_class(@code2tst).create_ddd('P')
      @app.atc_class(@code2tst).ddds['P'].dose = Quanty.new(2.7, 'mg')
      @app.atc_class(@code2tst).create_ddd('Pdepot')
      @app.atc_class(@code2tst).ddds['Pdepot'].dose = Quanty.new(1.8, 'mg')
      atc.pointer = Persistence::Pointer.new([:atc_class, @atc.code.to_sym])
      @app.atc_class(@code2tst).ddds.each {|key, value| value.pointer =  Persistence::Pointer.new(atc.pointer + [:ddd, key]) }
      pointer = flexmock('atc_pointer')
      atc_creator = flexmock('atc_creator')
      # atc_creator.should_receive(:issue_update).and_return(@app.atc_class(@code2tst))
      pointer.should_receive(:creator).and_return(atc_creator)
      pointer.should_receive(:+).and_return(pointer)
      expected = "Imported  31 ATC-Codes\nCreated    0 English descriptions\nUpdated    1 Guidelines\nUpdated    0 DDD-Guidelines\nRepaired   0 wrong sequences\n"
      @datadir = File.expand_path '../data/html/who', File.dirname(__FILE__)
      mechanize = Mechanize.new
      path = File.join @datadir, @code2tst+'.html'
      mechanize_get = mechanize.get('file://' + path)
      agent  = flexmock('agent')
      agent.should_receive(:get).and_return(mechanize_get)
      @app.should_receive(:update).at_least.once.and_return(@app.atc_class(@code2tst))
      @plugin = ODDB::WhoPlugin.new(@app)
      result = @plugin.import(agent)
      m = /Created\s+(\d+)\s+English/.match(result)
      assert(m[1].to_i > 0)
      assert_equal(['O', 'Pdepot'], @app.atc_class(@code2tst).ddds.keys.sort)
    end
    def test_import_add_ddd_roa_P
      @app.atc_classes
      atc = @app.atc_class(@code2tst) || @app.create_atc_class(@code2tst)
      @app.atc_class(@code2tst).create_ddd('0')
      @app.atc_class(@code2tst).ddds['0'].dose = Quanty.new(5, 'mg')
      atc.pointer = Persistence::Pointer.new([:atc_class, @atc.code.to_sym])
      @app.atc_class(@code2tst).ddds.each {|key, value| value.pointer =  Persistence::Pointer.new(atc.pointer + [:ddd, key]) }
      pointer = flexmock('atc_pointer')
      atc_creator = flexmock('atc_creator')
      pointer.should_receive(:creator).and_return(atc_creator)
      pointer.should_receive(:+).and_return(pointer)
      expected = "Imported  31 ATC-Codes\nCreated    0 English descriptions\nUpdated    1 Guidelines\nUpdated    0 DDD-Guidelines\nRepaired   0 wrong sequences\n"
      @datadir = File.expand_path '../data/html/who', File.dirname(__FILE__)
      mechanize = Mechanize.new
      path = File.join @datadir, @code2tst+'.html'
      mechanize_get = mechanize.get('file://' + path)
      agent  = flexmock('agent')
      agent.should_receive(:get).and_return(mechanize_get)
      @app.should_receive(:update).at_least.times(4).and_return(@app.atc_class(@code2tst))
      @plugin = ODDB::WhoPlugin.new(@app)
      result = @plugin.import(agent)
      m = /Created\s+(\d+)\s+English/.match(result)
      assert(m[1].to_i > 0)
      assert_equal(['O', 'Pdepot'], @app.atc_class(@code2tst).ddds.keys.sort)
    end
  end
end
