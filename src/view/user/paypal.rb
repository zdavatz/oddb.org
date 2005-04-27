#!/usr/bin/env ruby
# View::User::PayPal -- ODDB -- 21.04.2005 -- hwyss@ywesee.com

require 'view/publictemplate'

module ODDB
	module View
		module User
class PayPalDownloads < HtmlGrid::List
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
				? time.strftime(@lookandfeel.time_format) \
				: @lookandfeel.lookup(:paypal_e_invalid)
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
class PayPalComposite < HtmlGrid::Composite
	COMPONENTS = { }
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
				components.update({
					[0,0]	=>	'paypal_success',
					[0,1]	=>	'paypal_msg_success',
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
		PayPalDownloads.new(model.items, @session, self)
	end
end
class PayPal < PublicTemplate
	CONTENT = PayPalComposite
end
		end
	end
end
