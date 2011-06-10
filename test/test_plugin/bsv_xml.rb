#!/usr/bin/env ruby
# TestBsvXmlPlubin -- oddb.org -- 10.06.2011 -- mhatakeyama@ywesee.com
# TestBsvXmlPlugin -- oddb.org -- 10.11.2008 -- hwyss@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'stub/odba'
require 'plugin/bsv_xml'
require 'flexmock'
require 'util/logfile'
require 'ext/swissindex/src/swissindex'

module ODDB
  class PackageCommon
  end
  class Package < PackageCommon
  end
end

module ODDB
  class TestListener < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      app = flexmock('app')
      @listener = ODDB::BsvXmlPlugin::Listener.new(app)
    end
    def test_date
      expected = Date.new(2011,2,1)
      assert_equal(expected, @listener.date('01.02.2011'))
    end
    def test_date__nil
      assert_equal(nil, @listener.date(''))
    end
    def test_text
      @listener.instance_eval('@html="<html>html</html>"')
      expected = "htmltext\ntext"
      assert_equal(expected, @listener.text('text<br />text'))
    end
    def test_text__nil
      @listener.instance_eval('@html=nil')
      assert_equal(nil, @listener.text('text<br />text'))
    end
    def test_time
      expected = Time.local(2011,2,1)
      assert_equal(expected, @listener.time('01.02.2011'))
    end
    def test_time__nil
      assert_equal(nil, @listener.time(''))
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
      text = [
        '<i>hello</i>',
        '<h>hello</h>'
      ]
      assert_equal('clean!', @listener.update_chapter(chapter, text, 'subheading'))

      # check a local variable
      expected = ["hello", "<", "h>hello", "<", "/h>"]
      assert_equal(expected, paragraph)
    end
  end

  class TestGenericsListener < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @app = flexmock('app')
      @listener = ODDB::BsvXmlPlugin::GenericsListener.new(@app)
    end
    def test_tag_start
      assert_equal('', @listener.tag_start('name', 'attrs'))

      # check instance variables
      assert_equal('', @listener.instance_eval('@text'))
      assert_equal('', @listener.instance_eval('@html'))
    end
    def test_tag_end__GenGroupOrg
      assert_equal([nil], @listener.tag_end('GenGroupOrg'))

      # check an instance variable
      expected = Persistence::Pointer.new [:generic_group, @text]
      assert_equal(expected, @listener.instance_eval('@pointer'))
    end
    def test_tag_end__PharmacodeOrg
      flexstub(Package) do |p|
        p.should_receive(:find_by_pharmacode).and_return('original')
      end
      assert_equal([nil], @listener.tag_end('PharmacodeOrg'))

      # check an instance variable
      assert_equal('original', @listener.instance_eval('@original'))
    end
    def test_tag_end__PharmacodeGen
      flexstub(Package) do |p|
        p.should_receive(:find_by_pharmacode).and_return('generic')
      end
      assert_equal([nil], @listener.tag_end('PharmacodeGen'))

      # check an instance variable
      assert_equal('generic', @listener.instance_eval('@generic'))
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
      assert_equal([nil], @listener.tag_end('OrgGen'))
    end
    def test_tag_end__else
      assert_equal([nil], @listener.tag_end('name'))

      # check instance variables
      assert_equal(nil, @listener.instance_eval('@text'))
      assert_equal(nil, @listener.instance_eval('@html'))
    end
  end
  
  class TestItCodesListener < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
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
      assert_equal([nil], @listener.tag_end('ItCode'))
    end
    def test_tag_end__Limitations
      @listener.instance_eval('@target_data = {}')
      assert_equal([nil], @listener.tag_end('Limitations'))
    end
    def test_tag_end__ValidFromDate
      @listener.instance_eval('@target_data = {}')
      assert_equal([nil], @listener.tag_end('ValidFromDate'))

      # check instance variable
      assert_equal({:valid_from=>nil}, @listener.instance_eval('@target_data'))
    end
    def test_tag_end__Points
      @listener.instance_eval('@target_data = {}')
      assert_equal([nil], @listener.tag_end('Points'))

      # check instance variable
      assert_equal({:limitation_points=>0}, @listener.instance_eval('@target_data'))
    end
    def test_tag_end__else
      assert_equal([nil], @listener.tag_end('name'))

      # check instance variables
      assert_equal(nil, @listener.instance_eval('@text'))
      assert_equal(nil, @listener.instance_eval('@html'))
    end
  end

  class BsvXmlPlugin
  class PreparationsListener < Listener
    MEDDATA_SERVER = self
  end
  end

  class TestPreparationsListener < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
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
      sequence = flexmock('sequence') do |s|
        s.should_receive(:"name_base.downcase").and_return(['name'])
      end
      registration = flexmock('registration') do |r|
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
      assert_equal(nil, @listener.find_typo_registration('', name))
    end
    def test_identify_sequence
      active_agent = flexmock('active_agent') do |act|
        act.should_receive(:same_as?)
      end
      sequence = flexmock('sequence') do |seq|
        seq.should_receive(:active_agents).and_return([active_agent])
      end
      pointer = flexmock('pointer') do |ptr|
        ptr.should_receive(:creator)
      end
      flexmock(pointer) do |ptr|
        ptr.should_receive(:+).and_return(pointer)
      end
      registration = flexmock('registration') do |reg|
        reg.should_receive(:sequences).and_return({'key' => sequence})
        reg.should_receive(:pointer).and_return(pointer)
      end
      flexmock(@app) do |app|
        app.should_receive(:update).and_return(sequence)
      end
      assert_equal(sequence, @listener.identify_sequence(registration, 'name', 'substances'))
    end
    def test_identify_sequence__active_agent_nil
      pointer = flexmock('pointer') do |ptr|
        ptr.should_receive(:creator)
      end
      sequence = flexmock('sequence') do |seq|
        seq.should_receive(:active_agents).and_return([])
        seq.should_receive(:pointer).and_return(pointer)
        seq.should_receive(:oid)
      end
      flexmock(pointer) do |ptr|
        ptr.should_receive(:+).and_return(pointer)
      end
      registration = flexmock('registration') do |reg|
        reg.should_receive(:sequences).and_return({'key' => sequence})
        reg.should_receive(:pointer).and_return(pointer)
      end
      flexmock(@app) do |app|
        app.should_receive(:update).and_return(sequence)
        app.should_receive(:create).and_return(registration)
        app.should_receive(:substance)
      end
      assert_equal(sequence, @listener.identify_sequence(registration, 'name', 'substances'))
    end
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
      swissindex = flexmock('swissindex', :search_item => {:gtin => '1234567890123'})
      server = flexmock('server') do |serv|
        serv.should_receive(:session).and_yield(swissindex)
      end
      replace_constant('ODDB::SwissindexPharmaPlugin::SWISSINDEX_PHARMA_SERVER', server) do 
        assert_equal('56789012', @listener.load_ikskey('pharmacode'))
      end
    end
    def test_load_ikskey__nil
      assert_equal(nil, @listener.load_ikskey(''))
    end
    def test_load_ikskey__error
      swissindex = flexmock('swissindex', :search_item => nil)
      server = flexmock('server') do |serv|
        serv.should_receive(:session).and_yield(swissindex)
      end
      replace_constant('ODDB::SwissindexPharmaPlugin::SWISSINDEX_PHARMA_SERVER', server) do 
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
      @listener.instance_eval('@pcode = ""')
      assert_equal(false, @listener.tag_start('Pack', 'attr'))
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
      assert_raise(StandardError) do 
        @listener.tag_start('Pack', 'attr')
      end
    end
    def test_tag_end__pack
      # Memo
      # This method is too long.
      # It should be divided into small methods 
      sequence = flexmock('sequence') do |seq|
        seq.should_receive(:pointer)
      end
      package = flexmock('package') do |pac|
        pac.should_receive(:price_public).and_return(nil)
        pac.should_receive(:pharmacode).and_return('pharmacode')
        pac.should_receive(:sequence).and_return(sequence)
        pac.should_receive(:price_exfactory).and_return(1)
        pac.should_receive(:ikscat)
        pac.should_receive(:pointer)
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
      assert_equal([nil], @listener.tag_end('Pack'))
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
      assert_equal([nil], @listener.tag_end('Preparation'))
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
      sl_entry = flexmock('sl_entry') do |sle|
        sle.should_receive(:pointer).and_return(sl_ptr)
        sle.should_receive(:limitation_text)
        #sle.should_receive(:limitation_text).and_return('limitation_text')
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
      #sl_entries = {pac_ptr => {}}
      @listener.instance_eval('@sl_entries = sl_entries')
      lim_texts = {pac_ptr => 'lim_data'}
      @listener.instance_eval('@lim_texts = lim_texts')
      flexmock(@app) do |app|
        app.should_receive(:delete)
        app.should_receive(:update)
      end
      assert_equal([nil], @listener.tag_end('Preparation'))
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
      sequence = flexmock('sequence') do |s|
        s.should_receive(:"name_base.downcase").and_return(['name'])
      end
      registration = flexmock('registration') do |r|
        r.should_receive(:"sequences.collect").and_yield('seqnr', sequence)
        r.should_receive(:iksnr).and_return('iksnr')
        r.should_receive(:packages).and_return([])
      end
      flexstub(@app) do |a|
        a.should_receive(:registration).and_return(registration)
      end
      @listener.instance_eval('@name = name')
      assert_equal([nil], @listener.tag_end('SwissmedicNo5'))
    end
    def test_tag_end__swissmedic_no_5__else
      @listener.instance_eval('@report_data = {}')
      visited_iksnrs = {'12345' => ['atc', 'name']}
      @listener.instance_eval('@visited_iksnrs = visited_iksnrs')
      @listener.instance_eval('@text = "12345"')
      @listener.instance_eval('@atc_code = "atc_code"')

      flexmock(@listener) do |lis|
        lis.should_receive(:find_typo_registration)
      end
      assert_equal([nil], @listener.tag_end('SwissmedicNo5'))
    end
    def test_tag_end__swissmedic_no_8
      @listener.instance_eval('@report = {}')
      @listener.instance_eval('@text = ""')
      flexmock(@app) do |app|
        app.should_receive(:registration)
      end
      assert_equal([nil], @listener.tag_end('SwissmedicNo8'))
    end
    def test_tag_end__swissmedic_no_8__out_of_trade
      @listener.instance_eval('@report = {}')
      @listener.instance_eval('@text = ""')
      flexmock(@app) do |app|
        app.should_receive(:registration)
      end
      @listener.instance_eval('@out_of_trade = "out_of_trade"')
      assert_equal([nil], @listener.tag_end('SwissmedicNo8'))
    end
    def test_tag_end__StatusTypeCodeSl__2_6
      @listener.instance_eval('@sl_data = {}')
      @listener.instance_eval('@text = "2"')
      pack = flexmock('package') do |pac|
        pac.should_receive(:sl_entry)
        pac.should_receive(:pointer)
      end
      @listener.instance_eval('@pack = pack')
      assert_equal([nil], @listener.tag_end('StatusTypeCodeSl'))
    end
    def test_tag_end__StatusTypeCodeSl__3_7
      @listener.instance_eval('@sl_data = {}')
      @listener.instance_eval('@text = "3"')
      pack = flexmock('package') do |pac|
        pac.should_receive(:sl_entry).and_return('sl_entry')
        pac.should_receive(:pointer)
      end
      @listener.instance_eval('@pack = pack')
      assert_equal([nil], @listener.tag_end('StatusTypeCodeSl'))
    end
    def test_tag_end__StatusTypeCodeSl__confict
      @listener.instance_eval('@sl_data = {}')
      @listener.instance_eval('@conflict = "conflict"')
      @listener.instance_eval('@out_of_trade = "out_of_trade"')
      assert_equal([nil], @listener.tag_end('StatusTypeCodeSl'))
    end
    def test_tag_end__limitation
      assert_equal([nil], @listener.tag_end('Limitation'))
    end
    def test_tag_end__limitationXXX
      assert_equal([nil], @listener.tag_end('LimitationXXX'))
    end
    def test_tag_end__description
      @listener.instance_eval('@in_limitation = "in_limitation"')
      @listener.instance_eval('@lim_data = {}')
      @listener.instance_eval('@html = []')
      assert_equal([nil], @listener.tag_end('DescriptionXX'))
    end
    def test_tag_end__description_else
      @listener.instance_eval('@in_limitation = "in_limitation"')
      @listener.instance_eval('@html = []')
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
      assert_equal([nil], @listener.tag_end('DescriptionXX'))
    end
    def test_tag_end__description_else_it_descriptions
      @listener.instance_eval('@in_limitation = "in_limitation"')
      @listener.instance_eval('@html = []')
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
      assert_equal([nil], @listener.tag_end('DescriptionXX'))
    end
    def test_tag_end__points
      @listener.instance_eval('@sl_data = {}')
      assert_equal([nil], @listener.tag_end('Points'))
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
      assert_equal([nil], @listener.tag_end('Preparations'))
    end
    def test_tag_end__error
      pointer = flexmock('pointer') do |ptr|
        ptr.should_receive(:+).and_raise(StandardError)
      end
      known_packages = {pointer => 'data'}
      @listener.instance_eval('@known_packages = known_packages')
      assert_raise(StandardError) do 
        @listener.tag_end('Preparations')
      end
    end
  end

  class TestBsvXmlPlugin2 < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
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
      flexstub(Zip::ZipFile) do |z|
        z.should_receive(:foreach).and_yield(entry)
      end
      flexstub(@plugin) do |p|
        p.should_receive(:update_ab_cdef).and_return('update_ab_cdef')
      end
      flexstub(entry) do |e|
        e.should_receive(:get_input_stream).and_return(@plugin.update_ab_cdef)
      end
      assert_equal('update_ab_cdef', @plugin._update('path'))
    end
    def test__update_do_nothing
      entry = flexmock('entry') do |e|
        e.should_receive(:name).and_return('Publications.xls')
      end
      flexstub(Zip::ZipFile) do |z|
        z.should_receive(:foreach).and_yield(entry)
      end
      assert_equal(nil, @plugin._update('path'))
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
        f.should_receive(:exists?).and_return(true)
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
      assert_equal(nil, @plugin.download_file('target_url', 'save_dir', 'file_name'))
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
      assert_raise(EOFError) do 
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
        p.should_receive(:created_sl_entries)
        p.should_receive(:updated_sl_entries)
        p.should_receive(:deleted_sl_entries)
        p.should_receive(:created_limitation_texts)
        p.should_receive(:updated_limitation_texts)
        p.should_receive(:deleted_limitation_texts)
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
        p.should_receive(:created_sl_entries)
        p.should_receive(:updated_sl_entries)
        p.should_receive(:deleted_sl_entries)
        p.should_receive(:created_limitation_texts)
        p.should_receive(:updated_limitation_texts)
        p.should_receive(:deleted_limitation_texts)
        p.should_receive(:duplicate_iksnrs).and_return([])
        p.should_receive(:completed_registrations).and_return([])
        p.should_receive(:conflicted_registrations).and_return([])
        p.should_receive(:conflicted_packages).and_return([])
        p.should_receive(:conflicted_packages_oot).and_return([])
        p.should_receive(:missing_ikscodes).and_return([])
        p.should_receive(:missing_pharmacodes).and_return([])
        p.should_receive(:missing_ikscodes_oot).and_return([])
        p.should_receive(:unknown_packages).and_return([])
        p.should_receive(:unknown_registrations).and_return([])
        p.should_receive(:unknown_packages_oot).and_return(['data'])
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
      # assert_equal('', log_info)
    end
    def test_log_info_bsv
      preparations_listener = flexmock('preparations_listener') do |p|
        p.should_receive(:conflicted_registrations).and_return([])
        p.should_receive(:missing_ikscodes).and_return([])
        p.should_receive(:missing_ikscodes_oot).and_return([])
        p.should_receive(:unknown_packages).and_return([])
        p.should_receive(:unknown_registrations).and_return([])
        p.should_receive(:unknown_packages_oot).and_return(['data'])
        p.should_receive(:missing_pharmacodes).and_return([])
        p.should_receive(:duplicate_iksnrs).and_return([])
      end
      @plugin.instance_eval('@preparations_listener = preparations_listener')
      log_info_bsv = @plugin.log_info_bsv
      expected = ["mail_from", "parts", "recipients", "report"]
      assert_equal(expected, log_info_bsv.keys.map{|k| k.to_s}.sort)
      assert_equal("zdavatz@ywesee.com", log_info_bsv[:mail_from])
      #assert_equal('', log_info_bsv)
    end
    def test_report_bsv
      preparations_listener = flexmock('preparations_listener') do |p|
        p.should_receive(:conflicted_registrations).and_return([])
        p.should_receive(:missing_ikscodes).and_return([])
        p.should_receive(:missing_ikscodes_oot).and_return([])
        p.should_receive(:unknown_packages).and_return([])
        p.should_receive(:unknown_registrations).and_return([])
        p.should_receive(:unknown_packages_oot).and_return(['data'])
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
                 "Pharmacode-bag:      pharmacode_bag\n" +
                 "Pharmacode-oddb:     pharmacode_oddb\n" +
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
      assert_equal('parse_stream', @plugin.update_it_codes('io'))
    end
    def test_update_preparations
      flexmock(REXML::Document) do |xml|
        xml.should_receive(:parse_stream).and_return('parse_stream')
      end
      preparations_listener = flexmock('preparations_listener') do |p|
        p.should_receive(:change_flags).and_return('change_flags')
      end
      flexmock(ODDB::BsvXmlPlugin::PreparationsListener) do |klass|
        klass.should_receive(:new).and_return(preparations_listener)
      end
      assert_equal('change_flags', @plugin.update_preparations('io'))
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
  class TestBsvXmlPlugin < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @url = 'http://bag.e-mediat.net/SL2007.Web.External/File.axd?file=XMLPublications.zip'
      ODDB.config.url_bag_sl_zip = @url
      @archive = File.expand_path '../data', File.dirname(__FILE__)
      @zip = File.join @archive, 'xml', 'XMLPublications.zip'
      @app = flexmock 'app'
      @plugin = BsvXmlPlugin.new @app
      @src = <<-EOS
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<Preparations ReleaseDate="01.11.2008">
  <Preparation ProductCommercial="33">
    <NameDe>Ponstan</NameDe>
    <NameFr>Ponstan</NameFr>
    <NameIt>Ponstan</NameIt>
    <DescriptionDe>Filmtabs 500 mg </DescriptionDe>
    <DescriptionFr>filmtabs 500 mg </DescriptionFr>
    <DescriptionIt>filmtabs 500 mg </DescriptionIt>
    <AtcCode>M01AG01</AtcCode>
    <SwissmedicNo5>39271</SwissmedicNo5>
    <FlagItLimitation>Y</FlagItLimitation>
    <OrgGenCode>O</OrgGenCode>
    <FlagSB20>N</FlagSB20>
    <CommentDe />
    <CommentFr />
    <CommentIt />
    <Packs>
      <Pack Pharmacode="703279" PackId="8853" ProductKey="33">
        <DescriptionDe>12 Stk</DescriptionDe>
        <DescriptionFr>12 pce</DescriptionFr>
        <DescriptionIt>12 pce</DescriptionIt>
        <SwissmedicCategory>B</SwissmedicCategory>
        <SwissmedicNo8>39271028</SwissmedicNo8>
        <FlagNarcosis>N</FlagNarcosis>
        <FlagModal>N</FlagModal>
        <BagDossierNo>12495</BagDossierNo>
        <Limitations />
        <PointLimitations />
        <Prices>
          <ExFactoryPrice>
            <Price>2.9</Price>
            <ValidFromDate>01.08.2006</ValidFromDate>
            <Division />
            <DivisionPriveIncVat />
            <DivisionDescription />
            <PriceTypeCode>PEXF</PriceTypeCode>
            <PriceTypeDescriptionDe>Ex-Factory Preis</PriceTypeDescriptionDe>
            <PriceTypeDescriptionFr>Prix ex-factory</PriceTypeDescriptionFr>
            <PriceTypeDescriptionIt>Prix ex-factory</PriceTypeDescriptionIt>
            <PriceChangeTypeCode>NORMAL</PriceChangeTypeCode>
            <PriceChangeTypeDescriptionDe>Normale Preismutation</PriceChangeTypeDescriptionDe>
            <PriceChangeTypeDescriptionFr>Mutation de prix normale</PriceChangeTypeDescriptionFr>
            <PriceChangeTypeDescriptionIt>Mutation de prix normale</PriceChangeTypeDescriptionIt>
          </ExFactoryPrice>
          <PublicPrice>
            <Price>7.5</Price>
            <ValidFromDate>01.08.2006</ValidFromDate>
            <Division />
            <DivisionPriveIncVat />
            <DivisionDescription />
            <PriceTypeCode>PPUB</PriceTypeCode>
            <PriceTypeDescriptionDe>Publikumspreis</PriceTypeDescriptionDe>
            <PriceTypeDescriptionFr>Prix public</PriceTypeDescriptionFr>
            <PriceTypeDescriptionIt>Prix public</PriceTypeDescriptionIt>
            <PriceChangeTypeCode>NORMAL</PriceChangeTypeCode>
            <PriceChangeTypeDescriptionDe>Normale Preismutation</PriceChangeTypeDescriptionDe>
            <PriceChangeTypeDescriptionFr>Mutation de prix normale</PriceChangeTypeDescriptionFr>
            <PriceChangeTypeDescriptionIt>Mutation de prix normale</PriceChangeTypeDescriptionIt>
          </PublicPrice>
        </Prices>
        <Partners>
          <Partner>
            <PartnerType>V</PartnerType>
            <Description>Pfizer AG</Description>
            <Street>Schärenmoosstrasse 99</Street>
            <ZipCode>8052</ZipCode>
            <Place>Zürich</Place>
            <Phone>043/495 71 11</Phone>
          </Partner>
        </Partners>
        <Status>
          <IntegrationDate>15.03.1977</IntegrationDate>
          <ValidFromDate>15.03.1977</ValidFromDate>
          <ValidThruDate>31.12.9999</ValidThruDate>
          <StatusTypeCodeSl>0</StatusTypeCodeSl>
          <StatusTypeDescriptionSl>Initialzustand</StatusTypeDescriptionSl>
          <FlagApd>N</FlagApd>
        </Status>
      </Pack>
    </Packs>
    <Substances>
      <Substance>
        <DescriptionLa>Acidum mefenamicum</DescriptionLa>
        <Quantity>500</Quantity>
        <QuantityUnit>mg</QuantityUnit>
      </Substance>
    </Substances>
    <Limitations />
    <ItCodes>
      <ItCode Code="07.">
        <DescriptionDe>STOFFWECHSEL</DescriptionDe>
        <DescriptionFr>METABOLISME</DescriptionFr>
        <DescriptionIt>METABOLISME</DescriptionIt>
        <Limitations />
      </ItCode>
      <ItCode Code="07.10.">
        <DescriptionDe>Arthritis und rheumatische Krankheiten</DescriptionDe>
        <DescriptionFr>Arthrites et affections rhumatismales</DescriptionFr>
        <DescriptionIt>Arthrites et affections rhumatismales</DescriptionIt>
        <Limitations />
      </ItCode>
      <ItCode Code="07.10.10.">
        <DescriptionDe>Einfache entzündungshemmende Mittel </DescriptionDe>
        <DescriptionFr>Anti-inflammatoires simples </DescriptionFr>
        <DescriptionIt>Anti-inflammatoires simples </DescriptionIt>
        <Limitations />
      </ItCode>
    </ItCodes>
    <Status>
      <IntegrationDate>15.03.1977</IntegrationDate>
      <ValidFromDate>15.03.1977</ValidFromDate>
      <ValidThruDate>31.12.9999</ValidThruDate>
      <StatusTypeCodeSl>0</StatusTypeCodeSl>
      <StatusTypeDescriptionSl>Initialzustand</StatusTypeDescriptionSl>
      <FlagApd>N</FlagApd>
    </Status>
  </Preparation>
