#!/usr/bin/env ruby
# TestYamlPlugin -- oddb -- 02.09.2003 -- rwaltert@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'plugin/yaml'

module ODDB
	class YamlExporter < Plugin
		remove_const :EXPORT_DIR
		EXPORT_DIR = File.expand_path('../data/export', File.dirname(__FILE__))
	end
end

class TestYamlPlugin < Test::Unit::TestCase
	def test_active_agent_to_yaml
		agent = ODDB::ActiveAgent.new('Acidum Acetylsalicylicum')
		assert_equal('!oddb.org,2003/ODDB::ActiveAgent', agent.to_yaml_type)
		exported_properties = [
			'@substance',
			'@dose',
		]
		assert_equal(exported_properties, agent.to_yaml_properties)
	end
	def test_atc_class_to_yaml
		atc_class = ODDB::AtcClass.new('a01ab02')
		assert_equal('!oddb.org,2003/ODDB::AtcClass', atc_class.to_yaml_type)
		exported_properties = [
			'@code',
			'@descriptions',
			'@guidelines',
			'@ddd_guidelines',
			'@ddds',
		]
		assert_equal(exported_properties, atc_class.to_yaml_properties)
	end
	def test_atc_ddd_to_yaml
		ddd = ODDB::AtcClass::DDD.new('O')
		assert_equal('!oddb.org,2003/ODDB::AtcClass::DDD', ddd.to_yaml_type)
		exported_properties = [
			'@administration_route',
			'@dose',
			'@note',
		]
		assert_equal(exported_properties, ddd.to_yaml_properties)
	end
	def test_company_to_yaml
		company = ODDB::Company.new
		assert_equal('!oddb.org,2003/ODDB::Company', company.to_yaml_type)
		exported_properties = [
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
		assert_equal(exported_properties, company.to_yaml_properties)
	end
	def test_description_to_yaml
		description = ODDB::SimpleLanguage::Descriptions.new
		description.store('de', 'Foo')
		assert_equal('!oddb.org,2003/ODDB::SimpleLanguage::Descriptions', description.to_yaml_type)
	end
	def test_dose_to_yaml
		dose = ODDB::Dose.new(1, 'mg / 2 ml')
		assert_equal('!oddb.org,2003/ODDB::Dose', dose.to_yaml_type)
		exported_properties = [
			'@val',
			'@unit',
		]
		assert_equal(exported_properties, dose.to_yaml_properties)

	end	
	def test_fachinfo
		fi = ODDB::Fachinfo.new
		assert_equal('!oddb.org,2003/ODDB::Fachinfo', fi.to_yaml_type)
		exported_properties = [
			'@oid',
			'@descriptions',
		]
		assert_equal(exported_properties, fi.to_yaml_properties)
	end	
	def test_galenic_form_to_yaml
		galenic_form = ODDB::GalenicForm.new
		assert_equal('!oddb.org,2003/ODDB::GalenicForm', galenic_form.to_yaml_type)
		exported_properties = [
			'@oid',
			'@descriptions',
			'@galenic_group',
		]
		assert_equal(exported_properties, galenic_form.to_yaml_properties)
	end	
	def test_galenic_group_to_yaml
		galenic_group = ODDB::GalenicGroup.new
		assert_equal('!oddb.org,2003/ODDB::GalenicGroup', galenic_group.to_yaml_type)
		exported_properties = [
			'@oid',
			'@descriptions',
		]
		assert_equal(exported_properties, galenic_group.to_yaml_properties)
	end	
	def test_indication_to_yaml
		indication = ODDB::Indication.new
		assert_equal('!oddb.org,2003/ODDB::Indication', indication.to_yaml_type)
		exported_properties = [
			'@oid',
			'@descriptions',
		]
		assert_equal(exported_properties, indication.to_yaml_properties)
	end	
	def test_limitation_text_to_yaml
		lim_txt = ODDB::LimitationText.new
		assert_equal('!oddb.org,2003/ODDB::LimitationText', lim_txt.to_yaml_type)
		exported_properties = [
			'@descriptions',
		]
		assert_equal(exported_properties, lim_txt.to_yaml_properties)
	end	
	def test_package_to_yaml
		package = ODDB::Package.new('')
		assert_equal('!oddb.org,2003/ODDB::Package', package.to_yaml_type)
		exported_properties = [
			'@ikscd',
			'@size',
			'@descr',
			'@ikscat',
			'@price_exfactory',
			'@price_public',
			'@sl_entry',
		]
		assert_equal(exported_properties, package.to_yaml_properties)
	end
	class StubPackage < ODDB::Package
		attr_accessor :iksnr, :ikscd
		def barcode
			['7680', iksnr, ikscd, '1'].join
		end
	end
	def test_package_to_yaml__ean13
		package = StubPackage.new('007')
		package.iksnr = '12345'
		package.pharmacode = '11223'
		expected = <<-EOS
--- !oddb.org,2003/TestYamlPlugin::StubPackage 
ikscd: "007"
size: 
descr: 
ikscat: 
price_exfactory: 
price_public: 
sl_entry: 
ean13: "7680123450071"
pharmacode: "11223"
		EOS
		assert_equal(expected.strip, package.to_yaml)
	end
	def test_registration_to_yaml
		registration = ODDB::Registration.new('12345')
		assert_equal('!oddb.org,2003/ODDB::Registration', registration.to_yaml_type)
		exported_properties = [
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
		assert_equal(exported_properties, registration.to_yaml_properties)
	end
	def test_sequence_to_yaml
		sequence = ODDB::Sequence.new('01')
		assert_equal('!oddb.org,2003/ODDB::Sequence', sequence.to_yaml_type)
		exported_properties = [
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
		assert_equal(exported_properties, sequence.to_yaml_properties)
	end	
	def test_sl_entry_to_yaml
		sl_entry = ODDB::SlEntry.new
		assert_equal('!oddb.org,2003/ODDB::SlEntry', sl_entry.to_yaml_type)
		exported_properties = [
			'@introduction_date',
			'@limitation',
			'@limitation_points',
			'@limitation_text',
		]
		assert_equal(exported_properties, sl_entry.to_yaml_properties)
	end	
	def test_substance_to_yaml
		substance = ODDB::Substance.new('Levomentholum')
		assert_equal('!oddb.org,2003/ODDB::Substance', substance.to_yaml_type)
		exported_properties = [
			'@oid',
			'@name',
		]
		assert_equal(exported_properties, substance.to_yaml_properties)
	end	
	def test_compress
		dir = File.expand_path('../data/export', File.dirname(__FILE__))
		file = File.expand_path('oddb.yaml', dir)
		expected = [
			file + '.gz',
			file + '.zip',
		]
		expected.each { |path|
			File.delete(path) if File.exist?(path)
		}
		footext = "---\n  many Companies!\n"
		File.open(file, 'w') { |fh|
			fh << footext
		}
		plugin = ODDB::YamlExporter.new(nil)
		plugin.compress('oddb.yaml')
		expected.each { |path|
			assert(File.exist?(path), "missing file: #{path})")
		}
		result = Zlib::GzipReader.open(file + '.gz') { |gz|
			gz.read
		}
		assert_equal(footext, result)
		result = Zip::ZipInputStream.open(file + '.zip') { |is|
			is.get_next_entry
			is.read
		}
		assert_equal(footext, result)
		expected.each { |path|
			File.delete(path) if File.exist?(path)
		}
	end
end
