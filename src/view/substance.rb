#!/usr/bin/env ruby
# SubstanceView -- oddb -- 25.05.2004 -- maege@ywesee.com

require 'view/privatetemplate'
require 'view/descriptionform'
require 'view/additional_information'

=begin
zwei probleme:
- snapback wird nicht sauber generiert
- alle descriptions werden mandatory gesetzt
=end

module ODDB
	module SubstanceSubstrateList
		include AdditionalInformation
		COMPONENTS = {
			[0,0]	=>	:substrates,
		}
		CSS_CLASS = 'composite'
		CSS_MAP = {
			[0,0,1]	=>	'list',
		}	
		DEFAULT_CLASS = HtmlGrid::Value
		DEFUALT_HEAD_CLASS = 'subheading'
		SORT_HEADER = false
		SORT_DEFAULT = :cyp_id
		def substrates(model, session)
			txt = HtmlGrid::Text.new(:substrates, model, session, self)
			txt.label = false 
			txt.value = model.cyp_id 
			txt
		end
	end
	class SubstanceSubstrates < HtmlGrid::List
		include SubstanceSubstrateList
	end
	class SubstanceForm < DescriptionForm
		DESCRIPTION_CSS = 'xl'
		def languages
			lang = @lookandfeel.languages.dup
			lang << 'en' << 'lt'
		end
	end
	class SubstanceComposite < HtmlGrid::Composite
		COMPONENTS = {
			[0,0]	=>	:substance_name,
			[0,1]	=>	SubstanceForm,
			[0,2]	=>	:nbsp,
			[0,4]	=>	:substrate_connections,
		}
		CSS_CLASS = 'composite'
		CSS_MAP = {
			[0,0]	=>	'th',
		}
		DEFAULT_CLASS = HtmlGrid::Value
		def substance_name(model, session)
			model.name
		end
		def substrate_connections(model, session)
			unless(model.substrate_connections.nil?)
				connections = model.substrate_connections.values
				values = PointerArray.new(connections, model.pointer)
				SubstanceSubstrates.new(values, session, self)
			end
		end
	end
	class SubstanceView < PrivateTemplate
		CONTENT = SubstanceComposite
		SNAPBACK_EVENT = :substances
	end
end
