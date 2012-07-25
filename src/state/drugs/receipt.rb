#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::Receipt  -- oddb.org -- 25.07.2012 -- yasaka@ywesee.com

require 'state/drugs/global'
require 'view/drugs/receipt'

module ODDB
  module State
    module Drugs
class Receipt < State::Drugs::Global
  DIRECT_EVENT = :receipt
  VIEW = View::Drugs::Receipt
end
class ReceiptPrint < State::Drugs::Global
	VIEW = View::Drugs::ReceiptPrint
	VOLATILE = true
end
    end
  end
end

