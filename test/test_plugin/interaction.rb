#!/usr/bin/env ruby
# TestInteractionPlugin -- oddb -- 23.02.2004 -- maege@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'plugin/interaction'
require 'util/html_parser'
require 'mock'

module ODDB
	module Interaction
		class InteractionPlugin
			attr_accessor :merging_errors, :hayes, :flockhart
			REFETCH_PAGES = false
		end
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
	class StubApp
		def initialize
		end
	end
	def setup
		app = StubApp.new
		@plugin = ODDB::Interaction::InteractionPlugin.new(app)
		@mock_plugin = Mock.new('mock_plugin') 
	end
	def teardown
		@mock_plugin.__verify
	end
	def test_flock_conn_name
		flock_conn = Mock.new('flock_conn')
		flock_conn.__next(:name_base) {
			"acetaminophen="
		}
		result = @plugin.flock_conn_name(flock_conn)
		assert_equal("acetaminophen", result)
	end
	def test_flock_conn_name2
		flock_conn = Mock.new('flock_conn')
		flock_conn.__next(:name_base) {
			"acetaminophen (in part)"
		}
		result = @plugin.flock_conn_name(flock_conn)
		assert_equal("acetaminophen", result)
	end
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
		table_connection.__next(:name_base) {
			'Bar Foo'
		}
		detail_connection.__next(:name_base) {
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
		table_connection.__next(:name_base) {
			'Foo Bar'
		}
		detail_connection.__next(:name_base) {
			'bar foo'
		}
		detail_cytochrome.__next(:inducers) {
			[ detail_connection ]
		}
		table_cytochrome.__next(:inducers) {
			[ table_connection ]
		}
		table_connection.__next(:name_base) {
			'Foo Bar'
		}
		detail_connection.__next(:name_base) {
			'bar foo'
		}
		@plugin.parse_flockhart(@mock_plugin)
		table_cytochrome.__verify
		detail_cytochrome.__verify
		table_connection.__verify
		detail_connection.__verify
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
	def test_merge_data
		hayes_cytochrome = Mock.new('hayes_cytochrome')
		flockhart_cytochrome = Mock.new('flockhart_cytochrome')
		hayes_connection = Mock.new('hayes_connection')
		flockhart_connection = Mock.new('flockhart_connection')
		flock_link = Mock.new('flock_link')
		hayes = { 'foo'	=>	hayes_cytochrome }
		flockhart = { 'foo'	=>	flockhart_cytochrome }
		hayes_cytochrome.__next(:substrates) {
			[ hayes_connection ]
		}
		flockhart_cytochrome.__next(:substrates) {
			[ flockhart_connection ]
		}
		hayes_connection.__next(:name_base) {
			'foo bar'
		}
		flockhart_connection.__next(:name_base) {
			'foo bar'
		}
		hayes_connection.__next(:category=) { |param|
			assert_equal('category', param)
		}
		flockhart_connection.__next(:category) { 
			'category'
		}
		flockhart_connection.__next(:links) {
			[ flock_link ]
		}
		hayes_connection.__next(:links) {
			[]
		}
		hayes_cytochrome.__next(:inhibitors) {
			[ hayes_connection ]
		}
		flockhart_cytochrome.__next(:inhibitors) {
			[ flockhart_connection ]
		}
		flockhart_connection.__next(:name_base) {
			'foo bar'		
		}
		hayes_connection.__next(:name_base) {
			'bar foo'
		}
		hayes_connection.__next(:name_base) {
			'bar foo'
		}
		flockhart_connection.__next(:name_base) {
			'foo bar'		
		}
		hayes_cytochrome.__next(:inducers) {
			[ hayes_connection ]
		}
		flockhart_cytochrome.__next(:inducers) {
			[ flockhart_connection ]
		}
		flockhart_connection.__next(:name_base) {
			'foo bar'		
		}
		hayes_connection.__next(:name_base) {
			'bar foo'
		}
		hayes_connection.__next(:name_base) {
			'bar foo'
		}
		flockhart_connection.__next(:name_base) {
			'foo bar'		
		}
		@plugin.merge_data(hayes, flockhart)
		expected = {
			:no_flock_conn=>["foo => bar foo", "foo => bar foo"],
			:no_hayes_conn=>["foo => foo bar", "foo => foo bar"],
		}
		assert_equal(expected, @plugin.merging_errors)
		hayes_cytochrome.__verify
		flockhart_cytochrome.__verify
		hayes_connection.__verify
		flockhart_connection.__verify
		flock_link.__verify
	end
	def test_update
		@plugin.update
	end
	def test_report
		@plugin.merging_errors = {
			:no_flock_conn	=> ["flock_conn1", "flock_conn2"], 
			:no_hayes_conn => ["hayes_conn1", "hayes_conn2"],
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
			"Keine passende Hayes Connection gefunden:",
			"hayes_conn1","hayes_conn2",
			"Keine passende Flockhart Connection gefunden:",
			"flock_conn1","flock_conn2",
		]
		assert_equal(expected.sort, result)
	end
	def test_similar_name
		result = []
		result.push(@plugin.similar_name?("astring", "astring"))
		result.push(@plugin.similar_name?("astring", "bstring"))
		result.push(@plugin.similar_name?("abstring", "bcstring"))
		expected = [true, true, false]
		assert_equal(expected, result)
	end
end