</Preparations>
       EOS
      @conflicted_src = <<-EOS
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<Preparations ReleaseDate="01.11.2008">
  <Preparation ProductCommercial="33">
    <NameDe>Ponstan</NameDe>
    <NameFr>Ponstan</NameFr>
    <NameIt>Ponstan</NameIt>
    <DescriptionDe>Filmtabs 500 mg </DescriptionDe>
    <DescriptionFr>filmtabs 500 mg </DescriptionFr>
    <DescriptionIt>filmtabs 500 mg </DescriptionIt>
    <AtcCode>M01AG01</AtcCode>
    <SwissmedicNo5>12345</SwissmedicNo5>
    <FlagItLimitation>Y</FlagItLimitation>
    <OrgGenCode>O</OrgGenCode>
    <FlagSB20>N</FlagSB20>
    <CommentDe />
    <CommentFr />
    <CommentIt />
    <Packs>
      <Pack Pharmacode="703279" PackId="8853" ProductKey="33">
        <DescriptionDe>12 Stk</DescriptionDe>
        <DescriptionFr>12 pce</DescriptionFr>
        <DescriptionIt>12 pce</DescriptionIt>
        <SwissmedicCategory>B</SwissmedicCategory>
        <SwissmedicNo8>39271028</SwissmedicNo8>
        <FlagNarcosis>N</FlagNarcosis>
        <FlagModal>N</FlagModal>
        <BagDossierNo>12495</BagDossierNo>
        <Limitations />
        <PointLimitations />
        <Prices>
          <ExFactoryPrice>
            <Price>2.9</Price>
            <ValidFromDate>01.08.2006</ValidFromDate>
            <Division />
            <DivisionPriveIncVat />
            <DivisionDescription />
            <PriceTypeCode>PEXF</PriceTypeCode>
            <PriceTypeDescriptionDe>Ex-Factory Preis</PriceTypeDescriptionDe>
            <PriceTypeDescriptionFr>Prix ex-factory</PriceTypeDescriptionFr>
            <PriceTypeDescriptionIt>Prix ex-factory</PriceTypeDescriptionIt>
            <PriceChangeTypeCode>NORMAL</PriceChangeTypeCode>
            <PriceChangeTypeDescriptionDe>Normale Preismutation</PriceChangeTypeDescriptionDe>
            <PriceChangeTypeDescriptionFr>Mutation de prix normale</PriceChangeTypeDescriptionFr>
            <PriceChangeTypeDescriptionIt>Mutation de prix normale</PriceChangeTypeDescriptionIt>
          </ExFactoryPrice>
          <PublicPrice>
            <Price>7.5</Price>
            <ValidFromDate>01.08.2006</ValidFromDate>
            <Division />
            <DivisionPriveIncVat />
            <DivisionDescription />
            <PriceTypeCode>PPUB</PriceTypeCode>
            <PriceTypeDescriptionDe>Publikumspreis</PriceTypeDescriptionDe>
            <PriceTypeDescriptionFr>Prix public</PriceTypeDescriptionFr>
            <PriceTypeDescriptionIt>Prix public</PriceTypeDescriptionIt>
            <PriceChangeTypeCode>NORMAL</PriceChangeTypeCode>
            <PriceChangeTypeDescriptionDe>Normale Preismutation</PriceChangeTypeDescriptionDe>
            <PriceChangeTypeDescriptionFr>Mutation de prix normale</PriceChangeTypeDescriptionFr>
            <PriceChangeTypeDescriptionIt>Mutation de prix normale</PriceChangeTypeDescriptionIt>
          </PublicPrice>
        </Prices>
        <Partners>
          <Partner>
            <PartnerType>V</PartnerType>
            <Description>Pfizer AG</Description>
            <Street>Schärenmoosstrasse 99</Street>
            <ZipCode>8052</ZipCode>
            <Place>Zürich</Place>
            <Phone>043/495 71 11</Phone>
          </Partner>
        </Partners>
        <Status>
          <IntegrationDate>15.03.1977</IntegrationDate>
          <ValidFromDate>15.03.1977</ValidFromDate>
          <ValidThruDate>31.12.9999</ValidThruDate>
          <StatusTypeCodeSl>0</StatusTypeCodeSl>
          <StatusTypeDescriptionSl>Initialzustand</StatusTypeDescriptionSl>
          <FlagApd>N</FlagApd>
        </Status>
      </Pack>
    </Packs>
    <Substances>
      <Substance>
        <DescriptionLa>Acidum mefenamicum</DescriptionLa>
        <Quantity>500</Quantity>
        <QuantityUnit>mg</QuantityUnit>
      </Substance>
    </Substances>
    <Limitations />
    <ItCodes>
      <ItCode Code="07.">
        <DescriptionDe>STOFFWECHSEL</DescriptionDe>
        <DescriptionFr>METABOLISME</DescriptionFr>
        <DescriptionIt>METABOLISME</DescriptionIt>
        <Limitations />
      </ItCode>
      <ItCode Code="07.10.">
        <DescriptionDe>Arthritis und rheumatische Krankheiten</DescriptionDe>
        <DescriptionFr>Arthrites et affections rhumatismales</DescriptionFr>
        <DescriptionIt>Arthrites et affections rhumatismales</DescriptionIt>
        <Limitations />
      </ItCode>
      <ItCode Code="07.10.10.">
        <DescriptionDe>Einfache entzündungshemmende Mittel </DescriptionDe>
        <DescriptionFr>Anti-inflammatoires simples </DescriptionFr>
        <DescriptionIt>Anti-inflammatoires simples </DescriptionIt>
        <Limitations />
      </ItCode>
    </ItCodes>
    <Status>
      <IntegrationDate>15.03.1977</IntegrationDate>
      <ValidFromDate>15.03.1977</ValidFromDate>
      <ValidThruDate>31.12.9999</ValidThruDate>
      <StatusTypeCodeSl>0</StatusTypeCodeSl>
      <StatusTypeDescriptionSl>Initialzustand</StatusTypeDescriptionSl>
      <FlagApd>N</FlagApd>
    </Status>
  </Preparation>
