#!/usr/bin/env ruby
# TestVaccinePlugin -- ydpm -- 22.03.2005 -- hwyss@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))
$: << File.expand_path('..', File.dirname(__FILE__))

require 'test/unit'
require 'rubygems'
require 'flexmock'
require 'plugin/vaccines'

module ODBA
	def ODBA.transaction(&block)
		block.call
	end
end
module ODDB
	class TestVaccinePlugin < Test::Unit::TestCase
		def setup
			@app = FlexMock.new
			@plugin = VaccinePlugin.new(@app)
		end
		def test_parse_smj_line__1
			line = <<-EOL
Albumin Human Octapharma 20%	55536	Wiederherstellung und Erhaltung des Kreislaufvolumens, wenn ein Volumendefizit festgestellt wurde und die Verwendung eines Kolloids angezeigt ist	B	x	x	x			Octapharma AG	
			EOL
			registration, sequence = @plugin.parse_smj_line(line)
			assert_equal("Albumin Human Octapharma 20%", sequence.name)
			assert_equal("55536", registration.iksnr)
			expected = <<-EOS
Wiederherstellung und Erhaltung des Kreislaufvolumens, wenn ein Volumendefizit festgestellt wurde und die Verwendung eines Kolloids angezeigt ist	
			EOS
			assert_equal(expected.strip, registration.indication)
			assert_equal('B', registration.ikscat)
			assert_equal('Octapharma AG', registration.company)
			assert_equal('20%', sequence.dose)
		end
		def test_parse_smj_line__2
			line = <<-EOL
Perenterol 250, Sachets	47572	Prophylaxe und Therapie antibiotikabedingter Diarrhöen	D						Biomed AG	
			EOL
			registration, sequence = @plugin.parse_smj_line(line)
			assert_equal("Perenterol 250, Sachets", sequence.name)
			assert_equal("47572", registration.iksnr)
			expected = <<-EOS
Prophylaxe und Therapie antibiotikabedingter Diarrhöen
			EOS
			assert_equal(expected.strip, registration.indication)
			assert_equal('D', registration.ikscat)
			assert_equal('Biomed AG', registration.company)
			assert_equal('250', sequence.dose)
		end
		def test_dose__3
			sequence = VaccinePlugin::ParsedSequence.new
			sequence.name = "FSME-Immun 0.25 ml Junior"
			assert_equal('0.25 ml', sequence.dose)
		end
		def test_integrate__1
			path = File.expand_path('../data/xls/vaccines.xls', 
				File.dirname(__FILE__))
			regs = @plugin.registrations_from_xls(path)
			reg = regs['55536']
			assert_instance_of(VaccinePlugin::ParsedRegistration, reg)
			assert_equal('55536', reg.iksnr)
			assert_equal('Octapharma AG', reg.company)
			seq = reg.sequences.first
			assert_instance_of(VaccinePlugin::ParsedSequence, seq)
			assert_equal('Albumin Human Octapharma 20%', seq.name)
			assert_equal(1, seq.active_agents.size)
			agent = seq.active_agents.first
			assert_equal('Albumin vom Menschen', agent.substance)
			assert_equal('200.0', agent.dose)
			assert_equal('g', agent.unit)
		end
		def test_integrate__2
			path = File.expand_path('../data/xls/vaccines.xls', 
				File.dirname(__FILE__))
			regs = @plugin.registrations_from_xls(path)
			reg = regs['00332']
			assert_instance_of(VaccinePlugin::ParsedRegistration, reg)
			assert_equal('00332', reg.iksnr)
			assert_equal('Sérolab SA', reg.company)
			seq = reg.sequences.first
			assert_instance_of(VaccinePlugin::ParsedSequence, seq)
			assert_equal('Articulaire / Gelenk', seq.name)
			assert_equal(1, seq.active_agents.size)
			agent = seq.active_agents.first
			expected = <<-EOS
