#!/usr/bin/env ruby
# TestVaccinePlugin -- ydpm -- 22.03.2005 -- hwyss@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'rubygems'
require 'flexmock'
require 'plugin/vaccines'

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
	end
end
