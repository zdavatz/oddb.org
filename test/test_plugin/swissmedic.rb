#!/usr/bin/env ruby
# SwissmedicPluginTest -- oddb.org -- 18.03.2008 -- hwyss@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'plugin/swissmedic'

module ODDB
  class SwissmedicPluginTest < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @app = flexmock 'app'
      @archive = File.expand_path('../var', File.dirname(__FILE__))
      @latest = File.join @archive, 'xls', 'Packungen-latest.xls'
      @target = File.join @archive, 'xls', 
                          @@today.strftime('Packungen-%Y.%m.%d.xls')
      @plugin = SwissmedicPlugin.new @app, @archive
      @data = File.expand_path '../data/xls/Packungen.xls',
                               File.dirname(__FILE__)
      @older = File.expand_path '../data/xls/Packungen.older.xls',
                                File.dirname(__FILE__)
      @initial = File.expand_path '../data/xls/Packungen.initial.xls',
                                  File.dirname(__FILE__)
      @workbook = Spreadsheet::ParseExcel.parse(@data)
    end
    def teardown
      File.delete(@latest) if File.exist?(@latest)
      File.delete(@target) if File.exist?(@target)
      super
    end
    def test_get_latest_file__new
      assert !File.exist?(@latest), "A previous test did not clean up #@latest"
      assert !File.exist?(@target), "A previous test did not clean up #@target"
      agent = flexmock 'agent'
      page = flexmock 'page'
      page.should_receive(:body).and_return('Content of the xml')
      agent.should_receive(:get).and_return(page)
      @plugin.get_latest_file(agent)
      assert File.exist?(@target), "#@target was not saved"
    end
    def test_get_latest_file__identical
      assert !File.exist?(@latest), "A previous test did not clean up #@latest"
      assert !File.exist?(@target), "A previous test did not clean up #@target"
      File.open(@latest, 'w') { |fh| fh.puts 'Content of the xml' }
      agent = flexmock 'agent'
      page = flexmock 'page'
      page.should_receive(:body).and_return('Content of the xml')
      agent.should_receive(:get).and_return(page)
      @plugin.get_latest_file(agent)
      assert !File.exist?(@target), "#@target should not have been saved"
    end
    def test_get_latest_file__replace
      assert !File.exist?(@latest), "A previous test did not clean up #@latest"
      assert !File.exist?(@target), "A previous test did not clean up #@target"
      File.open(@latest, 'w') { |fh| fh.puts 'Content of a previous xml' }
      agent = flexmock 'agent'
      page = flexmock 'page'
      page.should_receive(:body).and_return('Content of the xml')
      agent.should_receive(:get).and_return(page)
      @plugin.get_latest_file(agent)
      assert File.exist?(@target), "#@target was not saved"
    end
    def test_update_company__create
      row = @workbook.worksheet(0).row(3)
      name = 'Bayer (Schweiz) AG'
      @app.should_receive(:company_by_name).with(name)
      ptr = Persistence::Pointer.new(:company)
      @app.should_receive(:update).with(ptr.creator, { :name => name })\
        .times(1).and_return { assert true }
      @plugin.update_company(row)
    end
    def test_update_registration__create
      row = @workbook.worksheet(0).row(3)
      company = flexmock 'company'
      @app.should_receive(:indication_by_text).and_return nil
      ptr = Persistence::Pointer.new(:indication)
      args = {:de=>"Analgetikum, Antipyretikum"}
      @app.should_receive(:update).with(ptr.creator, args, :swissmedic)\
        .times(1).and_return { assert true }
      @app.should_receive(:company_by_name)\
        .with('Bayer (Schweiz) AG').and_return company
      company.should_receive(:pointer).and_return 'company-pointer'
      @app.should_receive(:registration).with('08537')
      ptr = Persistence::Pointer.new([:registration, '08537'])
      args = {
        :product_group       => 'OTC',
        :index_therapeuticus => '01.01.1.', 
        :production_science  => 'Synthetika human',
        :registration_date   => Date.new(1936,6,30),
        :expiration_date     => Date.new(2012,5,9),
        :company             => 'company-pointer',
        :renewal_flag        => false,
      }
      @app.should_receive(:update).with(ptr.creator, args, :swissmedic)\
        .times(1).and_return { assert true }
      @plugin.update_registration(row, :date => Date.new(2008,3,19))
    end
    def test_update_registration__update
      row = @workbook.worksheet(0).row(3)
      indication = flexmock 'indication'
      indication.should_receive(:pointer).and_return 'indication-pointer'
      @app.should_receive(:indication_by_text).with("Analgetikum, Antipyretikum")\
        .and_return indication
      company = flexmock 'company'
      @app.should_receive(:company_by_name)\
        .with('Bayer (Schweiz) AG').and_return company
      company.should_receive(:pointer).and_return 'company-pointer'
      registration = flexmock 'registration'
      @app.should_receive(:registration).with('08537').and_return registration
      ptr = Persistence::Pointer.new([:registration, '08537'])
      registration.should_receive(:pointer).and_return ptr
      args = {
        :product_group       => 'OTC',
        :index_therapeuticus => '01.01.1.', 
        :production_science  => 'Synthetika human',
        :registration_date   => Date.new(1936,6,30),
        :expiration_date     => Date.new(2012,5,9),
        :company             => 'company-pointer',
        :renewal_flag        => false,
        :indication          => 'indication-pointer',
      }
      @app.should_receive(:update).with(ptr, args, :swissmedic)\
        .times(1).and_return { assert true }
      @plugin.update_registration(row, :date => Date.new(2008,3,19))
    end
    def test_update_registration__ignore_vet
      row = @workbook.worksheet(0).row(7)
      assert_nothing_raised {
        @plugin.update_registration(row)
      }
    end
    def test_update_registration__phyto
      row = @workbook.worksheet(0).row(4)
      company = flexmock 'company'
      @app.should_receive(:company_by_name)\
        .with('Hänseler AG').and_return company
      company.should_receive(:pointer).and_return 'company-pointer'
      registration = flexmock 'registration'
      @app.should_receive(:registration).with('08599').and_return registration
      ptr = Persistence::Pointer.new([:registration, '08599'])
      registration.should_receive(:pointer).and_return ptr
      args = {
        :product_group       => 'KPA',
        :index_therapeuticus => '12.02.4.', 
        :production_science  => 'Phytotherapeutika',
        :registration_date   => Date.new(1930,9,6),
        :expiration_date     => Date.new(2010,9,6),
        :company             => 'company-pointer',
        :complementary_type  => 'phytotherapy',
        :renewal_flag        => false,
      }
      @app.should_receive(:update).with(ptr, args, :swissmedic)\
        .times(1).and_return { assert true }
      @plugin.update_registration(row, :date => Date.new(2008,3,19))
    end
    def test_update_registration__anthropo
      row = @workbook.worksheet(0).row(6)
      company = flexmock 'company'
      @app.should_receive(:company_by_name)\
        .with('Weleda AG').and_return company
      company.should_receive(:pointer).and_return 'company-pointer'
      registration = flexmock 'registration'
      @app.should_receive(:registration).with('09232').and_return registration
      ptr = Persistence::Pointer.new([:registration, '09232'])
      registration.should_receive(:pointer).and_return ptr
      args = {
        :product_group       => 'KPA',
        :index_therapeuticus => '20.02.0.', 
        :production_science  => 'Anthroposophika',
        :registration_date   => Date.new(1937,9,21),
        :expiration_date     => Date.new(2011,11,1),
        :company             => 'company-pointer',
        :complementary_type  => 'anthroposophy',
        :renewal_flag        => false,
      }
      @app.should_receive(:update).with(ptr, args, :swissmedic)\
        .times(1).and_return { assert true }
      @plugin.update_registration(row, :date => Date.new(2008,3,19))
    end
    def test_update_registration__homoeo
      row = @workbook.worksheet(0).row(8)
      company = flexmock 'company'
      @app.should_receive(:company_by_name)\
        .with('Iromedica AG').and_return company
      company.should_receive(:pointer).and_return 'company-pointer'
      registration = flexmock 'registration'
      @app.should_receive(:registration).with('10999').and_return registration
      ptr = Persistence::Pointer.new([:registration, '10999'])
      registration.should_receive(:pointer).and_return ptr
      args = {
        :product_group       => 'KPA',
        :index_therapeuticus => '20.01.0.', 
        :production_science  => 'Homöopathika',
        :registration_date   => Date.new(1935,9,5),
        :expiration_date     => Date.new(2011,11,6),
        :company             => 'company-pointer',
        :complementary_type  => 'homeopathy',
        :renewal_flag        => false,
      }
      @app.should_receive(:update).with(ptr, args, :swissmedic)\
        .times(1).and_return { assert true }
      @plugin.update_registration(row, :date => Date.new(2008,3,19))
    end
    def test_update_registration__renewal
      row = @workbook.worksheet(0).row(3)
      indication = flexmock 'indication'
      indication.should_receive(:pointer).and_return 'indication-pointer'
      @app.should_receive(:indication_by_text).with("Analgetikum, Antipyretikum")\
        .and_return indication
      company = flexmock 'company'
      @app.should_receive(:company_by_name)\
        .with('Bayer (Schweiz) AG').and_return company
      company.should_receive(:pointer).and_return 'company-pointer'
      registration = flexmock 'registration'
      @app.should_receive(:registration).with('08537').and_return registration
      ptr = Persistence::Pointer.new([:registration, '08537'])
      registration.should_receive(:pointer).and_return ptr
      args = {
        :product_group       => 'OTC',
        :index_therapeuticus => '01.01.1.', 
        :production_science  => 'Synthetika human',
        :registration_date   => Date.new(1936,6,30),
        :expiration_date     => Date.new(2012,5,9),
        :company             => 'company-pointer',
        :renewal_flag        => true,
        :indication          => 'indication-pointer',
      }
      @app.should_receive(:update).with(ptr, args, :swissmedic)\
        .times(1).and_return { assert true }
      @plugin.update_registration(row, :date => Date.new(2012,5,10))
    end
    def test_update_sequence__create
      row = @workbook.worksheet(0).row(3)
      reg = flexmock 'registration'
      ptr = Persistence::Pointer.new([:registration, '08537'])
      reg.should_receive(:pointer).and_return ptr
      reg.should_receive(:sequence).with('01')
      atc = flexmock 'atc'
      atc.should_receive(:code).and_return 'A01BC23'
      reg.should_receive(:atc_classes).and_return [atc]
      sptr = Persistence::Pointer.new([:registration, '08537'], [:sequence, '01'])
      args = { 
        :name_base        => "Aspirin",
        :name_descr       => "Tabletten",
        :composition_text => "acidum acetylsalicylicum 500 mg, excipiens pro compresso.",
        :atc_class        => "A01BC23",
        :dose             => nil,
      }
      @app.should_receive(:update).with(sptr.creator, args, :swissmedic)\
        .times(1).and_return { assert true }
      @plugin.update_sequence reg, row
    end
    def test_update_package__create
      row = @workbook.worksheet(0).row(3)
      reg = flexmock 'registration'
      seq = flexmock 'sequence'
      ptr = Persistence::Pointer.new([:registration, '08537'], [:sequence, '01'])
      seq.should_receive(:pointer).and_return ptr
      reg.should_receive(:package).with('011')
      seq.should_receive(:name_base).and_return 'existing sequence'
      comp = flexmock 'composition'
      comp.should_receive(:pointer).and_return 'composition-pointer'
      seq.should_receive(:compositions).and_return [ comp ]
      pptr = Persistence::Pointer.new([:registration, '08537'], 
                                      [:sequence, '01'], [:package, '011'])
      comform = flexmock 'commercial form'
      comform.should_receive(:pointer).and_return 'comform-pointer'
      @app.should_receive(:commercial_form_by_name).with('Tablette(n)')\
        .and_return comform
      args = {
        :ikscat            => "D",
        :refdata_override  => true,
        :swissmedic_source => {
          :atc_class       => "N02BA01",
          :composition     => "acidum acetylsalicylicum 500 mg, excipiens pro compresso.", 
          :company         => "Bayer (Schweiz) AG", 
          :product_group   => "OTC", 
          :name_base       => "Aspirin, Tabletten", 
          :iksnr           => "08537", 
          :import_date     => @@today, 
          :ikscat          => "D", 
          :expiry_date     => Date.new(2012,5,9), 
          :index_therapeuticus => "01.01.1.", 
          :seqnr           => "01", 
          :ikscd           => "011", 
          :production_science => "Synthetika human", 
          :unit            => "Tablette(n)", 
          :registration_date => Date.new(1936,6,30), 
          :size            => "20", 
          :substances      => "acidum acetylsalicylicum",
          :indication_sequence => nil,
          :indication_registration => 'Analgetikum, Antipyretikum',
        }
      }
      pac = flexmock 'package'
      pac.should_receive(:pointer).and_return pptr
      @app.should_receive(:update).with(pptr.creator, args, :swissmedic)\
        .times(1).and_return { 
        assert true 
        pac
      }
      pac.should_receive(:parts).and_return []
      ptptr = pptr + :part
      part = flexmock 'part'
      part.should_receive(:pointer).and_return('part-pointer')
      part.should_ignore_missing
      @app.should_receive(:create).times(1).with(ptptr).and_return part
      args = {
        :commercial_form   => 'comform-pointer',
        :composition       => 'composition-pointer',
        :size              => "20 Tablette(n)",
      }
      @app.should_receive(:update).with('part-pointer', args, :swissmedic)\
        .times(1).and_return { 
        assert true 
        part
      }
      @plugin.update_package reg, seq, row
    end
    def test_update_package__create__replacement
      row = @workbook.worksheet(0).row(3)
      reg = flexmock 'registration'
      seq = flexmock 'sequence'
      ptr = Persistence::Pointer.new([:registration, '08537'], [:sequence, '01'])
      seq.should_receive(:pointer).and_return ptr
      seq.should_receive(:name_base).and_return 'existing sequence'
      comp = flexmock 'composition'
      comp.should_receive(:pointer).and_return 'composition-pointer'
      seq.should_receive(:compositions).and_return [ comp ]
      pac = flexmock 'package'
      pac.should_receive(:pharmacode).and_return '1234567'
      pac.should_receive(:ancestors).and_return nil
      pac.should_ignore_missing
      reg.should_receive(:package).with('007').and_return pac
      reg.should_receive(:package).with('011')
      pptr = Persistence::Pointer.new([:registration, '08537'], 
                                      [:sequence, '01'], [:package, '011'])
      comform = flexmock 'commercial form'
      comform.should_receive(:pointer).and_return 'comform-pointer'
      @app.should_receive(:commercial_form_by_name).with('Tablette(n)')\
        .and_return comform
      args = {
        :ikscat          => "D",
        :refdata_override=> true,
        :pharmacode      => '1234567',
        :ancestors       => ['007'],
        :swissmedic_source => {
          :atc_class       => "N02BA01",
          :composition     => "acidum acetylsalicylicum 500 mg, excipiens pro compresso.", 
          :company         => "Bayer (Schweiz) AG", 
          :product_group   => "OTC", 
          :name_base       => "Aspirin, Tabletten", 
          :iksnr           => "08537", 
          :import_date     => @@today, 
          :ikscat          => "D", 
          :expiry_date     => Date.new(2012,5,9), 
          :index_therapeuticus => "01.01.1.", 
          :seqnr           => "01", 
          :ikscd           => "011", 
          :production_science => "Synthetika human", 
          :unit            => "Tablette(n)", 
          :registration_date => Date.new(1936,6,30), 
          :size            => "20", 
          :substances      => "acidum acetylsalicylicum",
          :indication_sequence => nil,
          :indication_registration => 'Analgetikum, Antipyretikum',
        }
      }
      @app.should_receive(:update).with(pptr.creator, args, :swissmedic)\
        .times(1).and_return { 
        assert true 
        pac
      }
      pac.should_receive(:parts).and_return []
      pac.should_receive(:pointer).and_return pptr
      ptptr = pptr + :part
      part = flexmock 'part'
      part.should_receive(:pointer).and_return('part-pointer')
      part.should_ignore_missing
      @app.should_receive(:create).times(1).with(ptptr).and_return part
      args = {
        :commercial_form   => 'comform-pointer',
        :composition       => 'composition-pointer',
        :size              => "20 Tablette(n)",
      }
      @app.should_receive(:update).with('part-pointer', args, :swissmedic)\
        .times(1).and_return { 
        assert true 
        part
      }
      @plugin.update_package reg, seq, row, {row => '007'}
    end
    def test_update_package__update
      row = @workbook.worksheet(0).row(3)
      reg = flexmock 'registration'
      seq = flexmock 'sequence'
      ptr = Persistence::Pointer.new([:registration, '08537'], [:sequence, '01'])
      seq.should_receive(:pointer).and_return ptr
      pac = flexmock 'package'
      reg.should_receive(:package).with('011').and_return pac
      seq.should_receive(:name_base).and_return 'existing sequence'
      pptr = Persistence::Pointer.new([:registration, '08537'], 
                                      [:sequence, '01'], [:package, '011'])
      pac.should_receive(:pointer).and_return pptr
      comform = flexmock 'commercial form'
      comform.should_receive(:pointer).and_return 'comform-pointer'
      @app.should_receive(:commercial_form_by_name).with('Tablette(n)')\
        .and_return comform
      args = {
        :ikscat          => "D",
        :swissmedic_source => {
          :atc_class       => "N02BA01",
          :composition     => "acidum acetylsalicylicum 500 mg, excipiens pro compresso.", 
          :company         => "Bayer (Schweiz) AG", 
          :product_group   => "OTC", 
          :name_base       => "Aspirin, Tabletten", 
          :iksnr           => "08537", 
          :import_date     => @@today, 
          :ikscat          => "D", 
          :expiry_date     => Date.new(2012,5,9), 
          :index_therapeuticus => "01.01.1.", 
          :seqnr           => "01", 
          :ikscd           => "011", 
          :production_science => "Synthetika human", 
          :unit            => "Tablette(n)", 
          :registration_date => Date.new(1936,6,30), 
          :size            => "20", 
          :substances      => "acidum acetylsalicylicum",
          :indication_sequence => nil,
          :indication_registration => 'Analgetikum, Antipyretikum',
        }
      }
      @app.should_receive(:update).with(pptr, args, :swissmedic)\
        .times(1).and_return { 
        assert true
        pac
      }
      part = flexmock 'part'
      part.should_receive(:composition).and_return 'some composition'
      part.should_receive(:pointer).and_return 'part-pointer'
      pac.should_receive(:parts).and_return [part]
      args = {
        :commercial_form   => 'comform-pointer',
        :size              => "20 Tablette(n)",
      }
      @app.should_receive(:update).with('part-pointer', args, :swissmedic)\
        .times(1).and_return { 
        assert true
        pac
      }
      @plugin.update_package reg, seq, row
    end
    def test_update_composition__create
      row = @workbook.worksheet(0).row(3)
      seq = flexmock 'sequence'
      ptr = Persistence::Pointer.new([:registration, '08537'], [:sequence, '01'])
      seq.should_receive(:pointer).and_return ptr
      seq.should_receive(:active_agents).and_return []
      seq.should_receive(:compositions).and_return []
      @app.should_receive(:substance).with('Acidum Acetylsalicylicum')
      sptr = Persistence::Pointer.new([:substance]).creator
      args = { :lt => 'Acidum Acetylsalicylicum' }
      @app.should_receive(:update).with(sptr, args, :swissmedic)\
        .times(1).and_return { assert true }
      comp = flexmock 'composition'
      comp.should_receive(:active_agent).with('Acidum Acetylsalicylicum')
      comp.should_receive(:active_agents).and_return []
      cptr = ptr + [:composition, 'id']
      comp.should_receive(:pointer).and_return(cptr)
      @app.should_receive(:create).with(ptr + :composition).and_return comp
      aptr = cptr + [:active_agent, 'Acidum Acetylsalicylicum']
      args =  {
        :substance => 'Acidum Acetylsalicylicum',
        :dose      => ["500", 'mg'],
      }
      @app.should_receive(:update).with(aptr.creator, args, :swissmedic)\
        .times(1).and_return { assert true }
      @plugin.update_composition(seq, row)
    end
    def test_update_composition__focus_on_doses
      row = @workbook.worksheet(0).row(6)
      seq = flexmock 'sequence'
      ptr = Persistence::Pointer.new([:registration, '08537'], [:sequence, '01'])
      seq.should_receive(:pointer).and_return ptr
      seq.should_receive(:active_agents).and_return []
      seq.should_receive(:compositions).and_return []
      sub = flexmock 'substance'
      sub.should_receive(:pointer).and_return 'substance-pointer'
      @app.should_receive(:substance).and_return sub
      act = flexmock 'active-agent'
      act.should_receive(:pointer).and_return 'active-agent-pointer'
      comp = flexmock 'composition'
      comp.should_receive(:active_agent).and_return act
      comp.should_receive(:active_agents).and_return []
      cptr = ptr + [:composition, 'id']
      comp.should_receive(:pointer).and_return(cptr)
      @app.should_receive(:create).with(ptr + :composition).and_return comp
      aptr = cptr + [:active_agent, 'Acidum Acetylsalicylicum']
      args =  [
        { :dose => ["10", 'mg/g'], :substance => 'Berberidis Fructus Recens' },
        { :dose => ["10", "mg/g"], 
          :substance => "Pruni Spinosae Fructus Recens" },
        { :dose => ["12", "mg/g"], 
          :substance => "Echinaceae Purpureae Planta Tota Recens" },
        { :dose => ["0.1", "mg/g"], :substance => "Bryoniae Radix Recens" },
        { :dose => ["1.1", "mg/g"], :substance=>"Esculosidum" },
        { :dose => ["0.12", "mg/g"], :substance => "Dextrocamphora" },
        { :dose => ["3.88", "mg/g"], :substance => "Eucalypti Aetheroleum" },
        { :dose => ["3.88", "mg/g"],
          :substance => "Menthae Piperitae Aetheroleum" },
        { :dose=>["0.12", "mg/g"], :substance => "Thymi Aetheroleum" },
      ]
      @app.should_receive(:update)\
        .with('active-agent-pointer', Hash, :swissmedic)\
        .times(9).and_return { |ptr, data, key|
          assert_equal args.shift, data
      }
      @plugin.update_composition(seq, row)
    end
    def test_update_composition__focus_on_doses_percent
      row = @workbook.worksheet(0).row(8)
      seq = flexmock 'sequence'
      ptr = Persistence::Pointer.new([:registration, '08537'], [:sequence, '01'])
      seq.should_receive(:pointer).and_return ptr
      seq.should_receive(:active_agents).and_return []
      seq.should_receive(:compositions).and_return []
      sub = flexmock 'substance'
      sub.should_receive(:pointer).and_return 'substance-pointer'
      @app.should_receive(:substance).and_return sub
      act = flexmock 'active-agent'
      act.should_receive(:pointer).and_return 'active-agent-pointer'
      comp = flexmock 'composition'
      comp.should_receive(:active_agent).and_return act
      comp.should_receive(:active_agents).and_return []
      cptr = ptr + [:composition, 'id']
      comp.should_receive(:pointer).and_return(cptr)
      @app.should_receive(:create).with(ptr + :composition).and_return comp
      aptr = cptr + [:active_agent, 'Acidum Acetylsalicylicum']
      args =  [
        { :dose => ["5", '%'], :substance => 'Calcii Carbonas Hahnemanni C7' },
        { :dose => ["22.5", '%'], :substance => 'Chamomilla Recutita D5' },
        { :dose => ["50", '%'], :substance => 'Magnesii Phosphas C5' },
        { :dose => ["22.5", '%'], :substance => 'Passiflora Incarnata D5' },
      ]
      @app.should_receive(:update)\
        .with('active-agent-pointer', Hash, :swissmedic)\
        .times(4).and_return { |ptr, data, key|
          assert_equal args.shift, data
      }
      @plugin.update_composition(seq, row)
    end
    def test_update_composition__focus_on_doses_qty_in_scale
      row = @workbook.worksheet(0).row(20)
      seq = flexmock 'sequence'
      ptr = Persistence::Pointer.new([:registration, '08537'], [:sequence, '01'])
      seq.should_receive(:pointer).and_return ptr
      seq.should_receive(:active_agents).and_return []
      seq.should_receive(:compositions).and_return []
      sub = flexmock 'substance'
      sub.should_receive(:pointer).and_return 'substance-pointer'
      @app.should_receive(:substance).and_return sub
      act = flexmock 'active-agent'
      act.should_receive(:pointer).and_return 'active-agent-pointer'
      comp = flexmock 'composition'
      comp.should_receive(:active_agent).and_return act
      comp.should_receive(:active_agents).and_return []
      cptr = ptr + [:composition, 'id']
      comp.should_receive(:pointer).and_return(cptr)
      @app.should_receive(:create).with(ptr + :composition).and_return comp
      aptr = cptr + [:active_agent, 'Acidum Acetylsalicylicum']
      args =  [
        { :dose => ["100", 'µg/25 mg'], 
          :substance => 'Fluticasoni-17 Propionas' },
      ]
      @app.should_receive(:update)\
        .with('active-agent-pointer', Hash, :swissmedic)\
        .times(1).and_return { |ptr, data, key|
          assert_equal args.shift, data
      }
      @plugin.update_composition(seq, row)
    end
    def test_update_composition__update
      row = @workbook.worksheet(0).row(3)
      seq = flexmock 'sequence'
      ptr = Persistence::Pointer.new([:registration, '08537'], [:sequence, '01'])
      seq.should_receive(:pointer).and_return ptr
      comp = flexmock 'composition'
      seq.should_receive(:compositions).and_return [comp]
      substance = flexmock 'substance'
      substance.should_receive(:same_as?).with('Acidum Acetylsalicylicum').and_return true
      #sptr = Persistence::Pointer.new([:substance, 12])
      @app.should_receive(:substance).with('Acidum Acetylsalicylicum')\
        .and_return substance
      aptr = ptr + [:active_agent, 'Acidum Acetylsalicylicum']
      agent = flexmock 'active-agent'
      agent.should_receive(:pointer).and_return aptr
      agent.should_receive(:substance).and_return substance
      comp.should_receive(:active_agents).and_return [agent]
      comp.should_receive(:active_agent).with('Acidum Acetylsalicylicum')\
        .and_return agent
      args =  {
        :substance => 'Acidum Acetylsalicylicum',
        :dose      => ['500', 'mg'],
      }
      @app.should_receive(:update).with(aptr, args, :swissmedic)\
        .times(1).and_return { assert true }
      @plugin.update_composition(seq, row)
    end
    def test_update_composition__chemical_form
      row = @workbook.worksheet(0).row(9)
      seq = flexmock 'sequence'
      ptr = Persistence::Pointer.new([:registration, '08537'], [:sequence, '01'])
      seq.should_receive(:pointer).and_return ptr
      comp = flexmock 'composition'
      comp.should_receive(:active_agents).and_return []
      seq.should_receive(:compositions).and_return [comp]
      substance1 = flexmock 'substance1'
      substance1.should_receive(:pointer).and_return 'substance-ptr'
      @app.should_receive(:substance).with('Procainum')\
        .and_return substance1
      equivalence = flexmock 'equivalence'
      equivalence.should_receive(:pointer).and_return 'equi-ptr'
      @app.should_receive(:substance).with('Procaini Hydrochloridum')\
        .and_return equivalence
      substance2 = flexmock 'substance2'
      @app.should_receive(:substance).with('Phenazonum')\
        .and_return substance2
      aptr1 = ptr + [:active_agent, 'Procainum']
      agent1 = flexmock 'active-agent1'
      agent1.should_receive(:pointer).and_return aptr1
      comp.should_receive(:active_agent).with('Procainum')\
        .and_return agent1
      aptr2 = ptr + [:active_agent, 'Phenazonum']
      agent2 = flexmock 'active-agent1'
      agent2.should_receive(:pointer).and_return aptr2
      comp.should_receive(:active_agent).with('Phenazonum')\
        .and_return agent2
      args =  {
        :substance          => 'Procainum',
        :dose               => %w{10 mg/g},
        :chemical_substance => 'Procaini Hydrochloridum',
        :chemical_dose      => nil,
      }
      @app.should_receive(:update).with(aptr1, args, :swissmedic)\
        .times(1).and_return { assert true }
      args =  {
        :substance          => 'Phenazonum',
        :dose               => %w'50 mg/g',
      }
      @app.should_receive(:update).with(aptr2, args, :swissmedic)\
        .times(1).and_return { assert true }
      args =  {
        :effective_form => 'substance-ptr',
      }
      @plugin.update_composition(seq, row)
    end
    def test_update_composition__delete
      row = @workbook.worksheet(0).row(3)
      seq = flexmock 'sequence'
      ptr = Persistence::Pointer.new([:registration, '08537'], [:sequence, '01'])
      seq.should_receive(:pointer).and_return ptr
      comp = flexmock 'composition'
      seq.should_receive(:compositions).and_return [comp]
      substance = flexmock 'substance'
      substance.should_receive(:same_as?).with('Acidum Acetylsalicylicum').and_return false
      #sptr = Persistence::Pointer.new([:substance, 12])
      @app.should_receive(:substance).with('Acidum Acetylsalicylicum')\
        .and_return substance
      aptr = ptr + [:active_agent, 'Acidum Acetylsalicylicum']
      agent = flexmock 'active-agent'
      agent.should_receive(:pointer).and_return aptr
      agent.should_receive(:substance).and_return substance
      comp.should_receive(:active_agents).and_return [agent]
      comp.should_receive(:active_agent).with('Acidum Acetylsalicylicum')\
        .and_return agent
      args =  {
        :substance => 'Acidum Acetylsalicylicum',
        :dose      => ['500', 'mg'],
      }
      @app.should_receive(:update).with(aptr, args, :swissmedic)\
        .times(1).and_return { assert true }
      @app.should_receive(:delete).with(aptr)\
        .times(1).and_return { assert true }
      @plugin.update_composition(seq, row)
    end
    def test_update_galenic_form__dont_update__descr
      row = @workbook.worksheet(0).row(3)
      seq = flexmock 'sequence'
      seq.should_receive(:name_descr).and_return 'Tabletten'
      seq.should_receive(:pointer).and_return 'sequence-ptr'
      comp = flexmock 'composition'
      galform = flexmock 'galform'
      comp.should_receive(:galenic_form).and_return galform
      @plugin.update_galenic_form(seq, comp, row)
    end
    def test_update_galenic_form__dont_update__composition
      row = @workbook.worksheet(0).row(3)
      seq = flexmock 'sequence'
      seq.should_receive(:name_descr)
      seq.should_receive(:pointer).and_return 'sequence-ptr'
      @app.should_receive(:galenic_form).with('Tabletten')
      comp = flexmock 'composition'
      galform = flexmock 'galenic-form'
      comp.should_receive(:galenic_form).and_return galform
      @plugin.update_galenic_form(seq, comp, row)
    end
    def test_update_galenic_form__create__descr
      row = @workbook.worksheet(0).row(3)
      seq = flexmock 'sequence'
      seq.should_receive(:name_descr).and_return 'Tabletten'
      comp = flexmock 'composition'
      comp.should_receive(:pointer).and_return 'composition-ptr'
      comp.should_receive(:galenic_form).and_return nil
      @app.should_receive(:galenic_form).with('Tabletten')
      @app.should_receive(:galenic_form).with('compresso')
      args = { :de => 'Tabletten' }
      ptr = Persistence::Pointer.new([:galenic_group, 1], [:galenic_form]).creator
      @app.should_receive(:update).with(ptr, args, :swissmedic)\
        .times(1).and_return { assert true }
      args = { :galenic_form => 'Tabletten' }
      @app.should_receive(:update).with('composition-ptr', args, :swissmedic)\
        .times(1).and_return { assert true }
      @plugin.update_galenic_form(seq, comp, row)
    end
    def test_update_galenic_form__create__composition
      row = @workbook.worksheet(0).row(6)
      seq = flexmock 'sequence'
      seq.should_receive(:name_descr)
      comp = flexmock 'composition'
      comp.should_receive(:pointer).and_return 'composition-ptr'
      comp.should_receive(:galenic_form).and_return nil
      @app.should_receive(:galenic_form).with('unguentum')
      args = { :lt => 'unguentum' }
      ptr = Persistence::Pointer.new([:galenic_group, 1], [:galenic_form]).creator
      @app.should_receive(:update).with(ptr, args, :swissmedic)\
        .times(1).and_return { assert true }
      args = { :galenic_form => 'unguentum' }
      @app.should_receive(:update).with('composition-ptr', args, :swissmedic)\
        .times(1).and_return { assert true }
      @plugin.update_galenic_form(seq, comp, row)
    end
    def test_diff
      result = @plugin.diff(@data, @older)
      assert_equal 3, result.news.size
      assert_equal 'Osanit, homöopathische Kügelchen', 
                   result.news.first.at(2).to_s('latin1')
      assert_equal 7, result.updates.size
      assert_equal 'Weleda Schnupfencrème, anthroposophisches Heilmittel', 
                   result.updates.first.at(2).to_s('latin1')
      assert_equal 6, result.changes.size
      expected = {
        "09232" => [:name_base],
        "10368" => [:delete],
        "10999" => [:new],
        "25144" => [:sequence, :replaced_package],
        "57678" => [:company, :index_therapeuticus, :atc_class, :expiry_date, :ikscat],
        "57699" => [:new],
      }
      assert_equal(expected, result.changes)
      assert_equal 3, result.package_deletions.size
      assert_equal 4, result.package_deletions.first.size
      iksnrs = result.package_deletions.collect { |row| row.at(0) }.sort
      ikscds = result.package_deletions.collect { |row| row.at(2) }.sort
      assert_equal ['10368', '13689', '25144'], iksnrs
      assert_equal ['024', '031', '049'], ikscds
      assert_equal 1, result.sequence_deletions.size
      assert_equal ['10368', '01'], result.sequence_deletions.at(0)
      assert_equal 1, result.registration_deletions.size
      assert_equal ['10368'], result.registration_deletions.at(0)
      assert_equal 1, result.replacements.size
      assert_equal '031', result.replacements.values.first
    end
    def test_diff__initial
      File.delete @initial if File.exist? @initial
      part = flexmock 'part'
      pac = flexmock 'package'
      pac.should_receive(:parts).and_return [ part ]
      seq = flexmock 'sequence'
      seq.should_receive(:packages).and_return({ '001' => pac })
      seq.should_receive(:name_base).and_return 'delete me'
      reg = flexmock 'registration'
      reg.should_receive(:sequences).and_return({ '01' => seq })
      reg.should_receive(:company_name).and_return('ywesee.com')
      reg.should_ignore_missing
      @app.should_receive(:registrations).and_return({ '11111' => reg })
      result = @plugin.diff(@data, @initial)
      assert_equal 17, result.news.size
      assert_equal 'Aspirin, Tabletten', 
                   result.news.first.at(2).to_s('latin1')
      assert_equal 0, result.updates.size
      assert_equal 13, result.changes.size
      deletion = result.changes.delete('11111')
      assert_equal [:delete], deletion
      assert result.changes.all? { |key, flags| flags == [:new] }
      assert_equal 1, result.package_deletions.size
      assert_equal [['11111', '01', '001', 0]], result.package_deletions
      assert_equal 1, result.sequence_deletions.size
      assert_equal 1, result.registration_deletions.size
    end
    def test_delete__packages
      ptr = Persistence::Pointer.new([:registration, '12345'], [:sequence, '01'],
                                     [:package, '234'])
      @app.should_receive(:delete).with(ptr).times(1).and_return { assert true }
      @plugin.delete([['12345', '01', '234']])
    end
    def test_delete__sequences
      ptr = Persistence::Pointer.new([:registration, '12345'], [:sequence, '01'])
      @app.should_receive(:delete).with(ptr).times(1).and_return { assert true }
      @plugin.delete([['12345', '01']])
    end
    def test_delete__registration
      ptr = Persistence::Pointer.new([:registration, '12345'])
      @app.should_receive(:delete).with(ptr).times(1).and_return { assert true }
      @plugin.delete([['12345']])
    end
    def test_to_s
      assert_nothing_raised {
        @plugin.to_s
      }
      result = @plugin.diff(@data, @older)
      assert_equal <<-EOS.strip, @plugin.to_s
