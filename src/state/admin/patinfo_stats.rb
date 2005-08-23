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
		def initialize(invoice_item)
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
			@slate_sequences= {}
		end
		def add_sequence(item_facade)
			sequence = item_facade.sequence
			sequence_facade = @slate_sequences.fetch(sequence) {
				@slate_sequences.store(sequence, 
					SequenceFacade.new(sequence))
			}
			sequence_facade.add_invoice_item(item_facade)
		end
		def slate_sequences
			@slate_sequences.values.sort_by { |seq|
				seq.newest_date
			}.reverse
		end
		def slate_count
			@slate_sequences.size
		end
		def name
			@company.name
		end
		def newest_date
			@slate_sequences.values.collect { |seq| 
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
		patinfo_slate = @session.slate(:patinfo)
		patinfo_slate.items.each_value { |item|
			if(item.type == :annual_fee \
				&& (sequence = @session.app.resolve(item.item_pointer)))
				item_facade = InvoiceItemFacade.new(item)
				item_facade.sequence = sequence
				item_facade.user = @session.app.resolve(item.user_pointer)
				company = sequence.company
				company_facade = model.fetch(company.name) {
					model.store(company.name, CompanyFacade.new(company))
				}
				company_facade.add_sequence(item_facade)
			end
		}
		@model = model.values
	end
end
class PatinfoStatsCompanyUser < State::Admin::PatinfoStatsCommon
	def init
		super
		name = @session.user.model.name
		@model.delete_if { |comp|
			comp.name != name
		}
	end
end
class PatinfoStats < State::Admin::PatinfoStatsCommon
	VIEW = View::Admin::PatinfoStats
	include Interval
	FILTER_THRESHOLD = 0
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
		:name
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
