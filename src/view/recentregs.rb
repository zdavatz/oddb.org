#!/usr/bin/env ruby
# RecentRegsView -- oddb -- 01.09.2003 -- maege@ywesee.com

require 'view/result'

module ODDB
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
	class RootRecentRegsList < RootResultList
		SUBHEADER = DateHeader
	end
	class RecentRegsList < ResultList
		SUBHEADER = DateHeader
	end
	class RecentRegsForm < ResultForm
		COMPONENTS = {
			[0,1]		=>	'price_compare',
			[1,1]		=>	:search_query,
			[1,1,1]	=>	:submit,
			[0,2]		=>	RecentRegsList,
			[0,3]		=>	ResultFoot,
		}
		ROOT_LISTCLASS = RootRecentRegsList
	end
	class RecentRegsView < PublicTemplate
		CONTENT = RecentRegsForm
	end
end
