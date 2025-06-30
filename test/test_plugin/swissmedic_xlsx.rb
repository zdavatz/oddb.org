#!/usr/bin/env ruby
# encoding: utf-8

# We ignore registration 00277, 47066, 57678 which
# we used for testing the atc_less

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'minitest/unit'
require 'flexmock/minitest'
require 'test_helpers' # for VCR setup
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
      ODDB::TestHelpers.vcr_setup
      @app = flexmock(ODDB::App.new)
      @archive = ODDB::WORK_DIR
      FileUtils.rm_rf(@archive)
      FileUtils.mkdir_p(@archive)
      @latest = File.join @archive, 'xls', 'Packungen-latest.xlsx'
      @plugin = flexmock('plugin', SwissmedicPlugin.new(@app, @archive))
      @bag_listen  = File.join(ODDB::TEST_DATA_DIR, 'html/listen_neu.html')
      @current  = File.join(ODDB::TEST_DATA_DIR, 'xlsx/Packungen-2019.01.31.xlsx')
      @target   = File.join @archive, 'xls',  @@today.strftime('Packungen-%Y.%m.%d.xlsx')
      @plugin.should_receive(:fetch_with_http).with('https://www.swissmedic.ch/swissmedic/de/home/services/listen_neu.html').and_return(File.open(@bag_listen).read).by_default
      @plugin.should_receive(:open).with( ODDB::SwissmedicPlugin.get_packages_url).and_return(File.open(@current).read).by_default
      @prep_from = File.join(ODDB::TEST_DATA_DIR, 'xlsx/Erweiterte_Arzneimittelliste_HAM_31012019.xlsx')
      FileUtils.cp(@prep_from, File.join(@archive, 'xls', 'Erweiterte_Arzneimittelliste_HAM_31012019.xlsx'),
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
