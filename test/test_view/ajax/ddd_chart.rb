#!/usr/bin/env ruby
# encoding: utf-8
$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'flexmock/minitest'
require 'view/ajax/ddd_chart'
require 'rmagick'

class ODDB::View::Ajax::DDDChart
  attr_reader :data
end

class TestSideBar <Minitest::Test
  def setup
    @sidebar = SideBar.new
  end
  def test_setup_graph_measurements
    @sidebar.instance_eval('@maximum_value = 123')
    @sidebar.instance_eval('@spread = 0.0')
    @sidebar.instance_eval('@marker_count = 1.0')
    assert_in_delta(435.0, @sidebar.setup_graph_measurements, 0.01)
  end
  def test_setup_graph_measurements__hide_line_markers
    @sidebar.instance_eval('@maximum_value = 123')
    @sidebar.instance_eval('@spread = 0.0')
    @sidebar.instance_eval('@marker_count = 1.0')
    @sidebar.instance_eval('@hide_line_markers = 0')
    assert_in_delta(468.0, @sidebar.setup_graph_measurements, 0.01)
  end
  def test_setup_graph_measurements__has_left_labels
    @sidebar.instance_eval('@maximum_value = 123')
    @sidebar.instance_eval('@spread = 0.0')
    @sidebar.instance_eval('@marker_count = 1.0')
    @sidebar.instance_eval('@has_left_labels = true')
    @sidebar.labels = {'key' => ' 1 /x '}
    assert_in_delta(435.0, @sidebar.setup_graph_measurements, 0.01)
  end
  def test_draw_title
    @sidebar.instance_eval('@hide_title = nil')
    @sidebar.instance_eval('@title = "title"')
    assert_kind_of(Magick::Draw, @sidebar.draw_title)
  end
  def test_draw_title__nil
    assert_nil(@sidebar.draw_title)
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
    assert_nil(@sidebar.draw_label(0,0))
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

class TestDDDChart <Minitest::Test
  def setup_test(price = 123)
    @package  = flexmock('package'+ name,
                        :sequence             => 'sequence',
                       )
    lookandfeel = flexmock('lookandfeel', :lookup => 'lookup')
    @package.should_receive(:ddd_price).and_return(price).by_default
    @package.should_receive(:generic_group_factor).and_return(price ? 'generic_group_factor' : nil)
    @session = flexmock('session',
                        :language          => 'language',
                        :lookandfeel       => lookandfeel
                       )
    @session.should_receive(:package_by_ikskey).and_return(@package).by_default
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
    @model   = flexmock('model_'+name,
                        :ddd_price => price,
                        :name_base => 'name_base',
                        :parts     => [part],
                        :sequence  => sequence,
                        :commercial_forms     => [commercial_form],
                       )
    @model.should_receive(:generic_group_factor).and_return(price ? 'generic_group_factor' : 2)
    @chart   = ODDB::View::Ajax::DDDChart.new([@model], @session)
  end
  def test_init
    setup_test
    assert_nil(@chart.init)
  end
  def test_to_html
    setup_test
    flexmock(@session) do |s|
      s.should_receive(:user_input).once.with(:factor)
    end
    cgi = flexmock('cgi')
    result =  @chart.to_html(cgi)
    assert_kind_of(String, result)
    assert_equal([123], @chart.data)
  end
  def test_to_html_empty_data
    setup_test(nil)
    @package.should_receive(:generic_group_factor).and_return(nil)
    @model.should_receive(:generic_group_factor).and_return(2)
    @package.should_receive(:ddd_price).and_return(nil)
    @session.should_receive(:package_by_ikskey).and_return(@package)
    flexmock(@session) do |s|
      s.should_receive(:user_input).once.with(:factor)
    end
    cgi = flexmock('cgi')
    result =  @chart.to_html(cgi)
    assert_equal(2, @model.generic_group_factor)
    assert_nil(@package.generic_group_factor)
    assert_kind_of(String, result)
    assert_equal([], @chart.data)
  end
end