+ 10999: Osanit, homöopathische Kügelchen
+ 57699: Pyrazinamide Labatec, comprimés
- 10368: Alcacyl, Tabletten
> 09232: Weleda Schnupfencrème, anthroposophisches Heilmittel; Namensänderung (Weleda Schnupfencrème, anthroposophisches Heilmittel)
> 25144: Panadol, Filmtabletten; Packungs-Nummer (031 -> 048)
> 57678: Amlodipin-besyl-Mepha 5, Tabletten; Zulassungsinhaber (Vifor SA), Index Therapeuticus (07.10.5.), ATC-Code (D11AF), Ablaufdatum der Zulassung (10.05.2017), Abgabekategorie (A)
      EOS
      assert_equal <<-EOS.strip, @plugin.to_s(:name)
- 10368: Alcacyl, Tabletten
> 57678: Amlodipin-besyl-Mepha 5, Tabletten; Zulassungsinhaber (Vifor SA), Index Therapeuticus (07.10.5.), ATC-Code (D11AF), Ablaufdatum der Zulassung (10.05.2017), Abgabekategorie (A)
+ 10999: Osanit, homöopathische Kügelchen
> 25144: Panadol, Filmtabletten; Packungs-Nummer (031 -> 048)
+ 57699: Pyrazinamide Labatec, comprimés
> 09232: Weleda Schnupfencrème, anthroposophisches Heilmittel; Namensänderung (Weleda Schnupfencrème, anthroposophisches Heilmittel)
      EOS
      assert_equal <<-EOS.strip, @plugin.to_s(:registration)
> 09232: Weleda Schnupfencrème, anthroposophisches Heilmittel; Namensänderung (Weleda Schnupfencrème, anthroposophisches Heilmittel)
- 10368: Alcacyl, Tabletten
+ 10999: Osanit, homöopathische Kügelchen
> 25144: Panadol, Filmtabletten; Packungs-Nummer (031 -> 048)
> 57678: Amlodipin-besyl-Mepha 5, Tabletten; Zulassungsinhaber (Vifor SA), Index Therapeuticus (07.10.5.), ATC-Code (D11AF), Ablaufdatum der Zulassung (10.05.2017), Abgabekategorie (A)
+ 57699: Pyrazinamide Labatec, comprimés
      EOS
    end
  end
end
