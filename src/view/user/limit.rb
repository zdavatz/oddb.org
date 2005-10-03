#!/usr/bin/env ruby
# View::User::Limit -- oddb -- 26.07.2005 -- hwyss@ywesee.com

require 'view/resulttemplate'
require 'view/admin/loginform'
require 'view/drugs/result'
require 'view/additional_information'
require 'view/dataformat'

module ODDB
	module View
		module User
class LimitForm < View::Form
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,0]	=>	:query_limit_poweruser_365,
		[1,0]	=>	:query_limit_poweruser_a,
		[0,1]	=>	:query_limit_poweruser_30,
		[1,1]	=>	:query_limit_poweruser_b,
		[0,2]	=>	:query_limit_poweruser_1,
		[1,2]	=>	:query_limit_poweruser_c,
		[1,3]	=>  :submit,
	}
	CSS_MAP = {
		[0,0,2,4]	=>	'list',
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
			@session.state.class.price(365))
	end
	def query_limit_poweruser_b(model)
		price = @session.state.class.price(30)
		@lookandfeel.lookup(:query_limit_poweruser_b,
			@session.class.const_get(:QUERY_LIMIT),
			@lookandfeel.format_price(price * 100, 'EUR'))
	end
	def query_limit_poweruser_c(model)
		query_limit_poweruser_txt(:query_limit_poweruser_c,
			@session.state.class.price(1))
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
		[0,0]	=> :query_limit,
		[0,1]	=> 'query_limit_welcome',
		[0,2]	=> 'query_limit_new_user',
		[0,3]	=> :query_limit_explain,
		[0,4]	=> :query_limit_more_info,
		[0,5,0]	=> 'ol_open',
		[0,5,1]	=> 'li_open',
		[0,5,2]		=> 'query_limit_download',
		[0,5,3]	=> :query_limit_download,
		[0,5,4]	=> 'li_close',
		[0,5,5]	=> 'li_open',
		[0,5,6]	=>	'query_limit_poweruser',
		[0,5,7]	=>	'li_close',
		[0,5,8]	=>	'ol_close',
		[0,6]	=> LimitForm,
		[0,8]	=>	'query_limit_login',
		[0,9]	=> View::Admin::LoginForm,
		[0,11]	=>	'query_limit_thanks0',
		[0,12]	=>	'query_limit_thanks1',
		[0,12,1]	=>	:query_limit_email,
		[0,12,2]	=>	'query_limit_thanks2',
	}
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,1]	=>	'list',
		[0,2]	=>	'subheading bold',
		[0,3,1,3]	=>	'list',
		[0,8]	=>	'subheading bold',
		[0,11]	=>	'subheading bold',
		[0,12]	=>	'list',
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
class ResultLimitList < HtmlGrid::List
	include DataFormat
	include View::AdditionalInformation
	COMPONENTS = {
		[0,0]	=>  :fachinfo,
		[1,0]	=>	:patinfo,
		[2,0]	=>	:name_base,
		[3,0]	=>	:galenic_form,
		[4,0]	=>	:most_precise_dose,
		[5,0]	=>	:size,
		[6,0]	=>	:price_exfactory,
		[7,0]	=>	:price_public,
		[8,0]	=>	:ikscat,
	}
	DEFAULT_CLASS = HtmlGrid::Value
	CSS_CLASS = 'composite'
	SORT_HEADER = false
	CSS_MAP = {
		[0,0,2]	=>	'list',
		[2,0] => 'list-big',
		[3,0] => 'list',
		[4,0,5] => 'list-r',
	}
	CSS_HEAD_MAP = {
		[4,0,5] => 'th-r',
	}
	def compose_empty_list(offset)
		count = @session.state.package_count.to_i
		if(count > 0)
			@grid.add(@lookandfeel.lookup(:query_limit_empty, 
				@session.state.package_count, 
				@session.class.const_get(:QUERY_LIMIT)), *offset)
			@grid.add_attribute('class', 'list', *offset)
			@grid.set_colspan(*offset)
		else
			super
		end
	end
	def name_base(model, session)
		model.name_base
	end
end
class ResultLimitComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=> :export_csv,
		[0,1]	=> SearchForm,
		[0,2] => ResultLimitList, 
		[0,3]	=> LimitComposite,
	}
	LEGACY_INTERFACE = false
	def export_csv(model)
		if(@session.state.package_count.to_i > 0)
			View::Drugs::ExportCSV.new(model, @session, self)
		end
	end
end
class ResultLimit < ResultTemplate
	CONTENT = ResultLimitComposite
end
		end
	end
end
