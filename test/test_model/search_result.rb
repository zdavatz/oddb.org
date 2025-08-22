#!/usr/bin/env ruby

# ODDB::TestSearchResult -- oddb.org -- 15.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "stub/odba"
require "flexmock/minitest"
require "model/search_result"
require "model/sequence"

module ODDB
  class TestAtcFacade < Minitest::Test
    def setup
      @result = flexmock("result")
      @session = flexmock("session")
      @lnf = flexmock("lnf", enabled?: false)
      @session.should_receive(:request_path).and_return(nil)
      @session.should_receive(:lookandfeel).and_return(@lnf)
      @session.should_receive(:user).and_return(nil)
      @atc = ODDB::AtcClass.new("C07AA05")
      @facade = ODDB::AtcFacade.new(@atc, @session, @result)
    end

    def test_active_packages
      flexmock(@atc, packages: [flexmock("active", expired?: false, to_s: "active_package")])
      assert_equal(1, @facade.active_packages.size)
      assert_equal("active_package", @facade.active_packages.first.to_s)
    end

    def test_code
      flexmock(@atc, code: "code")
      assert_equal("code", @facade.code)
    end

    def test_description
      flexmock(@atc, description: "description")
      assert_equal("description", @facade.description)
    end

    def test_odba_id
      flexmock(@atc, odba_id: "odba_id")
      assert_equal("odba_id", @facade.odba_id)
    end

    def setup_two_packages(sequence)
      @package1 = flexmock("package1",
        expired?: false,
        generic_type: :original,
        name_base: "package1",
        galenic_forms: [],
        dose: "dose",
        company: "company",
        out_of_trade: false,
        sequence: sequence,
        sl_generic_type: :original,
        comparable_size: 1,
        sl_entry: nil,
        registration: flexmock("registration", name_base: "registration1"),
        iksnr: "isknr",
        seqnr: "isknr",
        ikscd: "ikscd",
        ikscat: "ikscat",
        name: "name_package1")
      @package2 = flexmock("package2",
        expired?: false,
        generic_type: :original,
        name_base: "package2",
        galenic_forms: [],
        dose: "dose",
        company: "company",
        out_of_trade: false,
        sequence: sequence,
        sl_generic_type: :original,
        comparable_size: 1,
        sl_entry: nil,
        registration: flexmock("registration", name_base: "registration2"),
        iksnr: "isknr",
        seqnr: "isknr",
        ikscd: "ikscd",
        ikscat: "ikscat",
        name: "name_package2")
    end

    def test_packages
      sequence = flexmock("sequence", name: "sequence")
      setup_two_packages(sequence)
      active_packages = [@package2, @package1]
      flexmock(@atc, packages: active_packages)
      expected = [@package1, @package2]
      assert_equal(expected, @facade.packages)
    end

    def test_empty?
      flexmock(@atc, packages: [])
      assert(@facade.empty?)
    end

    def test_has_ddd?
      package = flexmock("package", ddd: "ddd", expired?: false)
      flexmock(@atc, packages: [package])
      @facade = ODDB::AtcFacade.new(@atc, @session, @result)
      assert(@facade.has_ddd?)
    end

    def test_overflow?
      flexmock(@result, overflow?: true)
      assert(@facade.overflow?)
    end

    def test_pointer
      flexmock(@atc, pointer: "pointer")
      assert_equal("pointer", @facade.pointer)
    end

    def test_package_count
      assert_equal(0, @facade.package_count)
    end

    def test_parent_code
      flexmock(@atc, parent_code: "parent_code")
      assert_equal("parent_code", @facade.parent_code)
    end

    def test_sequences
      sequence = flexmock("sequence", active?: true)
      flexmock(@atc, sequences: [sequence])
      assert_equal([sequence], @facade.sequences)
    end
  end

  class TestSearchResult < Minitest::Test
    def setup
      @result = ODDB::SearchResult.new
      @package = create_package
    end

    def create_package(name = "package")
      flexmock(name,
        expired?: nil,
        generic_type: :original,
        name: name + "xx",
        name_base: name,
        galenic_forms: [],
        dose: "dose",
        company: "company",
        out_of_trade: false,
        sl_generic_type: :original,
        comparable_size: 1,
        sl_entry: nil,
        registration: flexmock("registration", name_base: "registration"),
        iksnr: "isknr",
        seqnr: "isknr",
        ikscd: "ikscd",
        ikscat: "ikscat",
        public?: true)
    end

    def testresult_with_2_packages
      @atc = ODDB::AtcClass.new("C07AA05")
      @atc.sequences << ODDB::Sequence.new("01")

      @package1 = create_package("package1")
      @package2 = create_package("package2")
      @atc.sequences.first.packages["001"] = @package1
      @atc.sequences.first.packages["002"] = @package2
      assert_equal(2, @atc.sequences.first.package_count)
      @result.atc_classes = [@atc]
      assert_equal(2, @result.package_count)
    end

    def test_atc_facades
      flexmock("atc_class")
      @result.instance_eval("@atc_classes = [atc_class]", __FILE__, __LINE__)
      result = @result.atc_facades
      assert_equal(1, result.length)
      assert_kind_of(ODDB::AtcFacade, result[0])
    end

    def test_empty?
      assert(@result.empty?)
    end

    def test_sequence_filter_nil
      testresult_with_2_packages
      @result.sequence_filter
      assert_equal(2, @result.package_count)
    end

    def test_sequence_filter_true
      testresult_with_2_packages
      @result.sequence_filter = proc { |seq| true }
      assert(@result.sequence_filter)
      assert_equal(2, @result.package_count)
    end

    def test_sequence_filter_false
      testresult_with_2_packages
      @result.sequence_filter = proc { |seq| false }
      assert(@result.sequence_filter)
      assert_equal(0, @result.package_count)
    end

    def test_package_count
      testresult_with_2_packages
      assert_equal(2, @result.package_count)
    end

    def test_overflow?
      flexmock("atc_class", package_count: 1)
      @result.instance_eval("@atc_classes = [atc_class]", __FILE__, __LINE__)
      assert_equal(false, @result.overflow?)
    end

    def test_set_relevance
      relevance = 1.23
      odba_id = 0
      assert_in_delta(1.23, @result.set_relevance(odba_id, relevance), 1e-10)
    end

    def test_delete_empty_packages
      # This is a testcase for a private method
      flexmock("atc_class", packages: [])
      assert_equal([], @result.instance_eval("delete_empty_packages([atc_class])", __FILE__, __LINE__))
    end

    def test_atc_sorted__already
      @result.instance_eval('@atc_sorted = "atc_sorted"', __FILE__, __LINE__)
      assert_equal("atc_sorted", @result.atc_sorted)
    end

    def test_atc_sorted
      flexmock("atc_class",
        package_count: 1,
        packages: [@package])
      @result.instance_eval("@atc_classes = [atc_class]", __FILE__, __LINE__)
      result = @result.atc_sorted
      assert_equal(1, result.length)
      assert_kind_of(ODDB::AtcFacade, result[0])
    end

    def test_atc_sorted__overflow
      flexmock("atc_class",
        package_count: 1,
        packages: [@package],
        description: "description")
      @result.instance_eval("@atc_classes = [atc_class, atc_class]", __FILE__, __LINE__)
      @result.instance_eval("@display_limit = 0", __FILE__, __LINE__)
      result = @result.atc_sorted
      assert_equal(2, result.length)
      assert_kind_of(ODDB::AtcFacade, result[0])
    end

    def test_atc_sorted__search_type_substance
      active_agent = flexmock("active_agent", same_as?: nil)
      sequence = flexmock("sequence", name: "package")
      registration = flexmock("registration", name_base: "name_base")
      package = flexmock("package",
        expired?: nil,
        generic_type: :original,
        registration: registration,
        sl_entry: "sl_entry",
        name_base: "name_base",
        galenic_forms: [],
        dose: "dose",
        active_agents: [active_agent],
        company: "company",
        out_of_trade: false,
        comparable_size: 1,
        sequence: sequence,
        sl_generic_type: :original)
      flexmock("atc_class",
        package_count: 1,
        packages: [package])
      @result.instance_eval("@atc_classes = [atc_class]", __FILE__, __LINE__)
      @result.instance_eval("@search_type = :substance", __FILE__, __LINE__)
      result = @result.atc_sorted
      assert_equal(1, result.length)
      assert_kind_of(ODDB::AtcFacade, result[0])
    end

    def test_atc_sorted__relevance_not_empty
      flexmock("atc_class",
        package_count: 1,
        packages: [@package])
      @result.instance_eval("@atc_classes = [atc_class]", __FILE__, __LINE__)
      @result.instance_eval('@relevance = {"key" => "value"}', __FILE__, __LINE__)
      result = @result.atc_sorted
      assert_equal(1, result.length)
      assert_kind_of(ODDB::AtcFacade, result[0])
    end

    def test_atc_inactive_sequences
      sequence = flexmock("sequence", active?: false)
      flexmock("atc_class",
        package_count: 1,
        packages: [@package],
        sequences: [sequence])
      @result.instance_eval("@atc_classes = [atc_class]", __FILE__, __LINE__)
      @result.instance_eval('@relevance = {"key" => "value"}', __FILE__, __LINE__)
      @result.instance_eval("@search_type = :interaction", __FILE__, __LINE__)
      result = @result.atc_sorted
      assert_equal(1, result.length)
      assert_kind_of(ODDB::AtcFacade, result[0])
      assert_equal(0, result[0].sequences.size)
    end

    def test_atc_sorted__relevance_not_empty_interaction
      sequence = flexmock("sequence", active?: true)
      flexmock("atc_class",
        package_count: 1,
        packages: [@package],
        sequences: [sequence])
      @result.instance_eval("@atc_classes = [atc_class]", __FILE__, __LINE__)
      @result.instance_eval('@relevance = {"key" => "value"}', __FILE__, __LINE__)
      @result.instance_eval("@search_type = :interaction", __FILE__, __LINE__)
      result = @result.atc_sorted
      assert_equal(1, result.length)
      assert_kind_of(ODDB::AtcFacade, result[0])
      assert_equal(1, result[0].sequences.size)
    end

    def std_null
      require "tempfile"
      $stderr = Tempfile.open("stderr")
      $stdout = Tempfile.open("stdout")
      yield
      $stderr.close
      $stdout.close
      $stderr = STDERR
      $stdout = STDOUT
    end

    def test_atc_sorted__error
      flexmock("atc_class") do |a|
        a.should_receive(:package_count).and_raise(StandardError)
      end
      @result.instance_eval("@atc_classes = [atc_class]", __FILE__, __LINE__)
      std_null do
        result = @result.atc_sorted
        assert_equal(1, result.length)
        assert_kind_of(ODDB::AtcFacade, result[0])
      end
    end

    def test_each
      flexmock("atc_class",
        package_count: 1,
        packages: [@package])
      @result.instance_eval("@atc_classes = [atc_class]", __FILE__, __LINE__)
      @result.each do |atc|
        assert_kind_of(ODDB::AtcFacade, atc)
      end
    end

    def test_filtered_packages
      testresult_with_2_packages
      filter_proc = proc { |pack| !pack.name_base.eql?("package1") }
      assert_equal(2, @result.package_count)
      assert_equal(1, @result.atc_classes.size)
      assert_equal(2, @result.package_count)
      @result.package_filters = {"only_package1" => filter_proc}
      @result.apply_filters
      assert_equal(1, @result.package_count)
      assert_equal("package1", @result.atc_classes.first.packages.first.name_base)
      assert_equal(1, @result.atc_classes.size)
    end
  end
end
