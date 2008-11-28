#!/usr/bin/env ruby
# Util::Money -- oddb.org -- 14.11.2006 -- hwyss@ywesee.com

module ODDB
  module Util
class Money
  attr_reader :credits
  attr_accessor :type, :country, :origin, :valid_from, :mutation_code, :authority
  include Comparable
  def initialize(amount, type=nil, country=nil)
    self.amount = amount
    @type, @country = type.to_s.downcase, country.to_s.upcase
    @valid_from = Time.now
  end
  def amount=(amount)
    @amount = amount.to_f
    @credits = (@amount * 100).round
  end
  def is_for?(type, country)
    @type == type.to_s.downcase && @country == country.to_s.upcase
  end
  def to_f
    @amount || (@credits.to_f / 100)
  end
  alias :amount :to_f
  def to_i
    @credits.to_i
  end
  def to_s
    sprintf("%1.2f", to_f)
  end
  def +(other)
    Money.new((@amount || to_f) + other.to_f)
  end
  def -(other)
    Money.new((@amount || to_f) - other.to_f)
  end
  def *(other)
    Money.new((@amount || to_f) * other.to_f)
  end
  def /(other)
    Money.new((@amount || to_f) / other.to_f)
  end
  def <=>(other)
    case other
    when Money
      @credits <=> other.credits
    else
      to_f <=> other.to_f
    end
  end
end
  end
end
