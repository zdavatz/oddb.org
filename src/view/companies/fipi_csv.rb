#!/usr/bin/env ruby
# encoding: utf-8
# View::Companies::FiPiCsv -- de.oddb.org -- 04.12.2006 -- hwyss@ywesee.com

require 'csv'
require 'htmlgrid/component'
require 'view/additional_information'
require 'view/companies/fipi_overview'

module ODDB
  module View
    module Companies
class FiPiCsv < HtmlGrid::Component
  include AdditionalInformation
  include FiPiMethods
  COMPONENTS = [
    :name_base,
    :galenic_form,
    :dose,
    :comparable_size,
    :barcode,
    :swissmedic_numbers,
    :date_fi_de,
    :date_fi_fr,
    :date_pi_de,
    :date_pi_fr,
  ]
  def http_headers
    name = @model.name.gsub(/[\s]+/u, '_')
    {
      'Content-Type'         =>  'text/csv',
      'Content-Disposition'  =>  "attachment;filename=#{name}.csv",
    }
  end
  def to_csv(keys)
    result = ''
    lang = @session.language
    CSV::Writer.generate(result, ';') { |writer|
      writer << [@lookandfeel.lookup(:fachinfos), model.fi_count]
      writer << [@lookandfeel.lookup(:patinfos), model.pi_count]
      writer << keys.collect { |key| 
        @lookandfeel.lookup("th_#{key}") { key.to_s }
      }
      @model.packages.each { |pac|
        writer << keys.collect { |key|
          if(self.respond_to?(key))
            item = self.send(key, pac)
            case item
            when SimpleLanguage
              item.send(lang)
            when HtmlGrid::Value
              item.value
            else
              item
            end
          else
            pac.send(key)
          end.to_s
        }
      }
    }
    result
  end
  def to_html(context)
    to_csv(COMPONENTS)
  end
end
    end
  end
end
