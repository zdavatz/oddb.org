#!/usr/bin/env ruby
# TestInteractionPlugin -- oddb -- 23.02.2004 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'plugin/interaction'
require 'util/html_parser'
require 'mock'
require 'flexmock'

module ODDB
	module Interaction
		class InteractionPlugin
			attr_accessor :hayes, :flockhart
			attr_accessor :hayes_conn_not_found, :flock_conn_not_found
			attr_accessor :updated_substances, :update_reports
			REFETCH_PAGES = false
		end
	end
  class TestInteractionPlugin < Test::Unit::TestCase
    def TestInteractionPlugin.cyt_hsh(cyt_range, option=nil)
      cyts = {}
      cyt_range.each { |dig|
        cyts.store("cyt_#{dig}", ODDB::Interaction::Cytochrome.new("cyt_#{dig}"))
      }
      cyts.each { |key, value|
        TestInteractionPlugin.add_types(value)
      }
      if(option=="links")
        cyts.values.each { |cyt|
          ODDB::Interaction::InteractionPlugin::INTERACTION_TYPES.each { |type|
            cyt.send(type).each { |conn|
              conn.add_link("conn_link")
            }
          }
        }
      end
      if(option=="categories")
        cyts.values.each { |cyt|
          ODDB::Interaction::InteractionPlugin::INTERACTION_TYPES.each { |type|
            cyt.send(type).each { |conn|
              conn.category="conn_cat"
            }
          }
        }
      end
      cyts
    end
    def TestInteractionPlugin.add_types(cyt)
      (1..2).each { |dig|
        cyt.substrates.push(ODDB::Interaction::SubstrateConnection.new("sub_#{dig}"))
      }
      (1..3).each { |dig|
        cyt.inhibitors.push(ODDB::Interaction::InhibitorConnection.new("inh_#{dig}"))
      }
      (1..4).each { |dig|
        cyt.inducers.push(ODDB::Interaction::InducerConnection.new("ind_#{dig}"))
      }
      cyt
    end
    def setup
      @app = Mock.new('app')
      @plugin = ODDB::Interaction::InteractionPlugin.new(@app)
      @mock_plugin = Mock.new('mock_plugin') 
    end
    def teardown
      @mock_plugin.__verify
      @app.__verify
    end
    def test_flock_conn_name
      flock_conn = Mock.new('flock_conn')
      flock_conn.__next(:name) {
        "acetaminophen="
      }
      result = @plugin.flock_conn_name(flock_conn)
      assert_equal("acetaminophen", result)
    end
    def test_flock_conn_name2
      flock_conn = Mock.new('flock_conn')
      flock_conn.__next(:name) {
        "acetaminophen (in part)"
      }
      result = @plugin.flock_conn_name(flock_conn)
      assert_equal("acetaminophen", result)
    end
    def test_parse_hayes
      interaction = Mock.new('interaction')
      cytochrome = Mock.new('cytochrome')
      connection = Mock.new('connection')
      @mock_plugin.__next(:parse_substrate_table) {
        { 'foo' => cytochrome }
      }
      @mock_plugin.__next(:parse_interaction_table) {
        { 'foo'	=> interaction }
      }
      interaction.__next(:inhibitors) {
        [ connection ]
      }
      cytochrome.__next(:add_connection) { |param|
        assert_equal(connection, param)
      }
      interaction.__next(:inducers) {
        [ connection ]
      }
      cytochrome.__next(:add_connection) { |param|
        assert_equal(connection, param)
      }
      @plugin.parse_hayes(@mock_plugin)
      interaction.__verify
      cytochrome.__verify
      connection.__verify
    end
