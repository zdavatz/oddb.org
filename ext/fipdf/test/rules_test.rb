#!/usr/bin/env ruby
#TestRules -- oddb -- 02.02.2004 -- mwalder@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'fachinfo_writer'
require 'rules.rb'
require 'model/text'
require 'date'

module ODDB
	module FiPDF
		class Rule
		end
	end
	class TestFachinfoRule < Test::Unit::TestCase
		def setup
			@fachinfo_rule = ODDB::FiPDF::FachinfoRule.new(:Fachinfo_rule)
		end
		def test_fachinfo_fulfilled
			@fachinfo_rule.notify(:write_paragraph)
			@fachinfo_rule.notify(:ez_new_page)
			assert_equal(true, @fachinfo_rule.fulfilled?)
			@fachinfo_rule.notify(:write_paragraph)
			assert_equal(true, @fachinfo_rule.fulfilled?)
		end
		def test_fachinfo_fulfilled_no_page_break
			@fachinfo_rule.notify(:write_paragraph)
			assert_equal(true, @fachinfo_rule.fulfilled?)
			@fachinfo_rule.notify(:write_paragraph)
			assert_equal(true, @fachinfo_rule.fulfilled?)
		end
		def test_fachinfo_not_fulfilled
			@fachinfo_rule.notify(:ez_new_page)
			assert_equal(false, @fachinfo_rule.fulfilled?)
			@fachinfo_rule.notify(:write_paragraph)
			assert_equal(false, @fachinfo_rule.fulfilled?)
		end
	end
	class TestOrphanRule < Test::Unit::TestCase
		def setup
			@orphan_rule = ODDB::FiPDF::OrphanRule.new(:orphan_rule)
		end
		def test_orphan_fulfilled
			@orphan_rule.notify(:add_text_wrap)
			@orphan_rule.notify(:add_text_wrap)
			@orphan_rule.notify(:ez_new_page)
			assert_equal(true, @orphan_rule.fulfilled?)
		end
		def test_orphan_not_fulfilled
			@orphan_rule.notify(:add_text_wrap)
			@orphan_rule.notify(:ez_new_page)
			@orphan_rule.notify(:add_text_wrap)
			assert_equal(false, @orphan_rule.fulfilled?)
		end
		def test_orphan_not_fulfilled2
			@orphan_rule.notify(:add_text_wrap)
			@orphan_rule.notify(:ez_new_page)
			@orphan_rule.notify(:add_text_wrap)
			@orphan_rule.notify(:add_text_wrap)
			@orphan_rule.notify(:add_text_wrap)
			assert_equal(false, @orphan_rule.fulfilled?)
		end
		def test_orphan_single_line
			@orphan_rule.notify(:add_text_wrap)
			@orphan_rule.notify(:ez_new_page)
			assert_equal(true, @orphan_rule.fulfilled?)
		end
		def test_orphan_multiple_page_breaks
			@orphan_rule.notify(:add_text_wrap)
			@orphan_rule.notify(:ez_new_page)
			@orphan_rule.notify(:add_text_wrap)
			@orphan_rule.notify(:add_text_wrap)
			@orphan_rule.notify(:ez_new_page)
			assert_equal(false, @orphan_rule.fulfilled?)
		end
	end
	class TestWidowRule < Test::Unit::TestCase
		def setup
			@widow_rule = ODDB::FiPDF::WidowRule.new(:widow_rule)
		end
		def test_widow_rule_fulfilled
			@widow_rule.notify(:add_text_wrap)
			@widow_rule.notify(:add_text_wrap)
			@widow_rule.notify(:ez_new_page)
			assert_equal(true, @widow_rule.fulfilled?)
		end
		def test_widow_rule_not_fulfilled
			@widow_rule.notify(:add_text_wrap)
			@widow_rule.notify(:ez_new_page)
			@widow_rule.notify(:add_text_wrap)
			assert_equal(false, @widow_rule.fulfilled?)
		end
		def test_widow_single_line
			@widow_rule.notify(:add_text_wrap)
			assert_equal(true, @widow_rule.fulfilled?)
		end
	end
end
