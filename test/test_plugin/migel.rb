#!/usr/bin/env ruby
# TestMiGeLPlugin -- oddb -- 30.08.2005 -- hwyss@ywesee.com

$: << File.expand_path('../../src', 
	File.dirname(__FILE__))
$: << File.expand_path('..', File.dirname(__FILE__))


require 'test/unit'
require 'plugin/migel'
require 'flexmock'

module ODDB
	class TestMiGeLPlugin < Test::Unit::TestCase
		def setup
			@app = FlexMock.new
			@plugin = MiGeLPlugin.new(@app)
		end
		def test_update_group__id
			row = [
"3","APPLIKATIONSHILFEN","GerŠtereparaturen beim Kaufsystem: Bei sorgfŠltigemGebrauch ohne Selbstverschuldung, VergŸtung nach Aufwand nur nach vorgŠngiger Kostengutsprache durch den Krankenversicherer.","3.02","Insulinpumpen","","","","03.02.01.00.2","Insulinpumpen-System,Inkl. Zubehšr und Verbrauchsmaterial.Limitation: KostenŸbernahme nur auf vorgŠngige besondere Gutsprache des Krankenversicherers und mit ausdrŸcklicher Bewilligung des Vertrauensarztes oder der VertrauensŠrztin.Zur Insulintherapie bei:- 	Extrem labiler Diabetes.- 	Einstellung auch mit der Methode der 		Mehrfachinjektionen unbefriedigend.- 	Indikationen des Pumpeneinsatzes und 	Betreuung des Patienten durch ein 		qualifiziertes Zentrum oder, nach 		RŸcksprache mit dem Vertrauensarzt, durch 	einen Arzt, der in der Anwendung der 	Insulinpumpen ausgebildet ist.","L","","Miete/Tag","10","1.1.2003"
			]
			id = %w(03 02 01 00 199)
			ptr = Persistence::Pointer.new([:migel_group, '03'])
			pointers = [ptr, ptr + :limitation_text]
			expecteds = [
				{
					:code => '03',
					:de    => 'APPLIKATIONSHILFEN',
				},
				{
					:de    => "Gerätereparaturen beim Kaufsystem: Bei sorgfältigem Gebrauch ohne Selbstverschuldung, Vergütung nach Aufwand nur nach vorgängiger Kostengutsprache durch den Krankenversicherer.",
				},
			]
			@app.mock_handle(:update, 2) { |pointer, values|
				ptr = pointers.shift
				assert_equal(ptr.creator, pointer)
				expected = expecteds.shift
				assert_equal(expected, values)
			}
			@plugin.update_group(id, row, :de)
			@app.mock_verify
		end
		def test_update_group__de
			row = [
"3","APPLIKATIONSHILFEN","GerŠtereparaturen beim Kaufsystem: Bei sorgfŠltigemGebrauch ohne Selbstverschuldung, VergŸtung nach Aufwand nur nach vorgŠngiger Kostengutsprache durch den Krankenversicherer.","3.02","Insulinpumpen","","","","03.02.01.00.2","Insulinpumpen-System,Inkl. Zubehšr und Verbrauchsmaterial.Limitation: KostenŸbernahme nur auf vorgŠngige besondere Gutsprache des Krankenversicherers und mit ausdrŸcklicher Bewilligung des Vertrauensarztes oder der VertrauensŠrztin.Zur Insulintherapie bei:- 	Extrem labiler Diabetes.- 	Einstellung auch mit der Methode der 		Mehrfachinjektionen unbefriedigend.- 	Indikationen des Pumpeneinsatzes und 	Betreuung des Patienten durch ein 		qualifiziertes Zentrum oder, nach 		RŸcksprache mit dem Vertrauensarzt, durch 	einen Arzt, der in der Anwendung der 	Insulinpumpen ausgebildet ist.","L","","Miete/Tag","10","1.1.2003"
			]
			id = %w(03 02 01 00 2)
			ptr = Persistence::Pointer.new([:migel_group, '03'])
			pointers = [ptr, ptr + :limitation_text]
			expecteds = [
				{
					:code => '03',
					:de    => 'APPLIKATIONSHILFEN',
				},
				{
					:de    => "Gerätereparaturen beim Kaufsystem: Bei sorgfältigem Gebrauch ohne Selbstverschuldung, Vergütung nach Aufwand nur nach vorgängiger Kostengutsprache durch den Krankenversicherer.",
				},
			]
			@app.mock_handle(:update, 2) { |pointer, values|
				ptr = pointers.shift
				assert_equal(ptr.creator, pointer)
				expected = expecteds.shift
				assert_equal(expected, values)
			}
			@plugin.update_group(id, row, :de)
			@app.mock_verify
		end
		def test_update_group__fr
			row = [
"3","APPLIKATIONSHILFEN","GerŠtereparaturen beim Kaufsystem: Bei sorgfŠltigemGebrauch ohne Selbstverschuldung, VergŸtung nach Aufwand nur nach vorgŠngiger Kostengutsprache durch den Krankenversicherer.","3.02","Insulinpumpen","","","","03.02.01.00.2","Insulinpumpen-System,Inkl. Zubehšr und Verbrauchsmaterial.Limitation: KostenŸbernahme nur auf vorgŠngige besondere Gutsprache des Krankenversicherers und mit ausdrŸcklicher Bewilligung des Vertrauensarztes oder der VertrauensŠrztin.Zur Insulintherapie bei:- 	Extrem labiler Diabetes.- 	Einstellung auch mit der Methode der 		Mehrfachinjektionen unbefriedigend.- 	Indikationen des Pumpeneinsatzes und 	Betreuung des Patienten durch ein 		qualifiziertes Zentrum oder, nach 		RŸcksprache mit dem Vertrauensarzt, durch 	einen Arzt, der in der Anwendung der 	Insulinpumpen ausgebildet ist.","L","","Miete/Tag","10","1.1.2003"
			]
			id = %w(03 02 01 00 2)
			ptr = Persistence::Pointer.new([:migel_group, '03'])
			pointers = [ptr, ptr + :limitation_text]
			expecteds = [
				{
					:code => '03',
					:fr    => 'APPLIKATIONSHILFEN',
				},
				{
					:fr    => "Gerätereparaturen beim Kaufsystem: Bei sorgfältigem Gebrauch ohne Selbstverschuldung, Vergütung nach Aufwand nur nach vorgängiger Kostengutsprache durch den Krankenversicherer.",
				},
			]
			@app.mock_handle(:update, 2) { |pointer, values|
				ptr = pointers.shift
				assert_equal(ptr.creator, pointer)
				expected = expecteds.shift
				assert_equal(expected, values)
			}
			@plugin.update_group(id, row, :fr)
			@app.mock_verify
		end
		def test_update_subgroup
			row = [
"3","APPLIKATIONSHILFEN","GerŠtereparaturen beim Kaufsystem: Bei sorgfŠltigemGebrauch ohne Selbstverschuldung, VergŸtung nach Aufwand nur nach vorgŠngiger Kostengutsprache durch den Krankenversicherer.","3.02","Insulinpumpen","","","","03.02.01.00.2","Insulinpumpen-System,Inkl. Zubehšr und Verbrauchsmaterial.Limitation: KostenŸbernahme nur auf vorgŠngige besondere Gutsprache des Krankenversicherers und mit ausdrŸcklicher Bewilligung des Vertrauensarztes oder der VertrauensŠrztin.Zur Insulintherapie bei:- 	Extrem labiler Diabetes.- 	Einstellung auch mit der Methode der 		Mehrfachinjektionen unbefriedigend.- 	Indikationen des Pumpeneinsatzes und 	Betreuung des Patienten durch ein 		qualifiziertes Zentrum oder, nach 		RŸcksprache mit dem Vertrauensarzt, durch 	einen Arzt, der in der Anwendung der 	Insulinpumpen ausgebildet ist.","L","","Miete/Tag","10","1.1.2003"
			]
			id = %w(03 02 01 00 2)
			group = FlexMock.new 
			group.mock_handle(:pointer) {
				Persistence::Pointer.new([:migel, '03'])
			}
			@app.mock_handle(:update, 1) { |pointer, values|
				ptr = Persistence::Pointer.new([:migel, '03'],[:subgroup, '02'])
				assert_equal(ptr.creator, pointer)
				expected = {
					:code => '02',
					:de => 'Insulinpumpen',
				}
				assert_equal(expected, values) 
 
			}
			@plugin.update_subgroup(id, group, row, :de)
			@app.mock_verify	
		end
		def test_update_subgroup__limitation
			row = [
"3","APPLIKATIONSHILFEN","GerŠtereparaturen beim Kaufsystem: Bei sorgfŠltigemGebrauch ohne Selbstverschuldung, VergŸtung nach Aufwand nur nach vorgŠngiger Kostengutsprache durch den Krankenversicherer.","3.03","Infusionspumpen","Limitation: Zur Zytostatika-, Antibiotika-, Schmerz-, Chelatbildner-, Parkinsontherapie sowie fŸr die parenterale ErnŠhrung.","","","03.03.02.06.2","Nadel","","1","StŸck",".5","1.1.1997"
			]
			id = %w(03 02 01 00 2)
			group = FlexMock.new 
			group.mock_handle(:pointer) {
				Persistence::Pointer.new([:migel, '03'])
			}
			ptr = Persistence::Pointer.new([:migel, '03'],[:subgroup, '02'])
			pointers = [ptr, ptr + [:limitation_text]]
			expecteds = [
				{
					:code => '02',
					:de => 'Infusionspumpen',
				},
				{
					:de => "Limitation: Zur Zytostatika-, Antibiotika-, Schmerz-, Chelatbildner-, Parkinsontherapie sowie für die parenterale Ernährung.",
				}
			]
			@app.mock_handle(:update, 2) { |pointer, values|
				ptr = pointers.shift
				assert_equal(ptr.creator, pointer)
				expected = expecteds.shift
				assert_equal(expected, values) 
 
			}
			@plugin.update_subgroup(id, group, row, :de)
			@app.mock_verify	
		end
		def test_update_product__naked_de
			row = [
"3","APPLIKATIONSHILFEN","GerŠtereparaturen beim Kaufsystem: Bei sorgfŠltigemGebrauch ohne Selbstverschuldung, VergŸtung nach Aufwand nur nach vorgŠngiger Kostengutsprache durch den Krankenversicherer.","3.02","Insulinpumpen","","","","03.02.01.00.2","Insulinpumpen-System,Inkl. Zubehšr und Verbrauchsmaterial.Limitation: KostenŸbernahme nur auf vorgŠngige besondere Gutsprache des Krankenversicherers und mit ausdrŸcklicher Bewilligung des Vertrauensarztes oder der VertrauensŠrztin.Zur Insulintherapie bei:- 	Extrem labiler Diabetes.- 	Einstellung auch mit der Methode der 		Mehrfachinjektionen unbefriedigend.- 	Indikationen des Pumpeneinsatzes und 	Betreuung des Patienten durch ein 		qualifiziertes Zentrum oder, nach 		RŸcksprache mit dem Vertrauensarzt, durch 	einen Arzt, der in der Anwendung der 	Insulinpumpen ausgebildet ist.","L","","Miete/Tag","10","1.1.2003"
			]
			id = %w(03 02 01 00 2)
			subgroup = FlexMock.new
			sg_pointer = Persistence::Pointer.new([:migel, '03'],
				[:subgroup, '02']) 
			subgroup.mock_handle(:pointer) {
				sg_pointer
			}
			pointer = sg_pointer + [:product, '01.00.2']
			pointers = [
				pointer,
				pointer + [:limitation_text],
				pointer + [:unit],
			]
			expecteds = [
				{
					:de => "Insulinpumpen-System,\nInkl. Zubehör und Verbrauchsmaterial.",
					:price =>	1000,
					:type	 => :rent,
					:date  => Date.new(2003),
					:limitation => true,
				},
				{
					:de => "Limitation: Kostenübernahme nur auf vorgängige besondere Gutsprache des Krankenversicherers und mit ausdrücklicher Bewilligung des Vertrauensarztes oder der Vertrauensärztin.\nZur Insulintherapie bei:\n- Extrem labiler Diabetes.\n- Einstellung auch mit der Methode der Mehrfachinjektionen unbefriedigend.\n- Indikationen des Pumpeneinsatzes und Betreuung des Patienten durch ein qualifiziertes Zentrum oder, nach Rücksprache mit dem Vertrauensarzt, durch einen Arzt, der in der Anwendung der Insulinpumpen ausgebildet ist.",
				},
				{
					:de => 'Miete/Tag',
				},
			]
			@app.mock_handle(:update, 3) { |pointer, values|
				ptr = pointers.shift
				assert_equal(ptr.creator, pointer) 	
				expected = expecteds.shift
				assert_equal(expected, values)	
		  }	
			@plugin.update_product(id, subgroup, row, :de)
			@app.mock_verify
		end
		def test_update_product__naked_fr
			row = [
"3","APPLIKATIONSHILFEN","GerŠtereparaturen beim Kaufsystem: Bei sorgfŠltigemGebrauch ohne Selbstverschuldung, VergŸtung nach Aufwand nur nach vorgŠngiger Kostengutsprache durch den Krankenversicherer.","3.02","Insulinpumpen","","","","03.02.01.00.2","Insulinpumpen-System,Inkl. Zubehšr und Verbrauchsmaterial.Limitation: KostenŸbernahme nur auf vorgŠngige besondere Gutsprache des Krankenversicherers und mit ausdrŸcklicher Bewilligung des Vertrauensarztes oder der VertrauensŠrztin.Zur Insulintherapie bei:- 	Extrem labiler Diabetes.- 	Einstellung auch mit der Methode der 		Mehrfachinjektionen unbefriedigend.- 	Indikationen des Pumpeneinsatzes und 	Betreuung des Patienten durch ein 		qualifiziertes Zentrum oder, nach 		RŸcksprache mit dem Vertrauensarzt, durch 	einen Arzt, der in der Anwendung der 	Insulinpumpen ausgebildet ist.","L","","Miete/Tag","10","1.1.2003"
			]
			id = %w(03 02 01 00 2)
			subgroup = FlexMock.new
			sg_pointer = Persistence::Pointer.new([:migel, '03'],
				[:subgroup, '02']) 
			subgroup.mock_handle(:pointer) {
				sg_pointer
			}
			pointer = sg_pointer + [:product, '01.00.2']
			pointers = [
				pointer,
				pointer + [:limitation_text],
				pointer + [:unit],
			]
			expecteds = [
				{
					:fr => "Insulinpumpen-System,\nInkl. Zubehör und Verbrauchsmaterial.",
					:price =>	1000,
					:type	 => :rent,
					:date  => Date.new(2003),
					:limitation => true,
				},
				{
					:fr => "Limitation: Kostenübernahme nur auf vorgängige besondere Gutsprache des Krankenversicherers und mit ausdrücklicher Bewilligung des Vertrauensarztes oder der Vertrauensärztin.\nZur Insulintherapie bei:\n- Extrem labiler Diabetes.\n- Einstellung auch mit der Methode der Mehrfachinjektionen unbefriedigend.\n- Indikationen des Pumpeneinsatzes und Betreuung des Patienten durch ein qualifiziertes Zentrum oder, nach Rücksprache mit dem Vertrauensarzt, durch einen Arzt, der in der Anwendung der Insulinpumpen ausgebildet ist.",
				},
				{
					:fr => 'Miete/Tag',
				},
			]
			@app.mock_handle(:update, 3) { |pointer, values|
				ptr = pointers.shift
				assert_equal(ptr.creator, pointer) 	
				expected = expecteds.shift
				assert_equal(expected, values)	
		  }	
			@plugin.update_product(id, subgroup, row, :fr)
			@app.mock_verify
		end
		def test_update_product__naked_it
			row = [
"3","APPLIKATIONSHILFEN","GerŠtereparaturen beim Kaufsystem: Bei sorgfŠltigemGebrauch ohne Selbstverschuldung, VergŸtung nach Aufwand nur nach vorgŠngiger Kostengutsprache durch den Krankenversicherer.","3.02","Insulinpumpen","","","","03.02.01.00.2","Insulinpumpen-System,Inkl. Zubehšr und Verbrauchsmaterial.Limitation: KostenŸbernahme nur auf vorgŠngige besondere Gutsprache des Krankenversicherers und mit ausdrŸcklicher Bewilligung des Vertrauensarztes oder der VertrauensŠrztin.Zur Insulintherapie bei:- 	Extrem labiler Diabetes.- 	Einstellung auch mit der Methode der 		Mehrfachinjektionen unbefriedigend.- 	Indikationen des Pumpeneinsatzes und 	Betreuung des Patienten durch ein 		qualifiziertes Zentrum oder, nach 		RŸcksprache mit dem Vertrauensarzt, durch 	einen Arzt, der in der Anwendung der 	Insulinpumpen ausgebildet ist.","L","","Miete/Tag","10","1.1.2003"
			]
			id = %w(03 02 01 00 2)
			subgroup = FlexMock.new
			sg_pointer = Persistence::Pointer.new([:migel, '03'],
				[:subgroup, '02']) 
			subgroup.mock_handle(:pointer) {
				sg_pointer
			}
			pointer = sg_pointer + [:product, '01.00.2']
			pointers = [
				pointer,
				pointer + [:limitation_text],
				pointer + [:unit],
			]
			expecteds = [
				{
					:it => "Insulinpumpen-System,\nInkl. Zubehör und Verbrauchsmaterial.",
					:price =>	1000,
					:type	 => :rent,
					:date  => Date.new(2003),
					:limitation => true,
				},
				{
					:it => "Limitation: Kostenübernahme nur auf vorgängige besondere Gutsprache des Krankenversicherers und mit ausdrücklicher Bewilligung des Vertrauensarztes oder der Vertrauensärztin.\nZur Insulintherapie bei:\n- Extrem labiler Diabetes.\n- Einstellung auch mit der Methode der Mehrfachinjektionen unbefriedigend.\n- Indikationen des Pumpeneinsatzes und Betreuung des Patienten durch ein qualifiziertes Zentrum oder, nach Rücksprache mit dem Vertrauensarzt, durch einen Arzt, der in der Anwendung der Insulinpumpen ausgebildet ist.",
				},
				{
					:it => 'Miete/Tag',
				},
			]
			@app.mock_handle(:update, 3) { |pointer, values|
				ptr = pointers.shift
				assert_equal(ptr.creator, pointer) 	
				expected = expecteds.shift
				assert_equal(expected, values)	
		  }	
			@plugin.update_product(id, subgroup, row, :it)
			@app.mock_verify
		end
		def test_update_product__no_extras
			row = [
"3","APPLIKATIONSHILFEN","GerŠtereparaturen beim Kaufsystem: Bei sorgfŠltigemGebrauch ohne Selbstverschuldung, VergŸtung nach Aufwand nur nach vorgŠngiger Kostengutsprache durch den Krankenversicherer.","3.02","Insulinpumpen","","","","03.02.01.00.2","Insulinpumpen-System,Inkl. Zubehšr und Verbrauchsmaterial.","L","","","10","1.1.2003"
			]
			id = %w(03 02 01 00 2)
			subgroup = FlexMock.new
			sg_pointer = Persistence::Pointer.new([:migel, '03'],
				[:subgroup, '02']) 
			subgroup.mock_handle(:pointer) {
				sg_pointer
			}
			@app.mock_handle(:update, 1) { |pointer, values|
				ptr = sg_pointer + [:product, '01.00.2']
				assert_equal(ptr.creator, pointer) 	
				expected = {
					:de => "Insulinpumpen-System,\nInkl. Zubehör und Verbrauchsmaterial.",
					:price =>	1000,
					:type	 => :rent,
					:date  => Date.new(2003),
					:limitation => true,
				}
				assert_equal(expected, values)
		  }	
			@plugin.update_product(id, subgroup, row, :de)
			@app.mock_verify
		end
		def test_update_accessory
			row = [
"3","APPLIKATIONSHILFEN","GerŠtereparaturen beim Kaufsystem: Bei sorgfŠltigemGebrauch ohne Selbstverschuldung, VergŸtung nach Aufwand nur nach vorgŠngiger Kostengutsprache durch den Krankenversicherer.","3.02","Insulinpumpen","","","","03.02.01.00.2","Insulinpumpen-System,Inkl. Zubehšr und Verbrauchsmaterial.Limitation: KostenŸbernahme nur auf vorgŠngige besondere Gutsprache des Krankenversicherers und mit ausdrŸcklicher Bewilligung des Vertrauensarztes oder der VertrauensŠrztin.Zur Insulintherapie bei:- 	Extrem labiler Diabetes.- 	Einstellung auch mit der Methode der 		Mehrfachinjektionen unbefriedigend.- 	Indikationen des Pumpeneinsatzes und 	Betreuung des Patienten durch ein 		qualifiziertes Zentrum oder, nach 		RŸcksprache mit dem Vertrauensarzt, durch 	einen Arzt, der in der Anwendung der 	Insulinpumpen ausgebildet ist.","L","","Miete/Tag","10","1.1.2003"
			]
			id = %w(03 02 01 00 2)
			subgroup = FlexMock.new
			sg_pointer = Persistence::Pointer.new([:migel, '03'],
				[:subgroup, '02']) 
			subgroup.mock_handle(:pointer) {
				sg_pointer
			}
			pointer = sg_pointer + [:product, '01.00.2']
			pointers = [
				pointer,
				pointer + [:limitation_text],
				pointer + [:unit],
			]
			expecteds = [
				{
					:de => "Insulinpumpen-System,\nInkl. Zubehör und Verbrauchsmaterial.",
					:price =>	1000,
					:type	 => :rent,
					:date  => Date.new(2003),
					:limitation => true,
				},
				{
					:de => "Limitation: Kostenübernahme nur auf vorgängige besondere Gutsprache des Krankenversicherers und mit ausdrücklicher Bewilligung des Vertrauensarztes oder der Vertrauensärztin.\nZur Insulintherapie bei:\n- Extrem labiler Diabetes.\n- Einstellung auch mit der Methode der Mehrfachinjektionen unbefriedigend.\n- Indikationen des Pumpeneinsatzes und Betreuung des Patienten durch ein qualifiziertes Zentrum oder, nach Rücksprache mit dem Vertrauensarzt, durch einen Arzt, der in der Anwendung der Insulinpumpen ausgebildet ist.",
				},
				{
					:de => 'Miete/Tag',
				},
			]
			@app.mock_handle(:update, 3) { |pointer, values|
				ptr = pointers.shift
				assert_equal(ptr.creator, pointer) 	
				expected = expecteds.shift
				assert_equal(expected, values)	
		  }	
			@plugin.update_product(id, subgroup, row, :de)
			@app.mock_verify
		end
		def test_date_object
			assert_equal(Date.new(2005, 8,1), 
				@plugin.date_object('01.08.2005'))
			assert_nothing_raised {
				@plugin.date_object('')
			}
		end
	end
end
