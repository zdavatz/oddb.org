#!/usr/bin/env ruby
# TestHtmlParser -- oddb -- 06.10.2003 -- maege@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'util/html_parser'

module ODDB
	class HtmlFormatter < AbstractFormatter
		attr_accessor :table_stack, :tablehandler, :link_stack
	end
	class HtmlLinkHandler
		attr_accessor :attributes
	end
end

class TestHtmlParser < Test::Unit::TestCase
	class StubFormatter
		attr_accessor :flowing_data, :literal_data
		attr_reader :called
		def initialize
			@flowing_data = ''
			@literal_data = ''
			@called = false
		end
		def add_flowing_data(data)
			@flowing_data << data
		end
		def add_literal_data(data)
			@literal_data << data
		end
		def end_paragraph(*args)
		end
		def pop_font
		end
		def push_font(*args)
		end
		def method_missing(mname, *args)
			@called = mname
		end
	end
	def setup
		@formatter = StubFormatter.new
		@parser = ODDB::HtmlParser.new(@formatter)
	end
	def test_unknown_entityref
		@parser.unknown_entityref('uuml')
		assert_equal('ü', @formatter.flowing_data)
		@parser.unknown_entityref('sup2')
		assert_equal('ü²', @formatter.flowing_data)
		@parser.unknown_entityref('para')
		assert_equal('ü²¶', @formatter.flowing_data)
		@parser.unknown_entityref('ETH')
		assert_equal('ü²¶Ð', @formatter.flowing_data)
	end
	def test_no_premature_pre_end
		html = '<b>foo<pre></b>bar</pre>baz'
		@parser.feed(html)
		assert_equal('foobaz', @formatter.flowing_data)
		assert_equal('bar', @formatter.literal_data)
	end
	def test_start_link
		html = '<a>'
		@parser.feed(html)
		assert_equal(:push_link, @formatter.called)
	end
	def test_end_link
		html = '<a>foo</a>'
		@parser.feed(html)
		assert_equal(:pop_link, @formatter.called)
	end
	def test_start_table
		html = '<table>'
		@parser.feed(html)
		assert_equal(:push_table, @formatter.called)
	end
	def test_end_table
		html = '<table>foo</table>'
		@parser.feed(html)
		assert_equal(:pop_table, @formatter.called)
	end
	def test_start_tr
		html = '<tr>'
		@parser.feed(html)
		assert_equal(:push_tablerow, @formatter.called)
	end
	def test_end_tr
		html = '<tr>foo</tr>'
		@parser.feed(html)
		assert_equal(:pop_tablerow, @formatter.called)
	end
	def test_start_td
		html = '<td>'
		@parser.feed(html)
		assert_equal(:push_tablecell, @formatter.called)
	end
	def test_end_td
		html = '<td>foo</td>'
		@parser.feed(html)
		assert_equal(:pop_tablecell, @formatter.called)
	end
	def test_start_font
		html = '<font face="symbol">'
		@parser.feed(html)
		assert_equal(:push_fonthandler, @formatter.called)
	end
	def test_end_font
		html = '<font face="symbol">foo</font>'
		@parser.feed(html)
		assert_equal(:pop_fonthandler, @formatter.called)
	end
end
class TestHtmlFormatter < Test::Unit::TestCase
	class StubWriter
		attr_reader :called, :arguments
		def method_missing(method_name, *args)
			@called = method_name	
			@arguments = args
		end
	end
	class StubTableHandler
		attr_reader :called, :arguments
		def method_missing(mname, *args)
			@called = mname	
			@arguments = args
		end
	end
	def setup
		@writer = StubWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
	end
	def test_push_link
		attrs = [ ["foo","bar"] ]
		@formatter.push_link(attrs)
		assert_equal(1, @formatter.link_stack.size)
		lhandler = @formatter.link_stack.first
		assert_instance_of(ODDB::HtmlLinkHandler, lhandler)
		hash = {'foo' => 'bar'}
		assert_equal(hash, lhandler.attributes)
		assert_equal(:new_linkhandler, @writer.called)
		@formatter.push_link(attrs)
		assert_equal(2, @formatter.link_stack.size)
		lhandler = @formatter.link_stack.last
		assert_instance_of(ODDB::HtmlLinkHandler, lhandler)
	end
	def test_pop_link
		@formatter.link_stack = [
			'first', 'second',	
		]
		@formatter.pop_link
		assert_equal(['first'], @formatter.link_stack)
		assert_equal(:new_linkhandler, @writer.called)
		assert_equal(['first'], @writer.arguments)
		@formatter.pop_link
		assert_equal([], @formatter.link_stack)
		assert_equal(:new_linkhandler, @writer.called)
		assert_equal([nil], @writer.arguments)
	end
	def test_push_table
		attrs = [ ["foo","bar"] ]
		@formatter.push_table(attrs)
		assert_equal(1, @formatter.table_stack.size)
		thandler = @formatter.table_stack.first
		assert_instance_of(ODDB::HtmlTableHandler, thandler)
		assert_equal(attrs, thandler.attributes)
		assert_equal(:new_tablehandler, @writer.called)
		@formatter.push_table(attrs)
		assert_equal(2, @formatter.table_stack.size)
		thandler = @formatter.table_stack.last
		assert_instance_of(ODDB::HtmlTableHandler, thandler)
	end
	def test_pop_table
		@formatter.table_stack = [
			'first', 'second',	
		]
		@formatter.pop_table
		assert_equal(['first'], @formatter.table_stack)
		assert_equal(:new_tablehandler, @writer.called)
		assert_equal(['first'], @writer.arguments)
		@formatter.pop_table
		assert_equal([], @formatter.table_stack)
		assert_equal(:new_tablehandler, @writer.called)
		assert_equal([nil], @writer.arguments)
	end
	def test_push_tablerow
		handler = StubTableHandler.new
		@formatter.tablehandler = handler
		attrs = [[ "foo","bar" ]]
		@formatter.push_tablerow(attrs)	
		assert_equal(:next_row, handler.called)
		assert_equal([attrs], handler.arguments)
	end
	def test_pop_tablerow
		assert_respond_to(@formatter, :pop_tablerow)
	end
	def test_push_tablecell
		handler = StubTableHandler.new
		@formatter.tablehandler = handler
		attrs = [[ "foo","bar" ]]
		@formatter.push_tablecell(attrs)	
		assert_equal(:next_cell, handler.called)
		assert_equal([attrs], handler.arguments)
	end
	def test_pop_tablecell
		assert_respond_to(@formatter, :pop_tablecell)
	end
	def test_interface_additions
		writer = ODDB::NullWriter.new
		assert_respond_to(writer, :new_tablehandler)
		assert_equal(1, writer.method(:new_tablehandler).arity)
	end
