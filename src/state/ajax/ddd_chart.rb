#!/usr/bin/env ruby
# State::Drugs::DDDChart -- oddb.org -- 17.04.2009 -- hwyss@ywesee.com

require 'state/ajax/global'
require 'view/ajax/ddd_chart'

module ODDB
  module State
    module Ajax
class DDDChart < Global
	VIEW = View::Ajax::DDDChart
  def init
    super
    img_name = @session.user_input(:for)
    match = /^(\d{5})(\d{3})/.match img_name
    original = @session.registration(match[1]).package(match[2])
    packages = original.sequence.public_packages
    original.sequence.comparables.each do |seq|
      packages.concat seq.public_packages
    end
    @model = packages.select do |pac| pac.ddd_price end.sort_by do |pac|
      [ pac.name_base, pac.size ]
    end
  end
end
    end
  end
end
