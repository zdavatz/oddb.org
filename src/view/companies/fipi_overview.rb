#!/usr/bin/env ruby
# View::Companies::FiPiOverview -- oddb.org -- 27.11.2006 -- hwyss@ywesee.com

require 'view/privatetemplate'
require 'view/additional_information'
require 'view/drugs/result'
require 'htmlgrid/list'

module ODDB
  module View
    module Companies
module FiPiMethods
  def info_date(model, type, language)
    if((info = model.send(type)) \
       && (lang = info.descriptions[language.to_s]) \
       && (chapter = lang.date))
      chapter.sections.first.to_s[/\S+\s\d{4}/u]
    end
  end
  def date_fi_de(model)
    info_date(model, :fachinfo, :de)
  end
  def date_fi_fr(model)
    info_date(model, :fachinfo, :fr)
  end
  def date_pi_de(model)
    info_date(model, :patinfo, :de)
  end
  def date_pi_fr(model)
    info_date(model, :patinfo, :fr)
  end
  def swissmedic_numbers(model)
    if(fi = model.fachinfo)
      fi.iksnrs.join(', ')
    else
      model.iksnr
    end
  end
end
class ExportCSV < View::Form
  CSS_CLASS = 'right'
  COMPONENTS = {
    [0,0] => :submit,
  }
  EVENT = :export_csv
  def init
    super
    url = @lookandfeel._event_url(:export_csv)
    self.onsubmit = "location.href='#{url}';return false;"
  end
end
class FiPiOverviewList < HtmlGrid::List
  include AdditionalInformation
  include FiPiMethods
  COMPONENTS = {
    [0,0] => :name_base,
    [1,0] => :galenic_form,
    [2,0] => :dose,
    [3,0] => :comparable_size,
    [4,0] => :barcode,
    [5,0] => :swissmedic_numbers,
    [6,0] => :date_fi_de,
    [7,0] => :date_fi_fr,
    [8,0] => :date_pi_de,
    [9,0] => :date_pi_fr,
  }
  CSS_CLASS = 'composite'
  CSS_MAP = {
    [0,0,2] => 'list',
    [2,0,2] => 'list right',
    [4,0,6]  => 'list', 
  }
  CSS_HEAD_MAP = {
    [2,0] => 'subheading right',
    [3,0] => 'subheading right',
  }
  DEFAULT_HEAD_CLASS = 'subheading'
  SORT_DEFAULT = :name_base
  SORT_HEADER = false
  LEGACY_INTERFACE = false
end
class FiPiOverviewComposite < HtmlGrid::Composite
  COMPONENTS = {
    [0,0] => :counts,
    [1,0] => ExportCSV, 
    [0,1,0] => 'company', 
    [0,1,1] => :name, 
    [0,2]   => "fipi_overview_explain", 
    [0,3]   => :fipi_list, 
  }
  COLSPAN_MAP = {
    [0,1] => 2,
    [0,2] => 2,
    [0,3] => 2,
  }
  CSS_MAP = {
    [0,0] => 'result-found',
    [0,1] => 'th',
    [0,2] => 'migel-group list',
  }
  CSS_CLASS = 'composite'
  DEFAULT_CLASS = HtmlGrid::Value
  LEGACY_INTERFACE = false
  def counts(model)
    @lookandfeel.lookup(:fipi_counts, model.fi_count, model.pi_count)
  end
  def fipi_list(model)
    FiPiOverviewList.new(model.packages, @session, self)
  end
end
class FiPiOverview < PrivateTemplate
  CONTENT = FiPiOverviewComposite
  SNAPBACK_EVENT = :companies
end
    end
  end
end
