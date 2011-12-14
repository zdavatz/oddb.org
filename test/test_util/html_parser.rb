#!/usr/bin/env ruby
# encoding: utf-8
# TestHtmlParser -- oddb -- 11.03.2011 -- mhatakeyama@ywesee.com
# TestHtmlParser -- oddb -- 06.10.2003 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
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
  def test_do_meta
    assert_equal(:send_meta, @parser.do_meta('attrs'))
  end
  def test_handle_image
    assert_equal(:send_image, @parser.handle_image('src'))
  end
  def test_do_img
    attrs = {
      'align' => 'xxx', 
      'alt'   => 'xxx',
      'ismap' => 'xxx',
      'src'   => 'xxx',
      'width' => 'xxx',
      'height'=> 'xxx'
    }
    assert_equal(:send_image, @parser.do_img(attrs))
  end
end

class TestHtmlFormatter < Test::Unit::TestCase
  include FlexMock::TestCase
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
  def test_pop_alignment
    @formatter.instance_eval('@align_stack = ["pop"]')
    assert_equal('pop', @formatter.pop_alignment)
  end
  def test_pop_fonthandler
    flexmock(@writer, :new_fonthandler => 'new_fonthandler')
    assert_equal('new_fonthandler',@formatter.pop_fonthandler)
  end
  def test_push_alignment
    assert_equal(['alignment'], @formatter.push_alignment('alignment'))
  end
  def test_push_fonthandler
    assert_kind_of(ODDB::HtmlFontHandler, @formatter.push_fonthandler({})[0])
  end
  def test_send_image
    assert_equal(['src'], @formatter.send_image('src'))
  end
  def test_send_meta
    assert_equal(['attrs'], @formatter.send_meta('attrs'))
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
  def test_to_s
    assert_equal('', @handler.to_s)
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
  def test_add_child
    current_row = ODDB::HtmlTableHandler::Row.new({})
    current_cell = ODDB::HtmlTableHandler::Cell.new({})
    current_row.instance_eval('@current_cell = current_cell')
    @handler.instance_eval('@current_row = current_row')
    assert_equal(['child'], @handler.add_child('child'))
  end
  def test_children
    row = ODDB::HtmlTableHandler::Row.new({})
    rows = [row]
    cell = ODDB::HtmlTableHandler::Cell.new({})
    cell.add_child('child')
    cells = [cell]
    row.instance_eval('@cells = cells')
    @handler.instance_eval('@rows = rows')
    assert_equal(['child'], @handler.children(0,0))
  end
  def test_children__nil
    assert_equal(nil, @handler.children(0,0))
  end
  def test_current_colspan
    current_row = ODDB::HtmlTableHandler::Row.new({})
    current_cell = ODDB::HtmlTableHandler::Cell.new({})
    current_row.instance_eval('@current_cell = current_cell')
    @handler.instance_eval('@current_row = current_row')
    assert_equal(1, @handler.current_colspan)
  end
  def test_each_row
    row = ODDB::HtmlTableHandler::Row.new({})
    rows = [row]
    @handler.each_row do |r|
      assert_equal(row, r)
    end
  end
  def test_next_line
    current_row = ODDB::HtmlTableHandler::Row.new({})
    current_cell = ODDB::HtmlTableHandler::Cell.new({})
    current_row.instance_eval('@current_cell = current_cell')
    @handler.instance_eval('@current_row = current_row')
    assert_equal(['',''], @handler.next_line)
  end
  def test_next_cell
    row = ODDB::HtmlTableHandler::Row.new({})
    rows = [row]
    cell = ODDB::HtmlTableHandler::Cell.new({'rowspan' => '2'})
    cell.add_child('child')
    cells = [cell, cell]
    row.instance_eval('@cells = cells')
    @handler.instance_eval('@rows = rows')
    assert_kind_of(ODDB::HtmlTableHandler::Cell, @handler.next_cell({}))
  end
  def test_to_s
    row = ODDB::HtmlTableHandler::Row.new({})
    rows = [row]
    cell = ODDB::HtmlTableHandler::Cell.new({'rowspan' => '2', 'colspan' => '2'})
    cdata = ['data']
    cell.instance_eval('@cdata = cdata')
    cells = [cell, cell]
    row.instance_eval('@cells = cells')
    @handler.instance_eval('@rows = rows')
    expected = "------\ndata  \n------\n"
    assert_equal(expected, @handler.to_s)
  end
  def test_to_s__colspan_1
    row = ODDB::HtmlTableHandler::Row.new({})
    rows = [row]
    cell = ODDB::HtmlTableHandler::Cell.new({})
    cdata = ['data']
    cell.instance_eval('@cdata = cdata')
    cells = [cell, cell]
    row.instance_eval('@cells = cells')
    @handler.instance_eval('@rows = rows')
    expected = "----------\ndata  data\n----------\n"
    assert_equal(expected, @handler.to_s)
  end

  def test_to_s__empty
    assert_equal('', @handler.to_s)
  end
  def test_width
    row = ODDB::HtmlTableHandler::Row.new({})
    rows = [row]
    cell = ODDB::HtmlTableHandler::Cell.new({})
    cdata = ['data']
    cell.instance_eval('@cdata = cdata')
    cells = [cell, cell]
    row.instance_eval('@cells = cells')
    @handler.instance_eval('@rows = rows')
    assert_equal(10, @handler.width)
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

