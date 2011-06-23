#!/usr/bin/env ruby
# ODDB::AnalysisParse::TestAnalysisHpricot -- oddb.org -- 23.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path('../../../src', File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'model/analysis/position'
require 'analysis_hpricot'
require 'iconv'

module ODDB
  module AnalysisParse

class TestAnalysisHpricot < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @hpricot = ODDB::AnalysisParse::AnalysisHpricot.new
  end
  def test_format_string
    assert_equal('text', @hpricot.format_string('text'))
  end
  def test_fetch_additional_info
    assert_equal({}, @hpricot.fetch_additional_info('<html>html</html>'))
  end
  def test_fetch_additional_info__Beschreibung
    html = "<tr align='left'><td colspan='2'><strong>Beschreibung</strong></td></tr>" + 
           "<tr align='left'><td colspan='2'>Beschreibung</td></tr>"
    expected = {:info_description => "Beschreibung"}
    assert_equal(expected, @hpricot.fetch_additional_info(html))
  end
  def test_fetch_additional_info__Interpretation
    html = "<tr align='left'><td colspan='2'><strong>Interpretation</strong></td></tr>" + 
           "<tr align='left'><td colspan='2'>Interpretation</td></tr>"
    expected = {:info_interpretation => "Interpretation"}
    assert_equal(expected, @hpricot.fetch_additional_info(html))
  end
  def test_fetch_additional_info__Indikation
    html = "<tr align='left'><td colspan='2'><strong>Indikation</strong></td></tr>" + 
           "<tr align='left'><td colspan='2'>Indikation</td></tr>"
    expected = {:info_indication => "Indikation"}
    assert_equal(expected, @hpricot.fetch_additional_info(html))
  end
  def test_fetch_additional_info__Aussagekraft
    html = "<tr align='left'><td colspan='2'><strong>Aussagekraft (Bewertung)</strong></td></tr>" + 
           "<tr align='left'><td colspan='2'>Aussagekraft (Bewertung)</td></tr>"
    expected = {:info_significance => "Aussagekraft (Bewertung)"}
    assert_equal(expected, @hpricot.fetch_additional_info(html))
  end
  def test_fetch_additional_info__Entnahmematerial
    html = "<tr align='left'><td colspan='2'><strong>Entnahmematerial</strong></td></tr>" + 
           "<tr align='left'><td colspan='2'>Entnahmematerial</td></tr>"
    expected = {:info_ext_material => "Entnahmematerial"}
    assert_equal(expected, @hpricot.fetch_additional_info(html))
  end
  def test_fetch_additional_info__Entnahmebedingungen
    html = "<tr align='left'><td colspan='2'><strong>Entnahmebedingungen</strong></td></tr>" + 
           "<tr align='left'><td colspan='2'>Entnahmebedingungen</td></tr>"
    expected = {:info_ext_condition => "Entnahmebedingungen"}
    assert_equal(expected, @hpricot.fetch_additional_info(html))
  end
  def test_fetch_additional_info__Lagerungsbedingungen
    html = "<tr align='left'><td colspan='2'><strong>Lagerungsbedingungen</strong></td></tr>" + 
           "<tr align='left'><td colspan='2'>Lagerungsbedingungen</td></tr>"
    expected = {:info_storage_condition => "Lagerungsbedingungen"}
    assert_equal(expected, @hpricot.fetch_additional_info(html))
  end
  def test_fetch_additional_info__Lagerunsgdauer
    html = "<tr align='left'><td colspan='2'><strong>Lagerunsgdauer</strong></td></tr>" + 
           "<tr align='left'><td colspan='2'>Lagerunsgdauer</td></tr>"
    expected = {:info_storage_time => "Lagerunsgdauer"}
    assert_equal(expected, @hpricot.fetch_additional_info(html))
  end
  def test_fetch_position_hrefs
    flexmock(@hpricot, :open => '')
    position = flexmock('position') do |pos|
      pos.should_receive(:inner_html).and_return('code')
      pos.should_receive(:attributes).and_return({'href' => 'url_base'})
    end
    document = flexmock('document') do |doc|
      doc.should_receive(:/).and_return([position])
    end
    @hpricot.fetch_position_hrefs(document) do |code, info|
      assert_equal('code', code)
      assert_equal({}, info)
    end
  end
  def test_dacapo_infos
    flexmock(@hpricot, :open => '')
    @hpricot.dacapo_infos do |doc|
      assert_equal('', doc)
    end
  end
end


  end # AnalysisParse
end # ODDB
