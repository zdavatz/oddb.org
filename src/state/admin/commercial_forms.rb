#!/usr/bin/env ruby
# encoding: utf-8
# State::Admin::CommercialForms -- oddb.org -- 23.11.2006 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/admin/commercial_forms'

module ODDB
  module State
    module Admin
class CommercialForms < Global
  DIRECT_EVENT = :commercial_forms
  VIEW = View::Admin::CommercialForms
end
    end
  end
end
