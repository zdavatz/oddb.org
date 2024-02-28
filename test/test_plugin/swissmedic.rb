#!/usr/bin/env ruby
# encoding: utf-8

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'minitest/unit'
require 'test_helpers'
require 'stub/odba'
require 'stub/oddbapp'
require 'util/persistence'
require 'plugin/swissmedic'
require 'model/registration'
require 'model/sequence'
require 'model/package'
require 'flexmock/minitest'
require 'ostruct'
require 'tempfile'
require 'util/log'
require 'util/util'
require 'util/oddbconfig'

class FlexMock::TestUnitFrameworkAdapter
    attr_accessor :assertions
end

module ODDB
  class SwissmedicPlugin
    attr_reader      :recreate_missing,
      :known_export_registrations,
      :known_export_sequences,
      :checked_compositions,
      :deleted_compositions,
      :new_compositions,
      :updated_agents,
      :new_agents,
      :export_registrations,
      :export_sequences,
      :skipped_packages,
      :iksnr_with_wrong_data,
      :active_registrations_praeparateliste,
      :update_time,
      :target_keys,
      :empty_compositions,
      :known_packages,
      :deletes_packages
  end
   class SwissmedicPluginTest < Minitest::Test
    NAME_OFFSET = 2
    INDICATION_OFFSET = 18
    ROW_ASPIRIN = 5 # row in excel -1
    ROW_WELEDA = 8
    ROW_OSANIT = 10
    ROW_AXOTIDE = 19
    IKSNR_WELEDA = "09232"
    EXPIRATION_DATE_ASPIRIN = Date.new(2017,5,9)
    MEDI_NAME = 'Zymafluor 0.25 mg, Tabletten'
    def setup
      # @app = flexmock 'app'
      ODDB::GalenicGroup.reset_oids
      ODBA.storage.reset_id
      @app = flexmock(ODDB::App.new)
      @archive = ODDB::WORK_DIR
      FileUtils.rm_rf(@archive)
      FileUtils.mkdir_p(@archive)
      @plugin = flexmock('plugin', SwissmedicPlugin.new(@app, @archive))
      @state_2019_01_31 = File.join(ODDB::TEST_DATA_DIR, 'xlsx/Packungen-2019.01.31.xlsx')
      @state_2015_07_02 = File.join(ODDB::TEST_DATA_DIR, 'xlsx/Packungen-2015.07.02.xlsx')
      prep_from = File.join(ODDB::TEST_DATA_DIR, 'xlsx/Erweiterte_Arzneimittelliste_HAM_31012019.xlsx')
      @plugin.should_receive(:fetch_with_http).with( ODDB::SwissmedicPlugin.get_packages_url).and_return(File.open(@state_2015_07_02).read).by_default
      @plugin.should_receive(:fetch_with_http).with( ODDB::SwissmedicPlugin.get_preparations_url).and_return(File.open(prep_from).read).by_default
      @target = File.join @archive, 'xls',  @@today.strftime('Packungen-%Y.%m.%d.xlsx')
      @latest = File.join @archive, 'xls', 'Packungen-latest.xlsx'
      FileUtils.makedirs(File.dirname(@latest)) unless File.exist?(File.dirname(@latest))
      FileUtils.rm(@latest) if File.exist?(@latest)

      @test_packages = File.join(ODDB::TEST_DATA_DIR, 'xlsx/Packungen-2019.01.31.xlsx')
      latest_to =      File.join(ODDB::TEST_DATA_DIR, 'xls/Packungen-latest.xlsx')
      FileUtils.cp(@test_packages, latest_to, :verbose => true, :preserve => true)
      FileUtils.cp(prep_from, File.join(@archive, 'xls',  @@today.strftime('Präparateliste-%Y.%m.%d.xlsx')),
                   :verbose => true, :preserve => true)
      FileUtils.cp(prep_from, File.join(@archive, 'xls', 'Erweiterte_Arzneimittelliste_HAM_31012019.xlsx'),
                   :verbose => true, :preserve => true)
      @workbook = Spreadsheet.open( @test_packages)
    end
    def teardown
      ODBA.storage = nil
      super # to clean up FlexMock
    end

    def setup_simple_seq(iksnr = '12345', seqnr='01')
      @ptr = Persistence::Pointer.new([:registration, iksnr], [:sequence, seqnr])
      seq = flexmock 'sequence'
      seq.should_receive(:pointer).and_return @ptr
      seq.should_receive(:seqnr).and_return seqnr
      seq.should_receive(:iksnr).and_return 'iksnr'
      seq.should_receive(:odba_store)
      seq.should_receive(:delete_composition)
      seq.should_receive(:composition_text=)
      seq.should_receive(:composition_text).and_return "composition_text #{iksnr} #{seqnr}"
      seq.should_receive(:delete_composition)
      seq
    end

    def setup_simple_agent(name)
      aptr = @ptr + [:active_agent, name]
      agent = flexmock "active-agent-#{name}"
      substance = flexmock "substance-#{name}"
      agent.should_receive(:pointer).and_return aptr
      agent.should_receive(:oid).and_return 'oid'
      agent.should_receive(:dose).and_return 'dose'
      agent.should_receive(:substance).and_return substance
      agent.should_receive(:chemical_dose).and_return 'chemical_dose'
      agent.should_receive(:chemical_substance).and_return 'chemical_substance'
      substance.should_receive(:pointer).and_return "substance-ptr-#{name}"
      substance.should_receive(:oid).and_return 'oid'
      return agent, substance
    end

    def setup_active_agent(name='active-agent')
      act = flexmock name
      act.should_receive(:oid).and_return "#{name}-oid"
      act.should_receive(:pointer).and_return "#{name}-pointer"
      act.should_receive(:pointer=).and_return "#{name}-pointer"
      act.should_receive(:dose).and_return 'dose'
      act.should_receive(:substance).and_return 'substance'
      act.should_receive(:chemical_dose).and_return 'chemical_dose'
      act.should_receive(:chemical_substance).and_return 'chemical_substance'
      act
    end

    def test_get_latest_file__identical
      content = 'Content of the xml'
      assert !File.exist?(@latest), "A previous test did not clean up #@latest"
      assert !File.exist?(@target), "A previous test did not clean up #@target"
      File.open(@latest, 'wb+') { |f| f.write content }
      @plugin.get_latest_file('Packungen')
      assert File.exist?(@latest), "#{@latest} should have been saved"
      assert File.exist?(@target), "#{@target} should have been saved"
    end

    def test_get_latest_file__new
      assert !File.exist?(@latest), "A previous test did not clean up #@latest"
      assert !File.exist?(@target), "A previous test did not clean up #@target"
      @plugin.get_latest_file('Packungen')
      assert File.exist?(@target), "#@target was not saved"
    end

    def test_get_latest_file__replace
      assert !File.exist?(@latest), "A previous test did not clean up #@latest"
      assert !File.exist?(@target), "A previous test did not clean up #@target"
      File.open(@latest, 'w') { |fh| fh.puts 'Content of a previous xml' }
      @plugin.get_latest_file('Packungen')
      assert File.exist?(@target), "#@target was not saved"
    end

    def test_update_company__create
      # 15219	1	Zymafluor 0.25 mg, Tabletten	MEDA Pharma GmbH	Synthetika human	13.05.1.	A01AA01	15.06.50	15.06.50	31.12.17	068	400	Tablette(n)	C	C	C	fluoridum	fluoridum 0.25 mg ut natrii fluoridum, aromatica, excipiens pro compresso.		Kariesprophylaxe
      row = @workbook.worksheet(0).find { |x| /Zymafluor/.match x[2].value};

      name = 'MEDA Pharma GmbH'
      @app.should_receive(:company_by_name).with(name, 0.8)
      ptr = Persistence::Pointer.new(:company)
      args = { :name => name, :business_area => 'ba_pharma' }
      @app.should_receive(:update).with(ptr.creator, args)\
        .times(1).and_return { assert true }
      @plugin.update_company(row)
    end

    def stdout_null
      require 'tempfile'
      $stdout = Tempfile.open('stdout')
      yield
    ensure
      $stdout.close
      $stdout = STDOUT
    end
    def test_update_registration__error
      registration = flexmock('registration', :pointer => 'pointer')
      company = flexmock('company', :pointer => 'pointer')
      update  = flexmock('update', :pointer => 'pointer')
      flexmock(@app,
               :registration    => registration,
               :company_by_name => company
              )
      flexmock(@app).should_receive(:update).and_raise(SystemStackError)
      row = []
      flexmock(@plugin, :date_cell => Date.today + 2)
      stdout_null do
        assert_nil(@plugin.update_registration(row))
      end
    end

    def test_update_sequence__create
      row = @workbook.worksheet(0).find { |x| /Zymafluor/.match x[2].value};
      assert_equal(MEDI_NAME, row[NAME_OFFSET].value)
      reg = flexmock 'registration'
      # 15219	1	Zymafluor 0.25 mg, Tabletten	MEDA Pharma GmbH	Synthetika human	13.05.1.	A01AA01	15.06.50	15.06.50	31.12.17	068	400	Tablette(n)	C	C	C	fluoridum	fluoridum 0.25 mg ut natrii fluoridum, aromatica, excipiens pro compresso.		Kariesprophylaxe
      reg_nr = '15219'
      ptr = Persistence::Pointer.new([:registration, reg_nr])
      ptr= flexmock('registration_fake')
      ptr.should_receive(:update).with_any_args.and_return 'update'
      reg.should_receive(:pointer).and_return ptr
      seq = flexmock 'sequence'
      seq.should_receive(:seqnr).and_return 'seqnr'
      # seq.should_receive(:atc_class).and_return 'atc_class'
      reg.should_receive(:sequence).with('00').and_return(nil)
      reg.should_receive(:sequence).with('01').and_return(seq)
      j06aa = ODDB::AtcClass.new('J06AA')
      a010aa01 = ODDB::AtcClass.new('A01AA01')
      reg.should_receive(:iksnr).and_return reg_nr
      reg.should_receive(:atc_classes).and_return [a010aa01]
      seq.should_receive(:atc_class).and_return j06aa
      j06aa.descriptions[:de]='description for j06aa'
      a010aa01.descriptions[:de]='description for a010aa01'
      @app.should_receive(:atc_class).with('J06AA').and_return a010aa01
      @app.should_receive(:atc_class).with('a010aa01').and_return a010aa01
      sptr = Persistence::Pointer.new([:registration, reg_nr], [:sequence, '01'])
      seq.should_receive(:pointer).and_return sptr
      args = {
        :composition_text => "fluoridum 0.25 mg ut natrii fluoridum, aromatica, excipiens pro compresso.",
        :name_base        =>"Zymafluor 0.25 mg",
        :name_descr       =>"Tabletten",
        :dose             =>nil,
        :sequence_date    => Date.new(1950,6,15),
        :export_flag      =>nil,
      }
      @app.should_receive(:update).with(sptr, args, :swissmedic).and_return 'update_with_expected_args'
      result = @plugin.update_sequence reg, row
      assert_equal('update_with_expected_args', result)
    end


    def test_update_galenic_form__dont_update__descr
      row = @workbook.worksheet(0).find { |x| /Zymafluor/.match x[2].value};  
      assert_equal(MEDI_NAME, row[NAME_OFFSET].value)

      seq = flexmock 'sequence'
      seq.should_receive(:name_descr).and_return 'Tabletten'
      seq.should_receive(:pointer).and_return 'sequence-ptr'
      seq.should_receive(:seqnr).and_return 'seqnr'
      comp = flexmock 'composition'
      galform = flexmock 'galform'
      comp.should_receive(:galenic_form).and_return galform
      @plugin.update_galenic_form(seq, comp, row)
      assert true
    end
    def test_update_galenic_form__dont_update__composition
      row = @workbook.worksheet(0).find { |x| /Zymafluor/.match x[2].value};  assert_equal(MEDI_NAME, row[NAME_OFFSET].value)

      seq = flexmock 'sequence'
      seq.should_receive(:name_descr)
      seq.should_receive(:pointer).and_return 'sequence-ptr'
      seq.should_receive(:seqnr).and_return 'seqnr'
      @app.should_receive(:galenic_form).with('Tabletten')
      comp = flexmock 'composition'
      galform = flexmock 'galenic-form'
      comp.should_receive(:galenic_form).and_return galform
      @plugin.update_galenic_form(seq, comp, row)
      assert true
    end
    def test_update_galenic_form__create__descr
      row = @workbook.worksheet(0).find { |x| /Zymafluor/.match x[2].value};  assert_equal(MEDI_NAME, row[NAME_OFFSET].value)

      seq = flexmock 'sequence'
      seq.should_receive(:name_descr).and_return 'Tabletten'
      seq.should_receive(:seqnr).and_return 'seqnr'
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
      row = @workbook.worksheet(0).row(ROW_WELEDA)
      seq = flexmock 'sequence'
      seq.should_receive(:name_descr)
      comp = flexmock 'composition'
      comp.should_receive(:pointer).and_return 'composition-ptr'
      comp.should_receive(:galenic_form).and_return nil
      comp.should_receive(:source).and_return 'extractum ethanolicum liquidum ex berberidis fructus recens 10 mg et pruni spinosae fructus recens 10 mg et echinaceae purpureae planta tota recens 12 mg et bryoniae radix recens 0.1 mg, esculosidum 1.1 mg, dextrocamphora 0.12 mg, eucalypti aetheroleum 3.88 mg, menthae piperitae aetheroleum 3.88 mg, thymi aetheroleum 0.12 mg, adeps lanae (Schaf: Fell/Haare/Wolle), excipiens ad unguentum pro 1 g.'
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
    def test__update_galenic_form
      flexmock(@app, :update => 'update')
      flexmock(@app, :galenic_form => nil)
      composition = flexmock('composition', :pointer => 'pointer')
      assert_equal('update', @plugin._update_galenic_form(composition, 'language', '123,name'))
    end
    def test_diff_february_2019
      pac = flexmock 'package'
      pac.should_receive(:data_origin).and_return :swissmedic
      reg = flexmock 'registration'
      reg.should_receive(:package).and_return pac
      @app.should_receive(:registration).and_return reg
      result = @plugin.diff(@state_2019_01_31, @state_2015_07_02)
      assert_equal 37, result.news.size
      assert_equal "Zymafluor 0.25 mg, Tabletten", result.news.first[2].value
      assert_equal 3, result.updates.size
      assert_equal "Coeur-Vaisseaux Sérocytol, suppositoire", result.updates.first[2].value
      assert_equal 37, result.changes.size
      expected = {"00277"=>[:expiry_date, :production_science],
                  "15219"=>[:new],
                  "16598"=>[:new],
                  "28486"=>[:new],
                  "30015"=>[:new],
                  "31644"=>[:new],
                  "32475"=>[:new],
                  "35366"=>[:new],
                  "43454"=>[:new],
                  "44625"=>[:new],
                  "45882"=>[:new],
                  "53290"=>[:new],
                  "53662"=>[:new],
                  "54015"=>[:new],
                  "54534"=>[:new],
                  "55558"=>[:new],
                  "66297"=>[:new],
                  "55594"=>[:new],
                  "55674"=>[:new],
                  "56352"=>[:new],
                  "58943"=>[:new],
                  "59267"=>[:new],
                  "61186"=>[:new],
                  "62069"=>[:expiry_date],
                  "62132"=>[:new],
                  "65856"=>[:new],
                  "65857"=>[:new],
                  "58734"=>[:new],
                  "55561"=>[:new],
                  "65160"=>[:new],
                  "58158"=>[:new],
                  "44447"=>[:new],
                  "39252"=>[:new],
                  "00278"=>[:delete],
                  "48624"=>[:delete],
                  "57678"=>[:delete],
                  "00488"=>[:delete]
      }
      assert_equal(expected, result.changes)
      assert_equal 11, result.package_deletions.size
      assert_equal 4, result.package_deletions.first.size
      iksnrs = result.package_deletions.collect { |row| row[0] }.sort
      ikscds = result.package_deletions.collect { |row| row[2] }.sort
      assert_equal ["00278", "00278", "00488", "48624", "57678", "62069", "62069", "62069", "62069", "62069", "62069"], iksnrs
      assert_equal  ["001", "001", "002", "009", "010", "011", "012", "013", "014", "022", "024"], ikscds
      assert_equal 6, result.sequence_deletions.size
      assert_equal ['00278', '01'], result.sequence_deletions.at(0)
      assert_equal 4, result.registration_deletions.size
      assert_equal ['00278'], result.registration_deletions.at(0)
      assert_equal 0, result.replacements.size
    end
    def test_deactivate
      flexmock(@plugin) do |plg|
        plg.should_receive(:pointer)
      end
      flexmock(@app) do |app|
        app.should_receive(:update).and_return('update')
      end
      deactivations = ['row']
      assert_equal(deactivations, @plugin.deactivate(deactivations))
    end
    def test_pointer
      expected = Persistence::Pointer.new([:registration, "row"])
      assert_kind_of(Persistence::Pointer, @plugin.pointer(['row']))
      assert_equal(expected, @plugin.pointer(['row']))
    end
    def test_pointer_from_row
      row = ['12345', '01', '', '', '', '', '', '', '', '', '001']
      expected = Persistence::Pointer.new([:registration, '12345'], ['sequence', '01'], ['package', '001'])
      assert_kind_of(Persistence::Pointer, @plugin.pointer_from_row(row))
      assert_equal(expected, @plugin.pointer_from_row(row))
    end
      def test_resolve_link__with_pointer
      expected = "https://#{SERVER_NAME}/de/gcc/show/reg/12345/seq/01/pack/001"
      pointer = Persistence::Pointer.new([:registration, '12345'], ['sequence', '01'], ['package', '001'])
      package = flexmock('pack') do |pac|
        pac.should_receive(:iksnr).and_return('12345')
        pac.should_receive(:seqnr).and_return('01')
        pac.should_receive(:ikscd).and_return('001')
        pac.should_receive(:is_a?).with(ODDB::Registration).and_return(false)
        pac.should_receive(:is_a?).with(ODDB::Sequence).and_return(false)
        pac.should_receive(:is_a?).with(ODDB::Package).and_return(true)
      end
      flexmock(@app) do |app|
        app.should_receive(:resolve).and_return(package)
      end
      assert_equal(expected, @plugin.resolve_link(pointer))
    end
    def test__sanity_check_deletions
      table = {'xxx' => 0}
      deletions = [['xxx']]
      assert_equal([], @plugin._sanity_check_deletions(deletions, table))
    end
    def test_sanity_check_deletions
      diff = flexmock('diff') do |d|
        d.should_receive(:registration_deletions).and_return({'key' => 'value'})
        d.should_receive(:sequence_deletions).and_return([])
        d.should_receive(:package_deletions).and_return([])
      end
      assert_equal([], @plugin.sanity_check_deletions(diff))
    end
    def test_update_sequence
      pointer = flexmock('pointer')
      flexmock(pointer) do |ptr|
        ptr.should_receive(:+).and_return(pointer)
        ptr.should_receive(:creator)
      end
      sequence = flexmock('sequence') do |s|
        s.should_receive(:pointer)
        s.should_receive(:seqnr)
        s.should_receive(:atc_class)
      end
      atc_class = flexmock('atc_class') do |a|
        a.should_receive(:code)
      end
      registration = flexmock('registration') do |r|
        r.should_receive(:sequence).and_return(sequence)
        r.should_receive(:pointer).and_return(pointer)
        r.should_receive(:atc_classes).and_return([atc_class])
        r.should_receive(:iksnr).and_return('iksnr')
      end
      flexmock(@app) do |app|
        app.should_receive(:update).and_return('update')
      end
      row = [0,1,"xxx ,(3mg), (4mg)"]
      assert_equal('update', @plugin.update_sequence(registration, row))
    end
    def test_update_sequence__parts_empty
      pointer = flexmock('pointer')
      flexmock(pointer) do |ptr|
        ptr.should_receive(:+).and_return(pointer)
        ptr.should_receive(:creator)
      end
      sequence = flexmock('sequence') do |s|
        s.should_receive(:pointer)
        s.should_receive(:seqnr)
        s.should_receive(:atc_class)
      end
      atc_class = flexmock('atc_class') do |a|
        a.should_receive(:code)
      end
      registration = flexmock('registration') do |r|
        r.should_receive(:sequence).and_return(sequence)
        r.should_receive(:pointer).and_return(pointer)
        r.should_receive(:atc_classes).and_return([atc_class])
        r.should_receive(:iksnr).and_return('iksnr')
      end
      flexmock(@app) do |app|
        app.should_receive(:update).and_return('update')
      end
      row = [0,1,'']
      assert_equal('update', @plugin.update_sequence(registration, row))
    end
    def test_update_sequence__identication
      pointer = flexmock('pointer')
      flexmock(pointer) do |ptr|
        ptr.should_receive(:+).and_return(pointer)
        ptr.should_receive(:creator)
      end
      sequence = flexmock('sequence') do |s|
        s.should_receive(:pointer)
        s.should_receive(:seqnr)
        s.should_receive(:atc_class)
      end
      atc_class = flexmock('atc_class') do |a|
        a.should_receive(:code)
      end
      registration = flexmock('registration') do |r|
        r.should_receive(:sequence).and_return(sequence)
        r.should_receive(:pointer).and_return(pointer)
        r.should_receive(:iksnr).and_return('iksnr')
        r.should_receive(:atc_classes).and_return([atc_class])
      end
      flexmock(@app) do |app|
        app.should_receive(:update).and_return('update')
      end
      indication = flexmock('indication', :pointer => nil)
      flexmock(@plugin) do |p|
        p.should_receive(:update_indication).and_return(indication)
      end
      row = [0,1,"xxx ,(3mg), (4mg)"]
      assert_equal('update', @plugin.update_sequence(registration, row))
    end
    def test_update_sequence__substances
      pointer = flexmock('pointer')
      flexmock(pointer) do |ptr|
        ptr.should_receive(:+).and_return(pointer)
        ptr.should_receive(:creator)
      end
      sequence = flexmock('sequence') do |s|
        s.should_receive(:pointer)
        s.should_receive(:seqnr)
        s.should_receive(:atc_class)
      end
      registration = flexmock('registration') do |r|
        r.should_receive(:sequence).and_return(sequence)
        r.should_receive(:pointer).and_return(pointer)
        r.should_receive(:atc_classes).and_return([])
        r.should_receive(:iksnr).and_return('iksnr')
      end
      flexmock(@app) do |app|
        app.should_receive(:update).and_return('update')
      end
      row = [0,1,"xxx ,(3mg), (4mg)",3,4,5]
      assert_equal('update', @plugin.update_sequence(registration, row))
    end
    def test_update_sequence__atc_classes
      pointer = flexmock('pointer')
      flexmock(pointer) do |ptr|
        ptr.should_receive(:+).and_return(pointer)
        ptr.should_receive(:creator)
      end
      sequence = flexmock('sequence') do |s|
        s.should_receive(:seqnr).and_return 'seqnr'
        s.should_receive(:seqnr)
        s.should_receive(:pointer)
        s.should_receive(:atc_class)
      end
      atc_class = flexmock('atc_class') do |a|
        a.should_receive(:code)
      end
      registration = flexmock('registration') do |r|
        r.should_receive(:sequence).and_return(sequence)
        r.should_receive(:pointer).and_return(pointer)
        r.should_receive(:atc_classes).and_return([])
        r.should_receive(:iksnr).and_return('iksnr')
      end
      flexmock(@app) do |app|
        app.should_receive(:update).and_return('update')
        app.should_receive(:unique_atc_class).and_return(atc_class)
      end
      assert_equal('update', @plugin.update_sequence(registration, @workbook[0][6]))
    end

    def test_update_export_registrations
      data = flexmock('data') do |d|
        d.should_receive(:delete)
        d.should_receive(:update)
      end
      sequence = flexmock('sequence', :export_flag => true)
      registration = flexmock('registration') do |r|
        r.should_receive(:export_flag)
        r.should_receive(:pointer)
        r.should_receive(:sequences).and_return({'key' => sequence})
      end
      flexmock(@app) do |app|
        app.should_receive(:registration).once.with('123').and_return(nil)
        app.should_receive(:registration).once.with('456').and_return(registration)
        app.should_receive(:update)
      end
      export_registrations = {'123' => data, '456' => data}
      assert_equal({'456' => data}, @plugin.update_export_registrations(export_registrations))
    end
    def test_update_export_registrations__else
      data = flexmock('data') do |d|
        d.should_receive(:delete)
        d.should_receive(:update)
      end
      sequence = flexmock('sequence', :export_flag => false)
      registration = flexmock('registration') do |r|
        r.should_receive(:export_flag)
        r.should_receive(:pointer)
        r.should_receive(:sequences).and_return({'key' => sequence})
      end
      flexmock(@app) do |app|
        app.should_receive(:registration).once.with('123').and_return(nil)
        app.should_receive(:registration).once.with('456').and_return(registration)
        app.should_receive(:update)
      end
      export_registrations = {'123' => data, '456' => data}
      assert_equal({}, @plugin.update_export_registrations(export_registrations))
    end

    def test_update_export_sequences
      data = flexmock('data') do |d|
        d.should_receive(:update)
      end
      sequence = flexmock('sequence') do |s|
        s.should_receive(:export_flag)
        s.should_receive(:pointer)
      end
      registration = flexmock('registration') do |r|
        r.should_receive(:sequence).and_return(sequence)
      end
      flexmock(@app) do |app|
        app.should_receive(:registration).once.with('123').and_return(nil)
        app.should_receive(:registration).once.with('456').and_return(registration)
        app.should_receive(:update)
      end
      export_sequences = {['123', 'seqnr'] => data, ['456', 'seqnr'] =>data}
      assert_equal({['456', 'seqnr'] => data}, @plugin.update_export_sequences(export_sequences))
    end
    def test_mail_notifications
      company = flexmock('company') do |cmp|
        cmp.should_receive(:swissmedic_email).and_return('email')
        cmp.should_receive(:swissmedic_salutation).and_return('salutation')
      end
      registration = flexmock('registration') do |reg|
        reg.should_receive(:company).and_return(company)
        reg.should_receive(:name_base).and_return('name_base')
        reg.should_receive(:iksnr).and_return('iksnr')
        reg.should_receive(:pointer)
      end
      pointer = flexmock('pointer') do |ptr|
        ptr.should_receive(:resolve).and_return(registration)
      end
      log = flexmock('log') do |log|
        log.should_receive(:change_flags).and_return({pointer => 'flags'})
        log.should_receive(:date).and_return(Time.local(2016,1,2))
      end
      flexmock(Log).new_instances do |log|
        log.should_receive(:report=)
        log.should_receive(:recipients=)
        log.should_receive(:notify).and_return('notify')
      end
      log_group = flexmock('log_group', :latest => log)
      flexmock(@app) do |app|
        app.should_receive(:log_group).and_return(log_group)
      end
      flexmock(@plugin) do |plg|
        plg.should_receive(:resolve_link)
        plg.should_receive(:format_flags)
      end
      expected = {"email"=>[registration]}
      assert_equal(expected, @plugin.mail_notifications)
    end
    def test_update_swissmedic
      expected = []
      company_ptr = Persistence::Pointer.new([:registration, '111'], [:sequence, '222'])
      seq = flexmock 'sequence'
      seq.should_receive(:pointer).and_return(company_ptr)
      company = flexmock('company',
                         :pointer => company_ptr
                        )
      pac = flexmock 'package'
      pac.should_receive(:data_origin).and_return :swissmedic
      seq = setup_simple_seq
      seq.should_receive(:package).and_return(pac)
      seq.should_receive(:atc_class).and_return nil
      registration = flexmock('registration',
                              :pointer => 'pointer',
                              :ith_swissmedic => 'ith_swissmedic',
                              :production_science => 'production_science',
                              :registration_date => 'registration_date',
                              :expiration_date => 'expiration_date',
                              :inactive? => false,
                              :vaccine => 'vaccine',
                              :index_therapeuticus => 'index_therapeuticus',
                              :iksnr => 'iksnr',
                              :package => pac,
                              :sequence => seq,
                              :atc_classes => [],
                              :company_name => company)
      @app = flexmock(@app)
      @app.should_receive(:resolve).and_return(nil)
      newer = File.join(ODDB::TEST_DATA_DIR, 'xlsx', 'Packungen-latest.xlsx')
      older = @state_2015_07_02
      FileUtils.cp(older, File.join(ODDB::TEST_DATA_DIR, 'xls', 'Packungen-latest.xlsx'),
                   :verbose => true, :preserve => true)
      FileUtils.cp(older, File.join(ODDB::TEST_DATA_DIR, 'xls',  @@today.strftime('Packungen-%Y.%m.%d.xlsx')),
                   :verbose => true, :preserve => true)
      result =  @plugin.update
      assert_equal(4, @plugin.updated_agents.size)
      assert_equal(15, @plugin.recreate_missing.size)
      assert_equal(8, @plugin.known_export_registrations.size)
      assert_equal(8, @plugin.known_export_sequences.size)
      FileUtils.cp(newer, File.join(ODDB::TEST_DATA_DIR, 'xls',  @@today.strftime('Packungen-%Y.%m.%d.xlsx')),
                   :verbose => true, :preserve => true)
      result =  @plugin.update
      assert_equal(0, @plugin.updated_agents.size)
      assert_equal(0, @plugin.recreate_missing.size)
      assert_equal(8, @plugin.known_export_registrations.size)
      assert_equal(8, @plugin.known_export_sequences.size)
      assert_kind_of(OpenStruct, result)
    end
  end
end
