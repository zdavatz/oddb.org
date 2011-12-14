#!/usr/bin/env ruby
# encoding: utf-8
# State::Admin::GalenicGroups -- oddb -- 25.03.2003 -- andy@jetnet.ch

require 'state/admin/global'
require 'state/admin/galenicgroup'
require 'view/admin/galenicgroups'

module ODDB
	module State
		module Admin
class GalenicGroups < State::Admin::Global
	DIRECT_EVENT = :galenic_groups
	VIEW = View::Admin::GalenicGroups
end
		end
	end
end
