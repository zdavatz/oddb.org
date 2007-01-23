#!/usr/bin/env ruby
# Swissreg::TestSession -- oddb -- 04.05.2006 -- hwyss@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path('../../../src', File.dirname(__FILE__))

require 'test/unit'
require 'session'

module ODDB
	module Swissreg
		class TestSession < Test::Unit::TestCase
			def setup
				@session = Session.new
			end
      def test_get_result_list__online
        links = @session.get_result_list("sildenafil")
				expected = [
          "/srclient/faces/jsp/spc/sr300.jsp?language=de&section=spc&id=C00463756/01",
				]
				assert_equal(expected, links)
      end
      def test_get_result_list__online__server_error
        links = nil
        assert_nothing_raised { 
          links = @session.get_result_list("Ammonia")
        }
				assert_equal([], links)
      end
      def test_get_detail__online
        url = "/srclient/faces/jsp/spc/sr300.jsp?language=de&section=spc&id=C00463756/01"
        data = @session.get_detail(url)
				expected = {
					:base_patent				=> "EP00463756",
					:base_patent_date		=> Date.new(1991, 6, 7),
					:certificate_number	=> "C00463756/01",
					:expiry_date				=> Date.new(2013, 6, 21),
					:iksnrs							=> ["54642"],
					:issue_date					=> Date.new(1999, 7, 30),
					:protection_date		=> Date.new(2011, 6, 7),
					:publication_date		=> Date.new(1998, 8, 31),
					:registration_date	=> Date.new(1998, 8, 11),
				}
        assert_equal(expected, data)
      end
      def test_get_detail__online__pemetrexed
        url = "/srclient/faces/jsp/spc/sr300.jsp?language=de&section=spc&id=C00432677%2F01"
        data = @session.get_detail(url)
				expected = {
					:base_patent				=> "EP00432677",
					:base_patent_date		=> Date.new(1990, 12, 10),
					:certificate_number	=> "C00432677/01",
					:expiry_date				=> Date.new(2015, 12, 9),
					:iksnrs							=> ["57039"],
					:issue_date					=> Date.new(2006, 12, 29),
					:protection_date		=> Date.new(2010, 12, 10),
					:publication_date		=> Date.new(2005, 4, 15),
					:registration_date	=> Date.new(2005, 3, 16),
				}
        assert_equal(expected, data)
      end
			def test_extract_result_links
        path = File.expand_path('data/sildenafil.html', 
                                File.dirname(__FILE__))
        html = File.read(path)
				expected = [
          "/srclient/faces/jsp/spc/sr300.jsp?language=de&section=spc&id=C00463756/01",
				]
				assert_equal(expected, @session.extract_result_links(html))
			end
		end
	end
end
