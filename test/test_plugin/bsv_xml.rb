#!/usr/bin/env ruby
# encoding: utf-8
# TestBsvXmlPlubin -- oddb.org -- 11.05.2012 -- yasaka@ywesee.com
# TestBsvXmlPlubin -- oddb.org -- 21.06.2011 -- mhatakeyama@ywesee.com
# TestBsvXmlPlugin -- oddb.org -- 10.11.2008 -- hwyss@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'stub/odba'
require 'model/registration'
require 'model/sequence'
require 'model/package'
require 'plugin/bsv_xml'
require 'flexmock/minitest'
require 'util/logfile'
require 'ext/swissindex/src/swissindex'
require 'ext/refdata/src/refdata'
require 'test_helpers' # for VCR setup

module ODDB
  class PackageCommon
  end
  class Package < PackageCommon
  end
end

module ODDB
  class TestListener <Minitest::Test
    def teardown
      ODBA.storage = nil
      super # to clean up FlexMock
    end
    def setup
      ODDB::TestHelpers.vcr_setup
      app = flexmock('app')
      @listener = ODDB::BsvXmlPlugin::Listener.new(app)
    end
    def test_date
      expected = Date.new(2011,2,1)
      assert_equal(expected, @listener.date('01.02.2011'))
    end
    def test_date__nil
      assert_nil(@listener.date(''))
    end
    def test_text
      @listener.instance_eval('@html="<html>html</html>"')
      expected = "htmltext\ntext"
      assert_equal(expected, @listener.text('text<br />text'))
    end
    def test_text__nil
      @listener.instance_eval('@html=nil')
      assert_nil(@listener.text('text<br />text'))
    end
    def test_time
      expected = Time.local(2011,2,1)
      assert_equal(expected, @listener.time('01.02.2011'))
    end
    def test_time__nil
      assert_nil(@listener.time(''))
    end
    def test_update_chapter
      paragraph = flexmock(Array.new) do |p|
        p.should_receive(:reduce_format)
        p.should_receive(:augment_format)
      end
      section = flexmock('section') do |s|
        s.should_receive(:subheading).and_return('')
        s.should_receive(:next_paragraph).and_return(paragraph)
      end
      chapter = flexmock('chapter') do |c|
        c.should_receive(:next_section).and_return(section)
        c.should_receive(:clean!).and_return('clean!')
      end
      text = "<i>hello</i>\n<h>hello</h>"
      assert_equal('clean!', @listener.update_chapter(chapter, text, 'subheading'))

      # check a local variable
      expected = ["hello", "\n", "<", "h>hello", "<", "/h>"]
      assert_equal(expected, paragraph)
    end
  end

  class TestGenericsListener <Minitest::Test
    def teardown
      ODBA.storage = nil
      super # to clean up FlexMock
    end
    def setup
      ODDB::TestHelpers.vcr_setup
      @app = flexmock('app')
      @listener = ODDB::BsvXmlPlugin::GenericsListener.new(@app)
    end
    def test_tag_start
      assert_equal('', @listener.tag_start('name', 'attrs'))

      # check instance variables
      assert_equal('', @listener.instance_eval('@text'))
      assert_equal('', @listener.instance_eval('@html'))
    end
    def test_tag_end__OrgGen
      flexstub(@app) do |app|
        app.should_receive(:create)
        app.should_receive(:update)
      end
      package = flexmock('package') do |p|
        p.should_receive(:pointer)
      end
      @listener.instance_eval('@pointer = "pointer"')
      @listener.instance_eval('@original = package')
      @listener.instance_eval('@generic = package')
      assert_nil(@listener.tag_end('OrgGen'))
    end
    def test_tag_end__else
      assert_nil(@listener.tag_end('name'))

      # check instance variables
      assert_nil(@listener.instance_eval('@text'))
      assert_nil(@listener.instance_eval('@html'))
    end
  end

  class TestItCodesListener <Minitest::Test
    def teardown
      ODBA.storage = nil
      super # to clean up FlexMock
    end
    def setup
      ODDB::TestHelpers.vcr_setup
      @app = flexmock('app')
      @listener = ODDB::BsvXmlPlugin::ItCodesListener.new(@app)
    end
    def test_tag_start__ItCode
      attr = {'Code' => 'code'}
      assert_equal({}, @listener.tag_start('ItCode', attr))

      # check instance variables
      expected = Persistence::Pointer.new [:index_therapeuticus, 'code']
      assert_equal(expected, @listener.instance_eval('@pointer'))
      assert_equal({}, @listener.instance_eval('@target_data'))
      assert_equal({}, @listener.instance_eval('@data'))
      target_data_id = @listener.instance_eval('@target_data.object_id')
      data_id = @listener.instance_eval('@data.object_id')
      assert_equal(target_data_id, data_id)
    end
    def test_tag_start__Limitations
      assert_equal({}, @listener.tag_start('Limitations', 'attr'))

      # check instance variables
      assert_equal({}, @listener.instance_eval('@target_data'))
      assert_equal({}, @listener.instance_eval('@lim_data'))
      target_data_id = @listener.instance_eval('@target_data.object_id')
      lim_data_id = @listener.instance_eval('@lim_data.object_id')
      assert_equal(target_data_id, lim_data_id)
    end
    def test_tag_start__else
      assert_equal('', @listener.tag_start('name', 'attr'))

      # check instance variables
      assert_equal('', @listener.instance_eval('@text'))
      assert_equal('', @listener.instance_eval('@html'))
    end
    def test_tag_end__ItCode
      flexstub(@app) do |app|
        app.should_receive(:update)
      end
      pointer = flexmock('pointer') do |ptr|
        ptr.should_receive(:creator)
      end
      flexstub(pointer) do |ptr|
        ptr.should_receive(:+).and_return(pointer)
      end
      @listener.instance_eval('@pointer = pointer')
      lim_data = {'key' => 'value'}
      @listener.instance_eval('@lim_data = lim_data')
      assert_nil(@listener.tag_end('ItCode'))
    end
    def test_tag_end__Limitations
      @listener.instance_eval('@target_data = {}')
      assert_nil(@listener.tag_end('Limitations'))
    end
    def test_tag_end__ValidFromDate
      @listener.instance_eval('@target_data = {}')
      assert_nil(@listener.tag_end('ValidFromDate'))

      # check instance variable
      assert_equal({:valid_from=>nil}, @listener.instance_eval('@target_data'))
    end
    def test_tag_end__Points
      @listener.instance_eval('@target_data = {}')
      assert_nil(@listener.tag_end('Points'))

      # check instance variable
      assert_equal({:limitation_points=>0}, @listener.instance_eval('@target_data'))
    end
    def test_tag_end__else
      assert_nil(@listener.tag_end('name'))

      # check instance variables
      assert_nil(@listener.instance_eval('@text'))
      assert_nil(@listener.instance_eval('@html'))
    end
  end

  class BsvXmlPlugin
    class PreparationsListener < Listener
      MEDDATA_SERVER = self
    end
  end

  class TestPreparationsListener <Minitest::Test
    def teardown
      ODBA.storage = nil
      super # to clean up FlexMock
    end
    def setup
      ODDB::TestHelpers.vcr_setup
      @package = flexmock('package') do |pac|
        pac.should_receive(:public?).and_return(true)
        pac.should_receive(:sl_entry).and_return(true)
        pac.should_receive(:pointer)
        pac.should_receive(:name_base)
        pac.should_receive(:atc_class)
        pac.should_receive(:pharmacode)
        pac.should_receive(:iksnr)
        pac.should_receive(:ikskey)
        pac.should_receive(:[]).and_return('name_base')
      end
      @app = flexmock('app') do |app|
        app.should_receive(:each_package).and_yield(@package)
      end
      @listener = ODDB::BsvXmlPlugin::PreparationsListener.new(@app)
    end

    def test_completed_registrations
      completed_registrations = {'key' => 'value'}
      @listener.instance_eval('@completed_registrations = completed_registrations')
      assert_equal(['value'], @listener.completed_registrations)
    end
    def test_erroneous_packages
      known_packages = {'key' => @package}
      @listener.instance_eval('@known_packages = known_packages')
      assert_equal([@package], @listener.erroneous_packages)
    end
    def test_flag_change
      assert_equal(['key'], @listener.flag_change('pointer', 'key'))
    end
    def test_find_typo_registration
      name = flexmock('name') do |n|
        n.should_receive(:collect).and_return(['name'])
        n.should_receive(:downcase)
      end
      sequence = flexmock("sequence_#{__LINE__}") do |s|
        s.should_receive(:"name_base.downcase").and_return(['name'])
      end
      registration = flexmock("registration_#{__LINE__}") do |r|
        r.should_receive(:"sequences.collect").and_yield('seqnr', sequence)
      end
      flexstub(@app) do |a|
        a.should_receive(:registration).and_return(registration)
      end
      assert_equal(registration, @listener.find_typo_registration('iksnr', name))
    end
    def test_find_typo_registration__nil
      name = flexmock('name') do |n|
        n.should_receive(:collect)
      end
      assert_nil(@listener.find_typo_registration('', name))
    end
    def test_identify_sequence
      active_agent = flexmock('active_agent') do |act|
        act.should_receive(:same_as?)
      end
      sequence = flexmock("sequence_#{__LINE__}") do |seq|
        seq.should_receive(:active_agents).and_return([active_agent])
      end
      pointer = flexmock('pointer') do |ptr|
        ptr.should_receive(:creator)
      end
      flexmock(pointer) do |ptr|
        ptr.should_receive(:+).and_return(pointer)
      end
      registration = flexmock("registration_#{__LINE__}") do |reg|
        reg.should_receive(:sequences).and_return({'key' => sequence})
        reg.should_receive(:pointer).and_return(pointer)
      end
      flexmock(@app) do |app|
        app.should_receive(:update).and_return(sequence)
      end
      name = {:de => ''}
      substances = [{}]
      assert_equal(sequence, @listener.identify_sequence(registration, name, substances))
    end
    def test_identify_sequence__active_agent_nil
      pointer = flexmock('pointer') do |ptr|
        ptr.should_receive(:creator)
      end
      sequence = flexmock("sequence_#{__LINE__}") do |seq|
        seq.should_receive(:active_agents).and_return([])
        seq.should_receive(:pointer).and_return(pointer)
        seq.should_receive(:oid)
      end
      flexmock(pointer) do |ptr|
        ptr.should_receive(:+).and_return(pointer)
      end
      registration = flexmock("registration_#{__LINE__}") do |reg|
        reg.should_receive(:sequences).and_return({'key' => sequence})
        reg.should_receive(:pointer).and_return(pointer)
      end
      flexmock(@app) do |app|
        app.should_receive(:update).and_return(sequence)
        app.should_receive(:create).and_return(registration)
        app.should_receive(:substance)
      end
      name = {:de => ''}
      substances = [{}]
      assert_equal(sequence, @listener.identify_sequence(registration, name, substances))
    end
