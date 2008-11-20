#!/usr/bin/env ruby
# State::Admin::IncompleteRegs -- oddb -- 19.06.2003 -- hwyss@ywesee.com 

require 'state/admin/global'
require 'view/admin/incompleteregistrations'

module ODDB
	module State
		module Admin
class IncompleteRegs < State::Admin::Global
	ARCHIVE_PATH = File.expand_path('../../data', File.dirname(__FILE__))
	DIRECT_EVENT = :incomplete_registrations
	VIEW = View::Admin::IncompleteRegistrations
	def release
		@session.app.async {
			updater = Updater.new(@session.app)
			updater.update_minifis
			updater.update_trade_status
			updater.update_medwin_packages
			updater.reconsider_bsv
			updater.update_comarketing
			updater.update_swissreg_news
			exporter = Exporter.new(@session.app)
			exporter.export_generics_xls
      exporter.export_patents_xls
      exporter.mail_swissmedic_notifications
		}
		State::Admin::Confirm.new(@session, :release_confirm)
	end
end
		end
	end
end
