#!/usr/bin/env ruby
# TestOuwerkerkPlugin -- oddb -- 18.06.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'plugin/ouwerkerk'
require 'model/atcclass'
require 'model/galenicform'
require 'model/indication'

module ODDB
	class OuwerkerkPlugin < Plugin
		attr_accessor :file_path, :smj, :bsv
		ARCHIVE_PATH = File.expand_path('../data', File.dirname(__FILE__))
	end
end

class TestOuwerkerkPlugin < Test::Unit::TestCase
	class StubApp
		attr_accessor :log_groups
		def log_group(key)
			(@log_groups ||= {})[key]
		end
	end
	class StubPackage
		attr_accessor :pointer, :ikscat, :price_exfactory, :price_public, :size, :ikscd, :sl_entry
	end
	class StubSequence
		attr_accessor :seqnr, :packages, :name, :dose, :active_agents, :galenic_form
		attr_accessor :composition_text, :atc_class
	end
	class StubRegistration
		attr_accessor :iksnr, :export_flag, :indication, :company, :sequences
	end
	class StubDose
		attr_reader :qty, :unit
		def initialize(qty, unit)
			@qty, @unit = qty, unit
		end
	end
	class StubCompany
		attr_reader :name, :url
		def initialize(name, url)
			@name, @url = name, url
		end
	end
	class StubLogGroup
		attr_accessor :change_flags, :date
		def initialize
			@change_flags = {}
		end
		def latest
			self
		end
	end
	class StubPointer
		attr_writer :reg
		def resolve(*args)
			@reg
		end
		def parent
			self
		end
	end

	def setup
		@app = StubApp.new
		@plugin = ODDB::OuwerkerkPlugin.new(@app)
		@atc_class = ODDB::AtcClass.new('A01BC23')
		@galform = ODDB::GalenicForm.new
		@galform.update_values({:fr => 'Tabletten'})
		@indication = ODDB::Indication.new
		@indication.update_values({:de => 'Placebo'})
	end
	def teardown
		if(File.exists? @plugin.file_path)
			File.delete(@plugin.file_path)
			Dir.delete(File.dirname(@plugin.file_path))
		end
	end
	def test_log_info
		log = StubLogGroup.new
		log.date = Date.today
		@plugin.smj = log
		info = @plugin.log_info
		[:files, :report, :change_flags, :recipients, :date_str].each { |key|
			assert(info.include?(key), "Missing '#{key}' in Log-Info")
		}
	end
	def test_export_package
		pointer = ODDB::Persistence::Pointer.new([:reg, 1],[:seq, 2],[:pac, 3])
		pack = StubPackage.new
		pack.pointer = pointer
		pack.ikscd = '032'
		pack.ikscat = 'A'
		pack.size = "100 Tabletten"
		pack.price_exfactory = 1234
		pack.price_public = 5678
		flags = [:new]
		row = @plugin.export_package(pack, [flags], {pointer.to_s => [:price]})
		expected = [
			[1,11], nil, '032', nil, nil, nil, nil, nil, nil, nil, 'A', nil, 
			nil, "100 Tabletten", nil, nil, 12.34, 56.78, nil, nil, nil, nil, 
			nil, nil, 'keine'
		]
		assert_equal(expected, row)
		pack.sl_entry = Object.new
		row = @plugin.export_package(pack, [flags], {pointer.to_s => [:price]})
		expected = [
			[1,11], nil, '032', nil, nil, nil, nil, nil, nil, nil, 'A', nil, 
			nil, "100 Tabletten", nil, nil, 12.34, 56.78, nil, nil, nil, nil, 
			nil, nil, 'SL'
		]
		assert_equal(expected, row)
	end
	def test_export_sequence
		pack1 = StubPackage.new
		pack1.pointer = :foo
		pack1.ikscd = '032'
		pack1.ikscat = 'A'
		pack1.size = "100 Tabletten"
		pack1.price_exfactory = 1234
		pack1.price_public = 5678
		pack2 = StubPackage.new
		pack2.pointer = :bar
		pack2.ikscd = '064'
		pack2.ikscat = 'B'
		pack2.size = "200 Kapseln"
		pack2.price_exfactory = 4321
		pack2.price_public = 8765
		seq = StubSequence.new
		seq.packages = {'032'	=>	pack1, '064' => pack2}
		seq.seqnr = '01'
		seq.galenic_form = @galform
		seq.name = 'Ponstan, Tabletten'
		seq.dose = StubDose.new(150, 'mg')
		seq.active_agents = [:foo, :bar, :baz]
		seq.atc_class = @atc_class
		flags = [:productname, :address]
		rows = @plugin.export_sequence(seq, [flags], {'foo' => [:price]})
		expected = [
			[
				[3,4,11], nil, '032', '01', 'Ponstan, Tabletten', nil, nil, nil, 
				150, 'mg', 'A', 3, nil, "100 Tabletten", "Tabletten", nil, 
				12.34, 56.78, nil, nil, nil, 'A01BC23', nil, nil, 'keine'
			],
			[
				[3,4], nil, '064', '01', 'Ponstan, Tabletten', nil, nil, nil, 
				150, 'mg', 'B', 3, nil, "200 Kapseln", "Tabletten", nil, 43.21, 87.65,
				nil, nil, nil, 'A01BC23', nil, nil, 'keine'
			],
		]
		assert([expected, expected.reverse].include?(rows), 
			"expected\n<#{expected.inspect}>\nbut was\n<#{rows.inspect}>")
	end
	def test_export_registration
		pack1 = StubPackage.new
		pack1.pointer = :foo
		pack1.ikscd = '032'
		pack1.ikscat = 'A'
		pack1.size = "100 Tabletten"
		pack1.price_exfactory = 1234
		pack1.price_public = 5678
		pack2 = StubPackage.new
		pack2.pointer = :bar
		pack2.ikscd = '064'
		pack2.ikscat = 'B'
		pack2.size = "200 Kapseln"
		pack2.price_exfactory = 4321
		pack2.price_public = 8765
		seq = StubSequence.new
		seq.packages = {'032'	=>	pack1, '064' => pack2}
		seq.galenic_form = @galform
		seq.seqnr = '01'
		seq.name = 'Ponstan, Tabletten'
		seq.dose = StubDose.new(150, 'mg')
		seq.active_agents = [:foo, :bar, :baz]
		seq.atc_class = @atc_class
		reg = StubRegistration.new
		reg.sequences = {'01' => seq}
		reg.iksnr = '98765'
		reg.indication = @indication
		reg.export_flag = 'Export'
		reg.company = StubCompany.new('Pfizer', 'www.pfizer.ch')
		flags = [:productname, :address]
		rows = @plugin.export_registration(reg, [flags], {'foo' => [:price]})
		expected = [
			[
				[3,4,11], '98765', '032', '01', 'Ponstan, Tabletten', nil, 'Placebo', 
				'Export', 150, 'mg', 'A', 3, 'Pfizer', "100 Tabletten", "Tabletten", 
				nil, 12.34, 56.78, nil, 'www.pfizer.ch', nil, 'A01BC23', nil, nil, 'keine'
			],
			[
				[3,4], '98765', '064', '01', 'Ponstan, Tabletten', nil, 'Placebo', 
				'Export', 150, 'mg', 'B', 3, 'Pfizer', "200 Kapseln", "Tabletten", 
				nil, 43.21, 87.65, nil, 'www.pfizer.ch', nil, 'A01BC23', nil, nil, 'keine'
			],
		]
		assert([expected, expected.reverse].include?(rows), 
			"expected\n<#{expected.inspect}>\nbut was\n<#{rows.inspect}>")
	end
	def test_export_registrations
		# Combine Swissmedic and BSV Updates but only Packages from BSV
		pack1 = StubPackage.new
		pack1.pointer = :foo
		pack1.ikscd = '032'
		pack1.ikscat = 'A'
		pack1.size = "100 Tabletten"
		pack1.price_exfactory = 1234
		pack1.price_public = 5678
		pack2 = StubPackage.new
		pack2.pointer = :bar
		pack2.ikscd = '064'
		pack2.ikscat = 'B'
		pack2.size = "200 Kapseln"
		pack2.price_exfactory = 4321
		pack2.price_public = 8765
		seq = StubSequence.new
		seq.packages = {'032'	=>	pack1, '064' => pack2}
		seq.galenic_form = @galform
		seq.seqnr = '01'
		seq.name = 'Ponstan, Tabletten'
		seq.dose = StubDose.new(150, 'mg')
		seq.active_agents = [:foo, :bar, :baz]
		seq.atc_class = @atc_class
		reg = StubRegistration.new
		reg.sequences = {'01' => seq}
		reg.iksnr = '98765'
		reg.indication = @indication
		reg.export_flag = 'Export'
		reg.company = StubCompany.new('Pfizer', 'www.pfizer.ch')
		log = StubLogGroup.new
		pointer = StubPointer.new
		pointer.reg = reg
		flags = [:productname, :address]
		log.change_flags = {pointer => flags}
		pack3 = StubPackage.new
		pack3.ikscd = '007'
		pack3.ikscat = 'C'
		pack3.size = "7 cl"
		pack3.price_exfactory = 700 
		pack3.price_public = 7000
		pack4 = StubPackage.new
		seq2 = StubSequence.new
		seq2.packages = {'007'	=>	pack3, '008' => pack4}
		seq2.galenic_form = @galform
		seq2.seqnr = '02'
		seq2.name = 'Vodka Martini Dry, shaken - not stirred'
		seq2.dose = StubDose.new(7, 'cl')
		seq2.active_agents = ['Vodka', 'Vermouth', 'Lemon Zest']
		seq2.atc_class = @atc_class
		reg2 = StubRegistration.new
		reg2.sequences = {'02' => seq2}
		reg2.iksnr = '12007'
		reg2.indication = @indication
		reg2.export_flag = nil
		reg2.company = StubCompany.new('Her Majesty\'s Secret Service', nil)
		bsv = StubLogGroup.new
		bsv_pointer = StubPointer.new
		pack3.pointer = bsv_pointer
		bsv_pointer.reg = reg2
		flags = [:price]
		bsv.change_flags = {bsv_pointer => flags}
		@app.log_groups = {
			:swissmedic_journal	=>	log, 
			:bsv_sl => bsv,
		}
		rows = @plugin.export_registrations
		expected = [
			[ "3,4", "98765", "032", "01", "Ponstan, Tabletten", nil, "Placebo",
				"Export", 150, "mg", "A", 3, "Pfizer", "100 Tabletten", "Tabletten",
				nil, 12.34, 56.78, nil, "www.pfizer.ch", nil, "A01BC23", nil, nil, 'keine' ], 
			[ "3,4", "98765", "064", "01", "Ponstan, Tabletten", nil, "Placebo",
				"Export", 150, "mg", "B", 3, "Pfizer", "200 Kapseln", "Tabletten", 
				nil, 43.21, 87.65, nil, "www.pfizer.ch", nil, "A01BC23", nil, nil, 'keine'], 
			[ "11", "12007", "007", "02", "Vodka Martini Dry, shaken - not stirred",
				nil, "Placebo", nil, 7, "cl", "C", 3, "Her Majesty's Secret Service", 
				"7 cl", "Tabletten", nil, 7.00, 70.00, nil, nil, nil, "A01BC23", nil, nil, 'keine'], 
		]
		assert_equal(expected.sort, rows.sort)
	end
	def test_export_xls
		pack1 = StubPackage.new
		pack1.pointer = :foo
		pack1.ikscd = '032'
		pack1.ikscat = 'A'
		pack1.size = "100 Tabletten"
		pack1.price_exfactory = 1234
		pack1.price_public = 5678
		pack2 = StubPackage.new
		pack2.pointer = :bar
		pack2.ikscd = '064'
		pack2.ikscat = 'B'
		pack2.size = "200 Kapseln"
		pack2.price_exfactory = 4321
		pack2.price_public = 8765
		seq = StubSequence.new
		seq.packages = {'032'	=>	pack1, '064' => pack2}
		seq.galenic_form = @galform
		seq.seqnr = '01'
		seq.name = 'Ponstan, Tabletten'
		seq.dose = StubDose.new(150, 'mg')
		seq.active_agents = [:foo, :bar, :baz]
		seq.atc_class = @atc_class
		reg = StubRegistration.new
		reg.sequences = {'01' => seq}
		reg.iksnr = '98765'
		reg.indication = @indication
		reg.export_flag = 'Export'
		reg.company = StubCompany.new('Pfizer', 'www.pfizer.ch')
		log = StubLogGroup.new
		pointer = StubPointer.new
		pointer.reg = reg
		flags = [:productname, :address]
		log.change_flags = {pointer => flags}
		log.date = Date.today
		bsvlog = StubLogGroup.new
		bsvlog.date = Date.today
		@app.log_groups = {
			:swissmedic_journal	=>	log, 
			:bsv_sl => bsvlog,
		}
		@plugin.export_xls
		assert(File.exists?(File.dirname(@plugin.file_path)))
		assert(File.exists?(@plugin.file_path))
	end
end