</Preparations>
       EOS
      @lim_txt_src = <<-EOS
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<Preparations ReleaseDate="01.04.2010">
  <Preparation ProductCommercial="1018817">
    <NameDe>Reminyl Prolonged Release</NameDe>
    <NameFr>Reminyl Prolonged Release</NameFr>
    <NameIt>Reminyl Prolonged Release</NameIt>
    <DescriptionDe>Kaps 16 mg </DescriptionDe>
    <DescriptionFr>caps 16 mg </DescriptionFr>
    <DescriptionIt>caps 16 mg </DescriptionIt>
    <AtcCode>N06DA04</AtcCode>
    <SwissmedicNo5>56754</SwissmedicNo5>
    <FlagItLimitation>Y</FlagItLimitation>
    <OrgGenCode />
    <FlagSB20>N</FlagSB20>
    <CommentDe />
    <CommentFr />
    <CommentIt />
    <Packs>
      <Pack Pharmacode="2993471" PackId="14722" ProductKey="1018817">
        <DescriptionDe>28 Stk</DescriptionDe>
        <DescriptionFr>28 pce</DescriptionFr>
        <DescriptionIt>28 pce</DescriptionIt>
        <SwissmedicCategory>B</SwissmedicCategory>
        <SwissmedicNo8>56754007</SwissmedicNo8>
        <FlagNarcosis>N</FlagNarcosis>
        <FlagModal />
        <BagDossierNo>18168</BagDossierNo>
        <Limitations />
        <PointLimitations />
        <Prices>
          <ExFactoryPrice>
            <Price>125.8359</Price>
            <ValidFromDate>01.03.2010</ValidFromDate>
            <Division />
            <DivisionPriveIncVat />
            <DivisionDescription />
            <PriceTypeCode>PEXF</PriceTypeCode>
            <PriceTypeDescriptionDe>Ex-Factory Preis</PriceTypeDescriptionDe>
            <PriceTypeDescriptionFr>Prix ex-factory</PriceTypeDescriptionFr>
            <PriceTypeDescriptionIt>Prix ex-factory</PriceTypeDescriptionIt>
            <PriceChangeTypeCode>AUSLANDPV</PriceChangeTypeCode>
            <PriceChangeTypeDescriptionDe>Auslandspreisvergleich</PriceChangeTypeDescriptionDe>
            <PriceChangeTypeDescriptionFr>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionFr>
            <PriceChangeTypeDescriptionIt>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionIt>
          </ExFactoryPrice>
          <PublicPrice>
            <Price>160.7</Price>
            <ValidFromDate>01.03.2010</ValidFromDate>
            <Division />
            <DivisionPriveIncVat />
            <DivisionDescription />
            <PriceTypeCode>PPUB</PriceTypeCode>
            <PriceTypeDescriptionDe>Publikumspreis</PriceTypeDescriptionDe>
            <PriceTypeDescriptionFr>Prix public</PriceTypeDescriptionFr>
            <PriceTypeDescriptionIt>Prix public</PriceTypeDescriptionIt>
            <PriceChangeTypeCode>AUSLANDPV</PriceChangeTypeCode>
            <PriceChangeTypeDescriptionDe>Auslandspreisvergleich</PriceChangeTypeDescriptionDe>
            <PriceChangeTypeDescriptionFr>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionFr>
            <PriceChangeTypeDescriptionIt>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionIt>
          </PublicPrice>
        </Prices>
        <Partners>
          <Partner>
            <PartnerType>V</PartnerType>
            <Description>Janssen-Cilag AG</Description>
            <Street>Sihlbruggstrasse 111</Street>
            <ZipCode>6341</ZipCode>
            <Place>Baar</Place>
            <Phone>041/767 34 34</Phone>
          </Partner>
        </Partners>
        <Status>
          <IntegrationDate>01.07.2005</IntegrationDate>
          <ValidFromDate>01.07.2005</ValidFromDate>
          <ValidThruDate>31.12.9999</ValidThruDate>
          <StatusTypeCodeSl>0</StatusTypeCodeSl>
          <StatusTypeDescriptionSl>Initialzustand</StatusTypeDescriptionSl>
          <FlagApd>N</FlagApd>
        </Status>
      </Pack>
      <Pack Pharmacode="" PackId="14723" ProductKey="1018817">
        <DescriptionDe>84 Stk</DescriptionDe>
        <DescriptionFr>84 pce</DescriptionFr>
        <DescriptionIt>84 pce</DescriptionIt>
        <SwissmedicCategory>B</SwissmedicCategory>
        <SwissmedicNo8>56754015</SwissmedicNo8>
        <FlagNarcosis>N</FlagNarcosis>
        <FlagModal>Y</FlagModal>
        <BagDossierNo>18168</BagDossierNo>
        <Limitations />
        <PointLimitations />
        <Prices>
          <ExFactoryPrice>
            <Price>377.5076</Price>
            <ValidFromDate>01.03.2010</ValidFromDate>
            <Division />
            <DivisionPriveIncVat />
            <DivisionDescription />
            <PriceTypeCode>PEXF</PriceTypeCode>
            <PriceTypeDescriptionDe>Ex-Factory Preis</PriceTypeDescriptionDe>
            <PriceTypeDescriptionFr>Prix ex-factory</PriceTypeDescriptionFr>
            <PriceTypeDescriptionIt>Prix ex-factory</PriceTypeDescriptionIt>
            <PriceChangeTypeCode>AUSLANDPV</PriceChangeTypeCode>
            <PriceChangeTypeDescriptionDe>Auslandspreisvergleich</PriceChangeTypeDescriptionDe>
            <PriceChangeTypeDescriptionFr>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionFr>
            <PriceChangeTypeDescriptionIt>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionIt>
          </ExFactoryPrice>
          <PublicPrice>
            <Price>449.35</Price>
            <ValidFromDate>01.03.2010</ValidFromDate>
            <Division />
            <DivisionPriveIncVat />
            <DivisionDescription />
            <PriceTypeCode>PPUB</PriceTypeCode>
            <PriceTypeDescriptionDe>Publikumspreis</PriceTypeDescriptionDe>
            <PriceTypeDescriptionFr>Prix public</PriceTypeDescriptionFr>
            <PriceTypeDescriptionIt>Prix public</PriceTypeDescriptionIt>
            <PriceChangeTypeCode>AUSLANDPV</PriceChangeTypeCode>
            <PriceChangeTypeDescriptionDe>Auslandspreisvergleich</PriceChangeTypeDescriptionDe>
            <PriceChangeTypeDescriptionFr>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionFr>
            <PriceChangeTypeDescriptionIt>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionIt>
          </PublicPrice>
        </Prices>
        <Partners>
          <Partner>
            <PartnerType>V</PartnerType>
            <Description>Janssen-Cilag AG</Description>
            <Street>Sihlbruggstrasse 111</Street>
            <ZipCode>6341</ZipCode>
            <Place>Baar</Place>
            <Phone>041/767 34 34</Phone>
          </Partner>
        </Partners>
        <Status>
          <IntegrationDate>01.01.2010</IntegrationDate>
          <ValidFromDate>01.01.2010</ValidFromDate>
          <ValidThruDate>31.12.9999</ValidThruDate>
          <StatusTypeCodeSl>0</StatusTypeCodeSl>
          <StatusTypeDescriptionSl>Initialzustand</StatusTypeDescriptionSl>
          <FlagApd>N</FlagApd>
        </Status>
      </Pack>
    </Packs>
    <Substances>
      <Substance>
        <DescriptionLa>Galantamini hydrobromidum</DescriptionLa>
        <Quantity />
        <QuantityUnit />
      </Substance>
    </Substances>
    <Limitations>
      <Limitation>
        <LimitationCode>THERAPIEBEG</LimitationCode>
        <LimitationType>KOM</LimitationType>
        <LimitationNiveau>IP</LimitationNiveau>
        <LimitationValue />
        <DescriptionDe>Zu Therapiebeginn Durchführung z.B. eines Minimentaltests.&lt;br&gt;
