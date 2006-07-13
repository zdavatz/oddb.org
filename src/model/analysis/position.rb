#!/usr/bin/env ruby
# Analysis::Position -- oddb.org -- 12.06.2006 -- sfrischknecht@ywesee.com

require 'util/searchterms'
require 'model/analysis/permission'
require 'model/feedback_observer'

module ODDB
	module Analysis
		class Position
			include FeedbackObserver
			include Persistence
			ODBA_SERIALIZABLE = ['@permissions']
			attr_accessor :taxpoints, :limitation, :list_title,
				:description, :anonymous, :footnote,
				:anonymousgroup, :anonymouspos, :lab_areas,
				:taxnumber, :taxnote, :analysis_revision, :finding,
				:poscd, :group, :taxpoint_type, :permissions
			alias	:pointer_descr :poscd
			def initialize(poscd)
				@positions = {}
				@poscd = poscd
				@permissions = []
				@feedbacks = {}
			end
			def code
				[groupcd, @poscd].join('.')
			end
			def groupcd
				@group.groupcd
			end
			def search_alpha
				terms = [@description]
				ODDB.search_terms(terms)
			end
			def search_group
				terms = [code]
				terms.concat(groupcd)
				ODDB.search_terms(terms)
			end
			def search_terms
				terms = [@list_title]
				terms.concat(@list_title.split(' '))
				terms.concat(@list_title.split('/'))
				terms.concat(@description.split(' '))
				ODDB.search_terms(terms)
			end
			def localized_name(language)
				 @description
			end
		end
	end
end
