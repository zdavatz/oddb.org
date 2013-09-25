#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::TestPrescription -- oddb.org -- 06.08.2012 -- yasaka@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/drugs/prescription'

module ODDB
  module View
    module Drugs
class TestPrescriptionInnerForm <Minitest::Test
  include FlexMock::TestCase
  def test_init
    # pending
  end
end

class TestPrescriptionDrugsHeader <Minitest::Test
  include FlexMock::TestCase
  def test_init
    # pending
  end
end
class TestPrescriptionDrugSearchForm <Minitest::Test
  def test_init
    # pending
  end
end
class TestPrescriptionForm <Minitest::Test
  def test_init
    # pending
  end
end
class TestPrescriptionComposite <Minitest::Test
  def test_init
    # pending
  end
end
class TestPrescriptionPrintInnerComposite <Minitest::Test
  def test_init
    # pending
  end
end
class TestPrescriptionPrintComposite <Minitest::Test
  def test_init
    # pending
  end
end
class TestPrescription <Minitest::Test
  def test_init
    # pending
  end
end
class TestPrescriptionPrint <Minitest::Test
  def test_init
    # pending
  end
end
class TestPrescriptionCsv <Minitest::Test
  def test_init
    # pending
  end
end
    end
  end
end
