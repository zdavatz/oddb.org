#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestSession -- oddb.org -- 01.07.2012 -- yasaka@ywesee.com
# ODDB::TestSession -- oddb.org -- 24.06.2011 -- mhatakeyama@ywesee.com
# ODDB::TestSession -- oddb.org -- 22.10.2002 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'flexmock/minitest'
require 'stub/config'
require 'util/session'
require 'stub/odba'
require 'sbsm/trans_handler'
require 'sbsm/app'
require 'rack/test'
begin  require 'pry'; rescue LoadError; end # ignore error when pry cannot be loaded (for Jenkins-CI)
module ODDB
  class TestSession <Minitest::Test
    def setup
      @unknown_user = flexmock('unknown_user',
                               :valid? => false)
      @app = flexmock('app',
                      :unknown_user     => @unknown_user,
                      :sorted_fachinfos => [],
                      :sorted_feedbacks => [],
                      :package_by_ean13 => 'package',
                      )
      @session = flexmock('session', ODDB::Session.new(app: @app))
    end
    def teardown
      ODBA.storage = nil
    end
    def test_login_token
      @session.set_cookie_input(:email, 'email')
      @session.set_cookie_input(:remember, 'remember')
      user_via_token = flexmock('user_via_token',
                                :generate_token => 'generate_token')
      flexmock(@app, :login_token => user_via_token)
      @rack_if = SBSM::RackInterface.new(app: @app)
      skip("I do not know how to test login_token under rack")
      rack_request = Rack::MockRequest.new(@rack_if)
      res1= rack_request.request('GET', 'http://ch.oddb.org/de/gcc/login_form/')
      res = rack_request.request('POST', 'login', {:remember => 'remember', :email => 'email', :generate_token => 'generate_token'})
      assert_equal('', res.body)
      assert_equal(user_via_token, @session.login_token)
    end
    def test_active_state
      @session.set_cookie_input(:email, 'email')
      @session.set_cookie_input(:remember, 'remember')
      user = flexmock('user',
                      :generate_token => 'generate_token',
                      :valid?         => true,
                      :allowed?       => true)
      flexmock(@app, :login_token => user)
      skip("I do not know how to test test_active_state under rack")
      assert_kind_of(ODDB::State::Drugs::Init, @session.active_state)
    end
    def test_allowed?
      flexmock(@unknown_user, :allowed? => true)
      skip("I do not know how to test test_allowed? under rack")
      assert_equal(true, @session.allowed?('args'))
    end
    def test_event
      @session.lookandfeel
      assert_equal(:home, @session.event)
    end
    def test_event__else
      assert_equal(:home, @session.event)
    end
    def test_expired?
      assert_equal(false, @session.expired?)
    end
    def test_limit_queries
      @session.instance_eval('@remote_ip = "remote_ip"')
      @session.instance_eval('@process_start = 0')
      ODDB::Session.class_eval('@@requests = {"remote_ip" => [0,1,2,3,4,5,6]}')
      flexmock(@session.state, :limited? => true)
      skip("I do not know how to test test_limit_queries under rack")
      assert_nil(@session.limit_queries)
    end
    def test_login
      user = flexmock('user',
                      :generate_token => 'generate_token',
                      :email          => 'email')
      flexmock(@app, :login => user)
      assert_equal(user, @session.login)
    end
    def test_login__with_remember_me
      @session.should_receive(:cookie_set_or_get).with(:remember_me).and_return(true)
      user = flexmock('user',
                      :generate_token => 'generate_token',
                      :email          => 'email')
      flexmock(@app, :login => user)
      assert_equal(user, @session.login)
    end
    def test_logout
      flexmock(@unknown_user,
               :yus_session  => 'yus_session',
               :remove_token => 'remove_token')
      flexmock(@app, :logout => 'logout')
      assert_kind_of(ODDB::State::Drugs::Init, @session.logout)
    end
    def test_process
      @rack_if = SBSM::RackInterface.new(app: @app)
      rack_request = Rack::MockRequest.new(@rack_if)
      res = rack_request.request
      assert_equal('', res.body)
    end
    def test_process__no_change_in_logged_in_user_entity
      # login
      user = flexmock('user',
                      :generate_token => 'generate_token',
                      :email          => 'email',
                      :valid?         => true,
                      :allowed?       => true)
      user_via_token = flexmock('user_via_token',
                      :generate_token => 'generate_token',
                      :email          => 'email')
      flexmock(@app,
               :login       => user,
               :login_token => user_via_token) # => called via SBSM::Session#process
      @session.login
      @rack_if = SBSM::RackInterface.new(app: @app)
      rack_request = Rack::MockRequest.new(@rack_if)
      rack_request.request
      assert_equal('user', @session.user.flexmock_name)
    end
    def test_add_to_interaction_basket
      expected = ["object"]
      assert_equal(expected, @session.add_to_interaction_basket('object'))
    end
    def test_clear_interaction_basket
      assert_equal([], @session.clear_interaction_basket)
    end
    def test_currency
      assert_equal('CHF', @session.currency)
    end
    def test_interaction_basket
      @session.should_receive(:user_input).with(:substance_ids).and_return(nil)
      assert_equal([], @session.interaction_basket)
    end
    def test_interaction_detail
      @session = flexmock('session', ODDB::Session.new(app: @app))
      @session.should_receive(:event).at_least.once.and_return(:interaction_detail)
      @session.should_receive(:user_input).with(:substance_ids).and_return(nil)
      @session.should_receive(:user_input).with(:atc_code).at_least.once.and_return("C07AB02,G04BE03")
      result =  @session.interaction_basket_atc_codes
      assert_equal(['C07AB02', 'G04BE03'], @session.interaction_basket_atc_codes)
    end
    def test_interaction_basket_count
      assert_equal(0, @session.interaction_basket_count)
    end
    def test_interaction_basket_ids
      assert_equal('', @session.interaction_basket_ids)
    end
    def test_interaction_basket_link
      expected = "http://www.oddb.org/de/gcc/interaction_basket/substance_ids/"
      assert_equal(expected, @session.interaction_basket_link)
    end
    def test_migel_alphabetical
      flexmock(@app, :search_migel_alphabetical => 'search_migel_alphabetical')
      assert_equal('search_migel_alphabetical', @session.migel_alphabetical('range'))
    end
    Valid_EAN13 = '7601001380028'
    def test_search_doctor_invalid_ean
      @app.should_receive(:search_doctors).once.and_return( ['search_doctors'])
      @app.should_receive(:doctor).with('key').once.and_return([])
      assert_equal([], @session.search_doctor('key'))
      assert_equal(['search_doctors'], @session.search_doctors('key'))
    end
    def test_search_doctor_valid_ean
      @app.should_receive(:search_doctors).once.and_return( ['search_doctors'])
      @app.should_receive(:doctor).once.and_return(['doctor'])
      assert_equal(['doctor'], @session.search_doctor(Valid_EAN13))
      assert_equal(['search_doctors'], @session.search_doctors(Valid_EAN13))
    end
    def test_search_pharmacy_valid_ean
      @app.should_receive(:pharmacy_by_gln).with(Valid_EAN13).once.and_return(Valid_EAN13)
      assert_equal(Valid_EAN13, @session.search_pharmacy(Valid_EAN13))
    end
    def test_search_company_valid_ean
      @app.should_receive(:search_company).once.with(Valid_EAN13).and_return(Valid_EAN13)
      assert_equal(Valid_EAN13, @session.search_company(Valid_EAN13))
    end
    def test_search_hospital_valid_ean
      @app.should_receive(:hospital_by_gln).with(Valid_EAN13).once.and_return(Valid_EAN13)
      assert_equal(Valid_EAN13, @session.search_hospital(Valid_EAN13))
    end
    def test_search_pharmacy
      @app.should_receive(:search_pharmacies).once.and_return( ['search_pharmacies'])
      @app.should_receive(:pharmacy_by_gln).with('key').once.and_return(nil)
      assert_nil(@session.search_pharmacy('key'))
      assert_equal(['search_pharmacies'], @session.search_pharmacies('key'))
    end
    def test_search_companies
      @app.should_receive(:search_company).once.and_return('key')
      @app.should_receive(:search_companies).once.and_return( ['search_companies'])
      assert_equal('key', @session.search_company('key'))
      assert_equal(['search_companies'], @session.search_companies('key'))
    end
    def test_search_hospital
      @app.should_receive(:hospital_by_gln).with('key').once.and_return(nil)
      @app.should_receive(:search_hospitals).never
      assert_nil(@session.search_hospital('key'))
    end
    def test_navigation
      expected = [
        ODDB::State::User::Preferences,
        :help_link,
        :faq_link,
        ODDB::State::Admin::Login,
        ODDB::State::User::YweseeContact,
        ODDB::State::Drugs::Init]
      skip("I do not know how to test test_navigation under rack")
      assert_equal(expected, @session.navigation)
    end
    def test_search_exact_indication
      flexmock(@app, :search_exact_indication => 'search_exact_indication')
      assert_equal('search_exact_indication', @session.search_exact_indication('query'))
    end
    def test_search_interactions
      flexmock(@app, :search_interactions => 'search_interactions')
      assert_equal('search_interactions', @session.search_interactions('query'))
    end
    def test_search_migel_products
      flexmock(@app, :search_migel_products => 'search_migel_products')
      assert_equal('search_migel_products', @session.search_migel_products('query'))
    end
    def test_search_substances
      flexmock(@app, :search_substances => 'search_substances')
      assert_equal('search_substances', @session.search_substances('query'))
    end
    def test_set_persistent_user_input
      assert_equal('value', @session.set_persistent_user_input('key', 'value'))
    end
    def test_search_oddb
      flexmock(@app, :search_oddb => 'search_oddb')
      assert_equal('search_oddb', @session.search_oddb('query'))
    end
    def test_reset_query_limit
      # This is a testcase for a class method
      assert_equal({}, ODDB::Session.reset_query_limit)
      assert_nil(ODDB::Session.reset_query_limit('ip'))
    end
    ThreePackages = { '7680576730049' => 'package',
                     '7680193950301' => 'package',
                     '7680353520153' => 'package'}
    UrlForThreePackages = '7680576730049,7680193950301,7680353520153'
    def test_choosen_drugs_for_home_interaction
      @session = ODDB::Session.new(app: @app)
      @session.instance_eval("@request_path = '/de/gcc/home_interactions/#{UrlForThreePackages}'")
      assert_equal(ThreePackages, @session.choosen_drugs)
    end
    def test_choosen_drugs_for_interactions_with_atc_and_iksnr
      @session = ODDB::Session.new(app: @app)

      @session.instance_eval("@request_path = '/de/gcc/home_interactions/58392,7680591310011,L02BA01,58643'")
      expected = {"58392"=>"package",
                  "7680591310011"=>"package",
                  "L02BA01"=>"package",
                  "58643"=>"package",}
      assert_equal(expected, @session.choosen_drugs)
    end
    def test_choosen_drugs_for_interactions_plus_persistent
      @session = ODDB::Session.new(app: @app)

      @session.instance_eval("@request_path = '/de/gcc/home_interactions/58392,7680591310011,L02BA01,58643'")
      drugs = {'7680591310012' => 'package_drugs'}
      @session.set_persistent_user_input(:drugs, drugs)
      expected = {"58392"=>"package",
                  "7680591310011"=>"package",
                  "L02BA01"=>"package",
                  "58643"=>"package",
                  "7680591310012"=>"package_drugs",}
      assert_equal(expected, @session.choosen_drugs)
    end
    def test_choosen_drugs_nothing_found
      @session = ODDB::Session.new(app: @app)

      @session.instance_eval("@request_path = '/de/gcc/home_interactions'")
      @session.set_persistent_user_input(:drugs, nil)
      assert_equal({}, @session.choosen_drugs)
    end
    def test_create_search_url_interactions
      {
        'create_search_url' => 'http://www.oddb.org/de/gcc/home_interactions',
        'create_search_url([7680576730049,7680193950301] )' =>
            'http://www.oddb.org/de/gcc/home_interactions/ean/7680576730049/7680193950301'
        }.each {
          |cmd, url|
        @session = ODDB::Session.new(app: @app)

        res = @session.instance_eval(cmd)
        assert_equal(url,res)
      }
    end
    def test_get_address_parent_no_parent_in_url
      @session = ODDB::Session.new(app: @app)

      @session.instance_eval("@request_path = '/de/gcc/'")
      res = @session.get_address_parent
      assert_nil(res)
    end
    def test_get_address_parent_via_persistent_input
      @app.should_receive(:hospital_by_gln).once.with('7601001380028').and_return('7601001380028')
      @session = ODDB::Session.new(app: @app)

      @session.instance_eval("@request_path = '/de/gcc/'")
      @session.set_persistent_user_input(:ean, '7601001380028')
      res = @session.get_address_parent
      assert_equal('7601001380028', res)
    end
    def test_change_log_fachinfo
      reg_nr = '51193'
      @session = ODDB::Session.new(app: @app)

      text_info = flexmock('text_info', ODDB::FachinfoDocument2001.new, :odba_store => nil)
      fi = flexmock('fachinfo', ODDB::Fachinfo.new, :de => text_info)
      reg = flexmock('registration', ODDB::Registration.new(reg_nr), :fachinfo => fi)
      @app.should_receive(:registration).with(reg_nr).and_return(reg)
      text_info.add_change_log_item('alt','neu')
      @session.instance_eval("@request_path = '/de/gcc/show/fachinfo/#{reg_nr}/diff/#{@@today.strftime('%d.%m.%Y')}'")
      assert_equal(3, @session.choosen_info_diff.size)
      assert_equal(reg_nr,        @session.choosen_info_diff[0].iksnr)
      assert_equal(1,             @session.choosen_info_diff[1].size)
      assert_equal(@@today.to_s,  @session.choosen_info_diff[1].last.time.to_s)
      assert_equal(@@today.to_s,  @session.choosen_info_diff[2].time.to_s)
    end
    def test_is_mobile
      @session = ODDB::Session.new(app: SBSM::App.new)
      assert_equal(false, @session.is_mobile_app?)
    end
    def test_is_mobile_when_useragent_rack_request_nil
      @app = SBSM::App.new
      ODDB.config.app_user_agent = 'mobile'
      @session = ODDB::Session.new(app: @app)
      assert_equal(false, @session.is_mobile_app?)
    end
    def test_is_mobile_when_useragent_and_rack_request
        @app = SBSM::App.new
        ODDB.config.app_user_agent = 'mobile'
        saved_server_name = ODDB::Session::SERVER_NAME
        eval("ODDB::Session::SERVER_NAME = 'mobile.oddb.org'")
        @session = ODDB::Session.new(app: @app)
        @session.rack_request = flexmock('rack_request', :user_agent => 'mobile')
        assert_equal(true, @session.is_mobile_app?)
        eval("ODDB::Session::SERVER_NAME = '#{saved_server_name}'")
        saved_server_name = ODDB::Session::SERVER_NAME
    end
    def test_root_url
      assert_equal("https://www.oddb.org", @session.root_url)
    end
  end
end # ODDB
