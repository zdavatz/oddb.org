#!/usr/bin/env ruby
# encoding: utf-8
# State::Drugs::Package -- oddb -- 15.02.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/drugs/package'
require 'state/admin/package'

module ODDB
  module State
    module Drugs
class Package < State::Drugs::Global
  VIEW = View::Drugs::Package
  LIMITED = true
  def augment_self
    if klass = resolve_state(@model.pointer)
      klass.new(@session, @model)
    else
      self
    end
  end
end
    end
  end
end
