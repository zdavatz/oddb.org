#!/usr/bin/env ruby
# TestVaccinePlugin -- ydpm -- 22.03.2005 -- hwyss@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))
$: << File.expand_path('..', File.dirname(__FILE__))

require 'test/unit'
require 'rubygems'
require 'flexmock'
require 'plugin/vaccines'
require 'stub/odba'

module ODBA
	def ODBA.transaction(&block)
		block.call
	end
end
module ODDB
	class VaccinePlugin
		MEDDATA_SERVER = FlexMock.new
	end
	class TestVaccinePlugin < Test::Unit::TestCase
		class EncodedString < String
			def to_s(target_encoding)
				super()
			end
		end
		def setup
			@app = FlexMock.new
			@plugin = VaccinePlugin.new(@app)
			@meddata = VaccinePlugin::MEDDATA_SERVER
		end
		def test_extract_latest_filepath
			path = File.expand_path('../data/html/swissmedic/index.html',
															File.dirname(__FILE__))
			html = File.read(path)
			assert_equal('/files/pdf/B3.1.35-d.xls', 
									 @plugin.extract_latest_filepath(html))
		end
		def test_parse_worksheet_row_empty
			row = []
			assert_nil(@plugin.parse_worksheet_row(row))
		end
		def test_parse_worksheet_row_1
			row = [nil, EncodedString.new('Legende')]
			assert_nil(@plugin.parse_worksheet_row(row))
		end
		def test_parse_worksheet_row_2
			row = [nil, EncodedString.new('* Art. 17 HMG  -  Behördliche Chargenfreigabe erforderlich (Auskunft Tel. 031 324 88 20/Impfstoffe oder 031 324 90 35/Blutprodukte)')]
			assert_nil(@plugin.parse_worksheet_row(row))
		end
		def test_parse_worksheet_row_7
			row = [EncodedString.new('Handelsname'), EncodedString.new('Zul.-Nr.')]
			assert_nil(@plugin.parse_worksheet_row(row))
		end
		def test_parse_worksheet_row_8
			indication = EncodedString.new('Wiederherstellung und Erhaltung des Kreislaufvolumens, wenn ein Volumendefizit festgestellt wurde und die Verwendung eines Kolloids angezeigt ist')
			row = [
				EncodedString.new('Albumin Human Octapharma 20%'), 
				EncodedString.new('55536'), indication, EncodedString.new('B'),
				EncodedString.new('x'), EncodedString.new('x'), EncodedString.new('x'),
				EncodedString.new(''), EncodedString.new(''),
				EncodedString.new('Octapharma AG') 
			]
			reg, seq = @plugin.parse_worksheet_row(row)
			assert_instance_of(VaccinePlugin::ParsedRegistration, reg)
			assert_equal('55536', reg.iksnr)
			assert_equal('B', reg.ikscat)
			assert_equal(indication, reg.indication)
			assert_equal('Octapharma AG', reg.company)
			assert_instance_of(VaccinePlugin::ParsedSequence, seq)
			assert_equal('Albumin Human Octapharma 20%', seq.name)
			assert_equal(Dose.new(20, '%'), seq.dose)
		end
		def test_parse_worksheet
			indication = EncodedString.new('Wiederherstellung und Erhaltung des Kreislaufvolumens, wenn ein Volumendefizit festgestellt wurde und die Verwendung eines Kolloids angezeigt ist')
			sheet = [
				[ EncodedString.new('Albumin Human Octapharma 20%'),
					EncodedString.new('55536'), indication, EncodedString.new('B'),
					EncodedString.new('x'), EncodedString.new('x'),
					EncodedString.new('x'), EncodedString.new(''), EncodedString.new(''),
					EncodedString.new('Octapharma AG') ],
				[ EncodedString.new('Albumin Human Octapharma 5%'),
					EncodedString.new('55536'), indication, EncodedString.new('B'),
					EncodedString.new('x'), EncodedString.new('x'),
					EncodedString.new('x'), EncodedString.new(''), EncodedString.new(''),
					EncodedString.new('Octapharma AG') ],
			]
			regs = @plugin.parse_worksheet(sheet)
			assert_equal(1, regs.size)
			assert_equal(['55536'], regs.keys)
			reg = regs['55536']
			assert_equal(2, reg.sequences.size)
		end
		def test_parse_refdata_detail
			refdata = "7680555360120ALBUMIN HUMAN Octapharma Inf Lös 20 % Fl 100 ml"
			pack = @plugin.parse_refdata_detail(refdata)
			assert_instance_of(VaccinePlugin::ParsedPackage, pack)
			assert_equal('012', pack.ikscd)
			assert_equal(Dose.new(100 ,'ml'), pack.size)
			assert_equal(Dose.new(20, '%'), pack.dose)
		end
		def test_parse_refdata_detail_mcg
			refdata = "7680536090152RHOPHYLAC Inj Lös 200 mcg Fertigspr 2 ml"
			pack = @plugin.parse_refdata_detail(refdata)
			assert_instance_of(VaccinePlugin::ParsedPackage, pack)
			assert_equal('015', pack.ikscd)
			assert_equal(Dose.new(2, 'ml'), pack.size)
			assert_equal(Dose.new(200 ,'mcg'), pack.dose)
		end
		def test_parse_refdata_detail_10x
			refdata = "7680006400023INFANRIX HEXA Inj Lös 10 Fertigspr 1 Dos"
			pack = @plugin.parse_refdata_detail(refdata)
			assert_instance_of(VaccinePlugin::ParsedPackage, pack)
			assert_equal('002', pack.ikscd)
			assert_equal(Dose.new(10, 'Fertigspr'), pack.size)
			assert_equal('10 x 1 Dos', pack.sizestring)
		end
		def test_parse_refdata_detail_10x__2
			refdata = "7680524760623ALBUMIN ZLB Inf Lös 5 % 10 x 250 ml"
			pack = @plugin.parse_refdata_detail(refdata)
			assert_instance_of(VaccinePlugin::ParsedPackage, pack)
			assert_equal('062', pack.ikscd)
			assert_equal(Dose.new(5, '%'), pack.dose)
			assert_equal('10 x 250 ml', pack.sizestring)
			assert_equal(Dose.new(2500, 'ml'), pack.size)
		end
		def test_parse_refdata_detail_tachosil_1
			refdata = "7680006700178TACHOSIL Schwamm 3x2.5cm"
			pack = @plugin.parse_refdata_detail(refdata)
			assert_instance_of(VaccinePlugin::ParsedPackage, pack)
			assert_equal('017', pack.ikscd)
			assert_equal('3x2.5cm', pack.sizestring)
		end
		def test_parse_refdata_detail_tachosil_2
			refdata = "7680006701168TACHOSIL Schwamm 4.8x4.8cm 2 Stk"
			pack = @plugin.parse_refdata_detail(refdata)
			assert_instance_of(VaccinePlugin::ParsedPackage, pack)
			assert_equal('116', pack.ikscd)
			assert_equal('2 x 4.8x4.8cm', pack.sizestring)
		end
		def test_get_packages__1_on_1
			reg = FlexMock.new
			reg.mock_handle(:iksnr) { 'iksnr' }
			seq = VaccinePlugin::ParsedSequence.new
			seqs = [seq]
			@meddata.mock_handle(:search) { 
				['result']
			}
			@meddata.mock_handle(:detail) { 
				{:info => "7680536090152RHOPHYLAC Inj Lös 200 mcg Fertigspr 2 ml"}
			}
			reg.mock_handle(:sequences) { seqs }
			@plugin.get_packages(reg)
			assert_equal([seq], seqs)
			assert_equal(['015'], seq.packages.keys)
		end
		def test_get_packages__no_dose
			reg = FlexMock.new
			reg.mock_handle(:iksnr) { 'iksnr' }
			seq = VaccinePlugin::ParsedSequence.new
			seqs = [seq]
			@meddata.mock_handle(:search) { 
				['result1', 'result2', 'result3']
			}
			details = [
				{:info => "7680004640056ENDOBULIN S/D Trockensub c Solv Stechamp 10 g"},
				{:info => "7680004640032ENDOBULIN S/D Trockensub c Solv Stechamp 2.5 g"},
				{:info => "7680004640049ENDOBULIN S/D Trockensub c Solv Stechamp 5 g"},
			]
			@meddata.mock_handle(:detail) { 
				details.shift
			}
			reg.mock_handle(:sequences) { seqs }
			@plugin.get_packages(reg)
			assert_equal([seq], seqs)
			assert_equal(['003', '004', '005'], seq.packages.keys.sort)
		end
		def test_get_packages__different_doses
			reg = FlexMock.new
			reg.mock_handle(:iksnr) { 'iksnr' }
			seq = VaccinePlugin::ParsedSequence.new
			seqs = [seq]
			@meddata.mock_handle(:search) { 
				['result1', 'result2']
			}
			details = [
				{:info => "7680548090263BERININ HS FAKTOR IX Trockensub 1200 IE c sol Amp"},
				{:info => "7680548090188BERININ HS FAKTOR IX Trockensub 600 IE c solv Amp"},
			]
			@meddata.mock_handle(:detail) { 
				details.shift
			}
			reg.mock_handle(:sequences) { seqs }
			@plugin.get_packages(reg)
			assert_equal(2, seqs.size)
			assert_equal(['026'], seq.packages.keys)
			assert_equal(Dose.new(1200, 'IE'), seq.dose)
			assert_equal(['018'], seqs.last.packages.keys)
			assert_equal(Dose.new(600, 'IE'), seqs.last.dose)
		end
		def test_get_packages__more_different_doses
			reg = FlexMock.new
			reg.mock_handle(:iksnr) { 'iksnr' }
			seq = VaccinePlugin::ParsedSequence.new
			seqs = [seq]
			@meddata.mock_handle(:search) { 
				['result1', 'result2', 'result3']
			}
			details = [
				{:info => "7680006660038OCTANATE Trockensub 1000 IE c Solv Fl 10 ml"},
				{:info => "7680006660014OCTANATE Trockensub 250 IE c Solv Fl 5 ml"},
				{:info => "7680006660021OCTANATE Trockensub 500 IE c Solv Fl 10 ml"},
			]
			@meddata.mock_handle(:detail) { 
				details.shift
			}
			reg.mock_handle(:sequences) { seqs }
			@plugin.get_packages(reg)
			assert_equal(3, seqs.size)
		end
	end
end
