#!/usr/bin/env ruby
# View::Limit -- oddb -- 26.07.2005 -- hwyss@ywesee.com

require 'view/resulttemplate'
require 'view/admin/loginform'
require 'view/sponsorhead'

module ODDB
	module View
class LimitForm < View::Form
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,0]	=>	:query_limit_poweruser_365,
		[2,0]	=>	:query_limit_poweruser_a,
		[0,1]	=>	:query_limit_poweruser_30,
		[2,1]	=>	:query_limit_poweruser_b,
		[0,2]	=>	:query_limit_poweruser_1,
		[2,2]	=>	:query_limit_poweruser_c,
		[2,3]	=>  :submit,
	}
	CSS_MAP = {
		[0,0,3,4]	=>	'list top',
		[1,0,1,4]	=>	'small top',
	}
	LABELS = true
	LEGACY_INTERFACE = false
	EVENT = :proceed_poweruser
	def init
		super
		error_message
	end
	def query_limit_poweruser_a(model)
		query_limit_poweruser_txt(:query_limit_poweruser_a, 
			@session.state.price(365))
	end
	def query_limit_poweruser_b(model)
		price = @session.state.price(30)
		@lookandfeel.lookup(:query_limit_poweruser_b,
			@session.class.const_get(:QUERY_LIMIT),
			@lookandfeel.format_price(price * 100, 'EUR'))
	end
	def query_limit_poweruser_c(model)
		query_limit_poweruser_txt(:query_limit_poweruser_c,
			@session.state.price(1))
	end
	def query_limit_poweruser_txt(key, price)
		@lookandfeel.lookup(key, 
			@lookandfeel.format_price(price * 100, 'EUR'))
	end
	def query_limit_poweruser_1(model)
		query_limit_poweruser_radio(1)
	end
	def query_limit_poweruser_30(model)
		query_limit_poweruser_radio(30)
	end
	def query_limit_poweruser_365(model)
		query_limit_poweruser_radio(365)
	end
	def query_limit_poweruser_radio(value)
		radio = HtmlGrid::InputRadio.new('days', @model, @session, self)
		radio.value = value
		radio
	end
end
class LimitComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	  => :query_limit,
		[0,1]	  => 'query_limit_welcome',
		[0,2,0]	=> 'query_limit_new_user',
		[0,2,1]	=> :query_limit_more_info,
		[0,3]	  => :query_limit_explain,
		[0,4,0]	=> 'ol_open',
		[0,4,1]	=> 'li_open',
		[0,4,2]	=> 'query_limit_download',
		[0,4,3]	=> :query_limit_download,
		[0,4,4]	=> 'li_close',
		[0,4,5]	=> 'li_open',
		[0,4,6]	=> 'query_limit_poweruser',
		[0,4,7]	=> 'li_close',
		[0,4,8]	=> 'ol_close',
		[0,5]	  =>  LimitForm,
		[0,7]	  => 'query_limit_login',
		[0,8]	  =>  View::Admin::LoginForm,
		[0,10]	=> 'query_limit_thanks0',
		[0,11,0]=> 'query_limit_thanks1',
		[0,11,1]=> :query_limit_email,
		[0,11,2]=> 'query_limit_thanks2',
	}
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,1]	=>	'list',
		[0,2]	=>	'subheading bold',
		[0,3,1,2]	=>	'list',
		[0,7]	=>	'subheading bold',
		[0,10]	=>	'subheading bold',
		[0,11]	=>	'list',
	}
	CSS_CLASS = 'composite'
	LEGACY_INTERFACE = false
	def query_limit(model)
		@lookandfeel.lookup(:query_limit, 
			@session.class.const_get(:QUERY_LIMIT))
	end
	def query_limit_download(model)
		link = HtmlGrid::Link.new(:query_limit_download, 
			model, @session, self)
		link.value = link.href = @lookandfeel._event_url(:download_export)
		link
	end
	def query_limit_email(model)
		link = HtmlGrid::Link.new(:ywesee_contact_email, 
			model, @session, self)
		link.href = @lookandfeel.lookup(:ywesee_contact_href)
		link
	end
	def query_limit_explain(model)
		@lookandfeel.lookup(:query_limit_explain, @session.remote_ip,
			@session.class.const_get(:QUERY_LIMIT))
	end
	def query_limit_more_info(model)
		link = HtmlGrid::Link.new(:query_limit_more_info, 
			model, @session, self)
		link.href = "http://www.ywesee.com/pmwiki.php?n=Main.WekoBlog"
		link
	end
end
class Limit < ResultTemplate
	CONTENT = LimitComposite
end
	end
end