=begin
    def test_load_ikskey
      meddata = flexmock('meddata') do |med|
        med.should_receive(:search).and_return(['result'])
        med.should_receive(:detail).and_return({:ean13 => '12345678'})
      end
      flexmock(BsvXmlPlugin::PreparationsListener) do |meddata_server|
        meddata_server.should_receive(:session).and_yield(meddata)
      end
      assert_equal('5678', @listener.load_ikskey('pcode'))
    end
=end
    def stderr_null
      require 'tempfile'
      $stderr = Tempfile.open('stderr')
      yield
      $stderr.close
      $stderr = STDERR
    end
    def replace_constant(constant, temp)
      stderr_null do
        keep = eval constant
        eval "#{constant} = temp"
        yield
        eval "#{constant} = keep"
      end
    end
    def test_load_ikskey
      swissindex = flexmock('swissindex', :search_item => {:gtin => TestHelpers::LEVETIRACETAM_GTIN})
      server = flexmock('server') do |serv|
        serv.should_receive(:session).and_yield(swissindex)
      end
      replace_constant('ODDB::RefdataPlugin::REFDATA_SERVER', server) do
        assert_equal('62069008', @listener.load_ikskey('pharmacode'))
      end
    end
    def test_load_ikskey__nil
      assert_nil(@listener.load_ikskey(''))
    end
    def test_load_ikskey__error
      swissindex = flexmock('swissindex', :search_item => nil)
      server = flexmock('server') do |serv|
        serv.should_receive(:session).and_yield(swissindex)
      end
      replace_constant('ODDB::RefdataPlugin::REFDATA_SERVER', server) do
        @listener.load_ikskey('pcode')
      end
    end
    def test_tag_start__pack
      # Memo
      # This method is too long.
      # It should be divided into small methods
      @listener.instance_eval('@pac_data = {}')
      @listener.instance_eval('@report_data = {}')
      @listener.instance_eval('@data = {}')
      @listener.instance_eval('@reg_data = {}')
      @listener.instance_eval('@seq_data = {}')
      assert_equal({}, @listener.tag_start('Pack', 'attr'))
    end
    def test_tag_start__limitation
      assert_equal(true, @listener.tag_start('Limitation', 'attr'))
      assert_equal(true, @listener.instance_eval('@in_limitation'))
    end
    def test_tag_start__error
      pac_data = flexmock('pac_data') do |pac|
        pac.should_receive(:dup).and_raise(StandardError)
      end
      @listener.instance_eval('@pac_data = pac_data')
      assert_raises(StandardError) do
        @listener.tag_start('Pack', 'attr')
      end
    end
    def test_tag_end__pack
      # Memo
      # This method is too long.
      # It should be divided into small methods
      atc_class = flexmock('atc_class') do |atc_class|
        atc_class.should_receive(:code).and_return('code')
      end
      sequence = flexmock("sequence_#{__LINE__}") do |seq|
        seq.should_receive(:atc_class).and_return(atc_class)
        seq.should_receive(:pointer)
        seq.should_receive(:odba_store)
      end
      registration = flexmock("registration{__LINE__}") do |reg|
        reg.should_receive(:ikscat)
