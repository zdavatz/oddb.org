#!/usr/bin/env ruby
# TestDownloadExport -- ODDB -- 19.04.2005 -- hwyss@ywesee.com

$: << File.expand_path('../../../src', File.dirname(__FILE__))

require 'test/unit'
require 'state/user/download_export'

module ODDB
	module State
		module User
class TestDownloadExport < Test::Unit::TestCase
	def test_price
		assert_equal(600, DownloadExport.price('oddb.yaml.gz'))
		assert_equal(600, DownloadExport.price('oddb.yaml.zip'))
		assert_equal(800, DownloadExport.price('fachinfo.yaml.gz'))
		assert_equal(800, DownloadExport.price('fachinfo.yaml.zip'))
		assert_equal(500, DownloadExport.price('patinfo.yaml.gz'))
		assert_equal(500, DownloadExport.price('patinfo.yaml.zip'))
		assert_equal(700, DownloadExport.price('oddbdat.tar.gz'))
		assert_equal(700, DownloadExport.price('oddbdat.zip'))
		assert_equal(900, DownloadExport.price('s31x.gz'))
		assert_equal(900, DownloadExport.price('s31x.zip'))
	end
end
		end
	end
end