=begin
    def test_parse_flockhart
      table_cytochrome = Mock.new('table_cytochrome')
      detail_cytochrome = Mock.new('detail_cytochrome')
      table_connection = Mock.new('table_connection')
      detail_connection = Mock.new('detail_connection')
      @mock_plugin.__next(:parse_table) {
        { "foo"	=>	table_cytochrome }
      }
      @mock_plugin.__next(:parse_detail_pages) {
        { "foo"	=>	detail_cytochrome }	
      }
      detail_cytochrome.__next(:substrates) {
        [ detail_connection ]
      }
      table_cytochrome.__next(:substrates) {
        [ table_connection ]
      }
      table_connection.__next(:name) {
        'Bar Foo'
      }
      detail_connection.__next(:name) {
        'bar foo'
      }
      detail_connection.__next(:category=) { |param|
        assert_equal('foo_cat', param)
      }
      table_connection.__next(:category) {
        "foo_cat"
      }
      detail_cytochrome.__next(:inhibitors) {
        [ detail_connection ]
      }
      table_cytochrome.__next(:inhibitors) {
        [ table_connection ]
      }
      table_connection.__next(:name) {
        'Foo Bar'
      }
      detail_connection.__next(:name) {
        'bar foo'
      }
      detail_cytochrome.__next(:inducers) {
        [ detail_connection ]
      }
      table_cytochrome.__next(:inducers) {
        [ table_connection ]
      }
      table_connection.__next(:name) {
        'Foo Bar'
      }
      detail_connection.__next(:name) {
        'bar foo'
      }
      @plugin.parse_flockhart(@mock_plugin)
      table_cytochrome.__verify
      detail_cytochrome.__verify
      table_connection.__verify
      detail_connection.__verify
    end
=end
    def test_report
      @plugin.flock_conn_not_found = 3 
      @plugin.hayes_conn_not_found = 2 
      @plugin.hayes = { 
        'foo' =>	'foobar',
        'bar'	=>	'foobar',
      }
      @plugin.flockhart = { 
        'foobar'	=>	'foobar',
        'barfoo'	=>	'foobar',
      }
      result = @plugin.report.split("\n").sort
      expected = [
        "found hayes cytochromes: 2",
        "bar, foo",
        "found flock cytochromes: 2",
        "barfoo, foobar",
        "There are no matching hayes connections for 2 flockhart connections",
        "There are no matching flockhart connections for 3 hayes connections",
      ]
      assert_equal(expected.sort, result)
    end
    def test_report2
      @plugin.flock_conn_not_found = 3 
      @plugin.hayes_conn_not_found = 2 
      @plugin.update_reports = {
        :cyp450_created			=>	[ 'cyp450', 'cyp450_2' ],
        :substance_created	=>	[ 'substance' ],
        :inhibitors_created	=>	[ 'inhibitor updated' ],
        :inhibitors_deleted	=>	[ 'inhibitor deleted' ],
        :inducers_created		=>	[ 'inducer updated' ],
        :inducers_deleted		=>	[ 'inducer deleted' ],
        :substrates_created	=>	[ 'substrate updated' ],
        :substrates_deleted	=>	[ 'substrate deleted' ],
      }
      @plugin.hayes = { 
        'foo' =>	'foobar',
        'bar'	=>	'foobar',
      }
      @plugin.flockhart = { 
        'foobar'	=>	'foobar',
        'barfoo'	=>	'foobar',
      }
      result = @plugin.report.split("\n").sort
      expected = [
        "found hayes cytochromes: 2",
        "bar, foo",
        "found flock cytochromes: 2",
        "barfoo, foobar",
        "There are no matching hayes connections for 2 flockhart connections",
        "There are no matching flockhart connections for 3 hayes connections",
        ODDB::Interaction::InteractionPlugin::UPDATE_MESSAGES[:cyp450_created],
        "cyp450", "cyp450_2", 
        ODDB::Interaction::InteractionPlugin::UPDATE_MESSAGES[:substance_created],
        "substance",
        ODDB::Interaction::InteractionPlugin::UPDATE_MESSAGES[:inhibitors_created],
        "inhibitor updated",
        ODDB::Interaction::InteractionPlugin::UPDATE_MESSAGES[:inhibitors_deleted],
        "inhibitor deleted",
        ODDB::Interaction::InteractionPlugin::UPDATE_MESSAGES[:inducers_created],
        "inducer updated",
        ODDB::Interaction::InteractionPlugin::UPDATE_MESSAGES[:inducers_deleted],
        "inducer deleted",
        ODDB::Interaction::InteractionPlugin::UPDATE_MESSAGES[:substrates_created],
        "substrate updated",
        ODDB::Interaction::InteractionPlugin::UPDATE_MESSAGES[:substrates_deleted],
        "substrate deleted",
      ]
      assert_equal(expected.sort, result)
    end
    def test_similar_name
      subs = Mock.new('Substance')
      @app.__next(:substance) { |name| 
        assert_equal('astring', name)
        subs 
      }
      subs.__next(:same_as?) { |other|
        assert_equal('bstring', other)
        'result'
      }
      assert_equal('result', @plugin.similar_name?('astring', 'bstring'))
      subs.__verify
    end
