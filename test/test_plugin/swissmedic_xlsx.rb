#!/usr/bin/env ruby
# encoding: utf-8

# We ignore registration 00277, 47066, 57678 which
# we used for testing the atc_less

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'minitest/unit'
require 'stub/odba'
require 'util/persistence'
require 'plugin/swissmedic'
require 'model/registration'
require 'model/sequence'
require 'model/package'
require 'model/galenicgroup'
require 'model/composition'
require 'flexmock'
require 'ostruct'
require 'tempfile'
require 'util/log'
require 'util/util'
require 'util/oddbconfig'
require 'stub/oddbapp'

begin
  require 'pry';
rescue LoadError
end

class FlexMock::TestUnitFrameworkAdapter
    attr_accessor :assertions
end

module ODDB

  class SwissmedicPluginTestXLSX < Minitest::Test
    include FlexMock::TestCase

    def setup
      ODDB::GalenicGroup.reset_oids
      ODBA.storage.reset_id
      @app = flexmock(ODDB::App.new)
      @archive = File.expand_path('../var', File.dirname(__FILE__))
      FileUtils.rm_rf(@archive)
      FileUtils.mkdir_p(@archive)
      @latest = File.join @archive, 'xls', 'Packungen-latest.xlsx'
      @plugin = SwissmedicPlugin.new @app, @archive
      @current  = File.expand_path '../data/xlsx/Packungen-2015.07.02.xlsx', File.dirname(__FILE__)
      @older    = File.expand_path '../data/xlsx/Packungen-2015.06.04.xlsx', File.dirname(__FILE__)
      @target   = File.join @archive, 'xls',  @@today.strftime('Packungen-%Y.%m.%d.xlsx')
      FileUtils.makedirs(File.dirname(@latest)) unless File.exists?(File.dirname(@latest))
      FileUtils.rm(@latest) if File.exists?(@latest)
    end
    def teardown
      super # to clean up FlexMock
    end
    def setup_index_page
      link = flexmock('link', :href => 'href')
      links = flexmock('links', :select => [link])
      page = flexmock('page', :links => links)
      index = flexmock 'index'
      link1 = OpenStruct.new :attributes => {'title' => 'Packungen'},
                             :href => 'url'
      link2 = OpenStruct.new :attributes => {'title' => 'Something'},
                             :href => 'other'
      link3 = OpenStruct.new :attributes => {'title' => 'Präparateliste'},
                             :href => 'url'
      index.should_receive(:links).and_return [link1, link2, link3]
      index.should_receive(:body).and_return(IO.read(@current))
      agent = flexmock(Mechanize.new)
      agent.should_receive(:user_agent_alias=).and_return(true)
      agent.should_receive(:get).and_return(index)
      uri = 'http://www.example.com'
      [agent, page]
    end

    def check_agents(sequences)
      sequences.each {
        |seq|
        seq.compositions.each{
                             |comp|
                            comp.active_agents.each{
                                                    |agent|
                                                   unless agent.is_active_agent
                                                    puts "Expected true for is_active_agent in #{seq.iksnr}/#{seq.seqnr} #{agent.substance}"
                                                    pp agent
                                                    assert(false, "Expected true for is_active_agent in #{seq.iksnr}/#{seq.seqnr} #{agent.substance}")
                                                   end
                                                   }
                            comp.inactive_agents.each{
                                                    |agent|
                                                   if agent.is_active_agent
                                                    pp agent
                                                    assert(false, "Expected false for is_active_agent in #{seq.iksnr}/#{seq.seqnr} #{agent.substance}")
                                                   end
                                                   }
                            }
      }
    end

    def add_influvac
      reg = @app.create_registration('00485')
      seq = reg.create_sequence('26')
      seq.create_package('007')
      seq.create_package('008')

    end

    def test_july_2015
      agent, page = setup_index_page
      # Use first the last month and compare it to a non existing lates
      FileUtils.rm(Dir.glob("#{File.dirname(@latest)}/*"), :verbose => true)
      FileUtils.cp(@older, File.dirname(@latest), :verbose => true, :preserve => true)
      FileUtils.cp(@current, @target, :verbose => true, :preserve => true)
      FileUtils.cp(@older, @latest, :verbose => true, :preserve => true)

 # OddbPrevalence::registration(00278,sequence,01)
      newest  = @current.clone
      @adata = @older.clone
      assert_equal(0, @app.registrations.size)
      reg = @app.create_registration('00278')
      reg.pointer = Persistence::Pointer.new([:registration, '00278'])
      seq = reg.create_sequence('01')
      seq.composition_text = 'composition_text'
      seq.pointer = Persistence::Pointer.new([:registration, '00278', :sequence, '01'])
      seq.name_base = 'Colon Sérocytol, suppositoire'
      seq.name_descr = 'name_descr'
      seq.dose = nil
      seq.pointer = Persistence::Pointer.new([:registration, '00278', :sequence, '01'])
      seq.sequence_date = Date.new(2017,5,9)
      seq.export_flag = false
      seq.atc_class = ODDB::AtcClass.new('AB0')
      seq.indication = 'indication'
      seq.create_package('001')
      seq.create_package('002')

      reg = @app.create_registration('00279')
      seq = reg.create_sequence('01')
      seq.create_package('001')
      seq.create_package('002')

      reg = @app.create_registration('00288')
      seq = reg.create_sequence('02')
      seq.create_package('001')
      @app.should_receive(:delete).never # Registrations don't get deleted, just out of date. And now substances nor active_agents should be deleted neither

      result = @plugin.update({:update_compositions => true}, agent)
      assert_equal(3, @app.registrations.size)
      assert_equal(3, @app.sequences.size)
      assert_equal(5, @app.packages.size)
      assert_equal(true, result)
      check_agents(@app.sequences)

      add_influvac # this sequence must be delete
      assert_equal('26', @app.registration('00485').sequence('26').seqnr)
      assert_equal(2, @app.registration('00485').active_packages.size)
      assert_equal(4, @app.registrations.size)
      assert_equal(4, @app.sequences.size)
      assert_equal(7, @app.packages.size)

      puts "\nStarting second_run\n\n"
      result_second_run = @plugin.update({}, agent)
      puts @plugin.report
      assert File.exist?(@target), "#@target was not saved"
      @app.registrations.each{ |reg| puts "reg #{reg[1].iksnr} with #{reg[1].sequences.size} sequences"} if $VERBOSE
      assert(result_second_run)

      assert_equal(8, @app.registrations.size)

      assert_equal({"00278"=>[:company], "48624"=>[:new], "62069"=>[:new], "16105"=>[:new], "00488"=>[:new], "00279"=>[:delete]}, result_second_run.changes)
      missing = {}
      @app.registrations.each{
        |id, reg|
        reg.sequences.each{
                         |seq_id, seq|
                          seq.packages.each{
                                            |pack_id, pack|
                                           if pack.sequence and not pack.sequence.respond_to?(:odba_id)
                                            missing["#{id}/#{seq_id}/#{pack_id}"] = pack
                                           end
                                           }
                          }
      }
      assert_equal(0, missing.size)
      check_agents(@app.sequences)

      # Check that influvac is expired
      assert_equal('26', @app.registration('00485').sequence('26').seqnr)
      assert_equal(0, @app.registration('00485').active_packages.size)
      assert_equal(0, @app.registration('00485').packages.size)
      assert_equal(10, @app.sequences.size)
      assert_equal(14, @app.packages.size)
      assert_equal(12, @app.active_packages.size)
    end

    def test_mustcheck
      agent = flexmock(Mechanize.new)
      assert_equal(true, @plugin.mustcheck('46111', {:iksnrs => ['46111']}))
      assert_equal(true, @plugin.mustcheck('46112', {:iksnrs => ['46111', '46112']}))
      assert_equal(true, @plugin.mustcheck('46112', {:update_compositions => true}))

      assert_equal(false, @plugin.mustcheck('46112', {:iksnrs => ['46111']}))
    end

  end

end
