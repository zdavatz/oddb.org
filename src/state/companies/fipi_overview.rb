#!/usr/bin/env ruby
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
  VIEW = View::Companies::FiPiOverview
  def init
    model = OpenStruct.new
    model.name = @model.name
    model.packages = @model.packages.select { |pac|
      pac.public? && (pac.fachinfo || pac.has_patinfo?)
    }
    @model = model
  end
  def export_csv
    FiPiCsv.new(@session, @model)
  end
end
    end
  end
end
