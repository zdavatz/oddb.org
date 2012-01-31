#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::DDDChart -- oddb.org -- 31.01.2012 -- mhatakeyama@ywesee.com
# ODDB::State::Drugs::DDDChart -- oddb.org -- 17.04.2009 -- hwyss@ywesee.com

require 'state/ajax/global'
require 'view/ajax/ddd_chart'

module ODDB
  module State
    module Ajax
class DDDChart < Global
	VIEW = View::Ajax::DDDChart
  def init
    super
    packages = []
    img_name = @session.user_input(:for)
    if match = /^(\d{5})(\d{3})/.match(img_name) and original = @session.registration(match[1]).package(match[2])
      packages.concat original.generic_group_comparables
      packages.concat original.sequence.public_packages
      [0.5, 2, 1].each do |factor|
        original.sequence.comparables(factor).each do |seq|
          packages.concat seq.public_packages
        end
      end
    end
    packages.uniq!
    @model = packages.select do |pac| pac.ddd_price end.sort_by do |pac|
      [ pac.name_base, pac.size ]
    end
  end
end
    end
  end
end
