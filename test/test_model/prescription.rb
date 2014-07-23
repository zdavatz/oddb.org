#!/usr/bin/env ruby
# encoding: utf-8
# TestPatinfo -- oddb -- 25.02.2011 -- mhatakeyama@ywesee.com
# TestPatinfo -- oddb -- 29.10.2003 -- rwaltert@ywesee.com


$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'model/prescription'

module ODDB
  class Prescription
    attr_accessor :guid # for testing purposes only!
    SW_ORIGIN_ID            = 'TriaMed'
    SW_VERSION_ID           = '3.9.3.0'

    def Prescription.create_qrcode_example
      item1 = ODDB::Prescription::PrescriptionItem.new
      item1.pharmacode = '2014236'
      item1.may_be_substituted = false

      item2 = ODDB::Prescription::PrescriptionItem.new
      item2.description = 'SPEZIALVERBAND'
      item2.valid_til = Time.new(2013, 12, 14)  # '20131214'
      item2.nr_repetitions = 40
      
      item3 = ODDB::Prescription::PrescriptionItem.new
      item3.ean13 = '7680456740106'
      item3.simple_posology = [1, 1.0, 1, 0]
      item3.extended_posology = 'zu Beginn der Mahlzeiten mit mindestens einem halben Glas Wasser einzunehmen'

      prescription =  ODDB::Prescription.create_example_prescription
      prescription.add_item(item1)
      prescription.add_item(item2)
      prescription.add_item(item3)
      prescription
    end
    def Prescription.create_example_item
      item = ODDB::Prescription::PrescriptionItem.new
      item.ean13 = '7640111540007'
      item.pharmacode = '0020209'
      item.description = 'ERYTHROCIN i.v. Trockensub 1000 mg'
      item.quantity = 3
      item.valid_til = Time.new(2014, 12, 28)
      item.simple_posology = '1 0 0 0'
      item.extended_posology = 'Vor dem Morgenessen gemütlich'
      item.nr_repetitions = 3
      item
    end

    def Prescription.create_example_prescription
      prescription = ODDB::Prescription.new
      prescription.guid = '4dd33f59-1fbb-4fc9-96f1-488e7175d761'
      prescription.doctor_glin = '7601000092786'
      prescription.doctor_zsr          =  'K2345.33'
      prescription.patient_id = ''
      prescription.date_issued = Time.new(2013, 11, 04)
      prescription.patient_family_name = 'Beispiel'
      prescription.patient_first_name = 'Susanne'
      prescription.patient_zip_code = '3073'
      prescription.patient_birthday = Time.new(1946,8,1)
      prescription.patient_insurance_glin = '7601003000382'
      prescription
    end
  end
end


class TestPrescriptionItem <Minitest::Test
  def setup
    @item = ODDB::Prescription.create_example_item
  end

  def test_pretty
    expected = "Rezept gültig bis: 28.12.2014
3x [3] 7640111540007 0020209 ERYTHROCIN i.v. Trockensub 1000 mg
1 0 0 0
Vor dem Morgenessen gemütlich"

    assert_equal(expected, @item.pretty)
  end
end

class TestPrescription <Minitest::Test
  include FlexMock::TestCase
  def setup
    @prescription = ODDB::Prescription.create_example_prescription
  end
  def test_pretty
    expected = "Dr. 7601000092786 ZSR K2345.33
Rezept ausgestellt am 04.11.2013
Für Susanne Beispiel ( )
Aus 3073 geboren am 01.08.1946
Versicherungsnummer 7601003000382
Rezept gültig bis: 28.12.2014
3x [3] 7640111540007 0020209 ERYTHROCIN i.v. Trockensub 1000 mg
1 0 0 0
Vor dem Morgenessen gemütlich
"
    @prescription.add_item(ODDB::Prescription.create_example_item)
    assert_equal(expected, @prescription.pretty)
  end
  def test_qr_code_string
    prescription = ODDB::Prescription.create_qrcode_example
    expected = "http://2dmedication.org/|1.0|4dd33f59-1fbb-4fc9-96f1-488e7175d761|TriaMed|3.9.3.0|" +
        "7601000092786|K2345.33||20131104|Beispiel|Susanne|3073|19460801|7601003000382;"+
        "|2014236||1||0.00-0.00-0.00-0.00|||1|||SPEZIALVERBAND|1|20131214|0.00-0.00-0.00-0.00||40|0|"+
        "7680456740106|||1||1.00-1.00-1.00-0.00|zu Beginn der Mahlzeiten mit mindestens einem halben Glas Wasser einzunehmen||0;27834"
    assert_equal(expected, prescription.qr_string)
  end
  
  def test_checksum
    string =  "http://2dmedication.org/|1.0|4dd33f59-1fbb-4fc9-96f1-488e7175d761|TriaMed|3.9.3.0|" +
        "7601000092786|K2345.33||20131104|Beispiel|Susanne|3073|19460801|7601003000382;"+
        "|2014236||1||0.00-0.00-0.00-0.00|||1|||SPEZIALVERBAND|1|20131214|0.00-0.00-0.00-0.00||40|0|"+
        "7680456740106|||1||1.00-1.00-1.00-0.00|zu Beginn der Mahlzeiten mit mindestens einem halben Glas Wasser einzunehmen||0"
    assert_equal(27834, ODDB::Prescription.checksum(string))
  end
end
