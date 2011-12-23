#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::PriceHistory -- oddb.org -- 23.11.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Drugs::PriceHistory -- oddb.org -- 24.11.2008 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/drugs/price_history'

module ODDB
  module State
    module Drugs
class PriceHistory < State::Drugs::Global
  VIEW = View::Drugs::PriceHistory
  class PriceChange
    attr_reader :valid_from
    attr_accessor :exfactory, :public, :percent_exfactory, :percent_public
    def initialize date
      @valid_from = date
    end
  end
  class PriceChanges < Array
    attr_accessor :package, :pointer_descr
  end
  def init
    @model = PriceChanges.new
    reg  = @session.user_input(:reg)
    seq  = @session.user_input(:seq)
    pac  = @session.user_input(:pack)
    pack = if (reg = @session.app.registration(reg) and seq = reg.sequence(seq))
             seq.package(pac)
           end
    if pack
      @model.package = pack
      dates = {}
      pack.prices.each do |key, prices|
        previous = nil
        prices.sort_by do |price| price.valid_from end.each do |price|
          date = price.valid_from
          change = (dates[date] ||= PriceChange.new(date))
          change.send("#{key}=", price)
          if price.credits && previous && (pprice = previous.send(key)) \
            && pprice.credits
            change.send "percent_#{key}=", (price - pprice) / pprice * 100
          end
          previous = change
        end
      end
      @model.concat dates.values
    end
  end
end
    end
  end
end
