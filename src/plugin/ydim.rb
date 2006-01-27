#!/usr/bin/env ruby
# YdimPlugin -- oddb -- 27.01.2006 -- hwyss@ywesee.com

require 'plugin/plugin'
require 'ydim/config'
require 'ydim/client'
require 'openssl'

module ODDB
	class YdimPlugin < Plugin
		def create_debitor(comp_or_hosp)
			ydim_connect { |client|
				debitor = client.create_debitor
				debitor.email = comp_or_hosp.invoice_email \
					|| comp_or_hosp.user.unique_email
				if((name = comp_or_hosp.fullname) && !name.empty?)
					debitor.name = name
					debitor.contact = comp_or_hosp.contact
				else
					debitor.name = comp_or_hosp.contact
				end
				debitor.address_lines = comp_or_hosp.ydim_address_lines
				debitor.location = comp_or_hosp.ydim_location.to_s
				debitor.debitor_type = case comp_or_hosp
															 when Hospital
																 'dt_hospital'
															 when Company
																 if(ba = comp_or_hosp.business_area)
																	 ba.gsub(/^ba/, 'dt')
																 else
																	 'dt_pharma'
																 end
															 end
				debitor
			}
		end
		def debitor_id(comp_or_hosp)
			if(id = comp_or_hosp.ydim_id)
				id
			elsif(debitor = identify_debitor(comp_or_hosp))
				debitor.unique_id
			else
				create_debitor(comp_or_hosp).unique_id
			end
		end
		def identify_debitor(comp_or_hosp)
			ydim_connect { |client|
				if(debitor = client.search_debitors(comp_or_hosp.fullname).first)
					comp_or_hosp.ydim_id = debitor.unique_id
					comp_or_hosp.odba_store
					debitor
				end
			}
		end
		def inject(invoice)
			if(id = invoice.ydim_id)
				ydim_connect { |client| client.invoice(id) }
			else
				user = invoice.user_pointer.resolve(@app)
				comp_or_hosp = (user.respond_to?(:model)) ? user.model : user
				items = invoice.items.values
				ydim_inv = inject_from_items(invoice_date(items), comp_or_hosp, items)
				ydim_inv.payment_received = invoice.payment_received?
				ydim_inv.odba_store
				invoice.ydim_id = ydim_inv.unique_id
				invoice.odba_store
			end
		end
		def inject_from_items(date, comp_or_hosp, items)
			ydim_connect { |client|
				ydim_inv = client.create_invoice(debitor_id(comp_or_hosp))
				ydim_inv.description = invoice_description(items)
				ydim_inv.date = date
				ydim_inv.payment_period = 10
				item_data = items.collect { |item| 
					data = item.ydim_data 
					data[:text] = item_text(item)
					data
				}
				client.add_items(ydim_inv.unique_id, item_data)
				ydim_inv
			}
		end
		def invoice_date(items)
			times = items.collect { |item| item.time }
			time = times.max
			Date.new(time.year, time.month, time.day)
		end
		def invoice_description(items)
			types = []
			times = []
			items.each { |item| 
				types.push(item.type) 
				times.push(item.time) 
			}
			time = times.min
			last = times.max
			year = time.year
			if(types.include?(:poweruser))
				sprintf("PowerUser %s - %s", time.strftime('%d.%m.%Y'),
								items.first.expiry_time.strftime('%d.%m.%Y'))
			elsif(types.include?(:csv_export))
				fmt = '%d.%m.%Y'
				timstr = time.strftime(fmt)
				expstr = last.strftime(fmt)
				if(timstr == expstr)
					timstr = time.strftime("%m/%Y")
				end
				sprintf("%i x CSV-Download %s", items.size, timestr)
			elsif(types.include?(:download))
				sprintf('%i x Download %s', items.size, 
								time.strftime('Downloads %d.%m.%Y'))
			elsif(types.include?(:index))
				sprintf("Firmenverzeichnis %i/%i", year, year.next)
			elsif(types.include?(:lookandfeel))
				sprintf("Lookandfeel-Integration %i/%i", year, year.next)
			else
				fmt = 'Patinfo-Upload %d.%m.%Y'
				timstr = time.strftime(fmt)
				expstr = last.strftime(fmt)
				count = items.select { |item| item.type == :annual_fee }.size
				if(timstr == expstr)
					sprintf("%i x %s", count, timstr)
				else
					sprintf("%i x Patinfo-Upload %i/%i", count, year, year.next)
				end
			end
		end
		def item_name(item)
			name = ''
			if(data = item.data)
				name = data[:name].to_s.strip
			end
			if(name.empty? && (ptr = item.item_pointer))
				name = resolved_name(ptr).to_s.strip
			end
			name unless(name.empty?)
		end
		def item_text(item)
			lines = [item.text, item_name(item)]
			if(data = item.data) 
				first_date = data[:first_valid_date] || item.time
				last_date = data[:last_valid_date]
				days = data[:days]
				if(last_date && days)
					lines.push(sprintf("%s - %s", 
						first_date.strftime("%d.%m.%Y"), last_date.strftime("%d.%m.%Y")))
					lines.push(sprintf("%i Tage", days))
				end
			end
			lines.compact.join("\n")
		end
		def resolved_name(pointer)
			pointer.resolve(@app).name
		rescue StandardError
		end
		def send_invoice(ydim_invoice_id)
			ydim_connect { |client| client.send_invoice(ydim_invoice_id) }
		end
		def ydim_connect(&block)
			config = YDIM::Client::CONFIG
			server = DRbObject.new(nil, config.server_url)
			client = YDIM::Client.new(config)
			key = OpenSSL::PKey::DSA.new(File.read(config.private_key))
			client.login(server, key)
			block.call(client)
		ensure
			client.logout if(client)
		end
	end
end
