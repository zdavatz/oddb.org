#!/usr/bin/env ruby
# Swissreg::TestSession -- oddb -- 04.05.2006 -- hwyss@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path('../../../src', File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'swissreg'

module ODDB
  module Swissreg
    class TestSession <Minitest::Test
      def setup
        @session = Session.new
        @base    = 'https://www.swissreg.ch'
        @detail  = '/srclient/faces/jsp/spc/sr300.jsp?language=de&section=spc&id=C00463756/01'
      end
      def test_get_result_list__online
        links = Swissreg.search("54642")
        expected = [
          @base + @detail,
        ]
        assert_equal(expected, links)
      end

      # test result for 54642 sildenafil EP00463756
      def test_detail_online
        data = Swissreg.get_detail(@detail)
        expected = {
                :base_patent            => "EP00463756",
                :base_patent_date       => Date.new(1991, 6, 7),
                :certificate_number     => "C00463756/01",
                :expiry_date            => Date.new(2013, 6, 21),
                :iksnrs                 => ["54642"],
                :issue_date             => Date.new(1999, 7, 30),
                :protection_date        => Date.new(2011, 6, 7),
                :publication_date       => Date.new(1998, 8, 31),
                :registration_date      => Date.new(1998, 8, 11),
                :deletion_date          => Date.new(2013, 6, 21),
        }
        assert_equal(expected, data)
      end

      def test_extract_result_links
        path = File.expand_path('data/sildenafil.html',
        File.dirname(__FILE__))
        html = File.read(path)
        expected = [
          @base + @detail,
          # "/srclient/faces/jsp/spc/sr300.jsp?language=de&section=spc&id=C00463756/01",
        ]
        assert_equal(expected, @session.extract_result_links(html))
      end
    end
  end
end
