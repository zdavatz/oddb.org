#!/usr/bin/env ruby
#	State::Admin::PatinfoStats -- oddb -- 07.10.2004 -- mwalder@ywesee.com

require 'state/global_predefine'
require 'view/admin/patinfo_stats'

module ODDB
	module State
		module Admin
			class PatinfoStats < State::Admin::Global
				VIEW = View::Admin::PatinfoStats
				DIRECT_EVENT = :patinfo_stats	
				class InvoiceItemFacade
					attr_accessor :user, :sequence, :time
					def initialize(invoice_item, app)
						@user = app.resolve(invoice_item.user_pointer)
						@sequence = app.resolve(invoice_item.item_pointer)
						@time = invoice_item.time
					end
				end
				class SequenceFacade
					attr_accessor  :iksnr, :seqnr, :pointer
					def initialize(sequence)
						@iksnr = sequence.iksnr
						@seqnr = sequence.seqnr
						@pointer = sequence.pointer
						@invoice_items = [] 
					end
					def add_invoice_item(invoice_item)
						@invoice_items.push(invoice_item)
					end
					def iksnr_seqnr
						"#{@iksnr}&nbsp;&nbsp;#{@seqnr}"
					end
					def invoice_items
						@invoice_items.sort_by { |item|
							item.time
						}
					end
				end
				class CompanyFacade
					attr_accessor :company_name, :company
					def initialize(company)
						@company_name = company.name
						@company = company
						@invoice_sequences= {}
					end
					def add_sequence(item_facade)
						sequence = item_facade.sequence
						sequence_facade = @invoice_sequences.fetch(sequence) {
							@invoice_sequences.store(sequence, 
								SequenceFacade.new(sequence))
						}
						sequence_facade.add_invoice_item(item_facade)
					end
					def invoice_sequences
						@invoice_sequences.values
					end
				end
				def init
					model = {}
					patinfo_invoice  = @session.app.invoice(:patinfo)
					invoices = patinfo_invoice.items.values
					invoices.each { |invoice|
						item_facade = InvoiceItemFacade.new(invoice, @session.app)
						company = item_facade.sequence.company
						company_facade = model.fetch(company.name) {
							model.store(company.name, CompanyFacade.new(company))
						}
						company_facade.add_sequence(item_facade)
					}
					@model = model.values
				end
			end
			class PatinfoStatsCompanyUser < State::Admin::PatinfoStats
				def init
					super
					@model.delete_if { |comp|
						comp.company.user != @session.user
					}
				end
			end
		end
	end
end

