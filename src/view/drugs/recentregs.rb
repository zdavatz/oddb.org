#!/usr/bin/env ruby
# View::Drugs::RecentRegs -- oddb -- 01.09.2003 -- maege@ywesee.com

require 'view/drugs/result'

module ODDB
	module View
		module Drugs
class DateHeader < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	:date_packages,
	}
	CSS_CLASS = 'composite'
	def date_packages(model, session)
		date = model.date
		[
			@lookandfeel.lookup('month_' + date.month.to_s),
			date.year, 
			'-',
			model.package_count,
			@lookandfeel.lookup(:products),
		].join(' ')
	end
end
class RootRecentRegsList < View::Drugs::RootResultList
	SUBHEADER = View::Drugs::DateHeader
end
class RecentRegsList < View::Drugs::ResultList
	SUBHEADER = View::Drugs::DateHeader
end
class RecentRegsForm < View::Drugs::ResultForm
	COMPONENTS = {
		[0,1]		=>	'price_compare',
		[1,1]		=>	:search_query,
		[1,1,1]	=>	:submit,
		[0,2]		=>	View::Drugs::RecentRegsList,
		[0,3]		=>	View::ResultFoot,
	}
	ROOT_LISTCLASS = View::Drugs::RootRecentRegsList
end
class RecentRegs < View::ResultTemplate
	CONTENT = View::Drugs::RecentRegsForm
end
		end
	end
end
