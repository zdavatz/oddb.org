#!/usr/bin/env ruby
#View::Narcotic -- oddb -- 08.11.2005 -- spfenninger@ywesee.com

require 'view/privatetemplate'
require 'view/resultfoot'

module ODDB
	module View
		module Drugs
			class PackagesList < HtmlGrid::List	
				COMPONENTS = {
					[0,0]	=> :ikskey,
					[1,0]	=> :name_base,
				}
				CSS_MAP = {
					[0,0]	=>	'top list',
					[1,0]	=>	'list',
				}
				DEFAULT_CLASS = HtmlGrid::Value
				DEFAULT_HEAD_CLASS = 'subheading'
				SORT_HEADER = false
				SORT_DEFAULT = :name_base
				LEGACY_INTERFACE = false
				LOOKANDFEEL_MAP = {
					:ikskey	=>	:title_packages,
					:name_base	=>	:nbsp,
				}
				def ikskey(model)
					item = model.ikskey
					self.link(model, item)
				end
				def name_base(model)
					item  = model.name_base
					self.link(model, item)
				end
				def link(model, item)
					link = HtmlGrid::Link.new(:show, model, @session, self)
					link.href = @lookandfeel._event_url(:show, {:pointer => model.pointer})
					link.value = item
					link
				end
			end
			class NarcoticInnerComposite < HtmlGrid::Composite
				COMPONENTS = {
					[0,0]	=> :casrn,
					[0,1]	=> :swissmedic_code,
					[0,2] => :substance,
					[0,3] => :reservation_text,
				}
				LABELS = true
				DEFAULT_CLASS = HtmlGrid::Value
				LEGACY_INTERFACE = false
				CSS_MAP = {
					[0,0,1,4] => 'list top',
					[1,0,1,4] => 'list',
				}
			end
			class NarcoticComposite < HtmlGrid::Composite
				COMPONENTS = {
					[0,0] => :narcotic_connection,
					[0,1]	=> NarcoticInnerComposite,
					[0,2] => :packages,
				}
				CSS_MAP = {
					[0,0]	=> 'th',
					[0,2] => 'list',
				}
				LEGACY_INTERFACE = false
				CSS_CLASS = 'composite'
				DEFAULT_CLASS = HtmlGrid::Value
				def narcotic_connection(model)
					@lookandfeel.lookup(:narcotic_connection, model.substance)
				end
				def packages(model)
					pack = model.packages
					unless(pack.empty?)
						PackagesList.new(pack, @session, self)
					end
				end
			end
			class Narcotic < View::PrivateTemplate
				CONTENT = View::Drugs::NarcoticComposite
				SNAPBACK_EVENT = :result
			end
		end
	end
end
