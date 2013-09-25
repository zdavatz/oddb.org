#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::WhoPluginTest -- oddb.org -- 12.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'plugin/who'

module ODDB
  class WhoPlugin < Plugin
    class TestCodeHandler <Minitest::Test
      include FlexMock::TestCase
      def setup
        @handler = ODDB::WhoPlugin::CodeHandler.new
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
    include FlexMock::TestCase
    def setup
      datadir = File.expand_path '../data/html/who', File.dirname(__FILE__)
      mechanize = Mechanize.new
      path = File.join datadir, 'atc_ddd.html'
      mechanize_get = mechanize.get('file://' + path)
      @agent  = flexmock('agent', :get => mechanize_get)
      @app    = flexmock('app')
      @plugin = ODDB::WhoPlugin.new(@app)
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
      link = flexmock('link', :inner_text => 'inner_text')
      assert_equal('update', @plugin.import_atc('code', link))
    end
    def test_import_atc__no_atc_class
      flexmock(@app, 
               :atc_class => nil,
               :update    => 'update'
              )
      link = flexmock('link', :inner_text => 'inner_text')
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
        t.should_receive(:/).and_return([node])
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
      flexmock(table, :/ => [node])
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
      pointer = flexmock('pointer', :creator => 'creator')
      ddd = flexmock('ddd', :pointer => pointer)
      atc = flexmock('atc', 
                     :code => nil,
                     :ddd  => ddd
                    )
      assert_equal(nil, @plugin.import_ddds(atc, row))
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
      atc = flexmock('atc', 
                     :code => nil,
                     :ddd  => nil,
                     :pointer => pointer
                    )
      assert_equal(nil, @plugin.import_ddds(atc, row))
    end
    def test_import_code
      pointer = flexmock('pointer', :creator => 'creator')
      flexmock(pointer, :+ => pointer)
      atc = flexmock('atc', 
                     :guidelines => nil,
                     :pointer    => pointer
                    )
      flexmock(@app, :update => atc)
      flexmock(@app, :atc_class => atc)
      assert_equal(0, @plugin.import_code(@agent, 'A'))
    end
    def test_report
      expected = "Imported   0 ATC-Codes\nUpdated    0 English descriptions\nUpdated    0 Guidelines\nUpdated    0 DDD-Guidelines"
      assert_equal(expected, @plugin.report)
    end
    def test_import
      pointer = flexmock('pointer', :creator => 'creator')
      flexmock(pointer, :+ => pointer)
      atc = flexmock('atc', 
                     :guidelines => nil,
                     :pointer    => pointer
                    )
      flexmock(@app, :update => atc)
      flexmock(@app, :atc_class => atc)
      expected = "Imported  30 ATC-Codes\nUpdated    0 English descriptions\nUpdated    1 Guidelines\nUpdated    0 DDD-Guidelines"
      assert_equal(expected, @plugin.import(@agent))
    end
  end
end