Erste Zwischenevaluation nach 3 Monaten, dann alle 6 Monate.&lt;br&gt;
Falls die MMSE1)-Werte unter 10 liegen, ist die Behandlung abzubrechen.&lt;br&gt;
Die Therapie kann nur mit einem Präparat durchgeführt werden.&lt;br&gt;

1) mini mental status examination</DescriptionDe>
        <DescriptionFr>En début de thérapie, application par ex. d'un test minimental.&lt;br&gt;
Première évaluation intermédiaire après trois mois et ensuite tous les six mois.&lt;br&gt;
Si les valeurs MMSE1) sont inférieures à 10, il y a lieu d'interrompre la prise du médicament.&lt;br&gt;
La thérapie ne peut être appliquée qu'avec une préparation.&lt;br&gt;

1) mini mental status examination</DescriptionFr>
        <DescriptionIt>All'inizio della terapia si esegue ad es. un test minimentale.&lt;br&gt;
Prima valutazione intermedia dopo 3 mesi, poi ogni 6 mesi.&lt;br&gt;
Se i valori MMSE1) sono inferiori a 10 bisogna cessare la terapia.&lt;br&gt;
La terapia può essere effettuata soltanto con un preparato.&lt;br&gt;

1) mini mental status examination</DescriptionIt>
        <ValidFromDate>01.01.2007</ValidFromDate>
        <ValidThruDate>31.12.9999</ValidThruDate>
      </Limitation>
    </Limitations>
    <ItCodes>
      <ItCode Code="01.">
        <DescriptionDe>NERVENSYSTEM</DescriptionDe>
        <DescriptionFr>SYSTEME NERVEUX</DescriptionFr>
        <DescriptionIt>SYSTEME NERVEUX</DescriptionIt>
        <Limitations />
      </ItCode>
      <ItCode Code="01.99.">
        <DescriptionDe>Varia</DescriptionDe>
        <DescriptionFr>Varia</DescriptionFr>
        <DescriptionIt>Varia</DescriptionIt>
        <Limitations />
      </ItCode>
    </ItCodes>
    <Status>
      <IntegrationDate>01.07.2005</IntegrationDate>
      <ValidFromDate>01.07.2005</ValidFromDate>
      <ValidThruDate>31.12.9999</ValidThruDate>
      <StatusTypeCodeSl>0</StatusTypeCodeSl>
      <StatusTypeDescriptionSl>Initialzustand</StatusTypeDescriptionSl>
      <FlagApd>N</FlagApd>
    </Status>
  </Preparation>
  <Preparation ProductCommercial="1018818">
    <NameDe>Reminyl Prolonged Release</NameDe>
    <NameFr>Reminyl Prolonged Release</NameFr>
    <NameIt>Reminyl Prolonged Release</NameIt>
    <DescriptionDe>Kaps 24 mg </DescriptionDe>
    <DescriptionFr>caps 24 mg </DescriptionFr>
    <DescriptionIt>caps 24 mg </DescriptionIt>
    <AtcCode>N06DA04</AtcCode>
    <SwissmedicNo5>56754</SwissmedicNo5>
    <FlagItLimitation>Y</FlagItLimitation>
    <OrgGenCode />
    <FlagSB20>N</FlagSB20>
    <CommentDe />
    <CommentFr />
    <CommentIt />
    <Packs>
      <Pack Pharmacode="2993488" PackId="14724" ProductKey="1018818">
        <DescriptionDe>28 Stk</DescriptionDe>
        <DescriptionFr>28 pce</DescriptionFr>
        <DescriptionIt>28 pce</DescriptionIt>
        <SwissmedicCategory>B</SwissmedicCategory>
        <SwissmedicNo8>56754019</SwissmedicNo8>
        <FlagNarcosis>N</FlagNarcosis>
        <FlagModal />
        <BagDossierNo>18168</BagDossierNo>
        <Limitations />
        <PointLimitations />
        <Prices>
          <ExFactoryPrice>
            <Price>125.8359</Price>
            <ValidFromDate>01.03.2010</ValidFromDate>
            <Division />
            <DivisionPriveIncVat />
            <DivisionDescription />
            <PriceTypeCode>PEXF</PriceTypeCode>
            <PriceTypeDescriptionDe>Ex-Factory Preis</PriceTypeDescriptionDe>
            <PriceTypeDescriptionFr>Prix ex-factory</PriceTypeDescriptionFr>
            <PriceTypeDescriptionIt>Prix ex-factory</PriceTypeDescriptionIt>
            <PriceChangeTypeCode>AUSLANDPV</PriceChangeTypeCode>
            <PriceChangeTypeDescriptionDe>Auslandspreisvergleich</PriceChangeTypeDescriptionDe>
            <PriceChangeTypeDescriptionFr>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionFr>
            <PriceChangeTypeDescriptionIt>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionIt>
          </ExFactoryPrice>
          <PublicPrice>
            <Price>160.7</Price>
            <ValidFromDate>01.03.2010</ValidFromDate>
            <Division />
            <DivisionPriveIncVat />
            <DivisionDescription />
            <PriceTypeCode>PPUB</PriceTypeCode>
            <PriceTypeDescriptionDe>Publikumspreis</PriceTypeDescriptionDe>
            <PriceTypeDescriptionFr>Prix public</PriceTypeDescriptionFr>
            <PriceTypeDescriptionIt>Prix public</PriceTypeDescriptionIt>
            <PriceChangeTypeCode>AUSLANDPV</PriceChangeTypeCode>
            <PriceChangeTypeDescriptionDe>Auslandspreisvergleich</PriceChangeTypeDescriptionDe>
            <PriceChangeTypeDescriptionFr>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionFr>
            <PriceChangeTypeDescriptionIt>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionIt>
          </PublicPrice>
        </Prices>
        <Partners>
          <Partner>
            <PartnerType>V</PartnerType>
            <Description>Janssen-Cilag AG</Description>
            <Street>Sihlbruggstrasse 111</Street>
            <ZipCode>6341</ZipCode>
            <Place>Baar</Place>
            <Phone>041/767 34 34</Phone>
          </Partner>
        </Partners>
        <Status>
          <IntegrationDate>01.07.2005</IntegrationDate>
          <ValidFromDate>01.07.2005</ValidFromDate>
          <ValidThruDate>31.12.9999</ValidThruDate>
          <StatusTypeCodeSl>0</StatusTypeCodeSl>
          <StatusTypeDescriptionSl>Initialzustand</StatusTypeDescriptionSl>
          <FlagApd>N</FlagApd>
        </Status>
      </Pack>
      <Pack Pharmacode="" PackId="14725" ProductKey="1018818">
        <DescriptionDe>84 Stk</DescriptionDe>
        <DescriptionFr>84 pce</DescriptionFr>
        <DescriptionIt>84 pce</DescriptionIt>
        <SwissmedicCategory>B</SwissmedicCategory>
        <SwissmedicNo8>56754029</SwissmedicNo8>
        <FlagNarcosis>N</FlagNarcosis>
        <FlagModal>Y</FlagModal>
        <BagDossierNo>18168</BagDossierNo>
        <Limitations />
        <PointLimitations />
        <Prices>
          <ExFactoryPrice>
            <Price>377.5076</Price>
            <ValidFromDate>01.03.2010</ValidFromDate>
            <Division />
            <DivisionPriveIncVat />
            <DivisionDescription />
            <PriceTypeCode>PEXF</PriceTypeCode>
            <PriceTypeDescriptionDe>Ex-Factory Preis</PriceTypeDescriptionDe>
            <PriceTypeDescriptionFr>Prix ex-factory</PriceTypeDescriptionFr>
            <PriceTypeDescriptionIt>Prix ex-factory</PriceTypeDescriptionIt>
            <PriceChangeTypeCode>AUSLANDPV</PriceChangeTypeCode>
            <PriceChangeTypeDescriptionDe>Auslandspreisvergleich</PriceChangeTypeDescriptionDe>
            <PriceChangeTypeDescriptionFr>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionFr>
            <PriceChangeTypeDescriptionIt>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionIt>
          </ExFactoryPrice>
          <PublicPrice>
            <Price>449.35</Price>
            <ValidFromDate>01.03.2010</ValidFromDate>
            <Division />
            <DivisionPriveIncVat />
            <DivisionDescription />
            <PriceTypeCode>PPUB</PriceTypeCode>
            <PriceTypeDescriptionDe>Publikumspreis</PriceTypeDescriptionDe>
            <PriceTypeDescriptionFr>Prix public</PriceTypeDescriptionFr>
            <PriceTypeDescriptionIt>Prix public</PriceTypeDescriptionIt>
            <PriceChangeTypeCode>AUSLANDPV</PriceChangeTypeCode>
            <PriceChangeTypeDescriptionDe>Auslandspreisvergleich</PriceChangeTypeDescriptionDe>
            <PriceChangeTypeDescriptionFr>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionFr>
            <PriceChangeTypeDescriptionIt>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionIt>
          </PublicPrice>
        </Prices>
        <Partners>
          <Partner>
            <PartnerType>V</PartnerType>
            <Description>Janssen-Cilag AG</Description>
            <Street>Sihlbruggstrasse 111</Street>
            <ZipCode>6341</ZipCode>
            <Place>Baar</Place>
            <Phone>041/767 34 34</Phone>
          </Partner>
        </Partners>
        <Status>
          <IntegrationDate>01.01.2010</IntegrationDate>
          <ValidFromDate>01.01.2010</ValidFromDate>
          <ValidThruDate>31.12.9999</ValidThruDate>
          <StatusTypeCodeSl>0</StatusTypeCodeSl>
          <StatusTypeDescriptionSl>Initialzustand</StatusTypeDescriptionSl>
          <FlagApd>N</FlagApd>
        </Status>
      </Pack>
    </Packs>
    <Substances>
      <Substance>
        <DescriptionLa>Galantamini hydrobromidum</DescriptionLa>
        <Quantity />
        <QuantityUnit />
      </Substance>
    </Substances>
    <Limitations>
      <Limitation>
        <LimitationCode>THERAPIEBEG</LimitationCode>
        <LimitationType>KOM</LimitationType>
        <LimitationNiveau>IP</LimitationNiveau>
        <LimitationValue />
        <DescriptionDe>Zu Therapiebeginn Durchführung z.B. eines Minimentaltests.&lt;br&gt;
