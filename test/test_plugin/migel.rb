#!/usr/bin/env ruby
# ODDB::TestMiGeLPlugin -- oddb.org -- 14.04.2011 -- mhatakeyama@ywesee.com
# ODDB::TestMiGeLPlugin -- oddb.org -- 30.08.2005 -- hwyss@ywesee.com

$: << File.expand_path('../../src', 
	File.dirname(__FILE__))
$: << File.expand_path('..', File.dirname(__FILE__))


require 'test/unit'
require 'plugin/migel'
require 'flexmock'

module ODDB
	class TestMiGeLPlugin < Test::Unit::TestCase
    include FlexMock::TestCase
		def setup
			@app = flexmock('app')
			@plugin = MiGeLPlugin.new(@app)
		end
		def test_update_group__id
			row = [
"03.","","APPLIKATIONSHILFEN","Gerätereparaturen beim Kaufsystem: Bei sorgfältigem Gebrauch ohne Selbstverschuldung, Vergütung nach Aufwand nur nach vorgängiger Kostengutsprache durch den Krankenversicherer.","03.02","","Insulinpumpen","","","","","","","03.02.01.00.2","L","Insulinpumpen-System, Miete
Inkl. Zubehör und Verbrauchsmaterial.
Limitation: Kostenübernahme nur auf vorgängige besondere Gutsprache des Krankenversicherers und mit ausdrücklicher Bewilligung des Vertrauensarztes oder der Vertrauensärztin.
Zur Insulintherapie bei:
- Extrem labiler Diabetes.
-  Einstellung auch mit der Methode der   Mehrfachinjektionen unbefriedigend.
-  Indikationen des Pumpeneinsatzes und   Betreuung des Patienten durch ein   qualifiziertes Zentrum oder, nach    Rücksprache mit dem Vertrauensarzt, durch  einen Arzt, der in der Anwendung der   Insulinpumpen ausgebildet ist.","","Miete/Tag","9","B","01.01.2006"
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
			@app.should_receive(:update, 2).and_return { |pointer, values|
				ptr = pointers.shift
				assert_equal(ptr.creator, pointer)
				expected = expecteds.shift
				assert_equal(expected, values)
			}
			@plugin.update_group(id, row, :de)
			@app.flexmock_verify
		end
		def test_update_group__de
			row = [
"03.","","APPLIKATIONSHILFEN","Gerätereparaturen beim Kaufsystem: Bei sorgfältigem Gebrauch ohne Selbstverschuldung, Vergütung nach Aufwand nur nach vorgängiger Kostengutsprache durch den Krankenversicherer.","03.02","","Insulinpumpen","","","","","","","03.02.01.00.2","L","Insulinpumpen-System, Miete
Inkl. Zubehör und Verbrauchsmaterial.
Limitation: Kostenübernahme nur auf vorgängige besondere Gutsprache des Krankenversicherers und mit ausdrücklicher Bewilligung des Vertrauensarztes oder der Vertrauensärztin.
Zur Insulintherapie bei:
- Extrem labiler Diabetes.
-  Einstellung auch mit der Methode der   Mehrfachinjektionen unbefriedigend.
-  Indikationen des Pumpeneinsatzes und   Betreuung des Patienten durch ein   qualifiziertes Zentrum oder, nach    Rücksprache mit dem Vertrauensarzt, durch  einen Arzt, der in der Anwendung der   Insulinpumpen ausgebildet ist.","","Miete/Tag","9","B","01.01.2006"
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
			@app.should_receive(:update, 2).and_return { |pointer, values|
				ptr = pointers.shift
				assert_equal(ptr.creator, pointer)
				expected = expecteds.shift
				assert_equal(expected, values)
			}
			@plugin.update_group(id, row, :de)
			@app.flexmock_verify
		end
		def test_update_group__fr
			row = [
"03.","","MOYENS D'APPLICATION","Réparation des appareils selon le système d'achat: en cas d'utilisation soigneuse sans erreur de la part de l'utilisateur, contribution selon les frais, seulement après demande de remboursement préalable auprès de l'assureur-maladie.","03.02","","Pompes à insuline","","","","","","","03.02.01.00.2","L","Système pompe à insuline, location
Y c. accessoires et matériel à usage unique.
Limitation: prise en charge seulement si l'assureur-maladie a donné préalablement une garantie spéciale et avec l'autorisation expresse du médecin-conseil. La thérapie est liée aux conditions suivantes:
-  diabète extrêmement labile;  
-  impossibilité de stabiliser l'affection de manière  satisfaisante par la méthode des injections  multiples;  
-  indication d'une pose de pompe et suivi du  patient dans un centre spécialisé ou, avec  l'accord du  médecinconseil, par un médecin  expérimenté dans l'utilisation des pompes à  insuline.","","location/jour",9,"B","01.01.2006"
			]
			id = %w(03 02 01 00 2)
			ptr = Persistence::Pointer.new([:migel_group, '03'])
			pointers = [ptr, ptr + :limitation_text]
			expecteds = [
				{
					:code => '03',
					:fr    => 'MOYENS D\'APPLICATION',
				},
				{
					:fr    => "Réparation des appareils selon le système d'achat: en cas d'utilisation soigneuse sans erreur de la part de l'utilisateur, contribution selon les frais, seulement après demande de remboursement préalable auprès de l'assureur-maladie.",
				},
			]
			@app.should_receive(:update, 2).and_return { |pointer, values|
				ptr = pointers.shift
				assert_equal(ptr.creator, pointer)
				expected = expecteds.shift
				assert_equal(expected, values)
			}
			@plugin.update_group(id, row, :fr)
			@app.flexmock_verify
		end
		def test_update_subgroup
			row = [
"03.","","APPLIKATIONSHILFEN","Gerätereparaturen beim Kaufsystem: Bei sorgfältigem Gebrauch ohne Selbstverschuldung, Vergütung nach Aufwand nur nach vorgängiger Kostengutsprache durch den Krankenversicherer.","03.02","","Insulinpumpen","","","","","","","03.02.01.00.2","L","Insulinpumpen-System, Miete
Inkl. Zubehör und Verbrauchsmaterial.
Limitation: Kostenübernahme nur auf vorgängige besondere Gutsprache des Krankenversicherers und mit ausdrücklicher Bewilligung des Vertrauensarztes oder der Vertrauensärztin.
Zur Insulintherapie bei:
- Extrem labiler Diabetes.
-  Einstellung auch mit der Methode der   Mehrfachinjektionen unbefriedigend.
-  Indikationen des Pumpeneinsatzes und   Betreuung des Patienten durch ein   qualifiziertes Zentrum oder, nach    Rücksprache mit dem Vertrauensarzt, durch  einen Arzt, der in der Anwendung der   Insulinpumpen ausgebildet ist.","","Miete/Tag","9","B","01.01.2006"
			]
			id = %w(03 02 01 00 2)
			group = FlexMock.new 
			group.should_receive(:pointer).and_return {
				Persistence::Pointer.new([:migel, '03'])
			}
			@app.should_receive(:update, 1).and_return { |pointer, values|
				ptr = Persistence::Pointer.new([:migel, '03'],[:subgroup, '02'])
				assert_equal(ptr.creator, pointer)
				expected = {
					:code => '02',
					:de => 'Insulinpumpen',
				}
				assert_equal(expected, values) 
 
			}
			@plugin.update_subgroup(id, group, row, :de)
			@app.flexmock_verify	
		end
		def test_update_subgroup__limitation
			row = [
"03.","","APPLIKATIONSHILFEN","Gerätereparaturen beim Kaufsystem: Bei sorgfältigem Gebrauch ohne Selbstverschuldung, Vergütung nach Aufwand nur nach vorgängiger Kostengutsprache durch den Krankenversicherer.","03.03","L","Infusionspumpen","Limitation: Zur Zytostatika-, Antibiotika-, Schmerz-, Chelatbildner-, Parkinsontherapie sowie für die parenterale Ernährung.","","","","","","03.03.02.06.2","","Nadel","1","Stück",0.45,"B","01.01.2006"
			]
			id = %w(03 02 01 00 2)
			group = FlexMock.new 
			group.should_receive(:pointer).and_return {
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
			@app.should_receive(:update, 2).and_return { |pointer, values|
				ptr = pointers.shift
				assert_equal(ptr.creator, pointer)
				expected = expecteds.shift
				assert_equal(expected, values) 
 
			}
			@plugin.update_subgroup(id, group, row, :de)
			@app.flexmock_verify	
		end
		def test_update_product__naked_de
			row = [
"03.","","APPLIKATIONSHILFEN","Gerätereparaturen beim Kaufsystem: Bei sorgfältigem Gebrauch ohne Selbstverschuldung, Vergütung nach Aufwand nur nach vorgängiger Kostengutsprache durch den Krankenversicherer.","03.02","","Insulinpumpen","","","","","","","03.02.01.00.2","L","Insulinpumpen-System, Miete
Inkl. Zubehör und Verbrauchsmaterial.
Limitation: Kostenübernahme nur auf vorgängige besondere Gutsprache des Krankenversicherers und mit ausdrücklicher Bewilligung des Vertrauensarztes oder der Vertrauensärztin.
Zur Insulintherapie bei:
- Extrem labiler Diabetes.
-  Einstellung auch mit der Methode der   Mehrfachinjektionen unbefriedigend.
-  Indikationen des Pumpeneinsatzes und   Betreuung des Patienten durch ein   qualifiziertes Zentrum oder, nach    Rücksprache mit dem Vertrauensarzt, durch  einen Arzt, der in der Anwendung der   Insulinpumpen ausgebildet ist.","","Miete/Tag","Fr. 9","B","01.01.2006"
			]
			id = %w(03 02 01 00 2)
			subgroup = FlexMock.new
			sg_pointer = Persistence::Pointer.new([:migel, '03'],
				[:subgroup, '02']) 
			subgroup.should_receive(:pointer).and_return {
				sg_pointer
			}
			pointer = sg_pointer + [:product, '01.00.2']
			pointers = [
				pointer,
				pointer + [:product_text],
				pointer + [:limitation_text],
				pointer + [:unit],
			]
			expecteds = [
				{
					:de => "Insulinpumpen-System, Miete",
					:price =>	900,
					:type	 => :rent,
					:date  => Date.new(2006),
					:limitation => true,
				},
				{
					:de => "Inkl. Zubehör und Verbrauchsmaterial.",
				},
				{
					:de => "Limitation: Kostenübernahme nur auf vorgängige besondere Gutsprache des Krankenversicherers und mit ausdrücklicher Bewilligung des Vertrauensarztes oder der Vertrauensärztin.\nZur Insulintherapie bei:\n- Extrem labiler Diabetes.\n- Einstellung auch mit der Methode der Mehrfachinjektionen unbefriedigend.\n- Indikationen des Pumpeneinsatzes und Betreuung des Patienten durch ein qualifiziertes Zentrum oder, nach Rücksprache mit dem Vertrauensarzt, durch einen Arzt, der in der Anwendung der Insulinpumpen ausgebildet ist.",
				},
				{
					:de => 'Miete/Tag',
				},
			]
			@app.should_receive(:update, 4).and_return { |pointer, values|
				ptr = pointers.shift
				assert_equal(ptr.creator, pointer) 	
				expected = expecteds.shift
				assert_equal(expected, values)	
		  }	
			@plugin.update_product(id, subgroup, row, :de)
			@app.flexmock_verify
		end
		def test_update_product__naked_fr
			row = [
"03.","","MOYENS D'APPLICATION","Réparation des appareils selon le système d'achat: en cas d'utilisation soigneuse sans erreur de la part de l'utilisateur, contribution selon les frais, seulement après demande de remboursement préalable auprès de l'assureur-maladie.","03.02","","Pompes à insuline","","","","","","","03.02.01.00.2","L","Système pompe à insuline, location
Y c. accessoires et matériel à usage unique.
Limitation: prise en charge seulement si l'assureur-maladie a donné préalablement une garantie spéciale et avec l'autorisation expresse du médecin-conseil. La thérapie est liée aux conditions suivantes:
-  diabète extrêmement labile;  
-  impossibilité de stabiliser l'affection de manière  satisfaisante par la méthode des injections  multiples;  
-  indication d'une pose de pompe et suivi du  patient dans un centre spécialisé ou, avec  l'accord du  médecinconseil, par un médecin  expérimenté dans l'utilisation des pompes à  insuline.","","location/jour",9,"B","01.01.2006"
			]
			id = %w(03 02 01 00 2)
			subgroup = FlexMock.new
			sg_pointer = Persistence::Pointer.new([:migel, '03'],
				[:subgroup, '02']) 
			subgroup.should_receive(:pointer).and_return {
				sg_pointer
			}
			pointer = sg_pointer + [:product, '01.00.2']
			pointers = [
				pointer,
				pointer + [:product_text],
				pointer + [:limitation_text],
				pointer + [:unit],
			]
			expecteds = [
				{
					:fr => "Système pompe à insuline, location",
					:price =>	900,
					:type	 => :rent,
					:date  => Date.new(2006),
					:limitation => true,
				},
				{
					:fr => "Y c. accessoires et matériel à usage unique.",
				},
				{
					:fr => "Limitation: prise en charge seulement si l'assureur-maladie a donné préalablement une garantie spéciale et avec l'autorisation expresse du médecin-conseil. La thérapie est liée aux conditions suivantes:\n- diabète extrêmement labile; \n- impossibilité de stabiliser l'affection de manière satisfaisante par la méthode des injections multiples; \n- indication d'une pose de pompe et suivi du patient dans un centre spécialisé ou, avec l'accord du médecinconseil, par un médecin expérimenté dans l'utilisation des pompes à insuline.",
				},
				{
					:fr => 'location/jour',
				},
			]
			@app.should_receive(:update, 4).and_return { |pointer, values|
				ptr = pointers.shift
				assert_equal(ptr.creator, pointer) 	
				expected = expecteds.shift
				assert_equal(expected, values)	
		  }	
			@plugin.update_product(id, subgroup, row, :fr)
			@app.flexmock_verify
		end
		def test_update_product__no_extras
			row = [
"03.","","APPLIKATIONSHILFEN","Gerätereparaturen beim Kaufsystem: Bei sorgfältigem Gebrauch ohne Selbstverschuldung, Vergütung nach Aufwand nur nach vorgängiger Kostengutsprache durch den Krankenversicherer.","03.02","","Insulinpumpen","","","","","","","03.02.01.00.2","L","Insulinpumpen-System, Miete
Inkl. Zubehör und Verbrauchsmaterial.","","","9","B","01.01.2006"
			]
			id = %w(03 02 01 00 2)
			subgroup = FlexMock.new
			sg_pointer = Persistence::Pointer.new([:migel, '03'],
				[:subgroup, '02']) 
			subgroup.should_receive(:pointer).and_return {
				sg_pointer
			}

			pointer = sg_pointer + [:product, '01.00.2']
			pointers = [
				pointer, pointer + :product_text,	
			]
			expecteds = [
				{
					:de => "Insulinpumpen-System, Miete",
					:price =>	900,
					:type	 => :rent,
					:date  => Date.new(2006),
					:limitation => true,
				},
				{	:de	=>	"Inkl. Zubehör und Verbrauchsmaterial."  },
			]
			@app.should_receive(:update, 2).and_return { |pointer, values|
				ptr = pointers.shift
				assert_equal(ptr.creator, pointer) 	
				expected = expecteds.shift
				assert_equal(expected, values)
		  }	
			@plugin.update_product(id, subgroup, row, :de)
			@app.flexmock_verify
		end
		def test_date_object
			assert_equal(Date.new(2005, 8,1), 
				@plugin.date_object('01.08.2005'))
			assert_nothing_raised {
				@plugin.date_object('')
			}
		end

    def test_prune_old_revisions
      revision = Time.local(Time.now.year - 1, 2,3)
      limitation_text = flexmock('limitation_text', 
                                 :revision => revision,
                                 :pointer  => 'pointer'
                                )
      product_text    = flexmock('product_text', 
                                 :revision => revision,
                                 :pointer  => 'pointer'
                                )
      unit            = flexmock('unit', 
                                 :revision => revision,
                                 :pointer  => 'pointer'
                                )
      product  = flexmock('product', 
                          :limitation_text => limitation_text,
                          :product_text    => product_text,
                          :unit            => unit,
                          :revision        => revision,
                          :pointer         => 'pointer'
                         )
      subgroup = flexmock('subgroup', 
                          :products => {'key' => product},
                          :limitation_text => limitation_text
                         )
      group    = flexmock('group', 
                          :subgroups => {'key' => subgroup},
                          :limitation_text => limitation_text
                         )
      flexmock(@app, 
               :migel_groups => {'key' => group},
               :delete       => nil
              )
      expected = {"key" => group}
      assert_equal(expected, @plugin.prune_old_revisions)
    end
    def test_prune_old_revisions__products_empty
      revision = Time.local(Time.now.year - 1, 2,3)
      limitation_text = flexmock('limitation_text', 
                                 :revision => revision,
                                 :pointer  => 'pointer'
                                )
      subgroup = flexmock('subgroup', 
                          :products => {},
                          :limitation_text => limitation_text,
                          :revision => revision,
                          :pointer  => 'pointer'
                         )
      group    = flexmock('group', 
                          :subgroups => {'key' => subgroup},
                          :limitation_text => limitation_text
                         )
      flexmock(@app, 
               :migel_groups => {'key' => group},
               :delete       => nil
              )
      expected = {"key" => group}
      assert_equal(expected, @plugin.prune_old_revisions)
    end
    def test_prune_old_revisions__subgroups_empty
      revision = Time.local(Time.now.year - 1, 2,3)
      limitation_text = flexmock('limitation_text', 
                                 :revision => revision,
                                 :pointer  => 'pointer'
                                )
      group    = flexmock('group', 
                          :subgroups => {},
                          :limitation_text => limitation_text,
                          :revision  => revision,
                          :pointer   => 'pointer'
                         )
      flexmock(@app, 
               :migel_groups => {'key' => group},
               :delete       => nil
              )
      expected = {"key" => group}
      assert_equal(expected, @plugin.prune_old_revisions)
    end
    def test_update
      pointer = flexmock('pointer', :creator => 'creator')
      flexmock(pointer, :+ => pointer)
      update = flexmock('update', :pointer => pointer)
      flexmock(@app, :update => update)
      row = [0,1,2,3,4,5,6,7,8,9,10,11,12,"abc.def"]
      flexmock(CSV, :read => [nil, row])
      expected = [[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, "abc.def"]]
      assert_equal(expected, @plugin.update('path', 'language'))
    end
    def test_update__id_size_3
      pointer = flexmock('pointer', :creator => 'creator')
      flexmock(pointer, :+ => pointer)
      product = flexmock('product',
                        :pointer => pointer,
                        :product => product
                        )
      flexmock(@app, :update => product)
      row = [0,1,2,3,4,5,6,7,8,9,10,11,12,"1.2.3",14,'product_text']
      flexmock(CSV, :read => [nil, row])
      expected = [[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, "1.2.3", 14, "product_text"]]
      assert_equal(expected, @plugin.update('path', 'language'))
    end
    def test_update__id_empty
      pointer = flexmock('pointer', :creator => 'creator')
      flexmock(pointer, :+ => pointer)
      update = flexmock('update', :pointer => pointer)
      flexmock(@app, :update => update)
      row = [0,1,2,3,4,5,6,7,8,9,10,11,12,""]
      flexmock(CSV, :read => [nil, row])
      expected = [[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, ""]]
      assert_equal(expected, @plugin.update('path', 'language'))
    end
    def test_update_product
      pointer  = flexmock('pointer', :creator => 'creator')
      flexmock(pointer, :+ => pointer)
      product  = flexmock('product', :add_product => 'add_product')
      flexmock(@app, :update => product)
      subgroup = flexmock('subgroup', 
                          :pointer => pointer,
                          :product => product
                         )
      row      = [0,1,2,3,4,5,6,7,8,9,10,11,'name',13,14,'product_text', 16]
      assert_equal(product, @plugin.update_product([0,1,'2','3','4'], subgroup, row, 'language'))
    end

	end
end