=begin
    def test_update_oddb_cyp450_connections
      cytochrome = Mock.new('cytochrome')
      cyp450 = Mock.new('cyp450')	
      inhibitor = Mock.new('inhibitor')
      pointer = Mock.new('pointer')
      substance = Mock.new('substance')
      cyp450.__next(:inhibitors) {
        { 
          'key_1'	=>	'value_1',
          'key_2'	=>	'value_2',
        }
      }
      cytochrome.__next(:inhibitors) { [ inhibitor ] }
      cyp450.__next(:pointer) { pointer	}
      inhibitor.__next(:name) { 'foo_name' }
      inhibitor.__next(:links) { [ 'link' ] }
      inhibitor.__next(:category) { 'category' }
      #inhibitor.__next(:name)	{ 'key_3' }
      cyp450.__next(:inhibitors) { 
        { 
          'key_1'	=>	'value_1',
          'key_2'	=>	'value_2',
        }
      }
      cyp450.__next(:pointer) { pointer }
      pointer.__next(:+) { |params|
        assert_equal(Array, params.class)
        assert_equal(2, params.size)
        pointer
      }
      pointer.__next(:+) { |params|
        assert_equal(Array, params.class)
        assert_equal(2, params.size)
        pointer
      }
      #pointer.__next(:creator) { pointer }
      @app.__next(:substance_by_connection_key) { substance }
      substance.__next(:primary_connection_key) { 'key_1' }
      @app.__next(:update) { |create_pointer, args|
        assert_equal(Hash, args.class)
        assert_equal(3, args.size)
        assert_equal(pointer, create_pointer)
      }
      #inhibitor.__next(:name) { 'key_1' }
      #inhibitor.__next(:name) { 'key_1' }
      #inhibitor.__next(:name)	{ 'foo_name' }
      #cyp450.__next(:pointer) { pointer }
  #=begin
      pointer.__next(:+) { |params|
        assert_equal('key_2', params.last)
        assert_equal(Array, params.class)
        pointer
      }
  #=end
      cyp450.__next(:cyp_id) { 'cyp45_id' }
  #=begin
      @app.__next(:delete) { |delete_pointer| 
        assert_equal(pointer, delete_pointer)
      }
      #cyp450.__next(:pointer) { pointer }
      pointer.__next(:+) { |params|
        assert_equal('key_1', params.last)
        assert_equal(Array, params.class)
        pointer
      }
  #=end
      @app.__next(:delete) { |delete_pointer| 
        assert_equal(pointer, delete_pointer)
      }
      #cyp450.__next(:cyp_id) { 'cyp45_id' }
      @plugin.update_oddb_cyp450_connections('foo_id', cytochrome, cyp450, :inhibitors)
      cytochrome.__verify
      cyp450.__verify
      inhibitor.__verify
      pointer.__verify
    end
