#!/usr/bin/env ruby
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
	def release
		@session.app.async {
			updater = Updater.new(@session.app)
			updater.update_medwin_packages
			updater.reconsider_bsv
			updater.export_ouwerkerk
			exporter = Exporter.new(@session.app)
			exporter.export_generics_xls
		}
		State::Admin::Confirm.new(@session, :release_ouwerkerk_confirm)
	end
end
		end
	end
end
