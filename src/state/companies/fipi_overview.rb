#!/usr/bin/env ruby
# encoding: utf-8
# State::Companies::FiPiOverview -- oddb.org -- 02.03.2011 -- mhatakeyama@ywesee.com
# State::Companies::FiPiOverview -- oddb.org -- 27.11.2006 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/companies/fipi_csv'
require 'view/companies/fipi_overview'
require 'ostruct'

module ODDB
  module State
    module Companies
class FiPiOverview < Global
  DIRECT_EVENT = :fipi_overview
  VIEW = ODDB::View::Companies::FiPiOverview
  def init
    fis = []
    pis = []
    model = OpenStruct.new
    model.name = @model.name
    model.packages = @model.packages.select { |pac|
      if(pac.public?)
        take = false
        if(fi = pac.fachinfo)
          fis.push(fi)
          take = true
        end
        if(pac.has_patinfo?)
          pis.push(pac.pdf_patinfo || pac.patinfo)
          take = true
        end
        take
      end
    }
    model.fi_count = fis.uniq.size
    model.pi_count = pis.uniq.size
    @model = model
  end
  def export_csv
    FiPiCsv.new(@session, @model)
  end
end
    end
  end
end
