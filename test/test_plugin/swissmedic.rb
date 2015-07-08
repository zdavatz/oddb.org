#!/usr/bin/env ruby
# encoding: utf-8

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'minitest/unit'
require 'stub/odba'
require 'stub/oddbapp'
require 'util/persistence'
require 'plugin/swissmedic'
require 'model/registration'
require 'model/sequence'
require 'model/package'
require 'flexmock'
require 'ostruct'
require 'tempfile'
require 'util/log'
require 'util/util'
require 'util/oddbconfig'

class FlexMock::TestUnitFrameworkAdapter
    attr_accessor :assertions
end

module ODDB
   class SwissmedicPluginTest < Minitest::Test
    include FlexMock::TestCase
    NAME_OFFSET = 2
    INDICATION_OFFSET = 18
    ROW_ASPIRIN = 5 # row in excel -1
    ROW_WELEDA = 8
    ROW_VETERINARY = 9
    ROW_OSANIT = 10
    ROW_AXOTIDE = 19
    IKSNR_WELEDA = "09232"
    EXPIRATION_DATE_ASPIRIN = Date.new(2017,5,9)
    def setup
      @app = flexmock 'app'
      @archive = File.expand_path('../var', File.dirname(__FILE__))
      FileUtils.rm_rf(@archive)
      FileUtils.mkdir_p(@archive)
      @plugin = SwissmedicPlugin.new @app, @archive
      @current  = File.expand_path '../data/xlsx/Packungen-2015.07.02.xlsx', File.dirname(__FILE__)
      @older    = File.expand_path '../data/xlsx/Packungen-2015.06.04.xlsx', File.dirname(__FILE__)
      @target   = File.join @archive, 'xls',  @@today.strftime('Packungen-%Y.%m.%d.xlsx')
      @latest   = File.join @archive, 'xls', 'Packungen-latest.xlsx'
      FileUtils.makedirs(File.dirname(@latest)) unless File.exists?(File.dirname(@latest))
      FileUtils.rm(@latest) if File.exists?(@latest)
      @test_packages = File.expand_path '../data/xlsx/Packungen.xlsx', File.dirname(__FILE__)
      @workbook = Spreadsheet.open( @test_packages)
      @plugin.set_target_keys(@workbook)
    end
    def teardown
      super # to clean up FlexMock
    end

    def setup_index_page
      link = flexmock('link', :href => 'href')
      links = flexmock('links', :select => [link])
      page = flexmock('page', :links => links)
      index = flexmock 'index'
      link1 = OpenStruct.new :attributes => {'title' => 'Packungen'},
                             :href => 'url'
      link2 = OpenStruct.new :attributes => {'title' => 'Something'},
                             :href => 'other'
      link3 = OpenStruct.new :attributes => {'title' => 'Präparateliste'},
                             :href => 'url'
      index.should_receive(:links).and_return [link1, link2, link3]
      index.should_receive(:body).and_return(IO.read(@current))
      agent = flexmock(Mechanize.new)
      agent.should_receive(:user_agent_alias=).and_return(true)
      agent.should_receive(:get).and_return(index)
      uri = 'http://www.example.com'
      [agent, page]
    end


    def test_get_latest_file__identical
      content = 'Content of the xml'
      assert !File.exist?(@latest), "A previous test did not clean up #@latest"
      assert !File.exist?(@target), "A previous test did not clean up #@target"
      File.open(@latest, 'wb+') { |f| f.write content }
      agent, page = setup_index_page
      page.should_receive(:body).and_return(content)
      agent.should_receive(:get).and_return(page)
      @plugin.get_latest_file(agent)
      assert File.exist?(@latest), "#{@latest} should have been saved"
      assert File.exist?(@target), "#{@target} should have been saved"
    end

    def test_get_latest_file__new
      assert !File.exist?(@latest), "A previous test did not clean up #@latest"
      assert !File.exist?(@target), "A previous test did not clean up #@target"
      agent, page = setup_index_page
      page.should_receive(:body).and_return('Content of the xls')
      @plugin.get_latest_file(agent)
      assert File.exist?(@target), "#@target was not saved"
    end

    def test_get_latest_file__replace
      assert !File.exist?(@latest), "A previous test did not clean up #@latest"
      assert !File.exist?(@target), "A previous test did not clean up #@target"
      File.open(@latest, 'w') { |fh| fh.puts 'Content of a previous xml' }
      agent, page = setup_index_page
      page.should_receive(:body).and_return('Content of the xml')
      agent.should_receive(:get).and_return(page)
      @plugin.get_latest_file(agent)
      assert File.exist?(@target), "#@target was not saved"
    end

    def test_update_company__create
      row = @workbook.worksheet(0).row(ROW_ASPIRIN);  assert_equal('Aspirin, Tabletten', row[NAME_OFFSET].value)

      name = 'Bayer (Schweiz) AG'
      @app.should_receive(:company_by_name).with(name, 0.8)
      ptr = Persistence::Pointer.new(:company)
      args = { :name => name, :business_area => 'ba_pharma' }
      @app.should_receive(:update).with(ptr.creator, args)\
        .times(1).and_return { assert true }
      @plugin.update_company(row)
    end
    def test_update_registration__create
      row = @workbook.worksheet(0).row(ROW_ASPIRIN);  assert_equal('Aspirin, Tabletten', row[NAME_OFFSET].value)

      company = flexmock 'company'
      @app.should_receive(:indication_by_text).and_return nil
      indication = flexmock 'indication'
      indication.should_receive(:pointer).and_return('indication-pointer')
      args = {:de=>"Analgetikum, Antipyretikum"}
      ptr = Persistence::Pointer.new([:registration, '08537'])
      @app.should_receive(:update).with(ptr.creator, args, :swissmedic)\
        .times(1).and_return { assert true }
      name = 'Bayer (Schweiz) AG'
      @app.should_receive(:company_by_name)\
        .with(name, 0.8).and_return company
      company.should_receive(:pointer).and_return 'company-pointer'
      args = { :name => name, :business_area => 'ba_pharma' }
      @app.should_receive(:update).with('company-pointer', args)\
        .times(1).and_return { assert true; company }
      reg = flexmock 'registration'
      reg.should_receive(:pointer).and_return(ptr)
      @app.should_receive(:registration).with('08537').and_return(reg)
      args = {
        :ith_swissmedic      => '01.01.1.',
        :production_science  => 'Synthetika human',
        :vaccine             => nil,
        :registration_date   => Date.new(1936,6,30),
        :expiration_date     => EXPIRATION_DATE_ASPIRIN,
        :inactive_date       => nil,
        :export_flag         => nil,
        :company             => 'company-pointer',
        :renewal_flag        => false,
        :renewal_flag_swissmedic => false,
        :indication=>"indication-pointer",
      }
      @app.should_receive(:update).with(ptr.creator, args, :swissmedic)\
        .times(1).and_return { assert true }
      skip('Niklaus has no time to debug this')
      @plugin.update_registration(row, :date => Date.new(2008,3,19))
    end
    def test_update_registration__update
      row = @workbook.worksheet(0).row(ROW_ASPIRIN);  assert_equal('Aspirin, Tabletten', row[NAME_OFFSET].value)

      indication = flexmock 'indication'
      indication.should_receive(:pointer).and_return 'indication-pointer'
      @app.should_receive(:indication_by_text).with("Analgetikum, Antipyretikum")\
        .and_return indication
      company = flexmock 'company'
      name = 'Bayer (Schweiz) AG'
      @app.should_receive(:company_by_name)\
        .with(name, 0.8).and_return company
      company.should_receive(:pointer).and_return 'company-pointer'
      registration = flexmock 'registration'
      args = { :name => name, :business_area => 'ba_pharma' }
      @app.should_receive(:update).with('company-pointer', args)\
        .times(1).and_return { assert true; company }
      @app.should_receive(:registration).with('08537').and_return registration
      ptr = Persistence::Pointer.new([:registration, '08537'])
      registration.should_receive(:pointer).and_return ptr
      args = {
        :ith_swissmedic      => '01.01.1.',
        :production_science  => 'Synthetika human',
        :vaccine             => nil,
        :registration_date   => Date.new(1936,6,30),
        :expiration_date     => EXPIRATION_DATE_ASPIRIN,
        :inactive_date       => nil,
        :export_flag         => nil,
        :company             => 'company-pointer',
        :renewal_flag        => false,
        :renewal_flag_swissmedic => false,
        :indication          => 'indication-pointer',
      }
      @app.should_receive(:update).with(ptr, args, :swissmedic)\
        .times(1).and_return { assert true }
      @plugin.update_registration(row, :date => Date.new(2008,3,19))
    end

    def test_update_registration__ignore_vet
      row = @workbook.worksheet(0).row(ROW_VETERINARY)
      @plugin.update_registration(row)
    end
    def test_update_registration__phyto
      row = @workbook.worksheet(0).row(20);  assert_equal('Hametum, Salbe', row[NAME_OFFSET].value)
      indication = flexmock 'indication'
      indication.should_receive(:pointer).and_return 'indication-pointer'
      @app.should_receive(:indication_by_text).with("Bei kleineren Hautverletzungen")\
        .and_return indication
      company = flexmock 'company'
      name = 'Schwabe Pharma AG'
      @app.should_receive(:company_by_name)\
        .with(name, 0.8).and_return company
      company.should_receive(:pointer).and_return 'company-pointer'
      args = { :name => name, :business_area => 'ba_pharma' }
      @app.should_receive(:update).with('company-pointer', args)\
        .times(1).and_return { assert true; company }
      registration = flexmock 'registration'
      @app.should_receive(:registration).with('08653').and_return registration
      ptr = Persistence::Pointer.new([:registration, '08653'])
      ptr = flexmock('ptr')
      registration.should_receive(:pointer).and_return ptr
      args = {
        :ith_swissmedic      => '10.06.0.',
        :production_science  => 'Phytotherapeutika',
        :vaccine             => nil,
        :registration_date   => Date.new(1937,3,30),
        :expiration_date     => Date.new(2019,12,2),
        :renewal_flag        => false,
        :renewal_flag_swissmedic => false,
        :inactive_date       => nil,
        :export_flag         => nil,
        :complementary_type  => 'phytotherapy',
        :company             => 'company-pointer',
        :indication          => 'indication-pointer',
      }
      @app.should_receive(:update).with(ptr, args, :swissmedic).and_return {assert true }
      @plugin.update_registration(row, :date => Date.new(2008,3,19))
    end

    def test_update_registration__anthropo
      row = @workbook.worksheet(0).row(ROW_WELEDA)
      indication = flexmock 'indication'
      indication.should_receive(:pointer).and_return 'indication-pointer'
      @app.should_receive(:indication_by_text).with("Zur Linderung von Schnupfen")\
        .and_return indication
      company = flexmock 'company'
      name = 'Weleda AG'
      @app.should_receive(:company_by_name)\
        .with(name, 0.8).and_return company
      company.should_receive(:pointer).and_return 'company-pointer'
      args = { :name => name, :business_area => 'ba_pharma' }
      @app.should_receive(:update).with('company-pointer', args)\
        .times(1).and_return { assert true; company }
      registration = flexmock 'registration'
      @app.should_receive(:registration).with(IKSNR_WELEDA).and_return registration
      ptr = Persistence::Pointer.new([:registration, IKSNR_WELEDA])
      registration.should_receive(:pointer).and_return ptr
      args = {
        :ith_swissmedic      => '20.02.0.',
        :production_science  => 'Anthroposophika',
        :vaccine             => nil,
        :registration_date   => Date.new(1937,9,21),
        :expiration_date     => Date.new(2016,11,1),
        :inactive_date       => nil,
        :company             => 'company-pointer',
        :complementary_type  => 'anthroposophy',
        :indication          => 'indication-pointer',
        :renewal_flag        => false,
        :renewal_flag_swissmedic => false,
        :export_flag         => nil,
      }
      @app.should_receive(:update).with(ptr, args, :swissmedic)\
        .times(1).and_return { assert true }
      @plugin.update_registration(row, :date => Date.new(2008,3,19))
    end

    def test_update_registration__homoeo
      row = @workbook.worksheet(0).row(ROW_OSANIT)
      indication_text = "Bei Zahnungsbeschwerden"
      assert_equal('Osanit Zahnen, homöopathische Globuli', row[NAME_OFFSET].value)
      assert_equal(indication_text, row[INDICATION_OFFSET].value)
      indication = flexmock 'indication'
      indication.should_receive(:pointer).and_return 'indication-pointer'
      @app.should_receive(:indication_by_text).with(indication_text)\
        .and_return indication
      company = flexmock 'company'
      name = 'Iromedica AG'
      @app.should_receive(:company_by_name)\
        .with(name, 0.8).and_return company
      company.should_receive(:pointer).and_return 'company-pointer'
      args = { :name => name, :business_area => 'ba_pharma' }
      @app.should_receive(:update).with('company-pointer', args)\
        .times(1).and_return { assert true; company }
      registration = flexmock 'registration'
      @app.should_receive(:registration).with('10999').and_return registration
      ptr = Persistence::Pointer.new([:registration, '10999'])
      registration.should_receive(:pointer).and_return ptr
      args = {
        :ith_swissmedic      => '20.01.0.',
        :production_science  => 'Homöopathika',
        :vaccine             => nil,
        :registration_date   => Date.new(1935,9,5),
        :expiration_date     => Date.new(2016,11,6),
        :inactive_date       => nil,
        :company             => 'company-pointer',
        :complementary_type  => 'homeopathy',
        :indication          => 'indication-pointer',
        :renewal_flag        => false,
        :renewal_flag_swissmedic => false,
        :export_flag         => nil,
      }
      @app.should_receive(:update).with(ptr, args, :swissmedic)\
        .times(1).and_return { assert true }
      @plugin.update_registration(row, :date => Date.new(2008,3,19))
    end
    def test_update_registration__aspirin
      row = @workbook.worksheet(0).row(ROW_ASPIRIN)
      assert_equal('Aspirin, Tabletten', row[NAME_OFFSET].value)
      indication = flexmock 'indication'
      indication.should_receive(:pointer).and_return 'indication-pointer'
      @app.should_receive(:indication_by_text).with("Analgetikum, Antipyretikum")\
        .and_return indication
      company = flexmock 'company'
      name = 'Bayer (Schweiz) AG'
      @app.should_receive(:company_by_name)\
        .with(name, 0.8).and_return company
      company.should_receive(:pointer).and_return 'company-pointer'
      args = { :name => name, :business_area => 'ba_pharma' }
      @app.should_receive(:update).with('company-pointer', args)\
        .times(1).and_return { assert true; company }
      registration = flexmock 'registration'
      @app.should_receive(:registration).with('08537').and_return registration
      ptr = Persistence::Pointer.new([:registration, '08537'])
      registration.should_receive(:pointer).and_return ptr
      args = {
        :ith_swissmedic      => '01.01.1.',
        :production_science  => 'Synthetika human',
        :vaccine             => nil,
        :registration_date   => Date.new(1936,6,30),
        :expiration_date     => EXPIRATION_DATE_ASPIRIN,
        :inactive_date       => nil,
        :company             => 'company-pointer',
        :renewal_flag        => true,
        :renewal_flag_swissmedic => true,
        :export_flag         => nil,
        :indication          => 'indication-pointer',
      }
      @app.should_receive(:update).with(ptr, args, :swissmedic)\
        .times(1).and_return { assert true }
      @plugin.update_registration(row, :date => EXPIRATION_DATE_ASPIRIN + 2)
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
      row = @workbook.worksheet(0).row(ROW_ASPIRIN)
      assert_equal('Aspirin, Tabletten', row[NAME_OFFSET].value)
      reg = flexmock 'registration'
      ptr = Persistence::Pointer.new([:registration, '08537'])
      ptr= flexmock('registration_fake')
      ptr.should_receive(:update).with_any_args.and_return 'update'
      reg.should_receive(:pointer).and_return ptr
      seq = flexmock 'sequence'
      seq.should_receive(:seqnr).and_return 'seqnr'
      # seq.should_receive(:atc_class).and_return 'atc_class'
      reg.should_receive(:sequence).with('00').and_return(nil)
      reg.should_receive(:sequence).with('01').and_return(seq)
      j06aa = ODDB::AtcClass.new('J06AA')
      n02ba01 = ODDB::AtcClass.new('N02BA01')
      reg.should_receive(:iksnr).and_return '08537'
      reg.should_receive(:atc_classes).and_return [n02ba01]
      seq.should_receive(:atc_class).and_return j06aa
      j06aa.descriptions[:de]='description for j06aa'
      n02ba01.descriptions[:de]='description for n02ba01'
      @app.should_receive(:atc_class).with('J06AA').and_return n02ba01
      @app.should_receive(:atc_class).with('N02BA01').and_return n02ba01
      sptr = Persistence::Pointer.new([:registration, '08537'], [:sequence, '01'])
      seq.should_receive(:pointer).and_return sptr
      args = {
        :composition_text => "acidum acetylsalicylicum 500 mg, excipiens pro compresso.",
        :name_base        =>"Aspirin",
        :name_descr       =>"Tabletten",
        :dose             =>nil,
        :sequence_date    => Date.new(1936,6,30),
        :export_flag      =>nil,
      }
      @app.should_receive(:update).with(sptr, args, :swissmedic).and_return 'update_with_expected_args'
      result = @plugin.update_sequence reg, row
      assert_equal('update_with_expected_args', result)
    end

    def test_update_package__create
      row = @workbook.worksheet(0).row(ROW_ASPIRIN)
      assert_equal('Aspirin, Tabletten', row[NAME_OFFSET].value)
      reg = flexmock 'registration'
      seq = flexmock 'sequence'
      ptr = Persistence::Pointer.new([:registration, '08537'], [:sequence, '01'])
      seq.should_receive(:pointer).and_return ptr
      seq.should_receive(:seqnr).and_return 'seqnr'
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
        :swissmedic_source => {
          :import_date             => @@today,
          :iksnr                   => "08537",
          :seqnr                   => "01",
          :name_base               => "Aspirin, Tabletten",
          :company                 => "Bayer (Schweiz) AG",
          :production_science      => "Synthetika human",
          :index_therapeuticus     => "01.01.1.",
          :atc_class               => "N02BA01",
          :registration_date       => Date.new(1936,6,30),
          :sequence_date           => Date.new(1936,6,30),
          :expiry_date             => EXPIRATION_DATE_ASPIRIN,
          :ikscd                   => "011",
          :size                    => "20",
          :unit                    => "Tablette(n)",
          :ikscat                  => "D",
          :ikscat_seq              => "D",
          :ikscat_preparation      => "D",
          :substances              => "acidum acetylsalicylicum",
          :composition             => "acidum acetylsalicylicum 500 mg, excipiens pro compresso.",
          :indication_registration => 'Analgetikum, Antipyretikum',
          :indication_sequence     => "",
          :gen_production          => "",
          :insulin_category        => "",
          :drug_index              => "",
        },
        :refdata_override  => true,
      }
      pac = flexmock 'package'
      pac.should_receive(:pointer).and_return pptr
      pac.should_receive(:sequence).and_return(seq)
      @app.should_receive(:create).with(pptr.creator).times(1).and_return pac
      @app.should_receive(:update).with(pptr.creator, args, :swissmedic)\
        .times(1).and_return {
        assert true
        pac
      }
      pac.should_receive(:parts).and_return []
      ptptr = pptr.creator + :part
      part = flexmock 'part'
      part.should_receive(:pointer).and_return('part-pointer')
      part.should_receive(:composition)
      part.should_ignore_missing
      @app.should_receive(:create).with(ptptr.creator).times(1).and_return part
      args = {
        :commercial_form => 'comform-pointer',
        :composition     => 'composition-pointer',
        :size            => "20 Tablette(n)",
      }
      @app.should_receive(:update).with('part-pointer', args, :swissmedic)\
        .times(1).and_return {
        assert true
        part
      }
      @plugin.update_package reg, seq, row
    end

   def test_update_package__create__replacement
      row = @workbook.worksheet(0).row(ROW_ASPIRIN)
      assert_equal('Aspirin, Tabletten', row[NAME_OFFSET].value)
      reg = flexmock 'registration'
      seq = flexmock 'sequence'
      ptr = Persistence::Pointer.new([:registration, '08537'], [:sequence, '01'])
      seq.should_receive(:pointer).and_return ptr
      seq.should_receive(:seqnr).and_return 'seqnr'
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
        :ikscat            => "D",
        :refdata_override  => true,
        :pharmacode        => '1234567',
        :ancestors         => ['007'],
        :swissmedic_source => {
          :atc_class               => "N02BA01",
          :composition             => "acidum acetylsalicylicum 500 mg, excipiens pro compresso.",
          :company                 => "Bayer (Schweiz) AG",
          :name_base               => "Aspirin, Tabletten",
          :iksnr                   => "08537",
          :import_date             => @@today,
          :ikscat                  => "D",
          :expiry_date             => EXPIRATION_DATE_ASPIRIN,
          :index_therapeuticus     => "01.01.1.",
          :seqnr                   => "01",
          :ikscd                   => "011",
          :production_science      => "Synthetika human",
          :unit                    => "Tablette(n)",
          :registration_date       => Date.new(1936,6,30),
          :sequence_date           => Date.new(1936,6,30),
          :size                    => "20",
          :substances              => "acidum acetylsalicylicum",
          :indication_sequence     => '',
          :indication_registration => 'Analgetikum, Antipyretikum',
          :drug_index              => '', # new fields since july 2015
          :gen_production          => "",
          :insulin_category        => "",
          :ikscat_preparation      => "D",
          :ikscat_seq              => "D",
        }
      }
      @app.should_receive(:create).with(pptr.creator).times(1).and_return pac
      @app.should_receive(:update).with(pptr.creator, args, :swissmedic)\
        .times(1).and_return {
        assert true
        pac
      }
      pac.should_receive(:pointer).and_return pptr
      ptptr = pptr + :part
      part = flexmock 'part'
      part.should_receive(:pointer).and_return(ptptr)
      part.should_receive(:composition)
      part.should_ignore_missing
      pac.should_receive(:parts).and_return [part]
      args = {
        :commercial_form   => 'comform-pointer',
        :composition       => 'composition-pointer',
        :size              => "20 Tablette(n)",
      }
      @app.should_receive(:update).with(ptptr, args, :swissmedic)\
        .times(1).and_return {
        assert true
        part
      }
      @plugin.update_package reg, seq, row, {row => '007'}
    end

    def test_update_package__update
      row = @workbook.worksheet(0).row(ROW_ASPIRIN)
      assert_equal('Aspirin, Tabletten', row[NAME_OFFSET].value)
      reg = flexmock 'registration'
      seq = flexmock 'sequence'
      ptr = Persistence::Pointer.new([:registration, '08537'], [:sequence, '01'])
      seq.should_receive(:pointer).and_return ptr
      seq.should_receive(:seqnr).and_return 'seqnr'
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
          :name_base       => "Aspirin, Tabletten",
          :iksnr           => "08537",
          :import_date     => @@today,
          :ikscat          => "D",
          :expiry_date     => EXPIRATION_DATE_ASPIRIN,
          :index_therapeuticus => "01.01.1.",
          :seqnr           => "01",
          :ikscd           => "011",
          :production_science => "Synthetika human",
          :unit            => "Tablette(n)",
          :registration_date => Date.new(1936,6,30),
          :sequence_date   => Date.new(1936,6,30),
          :size            => "20",
          :substances      => "acidum acetylsalicylicum",
          :indication_sequence => '',
          :indication_registration => 'Analgetikum, Antipyretikum',
          :drug_index              => '', # new fields since july 2015
          :gen_production          => "",
          :insulin_category        => "",
          :ikscat_preparation      => "D",
          :ikscat_seq              => "D",
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
      pac.should_receive(:sequence).and_return(seq)
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
      row = @workbook.worksheet(0).row(ROW_ASPIRIN)
      assert_equal('Aspirin, Tabletten', row[NAME_OFFSET].value)
      seq = flexmock 'sequence'
      ptr = Persistence::Pointer.new([:registration, '08537'], [:sequence, '01'])
      seq.should_receive(:pointer).and_return ptr
      seq.should_receive(:active_agents).and_return []
      seq.should_receive(:seqnr).and_return 'seqnr'
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
      args = {
        :label  => nil,
        :source => "acidum acetylsalicylicum 500 mg, excipiens pro compresso."
      }
      @app.should_receive(:update).with(cptr, args, :swissmedic)\
        .times(1).and_return { assert true; comp }
      aptr = cptr + [:active_agent, 'Acidum Acetylsalicylicum']
      args =  {
        :substance => 'Acidum Acetylsalicylicum',
        :dose      => ["500", 'mg'],
      }
      @app.should_receive(:update).with(aptr.creator, args, :swissmedic)\
        .times(1).and_return { assert true }
      @plugin.update_compositions(seq, row)
    end

    def test_update_composition__focus_on_doses
      row = @workbook.worksheet(0).row(ROW_WELEDA)
      assert_equal('Weleda Schnupfencrème, anthroposophisches Arzneimittel', row[NAME_OFFSET].value)
      seq = flexmock 'sequence'
      ptr = Persistence::Pointer.new([:registration, IKSNR_WELEDA], [:sequence, '01'])
      seq.should_receive(:pointer).and_return ptr
      seq.should_receive(:seqnr).and_return 'seqnr'
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
      args = {
        :label  => nil,
        :source => "extractum ethanolicum liquidum ex berberidis fructus recens 10 mg et pruni spinosae fructus recens 10 mg et echinaceae purpureae planta tota recens 12 mg et bryoniae radix recens 0.1 mg, esculosidum 1.1 mg, dextrocamphora 0.12 mg, eucalypti aetheroleum 3.88 mg, menthae piperitae aetheroleum 3.88 mg, thymi aetheroleum 0.12 mg, adeps lanae (Schaf: Fell/Haare/Wolle), excipiens ad unguentum pro 1 g."
      }
      @app.should_receive(:update).with(cptr, args, :swissmedic)\
        .times(9).and_return { assert true; comp }
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
      skip('Niklaus has no time to debug this')
      @app.should_receive(:update).with_any_args do |*args| puts "Got args #{args.inspect}";  'unexpected_update' end
      result = @plugin.update_compositions(seq, row)
      refute_equal('unexpected_update', result)
    end

    def test_update_composition__focus_on_doses_percent
      row = @workbook.worksheet(0).row(ROW_OSANIT)
      assert_equal('Osanit Zahnen, homöopathische Globuli', row[NAME_OFFSET].value)
      seq = flexmock 'sequence'
      ptr = Persistence::Pointer.new([:registration, '08537'], [:sequence, '01'])
      seq.should_receive(:pointer).and_return ptr
      seq.should_receive(:seqnr).and_return 'seqnr'
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
      args = {
        :label  => nil,
        :source => 'calcium carbonicum hahnemanni C7 5 %, chamomilla recutita D5 22.5 %, magnesii hydrogenophosphas trihydricus C5 50 %, passiflora incarnata D5 22.5 %, xylitolum, excipiens ad globulos.'
      }
      @app.should_receive(:update).with(cptr, args, :swissmedic)\
        .times(4).and_return { assert true; comp }
      aptr = cptr + [:active_agent, 'Acidum Acetylsalicylicum']
      args =  [
        { :substance=>"Calcium Carbonicum Hahnemanni C7", :dose=>["5", "%"]},
        { :dose => ["22.5", '%'], :substance => 'Chamomilla Recutita D5' },
        {:substance=>"Magnesii Hydrogenophosphas Trihydricus C5", :dose=>["50", "%"]},
        { :dose => ["22.5", '%'], :substance => 'Passiflora Incarnata D5' },
{:substance=>"Passiflora Incarnata D5", :dose=>["22.5", "%"]},
      ]
      @app.should_receive(:update)\
        .with('active-agent-pointer', Hash, :swissmedic)\
        .times(4).and_return { |ptr, data, key|
          assert_equal args.shift, data
      }
      @plugin.update_compositions(seq, row)
    end
    def test_update_composition__focus_on_doses_qty_in_scale
      row = @workbook.worksheet(0).row(ROW_AXOTIDE)
      assert_equal('Axotide 100 ug, Diskus', row[NAME_OFFSET].value)
      seq = flexmock 'sequence'
      ptr = Persistence::Pointer.new([:registration, '08537'], [:sequence, '01'])
      seq.should_receive(:pointer).and_return ptr
      seq.should_receive(:seqnr).and_return 'seqnr'
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
      args = {
        :label  => nil,
        :source => "fluticasoni-17 propionas 100 \302\265g, lactosum monohydricum q.s. ad pulverem pro 25 mg.",
      }
      @app.should_receive(:update).with(cptr, args, :swissmedic)\
        .times(1).and_return { assert true; comp }
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
      skip('Niklaus has no time to debug this')
      @plugin.update_compositions(seq, row)
    end
    def test_update_composition__update
      row = @workbook.worksheet(0).row(ROW_ASPIRIN);  assert_equal('Aspirin, Tabletten', row[NAME_OFFSET].value)
      seq = flexmock 'sequence'
      ptr = Persistence::Pointer.new([:registration, '08537'], [:sequence, '01'])
      seq.should_receive(:pointer).and_return ptr
      seq.should_receive(:seqnr).and_return 'seqnr'
      comp = flexmock 'composition'
      seq.should_receive(:compositions).and_return [comp]
      substance = flexmock 'substance'
      substance.should_receive(:same_as?).with('Acidum Acetylsalicylicum').and_return true
      @app.should_receive(:substance).with('Acidum Acetylsalicylicum')\
        .and_return substance
      aptr = ptr + [:active_agent, 'Acidum Acetylsalicylicum']
      agent = flexmock 'active-agent'
      agent.should_receive(:pointer).and_return aptr
      agent.should_receive(:substance).and_return substance
      comp.should_receive(:pointer).and_return 'composition-pointer'
      comp.should_receive(:active_agents).and_return [agent]
      comp.should_receive(:active_agent).with('Acidum Acetylsalicylicum')\
        .and_return agent
      args = {
        :label  => nil,
        :source => "acidum acetylsalicylicum 500 mg, excipiens pro compresso."
      }
      @app.should_receive(:update).with('composition-pointer', args, :swissmedic)\
        .times(1).and_return { assert true; comp }
      args =  {
        :substance => 'Acidum Acetylsalicylicum',
        :dose      => ['500', 'mg'],
      }
      @app.should_receive(:update).with(aptr, args, :swissmedic)\
        .times(1).and_return { assert true; agent }
      @plugin.update_compositions(seq, row)
    end
    def test_update_composition__chemical_form
      row = @workbook.worksheet(0).row(ROW_OSANIT)
      assert_equal('Osanit Zahnen, homöopathische Globuli', row[NAME_OFFSET].value)
      seq = flexmock 'sequence'
      ptr = Persistence::Pointer.new([:registration, '08537'], [:sequence, '01'])
      seq.should_receive(:pointer).and_return ptr
      seq.should_receive(:seqnr).and_return 'seqnr'
      comp = flexmock 'composition'
      comp.should_receive(:pointer).and_return 'composition-pointer'
      comp.should_receive(:active_agents).and_return []
      args = {
        :label  => nil,
        :source => 'procainum 10 mg ut procaini hydrochloridum, phenazonum 50 mg, antiox.: E 320, excipiens ad solutionem pro 1 g.'
      }
      @app.should_receive(:update).with('composition-pointer', args, :swissmedic)\
        .times(2).and_return { assert true; comp }
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
      skip('Niklaus has no time to debug this')
      @plugin.update_compositions(seq, row)
    end
    def test_update_composition__delete
      row = @workbook.worksheet(0).row(ROW_ASPIRIN);  assert_equal('Aspirin, Tabletten', row[NAME_OFFSET].value)

      seq = flexmock 'sequence'
      ptr = Persistence::Pointer.new([:registration, '08537'], [:sequence, '01'])
      seq.should_receive(:pointer).and_return ptr
      seq.should_receive(:seqnr).and_return 'seqnr'
      comp = flexmock 'composition'
      comp.should_receive(:pointer).and_return 'composition-pointer'
      args = {
        :label  => nil,
        :source => "acidum acetylsalicylicum 500 mg, excipiens pro compresso."
      }
      @app.should_receive(:update).with('composition-pointer', args, :swissmedic)\
        .times(1).and_return { assert true; comp }
      seq.should_receive(:compositions).and_return [comp]
      substance = flexmock 'substance'
      substance.should_receive(:same_as?).with('Acidum Acetylsalicylicum').and_return false
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
      @plugin.update_compositions(seq, row)
    end

    def test_update_galenic_form__dont_update__descr
      row = @workbook.worksheet(0).row(ROW_ASPIRIN);  assert_equal('Aspirin, Tabletten', row[NAME_OFFSET].value)

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
      row = @workbook.worksheet(0).row(ROW_ASPIRIN);  assert_equal('Aspirin, Tabletten', row[NAME_OFFSET].value)

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
      row = @workbook.worksheet(0).row(ROW_ASPIRIN);  assert_equal('Aspirin, Tabletten', row[NAME_OFFSET].value)

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
    def test_diff
      pac = flexmock 'package'
      pac.should_receive(:data_origin).and_return :swissmedic
      reg = flexmock 'registration'
      reg.should_receive(:package).and_return pac
      @app.should_receive(:registration).and_return reg
      result = @plugin.diff(@current, @older)
      assert_equal 9, result.news.size
      assert_equal "Viscotears Tropfgel, Augengel", result.news.first[2].value
      assert_equal 2, result.updates.size
      assert_equal "Colon Sérocytol, suppositoire", result.updates.first[2].value
      assert_equal 5, result.changes.size
      expected = {
        "00278"=>[:company, :atc_class],
        "48624"=>[:new],
        "62069"=>[:new],
        "16105"=>[:new],
        "00279"=>[:delete]
      }
      assert_equal(expected, result.changes)
      assert_equal 2, result.package_deletions.size
      assert_equal 4, result.package_deletions.first.size
      iksnrs = result.package_deletions.collect { |row| row[0] }.sort
      ikscds = result.package_deletions.collect { |row| row[2] }.sort
      assert_equal ["00279", "00279"], iksnrs
      assert_equal ['001', '002'], ikscds
      assert_equal 1, result.sequence_deletions.size
      assert_equal ['00279', '01'], result.sequence_deletions.at(0)
      assert_equal 1, result.registration_deletions.size
      assert_equal ['00279'], result.registration_deletions.at(0)
      assert_equal 0, result.replacements.size
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
      pac = flexmock 'package'
      pac.should_receive(:data_origin).and_return :swissmedic
      reg = flexmock 'registration'
      reg.should_receive(:package).and_return pac
      @app.should_receive(:registration).and_return reg
      result = @plugin.diff(@current, @older)
      assert_equal <<-EOS.strip, @plugin.to_s
