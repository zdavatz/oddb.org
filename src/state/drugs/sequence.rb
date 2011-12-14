#!/usr/bin/env ruby
# encoding: utf-8
# State::Drugs::Sequence -- oddb.org -- 28.02.2008 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/admin/sequence'

module ODDB
  module State
    module Drugs
class Sequence < Global
  VIEW = View::Admin::Sequence
  LIMITED = true
end
    end
  end
end
