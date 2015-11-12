#!/usr/bin/env ruby
# ODDB::FiParse::TestWriter -- oddb.org -- 21.06.2011 -- mhatakeyama@ywesee.com

require 'hpricot'

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path('../../../src', File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'fiwriter'

module ODDB
  module FiParse

class TestWriter <Minitest::Test
  include FlexMock::TestCase
  def setup
    @writer = ODDB::FiParse::Writer.new
  end
  def test_new_alignment
    assert_kind_of(ODDB::Text::Paragraph, @writer.new_alignment('alignment'))
  end
  def test_send_flowing_data
    assert_nil(@writer.send_flowing_data('data'))
  end
  def test_send_hor_rule
    assert_nil(@writer.send_hor_rule)
  end
  def test_send_line_break__target_name
    @writer.instance_eval('@target = @name')
    assert_equal("\n", @writer.send_line_break)
  end
  def test_send_line_break__chapter_galenic_form
    section = flexmock('section', :subheading => 'subheading')
    @writer.instance_eval do
      @chapter = @galenic_form
      @section = section
    end
    assert_equal("subheading\n", @writer.send_line_break)
  end
  def test_send_line_break__chapter_heading
    chapter = flexmock('chapter', :heading => 'heading')
    @writer.instance_eval do
      @chapter = chapter
      @target = @chapter.heading
    end
    assert_equal("heading\n", @writer.send_line_break)
  end
  def test_send_line_break__else
    assert_kind_of(ODDB::Text::Paragraph, @writer.send_line_break)
  end
  def test_send_literal_data
    target = flexmock('target', 
                      :preformatted! => nil,
                      :<< => nil
                     )
    @writer.instance_eval('@target = target')
    assert_nil(@writer.send_literal_data('data'))
  end
  def test_next_chapter
    chapter = flexmock('chapter', :clean! => nil)
    @writer.instance_eval do
      @chapters = [chapter]
    end
    assert_kind_of(ODDB::Text::Chapter, @writer.next_chapter)
  end
end


  end # FiParse
end # ODDB

