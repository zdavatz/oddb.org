#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::TestPrescription -- oddb.org -- 06.08.2012 -- yasaka@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test-unit'
require 'flexmock'
require 'view/drugs/prescription'

module ODDB
  module View
    module Drugs
class TestPrescriptionInnerForm < Test::Unit::TestCase
  include FlexMock::TestCase
  def test_init
    # pending
  end
end

class TestPrescriptionDrugsHeader < Test::Unit::TestCase
  include FlexMock::TestCase
  def test_init
    # pending
  end
end
class TestPrescriptionDrugSearchForm < Test::Unit::TestCase
  def test_init
    # pending
  end
end
class TestPrescriptionForm < Test::Unit::TestCase
  def test_init
    # pending
  end
end
class TestPrescriptionComposite < Test::Unit::TestCase
  def test_init
    # pending
  end
end
class TestPrescriptionPrintInnerComposite < Test::Unit::TestCase
  def test_init
    # pending
  end
end
class TestPrescriptionPrintComposite < Test::Unit::TestCase
  def test_init
    # pending
  end
end
class TestPrescription < Test::Unit::TestCase
  def test_init
    # pending
  end
end
class TestPrescriptionPrint < Test::Unit::TestCase
  def test_init
    # pending
  end
end
class TestPrescriptionCsv < Test::Unit::TestCase
  def test_init
    # pending
  end
end
    end
  end
end
