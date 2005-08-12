#!/usr/bin/env ruby
# View::Admin::InvalidUser -- oddb -- 02.08.2005 -- hwyss@ywesee.com

require 'view/publictemplate'
require 'view/user/limit'

module ODDB
	module View
		module User
class InvalidUserComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	=>	'invalid_user_welcome',
		[0,1]	=>	:invalid_user_explain,
		#[0,1,1] => :renew_poweruser,
		[0,2]	=>	LimitForm,
	}
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,1]	=>	'list',
	}
	LEGACY_INTERFACE = false
	def invalid_user_explain(model)
		lkey = 'query_limit_poweruser_'
		user = @session.user
		name = ''
		salutation = ''
		if(user.is_a?(PowerUser) && (inv = user.invoices.last))
			lkey += inv.max_duration.to_s
			pointer = inv.user_pointer
			dluser = pointer.resolve(@session)
			name = dluser.name
			salutation = @lookandfeel.lookup(dluser.salutation)
		end
		usertype = @lookandfeel.lookup(lkey)
		@lookandfeel.lookup(:invalid_user_explain, 
			salutation, name, usertype)
	end
	def renew_poweruser(model)
		link = HtmlGrid::Link.new(:renew_poweruser, model, @session, self)
		args = {
			:pointer	=>	@session.user.pointer,
		}
		link.href = @lookandfeel._event_url(:renew_poweruser, args)
		link
	end
end
class InvalidUser < PublicTemplate
	CONTENT = InvalidUserComposite
end
		end
	end
end