#        reg.should_receive(:pointer)
#        reg.should_receive(:odba_store)
      end
      package = flexmock('package') do |pac|
        pac.should_receive(:registration).and_return(registration)
        pac.should_receive(:price_public).and_return(nil)
        pac.should_receive(:pharmacode).and_return('pharmacode')
        pac.should_receive(:sequence).and_return(sequence)
        pac.should_receive(:price_exfactory).and_return(1)
        pac.should_receive(:pointer)
        pac.should_receive(:odba_store)
        pac.should_receive(:index_therapeuticus)
        pac.should_receive(:ikscat)
        pac.should_receive(:generic_type)
        pac.should_receive(:deductible)
        pac.should_receive(:narcotic?)
        pac.should_receive(:bm_flag)
        pac.should_receive(:sl_generic_type)
      end
      data = {:public_price => nil, :price_exfactory => 2}
      @listener.instance_eval('@pack = package')
      @listener.instance_eval('@data = data')
      @listener.instance_eval('@report = {}')
      @listener.instance_eval('@sl_entries = {}')
      @listener.instance_eval('@lim_texts = {}')
      flexmock(@app) do |app|
        app.should_receive(:update)
      end
      assert_nil(@listener.tag_end('Pack'))  # TODO:
    end
    def test_tag_end__preparation
      @listener.instance_eval('@deferred_packages = []')
      txt_ptr = flexmock('txt_pointer') do |ptr|
        ptr.should_receive(:resolve)
        ptr.should_receive(:creator)
      end
      sl_ptr = flexmock('sl_pointer') do |ptr|
        ptr.should_receive(:+).and_return(txt_ptr)
      end
      sl_entry = flexmock('sl_entry') do |sle|
        sle.should_receive(:pointer).and_return(sl_ptr)
        #sle.should_receive(:limitation_text)
        sle.should_receive(:limitation_text).and_return('limitation_text')
      end
      package = flexmock('package') do |pac|
        pac.should_receive(:sl_entry).and_return(sl_entry)
      end
      pac_ptr = flexmock('package_pointer') do |ptr|
        ptr.should_receive(:resolve).and_return(package)
      end
      flexmock(pac_ptr) do |ptr|
        ptr.should_receive(:+).and_return(pac_ptr)
        ptr.should_receive(:creator)
      end
      #sl_entries = {pac_ptr => {'key' => 'sl_data'}}
      sl_entries = {pac_ptr => {}}
      @listener.instance_eval('@sl_entries = sl_entries')
      lim_texts = {pac_ptr => 'lim_data'}
      @listener.instance_eval('@lim_texts = lim_texts')
      flexmock(@app) do |app|
        app.should_receive(:delete)
        app.should_receive(:update)
      end
      assert_nil(@listener.tag_end('Preparation'))
    end
    def test_tag_end__preparation__limitation_text__sl_data
      @listener.instance_eval('@deferred_packages = []')
      txt_ptr = flexmock('txt_pointer') do |ptr|
        ptr.should_receive(:resolve)
        ptr.should_receive(:creator)
      end
      sl_ptr = flexmock('sl_pointer') do |ptr|
        ptr.should_receive(:+).and_return(txt_ptr)
      end
      limitation_text = flexmock('limitation_text') do |ptr|
        ptr.should_receive(:+).and_return(txt_ptr)
      end
      sl_entry = flexmock('sl_entry') do |sle|
        sle.should_receive(:pointer).and_return(sl_ptr)
        #sle.should_receive(:limitation_text)
        sle.should_receive(:limitation_text).and_return(limitation_text)
      end
      package = flexmock('package') do |pac|
        pac.should_receive(:sl_entry).and_return(sl_entry)
      end
      pac_ptr = flexmock('package_pointer') do |ptr|
        ptr.should_receive(:resolve).and_return(package)
      end
      flexmock(pac_ptr) do |ptr|
        ptr.should_receive(:+).and_return(pac_ptr)
        ptr.should_receive(:creator)
      end
      sl_entries = {pac_ptr => {'key' => 'sl_data'}}
      @listener.instance_eval('@sl_entries = sl_entries')
      @listener.instance_eval('@lim_texts = {}')
      @listener.instance_eval('@name = {:de => :name_de}')
      flexmock(@app) do |app|
        app.should_receive(:delete)
        app.should_receive(:update)
      end
      assert_nil(@listener.tag_end('Preparation'))
    end
    def test_tag_end__swissmedic_no_5
      @listener.instance_eval('@report_data = {}')
      visited_iksnrs = {'12345' => ['atc', 'name']}
      @listener.instance_eval('@visited_iksnrs = visited_iksnrs')
      @listener.instance_eval('@text = "12345"')
      @listener.instance_eval('@atc_code = "atc_code"')

      # for find_typo_resigration
      name = flexmock('name') do |n|
        n.should_receive(:collect).and_return(['name'])
        n.should_receive(:downcase)
      end
      sequence = flexmock("sequence_#{__LINE__}") do |s|
        s.should_receive(:"name_base.downcase").and_return(['name'])
      end
      registration = flexmock("registration_#{__LINE__}") do |r|
        r.should_receive(:"sequences.collect").and_yield('seqnr', sequence)
        r.should_receive(:iksnr).and_return('iksnr')
        r.should_receive(:packages).and_return([])
      end
      flexstub(@app) do |a|
        a.should_receive(:registration).and_return(registration)
      end
      @listener.instance_eval('@name = name')
      assert_nil(@listener.tag_end('SwissmedicNo5'))
    end
    def test_tag_end__swissmedic_no_5__else
      @listener.instance_eval('@report_data = {}')
      visited_iksnrs = {'12345' => ['atc', {:de => 'name'}]}
      @listener.instance_eval('@visited_iksnrs = visited_iksnrs')
      @listener.instance_eval('@text = "12345"')
      @listener.instance_eval('@atc_code = "atc_code"')

      flexmock(@listener) do |lis|
        lis.should_receive(:find_typo_registration)
      end
      assert_nil(@listener.tag_end('SwissmedicNo5'))
    end
    def test_tag_end__swissmedic_no_8
      @listener.instance_eval('@report = {}')
      @listener.instance_eval('@text = ""')
      flexmock(@app) do |app|
        app.should_receive(:registration)
      end
      assert_nil(@listener.tag_end('SwissmedicNo8'))
    end
    def test_tag_end__swissmedic_no_8__out_of_trade
      @listener.instance_eval('@report = {}')
      @listener.instance_eval('@text = ""')
      flexmock(@app) do |app|
        app.should_receive(:registration)
      end
      @listener.instance_eval('@out_of_trade = "out_of_trade"')
      assert_nil(@listener.tag_end('SwissmedicNo8'))
    end
    def test_tag_end__StatusTypeCodeSl__2_6
      @listener.instance_eval('@sl_data = {}')
      @listener.instance_eval('@text = "2"')
      pack = flexmock('package') do |pac|
        pac.should_receive(:sl_entry)
        pac.should_receive(:pointer)
      end
      @listener.instance_eval('@pack = pack')
      assert_nil(@listener.tag_end('StatusTypeCodeSl'))
    end
    def test_tag_end__StatusTypeCodeSl__3_7
      @listener.instance_eval('@sl_data = {}')
      @listener.instance_eval('@text = "3"')
      pack = flexmock('package') do |pac|
        pac.should_receive(:sl_entry).and_return('sl_entry')
        pac.should_receive(:pointer)
      end
      @listener.instance_eval('@pack = pack')
      assert_nil(@listener.tag_end('StatusTypeCodeSl'))
    end
    def test_tag_end__StatusTypeCodeSl__confict
      @listener.instance_eval('@sl_data = {}')
      @listener.instance_eval('@conflict = "conflict"')
      @listener.instance_eval('@out_of_trade = "out_of_trade"')
      assert_nil(@listener.tag_end('StatusTypeCodeSl'))
    end
    def test_tag_end__limitation
      assert_nil(@listener.tag_end('Limitation'))
    end
    def test_tag_end__limitationXXX
      assert_nil(@listener.tag_end('LimitationXXX'))
    end
    def test_tag_end__description
      @listener.instance_eval('@in_limitation = "in_limitation"')
      @listener.instance_eval('@lim_data = {}')
      @listener.instance_eval('@html = ""')
      assert_nil(@listener.tag_end('DescriptionXX'))
    end
    def test_tag_end__description_else
      @listener.instance_eval('@in_limitation = "in_limitation"')
      @listener.instance_eval('@html = ""')
      @listener.instance_eval('@name = {:xx => "name"}')

      # for update_chapter
      paragraph = flexmock(Array.new) do |p|
        p.should_receive(:reduce_format)
        p.should_receive(:augment_format)
      end
      section = flexmock('section') do |s|
        s.should_receive(:subheading).and_return('')
        s.should_receive(:next_paragraph).and_return(paragraph)
      end
      chapter = flexmock('chapter') do |c|
        c.should_receive(:next_section).and_return(section)
        c.should_receive(:clean!).and_return('clean!')
      end

      lim_texts = {'key' => {:xx => chapter}}
      @listener.instance_eval('@lim_texts = lim_texts')
      assert_nil(@listener.tag_end('DescriptionXX'))
    end
    def test_tag_end__description_else_it_descriptions
      @listener.instance_eval('@in_limitation = "in_limitation"')
      @listener.instance_eval('@html = ""')
      @listener.instance_eval('@name = {:xx => "name"}')

      # for update_chapter
      paragraph = flexmock(Array.new) do |p|
        p.should_receive(:reduce_format)
        p.should_receive(:augment_format)
      end
      section = flexmock('section') do |s|
        s.should_receive(:subheading).and_return('')
        s.should_receive(:next_paragraph).and_return(paragraph)
      end
      chapter = flexmock('chapter') do |c|
        c.should_receive(:next_section).and_return(section)
        c.should_receive(:clean!).and_return('clean!')
      end

      lim_texts = {'key' => {:xx => chapter}}
      @listener.instance_eval('@lim_texts = lim_texts')
      @listener.instance_eval('@it_descriptions = {:xx => "it_descriptions"}')
      assert_nil(@listener.tag_end('DescriptionXX'))
    end
    def test_tag_end__points
      @listener.instance_eval('@sl_data = {}')
      assert_nil(@listener.tag_end('Points'))
    end
    def test_tag_end__preparations
      pointer = flexmock('pointer') do |ptr|
        ptr.should_receive(:+)
      end
      known_packages = {pointer => 'data'}
      @listener.instance_eval('@known_packages = known_packages')
      flexmock(@app) do |app|
        app.should_receive(:delete)
      end
      assert_nil(@listener.tag_end('Preparations'))
    end
    def test_tag_end__error
      pointer = flexmock('pointer') do |ptr|
        ptr.should_receive(:+).and_raise(StandardError)
      end
      known_packages = {pointer => 'data'}
      @listener.instance_eval('@known_packages = known_packages')
      assert_raises(StandardError) do
        @listener.tag_end('Preparations')
      end
    end
  end

  class TestBsvXmlPlugin2 <Minitest::Test
    def teardown
      ODBA.storage = nil
      super # to clean up FlexMock
    end
    def setup
      ODDB::TestHelpers.vcr_setup
      flexstub(LogFile) do |log|
        log.should_receive(:append)
      end
      @target_file = flexmock('target_file') do |t|
        t.should_receive(:save_as)
      end
      @app = flexmock('app')
      @plugin = BsvXmlPlugin.new(@app)

    end
    def test__update
      entry = flexmock('entry') do |e|
        e.should_receive(:name).and_return('AbCdef-123.xml')
      end
      flexstub(Zip::File) do |z|
        z.should_receive(:foreach).and_yield(entry)
      end
      assert_nil @plugin._update('path')
    end
    def test__update_do_nothing
      entry = flexmock('entry') do |e|
        e.should_receive(:name).and_return('Publications.xls')
      end
      flexstub(Zip::File) do |z|
        z.should_receive(:foreach).and_yield(entry)
      end
      assert_nil(@plugin._update('path'))
    end
    def test_download_file
      flexstub(File) do |f|
        f.should_receive(:exist?)
      end
      flexstub(FileUtils) do |f|
        f.should_receive(:cp)
      end
      target_file = flexmock('target_file') do |t|
        t.should_receive(:save_as)
      end
      flexstub(Mechanize) do |klass|
        klass.should_receive(:new).and_return(flexmock('mechanize') do |m|
          m.should_receive(:get).and_return(target_file)
        end)
      end
      assert_equal('save_dir/file_name', @plugin.download_file('target_url', 'save_dir', 'file_name'))
    end
    def test_download_file__file_exist
      flexstub(File) do |f|
        f.should_receive(:exist?).and_return(true)
      end
      flexstub(FileUtils) do |f|
        f.should_receive(:cp)
        f.should_receive(:compare_file).and_return(true)
      end
      target_file = flexmock('target_file') do |t|
        t.should_receive(:save_as)
      end
      flexstub(Mechanize) do |klass|
        klass.should_receive(:new).and_return(flexmock('mechanize') do |m|
          m.should_receive(:get).and_return(target_file)
        end)
      end
      assert_raises(Errno::ENOENT) do
        @plugin.download_file('target_url', 'save_dir', 'file_name')
      end
    end
    def test_download_file__error
      flexstub(@target_file) do |t|
        t.should_receive(:save_as).and_raise(EOFError)
      end
      flexstub(Mechanize) do |klass|
        klass.should_receive(:new).and_return(flexmock('mechanize') do |m|
          m.should_receive(:get).and_return(@target_file)
        end)
      end
      flexstub(@plugin) do |p|
        p.should_receive(:sleep)
      end
      assert_raises(Errno::ENOENT) do
        @plugin.download_file('target_url', 'save_dir', 'file_name')
      end
    end
    def test_update
      # The methods, download_file and _update, are tested above
      # so it is not necessary to test them again here as an unit test.
      # But it is useful to test this as an integration test.
      flexstub(@plugin) do |p|
        p.should_receive(:download_file).and_return('path')
        p.should_receive(:_update)
      end
      assert_equal('path', @plugin.update)
    end
    def test_report
      preparations_listener = flexmock('preparations_listener') do |p|
        p.should_receive(:created_sl_entries).and_return(0)
        p.should_receive(:updated_sl_entries).and_return(0)
        p.should_receive(:deleted_sl_entries).and_return(0)
        p.should_receive(:created_limitation_texts).and_return(0)
        p.should_receive(:updated_limitation_texts).and_return(0)
        p.should_receive(:deleted_limitation_texts).and_return(0)
      end
      @plugin.instance_eval('@preparations_listener = preparations_listener')
      expected = "Created SL-Entries                                            0\n" +
                 "Updated SL-Entries                                            0\n" +
                 "Deleted SL-Entries                                            0\n" +
                 "Created Limitation-Texts                                      0\n" +
                 "Updated Limitation-Texts                                      0\n" +
                 "Deleted Limitation-Texts                                      0"
      assert_equal(expected, @plugin.report)
    end
    def test_log_info
      # Memo:
      # log_info method is too long.
      # It should be divided into small methods.

      preparations_listener = flexmock('preparations_listener') do |p|
        p.should_receive(:created_sl_entries).and_return(0)
        p.should_receive(:updated_sl_entries).and_return(0)
        p.should_receive(:deleted_sl_entries).and_return(0)
        p.should_receive(:created_limitation_texts).and_return(0)
        p.should_receive(:updated_limitation_texts).and_return(0)
        p.should_receive(:deleted_limitation_texts).and_return(0)
        p.should_receive(:duplicate_iksnrs).and_return([])
        p.should_receive(:completed_registrations).and_return([])
        p.should_receive(:conflicted_registrations).and_return([])
        p.should_receive(:conflicted_packages_oot).and_return([])
        p.should_receive(:missing_ikscodes).and_return([])
        p.should_receive(:missing_pharmacodes).and_return([])
        p.should_receive(:missing_ikscodes_oot).and_return([])
        p.should_receive(:unknown_packages).and_return([])
        p.should_receive(:unknown_packages_oot).and_return([])
      end
      package = flexmock('package') do |p|
        p.should_receive(:pharmacode)
        p.should_receive(:out_of_trade)
        p.should_receive(:expired?)
      end
      flexmock(@app) do |app|
        app.should_receive(:packages).and_return([package])
      end
      @plugin.instance_eval('@preparations_listener = preparations_listener')
      log_info = @plugin.log_info
      assert_kind_of(Hash, log_info)
      expected = ["change_flags", "parts", "recipients", "report"]
      assert_equal(expected, log_info.keys.map{|k| k.to_s}.sort)
      # Actually, the value of log_info should be checked but
      # it is too big data.
      # if you want to see the actual return value of log_info method,
      # just run below:
      assert(/^Updated SL-Entries\s+0$/.match(log_info[:report]), 'Updated SL-Entries')
      assert(/Duplicate Registrations in SL/.match(log_info[:report]), 'Duplicate Registrations in SL')
    end

    def wrap_update(klass, subj, &block)
      begin
        block.call
      rescue Exception => e #RuntimeError, StandardError => e
        notify_error(klass, subj, e)
        raise
      end
    rescue StandardError
      nil
    end

    def test_wrap_update_bsv
      Util.configure_mail :test
      Util.clear_sent_mails
      preparations_listener = flexmock('preparations_listener') do |p|
        p.should_receive(:created_sl_entries).and_return(['created_sl_entries'])
        p.should_receive(:conflicted_registrations).and_return([])
        p.should_receive(:missing_ikscodes).and_return([])
        p.should_receive(:missing_ikscodes_oot).and_return([])
        p.should_receive(:unknown_packages).and_return([])
        p.should_receive(:unknown_registrations).and_return([])
        p.should_receive(:unknown_packages_oot).and_return([{:test => 'data'}])
        p.should_receive(:missing_pharmacodes).and_return([])
        p.should_receive(:duplicate_iksnrs).and_return([])
      end
      @plugin.instance_eval('@preparations_listener = preparations_listener')
      klass = BsvXmlPlugin
      subj = 'SL-Update (XML)'
      plug = klass.new(@app)
      plug = @plugin

      return_value_plug_update = nil
      result = {:error => -1}
      wrap_update(klass, subj) {
        return_value_plug_update = plug.update
        result =  log_notify_bsv(plug, this_month, subj)
      }
      expected = {"report" => 'x', "parts" => 'y', "recipients" => 'z'}
      assert(result, "result of log_notify_bsv may not be nil" )
      skip "Line #{__LINE__}: Don't know how to test wrap_update"
      assert_equal(expected.keys, result.keys.map{|k| k.to_s}.sort)
      assert_equal(["oddb_bsv", "oddb_bsv_info"], result[:recipients])
      assert(result[:report].index('Dear Mr. Jones'), 'The report must contain a valid anrede for Mr. Jones   (see test/data/oddb_mailing_test.yml)')
      assert(result[:report].index('Dear Mrs. Smith'), 'The report must contain a valid anrede for Mrs. Smith (see test/data/oddb_mailing_test.yml)')
      assert_equal(8, result[:parts].size, 'Must have 8 attachements (aka parts)')
    end

    def test_result
      Util.configure_mail :test
      Util.clear_sent_mails
      preparations_listener = flexmock('preparations_listener') do |p|
        p.should_receive(:created_sl_entries).and_return(['created_sl_entries'])
        p.should_receive(:conflicted_registrations).and_return([])
        p.should_receive(:missing_ikscodes).and_return([])
        p.should_receive(:missing_ikscodes_oot).and_return([])
        p.should_receive(:unknown_registrations).and_return([])
        p.should_receive(:unknown_packages).and_return([])
        p.should_receive(:unknown_packages_oot).and_return([{:test => 'data'}])
        p.should_receive(:missing_pharmacodes).and_return([])
        p.should_receive(:duplicate_iksnrs).and_return([])
      end
      @plugin.instance_eval('@preparations_listener = preparations_listener')
      result = @plugin.log_info_bsv
      expected = ["report", "parts", "recipients"]
      assert_equal(expected.sort, result.keys.map{|k| k.to_s}.sort)
      assert_equal(["oddb_bsv", "oddb_bsv_info"], result[:recipients])
      assert(result[:report].index('Dear Mr. Jones'), 'The report must contain a valid anrede for Mr. Jones   (see test/data/oddb_mailing_test.yml)')
      assert(result[:report].index('Dear Mrs. Smith'), 'The report must contain a valid anrede for Mrs. Smith (see test/data/oddb_mailing_test.yml)')
      assert_equal(6, result[:parts].size, 'Must have 6 attachements (aka parts)')
    end
    def test_report_bsv
      preparations_listener = flexmock('preparations_listener') do |p|
        p.should_receive(:conflicted_registrations).and_return([])
        p.should_receive(:missing_ikscodes).and_return([])
        p.should_receive(:missing_ikscodes_oot).and_return([])
        p.should_receive(:unknown_packages).and_return([])
        p.should_receive(:unknown_registrations).and_return([])
        p.should_receive(:unknown_packages_oot).and_return([{:test => 'data'}])
        p.should_receive(:missing_pharmacodes).and_return([])
        p.should_receive(:duplicate_iksnrs).and_return([])
      end
      @plugin.instance_eval('@preparations_listener = preparations_listener')
      assert_kind_of(String, @plugin.report_bsv)
      #assert_equal('', @plugin.report_bsv)
    end
    def test_report_format_header
      expected = "name                                                        123"
      assert_equal(expected, @plugin.report_format_header('name', 123))
    end
    def test_report_format
      hash = {
        :name_base => 'name_base',
        :name_descr => ' name_descr',
        :atc_class => 'atc_class',
        :generic_type => 'generic_type',
        :deductible => 'deductible',
        :pharmacode_bag => 'pharmacode_bag',
        :pharmacode_oddb => 'pharmacode_oddb',
        :swissmedic_no5_oddb => 'swissmedic_no5_oddb',
        :swissmedic_no8_oddb => 'swissmedic_no8_oddb',
        :swissmedic_no5_bag => 'swissmedic_no5_bag',
        :swissmedic_no8_bag => 'swissmedic_no8_bag'
      }
      expected = "Name-base:           name_base\n" +
                 "Name-descr:           name_descr\n" +
                 "Atc-class:           atc_class\n" +
                 "Generic-type:        generic_type\n" +
                 "Deductible:          deductible\n" +
                 "Swissmedic-no5-oddb: swissmedic_no5_oddb\n" +
                 "Swissmedic-no8-oddb: swissmedic_no8_oddb\n" +
                 "Swissmedic-no5-bag:  swissmedic_no5_bag\n" +
                 "Swissmedic-no8-bag:  swissmedic_no8_bag"
      assert_equal(expected, @plugin.report_format(hash))
    end
    def test_update_generics
      flexmock(REXML::Document) do |xml|
        xml.should_receive(:parse_stream).and_return('parse_stream')
      end
      assert_equal('parse_stream', @plugin.update_generics('io'))
    end
    def test_update_it_codes
      flexmock(REXML::Document) do |xml|
        xml.should_receive(:parse_stream).and_return('parse_stream')
      end
      assert_equal('parse_stream', @plugin.update_it_codes(StringIO.new('io')))
    end
    def test_update_preparations
      flexmock(REXML::Document) do |xml|
        xml.should_receive(:parse_stream).and_return('parse_stream')
      end
      preparations_listener = flexmock('preparations_listener') do |p|
        p.should_receive(:change_flags).and_return('change_flags')
        p.should_receive(:nr_visited_preparations).and_return 0
      end
      flexmock(ODDB::BsvXmlPlugin::PreparationsListener) do |klass|
        klass.should_receive(:new).and_return(preparations_listener)
        klass.should_receive(:nr_visited_preparations).and_return
      end
      assert_equal('change_flags', @plugin.update_preparations(StringIO.new('io')))
    end
  end

  # Memo:
  # Hannes-san made the following test-cases
  # These are a kind of integration tests
  class BsvXmlPlugin
    class PreparationsListener
    end
  end
  class PackageCommon
  end
  class Package < PackageCommon
  end
  class TestBsvXmlPlugin <Minitest::Test
    def teardown
      ODBA.storage = nil
      super # to clean up FlexMock
    end
    def setup
      ODDB::TestHelpers.vcr_setup
      @url = 'http://bag.e-mediat.net/SL2007.Web.External/File.axd?file=XMLPublications.zip'
      ODDB.config.url_bag_sl_zip = @url
      @archive = ODDB::TEST_DATA_DIR
      @zip = File.join @archive, 'xml', 'XMLPublications.zip'
      @app = flexmock 'app'
      @plugin = BsvXmlPlugin.new @app
      @test_src = File.join(TEST_DATA_DIR, 'xml/bsv_test.xml')
      assert(File.exist?(@test_src), "File #{@test_src} must exist?")
      @test_conflict = File.join(TEST_DATA_DIR, 'xml/bsv_test_conflicted.xml')
      assert(File.exist?(@test_conflict), "File #{@test_conflict} must exist?")
      @src = File.read(@test_src)
      @conflicted_src = File.read(@test_conflict)
    end
    def stderr_null
      require 'tempfile'
      $stderr = Tempfile.open('stderr')
      yield
      $stderr.close
      $stderr = STDERR
    end
    def replace_constant(constant, temp)
      stderr_null do
        keep = eval constant
        eval "#{constant} = temp"
        yield
        eval "#{constant} = keep"
      end
    end
    def setup_sequence(ptr)
      seq = flexmock 'sequence'
      seq.should_receive(:compositions).and_return []
      seq.should_receive(:pointer).and_return ptr
      seq.should_receive(:active_agents).and_return([flexmock('active-agent')])
      seq.should_receive(:package).and_return nil
      seq.should_receive(:create_package)
      seq.should_receive(:export_flag).and_return ''
      seq.should_receive(:bag_compositions).and_return []
      seq
    end
   def test_download_file
      # Preparing variables
      target_url = @url
      save_dir = File.expand_path 'var', File.dirname(__FILE__)
      file_name = "XMLPublications.zip"

      online_file = @zip
      temp_file = File.join save_dir, 'temp.zip'
      save_file = File.join save_dir,
               Date.today.strftime("XMLPublications-%Y.%m.%d.zip")
      FileUtils.makedirs save_dir
      latest_file = File.join save_dir, 'XMLPublications-latest.zip'

      # Preparing mock objects
      flexstub(Tempfile).should_receive(:new).and_return do
        flexmock do |tempfile|
          tempfile.should_receive(:close)
          tempfile.should_receive(:unlink)
          tempfile.should_receive(:path).and_return(temp_file)
        end
      end

      fileobj = flexmock do |obj|
        obj.should_receive(:save_as).with(temp_file).and_return do
          FileUtils.cp online_file, temp_file   # instead of downloading
        end
        obj.should_receive(:save_as).with(save_file).and_return do
          FileUtils.cp online_file, save_file   # instead of downloading
        end
      end
      flexstub(Mechanize) do |mechclass|
        mechclass.should_receive(:new).and_return do
          flexmock do |mechobj|
            mechobj.should_receive(:get).and_return(fileobj)
          end
        end
      end

      # Downloading tests
      result = nil
      result = @plugin.download_file(target_url, save_dir, file_name)
      assert_equal save_file, result

      # Not-downloading tests
      result = @plugin.download_file(target_url, save_dir, file_name)
      assert_nil result

      # Check files
      skip("Line #{__LINE__}: Don't know how to mock this stuff at the moment")
      assert File.exist?(save_file), "download to #{save_file} failed."
      assert File.exist?(latest_file), "download to #{latest_file} failed."
    ensure
      FileUtils.rm_r save_dir if File.exist? save_dir
    end
    def test_update_it_codes
      updates = []
      @app.should_receive(:update).times(38).and_return do |ptr, data|
        updates.push data
      end
      zip = Zip::File.open(@zip)
      zip.find_entry('ItCodes.xml').get_input_stream do |io|
        @plugin.update_it_codes io
      end
      expected = {
        :de => "NERVENSYSTEM",
        :fr => "SYSTEME NERVEUX",
        :it => "SYSTEME NERVEUX",
      }
      ith = updates.at(0)
      assert_equal expected, ith
      de = Text::Chapter.new
      pr = de.next_section.next_paragraph
      pr << "Gesamthaft zugelassen "
      pr.augment_format(:bold)
      pr << '120'
      pr.reduce_format(:bold)
      pr << " Punkte. "
      pr.augment_format(:bold)
      pr << "Iniectabilia sine limitatione"
      fr = Text::Chapter.new
      pr = fr.next_section.next_paragraph
      pr << "Prescription limitée au maximum à "
      pr.augment_format(:bold)
      pr << "120"
      pr.reduce_format(:bold)
      pr << " points. "
      pr.augment_format(:bold)
      pr << "Iniectabilia sine limitatione"
      it = Text::Chapter.new
      pr = it.next_section.next_paragraph
      pr << "Ammessi in totale "
      pr.augment_format(:bold)
      pr << "120"
      pr.reduce_format(:bold)
      pr << " punti. "
      pr.augment_format(:bold)
      pr << "Iniectabilia sine limitatione"
      expected = {
        :code       => "120PISL",
        :de         => de,
        :fr         => fr,
        :it         => it,
        :niveau     => "IP",
        :type       => "PKT",
        :valid_from => Date.new(2000),
        :value      => "120",
      }
      ith = updates.at(19)
      assert_equal expected, ith
    end
    def test_update_preparation__unknown_registration__out_of_trade
      updates = []
      @app.should_receive(:registration).and_return nil
      @app.should_receive(:each_package)
      swissindex = flexmock('swissindex', :search_item => {:gtin => TestHelpers::LEVETIRACETAM_GTIN})
      server = flexmock('server')
      replace_constant('ODDB::RefdataPlugin::REFDATA_SERVER', server) do
        @plugin.update_preparations StringIO.new(@src)
      end
      assert_equal [], updates
      assert_equal({}, @plugin.change_flags)
      listener = @plugin.preparations_listener
      assert_equal [], listener.conflicted_registrations
      assert_equal [], listener.unknown_packages
      expected = [{:name_descr => "Filmtabs 500 mg ", :swissmedic_no5_bag => "39271", :name_base => "Ponstan"}]
      assert_equal expected, listener.unknown_registrations
    end
    def test_update_preparation__unknown_registration
      updates = []
      @app.should_receive(:package_by_ikskey).and_return nil
      @app.should_receive(:registration).and_return nil
      @app.should_receive(:each_package)
      swissindex = flexmock('swissindex', :search_item => {:gtin => TestHelpers::LEVETIRACETAM_GTIN})
      server = flexmock('server') do |serv|
        serv.should_receive(:session).and_yield(swissindex)
      end
      replace_constant('ODDB::RefdataPlugin::REFDATA_SERVER', server) do
        @plugin.update_preparations StringIO.new(@src)
      end
      assert_equal [], updates
      assert_equal({}, @plugin.change_flags)
      listener = @plugin.preparations_listener
      assert_equal [], listener.conflicted_registrations
      expected = []
      assert_equal expected, listener.unknown_packages
      expected = [ {
        :name_base          => "Ponstan",
        :name_descr         => "Filmtabs 500 mg ",
        :swissmedic_no5_bag => "39271",
      } ]
      assert_equal expected, listener.unknown_registrations
    end
    def test_update_preparation__conflicted_registration
      reg = setup_registration :iksnr => '39271'
      package = setup_package :pharmacode => "703279", :registration => reg,
                              :steps => %w{39271 02 028},
                              :price_public => Util::Money.new(17.65),
                              :price_exfactory => Util::Money.new(11.22),
                              :data_origin => :sl,
                              :out_of_trade => true
      @app.should_receive(:package_by_ikskey).times(1).and_return package
      flexmock(Persistence).should_receive(:find_by_pointer)
      reg.should_receive(:packages).and_return []
      reg.should_receive(:keep_generic_type).and_return(false)
      # setup_meddata_server
      @app.should_receive(:registration).and_return reg
      @app.should_receive(:each_package)
      @app.should_receive(:delete)
      @app.should_receive(:update)
      composition = flexmock 'composition'
      composition.should_receive(:pointer).and_return(Persistence::Pointer.new(:composition))
      @app.should_receive(:create).and_return composition
      substance = flexmock 'substance'
      substance.should_receive(:oid)
      @app.should_receive(:substance).and_return substance
      expected_updates = {}
      ptr = Persistence::Pointer.new [:registration, '39271']
      expected_updates.store ptr, { :generic_type => :original,
                                    :index_therapeuticus => '07.10.10.' }
      ptr += [:sequence, '02']
      expected_updates.store ptr, {}
      pac_pointer = ptr += [:package, '028']
      pef = Util::Money.new(2.9)
      pef.origin = "http://bag.e-mediat.net/SL2007.Web.External/File.axd?file=XMLPublications.zip (10.05.2010)"
      ppb = Util::Money.new(7.5)
      ppb.origin = "http://bag.e-mediat.net/SL2007.Web.External/File.axd?file=XMLPublications.zip (10.05.2010)"
      data = {
        :price_exfactory => pef,
        :sl_generic_type => :original,
        :deductible      => :deductible_g,
        :price_public    => ppb,
        :narcotic        => false,
      }
      expected_updates.store ptr, data
      ptr += :sl_entry
      data = {
        :bsv_dossier       => "12495",
        :valid_until       => Date.new(9999,12,31),
        :status            => "0",
        :valid_from        => Date.new(1977,3,15),
        :introduction_date => Date.new(1977,3,15),
        :limitation_points => nil,
        :limitation        => nil,
      }
      expected_updates.store ptr.creator, data
      @app.should_receive(:update).at_least.once.and_return do |ptr, data|
        assert_equal expected_updates.delete(ptr), data, ptr.to_s
      end
      @plugin.update_preparations StringIO.new(@conflicted_src)
      listener = @plugin.preparations_listener
      expected = [ {
        :name_base          => "Ponstan",
        :name_descr         => "Filmtabs 500 mg ",
        :swissmedic_no5_bag => "12345",
        :deductible         => :deductible_g,
        :generic_type       => :original,
        :swissmedic_no5_oddb=> "39271",
        :swissmedic_no8_bag => "39271028",
      } ]
      assert_equal expected, listener.conflicted_registrations
      assert_equal [], listener.unknown_packages
      expected = []
      assert_equal [], listener.unknown_registrations
      puts  "Line #{__LINE__}: Don't know why we should have a price_cut here and were it should come from, range not valid"
      skip { assert_equal({pac_pointer => [:price_cut]}, @plugin.change_flags)}
    end
    def test_update_preparation__unknown_package__out_of_trade
      reg = setup_registration :iksnr => '39271'
      seq = setup_sequence(reg.pointer)
      reg.should_receive(:packages).and_return []
      reg.should_receive(:sequences).and_return({})
      reg.should_receive(:keep_generic_type).and_return(false)
      @app.should_receive(:package_by_ikskey).and_return nil
      @app.should_receive(:registration).and_return reg
      @app.should_receive(:each_package)
      seq_ptr = (reg.pointer + [:sequence, '01']).creator
      @app.should_receive(:update).once.with(seq_ptr, {:name_base => 'Ponstan'}).and_return seq
      pack_ptr = (reg.pointer + [:package, '028']).creator
      @app.should_receive(:update).once.with(reg.pointer,  {}).and_return reg
      @app.should_receive(:update).once
      @app.should_receive(:update) do | arg1 |  assert(false)  end
      composition = flexmock 'composition'
      composition.should_receive(:pointer).and_return(Persistence::Pointer.new(:composition))
      @app.should_receive(:create).and_return composition
      substance = flexmock 'substance'
      substance.should_receive(:oid)
      @app.should_receive(:substance).and_return substance
      swissindex = flexmock('swissindex', :search_item => nil)
      server = flexmock('server') do |serv|
        serv.should_receive(:session).and_yield(swissindex)
      end
      skip('Test does not work under Ruby 3.4') if RUBY_VERSION.to_f >= 3.4 # TODO:
      replace_constant('ODDB::RefdataPlugin::REFDATA_SERVER', server) do
        @plugin.update_preparations StringIO.new(@conflicted_src)
      end
      assert_equal({}, @plugin.change_flags)
      listener = @plugin.preparations_listener
      assert_equal [], listener.unknown_registrations
      expected = [ {
        :name_base          => "Ponstan",
        :name_descr         => "Filmtabs 500 mg ",
        :swissmedic_no5_bag => "12345",
        :deductible         => :deductible_g,
        :generic_type       => :original,
        :swissmedic_no5_oddb=> "39271",
        :swissmedic_no8_bag => "39271028",
      } ]
      assert_equal expected, listener.conflicted_registrations
      assert_equal expected, listener.unknown_packages
    end
    def test_update_preparation__unknown_package
      reg = setup_registration :iksnr => '39271'
      reg.should_receive(:packages).and_return []
      reg.should_receive(:sequences).and_return({})
      reg.should_receive(:keep_generic_type).and_return(false)
      @app.should_receive(:package_by_ikskey).and_return nil
      @app.should_receive(:registration).and_return reg
      @app.should_receive(:each_package)
      composition = flexmock 'composition'
      composition.should_receive(:pointer).and_return(Persistence::Pointer.new(:composition))
      @app.should_receive(:create).and_return composition
      substance = flexmock 'substance'
      substance.should_receive(:oid)
      @app.should_receive(:substance).and_return substance
      expected_updates = {}
      # ptr = Persistence::Pointer.new [:registration, '39271']
      ptr = reg.pointer
      expected_updates.store ptr.clone, [{ :generic_type => :original,
                                    :index_therapeuticus => '07.10.10.' }, reg]
      ptr += [:sequence, '01']
      expected_updates.store ptr, [{ :atc_class => 'M01AG01' }, reg]
      seq = flexmock 'sequence'
      seq.should_receive(:compositions).and_return []
      seq.should_receive(:pointer).and_return ptr
      seq.should_receive(:active_agents).and_return([flexmock('active-agent')])
      reg.should_receive(:sequence).and_return(seq)
      seq.should_receive(:bag_compositions).and_return []
      expected_updates.store ptr.creator, [{:name_base=>"Ponstan"}, seq]
      @app.should_receive(:update).and_return seq
      ptr += [:package, '028']
      pac = flexmock 'package'
      pac.should_receive(:sl_entry).and_return nil
      data = {
        :ikscat          => 'B',
        :price_exfactory => Util::Money.new(2.9),
        :sl_generic_type => :original,
        :deductible      => :deductible_g,
        :price_public    => Util::Money.new(7.5),
        :narcotic        => false,
        :pharmacode      => '703279',
      }
      seq.should_receive(:package).and_return pac
      expected_updates.store ptr.creator, [data, pac]
      part = flexmock 'part'
      data = { :composition => nil, :size => '12 Stk' }
      expected_updates.store((ptr + :part).creator, [data, pac])
      sl_entry = flexmock 'sl_entry'
      data = {
        :introduction_date => Date.new(1977, 3, 15),
        :limitation_points => nil,
        :status            => "0",
        :limitation        => nil,
        :bsv_dossier       => "12495",
      }
      expected_updates.store((ptr + :sl_entry).creator, [data, pac])
      @app.should_receive(:update).and_return do |ptr, data|
        exp, res = expected_updates.delete(ptr)
        res
      end
      swissindex = flexmock('swissindex', :search_item => {:gtin => TestHelpers::LEVETIRACETAM_GTIN})
      server = flexmock('server') do |serv|
        serv.should_receive(:session).and_yield(swissindex)
      end
      replace_constant('ODDB::RefdataPlugin::REFDATA_SERVER', server) do
        @plugin.update_preparations StringIO.new(@src)
      end
      assert_equal({}, @plugin.change_flags)
      listener = @plugin.preparations_listener
      assert_equal [], listener.conflicted_registrations
      expected = [ {
        :name_base          => "Ponstan",
        :name_descr         => "Filmtabs 500 mg ",
        :swissmedic_no5_bag => "39271",
        :deductible         => :deductible_o,
        :generic_type       => :original,
        :swissmedic_no5_oddb=>"39271",
        :swissmedic_no8_bag => "39271063",
      } ]
      assert_equal [], listener.unknown_registrations
      # assert_equal({}, expected_updates)
      assert_equal expected[0], listener.unknown_packages[2]
    end
    def test_update_preparation__conflicted_package
      package = setup_package :pharmacode => "987654",
                              :steps => %w{39271 02 028},
                              :price_public => Util::Money.new(17.65),
                              :price_exfactory => Util::Money.new(11.22)
      reg = setup_registration :iksnr => '39271', :package => package
      reg.should_receive(:packages).and_return []
      reg.should_receive(:keep_generic_type).and_return(false)
      seq = flexmock 'sequence'
      seq.should_receive(:compositions).and_return []
      active_agent = flexmock('active_agent') do |act|
        act.should_receive(:dose).and_return(Quanty.new(500, 'mg'))
        act.should_receive(:same_as?).and_return(true)
      end
      seq.should_receive(:active_agents).and_return([active_agent])
      ptr = Persistence::Pointer.new [:registration, '39271']
      seq.should_receive(:pointer).and_return ptr.clone + [:sequence, '02']
      seq.should_receive(:active_agents).and_return([flexmock('active-agent', {:same_as? => true})])
      seq.should_receive(:bag_compositions).and_return []
      reg.should_receive(:sequences).and_return({'02' => seq})
      package.should_receive(:registration).and_return nil
      @app.should_receive(:package_by_ikskey).and_return nil
      @app.should_receive(:registration).and_return reg
      @app.should_receive(:each_package)
      expected_updates = {}
      expected_updates.store ptr, { :generic_type => :original, :index_therapeuticus => '07.10.10.' }
      expected_updates.store ptr + [:sequence, '02'], { :generic_type => :original, :index_therapeuticus => '07.10.10.' }

      @app.should_receive(:update).and_return do |ptr, data|
        expected_updates.delete(ptr)
        true
      end
      pac_pointer = ptr += [:package, '028']
      swissindex = flexmock('swissindex', :search_item => {:gtin => TestHelpers::LEVETIRACETAM_GTIN})
      server = flexmock('server') do |serv|
        serv.should_receive(:session).and_yield(swissindex)
      end
      skip "Line #{__LINE__}: Don't know how to resolve pac_ptr"
      replace_constant('ODDB::RefdataPlugin::REFDATA_SERVER', server) do
        @plugin.update_preparations StringIO.new(@conflicted_src)
      end
      assert_equal({}, expected_updates)
      assert_equal({}, @plugin.change_flags)
      listener = @plugin.preparations_listener
      expected = [ {
        :name_base          => "Ponstan",
        :name_descr         => "Filmtabs 500 mg ",
        :swissmedic_no5_bag => "12345",
        :generic_type       => :original,
        :deductible         => :deductible_g,
        :swissmedic_no8_bag => "39271028",
        :pharmacode_bag     => "703279",
        :pharmacode_oddb    => "987654",
      } ]
      assert_equal [], listener.unknown_packages
      assert_equal [], listener.unknown_registrations
      assert_equal [], listener.conflicted_registrations
    end
    def test_update_preparation
      reg = setup_registration :iksnr => '39271'
      reg.should_receive(:packages).and_return []
      reg.should_receive(:keep_generic_type).and_return(false)
      package = setup_package :pharmacode => "703279", :registration => reg,
                              :steps => %w{39271 02 028},
                              :price_public => Util::Money.new(17.65),
                              :price_exfactory => Util::Money.new(11.22)
      @app.should_receive(:package_by_ikskey).and_return package
      flexmock(Persistence).should_receive(:find_by_pointer)
      setup_meddata_server
      @app.should_receive(:registration).and_return reg
      @app.should_receive(:each_package)
      @app.should_receive(:delete)
      composition = flexmock 'composition'
      composition.should_receive(:pointer).and_return(Persistence::Pointer.new(:composition))
      @app.should_receive(:create).and_return composition
      substance = flexmock 'substance'
      substance.should_receive(:oid)
      @app.should_receive(:substance).and_return substance
      expected_updates = {}
      ptr = Persistence::Pointer.new [:registration, '39271']
      expected_updates.store ptr, { :generic_type => :original,
                                    :index_therapeuticus => '07.10.10.' }
      ptr += [:sequence, '02']
      expected_updates.store ptr, { :atc_class => 'M01AG01' }
      pac_pointer = ptr += [:package, '028']
      data = {
        :price_exfactory => Util::Money.new(1.82),
        :sl_generic_type => :original,
        :deductible      => :deductible_o,
        :price_public    => Util::Money.new(6.2),
        :narcotic        => false,
      }
      expected_updates.store ptr, data
      ptr += :sl_entry
      data = {
        :bsv_dossier       => "12495",
        :valid_until       => Date.new(9999,12,31),
        :status            => "0",
        :valid_from        => Date.new(1977,3,15),
        :introduction_date => Date.new(1977,3,15),
        :limitation_points => nil,
        :limitation        => nil,
      }
      expected_updates.store ptr.creator, data
      puts "Line #{__LINE__}: Don't know why we should have a price_cut here and were it should come from"
      skip
      @app.should_receive(:update).once.with_any_args.and_return do |ptr, data|
        from_xml = expected_updates.delete(ptr)
        assert_equal  from_xml[:price_public].amount, data[:price_public].amount
        assert_equal  from_xml[:price_exfactory].amount, data[:price_exfactory].amount
        assert_equal  from_xml[:deductible], data[:deductible]
        assert_equal  from_xml[:narcotic], false
        assert_equal  from_xml[:sl_generic_type], :original
      end
      @app.should_receive(:update).with_any_args
      @plugin.update_preparations StringIO.new(@src) # TODO:
      listener = @plugin.preparations_listener
      assert_equal [], listener.conflicted_registrations
      assert_equal [], listener.unknown_packages
      expected = []
      assert_equal [], listener.unknown_registrations
      puts "Line #{__LINE__}: Don't know why we should have a price_cut here and were it should come from"
      skip { assert_equal({pac_pointer => [:price_cut]}, @plugin.change_flags) }
    end
    def setup_package opts={}
      pack = flexmock('package_1', opts)
      atc_class = flexmock('atc_class_1') do |atc_class|
        atc_class.should_receive(:code).and_return('code')
      end
      sequence = flexmock("sequence_#{__LINE__}", opts)
      sequence.should_receive(:odba_store)
      sequence.should_receive(:atc_class).and_return(atc_class)
      sequence.should_receive(:bag_compositions).and_return []
      if steps = opts[:steps]
        iksnr, seqnr, pacnr = steps
        ptr = Persistence::Pointer.new [:registration, iksnr], [:sequence, seqnr]
        sequence.should_receive(:pointer).and_return(ptr)
        pack.should_receive(:pointer).and_return(ptr + [:package, pacnr])
        if reg = opts[:registration]
          reg.should_receive(:sequence).with(seqnr).and_return(sequence)
          reg.should_receive(:package).with(pacnr).and_return(pack)
          sequence.should_receive(:package).with(pacnr).and_return(pack)
        end
      end
      pack.should_receive(:sequence).and_return sequence
      pack.should_ignore_missing
      pack
    end
    def setup_registration opts={}
      ODDB::TestHelpers.vcr_setup
      reg = flexmock("registration_#{__LINE__}", opts)
      ptr = Persistence::Pointer.new([:registration, opts[:iksnr]])
      reg.should_receive(:index_therapeuticus)
      reg.should_receive(:ikscat)
      reg.should_receive(:pointer).and_return ptr
      reg.should_receive(:package).and_return do |ikscd|
        (packs = opts[:packages]) && packs[ikscd]
      end
      reg
    end
    def setup_meddata_server opts={}
      ODDB::TestHelpers.vcr_setup
      server = flexmock(BsvXmlPlugin::PreparationsListener::MEDDATA_SERVER)
      session = flexmock 'session'
      server.should_receive(:session).and_return do |type, block|
        assert_equal :product, type
        block.call session
      end
      session.should_receive(:search).and_return ['meddata-result']
      session.should_receive(:detail).and_return opts
    end

    def setup_read_from_file name, iksnr=nil, seqNr=nil, packNr=nil
      @test_file = File.join(TEST_DATA_DIR, "xml/#{name}.xml")
      assert(File.exist?(@test_file), "File #{@test_file} must exist?")
      @src = File.read(@test_file)
      if iksnr
        @myReg = ODDB::Registration.new(iksnr)
        if seqNr
          @mySeq = @myReg.create_sequence(seqNr)
          @pointer = flexmock("pointer_#{__LINE__}")
          @mySeq.pointer = @pointer
          if packNr
            @pointer.should_receive(:+)
            @pointer.should_receive(:creator)
            @myPackage = @mySeq.create_package(packNr)
          end
        end
      end
      @substance = flexmock("substancer_#{__LINE__}")
      @substance.should_receive(:oid)
      @app.should_receive(:substance).and_return(@substance)
      @agent_pointer = flexmock("@agent_pointer{__LINE__}")
      @composition = flexmock("composition_#{__LINE__}")
      @aPtr = flexmock("a_pointer_#{__LINE__}")
      @aAgent = flexmock("agent_#{__LINE__}")
      @aAgent.should_receive(:creator)
      @aPtr.should_receive(:+).and_return(@aAgent)
      @aPtr.should_receive(:pointer)
      @aPtr.should_receive(:creator).and_return('agent')
      @composition_pointer = flexmock("composition_pointer_#{__LINE__}")
      @composition_pointer.should_receive(:+)
      @composition_pointer.should_receive(:creator).and_return(@agent_pointer)
      @composition_pointer.should_receive(:pointer).and_return(@aPtr)
      @composition.should_receive(:pointer).and_return(@aPtr)
    end

    # This is test where registration, sequence and pack must be created
    def test_nasonex_from_nothing
      setup_read_from_file('nasonex_2024')
      @app.should_receive(:each_package).and_return([])
      @newReg = ODDB::Registration.new(54189)
      @app.should_receive(:registration).and_return(@newReg)
      @newSeq = @newReg.create_sequence('02')
      @pointer = flexmock("pointer_#{__LINE__}")
      @newSeq.pointer = @pointer
      @pointer.should_receive(:+)
      @pointer.should_receive(:creator)
      @newPack = @newSeq.create_package('036')
      @app.should_receive(:package_by_ikskey).and_return(@newPack)
      @app.should_receive(:update).and_return()
      @app.should_receive(:create).with(nil).and_return(@composition)

      @plugin.update_preparations File.open(@test_file)
      seqs = @plugin.preparations_listener.test_sequences
      nasonex = seqs.first.packages.values.first
      assert_equal('18.0', nasonex.price_public.amount.to_s)
      assert_equal('8.5',  nasonex.price_exfactory.amount.to_s)
      assert_equal('2024-01-01 00:00:00 +0000', nasonex.price_exfactory.valid_from.to_s)
      assert_equal('2024-01-01 00:00:00 +0000', nasonex.price_public.valid_from.to_s)
      assert_equal('FREIWILLIGEPS', nasonex.price_public.mutation_code, 'mutation_code for public price')
      assert_equal('FREIWILLIGEPS', nasonex.price_exfactory.mutation_code, 'mutation_code for exfactory price')
      assert_equal(false, nasonex.has_price_history?, 'nasonex may not have a price_history')
      assert_equal(1, nasonex.oid)
    end

    # This is test where an old price must be overwritten
    def test_nasonex_exfactory_price
      setup_read_from_file('nasonex_2024', '54189', '02', '036')
      originUrl22 = "Dummy-31-01-2022.xls"
      @myPackage.price_exfactory = Util::Money.new(10, @price_type, 'CH')
      @myPackage.price_exfactory.valid_from = Time.new(2022,1,31)
      @myPackage.price_exfactory.origin = originUrl22
      @myPackage.price_exfactory.mutation_code = '1JAHRS'
      @myPackage.price_exfactory.type = "exfactory"

      @myPackage.price_exfactory = Util::Money.new(10, @price_type, 'CH')
      @myPackage.price_exfactory.valid_from = Time.new(2022,6,6)
      @myPackage.price_exfactory.origin = "Dummy-06-06-2022.xls"
      @myPackage.price_exfactory.type = "exfactory"

      @myPackage.price_exfactory = Util::Money.new(10, @price_type, 'CH')
      @myPackage.price_exfactory.valid_from = Time.new(2024,1,1)
      @myPackage.price_exfactory.origin = "Dummy-01-01-2024.xls"
      @myPackage.price_exfactory.type = "exfactory"
      @myPackage.deductible = :deductible_o;
      @myPackage.ikscat = 'MustNotBeOverwritten';

      # See https://github.com/zdavatz/oddb.org/issues/240#issuecomment-1932371433
      # we must correct this false price
      @myPackage.price_public = Util::Money.new(18, @price_type, 'CH')
      @myPackage.price_public.valid_from = Time.new(2022,1,1)
      @myPackage.price_public.origin = originUrl22
      @myPackage.price_public.type = "public"

      @myPackage.price_public
      @app.should_receive(:each_package).and_return([@myPackage])
      @app.should_receive(:package_by_ikskey).and_return @myPackage
      @myPackage.pointer= 'pointer'
      @app.should_receive(:registration).and_return @myReg
      @app.should_receive(:update)
      @app.should_receive(:update)
      @app.should_receive(:create).with(nil).and_return(@composition)
      @plugin.update_preparations File.open(@test_file)
      seqs = @plugin.preparations_listener.test_sequences
      nasonex = seqs.first.packages.values.first
      assert_equal(:original, nasonex.sl_generic_type)
      assert_equal(nil, nasonex.bm_flag)
      assert_equal('MustNotBeOverwritten', nasonex.ikscat)
      assert_equal(:deductible_g, nasonex.deductible)
      assert_equal('18.0', nasonex.price_public.amount.to_s)
      assert_equal('8.5',  nasonex.price_exfactory.amount.to_s)
      assert_equal(true, nasonex.has_price_history?, 'nasonex must have a price_history')
      assert_equal('2024-01-01 00:00:00 +0000', nasonex.price_exfactory.valid_from.to_s)
      assert_equal('2024-01-01 00:00:00 +0000', nasonex.price_public.valid_from.to_s)
      assert_equal('FREIWILLIGEPS', nasonex.price_public.mutation_code, 'mutation_code for public price')
      assert_equal('FREIWILLIGEPS', nasonex.price_exfactory.mutation_code, 'mutation_code for exfactory price')
      assert_equal(1, nasonex.oid)
    end

    # This is test where we have a swissmedicn08 shorter than 8 digits
    def test_hepatec
      setup_read_from_file('hepatec', '00488', '01', '001')
      originUrl22 = "Dummy-31-01-2022.xls"
      @myReg.generic_type = :original
      @myReg.index_therapeuticus = "12.02.30."
      @myReg.ikscat = 'B'
      @myPackage.bm_flag = false # narcotic
      @myPackage.deductible = :deductible_g
      @myPackage.prices[:public] = []
      @myPackage.prices[:exfactory ] = []

      @app.should_receive(:each_package).and_return([@myPackage])
      @app.should_receive(:package_by_ikskey).with('00488001').and_return @myPackage
      @myPackage.pointer= 'pointer'
      @app.should_receive(:registration).and_return @myReg
      @app.should_receive(:update).at_least.once
      @app.should_receive(:create).with(nil).and_return(@composition)
      @plugin.update_preparations File.open(@test_file)
      seqs = @plugin.preparations_listener.test_sequences
      hepatec = seqs.first.packages.values.first
      assert_equal('415.25', hepatec.price_public.amount.to_s)
      assert_equal('347.09',  hepatec.price_exfactory.to_s)
      assert_equal(false, hepatec.has_price_history?, 'hepatec may not have a price_history, as price already correct')
      assert_equal('2022-12-01 00:00:00 +0000', hepatec.price_exfactory.valid_from.to_s)
      assert_equal('2024-01-01 00:00:00 +0000', hepatec.price_public.valid_from.to_s)
      assert_equal('MWSTAENDERUNG', hepatec.price_public.mutation_code, 'mutation_code for public price')
      assert_equal('3JUEBERPRUEF', hepatec.price_exfactory.mutation_code, 'mutation_code for exfactory price')
    end

    # This is test where we have an old price and a new one with a different VAT
    def test_amlodipin_with_new_vat
      setup_read_from_file('Amlodipin_MwSt', '66015', '01', '011')
      @myPackage.price_exfactory = Util::Money.new(36.71, @price_type, 'CH')
      @myPackage.price_exfactory.valid_from = Time.new(2020,12,1)
      @myPackage.price_exfactory.origin = "Dummy-01-12-2020.xls"
      @myPackage.price_exfactory.type = "exfactory"
      @myPackage.price_exfactory.mutation_code = "SLAUFNAHME"

      # See https://github.com/zdavatz/oddb.org/issues/240#issuecomment-1932538213
      # we must correct this false price
      @myPackage.price_public = Util::Money.new(58.55, @price_type, 'CH')
      @myPackage.price_public.valid_from = Time.new(2020,12,1)
      @myPackage.price_public.origin = "Dummy-01-12-2020.xls"
      @myPackage.price_public.type = "public"
      @myPackage.price_public.mutation_code = "SLAUFNAHME"

      @myPackage.registration.generic_type = :originalXX
      @app.should_receive(:each_package).and_return([@myPackage])
      @app.should_receive(:package_by_ikskey).and_return @myPackage
      @myPackage.pointer= 'pointer'
      @app.should_receive(:registration).and_return @myReg
      @app.should_receive(:update)
      composition_pointer = flexmock("composition_pointer_#{__LINE__}")
      @pointer.should_receive(:+)
      composition = flexmock("composition_#{__LINE__}")
      composition.should_receive(:pointer).and_return(composition_pointer)
      composition_pointer.should_receive(:+).and_return(@pointer)
      @app.should_receive(:update)
      @app.should_receive(:create).and_return(composition)
      @plugin.update_preparations File.open(@test_file)
      seqs = @plugin.preparations_listener.test_sequences
      amlodipin = seqs.first.packages.values.first
      assert_equal(true, amlodipin.has_price_history?, 'amlodipin must have a price_history')
      assert_equal('58.6', amlodipin.price_public.amount.to_s)
      assert_equal('36.71',  amlodipin.price_exfactory.amount.to_s)
      assert_equal('MWSTAENDERUNG', amlodipin.price_public.mutation_code, 'mutation_code for public price')
      assert_equal('SLAUFNAHME', amlodipin.price_exfactory.mutation_code, 'mutation_code for exfactory price')
      assert_equal('2020-12-01 00:00:00 +0000', amlodipin.price_exfactory.valid_from.to_s)
      assert_equal('2024-01-01 00:00:00 +0000', amlodipin.price_public.valid_from.to_s)
      assert_equal(1, amlodipin.oid)
    end
  end
end

