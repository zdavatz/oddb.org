#!/usr/bin/env ruby
# encoding: utf-8
# State::Drugs::Registration -- oddb.org -- 28.02.2008 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/admin/registration'

module ODDB
  module State
    module Drugs
class Registration < State::Drugs::Global
  VIEW = View::Admin::Registration
  LIMITED = true
end
    end
  end
end