=end
    def test_update_oddb_cyp450
      cyp450 = Mock.new('cyp450')
      @app.__next(:cyp450) { |param|
        assert_equal('foo_id', param)
        'cyp450'
      }
      @plugin.update_oddb_cyp450('foo_id', 'cytochrome')
      cyp450.__verify
    end
    def test_update_oddb_cyp4502
      cytochrome = Mock.new('cytochrome')
      cyp450 = Mock.new('cyp450')
      @app.__next(:cyp450) { |param|
        assert_equal('foo_id', param)
      }
      @app.__next(:create) { |param|
        assert_equal(ODDB::Persistence::Pointer, param.class)
        cyp450
      }
      cyp450.__next(:cyp_id) {
        'cyp450_id'
      }
      @plugin.update_oddb_cyp450('foo_id', cytochrome)
      cytochrome.__verify
      cyp450.__verify
    end
    def test_update_oddb_create_substance
      connection = Mock.new("connection")
      substance = Mock.new("substance")
      connection.__next(:lang) { 'en' }
      connection.__next(:name) { 'not_yet_updated' }
      @app.__next(:update) { substance }
      #substance.__next(:substrate_connections) { [connection] }
      substance.__next(:name) { 'not_yet_updated' }
      expected = {
        substance =>	{},
      }
      @plugin.update_oddb_create_substance(connection)
      assert_equal(expected, 
        @plugin.instance_variable_get('@updated_substances'))
      connection.__verify
      substance.__verify
    end
    def test_update_oddb_substrates
      cytochrome = Mock.new('cytochrome')
      substrate = Mock.new('substrate')
      substance = Mock.new('substance')
      connection = Mock.new('connection')
      pointer = Mock.new('pointer')
      @plugin.updated_substances = { 
        'found'	=>	{ 
          :connections	=>	{ 
            'cyt_id'	=> connection
          }
        }
      }
      cytochrome.__next(:substrates) { [ substrate ] }
      substrate.__next(:links) { 'links' }
      substrate.__next(:category) { 'category' }
      substrate.__next(:name) { 'substratename' }
      @app.__next(:substance_by_connection_key) { 
        substance 
      }
=begin
      substance.__next(:has_connection_key?) { |key|
        assert_equal('substratename', key) 
        true
      }
=end
      substance.__next(:primary_connection_key) { 
        'substratename'
      }
      substance.__next(:pointer) { pointer }
      pointer.__next(:+) { pointer }
      substance.__next(:cyp450substrate) { |param| 
        assert_equal('cyt_id', param)	
        false
      }
      pointer.__next(:creator) { 'creator' }
      substrate.__next(:name) { 'substratename' }
      #substance.__next(:connection_keys) { ['found'] }
      @app.__next(:update) {}
      @plugin.update_oddb_substrates('cyt_id', cytochrome)
      cytochrome.__verify
      substrate.__verify
      substance.__verify
      connection.__verify
      pointer.__verify
    end
=begin
    def test_real_life
      #app = ODDB::App.new
      #plugin = ODDB::Interaction::InteractionPlugin.new(app)	
      #plugin.update
    end
=end
  end
  class TestFlockhartPlugin < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @app = flexmock 'app'
      @plugin = ODDB::Interaction::FlockhartPlugin.new @app, false
    end
    def test_parse_detail
      path = File.expand_path('../data/html/interaction/flockhart/3A457.htm',
                              File.dirname(__FILE__))
      page = WWW::Mechanize::Page.new(nil, { 'content-type' => 'text/html' },
                                      open(path).read, 200)
      cytochrome = @plugin.parse_detail_page '3A457', page
      assert_instance_of ODDB::Interaction::Cytochrome, cytochrome
      assert_equal 86, cytochrome.substrates.size
      assert_equal 31, cytochrome.inhibitors.size
      names = cytochrome.inhibitors.collect do |substr| substr.name end
      assert_equal 14, cytochrome.inducers.size
    end
  end
end
