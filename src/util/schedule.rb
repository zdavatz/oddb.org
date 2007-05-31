#!/usr/bin/env ruby
# Util::Schedule -- oddb.org -- 30.05.2007 -- hwyss@ywesee.com

module ODDB
  module Util
module Schedule
  def run_on_monthday(day, &block)
    if(today.day == day)
      block.call
    end
  end
  def run_on_weekday(day, &block)
    if(today.wday == day)
      block.call
    end
  end
end
  end
end
