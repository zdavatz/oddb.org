#!/usr/bin/env ruby
# encoding: utf-8

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'stub/cgi'
require 'stub/odba'
require 'stub/session'
require 'htmlgrid/inputcheckbox'
require 'htmlgrid/pass'
require 'util/today'
require 'view/drugs/fachinfo'
require 'custom/lookandfeelwrapper'

module ODDB
  class Session
    DEFAULT_FLAVOR = 'gcc'
  end
  module State
    class Global < SBSM::State
      attr_accessor :snapback_model
    end
  end
  module View
    class TestFachinfoChangelog <Minitest::Test
      include FlexMock::TestCase
      DEBUG_HTML = false
      def teardown
        ODBA.storage = nil
        super
      end
      def setup
        @context  = flexmock('context', :table => 'table')
        @user  = flexmock('user',
                          :valid? => false,
                          :groups => [],
                          :zones => {},
                          :navigation => {},
                          )
        @zone = flexmock('zone', :zone => 'zone')
        @snapback_model = flexmock('snapback_model', :pointer => 'pointer')
        @state = flexmock('state',
                          :direct_event => 'direct_event',
                          :zone => @zone,
                          :snapback_model => @snapback_model,
                          )
        @app = flexmock('app', StubApp.new)
        @app.unknown_user = @user
        @session = StubSession.new('key', @app)
        @session.lookandfeel = LookandfeelBase.new(@session)
        @session.language = 'de'
        @session.state = @state
        @text_item = FachinfoDocument.new
        @text_item.name = 'name_of_fi'
        @old_string = '1234_old'
        @new_string = 'very_different'
        @text_item.add_change_log_item(@old_string, @new_string, @@two_years_ago)
        old_long = "eins\nzwei\ndrei\nvier\n\nfünf\nsechs\n\sieben\nacht\nNeun\nZehn\n"
        @session.request_path = "de/gcc/show/fachinfo/51193/diff/#{@@one_year_ago.strftime('%d.%m.%Y')}"
        new_long = "eins\nzwei\ndrei\nvier\n\nFünfte Zeile geändert\nZeile eingefügt\nsechs\n\sieben\nacht\nNeun\nZehn\n"
        @text_item.add_change_log_item(old_long, new_long,
                                       @@one_year_ago,
                                       { :context => 3, :include_plus_and_minus_in_html => true})
        @list    = ODDB::View::Drugs::FachinfoDocumentChangelogs.new(@text_item.change_log, @session)
        @reg_nr = '51193'
        text_info = flexmock('text_info', ODDB::FachinfoDocument2001.new, :odba_store => nil)
        fi = flexmock('fachinfo', ODDB::Fachinfo.new, :de => text_info)
        reg = flexmock('registration',
                       ODDB::Registration.new(@reg_nr),
                       :fachinfo => fi,
                       :name_base => 'Gracial')
        @app.registrations = {@reg_nr => reg}
        @app.should_receive(:registration).with(@reg_nr).and_return(reg)
        text_info.add_change_log_item('alt','neu')
        diff_info = [ @session.app.registrations.values.first,
                               @session.app.registrations.values.first.fachinfo.de.change_log,
                               @session.app.registrations.values.first.fachinfo.de.change_log.first,
                            ]
        @session.diff_info = diff_info

        assert_equal(3, @session.choosen_fachinfo_diff.size)
      end
      def test_diff_single_item
        @item   = ODDB::View::Drugs::FachinfoDocumentChangelogItem.new(@text_item.change_log[1], @session)
        @item.init
        assert_match(@reg_nr, @session.choosen_fachinfo_diff[0].iksnr)
        result_single_item = @item.to_html(CGI.new)
        File.open("test_diff_single_item.html", 'w+') {|f| f.write result_single_item.split('<TD').join("\n") }if DEBUG_HTML
        assert_match(@@one_year_ago.strftime('%d.%m.%Y'), result_single_item)
        assert_match(@old_string, result_single_item)
        assert_match(@new_string, result_single_item)
        assert_match('4&nbspÄnderungen an Fachinfo&nbspGracial', result_single_item, 'Must find correct fi heading')
      end

      def test_display_changes_in_item
        @item   = ODDB::View::Drugs::FachinfoDocumentChangelogItem.new(@text_item.change_log[1], @session)
        changelog_request_path = "de/gcc/show/fachinfo/#{@reg_nr}/diff/#{@@two_years_ago.strftime('%d.%m.%Y')}"
        diff_info = [ @session.app.registrations.values.first,]
        @session.diff_info = diff_info
        @session.request_path = changelog_request_path
        assert_equal(1, @session.choosen_fachinfo_diff.size)
        assert_match(@reg_nr, @session.choosen_fachinfo_diff[0].iksnr)
        @list.init
        result_change_item = @item.to_html(CGI.new)
        File.open("test_diff_single_item.html", 'w+') {|f| f.write result_change_item.split('<TD').join("\n") }if DEBUG_HTML
        assert_match(@@two_years_ago.strftime('%d.%m.%Y'), result_change_item)
        assert_match(@old_string, result_change_item)
        assert_match(@new_string, result_change_item)
        assert_match('4&nbspÄnderungen an Fachinfo&nbspGracial', result_change_item, 'Must find correct fi heading')
        skip "Snapback does not yet work correctly"
        assert_match('pointer_descr', result_change_item, 'Must find pointer_descr')
        assert_match('<TD class="th-pointersteps">Änderung zu Fachinfo', result_change_item, 'Must find snapback for Änderung')
        assert_match('<TD class="th-pointersteps">10.11.2015', result_change_item, 'Must find snapback for date')
      end
      def test_show_diff_changelog_with_two_items
        @text_item.add_change_log_item('alt', 'neu',
                                      @@today,
                                      { :context => 3, :include_plus_and_minus_in_html => true})
        changelog_request_path = "de/gcc/show/fachinfo/#{@reg_nr}/diff"
        diff_info = [ @session.app.registrations.values.first,]
        @session.diff_info = diff_info
        @session.request_path = changelog_request_path
        assert_equal(1, @session.choosen_fachinfo_diff.size)
        assert_match(@reg_nr, @session.choosen_fachinfo_diff[0].iksnr)
        @list.init
        result_3_items = @list.to_html(CGI.new)
        File.open("test_diff.html", 'w+') {|f| f.write result_3_items.split('<TD').join("\n") } if DEBUG_HTML
        assert_match(@@two_years_ago.strftime('%d.%m.%Y'), result_3_items, 'Must time of two years old entry')
        assert_match(@@one_year_ago.strftime('%d.%m.%Y'), result_3_items, 'Must find time of one year old entry')
        assert(result_3_items.index(@@two_years_ago.strftime('%d.%m.%Y')) > result_3_items.index(@@one_year_ago.strftime('%d.%m.%Y')), 'Newer entries must come first')
        # Do we have the correct links?
        needed_part = changelog_request_path.sub('de/gcc/', '')
        assert_match(needed_part + '/' + @@two_years_ago.strftime('%d.%m.%Y'), result_3_items, 'Must find link for two years old entry')
        assert_match(needed_part + '/' + @@one_year_ago.strftime('%d.%m.%Y'), result_3_items, 'Must find link for one year old entry')
        assert_match(needed_part + '/' + @@today.strftime('%d.%m.%Y'), result_3_items, 'Must find link for todays entry')
        assert_match('Änderungsdatum', result_3_items, 'Must find Änderungsdatum in header')
        assert_match('Markenname', result_3_items, 'Must find Markenname in header')
        assert_match('Anzahl Änderungen', result_3_items, 'Must find Anzahl Änderungen in header')
        skip "Snapback does not yet work correctly"
        assert_match('pointer_descr', result_3_items, 'Must find pointer_descr')
        assert_match('Liste der Änderungen an der Fachinformation zu Gracial (Swissmedic-Nr. 51193)', result_3_items, 'Must find correct heading')
        assert_match('<TD class="th-pointersteps">Änderung zu Fachinfo', result_3_items, 'Must find snapback for Änderung')
      end
    end
  end
end

