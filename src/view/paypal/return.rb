#!/usr/bin/env ruby
# View::PayPal::Return -- ODDB -- 21.04.2005 -- hwyss@ywesee.com

require 'view/resulttemplate'
require 'view/datadeclaration'

module ODDB
	module View
		module PayPal
class ReturnDownloads < HtmlGrid::List
	COMPONENTS = {
		[0,0]	=>	:download_link	
	}
	CSS_MAP = {
		[0,0]	=>	'list',
	}
	LEGACY_INTERFACE = false
	OMIT_HEADER = true
	STRIPED_BG = false
	def download_link(model)
		if(model.expired?)
			time = model.expiry_time
			timestr = (time) \
				? time.strftime(@lookandfeel.lookup(:time_format_long)) \
				: @lookandfeel.lookup(:paypal_e_invalid_time)
			@lookandfeel.lookup(:paypal_e_expired, model.text, timestr)
		else
			data = {
				:email			=>	model.email,
				:invoice		=>	model.oid,
				:filename		=>	model.text,
			}
			link = HtmlGrid::Link.new(:download, model, @session, self)
			link.href = @lookandfeel._event_url(:download, data)
			link.value = model.text
			link
		end
	end
end
class ReturnComposite < HtmlGrid::Composite
	include View::DataDeclaration
	## in this class, COMPONENTS only includes the unchanging components
	COMPONENTS = {
		[0,0,0]	=>	'dash_separator',
		[0,0,1]	=>	:data_declaration,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,1]	=>	'list',
	}
	LEGACY_INTERFACE = false
	def init
		if(@model.nil?)
			components.update({
				[0,0]	=>	'paypal_unconfirmed',
				[0,1]	=>	'paypal_e_missing_invoice',
				[0,2]	=>	:back,
			})
			css_map.store([0,1], 'error')
		else
			if(@model.payment_received?)
				suffix = @model.items.size == 1 ? 's' : 'p'
				components.update({
					[0,0]	=>	'paypal_success',
					[0,1]	=>	"paypal_msg_success_#{suffix}",
					[0,2]	=>	:download_links,
					[0,3]	=>	:back,
				})
				css_map.store([0,2], 'list')
			else
				components.update({
					[0,0]	=>	'paypal_unconfirmed',
					[0,1]	=>	'paypal_msg_unconfirmed',
					[0,2]	=>	:back,
				})
			end
		end
		super
	end
	def back(model)
		button = super
		button.value = @lookandfeel.lookup(:back_to_download)
		button
	end
	def download_links(model)
		ReturnDownloads.new(model.items, @session, self)
	end
end
class Return < PublicTemplate
	CONTENT = ReturnComposite
	def http_headers
		headers = super
		unless(@model && @model.payment_received?)
			args = { :invoice => @model.oid }
			## use event_url as opposed to _event_url in order to include
			## the state-id, so we stay in the same state instead of
			## creating a new one with each refresh
			url = @lookandfeel.event_url(:paypal_return, args)
			headers.store('Refresh', "10; URL=#{url}")
		end
		headers
	end
end
		end
	end
end
