#!/usr/bin/env ruby
# YAML -- oddb -- 09.12.2004 -- hwyss@ywesee.com

require 'psych'

class Time
  def to_yaml_properties
    []
  end
end
class String
  ## prevent String from exporting _rails_html_safe
  def to_yaml_properties
    []
  end
end
class Module
  def yaml_as tag, sc = true
    Psych.dump_tags.store self, tag
  end
end
module Psych
  module Visitors
    class YAMLTree
      alias :odba_accept :accept
      def accept o
        odba_accept o.odba_instance
      end
      alias :odba_visit_Object :visit_Object
      def visit_Object o
        odba_visit_Object o.odba_instance
      end
      def visit_String o
        plain = false
        quote = false

        if o.index("\x00") || o.count("^ -~\t\r\n").fdiv(o.length) > 0.3
          str   = [o].pack('m').chomp
          tag   = '!binary'
        else
          str   = o
          tag   = nil
          begin
            quote = !(String === @ss.tokenize(o))
          rescue ArgumentError => e
            quote = true
          end
          plain = !quote
        end

        ivars = o.respond_to?(:to_yaml_properties) ?
          o.to_yaml_properties :
          o.instance_variables

        scalar = Nodes::Scalar.new str, nil, tag, plain, quote

        if ivars.empty?
          append scalar
        else
          mapping = append Nodes::Mapping.new(nil, '!str', false)

          mapping.children << Nodes::Scalar.new('str')
          mapping.children << scalar

          @stack.push mapping
          dump_ivars o, mapping
          @stack.pop
        end
      end
      alias :odba_visit_Array :visit_Array
      def visit_Array o
        odba_visit_Array o.odba_instance
      end
      alias :odba_visit_Hash :visit_Hash
      def visit_Hash o
        odba_visit_Hash o.odba_instance
      end
      alias :odba_dump_ivars :dump_ivars
      def dump_ivars target, map
        target = target.odba_instance
        odba_dump_ivars target, map
        if target.respond_to?(:custom_yaml_properties)
          target.custom_yaml_properties.each do |iv, value|
            unless value.nil?
              map.children << Nodes::Scalar.new(iv.to_s)
              accept value
            end
          end
        end
      end
    end
  end
end
module ODDB
	module OddbYaml
		YAML_URI = '!oddb.org,2003'
		EXPORT_PROPERTIES = []
    def to_yaml_properties
      self::class::EXPORT_PROPERTIES.reject do |name|
        instance_variable_get(name).nil?
      end
    end
    def self.append_features mod
      Psych.dump_tags.store mod, "#{YAML_URI}/#{mod}"
      super
    end
  end		
	module SimpleLanguage
		class Descriptions #< Hash
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
  module Interaction
    class AbstractLink
      include OddbYaml
      EXPORT_PROPERTIES = [
        '@info',
        '@href',
        '@text',
      ]
   end
  end
	class ActiveAgent #< ActiveAgentCommon
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
  class CommercialForm
    include OddbYaml
    EXPORT_PROPERTIES = [
      '@oid',
      '@descriptions',
    ]
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
  class Composition
    include OddbYaml
    EXPORT_PROPERTIES = [
      '@galenic_form', '@active_agents'
    ]
  end
  class CyP450
    include OddbYaml
    EXPORT_PROPERTIES = [
      '@cyp_id',
    ]
    def custom_yaml_properties
      { :inhibitors => self.inhibitors.values,
        :inducers   => self.inducers.values }
    end
 end
  class CyP450Connection
    include OddbYaml
  end
  class CyP450SubstrateConnection
    EXPORT_PROPERTIES = [
      '@oid',
      '@cyp450',
      '@category',
      '@links',
      '@substance',
    ]
  end
  class CyP450InteractionConnection
    EXPORT_PROPERTIES = [
      '@oid',
      #'@cyp450', # some parsers don't like circular references
      '@category',
      '@links',
      '@substance',
      '@auc_factor',
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
	class Dose #< Quanty
		include OddbYaml
		EXPORT_PROPERTIES = [
			'@not_normalized',
			'@val',
			'@unit',
		]
    def custom_yaml_properties
      { :scale => self.scale }
    end
	end	
	class Ean13 < String
    def self.yaml_tag_subclasses?
			false
		end
	end
	class Fachinfo
		include OddbYaml
		EXPORT_PROPERTIES = [
			'@oid',
			'@descriptions',
		]
    def custom_yaml_properties
      { :article_codes => self.article_codes }
    end
	end
	class FachinfoDocument
		include OddbYaml
		EXPORT_PROPERTIES = [
      '@name',
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
      '@name',
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
			'@substances',
		]
    def custom_yaml_properties
      { :casrn    => casrn,
        :packages => @packages.collect { |pac| pac.ikskey } }
    end
	end
	class Package #< PackageCommon
		include OddbYaml
		EXPORT_PROPERTIES = [	
			'@ikscd',
			'@lppv',
			'@descr',
			'@ikscat',
			'@sl_entry',
      '@parts',
		]
    def custom_yaml_properties
      if Thread.current[:export_prices]
        { :iksnr        => self.iksnr,
          :name         => self.name,
          :size         => self.size,
          :ean13        => self.barcode.to_s,
          :pharmacode   => self.pharmacode,
          :out_of_trade => !self.public?,
          :prices       => self.prices }

      else
        deductibles = {'deductible_g' => 10, 'deductible_o' => 20 }
        { :has_generic     => self.has_generic?,
          :ean13           => self.barcode.to_s,
          :price_exfactory => self.price_exfactory.to_f,
          :price_public    => self.price_public.to_f,
          :pharmacode      => self.pharmacode,
          :narcotics       => @narcotics.collect { |narc| narc.casrn},
          :deductible      => deductibles[self.deductible.to_s] }
      end
    end
	end
  class Part
    include OddbYaml
    EXPORT_PROPERTIES = [
      '@measure', '@addition', '@commercial_form', '@composition',
    ]
    def custom_yaml_properties
      { :count => self.count || 1,
        :multi => self.multi || 1 }
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
	class Registration #< RegistrationCommon
		include OddbYaml
		EXPORT_PROPERTIES = [
			'@iksnr',
			'@registration_date',
			'@revision_date',
			'@expiration_date',
			'@inactive_date',
			'@sequences',
			'@indication',
			'@export_flag',
		]
    def custom_yaml_properties
      custom = {
        :generic_type => self.generic_type,
        :complementary_type => self.complementary_type
      }
      if @fachinfo
        custom.store :fachinfo_oid, @fachinfo.oid
      end
      custom
    end
	end
	class Sequence #< SequenceCommon
		include OddbYaml
		EXPORT_PROPERTIES = [
			'@seqnr',
			'@name_base',
			'@name_descr',
			'@atc_class',
			'@composition_text',
      '@compositions',
			'@packages',
		]
	end
	class SlEntry
		include OddbYaml
		EXPORT_PROPERTIES = [
      '@bsv_dossier',
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
			'@swissmedic_code',
		]
    def custom_yaml_properties
      custom = { :effective_form => nil }
      if @narcotic
        custom.store :narcotic, @narcotic.casrn
      end
      if @effective_form && @effective_form != self
        custom.store :effective_form, @effective_form
      end
      custom
    end
	end
  module Util
    class Money
      include OddbYaml
      EXPORT_PROPERTIES = [
        '@amount',
        '@authority',
        '@origin',
        '@type',
        '@valid_from',
      ]
    end
  end
end
