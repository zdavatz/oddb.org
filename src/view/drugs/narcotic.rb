#!/usr/bin/env ruby
#View::Narcotic -- oddb -- 08.11.2005 -- spfenninger@ywesee.com

require 'view/privatetemplate'
require 'view/resultfoot'
require 'view/additional_information'

module ODDB
	module View
		module Drugs
			class PackagesList < HtmlGrid::List	
				COMPONENTS = {
					[0,0]	=> :ikskey,
					[1,0]	=> :name_base,
					[2,0]	=> :size,
				}
				CSS_MAP = {
					[0,0]	=>	'top list',
					[1,0]	=>	'list',
					[2,0]	=>	'list',
				}
				DEFAULT_CLASS = HtmlGrid::Value
				DEFAULT_HEAD_CLASS = 'subheading'
				SORT_HEADER = false
				SORT_DEFAULT = :name_base
				LEGACY_INTERFACE = false
				LOOKANDFEEL_MAP = {
					:ikskey	=>	:title_packages,
					:name_base	=>	:nbsp,
					:size	=> :nbsp,
				}
				def ikskey(model)
					item = model.ikskey
					self.link(model, item)
				end
				def name_base(model)
					item  = model.name_base
					self.link(model, item)
				end
				def size(model)
					model.size
				end
				def link(model, item)
					link = HtmlGrid::Link.new(:show, model, @session, self)
					link.href = @lookandfeel._event_url(:show, {:pointer => model.pointer})
					link.value = item
					link
				end
			end
			class NarcoticInnerComposite < HtmlGrid::Composite
				include View::AdditionalInformation
				COMPONENTS = {
					[0,0]	=> :casrn,
					[0,1]	=> :swissmedic_code,
					[0,2] => :substances,
				}
				LABELS = true
				DEFAULT_CLASS = HtmlGrid::Value
				LEGACY_INTERFACE = false
				CSS_MAP = {
					[0,0,1,3] => 'top list',
					[1,0,1,3] => 'list',
				}
			end
			class NarcoticComposite < HtmlGrid::Composite
				COMPONENTS = {
					[0,0] => :narcotic_connection,
					[0,1]	=> NarcoticInnerComposite,
					[0,2]	=> :reservation_text,
					[0,3] => :packages,
				}
				CSS_MAP = {
					[0,0]	=> 'th',
					[0,2]	=> 'list bg',
					[0,3] => 'list',
				}
				LEGACY_INTERFACE = false
				CSS_CLASS = 'composite'
				DEFAULT_CLASS = HtmlGrid::Value
				def narcotic_connection(model)
					@lookandfeel.lookup(:narcotic_connection, model.substances)
				end
				def packages(model)
					pack = model.packages
					unless(pack.empty?)
						PackagesList.new(pack, @session, self)
					end
				end
				def reservation_text(model)
					if(text = model.reservation_text)
						css_map.store(components.index(:reservation_text), 
							'list-bg')
						txt = text.send(@session.language)
						if(match = /SR (\d{3}\.\d{3}\.\d{2})/.match(txt))
							url = sprintf('http://www.admin.ch/ch/%s/sr/c%s.html',
								@session.language[0,1], 
								match[1].gsub('.', '_'))
							link = "<a href='#{url}'>#{match.to_s}</a>"
							txt.gsub(match.to_s, link)
						else
							txt
						end
					end
				end
			end
			class Narcotic < View::PrivateTemplate
				CONTENT = View::Drugs::NarcoticComposite
				SNAPBACK_EVENT = :result
			end
			class NarcoticPlusComposite < HtmlGrid::List
				STRIPED_BG = false
				COMPONENTS = {
					[0,0]	=> NarcoticComposite,
				}
				CSS_MAP = {
					[0,0]	=>	'top',
				}
				LEGACY_INTERFACE = false
				CSS_CLASS = 'composite'
				OFFSET_STEP = [1,0]
				OMIT_HEADER = true
			end
			class NarcoticPlus < View::PrivateTemplate
				CONTENT = View::Drugs::NarcoticPlusComposite
				SNAPBACK_EVENT = :result
			end
		end
	end
end