+ 16105: Hirudoid, Creme
+ 48624: Viscotears Tropfgel, Augengel
+ 62069: Levetiracetam Desitin 250 mg, Minipacks mit Mini-Filmtabletten
- 00279: Conjonctif Sérocytol, suppositoire
> 00278: Colon Sérocytol, suppositoire; Zulassungsinhaber (Sérolab AG), ATC-Code (J06A)
      EOS
      assert_equal <<-EOS.strip, @plugin.to_s(:name)
> 00278: Colon Sérocytol, suppositoire; Zulassungsinhaber (Sérolab AG), ATC-Code (J06A)
- 00279: Conjonctif Sérocytol, suppositoire
+ 16105: Hirudoid, Creme
+ 62069: Levetiracetam Desitin 250 mg, Minipacks mit Mini-Filmtabletten
+ 48624: Viscotears Tropfgel, Augengel
      EOS
      assert_equal <<-EOS.strip, @plugin.to_s(:registration)
> 00278: Colon Sérocytol, suppositoire; Zulassungsinhaber (Sérolab AG), ATC-Code (J06A)
- 00279: Conjonctif Sérocytol, suppositoire
+ 16105: Hirudoid, Creme
+ 48624: Viscotears Tropfgel, Augengel
+ 62069: Levetiracetam Desitin 250 mg, Minipacks mit Mini-Filmtabletten
      EOS
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
      expected = "http://#{SERVER_NAME}/de/gcc/show/reg/12345/seq/01/pack/001"
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
    def test_resolve_link__with_row
      expected = "http://#{SERVER_NAME}/de/gcc/resolve/pointer/:!registration,12345!sequence,01!package,001."
      row = ['12345', '01', '', '', '', '', '', '', '', '', '001']
      skip('Niklaus has no time to debug this')
      assert_equal(expected, @plugin.resolve_link(row))
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
    def test_update_registrations
      registration = flexmock('registration')
      sequence = flexmock('sequence')
      composition = flexmock('composition')
      # Actually, we should test the following methods too withtout flexmock
      flexmock(@plugin) do |plg|
        plg.should_receive(:update_registration).and_return(registration)
        plg.should_receive(:update_sequence).and_return(sequence)
        plg.should_receive(:update_compositions).and_return([composition])
        plg.should_receive(:update_galenic_form)
        plg.should_receive(:update_package)
      end
      rows = ['row']
      replacements = []
      assert_equal(['row'], @plugin.update_registrations(rows, replacements))
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
    def test_initialize_export_registrations
      flexmock(@plugin) do |plg|
        plg.should_receive(:get_latest_file).and_return(true)
      end
      flexmock(FileUtils, :cp => nil)
      row = [0]
      workbook = flexmock('workbook') do |bok|
        bok.should_receive(:worksheet).and_return(flexmock("sheet") do |sht|
          sht.should_receive(:row).and_return(row)
          sht.should_receive(:each).and_yield(row)
        end)
      end
      flexmock(Spreadsheet) do |spr|
        spr.should_receive(:open).and_yield(workbook)
      end
      expected = {}
      skip('Niklaus has no time to debug this')
      assert_equal(expected, @plugin.initialize_export_registrations('agent'))
    end
    def test_initialize_export_registrations__export
      flexmock(@plugin) do |plg|
        plg.should_receive(:get_latest_file).and_return(true)
      end
      flexmock(FileUtils, :cp => nil)
      row = [0,1,2,3,"E"]
      workbook = flexmock('workbook') do |bok|
        bok.should_receive(:worksheet).and_return(flexmock("sheet") do |sht|
          sht.should_receive(:row).and_return(row)
          sht.should_receive(:each).and_yield(row)
        end)
      end
      flexmock(Spreadsheet) do |spr|
        spr.should_receive(:open).and_yield(workbook)
      end
      expected = {0 => {}}
      skip('Niklaus has no time to debug this')
      assert_equal(expected, @plugin.initialize_export_registrations('agent'))
    end
    def test_update_compositions
      flexmock(@app,
               :substance => 'substance',
               :delete    => 'delete'
              )
      row = [0,1,2,3,4,5,6,7,8,9,10,11,12,13, 'name', 'A)composition_text']
      composition = flexmock('composition', :pointer => 'pointer')
      sequence = flexmock('sequence',
                          :seqnr => 'seqnr',
                          :active_agents => [],
                          :compositions  => [composition]
                         )
      assert_equal([], @plugin.update_compositions(sequence, row))
    end
    def test_update_compositions__create_only
      row = []
      active_agent = flexmock('active_agent')
      sequence = flexmock('sequence',
                          :active_agents => [active_agent],
                          :compositions  => 'compositions'
                         )
      assert_equal('compositions', @plugin.update_compositions(sequence, row, {:create_only => true}))
    end
    def test_update_compositions__else
      row = []
      sequence = flexmock('sequence', :active_agents => [])
      assert_equal([], @plugin.update_compositions(sequence, row))
    end
  end

  # Tests for using with xlsx files
  class SwissmedicPluginTestXLSX < Minitest::Test
    include FlexMock::TestCase

    def setup
      ODDB::GalenicGroup.reset_oids
      ODBA.storage.reset_id
      dir = File.expand_path('../data/prevalence', File.dirname(__FILE__))
      @app = ODDB::App.new
      @archive = File.expand_path('../var', File.dirname(__FILE__))
      FileUtils.rm_rf(@archive)
      FileUtils.mkdir_p(@archive)
      @latest = File.join @archive, 'xls', 'Packungen-latest.xlsx'
      @plugin = SwissmedicPlugin.new @app, @archive
      @current  = File.expand_path '../data/xlsx/Packungen-2015.07.02.xlsx', File.dirname(__FILE__)
      @older    = File.expand_path '../data/xlsx/Packungen-2015.06.04.xlsx', File.dirname(__FILE__)
      @target   = File.join @archive, 'xls',  @@today.strftime('Packungen-%Y.%m.%d.xlsx')
      FileUtils.makedirs(File.dirname(@latest)) unless File.exists?(File.dirname(@latest))
      FileUtils.rm(@latest) if File.exists?(@latest)
    end
    def teardown
      super # to clean up FlexMock
    end
    def setup_index_page
      link = flexmock('link', :href => 'href')
      links = flexmock('links', :select => [link])
      page = flexmock('page', :links => links)
      index = flexmock 'index'
      link1 = OpenStruct.new :attributes => {'title' => 'Packungen'},
                             :href => 'url'
      link2 = OpenStruct.new :attributes => {'title' => 'Something'},
                             :href => 'other'
      link3 = OpenStruct.new :attributes => {'title' => 'Präparateliste'},
                             :href => 'url'
      index.should_receive(:links).and_return [link1, link2, link3]
      index.should_receive(:body).and_return(IO.read(@current))
      agent = flexmock(Mechanize.new)
      agent.should_receive(:user_agent_alias=).and_return(true)
      agent.should_receive(:get).and_return(index)
      uri = 'http://www.example.com'
      [agent, page]
    end
    def test_july_2015
      agent, page = setup_index_page
      # Use first the last month and compare it to a non existing lates
      FileUtils.rm(Dir.glob("#{File.dirname(@latest)}/*"), :verbose => true)
      FileUtils.cp(@older, File.dirname(@latest), :verbose => true, :preserve => true)
      FileUtils.cp(@current, @target, :verbose => true, :preserve => true)
      FileUtils.cp(@older, @latest, :verbose => true, :preserve => true)

      newest  = @current.clone
      @adata = @older.clone
      assert_equal(0, @app.registrations.size)
      reg = @app.create_registration('00278')
      seq = reg.create_sequence('01')
      seq.name_base = 'Colon Sérocytol, suppositoire'
      seq.name_descr = 'name_descr'
      seq.composition_text = 'composition_text'
      seq.dose = nil
      seq.sequence_date = Date.new(2017,5,9)
      seq.export_flag = false
      seq.atc_class = ODDB::AtcClass.new('AB0')
      seq.indication = 'indication'
      seq.create_package('001')
      seq.create_package('002')

      reg = @app.create_registration('00279')
      seq = reg.create_sequence('01')
      seq.create_package('001')
      seq.create_package('002')

      result = @plugin.update(agent)
      assert File.exist?(@target), "#@target was not saved"
      @app.registrations.each{ |reg| puts "reg #{reg[1].iksnr} with #{reg[1].sequences.size} sequences"} if $VERBOSE
      assert_equal(5, @app.registrations.size)
      assert_equal(7, @app.sequences.size)
      assert_equal(13, @app.packages.size)
      assert_equal({"00278"=>[:company], "48624"=>[:new], "62069"=>[:new], "16105"=>[:new], "00279"=>[:delete]}, result)

      result_second_run = @plugin.update(agent)
      assert_equal({}, result_second_run)
      assert_equal(5, @app.registrations.size)
      assert_equal(7, @app.sequences.size)
      assert_equal(13, @app.packages.size)
    end
  end
end
