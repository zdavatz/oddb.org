#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestResultSort -- oddb.org -- 23.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'util/resultsort'
require 'model/dose'

module ODDB
  class StubResultStateSort
    include ODDB::ResultStateSort
    def initialize(model)
      @model = model
    end
    def get_sortby!
    end
  end

  class TestResultStateSort < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      package = flexmock('package', :expired? => nil)
      @model = flexmock('model', :packages => [package])
      @sort  = ODDB::StubResultStateSort.new([@model])
    end
    def test_sort
      assert_equal(@sort, @sort.sort)
    end
  end

  class StubResultSort
    include ODDB::ResultSort
    def initialize(packages)
      @packages = packages
    end
  end

  class TestResultSort < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @session = flexmock('session', :language => 'language')
      @galenic_form = flexmock('galenic_form', :odba_instance => nil)
      @package = flexmock('package', 
                          :generic_type => :original,
                          :expired?  => nil,
                          :name_base => 'name_base',
                          :galenic_forms => [@galenic_form],
                          :dose => 'dose',
                          :comparable_size => 'comparable_size'
                         )
      @sort    = ODDB::StubResultSort.new([@package])
    end
    def test_dose_value
      assert_equal(Quanty(0,''), @sort.dose_value(nil))
    end
    def test_package_count
      assert_equal(1, @sort.package_count)
    end
    def test_galform_str
      assert_equal('', @sort.galform_str(@galenic_form, @session))
    end
    def test_galform_str__else
      flexmock(@galenic_form, 
               :odba_instance => 'odba_instance',
               :language => 'language'
              )
      assert_equal('language', @sort.galform_str(@galenic_form, @session))
    end
    def test_generic_type_weight__originel
      assert_equal(0, @sort.generic_type_weight(@package))
    end
    def test_generic_type_weight__generic
      flexmock(@package, :generic_type => :generic)
      assert_equal(5, @sort.generic_type_weight(@package))
    end
    def test_generic_type_weight__comarketing
      flexmock(@package, :generic_type => :comarketing)
      assert_equal(10, @sort.generic_type_weight(@package))
    end
    def test_generic_type_weight__complementary
      flexmock(@package, :generic_type => :complementary)
      assert_equal(15, @sort.generic_type_weight(@package))
    end
    def test_generic_type_weight__else
      flexmock(@package, :generic_type => 'else')
      assert_equal(20, @sort.generic_type_weight(@package))
    end
    def test_sort_result
      assert_equal([@package], @sort.sort_result([@package], @session))
    end
    def stdout_null
      require 'tempfile'
      $stdout = Tempfile.open('stdout')
      yield
      $stdout.close
      $stdout = STDERR
    end
    def test_sort_result__error
      flexmock(@package) do |p|
        p.should_receive(:expired?).and_raise(StandardError)
      end
      stdout_null do 
        assert_equal([@package], @sort.sort_result([@package], @session))
      end
    end
  end

end # ODDB

