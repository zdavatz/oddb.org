#!/usr/bin/env ruby
#	State::Admin::PatinfoStats -- oddb -- 07.10.2004 -- mwalder@ywesee.com

require 'state/global_predefine'
require 'view/admin/patinfo_stats'
require 'util/interval'

module ODDB
	module State
		module Admin
class PatinfoStatsCommon < State::Admin::Global
	VIEW = View::Admin::PatinfoStatsCompany
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
			}.reverse
		end
		def newest_date
			@newest_date ||= @invoice_items.collect { |item| 
				item.time 
			}.max
		end
	end
	class CompanyFacade
		def initialize(company)
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
			@invoice_sequences.values.sort_by { |seq|
				seq.newest_date
			}.reverse
		end
		def invoice_count
			@invoice_sequences.size
		end
		def name
			@company.name
		end
		def newest_date
			@invoice_sequences.values.collect { |seq| 
				seq.newest_date 
			}.max
		end
		def pointer
			@company.pointer
		end
		def user
			@company.user
		end
	end
	def init
		model = {}
		patinfo_slate  = @session.app.slate(:patinfo)
		patinfo_slate.items.each_value { |invoice|
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
class PatinfoStatsCompanyUser < State::Admin::PatinfoStatsCommon
	def init
		super
		@model.delete_if { |comp|
			comp.user != @session.user
		}
	end
end
class PatinfoStats < State::Admin::PatinfoStatsCommon
	VIEW = View::Admin::PatinfoStats
	include Interval
	def init
		super 
		if((pointer = @session.user_input(:pointer)) \
			&& (company = pointer.resolve(@session.app)))
			name = company.name
			@model.delete_if { |comp|
				comp.name != name
			}
		end
		filter_interval
	end
	def symbol
		:to_s
	end
end
=begin
class PatinfoStatsCompany < State::Admin::PatinfoStatsCommon
	DIRECT_EVENT = :patinfo_stats_company	
	def init
		super
		pointer = @session.user_input(:pointer)
	end
end
=end
		end
	end
end