end
class TestHtmlLimitationHandler < Test::Unit::TestCase
	class StubTableHandler
		def initialize
			@rows = []
		end
	end
	def setup
		@handler = ODDB::HtmlLimitationHandler.new
	end
	def test_feed
		th = StubTableHandler.new
		@handler.feed(th)
		assert_equal(th, @handler.rows[0])
	end
end
class TestHtmlLinkHandler < Test::Unit::TestCase
	def setup
		@handler = ODDB::HtmlLinkHandler.new([])
	end
	def test_initialize
		attrs = [['foo', '"bar"'], ['bAz', "'urgl'"]]
		handler =  ODDB::HtmlLinkHandler.new(attrs)
		assert_equal('bar', handler.attribute('foo'))
		assert_equal('urgl', handler.attribute('baz'))
	end
	def test_attribute
		@handler.attributes = {'arb', 'crd'}
		assert_equal('crd', @handler.attribute('ARb'))
	end
	def test_send_adata
		value = " link"
		assert_equal('link', @handler.send_adata(value))
	end
end
class TestHtmlTableHandler < Test::Unit::TestCase
	def setup
		@handler = ODDB::HtmlTableHandler.new([])
	end
	def test_next_row
		attr = [[ 'class','foorow' ]]
		row = @handler.next_row(attr)
		assert_instance_of(ODDB::HtmlTableHandler::Row, row)
		assert_equal(attr, row.attributes)
	end
	def test_next_cell
		row = @handler.next_row([])
		cell = @handler.next_cell([])
		assert_instance_of(ODDB::HtmlTableHandler::Cell, cell)
		assert_equal({}, cell.attributes)
	end
	def test_send_cdata
		row = @handler.next_row([])
		cell = @handler.next_cell([])
		@handler.send_cdata('Hello World!')
		assert_equal('Hello World!', cell.cdata)
		@handler.send_cdata(' ...Goodbye!')
		assert_equal('Hello World! ...Goodbye!', cell.cdata)
	end
	def test_cdata1
		row = @handler.next_row([])
		row = @handler.next_row([])
		cell = @handler.next_cell([])
		cell = @handler.next_cell([])
		cell = @handler.next_cell([])
		@handler.send_cdata('Moin!')
		assert_equal('Moin!', @handler.cdata(2,1))
		val = assert_nothing_raised {
			@handler.cdata(0,4)
		}
		assert_nil(val)
	end
	def test_cdata2
		row = @handler.next_row([])
		cell = @handler.next_cell([["colspan","2"]])
		cell = @handler.next_cell([])
		@handler.send_cdata('Moin!')
		assert_equal('Moin!', @handler.cdata(2,0))
	end
	def test_extract_cdata
		row = @handler.next_row([])
		cell = @handler.next_cell([])
		cell = @handler.next_cell([])
		@handler.send_cdata('fooval')
		row = @handler.next_row([])
		row = @handler.next_row([])
		cell = @handler.next_cell([])
		@handler.send_cdata('barval')
		row = @handler.next_row([])
		cell = @handler.next_cell([['colspan','2']])
		cell = @handler.next_cell([])
		@handler.send_cdata('valbaz')
		template = {
			:foo	=>	[1,0],
			:bar	=>	[0,2],
			:baz	=>	[2,3],
		}
		expected = {
			:foo	=>	"fooval",
			:bar	=>	"barval",
			:baz	=>	"valbaz",
		}
		assert_equal(expected, @handler.extract_cdata(template))
		assert_nothing_raised {
			@handler.extract_cdata({:no_such_pos=>[10,10]})
		}
	end
end
class TestHtmlFontHandler < Test::Unit::TestCase
	def test_attribute
		attr = [
			['FACE', 'SYMBOL']
		]
		handler = ODDB::HtmlFontHandler.new(attr)
		assert_equal('SYMBOL', handler.attribute('face'))
	end
end
