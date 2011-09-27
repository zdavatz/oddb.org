#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Migel:Items -- oddb.org -- 26.09.2011 -- mhatakeyama@ywesee.com

require 'state/global_predefine'
require 'view/migel/items'
require 'util/umlautsort'

module ODDB
	module State
		module Migel

class PageFacade < ODDB::State::PageFacade
  # Overwrite sort_by method otherwise the page is sorted in htmlgrid/list.rb#sort_model method
  def sort_by
    self
  end
end

class Items < State::Migel::Global
  include ODDB::UmlautSort
	VIEW = ODDB::View::Migel::Items
  ITEM_LIMIT = 350
  #ITEM_LIMIT = 100
  attr_reader :pages
  def init
    @pages = Array.new((@model.length.to_f / ITEM_LIMIT).ceil){|i| ODDB::State::Migel::PageFacade.new(i)}
    @current_page = @session.user_input(:page) || 0
    @pages[@current_page] = ODDB::State::Migel::PageFacade.new(@current_page)
    @pages[@current_page].concat @model[@current_page*ITEM_LIMIT, ITEM_LIMIT]
    @pages[@current_page].model = @model

    @filter = Proc.new { |model|
      @pages[@current_page]
#      page()
    }
  end
  def compare_entries(a, b)
    @sortby.each { |sortby|
      if sortby == :ppub
        return a.ppub.to_f <=> b.ppub.to_f
      else
        aval, bval = nil
        begin
          aval = umlaut_filter(a.send(sortby))
          bval = umlaut_filter(b.send(sortby))
        rescue 
          next
        end
        res = if (aval.nil? && bval.nil?)
          0
        elsif (aval.nil?)
          1
        elsif (bval.nil?)
          -1
        else
          aval <=> bval
        end
        return res unless(res == 0)
      end
    }
    0
  end
  def sort
    self
  end
  def page
    @pages[@current_page]
  end
end

		end
	end
end
