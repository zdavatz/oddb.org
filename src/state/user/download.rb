#!/usr/bin/env ruby
# State::User::Download -- ODDB -- 29.10.2003 -- hwyss@ywesee.com

require 'state/user/global'
require 'view/user/download'
require 'view/user/register_download'

module ODDB
	module State
		module User
class Download < State::User::Global
	VOLATILE = true
	def init
		check_or_set_cookie
		super
	end
	def check_or_set_cookie
		if((email = @session.cookie_input_by_key(:email)) && !email.empty?)
			@default_view = View::User::Download
		elsif((email = @session.user_input(:email)) && !email.empty?)
			@session.set_cookie_input(:email, email)
			@default_view = View::User::Download
		else
			@default_view = View::User::RegisterDownload
		end
	end
	def download
		check_or_set_cookie
	end
end
		end
	end
end
