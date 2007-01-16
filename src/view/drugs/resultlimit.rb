#!/usr/bin/env ruby
# View::Drugs::ResultLimit -- oddb -- 26.07.2005 -- hwyss@ywesee.com

require 'view/resulttemplate'
require 'view/limit'
require 'view/drugs/result'
require 'view/additional_information'
require 'view/dataformat'
require 'view/sponsorhead'

module ODDB
	module View
		module Drugs
class ResultLimitList < HtmlGrid::List
	include DataFormat
	include View::AdditionalInformation
	COMPONENTS = {
		[0,0]	=>  :fachinfo,
		[1,0]	=>	:patinfo,
		[2,0]	=>	:narcotic,
		[3,0]	=>	:name_base,
		[4,0]	=>	:galenic_form,
		[5,0]	=>	:most_precise_dose,
		[6,0]	=>	:comparable_size,
		[7,0]	=>	:price_exfactory,
		[8,0]	=>	:price_public,
		[9,0]	=>	:ikscat,
		[10,0]	=>	:feedback,
		[11,0]	=>  :google_search,
		[12,0]	=>	:notify,
	}
	DEFAULT_CLASS = HtmlGrid::Value
	CSS_CLASS = 'composite'
	SORT_HEADER = false
	CSS_MAP = {
		[0,0,3]	=>	'list',
		[3,0] => 'list big',
		[4,0] => 'list',
		[5,0,5] => 'list right',
		[10,0,3]=>	'list right',
	}
	CSS_HEAD_MAP = {
		[5,0] => 'th right',
		[6,0] => 'th right',
		[7,0] => 'th right',
		[8,0] => 'th right',
		[9,0] => 'th right',
		[10,0] => 'th right',
		[11,0] => 'th right',
		[12,0] => 'th right',
	}
	def compose_empty_list(offset)
		count = @session.state.package_count.to_i
		if(count > 0)
			@grid.add(@lookandfeel.lookup(:query_limit_empty, 
				@session.state.package_count, 
				@session.class.const_get(:QUERY_LIMIT)), *offset)
			@grid.add_attribute('class', 'list', *offset)
			@grid.set_colspan(*offset)
		else
			super
		end
	end
	def fachinfo(model, session)
		super(model, session, 'square important infos')
	end	
	def name_base(model, session)
		model.name_base
	end
  def most_precise_dose(model, session=@session)
    model.pretty_dose || if(model.active_agents.size == 1)
      model.dose
    end
  end
end
class ResultLimitComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=> :export_csv,
		[0,1]	=> SearchForm,
		[0,2] => ResultLimitList, 
		[0,3]	=> View::LimitComposite,
	}
	LEGACY_INTERFACE = false
  CSS_MAP = {
    [0,0] => 'right',
    [0,1] => 'right',
  }
	def export_csv(model)
		if(@session.state.package_count.to_i > 0)
			View::Drugs::DivExportCSV.new(model, @session, self)
		end
	end
end
class ResultLimit < ResultTemplate
	HEAD = View::SponsorHead
	CONTENT = ResultLimitComposite
end
		end
	end
end
