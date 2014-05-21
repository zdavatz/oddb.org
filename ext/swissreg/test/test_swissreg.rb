#!/usr/bin/env ruby
# Swissreg::TestSession -- oddb -- 04.05.2006 -- hwyss@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path('../../../src', File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'swissreg'
require 'writer'
require 'flexmock'

module ODDB
  module Swissreg
    class TestSession <Minitest::Test
      include FlexMock::TestCase
      def setup
        @session  = Session.new
        @base     = 'https://www.swissreg.ch'
        @detail_for_46574  = '/srclient/faces/jsp/spc/sr300.jsp?language=de&section=spc&id=C644840/01'
        @expected_for_46574 = {
                :certificate_number      => "C644840/01",
                :issue_date              => Date.new(1996, 8, 31),
                :publication_date        => Date.new(1996, 6, 28),
                :registration_date       => Date.new(1996, 2, 29),
                :protection_date         => Date.new(1998, 8, 14),
                :base_patent_date        => Date.new(1978, 8, 14),
                :base_patent             => "CH644840",
                :iksnrs                  => ["46574"],
                :expiry_date             => Date.new(2000, 8, 17),
                :deletion_date           => Date.new(2000, 8, 17)
        }
        @detail_for_54642   = '/srclient/faces/jsp/spc/sr300.jsp?language=de&section=spc&id=C00463756/01'
        @expected_for_54642 = {
                :certificate_number     => "C00463756/01",
                :expiry_date            => Date.new(2013, 6, 21),
                :issue_date             => Date.new(1999, 7, 30),
                :publication_date       => Date.new(1998, 8, 31),
                :registration_date      => Date.new(1998, 8, 11),
                :protection_date        => Date.new(2011, 6, 7),
                :base_patent_date       => Date.new(1991, 6, 7),
                :base_patent            => "EP00463756",
                :iksnrs                 => ["54642"],
                :deletion_date          => Date.new(2013, 6, 21),
        }

      end
      def test_get_result_list__online
        data =  Swissreg.search("54642")
        assert_equal(1, data.size  )
        assert_equal(@expected_for_54642, data[0]  )
      end

      # test result for 54642 sildenafil EP00463756
      def test_detail_online_for_54642
        data = Swissreg.get_detail(@detail_for_54642)
        assert_equal(@expected_for_54642, data)
      end

      def test_detail_online_for_46574
        data = Swissreg.get_detail(@detail_for_46574)
        assert_equal(@expected_for_46574, data)
      end

      def update_registration(iksnr, data)
        # dummy implementation
        puts "SwissregPlugin.update_registrations data #{iksnr} #{data.inspect} " if $VERBOSE
      end
      def test_failure_2014_may
        @patents = 0
        patents = Swissreg.search("46574")
        assert_equal(1, patents.size)
        # here the loop as used by src/plugin/swissreg.rb
        patents.each do |data|
          # if found in swissreg.ch
          @iksnrs  = []
          @patents += 1
          if(iksnrs = data[:iksnrs])
            @iksnrs.push(data)
            iksnrs.each { |iksnr|
              update_registration(iksnr, data)
            }
          end
        end
      end
    end
  end
end
