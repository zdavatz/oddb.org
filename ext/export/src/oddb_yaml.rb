#!/usr/bin/env ruby
# YAML -- oddb -- 09.12.2004 -- hwyss@ywesee.com

require 'yaml'

module ODDB
	module OddbYaml
		YAML_URI = '!oddb.org,2003'
		EXPORT_PROPERTIES = []
		def to_yaml_type
			"#{YAML_URI}/#{self.class}"
		end
		def to_yaml_properties
			self::class::EXPORT_PROPERTIES
		end
		yaml_as YAML_URI
  end		
	module SimpleLanguage
		class Descriptions < Hash
			include OddbYaml
		end
	end
	module Text
		class Chapter
			include ODDB::OddbYaml
			EXPORT_PROPERTIES = [
				'@heading',
				'@sections',
			]
		end
		class Section
			include ODDB::OddbYaml
			EXPORT_PROPERTIES = [
				'@subheading',
				'@paragraphs',
			]
		end
		class Paragraph
			include ODDB::OddbYaml
			EXPORT_PROPERTIES = [
				'@formats',
				'@text',
				'@preformatted',
			]
		end
		class Format
			include ODDB::OddbYaml
			EXPORT_PROPERTIES = [
				'@values',
				'@start',
				'@end',
			]
		end
		class ImageLink
			include ODDB::OddbYaml
			EXPORT_PROPERTIES = [
				'@src'
			]
		end	
		class Document
			include ODDB::OddbYaml
			EXPORT_PROPERTIES = [
				'@descriptions'
			]
		end
	end
	class ActiveAgent < ActiveAgentCommon
		include OddbYaml
		EXPORT_PROPERTIES = [
			'@substance',
			'@dose',
		]
	end
	class Address2
		include OddbYaml 
		EXPORT_PROPERTIES = [
			'@title',
			'@name',
			'@additional_lines',
			'@address',
			'@location',
			'@canton',
			'@fon',
			'@fax',
			'@type',
		]
	end
	class AtcClass 
		include OddbYaml 
		EXPORT_PROPERTIES = [
			'@code',
			'@descriptions',
			'@guidelines',
			'@ddd_guidelines',
			'@ddds',
		]
		class DDD
			include OddbYaml 
			EXPORT_PROPERTIES = [
				'@administration_route',
				'@dose',
				'@note',
			]
		end
	end
	class Company
		include OddbYaml
		EXPORT_PROPERTIES = [
			'@oid',
			'@ean13',
			'@name',
			'@business_area',
			'@generic_type',
			'@registrations',
			'@url',
			'@email',
			'@addresses',
			'@contact',
			'@contact_email',
		]
	end	
	class Doctor
		include OddbYaml
		EXPORT_PROPERTIES = [
			'@oid',
			'@ean13',
			'@email',
			'@language',
			'@firstname',
			'@name',
			'@exam',
			'@praxis',
			'@salutation',
			'@title',
			'@specialities',
			'@member',
			'@addresses',
		]
	end	
	class Dose < Quanty
		include OddbYaml
		EXPORT_PROPERTIES = [
			'@val',
			'@unit',
		]
	end	
	class Fachinfo
		include OddbYaml
		EXPORT_PROPERTIES = [
			'@oid',
			'@descriptions',
		]
		def to_yaml( opts = {} )
			YAML::quick_emit( self.object_id, opts ) { |out|
				out.map( taguri ) { |map|
					to_yaml_properties.each { |m|
						map.add( m[1..-1], instance_variable_get( m ) )
					}
					map.add('iksnrs', self.iksnrs)
				}
			}
		end
	end
	class FachinfoDocument
		include OddbYaml
		EXPORT_PROPERTIES = [
			'@galenic_form',
			'@composition',
			'@effects',
			'@kinetic',
			'@indications',
			'@usage',
			'@restrictions',
			'@unwanted_effects',
			'@interactions',
			'@overdose',
			'@other_advice',
			'@delivery',
			'@distribution',
			'@fabrication',
			'@reference',
			'@iksnrs',
			'@date',
		]
	end
	class FachinfoDocument2001
		include OddbYaml
		EXPORT_PROPERTIES = [
			'@amzv',
			'@composition',
			'@galenic_form',
			'@indications',
			'@usage',
			'@contra_indications',
			'@restrictions',
			'@interactions',
			'@pregnancy',
			'@driving_ability',
			'@unwanted_effects',
			'@overdose',
			'@effects',
			'@kinetic',
			'@preclinic',
			'@other_advice',
			'@iksnrs',
			'@registration_owner',
			'@date',
		]
	end
	class GalenicForm
		include OddbYaml
		EXPORT_PROPERTIES = [
			'@oid',
			'@descriptions',
			'@galenic_group',
		]
	end
	class GalenicGroup
		include OddbYaml
		EXPORT_PROPERTIES = [
			'@oid',
			'@descriptions',
		]
	end
	class Indication
		include OddbYaml
		EXPORT_PROPERTIES = [
			'@oid',
			'@descriptions',
		]
	end
	class LimitationText
		include OddbYaml
		EXPORT_PROPERTIES = [
			'@descriptions',
		]
	end
	class Narcotic
		include OddbYaml
		EXPORT_PROPERTIES = [
			'@oid',
			'@casrn',
			'@substance',
		]
		def to_yaml( opts = {} )
			YAML::quick_emit( self.object_id, opts ) { |out|
				out.map( taguri ) { |map|
					to_yaml_properties.each { |m|
						map.add( m[1..-1], instance_variable_get( m ) )
					}
					map.add('packages', @packages.collect { |pac| pac.ikskey })
				}
			}
		end
	end
	class Package < PackageCommon
		include OddbYaml
		EXPORT_PROPERTIES = [	
			'@ikscd',
			'@size',
			'@descr',
			'@ikscat',
			'@price_exfactory',
			'@price_public',
			'@sl_entry',
		]
		def to_yaml( opts = {} )
			YAML::quick_emit( self.object_id, opts ) { |out|
				out.map( taguri ) { |map|
					to_yaml_properties.each { |m|
						map.add( m[1..-1], instance_variable_get( m ) )
					}
					map.add('ean13', self.barcode)
					map.add('pharmacode', self.pharmacode)
					map.add('narcotics', @narcotics.collect { |narc| narc.casrn})
				}
			}
		end
	end
	class Patinfo
		include OddbYaml
		EXPORT_PROPERTIES = [
			'@oid',
			'@descriptions',
		]
	end
	class PatinfoDocument
		include OddbYaml
		EXPORT_PROPERTIES = [
			'@name',
			'@company',
			'@galenic_form',
			'@effects',
			'@amendments',
			'@contra_indications',
			'@precautions',
			'@pregnancy',
			'@usage',
			'@unwanted_effects',
			'@general_advice',
			'@composition',
			'@packages',
			'@distribution',
			'@date',
		]
	end
	class PatinfoDocument2001
		include OddbYaml
		EXPORT_PROPERTIES = [
			'@name',
			'@company',
			'@galenic_form',
			'@effects',
			'@amendments',
			'@contra_indications',
			'@precautions',
			'@pregnancy',
			'@usage',
			'@unwanted_effects',
			'@general_advice',
			'@composition',
			'@packages',
			'@distribution',
			'@date',
		]
	end
	class Registration < RegistrationCommon
		include OddbYaml
		EXPORT_PROPERTIES = [
			'@iksnr',
			'@registration_date',
			'@revision_date',
			'@expiration_date',
			'@inactive_date',
			'@sequences',
			'@indication',
			'@generic_type',
			'@export_flag',
			'@fachinfo_oid',
		]
	end
	class Sequence < SequenceCommon
		include OddbYaml
		EXPORT_PROPERTIES = [
			'@seqnr',
			'@name_base',
			'@name_descr',
			'@dose',
			'@atc_class',
			'@galenic_form',
			'@composition_text',
			'@active_agents',
			'@packages',
		]
	end
	class SlEntry
		include OddbYaml
		EXPORT_PROPERTIES = [
			'@introduction_date',
			'@limitation',
			'@limitation_points',
			'@limitation_text',
		]
	end
	class Substance 
		include OddbYaml
		EXPORT_PROPERTIES = [
			'@oid',
			'@descriptions',
			'@synonyms',
			'@effective_form',
			'@swissmedic_code',
		]
		def to_yaml( opts = {} )
			YAML::quick_emit( self.object_id, opts ) { |out|
				out.map( taguri ) { |map|
					to_yaml_properties.each { |m|
						map.add( m[1..-1], instance_variable_get( m ) )
					}
					if(@narcotic)
						map.add('narcotic', @narcotic.casrn)
					end
				}
			}
		end
	end
end
