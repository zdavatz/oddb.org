#!/usr/bin/env ruby
# State::Admin::IncompleteRegs -- oddb -- 19.06.2003 -- hwyss@ywesee.com 

require 'plugin/bsv'
require 'state/admin/global'
require 'view/admin/incompleteregistrations'

module ODDB
	module State
		module Admin
class IncompleteRegs < State::Admin::Global
	ARCHIVE_PATH = File.expand_path('../../data', File.dirname(__FILE__))
	DIRECT_EVENT = :incomplete_registrations
	VIEW = View::Admin::IncompleteRegistrations
=begin
	def update_bsv
		url = @session.user_input(:bsv_url)
		if(url.empty?)
			err = create_error(:e_missing_url, :bsv_url, url)
			@errors.store(:bsv_url, err)
		elsif(parts = url_parts(url))
			server, path, filename = parts
			success = begin
				http = Net::HTTP.new(server)
				resp = http.head(path)
				if(resp.is_a? Net::HTTPOK)
					@session.app.async {
						updater = Updater.new(@session.app)
						updater.update_bsv_from_url(server, path, filename)
					}
				end
			rescue SocketError
			end
			if(success)
				@infos.push(:i_bsv_in_progress)
			else
				err = create_error(:e_file_not_found, :bsv_url, url)
				@errors.store(:bsv_url, err)
			end
		else
			err = create_error(:e_invalid_url, :bsv_url, url)
			@errors.store(:bsv_url, err)
		end
		self
	end
	private 
	def url_parts(url)
		pattern = /(?:http:\/\/)?([^\/]+)((?:\/[^\/]*)*\/([^\/]+\.xls))/
		if(match = pattern.match(url))
			[match[1], match[2], match[3]]
		end
	end
=end
	def release
		@session.app.async {
			updater = Updater.new(@session.app)
			updater.update_trade_status
			updater.update_medwin_packages
			updater.reconsider_bsv
			exporter = Exporter.new(@session.app)
			exporter.export_generics_xls
		}
		State::Admin::Confirm.new(@session, :release_confirm)
	end
end
		end
	end
end