class TestBasicHtmlParser < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @formatter = flexmock('formatter')
    @parser = ODDB::BasicHtmlParser.new(@formatter)
  end
  def test_finish_endtab
    assert_equal(nil, @parser.finish_endtag('tag'))
  end
  def test_finish_endtab__last_tag
    @parser.instance_eval('@stack = ["tag"]')
    assert_equal(nil, @parser.finish_endtag('tag'))
  end
  def test_finish_endtag__empty
    assert_equal(nil, @parser.finish_endtag(''))
  end
  def test_start_td
    flexmock(@formatter) do |f|
      f.should_receive(:push_alignment)
      f.should_receive(:push_tablecell).and_return('push_tablecell')
    end
    attrs = {'align' => 'center'}
    assert_equal('push_tablecell', @parser.start_td(attrs))
  end
end

class TestHtmlTableHandlerCell < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    attrs = {}
    @cell = ODDB::HtmlTableHandler::Cell.new(attrs)
  end
  def test_add_child
    assert_equal(['child'], @cell.add_child('child'))
  end
  def test_cdata
    cdata = ['data1', 'data2']
    @cell.instance_eval('@cdata = cdata')
    assert_equal(cdata, @cell.cdata)
  end
  def test_formatted_cdata
    cdata = ['data']
    formats = [[[0, 'format']]]
    @cell.instance_eval('@cdata = cdata')
    @cell.instance_eval('@formats = formats')
    expected = ['formatdata']
    assert_equal(expected, @cell.formatted_cdata)
  end
  def test_cdata__empty
    assert_equal('', @cell.cdata)
  end
  def test_height
    cdata = ['data']
    @cell.instance_eval('@cdata = cdata')
    assert_equal(1, @cell.height)
  end
  def test_next_line
    assert_equal(['',''], @cell.next_line)
  end
  def test_send_format
    assert_equal('format', @cell.send_format('format'))
  end
  def test_width
    cdata = ['data']
    @cell.instance_eval('@cdata = cdata')
    assert_equal(4, @cell.width)
  end
end

class TestHtmlTableHandlerRow < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    attrs = {}
    @row = ODDB::HtmlTableHandler::Row.new(attrs)
  end
  def test_add_child
    current_cell = ODDB::HtmlTableHandler::Cell.new({})
    @row.instance_eval('@current_cell = current_cell')
    assert_equal(['child'], @row.add_child('child'))
  end
  def test_children
    cells = [ODDB::HtmlTableHandler::Cell.new({})]
    cells[0].add_child('child')
    @row.instance_eval('@cells = cells')
    assert_equal(['child'], @row.children(0))
  end
  def test_current_colspan
    current_cell = ODDB::HtmlTableHandler::Cell.new({})
    @row.instance_eval('@current_cell = current_cell')
    assert_equal(1, @row.current_colspan)
  end
  def test_each_cell_with_index
    cell = ODDB::HtmlTableHandler::Cell.new({})
    cells = [cell]
    @row.instance_eval('@cells = cells')
    @row.each_cell_with_index do |c, i|
      assert_equal(cell, c) 
    end
  end
  def test_height
    cell = ODDB::HtmlTableHandler::Cell.new({})
    cdata = ['data']
    cell.instance_eval('@cdata = cdata')
    cells = [cell]
    @row.instance_eval('@cells = cells')
    assert_equal(1, @row.height)
  end
  def test_next_line
    current_cell = ODDB::HtmlTableHandler::Cell.new({})
    @row.instance_eval('@current_cell = current_cell')
    assert_equal(['',''], @row.next_line)
  end
  def test_send_format
    assert_equal('format', @row.send_format('format'))
  end
end


