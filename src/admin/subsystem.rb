#!/usr/bin/env ruby
# Admin::Subsystem -- oddb -- 21.12.2004 -- hwyss@ywesee.com

require 'admin/download_user'
require 'odba'

module ODDB
	module Admin
		class Subsystem
			include ODBA::Persistable
			def initialize
				@download_users = {}
			end
			def create_download_user(email)
				@download_users[email.to_s] = DownloadUser.new(email)
			end
			def delete_download_user(email)
				@download_users.delete(email.to_s)
			end
			def download_user(email)
				@download_users[email.to_s]
			end
		end
	end
end