Erste Zwischenevaluation nach 3 Monaten, dann alle 6 Monate.&lt;br&gt;
Falls die MMSE1)-Werte unter 10 liegen, ist die Behandlung abzubrechen.&lt;br&gt;
Die Therapie kann nur mit einem Präparat durchgeführt werden.&lt;br&gt;

1) mini mental status examination</DescriptionDe>
        <DescriptionFr>En début de thérapie, application par ex. d'un test minimental.&lt;br&gt;
Première évaluation intermédiaire après trois mois et ensuite tous les six mois.&lt;br&gt;
Si les valeurs MMSE1) sont inférieures à 10, il y a lieu d'interrompre la prise du médicament.&lt;br&gt;
La thérapie ne peut être appliquée qu'avec une préparation.&lt;br&gt;

1) mini mental status examination</DescriptionFr>
        <DescriptionIt>All'inizio della terapia si esegue ad es. un test minimentale.&lt;br&gt;
Prima valutazione intermedia dopo 3 mesi, poi ogni 6 mesi.&lt;br&gt;
Se i valori MMSE1) sono inferiori a 10 bisogna cessare la terapia.&lt;br&gt;
La terapia può essere effettuata soltanto con un preparato.&lt;br&gt;

1) mini mental status examination</DescriptionIt>
        <ValidFromDate>01.01.2007</ValidFromDate>
        <ValidThruDate>31.12.9999</ValidThruDate>
      </Limitation>
    </Limitations>
    <ItCodes>
      <ItCode Code="01.">
        <DescriptionDe>NERVENSYSTEM</DescriptionDe>
        <DescriptionFr>SYSTEME NERVEUX</DescriptionFr>
        <DescriptionIt>SYSTEME NERVEUX</DescriptionIt>
        <Limitations />
      </ItCode>
      <ItCode Code="01.99.">
        <DescriptionDe>Varia</DescriptionDe>
        <DescriptionFr>Varia</DescriptionFr>
        <DescriptionIt>Varia</DescriptionIt>
        <Limitations />
      </ItCode>
    </ItCodes>
    <Status>
      <IntegrationDate>01.07.2005</IntegrationDate>
      <ValidFromDate>01.07.2005</ValidFromDate>
      <ValidThruDate>31.12.9999</ValidThruDate>
      <StatusTypeCodeSl>0</StatusTypeCodeSl>
      <StatusTypeDescriptionSl>Initialzustand</StatusTypeDescriptionSl>
      <FlagApd>N</FlagApd>
    </Status>
  </Preparation>
