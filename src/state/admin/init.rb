#!/usr/bin/env ruby
# encoding: utf-8
# State::Admin::Init -- oddb -- 22.10.2002 -- hwyss@ywesee.com 

require 'state/global_predefine'
require 'state/admin/confirm'
require 'view/admin/search'
require 'util/updater'
require 'util/exporter'

module ODDB
	module State
		module Admin
class Init < State::Admin::Global
	VIEW = View::Admin::Search
	DIRECT_EVENT = :home_admin
end
		end
	end
end
