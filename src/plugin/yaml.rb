#!/usr/bin/env ruby
# YamlPlugin -- oddb -- 02.09.2003 -- rwaltert@ywesee.com

require 'plugin/plugin'
require 'models'
require 'yaml'

module ODDB 
	module OddbYaml
		YAML_URI = 'oddb.org,2003'
		EXPORT_PROPERTIES = []
		def to_yaml_type
			#puts self.class
			"!#{YAML_URI}/#{self.class}"
		end
		def to_yaml_properties
			#puts self::class::EXPORT_PROPERTIES
			self::class::EXPORT_PROPERTIES
		end
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
			'@registrations',
			'@url',
			'@phone',
			'@fax',
			'@email',
			'@address',
			'@plz',
			'@location',
			'@contact',
			'@contact_email',
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
				out.map( self.to_yaml_type ) { |map|
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
				out.map( self.to_yaml_type ) { |map|
					to_yaml_properties.each { |m|
						map.add( m[1..-1], instance_variable_get( m ) )
					}
					map.add('ean13', self.barcode)
					map.add('pharmacode', self.pharmacode)
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
			'@purpose',
			'@amendments',
			'@contra_indications',
			'@precautions',
			'@pregnancy',
			'@usage',
			'@unwanted_effects',
			'@general_advice',
			'@other_advice',
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
			'@purpose',
			'@amendments',
			'@contra_indications',
			'@precautions',
			'@pregnancy',
			'@usage',
			'@unwanted_effects',
			'@general_advice',
			'@other_advice',
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
			#'@patinfo_oid',
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
=begin
		EXPORT_PROPERTIES = [
			'@introduction_date',
			'@limitation',
			'@limitation_points',
			'@limitation_text',
		]
=end
	end
	class Substance 
		include OddbYaml
		EXPORT_PROPERTIES = [
			'@oid',
			'@name',
		]
	end
	class YamlExporter < Plugin
		DOCUMENT_ROOT = File.expand_path('../../doc/', File.dirname(__FILE__))
		EXPORT_DIR = File.expand_path('resources/downloads', DOCUMENT_ROOT)
		def run
			db_name = 'oddb.yaml'
			fi_name = 'fachinfo.yaml'
			pi_name = 'patinfo.yaml'
			atc_name = 'atc.yaml'
			#puts "exporting #{db_name}"
			export(db_name)
			#puts "compressing #{db_name}"
			compress(db_name)
			export_atc_classes(atc_name)
			compress(atc_name)
			if(Date.today.wday==2)
				export_fachinfos(fi_name)
				compress(fi_name)
			end
			if(Date.today.wday==3)
				export_patinfos(pi_name)
				compress(pi_name)
			end
		end
		def export(name='oddb.yaml')
			export_obj(name, @app.companies)
		end
		def export_array(name, array)
			Dir.chdir(EXPORT_DIR)
			File.open(name, 'w') { |fh|
				array.each { |item|
					fh << item.to_yaml << "\n"
					#YAML.dump(item, fh)
					#fh << "\n\n"
				}
			}
		end
=begin
		def export_companies
			yaml_dir = File.expand_path('yaml', EXPORT_DIR)
			Dir.mkdir_r(yaml_dir) unless File.exist?(yaml_dir)
			@app.companies.each_value { |comp|
				export_obj("yaml/#{comp.name.gsub(/\s*/, '_')}.yaml", comp)
			}
		end
=end
		def export_atc_classes(name='atc.yaml')
			export_array(name, @app.atc_classes.values.sort_by { |atc| atc.code.to_s })
		end
		def export_fachinfos(name='fachinfo.yaml')
			export_array(name, @app.fachinfos.values)
		end
		def export_obj(name, obj)
			Dir.chdir(EXPORT_DIR)
			File.open(name, 'w') { |fh|
				fh << obj.to_yaml
				#YAML.dump(obj, fh)
			}
		end
		def export_patinfos(name='patinfo.yaml')
			export_array(name, @app.patinfos.values)
		end
		def compress(name)
			Dir.chdir(EXPORT_DIR)
			begin
				gzwriter = 	Zlib::GzipWriter.open(name+'.gz')
				zipwriter = Zip::ZipOutputStream.open(name+'.zip')
				zipwriter.put_next_entry(name)
				File.open(name, "r") { |fh|
					fh.each { |line|
						gzwriter << line
						zipwriter.puts(line)
					}
				}
			rescue
			ensure
				gzwriter.close unless gzwriter.nil?
				zipwriter.close unless zipwriter.nil?
			end
		end
	end
end
