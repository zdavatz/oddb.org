#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::Patent -- oddb.org -- 11.06.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Admin::Patent -- oddb.org -- 05.05.2006 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/admin/patent'
require 'plugin/swissreg'

module ODDB
	module State
		module Admin
class Patent < Global
	VIEW = View::Admin::Patent
	def update
    keys = [ :base_patent, :base_patent_date, :certificate_number,
      :expiry_date, :deletion_date, :iksnr, :issue_date,
      :protection_date, :publication_date, :registration_date ]
		input = user_input(keys)
		unless(error?)
			detail = {}

			# Swissreg has updated, and this code that fetch data via scraping doesn't work anymore
			# https://github.com/zdavatz/oddb.org/issues/282
			#
			# if(cn = input[:certificate_number])
			# 	url = @session.lookandfeel.lookup(:swissreg_url, cn)
			# 	plug = SwissregPlugin.new(@session.app)
			# 	plug.get_detail(url).each { |key, val|
			# 		if(input[key].nil? || input[key] == '')
			# 			input.store(key, val)
			# 		end
			# 	}
			# end
			@model = @session.app.update(@model.pointer, input, unique_email)
		end
		self
	end
end
class CompanyPatent < Patent
	def init
		@registration = @model.parent(@session)
		unless(allowed?(@registration))
			@default_view = ODDB::View::Admin::ReadonlyPatent
		end
	end
	def update
		if(allowed?(@registration))
			super
		end
	end
end
		end
	end
end
