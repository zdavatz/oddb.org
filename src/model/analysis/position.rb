#!/usr/bin/env ruby
# encoding: utf-8
# Analysis::Position -- oddb.org -- 12.06.2006 -- sfrischknecht@ywesee.com

require 'util/language'
require 'util/searchterms'
require 'model/analysis/detail_info'
require 'model/limitationtext'
require 'model/analysis/permission'
require 'model/feedback_observer'
require 'model/text'

module ODDB
	module Analysis
		class Position
			include FeedbackObserver
			include Persistence
			include SimpleLanguage
			ODBA_SERIALIZABLE = ['@descriptions', '@lab_areas']
			attr_accessor :taxpoints, :anonymous, :anonymousgroup,
				:anonymouspos, :lab_areas, :taxnumber,
				:analysis_revision, :finding, :poscd, :group,
				:taxpoint_type
			attr_reader :limitation_text, :footnote, :list_title, 
				:taxnote, :permissions
			alias	:pointer_descr :poscd
			def initialize(poscd)
				@positions = {}
				@poscd = poscd
				@feedbacks = {}
			end
			def code
				[groupcd, @poscd].join('.')
			end
			def create_detail_info(lab_key)
				detail_info = DetailInfo.new(lab_key)
				detail_infos.store(lab_key, detail_info)
			end
			def create_footnote
				@footnote = Text::Document.new
			end
			def create_limitation_text
				@limitation_text = LimitationText.new
			end
			def create_list_title
				@list_title = Text::Document.new
			end
			def create_permissions
				@permissions = Text::Document.new
			end
			def create_taxnote
				@taxnote = Text::Document.new
			end
			def delete_detail_info(lab_key)
				if(info = detail_infos.delete(lab_key))
					@detail_infos.odba_isolated_store
					info
				end
			end
			def delete_footnote
				if(fn = @footnote)
					@footnote = nil
					fn
				end
			end
			def delete_limitation_text
				if(lt = @limitation_text)
					@limitation_text = nil
					lt
				end
			end
			def delete_list_title
				if(title = @list_title)
					@list_title = nil
					title
				end
			end
			def delete_permissions
				if(perm = @permissions)
					@permissions = nil
					perm
				end
			end
			def delete_taxnote
				if(tn = @taxnote)
					@taxnote = nil
					tn
				end
			end
			def detail_info(lab_key)
				detail_infos[lab_key]
			end
			def detail_infos
				@detail_infos ||= {}
			end
			def groupcd
				@group.groupcd
			end
			def search_text(language)
				terms = [@list_title, @taxnote, @footnote,
					@limitation_text, self].compact.collect { |doc|
					doc.send(language).split(/\s+/u)
				}
				if(@permissions)
					@permissions.send(language).each { |perm|
						if(rest = perm.restriction)
							terms.concat(rest.split(' '))
						end
						terms.concat(perm.specialization.split(' '))
					}
				end
				terms.concat(detail_infos.values)
				terms.push(groupcd, code)
				ODDB.search_term(terms.join("\n"))
			end
			def localized_name(language)
				 self.send(language)
			end
		end
	end
end
