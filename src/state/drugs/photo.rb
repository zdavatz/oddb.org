#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::Photo -- oddb.org -- 25.07.2012 -- yasaka@ywesee.com

require 'state/drugs/global'
require 'view/drugs/photo'

module ODDB
	module State
		module Drugs
class Photo < State::Drugs::Global
	VIEW = View::Drugs::Photo # package
end
    end
  end
end
