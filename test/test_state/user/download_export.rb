#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestDownloadExport -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com
# ODDB::TestDownloadExport -- oddb.org -- 19.04.2005 -- hwyss@ywesee.com

$: << File.expand_path('../../../src', File.dirname(__FILE__))
$: << File.expand_path('..', File.dirname(__FILE__))


gem 'minitest'
require 'minitest/autorun'
require 'define_empty_class'
require 'htmlgrid/select'
require 'state/user/download_export'

module ODDB
	module State
		module User
class TestDownloadExport <Minitest::Test
	def test_price
		assert_equal(600, DownloadExport.price('oddb.yaml.gz'))
		assert_equal(600, DownloadExport.price('oddb.yaml.zip'))
		assert_equal(1900, DownloadExport.price('fachinfo.yaml.gz'))
		assert_equal(1900, DownloadExport.price('fachinfo.yaml.zip'))
		assert_equal(1300, DownloadExport.price('patinfo.yaml.gz'))
		assert_equal(1300, DownloadExport.price('patinfo.yaml.zip'))
		assert_equal(700, DownloadExport.price('oddbdat.tar.gz'))
		assert_equal(700, DownloadExport.price('oddbdat.zip'))
		assert_equal(900, DownloadExport.price('s31x.gz'))
		assert_equal(900, DownloadExport.price('s31x.zip'))
	end
  def test_duration
    assert_equal(0, DownloadExport.duration('file'))
    assert_equal(30, DownloadExport.duration('analysis.csv'))
  end
  def test_subscription_duration
    assert_equal(0, DownloadExport.subscription_duration('file'))
    assert_equal(365, DownloadExport.subscription_duration('chde.xls'))
  end
  def test_subscription_price
    assert_equal(0, DownloadExport.subscription_price('file'))
    assert_equal(2000, DownloadExport.subscription_price('chde.xls'))
  end
end
		end
	end
end