Globulines équines obtenues après immunisation par des extraits porcins de tissu ostéocartilagnieux, tissu conjonctif, séreuses, ganglions lymphatiques
			EOS
			assert_equal(expected.strip, agent.substance)
			assert_equal('20.0', agent.dose)
			assert_equal('', agent.unit)
		end
		def test_integrate__3
			path = File.expand_path('../data/xls/vaccines.xls', 
				File.dirname(__FILE__))
			regs = @plugin.registrations_from_xls(path)
			reg = regs['47604']
			assert_instance_of(VaccinePlugin::ParsedRegistration, reg)
			assert_equal('47604', reg.iksnr)
			assert_equal('Octapharma AG', reg.company)
			assert_equal(2, reg.sequences.size)
			seq = reg.sequences.first
			assert_instance_of(VaccinePlugin::ParsedSequence, seq)
			assert_equal('ATenativ', seq.name)
			assert_equal(1, seq.active_agents.size)
			agent = seq.active_agents.first
			assert_equal('Antithrombin III vom Menschen', agent.substance)
			assert_equal('500', agent.dose)
			assert_equal('IE', agent.unit)
			seq = reg.sequences.last
			assert_instance_of(VaccinePlugin::ParsedSequence, seq)
			assert_equal('ATenativ', seq.name)
			assert_equal(1, seq.active_agents.size)
			agent = seq.active_agents.first
			assert_equal('Antithrombin III vom Menschen', agent.substance)
			assert_equal('1500', agent.dose)
			assert_equal('IE', agent.unit)
		end
		def test_integrate__4
			path = File.expand_path('../data/xls/vaccines.xls', 
				File.dirname(__FILE__))
			regs = @plugin.registrations_from_xls(path)
			reg = regs['00655']
			assert_instance_of(VaccinePlugin::ParsedRegistration, reg)
			assert_equal('00655', reg.iksnr)
			assert_equal('Aventis Pasteur MSD AG', reg.company)
			seq = reg.sequences.first
			assert_instance_of(VaccinePlugin::ParsedSequence, seq)
			assert_equal('BCG-Impfstoff Mérieux', seq.name)
			assert_equal(1, seq.active_agents.size)
			agent = seq.active_agents.first
			assert_equal('Lebende attenuierte BCG-Bakterien (Mycobakterium bovis)', agent.substance)
			assert_equal('8.0-32.0', agent.dose)
			assert_equal('Mio.', agent.unit)
		end
		def test_integrate__5
			path = File.expand_path('../data/xls/vaccines.xls', 
				File.dirname(__FILE__))
			regs = @plugin.registrations_from_xls(path)
			reg = regs['54824']
			assert_instance_of(VaccinePlugin::ParsedRegistration, reg)
			assert_equal('54824', reg.iksnr)
			assert_equal('ZLB Behring (Schweiz) AG', reg.company)
			assert_equal(3, reg.sequences.size)
			## sequence 01
			seq = reg.sequences.at(0)
			assert_instance_of(VaccinePlugin::ParsedSequence, seq)
			assert_equal('Beriate P', seq.name)
			assert_equal(2, seq.active_agents.size)
			agent = seq.active_agents.first
			assert_equal('Blutgerinnungsfaktor VIII vom Menschen', agent.substance)
			assert_equal('250', agent.dose)
			assert_equal('IE', agent.unit)
			agent = seq.active_agents.last
			assert_equal('Gesamtprotein', agent.substance)
			assert_equal('0.5-2.5', agent.dose)
			assert_equal('mg', agent.unit)
			## sequence 02
			seq = reg.sequences.at(1)
			assert_instance_of(VaccinePlugin::ParsedSequence, seq)
			assert_equal('Beriate P', seq.name)
			assert_equal(2, seq.active_agents.size)
			agent = seq.active_agents.first
			assert_equal('Blutgerinnungsfaktor VIII vom Menschen', agent.substance)
			assert_equal('500', agent.dose)
			assert_equal('IE', agent.unit)
			agent = seq.active_agents.last
			assert_equal('Gesamtprotein', agent.substance)
			assert_equal('1-5', agent.dose)
			assert_equal('mg', agent.unit)
			## sequence 03
			seq = reg.sequences.at(2)
			assert_instance_of(VaccinePlugin::ParsedSequence, seq)
			assert_equal('Beriate P', seq.name)
			assert_equal(2, seq.active_agents.size)
			agent = seq.active_agents.first
			assert_equal('Blutgerinnungsfaktor VIII vom Menschen', agent.substance)
			assert_equal('1000', agent.dose)
			assert_equal('IE', agent.unit)
			agent = seq.active_agents.last
			assert_equal('Gesamtprotein', agent.substance)
			assert_equal('2-10', agent.dose)
			assert_equal('mg', agent.unit)
		end
		def test_integrate__6
			path = File.expand_path('../data/xls/vaccines.xls', 
				File.dirname(__FILE__))
			regs = @plugin.registrations_from_xls(path)
			reg = regs['00596']
			assert_instance_of(VaccinePlugin::ParsedRegistration, reg)
			assert_equal('00596', reg.iksnr)
			assert_equal('OM Pharma', reg.company)
			seq = reg.sequences.first
			assert_instance_of(VaccinePlugin::ParsedSequence, seq)
			assert_equal('Broncho-Vaxom Erwachsene', seq.name)
			assert_equal(4, seq.active_agents.size)
			agent = seq.active_agents.at(0)
			assert_equal('Standardisiertes OM-85 Lyophilisat', agent.substance)
			assert_equal('40.0', agent.dose)
			assert_equal('mg', agent.unit)
			agent = seq.active_agents.at(1)
		end
		def test_integrate__7__ean
			path = File.expand_path('../data/xls/vaccines_ean.xls', 
				File.dirname(__FILE__))
			regs = @plugin.registrations_from_xls(path)
			reg = regs['55536']
			reg.assign_seqnrs
			assert_instance_of(VaccinePlugin::ParsedRegistration, reg)
			assert_equal('55536', reg.iksnr)
			seq = reg.sequences.first
			assert_instance_of(VaccinePlugin::ParsedSequence, seq)
			assert_equal('02', seq.seqnr)
			assert_equal('Albumin Human Octapharma 20%', seq.name)
			assert_equal(['011', '012'], seq.packages.keys.sort)
			pack = seq.packages['011']
			assert_instance_of(VaccinePlugin::ParsedPackage, pack)
			assert_equal('011', pack.ikscd)
			assert_equal('1 Infusionsflasche zu 50 ml Lösung', pack.size)
		end
	end
end
