#!/usr/bin/env ruby
# encoding: utf-8

# We ignore registration 00277, 47066, 57678 which
# we used for testing the atc_less

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'minitest/unit'
require 'flexmock/minitest'
require 'test_helpers'
require 'stub/odba'
require 'util/persistence'
require 'plugin/swissmedic'
require 'model/registration'
require 'model/sequence'
require 'model/package'
require 'model/galenicgroup'
require 'model/composition'
require 'ostruct'
require 'tempfile'
require 'util/log'
require 'util/util'
require 'util/oddbconfig'
require 'stub/oddbapp'

begin  require 'debug'; rescue LoadError; end # ignore error when debug cannot be loaded (for Jenkins-CI)

class FlexMock::TestUnitFrameworkAdapter
    attr_accessor :assertions
end

module ODDB

  class SwissmedicPluginTestXLSX < Minitest::Test

    def setup
      ODDB::GalenicGroup.reset_oids
      ODBA.storage.reset_id
      mock_downloads
      @app = flexmock(ODDB::App.new)
      @archive = ODDB::WORK_DIR
      FileUtils.rm_rf(@archive)
      FileUtils.mkdir_p(@archive)
      @latest = File.join @archive, 'xls', 'Packungen-latest.xlsx'
      @older    = File.join(ODDB::TEST_DATA_DIR, 'xlsx/Packungen-2015.07.02.xlsx')
      @plugin = flexmock('plugin', SwissmedicPlugin.new(@app, @archive))
      @bag_listen  = File.join(ODDB::TEST_DATA_DIR, 'html/listen_neu.html')
      @current  = File.join(ODDB::TEST_DATA_DIR, 'xlsx/Packungen-2019.01.31.xlsx')
      @target   = File.join @archive, 'xls',  @@today.strftime('Packungen-%Y.%m.%d.xlsx')
      @plugin.should_receive(:fetch_with_http).with('https://www.swissmedic.ch/swissmedic/de/home/services/listen_neu.html').and_return(File.open(@bag_listen).read).by_default
      @plugin.should_receive(:open).with( ODDB::SwissmedicPlugin.get_packages_url).and_return(File.open(@current).read).by_default
      @prep_from = File.join(ODDB::TEST_DATA_DIR, 'xlsx/Erweiterte_Arzneimittelliste_HAM_31012019.xlsx')
      FileUtils.cp(@prep_from, File.join(@archive, 'xls',  @@today.strftime('Erweiterte_Arzneimittelliste_HAM_31012019.xlsx')),
                   :verbose => true, :preserve => true)
      FileUtils.cp(@prep_from, File.join(@archive, 'xls', 'Erweiterte_Arzneimittelliste_HAM_31012019.xlsx^'),
                   :verbose => true, :preserve => true)
      @plugin.should_receive(:fetch_with_http).with( ODDB::SwissmedicPlugin.get_preparations_url).and_return(File.open(@prep_from).read).by_default
      FileUtils.makedirs(File.dirname(@latest)) unless File.exist?(File.dirname(@latest))
      FileUtils.rm(@latest) if File.exist?(@latest)
      puts  ODDB::SwissmedicPlugin.get_preparations_url
      assert_equal('https://www.swissmedic.ch/dam/swissmedic/de/dokumente/internetlisten/zugelassene_packungen_ham.xlsx.download.xlsx/Zugelassene_Packungen%20HAM_31012019.xlsx', ODDB::SwissmedicPlugin.get_packages_url)
      assert_equal('https://www.swissmedic.ch/dam/swissmedic/de/dokumente/internetlisten/erweiterte_ham.xlsx.download.xlsx/Erweiterte_Arzneimittelliste%20HAM_31012019.xlsx', ODDB::SwissmedicPlugin.get_preparations_url)
    end
    def teardown
      ODBA.storage = nil
      super # to clean up FlexMock
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
      # Use first the last month and compare it to a non existing lates
      FileUtils.rm(Dir.glob("#{File.dirname(@latest)}/*"), :verbose => true)
      FileUtils.cp(@older, @latest, :verbose => true, :preserve => true)
      FileUtils.cp(@current, @target, :verbose => true, :preserve => true)
      FileUtils.cp(@older, @latest, :verbose => true, :preserve => true)

 # OddbPrevalence::registration(00278,sequence,01)
      newest  = @current.clone
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
      reg = @app.create_registration('57678')
      seq = reg.create_sequence('01')
      seq.create_package('001')
      seq2 = reg.create_sequence('03')
      seq2.create_package('002')

      reg = @app.create_registration('00279')
      seq = reg.create_sequence('01')
      seq.create_package('001')
      seq.create_package('002')

      reg = @app.create_registration('00288')
      seq = reg.create_sequence('02')
      seq.create_package('001')
      @app.should_receive(:delete).at_least.times(4)

      reg = @app.create_registration('48624')
      seq = reg.create_sequence('02')
      seq.create_package('022')

      reg = @app.create_registration('62069')
      seq = reg.create_sequence('02')
      seq.create_package('009')

      @plugin.should_receive(:fetch_with_http).with(  ODDB::SwissmedicPlugin.get_packages_url).
        and_return(File.open(@current).read)
      result = @plugin.update({:update_compositions => true})

      assert_equal(6, @app.registrations.size)
      assert_equal(7, @app.sequences.size)
      assert_equal(9, @app.packages.size)
      assert_equal(true, result)
      check_agents(@app.sequences)

      add_influvac # this sequence must be delete
      assert_equal('26', @app.registration('00485').sequence('26').seqnr)
      assert_equal(2, @app.registration('00485').active_packages.size)
      assert_equal(7, @app.registrations.size)
      assert_equal(8, @app.sequences.size)
      assert_equal(11, @app.packages.size)
      reg = @app.create_registration('00488')
      seq = reg.create_sequence('02')
      seq.create_package('001')

      puts "\nStarting second_run with #{ODDB::SwissmedicPlugin.get_preparations_url}\n\n"
      @plugin.should_receive(:fetch_with_http).with(ODDB::SwissmedicPlugin.get_preparations_url).
        and_return(File.open(@prep_from).read)
      result_second_run = @plugin.update({})
      puts @plugin.report
      assert File.exist?(@target), "#@target was not saved"
      @app.registrations.each{ |reg| puts "reg #{reg[1].iksnr} with #{reg[1].sequences.size} sequences"} if $VERBOSE
      assert(result_second_run); assert_equal(41, @app.registrations.size)

     expected = {
            "00277"=>[:expiry_date, :production_science], "15219"=>[:new], "16598"=>[:new], "28486"=>[:new], "30015"=>[:new],
            "31644"=>[:new], "32475"=>[:new], "35366"=>[:new], "43454"=>[:new], "44625"=>[:new], "45882"=>[:new],
            "53290"=>[:new], "53662"=>[:new], "54015"=>[:new], "54534"=>[:new], "55558"=>[:new], "66297"=>[:new],
            "55594"=>[:new], "55674"=>[:new], "56352"=>[:new], "58943"=>[:new], "59267"=>[:new], "61186"=>[:new],
            "62069"=>[:atc_class, :expiry_date], "62132"=>[:new], "65856"=>[:new], "65857"=>[:new], "58734"=>[:new], "55561"=>[:new],
            "65160"=>[:new], "58158"=>[:new], "44447"=>[:new], "39252"=>[:new], "00278"=>[:delete], "48624"=>[:delete],
            "57678"=>[:delete], "00488"=>[:delete]}
      assert_equal(expected, result_second_run.changes)
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
      assert_equal(2, @app.registration('00485').active_packages.size)
      assert_equal(2, @app.registration('00485').packages.size)
      assert_equal(46, @app.sequences.size)
      assert_equal(54, @app.packages.size)
      assert_equal(48, @app.active_packages.size)
      res =  @app.active_sequences.collect{|s| s.compositions.collect {|c| c.active_agents.find_all{|a| a.is_active_agent == nil }}}
      assert_equal(0, res.flatten.size)
    end

  def set_is_active_agent element, value
    class << element
      attr_writer :is_active_agent
    end
    element.send("is_active_agent=", value)
  end
  def test_cleanup_active_agents_all_nil
    iksnr = '65432'
    seqnr = '01'
    packnr = '001'
    reg = @app.create_registration(iksnr)
    seq = reg.create_sequence(seqnr)
    pack = seq.create_package(packnr)
    comp = seq.create_composition
    assert_equal([], comp.active_agents)
    agent1 = comp.create_active_agent('agent1')
    assert_equal(true, agent1.is_active_agent)
    agent2 = comp.create_active_agent('agent2')
    assert_equal(true, agent2.is_active_agent)
    assert_equal([agent1, agent2], comp.active_agents)
    inactive = comp.create_inactive_agent('inactive')
    assert_equal(false, inactive.is_active_agent)
    assert_equal([agent1, agent2], comp.active_agents)
    set_is_active_agent(agent2, nil)
    assert_nil(agent2.is_active_agent)
    res = @plugin.cleanup_active_agents_with_nil
  end
end

end
