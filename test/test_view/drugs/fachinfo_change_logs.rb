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
        @state = flexmock('state',
                          :direct_event => 'direct_event',
                          :zone => @zone,
                          )
        @app = flexmock('app', StubApp.new)
        @app.unknown_user = @user
        @session = StubSession.new('key', @app)
        @session.lookandfeel = LookandfeelBase.new(@session)
        @session.language = 'de'
        @text_item = FachinfoDocument.new
        @text_item.name = 'name_of_fi'
        @text_item.add_change_log_item("Old_first_Text", "new_text", @@two_years_ago)
        old_long = "eins\nzwei\ndrei\nvier\n\nfünf\nsechs\n\sieben\nacht\nNeun\nZehn\n"
        @session.request_path = "de/gcc/show/fachinfo/51193/diff/#{@@one_year_ago.to_s}"
        new_long = "eins\nzwei\ndrei\nvier\n\nFünfte Zeile geändert\nZeile eingefügt\nsechs\n\sieben\nacht\nNeun\nZehn\n"
#        registration('51193').fachinfo.de.add_change_log_item($old_long, $new_long, { :context => 3, :include_plus_and_minus_in_html => true})
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
                       :name_base => 'name_base')
        @app.registrations = {@reg_nr => reg}
        @app.should_receive(:registration).with(@reg_nr).and_return(reg)
        text_info.add_change_log_item('alt','neu')
        diff_info = [ @session.app.registrations.values.first,
                               @session.app.registrations.values.first.fachinfo.de.change_log,
                               @session.app.registrations.values.first.fachinfo.de.change_log.first,
                            ]
        @session.diff_info = diff_info

        assert_equal(3, @session.choosen_fachinfo_diff.size)
        @result = @list.to_html(CGI.new)

      end
      def test_time
        assert_kind_of(String, @result)
        assert_match(@@one_year_ago.to_s, @result)
        assert_match(@@two_years_ago.to_s, @result)
        assert_nil(/#{@@today}/.match(@result))
      end
      def test_diff_single_item
        @item   = ODDB::View::Drugs::FachinfoDocumentChangelogItem.new(@text_item.change_log[1], @session)
        @item.init
        result = @item.to_html(CGI.new)
        # puts @result.split('<TD').join("\n")
        File.open("test_diff_single_item.html", 'w+') {|f| f.write @result.split('<TD').join("\n") } if DEBUG_HTML
        assert_match(@@two_years_ago.to_s, result)
        assert_match('Old_first_Text', result)
        assert_match('new_text', result)
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
        @result = @list.to_html(CGI.new)
        File.open("test_diff.html", 'w+') {|f| f.write @result.split('<TD').join("\n") } if DEBUG_HTML
        assert_match(@@two_years_ago.to_s, @result)
        assert_match(@@one_year_ago.to_s, @result)
        assert_match(@@today.to_s, @result)
        assert(@result.index(@@two_years_ago.to_s) > @result.index(@@one_year_ago.to_s), 'Newer entries must come first')
        # Do we have the correct links?
        needed_part = changelog_request_path.sub('de/gcc/', '')
        assert_match(needed_part + '/' + @@two_years_ago.to_s, @result, 'Must find link for two years old entry')
        assert_match(needed_part + '/' + @@one_year_ago.to_s, @result, 'Must find link for one year old entry')
        assert_match(needed_part + '/' + @@today.to_s, @result, 'Must find link for todays entry')
      end
    end
  end
end