</Preparations>
      EOS
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
      assert_nothing_raised do
        result = @plugin.download_file(target_url, save_dir, file_name)
      end
      assert_equal save_file, result

      # Not-downloading tests
      assert_nothing_raised do
        result = @plugin.download_file(target_url, save_dir, file_name)
      end
      assert_equal nil, result

      # Check files
      assert File.exist?(save_file), "download to #{save_file} failed."
      assert File.exist?(latest_file), "download to #{latest_file} failed."
    ensure
      FileUtils.rm_r save_dir if File.exists? save_dir
    end
    def test_update_it_codes
      updates = []
      @app.should_receive(:update).times(38).and_return do |ptr, data|
        updates.push data
      end
      zip = Zip::ZipFile.open(@zip)
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
    def test_update_preparation__unknown_registration__out_of_trade
      updates = []
      flexmock(Package).should_receive(:find_by_pharmacode).
                        times(1).and_return nil
      @app.should_receive(:registration).and_return nil
      @app.should_receive(:each_package)
      swissindex = flexmock('swissindex', :search_item => {:gtin => '1234567890123'})
      server = flexmock('server') do |serv|
        serv.should_receive(:session).and_yield(swissindex)
      end
      replace_constant('ODDB::SwissindexPharmaPlugin::SWISSINDEX_PHARMA_SERVER', server) do 
        @plugin.update_preparations StringIO.new(@src)
      end
      assert_equal [], updates
      assert_equal({}, @plugin.change_flags)
      listener = @plugin.preparations_listener
      assert_equal [], listener.conflicted_packages
      assert_equal [], listener.conflicted_registrations
      assert_equal [], listener.unknown_packages
      expected = [{:name_descr => "Filmtabs 500 mg ", :swissmedic_no5_bag => "39271", :name_base => "Ponstan"}]
      assert_equal expected, listener.unknown_registrations
    end
    def test_update_preparation__unknown_registration
      updates = []
      flexmock(Package).should_receive(:find_by_pharmacode).
                        times(1).and_return nil
      @app.should_receive(:registration).and_return nil
      @app.should_receive(:each_package)
      swissindex = flexmock('swissindex', :search_item => {:gtin => '1234567890123'})
      server = flexmock('server') do |serv|
        serv.should_receive(:session).and_yield(swissindex)
      end
      replace_constant('ODDB::SwissindexPharmaPlugin::SWISSINDEX_PHARMA_SERVER', server) do 
        @plugin.update_preparations StringIO.new(@src)
      end
      assert_equal [], updates
      assert_equal({}, @plugin.change_flags)
      listener = @plugin.preparations_listener
      assert_equal [], listener.conflicted_packages
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
                              :price_exfactory => Util::Money.new(11.22)
      flexmock(Package).should_receive(:find_by_pharmacode).
                        times(1).and_return package
      flexmock(Persistence).should_receive(:find_by_pointer)
      reg.should_receive(:packages).and_return []
      setup_meddata_server
      @app.should_receive(:registration).and_return reg
      @app.should_receive(:each_package)
      @app.should_receive(:delete)
      expected_updates = {}
      ptr = Persistence::Pointer.new [:registration, '39271']
      expected_updates.store ptr, { :generic_type => :original,
                                    :index_therapeuticus => '07.10.10.' }
      ptr += [:sequence, '02']
      expected_updates.store ptr, { :atc_class => 'M01AG01' }
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
        :pharmacode      => '703279',
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
      @app.should_receive(:update).and_return do |ptr, data|
        assert_equal expected_updates.delete(ptr), data, ptr.to_s
      end
      @plugin.update_preparations StringIO.new(@conflicted_src)
      assert_equal({}, expected_updates)
      assert_equal({pac_pointer => [:price_cut]}, @plugin.change_flags)
      listener = @plugin.preparations_listener
      assert_equal [], listener.conflicted_packages
      expected = [ {
        :name_base          => "Ponstan",
        :name_descr         => "Filmtabs 500 mg ",
        :swissmedic_no5_oddb=> "39271",
        :swissmedic_no5_bag => "12345",
        :swissmedic_no8_bag => "39271028",
        :pharmacode_bag     => "703279",
        :pharmacode_oddb    => "703279",
        :generic_type       => :original,
        :deductible         => :deductible_g,
        :atc_class          => "M01AG01",
      } ]
      assert_equal expected, listener.conflicted_registrations
      assert_equal [], listener.unknown_packages
      expected = []
      assert_equal [], listener.unknown_registrations
    end
    def test_update_preparation__unknown_package__out_of_trade
      reg = setup_registration :iksnr => '39271'
      seq = flexmock 'sequence'
      reg.should_receive(:packages).and_return []
      reg.should_receive(:sequences).and_return({})
      flexmock(Package).should_receive(:find_by_pharmacode).
                        times(1).and_return nil
      #setup_meddata_server
      @app.should_receive(:registration).and_return reg
      @app.should_receive(:each_package)
      expected_updates = {}
      ptr = Persistence::Pointer.new [:registration, '39271']
      expected_updates.store ptr, { :generic_type => :original,
                                    :index_therapeuticus => '07.10.10.' }
      @app.should_receive(:update).times(1).and_return do |ptr, data|
        assert_equal expected_updates.delete(ptr), data
      end
      swissindex = flexmock('swissindex', :search_item => nil)
      server = flexmock('server') do |serv|
        serv.should_receive(:session).and_yield(swissindex)
      end
      replace_constant('ODDB::SwissindexPharmaPlugin::SWISSINDEX_PHARMA_SERVER', server) do 
        @plugin.update_preparations StringIO.new(@conflicted_src)
      end
      assert_equal({}, expected_updates)
      assert_equal({}, @plugin.change_flags)
      listener = @plugin.preparations_listener
      assert_equal [], listener.conflicted_packages
      assert_equal [], listener.conflicted_registrations
      assert_equal [], listener.unknown_packages
      expected = []
      assert_equal [], listener.unknown_registrations
    end
    def test_update_preparation__unknown_package
      reg = setup_registration :iksnr => '39271'
      reg.should_receive(:packages).and_return []
      reg.should_receive(:sequences).and_return({})
      flexmock(Package).should_receive(:find_by_pharmacode).
                        times(1).and_return nil
      @app.should_receive(:registration).and_return reg
      @app.should_receive(:each_package)
      expected_updates = {}
      ptr = Persistence::Pointer.new [:registration, '39271']
      expected_updates.store ptr, [{ :generic_type => :original,
                                    :index_therapeuticus => '07.10.10.' }, reg]
      ptr += [:sequence, '01']
      expected_updates.store ptr, [{ :atc_class => 'M01AG01' }, reg]
      seq = flexmock 'sequence'
      seq.should_receive(:compositions).and_return []
      seq.should_receive(:pointer).and_return ptr
      seq.should_receive(:active_agents).and_return([flexmock('active-agent')])
      reg.should_receive(:sequence).and_return(seq)
      expected_updates.store ptr.creator, [{:name_base=>"Ponstan"}, seq]
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
      @app.should_receive(:update).times(6).and_return do |ptr, data|
        exp, res = expected_updates.delete(ptr)
        assert_equal exp, data
        res
      end
      swissindex = flexmock('swissindex', :search_item => {:gtin => '1234567890123'})
      server = flexmock('server') do |serv|
        serv.should_receive(:session).and_yield(swissindex)
      end
      replace_constant('ODDB::SwissindexPharmaPlugin::SWISSINDEX_PHARMA_SERVER', server) do 
        @plugin.update_preparations StringIO.new(@src)
      end
      assert_equal({}, expected_updates)
      assert_equal({}, @plugin.change_flags)
      listener = @plugin.preparations_listener
      assert_equal [], listener.conflicted_packages
      assert_equal [], listener.conflicted_registrations
      expected = [ {
        :name_base          => "Ponstan",
        :name_descr         => "Filmtabs 500 mg ",
        :swissmedic_no5_bag => "39271",
        :swissmedic_no8_bag => "39271028",
        :pharmacode_bag     => "703279",
        :generic_type       => :original,
        :deductible         => :deductible_g,
        :atc_class          => "M01AG01",
      } ]
      assert_equal expected, listener.unknown_packages
      expected = []
      assert_equal [], listener.unknown_registrations
    end
    def test_update_preparation__conflicted_package
      package = setup_package :pharmacode => "987654",
                              :steps => %w{39271 02 028}, 
                              :price_public => Util::Money.new(17.65), 
                              :price_exfactory => Util::Money.new(11.22)
      reg = setup_registration :iksnr => '39271', :package => package
      reg.should_receive(:packages).and_return []
      package.should_receive(:registration).and_return reg
      flexmock(Package).should_receive(:find_by_pharmacode).
                        times(1).and_return nil
      @app.should_receive(:registration).and_return reg
      @app.should_receive(:each_package)
      expected_updates = {}
      ptr = Persistence::Pointer.new [:registration, '39271']
      expected_updates.store ptr, { :generic_type => :original,
                                    :index_therapeuticus => '07.10.10.' }
      ptr += [:sequence, '02']
      pac_pointer = ptr += [:package, '028']
      @app.should_receive(:update).and_return do |ptr, data|
        assert_equal expected_updates.delete(ptr), data
      end
      swissindex = flexmock('swissindex', :search_item => {:gtin => '1234567890123'})
      server = flexmock('server') do |serv|
        serv.should_receive(:session).and_yield(swissindex)
      end
      replace_constant('ODDB::SwissindexPharmaPlugin::SWISSINDEX_PHARMA_SERVER', server) do 
        @plugin.update_preparations StringIO.new(@conflicted_src)
      end
      assert_equal({}, expected_updates)
      assert_equal({}, @plugin.change_flags)
      listener = @plugin.preparations_listener
      expected = [ {
        :name_base          => "Ponstan",
        :name_descr         => "Filmtabs 500 mg ",
        :swissmedic_no5_bag => "12345",
        :swissmedic_no8_bag => "39271028",
        :pharmacode_bag     => "703279",
        :pharmacode_oddb    => "987654",
        :generic_type       => :original,
        :deductible         => :deductible_g,
        :atc_class          => "M01AG01",
      } ]
      assert_equal expected, listener.conflicted_packages
      assert_equal [], listener.conflicted_registrations
      assert_equal [], listener.unknown_packages
      expected = []
      assert_equal [], listener.unknown_registrations
    end
    def test_update_preparation
      reg = setup_registration :iksnr => '39271'
      reg.should_receive(:packages).and_return []
      package = setup_package :pharmacode => "703279", :registration => reg, 
                              :steps => %w{39271 02 028}, 
                              :price_public => Util::Money.new(17.65), 
                              :price_exfactory => Util::Money.new(11.22)
      flexmock(Package).should_receive(:find_by_pharmacode).
                        times(1).and_return package
      flexmock(Persistence).should_receive(:find_by_pointer)
      setup_meddata_server
      @app.should_receive(:registration).and_return reg
      @app.should_receive(:each_package)
      @app.should_receive(:delete)
      expected_updates = {}
      ptr = Persistence::Pointer.new [:registration, '39271']
      expected_updates.store ptr, { :generic_type => :original,
                                    :index_therapeuticus => '07.10.10.' }
      ptr += [:sequence, '02']
      expected_updates.store ptr, { :atc_class => 'M01AG01' }
      pac_pointer = ptr += [:package, '028']
      data = { 
        :price_exfactory => Util::Money.new(2.9),
        :sl_generic_type => :original,
        :deductible      => :deductible_g,
        :price_public    => Util::Money.new(7.5),
        :narcotic        => false,
        :pharmacode      => '703279',
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
      @app.should_receive(:update).and_return do |ptr, data|
        assert_equal expected_updates.delete(ptr), data
      end
      @plugin.update_preparations StringIO.new(@src)
      assert_equal({}, expected_updates)
      assert_equal({pac_pointer => [:price_cut]}, @plugin.change_flags)
      listener = @plugin.preparations_listener
      assert_equal [], listener.conflicted_packages
      assert_equal [], listener.conflicted_registrations
      assert_equal [], listener.unknown_packages
      expected = []
      assert_equal [], listener.unknown_registrations
    end
    def setup_package opts={}
      pack = flexmock opts
      sequence = flexmock opts
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
      reg = flexmock opts
      ptr = Persistence::Pointer.new([:registration, opts[:iksnr]])
      reg.should_receive(:pointer).and_return ptr
      reg.should_receive(:package).and_return do |ikscd|
        (packs = opts[:packages]) && packs[ikscd]
      end
      reg
    end
    def setup_meddata_server opts={}
      server = flexmock(BsvXmlPlugin::PreparationsListener::MEDDATA_SERVER)
      session = flexmock 'session'
      server.should_receive(:session).and_return do |type, block|
        assert_equal :product, type
        block.call session
      end
      session.should_receive(:search).and_return ['meddata-result']
      session.should_receive(:detail).and_return opts
    end
  end
end

