#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Migel::Items -- oddb.org -- 15.08.2011 -- mhatakeyama@ywesee.com

require 'htmlgrid/list'
require 'view/additional_information'
require 'view/dataformat'

module ODDB
  module View
    module Migel

class SubHeader < HtmlGrid::Composite
  include View::AdditionalInformation
  include View::DataFormat
  COMPONENTS = {
    [0,0,0] => 'Höchstvergütungsbetrag: ',
    [0,0,1] => :price,
    [0,0,2] => :qty_unit,
  }
	CSS_CLASS = 'composite'
  CSS_MAP = {
    [0,0] => 'subheading',
  }
end

class SearchedList < HtmlGrid::List
	CSS_CLASS = 'composite'
  SUBHEADER = ODDB::View::Migel::SubHeader
  def init
    @components = {
      [0,0]		=>	:pharmacode,
      [1,0]		=>	:ean_code,
      [2,0]		=>	:article_name,
      [3,0]		=>	:size,
      [4,0]		=>	:status,
      [5,0]		=>	:companyname,
      [6,0]		=>	:ppha,
      [7,0]		=>	:ppub,
      [8,0]		=>	:factor,
    }
    @css_map = {
      [0,0]   => 'list',
      [1,0]   => 'list',
      [2,0]   => 'list bold',
      [3,0]   => 'list italic',
      [4,0]   => 'list',
      [5,0]   => 'list',
      [6,0]   => 'list',
      [7,0]   => 'list',
      [8,0]   => 'list',
    }
    super
  end
  def compose_list(model = @model, offset=[0,0])
    unless model.empty? 
      item = model.at(0)
      subheader = SubHeader.new(item, @session, self)
      @grid.add(subheader, *offset)
      @grid.set_colspan(offset.at(0), offset.at(1), full_colspan)
      offset = resolve_offset(offset, self::class::OFFSET_STEP)
    end
    super(model, offset)
  end
end
class SearchedComposite < HtmlGrid::Composite
  COMPONENTS = {
    [0,0] => SearchedList,
  }
	CSS_CLASS = 'composite'
end
class Items < View::PrivateTemplate
  CONTENT = SearchedComposite
  SNAPBACK_EVENT = :result
end
    end
  end
end
