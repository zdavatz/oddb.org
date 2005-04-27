#!/usr/bin/env ruby
# State::User::RegisterDownload -- oddb -- 22.12.2004 -- hwyss@ywesee.com

require 'state/user/global'
require 'state/user/paypal_redirect'
require 'state/user/download_export' ## ??
require 'admin/download_user'
require 'view/user/register_download'

module ODDB
	module State
		module User
class RegisterDownload < Global
	VIEW = View::User::RegisterDownload
	def checkout
		mandatory = [ :salutation, :name, :name_first, :address, :plz,
			:location, :phone, :email ]
		keys = mandatory + [:business_area, :company_name]
		input = user_input(keys, mandatory)
		if(error?)
			self
		else
			email = input.delete(:email)
			@session.set_cookie_input(:email, email)
			ODBA.transaction { 
				pointer = Persistence::Pointer.new([:admin_subsystem], 
					[:download_user, email])
				user = @session.app.update(pointer.creator, input)
				pointer = Persistence::Pointer.new([:invoice])
				invoice = @session.app.create(pointer)
				@model.downloads.each { |abstract|
					item_ptr = pointer + [:item]
					time = Time.now
					file = abstract.text
					duration = abstract.duration
					expiry = DownloadExport.expiry_time(duration, time)
					data = {
						:duration			=> duration,
						:expiry_time	=> expiry,
						:price				=> abstract.price,
						:quantity			=> abstract.quantity,
						:text					=> file,
						:time					=> time,
						:vat_rate			=> VAT_RATE,
					}
					item = @session.app.update(item_ptr.creator, data)
				}
				user.add_invoice(invoice)
				State::User::PayPalRedirect.new(@session, invoice)
			}
		end
	end
end
		end
	end
end
