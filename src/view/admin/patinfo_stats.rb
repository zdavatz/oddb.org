#!/usr/bin/env ruby
# View::PatinfoStats -- oddb -- 07.10.2004 -- mwalder@ywesee.com 

require 'htmlgrid/composite'
require 'htmlgrid/list'
require 'htmlgrid/link'
require 'view/form'
require 'view/publictemplate'
require 'view/pointervalue'
require 'view/resulttemplate'
require 'view/additional_information'
require 'view/alphaheader'

module ODDB
	module View
		module Admin
class CompanyHeader < HtmlGrid::Composite
	include View::AdditionalInformation
	COMPONENTS = {
		[0,0] => :name,
		[0,0,1] => 'nbsp',
		[0,0,2] => 'total',
		[0,0,3] => 'nbsp',
		[0,0,4] => :invoice_count,
	}
	CSS_CLASS = 'composite'
	DEFAULT_CLASS = HtmlGrid::Value
	SYMBOL_MAP = {
		:name =>	View::PointerLink,
	}
	def init
		if(@session.user.is_a? RootUser)
			components.store([0,0,0], :edit)
		end
		super
	end
end
class PatinfoStatsCompanyList < HtmlGrid::List
	COMPONENTS = {
		[0,0]		=> :date,
		[1,0]		=> :email
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=> 'list',
		[1,0]	=> 'list',
	}
	#SORT_DEFAULT = :newest_date
	SORT_REVERSE = true
	SORT_HEADER = false
	LOOKANDFEEL_MAP = {
		:date					=>	:patinfo_stats,
		:email				=>	:nbsp,
	}
	def date(model, session)
		time = model.time
		time.strftime("%A %d.%m.%Y &nbsp;&nbsp;-&nbsp;&nbsp;%H.%M Uhr %Z")
	end
	def email(model, session)
		model.user.unique_email
	end
	SUBHEADER = View::Admin::CompanyHeader
	def compose_list(model=@model, offset=[0,0])
		model.each { |company|
			compose_subheader(company, offset)
			offset = resolve_offset(offset, self::class::OFFSET_STEP)
			invoice_sequences = company.invoice_sequences
			invoice_sequences.each { |seq|
				compose_subheader_seq(seq, offset)
				offset = resolve_offset(offset, self::class::OFFSET_STEP)
				invoice_items = seq.invoice_items
				super(invoice_items, offset)
				offset[1] += invoice_items.size
			}
		}
	end
	def compose_subheader(company, offset)
		subheader = self::class::SUBHEADER.new(company, @session, self)
		@grid.add(subheader, *offset)
		@grid.add_style('result-atc bold', *offset)
		@grid.set_colspan(offset.at(0), offset.at(1), full_colspan)
	end
	def compose_subheader_seq(seq, offset)
		@grid.add(seq_iks_link(seq), *offset)
		@grid.add_style('result-seq indent bold', *offset)
		x, y = offset
		@grid.add_style('result-seq', x + 1, y)
	end
	def seq_iks_link(seq)
		View::PointerLink.new(:iksnr_seqnr, seq, @session, self)
	end
end
class PatinfoStatsList < PatinfoStatsCompanyList
	include View::AlphaHeader
end
class PatinfoStatsComposite < HtmlGrid::Composite
	COMPONENTS = {
		#	[0,0]		=> 'patinfo_stats',
		[0,1]		=> View::Admin::PatinfoStatsList,
	}
	CSS_MAP = {
		#[0,0]	=> 'th',
	}
	CSS_CLASS = 'composite'
end	
class PatinfoStatsCompanyComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0] => 'patinfo_stats',
		[0,1]	=>	View::Admin::PatinfoStatsCompanyList
	}
	CSS_CLASS = 'composite'
end
class PatinfoStats < View::ResultTemplate
	CONTENT = View::Admin::PatinfoStatsComposite
end
class PatinfoStatsCompany < PatinfoStats
	CONTENT = View::Admin::PatinfoStatsCompanyComposite	
end
		end
	end
end
