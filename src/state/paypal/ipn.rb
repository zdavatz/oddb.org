#!/usr/bin/env ruby
# State::PayPal::Ipn -- ODDB -- 19.04.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'net/https'
require 'util/http'
require 'plugin/ydim'
require 'view/paypal/ipn'

module ODDB
	module State
		module PayPal
class Ipn < State::Global
	RECIPIENTS = [ 'hwyss@ywesee.com', ]
	VIEW = View::PayPal::Ipn
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
			tries = 3
			begin
				response = session.post('/cgi-bin/webscr', data)
				status = response.body
				if(status == 'VERIFIED')
					invoice.payment_received!
          yus_name = invoice.yus_name
          invoice.items.each_value { |item|
            case item.type
            when :poweruser
              @session.yus_set_preference(yus_name, 'poweruser_duration',
                                         invoice.max_duration)
              @session.yus_grant(yus_name, 'login', 'org.oddb.PowerUser')
              @session.yus_grant(yus_name, 'view', 'org.oddb', item.expiry_time)
            when :download
              @session.yus_grant(yus_name, 'download', item.text, 
                                 item.expiry_time)
            end
          }
					YdimPlugin.new(@session.app).inject(invoice)
					invoice.types.each { |type|
						case type
						when :poweruser
							send_poweruser_notification(invoice)
						else
							send_download_notification(invoice)
							send_download_seller_notification(invoice)
						end
					}
				end
			rescue RuntimeError => error
				if(tries > 0)
					tries -= 1
					sleep(3-tries)
					retry
				else
					send_notification(invoice) { |outgoing, recipient, lookandfeel|
						outgoing.subject = error.message
						parts = [ 
							lookandfeel.lookup(:paypal_msg_error),
							error.class,
							error.message,
							error.backtrace.join("\n"),
						]
						outgoing.body = parts.join("\n\n")
					}
				end
			end
		end
	end
	def send_download_notification(invoice)
		send_notification(invoice) { |outgoing, recipient, lookandfeel|
			outgoing.subject = lookandfeel.lookup(:download_mail_subject)
			urls = invoice.items.values.collect { |item|
				data = {
					:email			=>	recipient,
					:invoice		=>	invoice.oid,
					:filename		=>	item.text,
				}
				lookandfeel._event_url(:download, data)
			}
			salut = lookandfeel.lookup(yus(recipient, :salutation))
			suffix = (urls.size == 1) ? 's' : 'p'
			lines = [
				lookandfeel.lookup(:download_mail_body),
				lookandfeel.lookup("download_mail_instr_#{suffix}"),
			]
			parts = [
				lookandfeel.lookup(:download_mail_salut, salut, 
                           yus(recipient, :name_last)),
				lines.join("\n"),
				urls.join("\n"), 
				lookandfeel.lookup(:download_mail_feedback),
				format_invoice(invoice, lookandfeel),
			]
			outgoing.body = parts.join("\n\n")
		}
	end
	def send_download_seller_notification(invoice)
		if(name = invoice.yus_name)
			lookandfeel = @session.lookandfeel
			recipient = PAYPAL_RECEIVER
			outgoing = TMail::Mail.new
			outgoing.set_content_type('text', 'plain', 'charset'=>'ISO-8859-1')
			outgoing.to = [recipient]
			outgoing.from = MAIL_FROM
			outgoing.subject = lookandfeel.lookup(:download_mail_subject)
			salut = lookandfeel.lookup(yus(name, :salutation))
			company = yus(name, :company_name)
			business = lookandfeel.lookup(yus(name, :business_area))
			if(!company.to_s.strip.empty?)
				business = "#{company} (#{business})"
			end
			body = [
				[salut, yus(name, :name_first), yus(name, :name_last)].join(' '),
				business,
				yus(name, :address),
				[yus(name, :plz), yus(name, :location)].join(' '),
				yus(name, :phone),
				yus(name, :email),
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
	def send_poweruser_notification(invoice)
		send_notification(invoice) { |outgoing, recipient, lookandfeel|
			outgoing.subject = lookandfeel.lookup(:poweruser_mail_subject)
			salut = lookandfeel.lookup(yus(recipient, :salutation))
			item = invoice.item_by_text('unlimited access')
			dkey = "poweruser_duration_#{item.duration.to_i}"
			duration = lookandfeel.lookup(dkey)
			parts = [
				lookandfeel.lookup(:poweruser_mail_salut, salut, 
                           yus(recipient, :name_last)),
				lookandfeel.lookup(:poweruser_mail_body),
				lookandfeel.lookup(:poweruser_mail_instr, duration,
					lookandfeel._event_url(:login_form)),
				lookandfeel.lookup(:poweruser_regulatory),
			]
			outgoing.body = parts.join("\n\n")
		}
	end
	def send_notification(invoice, &block)
		if(recipient = invoice.yus_name)
			lookandfeel = @session.lookandfeel
			outgoing = TMail::Mail.new
			outgoing.set_content_type('text', 'plain', 'charset'=>'ISO-8859-1')
			outgoing.to = [recipient]
			outgoing.from = MAIL_FROM
			outgoing.date = Time.now
			outgoing['User-Agent'] = 'ODDB Paypal-IPN'

			block.call(outgoing, recipient, lookandfeel) 

			recipients = ([recipient] + RECIPIENTS).uniq
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
		lines = [lookandfeel.lookup(:invoice_origin), nil]
		qsizes = []
		tsizes = []
		nsizes = []
		downloads = invoice.items.values.collect { |item|
			qstr = sprintf('%i x', item.quantity)
			qsizes.push(qstr.size)
			tstr = item.text
			tsizes.push(tstr.size)
			nstr = sprintf('%3.2f', item.total_netto)
			nsizes.push(nstr.size)
			[qstr, tstr, nstr]
		}
		tstr = lookandfeel.lookup(:total_netto)
		tsizes.push(tstr.size)
		nstr = sprintf('%3.2f', invoice.total_netto)
		nsizes.push(nstr.size)
		netto_line = [nil, tstr, nstr]
		tstr = lookandfeel.lookup(:vat)
		tsizes.push(tstr.size)
		nstr = sprintf('%3.2f', invoice.vat)
		nsizes.push(nstr.size)
		vat_line = [nil, tstr, nstr]
		tstr = lookandfeel.lookup(:total_brutto)
		tsizes.push(tstr.size)
		nstr = sprintf('%3.2f', invoice.total_brutto)
		nsizes.push(nstr.size)
		brutto_line = [nil, tstr, nstr]

		sizes = [qsizes.max, tsizes.max, nsizes.max]

		width = sizes.inject(7) { |a,b| a + b }
		
		dline = "=" * width
		sline = "-" * width

		lines.push(dline)
		lines += downloads.collect { |data|
			format_line(sizes, data)
		}
		lines.push(sline)
		lines.push(format_line(sizes, netto_line))
		lines.push(sline)
		lines.push(format_line(sizes, vat_line))
		lines.push(dline)
		lines.push(format_line(sizes, brutto_line))
		lines.push(dline)
		lines.push(nil)
		lines.join("\n")
	end
	def format_line(sizes, data)
		sprintf("%#{sizes.at(0)}s %-#{sizes.at(1)}s  EUR %#{sizes.at(2)}s",
			*data)
	end
  def yus(recipient, key)
    @session.yus_get_preference(recipient, key)
  end
end
		end
	end
end
