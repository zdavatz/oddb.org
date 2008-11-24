#!/usr/bin/env ruby
# State::Drugs::PriceHistory -- oddb.org -- 24.11.2008 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/drugs/price_history'

module ODDB
  module State
    module Drugs
class PriceHistory < State::Drugs::Global
  VIEW = View::Drugs::PriceHistory
  class PriceChange
    attr_reader :valid_from
    attr_accessor :exfactory, :public
    def initialize date
      @valid_from = date
    end
  end
  class PriceChanges < Array
    attr_accessor :package, :pointer_descr
  end
  def init
    @model = PriceChanges.new
    if pack = (pointer = @session.user_input(:pointer)) \
      && pointer.resolve(@session.app)
      @model.package = pack
      dates = {}
      pack.prices.each do |key, prices|
        prices.each do |price|
          date = price.valid_from
          (dates[date] ||= PriceChange.new(date)).send("#{key}=", price)
        end
      end
      @model.concat dates.values
    end
  end
end
    end
  end
end
