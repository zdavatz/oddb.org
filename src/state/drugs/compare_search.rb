# encoding: utf-8
require 'state/global_predefine'
require 'view/drugs/compare_search'

module ODDB
  module State
    module Drugs
class CompareSearch < State::Drugs::Global
	VIEW = View::Drugs::CompareSearch
	DIRECT_EVENT = :compare_search
end
    end
  end
end
