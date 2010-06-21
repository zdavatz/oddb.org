#!/usr/bin/env ruby
# TestSlEntry -- oddb -- 03.03.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'stub/odba'
require 'test/unit'
require 'model/slentry'
require 'model/text'
require 'date'

module ODDB
  class SlEntry
    public :adjust_types
  end
  class TestSlEntry < Test::Unit::TestCase
    def setup
      @sl_entry = ODDB::SlEntry.new
    end
    def test_adjust_types
      values = {
        :introduction_date	=>	'01.02.2003',
        :limitation				=>	'Y',
        :limitation_points	=>	'23',
      }
      expected = {
        :introduction_date	=>	Date.new(2003, 2, 1),
        :limitation				=>	true,
        :limitation_points	=>	23,
      }
      assert_equal(expected, @sl_entry.adjust_types(values))
      values = {
        :introduction_date	=>	Date.new(2003, 2, 1),
        :limitation				=>	true,
        :limitation_points	=>	'23',
      }
      expected = {
        :introduction_date	=>	Date.new(2003, 2, 1),
        :limitation				=>	true,
        :limitation_points	=>	23,
      }
      assert_equal(expected, @sl_entry.adjust_types(values))
      values = {
        :limitation				=>	'',
        :limitation_points	=>	'0',
      }
      expected = {
        :limitation				=>	false,
        :limitation_points	=>	nil,
      }
      assert_equal(expected, @sl_entry.adjust_types(values))
    end
    def test_create_limitation_text
      txt = @sl_entry.create_limitation_text
      assert_instance_of LimitationText, txt
      assert_equal txt, @sl_entry.limitation_text
    end
    def test_delete_limitation_text
      @sl_entry.instance_variable_set '@limitation_text', 'a text'
      @sl_entry.delete_limitation_text
      assert_nil @sl_entry.limitation_text
    end
    def test_pointer_descr
      assert_equal :sl_entry, @sl_entry.pointer_descr
    end
  end
end
