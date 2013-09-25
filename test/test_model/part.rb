#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestPart -- oddb.org -- 08.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'model/part'

module ODDB
  class TestPart <Minitest::Test
    include FlexMock::TestCase
    def setup
      flexmock(ODBA.cache, :next_id => 123)
      @part = ODDB::Part.new
    end
    def test_active_agents
      assert_equal([], @part.active_agents)
    end
    def test_comparable_size
      assert_equal(Quanty(0,''), @part.comparable_size)
    end
    def test_multiplier
      assert_in_delta(1.0, @part.multiplier, 1e-10)
    end
    def test_set_comparable_size
      assert_equal(Quanty(1.0,''), @part.set_comparable_size!)
    end
    def test_parse_size_multi
      expected = [0, Quanty(10,''), 1, Quanty(20,'ml'), Quanty(1,''), nil]
      assert_equal(expected, @part.parse_size('10 x 20 ml'))
    end
    def test_parse_size_addition
      expected = [10, Quanty(1,''), 1, Quanty(20,'g'), Quanty(1,''), nil]
      assert_equal(expected, @part.parse_size('10 + 20 g'))
    end
    def test_parse_size_tabletten
      expected = [0, Quanty(1,''), 3, Quanty(1,''), Quanty(1,''), 'Tablette(n)']
      assert_equal(expected, @part.parse_size('3 Tablette(n)'))
    end
    def test_size=
      assert_equal('10 x 20 ml', @part.size = '10 x 20 ml')
    end
    def test_dose_from_multi
      multi = [['123', 'ml']]
      expected = Quanty(123,'ml')
      assert_equal(expected, @part.dose_from_multi(multi))
    end
    def test_dose_from_multi__nil
      expected = Quanty(1,'')
      assert_equal(expected, @part.dose_from_multi(nil))
    end
    def test__composition_scale
      dose        = flexmock('dose', :scale => 'scale')
      composition = flexmock('composition', :doses => [dose])
      @part.instance_eval('@composition = composition')
      assert_equal('scale', @part._composition_scale)
    end

    def test_init
      pointer = flexmock('pointer', :append => 'append')
      @part.instance_eval('@pointer = pointer')
      assert_equal('append', @part.init('app'))
    end
    def test_commercial_form
      commercial_form = flexmock('commercial_form', 
                                 :remove_package => 'remove_package',
                                 :add_package    => 'add_package'
                                )
      @part.instance_eval('@commercial_form = commercial_form')
      assert_equal(commercial_form, @part.commercial_form = commercial_form)
    end
    def test_fix_pointers
      flexmock(@part, :odba_store => 'odba_store')
      package = flexmock('package', :pointer => [])
      @part.instance_eval('@package = package')
      assert_equal('odba_store', @part.fix_pointers)
    end
    def test_size
      @part.instance_eval do 
        @multi = 2
        @count = 3
        @addition = 4
        @commercial_form = 'commercial_form'
      end
      expected = "2 x 4 + 3 commercial_form"
      assert_equal(expected, @part.size)
    end
    def test_size__measure
      @part.instance_eval do 
        @multi = 2
        @count = 3
        @addition = 4
        @measure = 'measure'
      end
      expected = "2 4 + 3 x measure"
      assert_equal(expected, @part.size)
    end
    def test_adjust_types
      # This is a testcase for a private method
      flexmock(ODDB::Persistence::Pointer).new_instances do |p|
        p.should_receive(:resolve).and_return('resolve')
      end
      values = {'key' => Persistence::Pointer.new, :measure => '1.0', :multi => '2.0'}
      expected = {:measure=>Quanty(1,''), :multi=>2, "key"=>"resolve"}
      assert_equal(expected, @part.instance_eval('adjust_types(values)'))
    end
  end
end # ODDB
