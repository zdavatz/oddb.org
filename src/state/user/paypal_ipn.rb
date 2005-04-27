#!/usr/bin/env ruby
# State::PayPalIpn -- ODDB -- 19.04.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'net/https'
require 'util/http'
require 'view/user/paypal_ipn'

module ODDB
	module State
		module User
class PayPalIpn < Global
	RECIPIENTS = [ 'hwyss@ywesee.com', ]
	VIEW = View::User::PayPalIpn
	VOLATILE = true
	def init
		validation_keys = [:payment_status, :receiver_email, 
			:invoice, :txn_id]
		input = user_input(validation_keys)
		if((invoice = @session.invoice(input[:invoice].to_i)) \
			&& input[:payment_status] == 'Completed' \
			&& input[:receiver_email] == PAYPAL_RECEIVER)
			session = HttpSession.new(PAYPAL_SERVER, 443)
			session.use_ssl = true
			#https.ca_file = '/usr/share/ssl/cert.pem'
			#https.verify_mode = OpenSSL::SSL::VERIFY_PEER
			#https.verify_depth = 5
			data = @session.unsafe_input.collect { |key, val| 
				[key.to_s, val.to_s]
			}
			data.push(['cmd', '_notify-validate'])
			response = session.post('/cgi-bin/webscr', data)
			status = response.body
			if(status == 'VERIFIED')
				invoice.payment_received!
				invoice.odba_store
				send_notification(invoice)
				send_seller_notification(invoice)
			end
		end
	end
	def send_notification(invoice)
		if((pointer = invoice.user_pointer) \
			&& user = @session.resolve(pointer))
			lookandfeel = @session.lookandfeel
			recipient = user.email
			outgoing = TMail::Mail.new
			outgoing.set_content_type('text', 'plain', 'charset'=>'ISO-8859-1')
			outgoing.to = [recipient]
			outgoing.from = MAIL_FROM
			outgoing.subject = lookandfeel.lookup(:download_mail_subject)
			urls = invoice.items.values.collect { |item|
				data = {
					:email			=>	recipient,
					:invoice		=>	invoice.oid,
					:filename		=>	item.text,
				}
				lookandfeel._event_url(:download, data)
			}
			salut = lookandfeel.lookup(user.salutation)
			body = lookandfeel.lookup(:download_mail_body, 
				salut, user.name, urls.join("\n"))
			body << "\n\n" << format_invoice(invoice, lookandfeel)
			outgoing.body = body
			outgoing.date = Time.now
			outgoing['User-Agent'] = 'ODDB Download'
			recipients = [recipient] + RECIPIENTS
			Net::SMTP.start(SMTP_SERVER) { |smtp|
				smtp.sendmail(outgoing.encoded, SMTP_FROM, recipients)
			}
		end
	rescue Exception => e
		puts e.class
		puts e.message
		puts e.backtrace
	end
	def send_seller_notification(invoice)
		if((pointer = invoice.user_pointer) \
			&& user = @session.resolve(pointer))
			lookandfeel = @session.lookandfeel
			recipient = PAYPAL_RECEIVER
			outgoing = TMail::Mail.new
			outgoing.set_content_type('text', 'plain', 'charset'=>'ISO-8859-1')
			outgoing.to = [recipient]
			outgoing.from = MAIL_FROM
			outgoing.subject = lookandfeel.lookup(:download_mail_subject)
			salut = lookandfeel.lookup(user.salutation)
			company = user.company_name
			business = lookandfeel.lookup(user.business_area)
			if(!company.to_s.strip.empty?)
				business = "#{company} (#{business})"
			end
			body = [
				[salut, user.name_first, user.name].join(' '),
				business,
				user.address,
				[user.plz, user.location].join(' '),
				user.phone,
				user.email,
			].compact
			body.push(nil)
			body.push(format_invoice(invoice, lookandfeel))
			outgoing.body = body.join("\n")
			outgoing.date = Time.now
			outgoing['User-Agent'] = 'ODDB Download'
			recipients = [recipient] + RECIPIENTS
			Net::SMTP.start(SMTP_SERVER) { |smtp|
				smtp.sendmail(outgoing.encoded, SMTP_FROM, recipients)
			}
		end
	rescue Exception => e
		puts e.class
		puts e.message
		puts e.backtrace
	end
	def format_invoice(invoice, lookandfeel)
		downloads = invoice.items.values.collect { |item|
			[sprintf('%i x', item.quantity), item.text, item.total_netto]
		}
		downloads += [
			[nil, lookandfeel.lookup(:total_netto), invoice.total_netto],
			[nil, lookandfeel.lookup(:vat), invoice.vat],
			[nil, lookandfeel.lookup(:total_brutto), invoice.total_brutto],
		]
		invoice = downloads.collect { |data|
			sprintf("%5s %-20s EUR %8.2f", *data)
		}
		invoice += [nil, lookandfeel.lookup(:invoice_origin)]
		invoice.join("\n")
	end
end
		end
	end
end
