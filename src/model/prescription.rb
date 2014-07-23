#!/usr/bin/env ruby
# encoding: utf-8
# Prescriptions are not saved in the database to preserve the anonymity of our users.
# Therefor no mentioning of persistance and odba here
require 'date'
require 'model/package'
require 'model/doctor'
require 'util/today'

module ODDB
  class Prescription
    URL_FORMAT_DESCRIPTION  = 'http://2dmedication.org/'
    FORMAT_VERSION          = '1.0'
    SW_ORIGIN_ID            = 'ywesee GmBh'
    SW_VERSION_ID           = '1.0'
    QR_TIME_FORMAT          = '%Y%m%d'
    LOCAL_TIME_FORMAT       = '%d.%m.%Y'
    
    attr_reader :guid, # Eindeutiger Rezeptidentifier gemäss wikipedia.org/wiki/GUID
          :items 
    attr_accessor :doctor_glin,     # aka ean13
          :doctor_zsr,            # ZSR des ausstellenden Arztes
          :patient_id,            # Versichertenkartennummer des Patienten (VEKA)
          :date_issued,           # Datum der Rezeptausstellung
          :patient_family_name,
          :patient_first_name,
          :patient_zip_code,
          :patient_birthday,
          :patient_insurance_glin # aka  Patient KV EAN      
    
    class PrescriptionItem
      attr_accessor :ean13,
          :pharmacode,
          :description,
          :quantity,
          :valid_til,
          :simple_posology,
          :extended_posology,
          :nr_repetitions,
          :may_be_substituted
      def pretty
        "Rezept gültig bis: #{valid_til ? valid_til.strftime('%d.%m.%Y') : '' }\n" +
        "#{nr_repetitions}x [#{quantity}] #{ean13} #{pharmacode} #{description}"+
            "#{simple_posology ? "\n"+simple_posology : '' }#{extended_posology ? "\n"+extended_posology : '' }"
      end
      def is_valid?
        true
      end
      # initializes the item with sensible defaults
      def initialize
        @simple_posology = [0, 0, 0, 0]
        @may_be_substituted = true
        @quantity = 1
      end
    end
      
    # initializes the Prescription with sensible defaults
    def initialize
      @items = []
    end
    def add_item(prescription_item)
      raise "invalid prescription_item #{prescription_item}" unless prescription_item.is_valid?
      @items << prescription_item
    end
    def qr_string
      s = "#{URL_FORMAT_DESCRIPTION}|#{FORMAT_VERSION}|" +
          "#{guid}|#{SW_ORIGIN_ID}|#{SW_VERSION_ID}|" +
          "#{doctor_glin}|#{doctor_zsr}|#{patient_id}|#{date_issued.strftime(QR_TIME_FORMAT)}|#{patient_family_name}|#{patient_first_name}|"+
          "#{patient_zip_code}|#{patient_birthday.strftime(QR_TIME_FORMAT)}|#{patient_insurance_glin};"
      @items.each{ 
        |item|
      if item.ean13
        s +=  "#{item.ean13}|#{item.pharmacode}|#{ item.description}|"
      elsif item.pharmacode
        s +=  "#{item.ean13}|#{item.pharmacode}|#{ item.description}|"
      elsif item.ean13 == nil and item.description == nil 
        s +=  "#{item.ean13}|#{item.pharmacode}|#{ item.description}|"
      elsif item.description
        s +=  "||#{item.description}|"
      else
        raise "invalid item #{item.inspect}"
      end      
      s += item.quantity.to_s + '|'
      s += item.valid_til ? item.valid_til.strftime(QR_TIME_FORMAT)  + '|'    : '|'
      if item.simple_posology
        formatted =[]
        item.simple_posology.each{ |elem| formatted << sprintf('%0.2f', elem.to_f) }
        s += formatted.join('-') + '|'
      end
      s += item.extended_posology ? item.extended_posology + '|'              : '|'
      s += item.nr_repetitions ? item.nr_repetitions.to_s + '|'               : '|'
      s += item.may_be_substituted ? '0|' : '1|'
      }
      s = s.chomp('|')
      s += ';' + Prescription. checksum(s.clone).to_s
    end

    def pretty
      s = "Dr. #{doctor_glin} ZSR #{doctor_zsr}
Rezept ausgestellt am #{date_issued.strftime(LOCAL_TIME_FORMAT)}
Für #{patient_first_name} #{patient_family_name} ( #{patient_id})
Aus #{patient_zip_code} geboren am #{patient_birthday.strftime(LOCAL_TIME_FORMAT)}
Versicherungsnummer #{patient_insurance_glin}
"
      
      @items.each{ |item| s += item.pretty + "\n"  }
      s
    end

    def Prescription.checksum(s)
      # Fussdaten Prüfziffer Zahl (Long) Pflichtfeld ASCII Wertsumme des Textes, vor dem decodieren in Quoted Printable und ohne das letzte Feld und Trennzeichen
      checksum = 0
      0.upto(s.length-1).each{
        |idx|
          ascii = s[idx].ord 
          checksum += ascii
      }
      checksum
    end
  end
end
