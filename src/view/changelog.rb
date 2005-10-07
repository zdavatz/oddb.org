#!/usr/bin/env ruby
#  -- oddb -- 24.08.2005 -- ffricker@ywesee.com

require 'htmlgrid/list'
require 'htmlgrid/urllink'

module ODDB
	module View
		class ChangeLog < HtmlGrid::List
			SORT_DEFAULT = nil
			CSS_CLASS = 'composite'
			CSS_MAP = {
				[0,0,4]	=>	'list',
			}
			COMPONENTS = {
				[0,0] => :time,
				[1,0] => :chapter,
				[2,0] => :email,
				[3,0] => :language,
			}
			OMIT_HEADER = true
			DEFAULT_CLASS = HtmlGrid::Value
			LEGACY_INTERFACE = false
			SORT_HEADER = false
			SORT_REVERSE = true
			SORT_DEFAULT = :time
			SYMBOL_MAP = {
				:email => HtmlGrid::MailLink,
			}
			def chapter(model)
				link = HtmlGrid::Link.new(:chapter, model, @session, self)
				link.value = @lookandfeel.lookup("fi_#{model.chapter}")
				args = {
					:pointer => @container.model.pointer,
					:chapter => model.chapter,
				}
				link.href = @lookandfeel._event_url(:resolve, args)
				link
			end
			def language(model)
				@lookandfeel.lookup(model.language)
			end
			def time(model)
				model.time.strftime(@lookandfeel.lookup(:time_format_long))
			end
		end
	end
end
