#!/usr/bin/env ruby
# View::PatinfoStats -- oddb -- 07.10.2004 -- mwalder@ywesee.com 

require 'htmlgrid/composite'
require 'htmlgrid/list'
require 'htmlgrid/link'
require 'view/form'
require 'view/publictemplate'
require 'view/additional_information'

module ODDB
	module View
		module Admin
class CompanyHeader < HtmlGrid::Composite
	include View::AdditionalInformation
	COMPONENTS = {
		[0,0] => :company_name,
	}
	CSS_CLASS = 'composite'
	def init
		if(@session.user.is_a? RootUser)
			components.store([0,0,0], :edit)
		end
		super
	end
	def company_name(company, session)
		comp = model.company
		return if comp.nil?
		if(@lookandfeel.enabled?(:powerlink, false) && comp.powerlink)
			link = HtmlGrid::HttpLink.new(:name, model.company, session, self)
			link.href = @lookandfeel.event_url(:powerlink, {'pointer'=>comp.pointer})
			link.set_attribute("class", "powerlink")
			link
		elsif(@lookandfeel.enabled?(:companylist) \
			&& model.company.listed?)
			View::PointerLink.new(:name, model.company, session, self)
		else
			HtmlGrid::Value.new(:name, model.company, session, self)
		end
	end
end
class PatinfoStatsList < HtmlGrid::List
	COMPONENTS = {
		[0,0]		=> :date,
		[1,0]		=> :email
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=> 'list',
		[1,0]	=> 'list',
	}
	OMIT_HEADER = true
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
			invoice_sequences.each {|seq|
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
		values = [
			seq_iks_link(seq),
			@lookandfeel.lookup(:user_pi_upload)
		]
		@grid.add(values, *offset)
		@grid.add_style('result-seq indent bold', *offset)
		x, y = offset
		@grid.add_style('result-seq', x + 1, y)
	end
	def seq_iks_link(seq)
		View::PointerLink.new(:iksnr_seqnr, seq, @session, self)
	end
end
class PatinfoStatsComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]		=> 'patinfo_stats',
		[0,1]		=> View::Admin::PatinfoStatsList,
	}
	CSS_MAP = {
		[0,0]	=> 'th',
	}
	CSS_CLASS = 'composite'
end
class PatinfoStats < View::PublicTemplate
	CONTENT = View::Admin::PatinfoStatsComposite
end
		end
	end
end
