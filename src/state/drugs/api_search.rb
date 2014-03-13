#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::ApiSearch -- oddb.org -- 12.04.2012 -- yasaka@ywesee.com
require 'view/api/json'

module ODDB
  module State
    module Drugs
class ApiSearch < State::Drugs::Global
  VIEW = View::Api::Json
  def init
    @model = []
    if ean = @session.user_input(:ean)
      if ean.to_s.match(/^7680/)
        package = @session.app.package_by_ikskey(ean.to_s[4,8])
      else
        package = @session.app.package_by_ean13(ean13)
      end
      if package.is_a?(ODDB::Package)
        @model = {
          'reg'    => package.iksnr,
          'seq'    => package.seqnr,
          'pack'   => package.ikscd,
          'name'   => package.name_base,
          'size'   => package.size,
          'price'  => package.price_public,
          'category'  => category(package),
          'deduction' => 
            @session.lookandfeel.lookup(package.deductible || :deductible_unknown)
        }
      end
    end
  end
  def category(package)
    elements = []
    if(cat = package.ikscat)
      elements.push(cat)
    end
    if(sl = package.sl_entry)
      elements.push(@session.lookandfeel.lookup(:sl))
    end
    if(lppv = package.lppv)
      catstr = @session.lookandfeel.lookup(:lppv)
      elements.push(catstr)
    end
    if(gt = package.sl_generic_type)
      elements.push(@session.lookandfeel.lookup("sl_#{gt}_short"))
    end
    elements.join('&nbsp;/&nbsp;')
  end
end
    end
  end
end
