#!/usr/bin/env ruby
# YdimPlugin -- oddb -- 27.01.2006 -- hwyss@ywesee.com

require 'plugin/plugin'
require 'ydim/config'
require 'ydim/client'
require 'openssl'

module ODDB
	class YdimPlugin < Plugin
    class DebitorFacade
      attr_reader :invoice_email
      def initialize(email, app)
        @app = app
        @email = email
        @debitor = app.yus_model(email)
        @invoice_email = method_missing(:invoice_email) || email
      end
      def method_missing(method, *args, &block)
        if(@debitor.respond_to?(method))
          @debitor.send(method, *args, &block)
        else
          @app.yus_get_preference(@email, method)
        end
      end
      def ydim_id=(id)
        if(@debitor.respond_to?(:ydim_id=))
          @debitor.ydim_id = id
          @debitor.odba_store
        else
          @app.yus_set_preference(@email, 'ydim_id', id)
        end
      end
      def ===(test)
        @debitor === test
      end
    end
		SECONDS_IN_DAY = 60*60*24
		SALUTATIONS = {
			'salutation_m'	=>	'Herr',	
			'salutation_f'	=>	'Frau',	
		}
		def create_debitor(facade)
			ydim_connect { |client|
				debitor = client.create_debitor
        debitor.name = facade.fullname || facade.company_name || facade.contact
        contact = facade.contact.to_s.dup
        salutation = contact.slice!(/^(Herr|Frau)\s+/).to_s.strip
        name_first, name_last = contact.split(' ', 2)
        debitor.salutation = SALUTATIONS[facade.salutation] || salutation
        debitor.contact_firstname = facade.name_first || name_first
        debitor.contact = facade.name_last || name_last
        debitor.address_lines = facade.ydim_address_lines || []
        debitor.location = facade.ydim_location.to_s
        debitor.debitor_type = case facade
                               when ODDB::Hospital
                                 'dt_hospital'
                               when ODDB::Company
                                 if(ba = facade.business_area)
                                   ba.gsub(/^ba/, 'dt')
                                 else
                                   'dt_pharma'
                                 end
                               else
                                 'dt_info'
                               end
				debitor.email = facade.invoice_email
				debitor.odba_store
				facade.ydim_id = debitor.unique_id
				debitor
			}
		end
		def debitor_id(facade)
      ## since not all users can be associated with a business-object,
      #  ydim_id needs to be a yus_preference. However, if a business-object 
      #  exists, it should take precedence.
      if(id = facade.ydim_id)
        id
      elsif(debitor = identify_debitor(facade))
        debitor.unique_id
      else
        create_debitor(facade).unique_id
      end
		end
		def identify_debitor(facade)
			ydim_connect { |client|
        term = facade.fullname || facade.company_name || facade.contact
				if(debitor = client.search_debitors(term).first)
          facade.ydim_id = debitor.unique_id
					debitor
				end
			}
		end
		def inject(invoice)
			if(id = invoice.ydim_id)
				ydim_connect { |client| client.invoice(id) }
			elsif(email = invoice.yus_name)
				items = invoice.items.values
				ydim_inv = inject_from_items(invoice_date(items), email, items,
																		invoice.currency || 'CHF')
				ydim_inv.payment_received = invoice.payment_received?
				ydim_inv.odba_store
				invoice.ydim_id = ydim_inv.unique_id
				invoice.odba_store
			end
		end
		def inject_from_items(date, email, items, currency='CHF')
      facade = DebitorFacade.new(email, @app)
			ydim_connect { |client|
				ydim_inv = client.create_invoice(debitor_id(facade))
				ydim_inv.description = invoice_description(items)
				ydim_inv.date = date
				ydim_inv.currency = currency
				ydim_inv.payment_period = 30
				item_data = sort_items(items).collect { |item| 
					if(sprintf('%1.2f', item.quantity) == "0.00")
						ydim_inv.precision = 3
					end
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
				sprintf("%i x CSV-Download %s", items.size, timstr)
			elsif(types.include?(:download))
				sprintf('%i x Download %s', items.size, time.strftime('%d.%m.%Y'))
			elsif(types.include?(:index))
				sprintf("Firmenverzeichnis %i/%i", year, year.next)
			elsif(types.include?(:lookandfeel))
				sprintf("Lookandfeel-Integration %i/%i", year, year.next)
			else
        year = @@today.year
				count = items.select { |item| item.type == :annual_fee }.size
				sprintf("%i x Patinfo-Upload %i/%i", count, year, year.next)
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
		def sort_items(items)
			items.sort_by { |item| 
				[item.time.to_i / SECONDS_IN_DAY, (item.type == :activation) ? 0 : 1,
					item_text(item), item.type.to_s]
			}
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
