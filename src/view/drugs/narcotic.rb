#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Narcotic -- oddb.org -- 26.10.2011 -- mhatakeyama@ywesee.com
# ODDB::View::Narcotic -- oddb.org -- 08.11.2005 -- spfenninger@ywesee.com

require 'view/drugs/privatetemplate'
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
				SORT_DEFAULT = nil
				LEGACY_INTERFACE = false
				LOOKANDFEEL_MAP = {
					:ikskey	=>	:title_packages,
					:name_base	=>	:nbsp,
					:size	=>	:nbsp,
				}
				def init
					@model = @model.sort_by { |package|
						[package.name_base.to_s, package.size.to_f]
					}
					super
				end
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
					link.href = @lookandfeel._event_url(:show, [:reg, model.iksnr, :seq, model.seqnr, :pack, model.ikscd])
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
					[0,3] => 'list',
				}
				LEGACY_INTERFACE = false
				CSS_CLASS = 'composite'
				DEFAULT_CLASS = HtmlGrid::Value
        @@reservation = /(SR|RS) (\d{3}\.\d{3}\.\d{2})/u
				def narcotic_connection(model)
					@lookandfeel.lookup(:narcotic_connection, model.substances.sort.first) if model
				end
				def packages(model)
          if model
            pack = model.packages
            unless(pack.empty?)
              PackagesList.new(pack, @session, self)
            end
          end
				end
				def reservation_text(model)
					if(model and text = model.reservation_text)
						div = HtmlGrid::Div.new(model, @session, self)
						div.css_class = 'long-text list bg'
						txt = text.send(@session.language)
						div.value = if(match = @@reservation.match(txt))
							url = sprintf('http://www.admin.ch/ch/%s/%s/c%s.html',
								(@session.language.to_s == 'fr') ? 'f' : 'd', 
								match[1].downcase,
								match[2].gsub('.', '_'))
							link = "<a href='#{url}'>#{match.to_s}</a>"
							txt.gsub(match.to_s, link)
						else
							txt
						end
						div
					end
				end
			end
			class Narcotic < PrivateTemplate
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
			class NarcoticPlus < PrivateTemplate
				CONTENT = View::Drugs::NarcoticPlusComposite
				SNAPBACK_EVENT = :result
			end
		end
	end
end
