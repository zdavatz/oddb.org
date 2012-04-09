#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Ajax::TestDDDChart -- oddb.org -- 09.04.2012 -- yasaka@ywesee.com
# ODDB::View::Ajax::TestDDDChart -- oddb.org -- 17.03.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/ajax/ddd_chart'
require 'RMagick'
#require 'encoding/character/utf-8'

class TestSideBar < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @sidebar = SideBar.new
  end
=begin
  def test_draw
    @sidebar.instance_eval('@maximum_value = 123')
    @sidebar.instance_eval('@spread = 0.0')
    @sidebar.instance_eval('@marker_count = 1.0')

    @sidebar.instance_eval('@has_data = "has_data"')
    assert_equal('', @sidebar.draw)
  end
=end
  def test_setup_graph_measurements
    @sidebar.instance_eval('@maximum_value = 123')
    @sidebar.instance_eval('@spread = 0.0')
    @sidebar.instance_eval('@marker_count = 1.0')
    assert_in_delta(452.0, @sidebar.setup_graph_measurements, 0.01)
  end
  def test_setup_graph_measurements__hide_line_markers
    @sidebar.instance_eval('@maximum_value = 123')
    @sidebar.instance_eval('@spread = 0.0')
    @sidebar.instance_eval('@marker_count = 1.0')
    @sidebar.instance_eval('@hide_line_markers = 0')
    assert_in_delta(480.0, @sidebar.setup_graph_measurements, 0.01)
  end
  def test_setup_graph_measurements__has_left_labels
    @sidebar.instance_eval('@maximum_value = 123')
    @sidebar.instance_eval('@spread = 0.0')
    @sidebar.instance_eval('@marker_count = 1.0')
    @sidebar.instance_eval('@has_left_labels = true')
    @sidebar.labels = {'key' => ' 1 /x '}
    assert_in_delta(452.0, @sidebar.setup_graph_measurements, 0.01)
  end
  def test_draw_title
    @sidebar.instance_eval('@hide_title = nil')
    @sidebar.instance_eval('@title = "title"')
    assert_kind_of(Magick::Draw, @sidebar.draw_title)
  end
  def test_draw_title__nil
    assert_equal(nil, @sidebar.draw_title)
  end
  def test_draw_source
    @sidebar.instance_eval('@theme_options[:source_font_size] = 1.0')
    @sidebar.instance_eval('@graph_bottom = 1.0')
    @sidebar.instance_eval('@theme_options[:source] = "source"')
    assert_kind_of(Magick::Draw, @sidebar.draw_source)
  end
  def test_draw_line_markers
    @sidebar.instance_eval('@maximum_value = 2.0')
    @sidebar.instance_eval('@graph_left = 0.0')
    @sidebar.instance_eval('@graph_right = 1.0')
    @sidebar.instance_eval('@graph_bottom = 0.0')
    @sidebar.instance_eval('@graph_top = 1.0')
    result = @sidebar.draw_line_markers
    assert_kind_of(Range, result)
    assert_equal(0, result.first)
    assert_equal(4, result.last.to_i)
  end
  def test_draw_label
    @sidebar.instance_eval('@labels[0] = " 11/x 456 ABC 123"')
    @sidebar.instance_eval('@factor_width = 0.0')
    @sidebar.instance_eval('@graph_left = 0.0')
    assert_equal(1, @sidebar.draw_label(0,0))
  end
  def test_draw_label__nil
    assert_equal(nil, @sidebar.draw_label(0,0))
  end
  def test_draw
    @sidebar.instance_eval('@has_data = true')
    @sidebar.instance_eval('@maximum_value = 2.0')
    @sidebar.instance_eval('@theme_options[:source_font_size] = 1.0')
    @sidebar.instance_eval('@graph_bottom = 1.0')
    @sidebar.instance_eval('@theme_options[:source] = "source"')
    assert_kind_of(Magick::Draw, @sidebar.draw)
  end
  def test_draw__norm_data
    @sidebar.instance_eval('@has_data = true')
    @sidebar.instance_eval('@maximum_value = 2.0')
    @sidebar.instance_eval('@theme_options[:source_font_size] = 1.0')
    @sidebar.instance_eval('@theme_options[:custom_colors] = []')
    @sidebar.instance_eval('@graph_bottom = 1.0')
    @sidebar.instance_eval('@theme_options[:source] = "source"')

    norm_data = [[0,[1,2,3],'white'], [0,[4,5,6],'white']]
    @sidebar.instance_eval('@norm_data = norm_data')
    @sidebar.instance_eval('@column_count = 3')
    assert_kind_of(Magick::Draw, @sidebar.draw)
  end
end

class TestDDDChart < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    package  = flexmock('package',
                        :sequence             => 'sequence',
                        :generic_group_factor => 'generic_group_factor'
                       )
    lookandfeel = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session',
                        :package_by_ikskey => package,
                        :language          => 'language',
                        :lookandfeel       => lookandfeel
                       )
    flexmock(@session) do |s|
      s.should_receive(:user_input).with(:for).and_return('12345678')
    end
    commercial_form = flexmock('commercial_form',
                               :language => 'language'
                              )
    part     = flexmock('part',
                        :multi   => 'multi',
                        :count   => 'count',
                        :measure => 'measure',
                        :commercial_form => commercial_form
                       )
    sequence = flexmock('sequence', :comparable? => nil)
    @model   = flexmock('model', 
                        :ddd_price => 123,
                        :name_base => 'name_base',
                        :parts     => [part],
                        :sequence  => sequence,
                        :commercial_forms     => [commercial_form],
                        :generic_group_factor => 'generic_group_factor'
                       )
    @chart   = ODDB::View::Ajax::DDDChart.new([@model], @session)
  end
  def test_init
    assert_equal(nil, @chart.init)
  end
  def test_to_html
    flexmock(@session) do |s|
      s.should_receive(:user_input).once.with(:factor)                                         
    end
    cgi = flexmock('cgi')
    assert_kind_of(String, @chart.to_html(cgi))
  end
end
