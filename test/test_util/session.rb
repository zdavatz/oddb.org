#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestSession -- oddb.org -- 01.07.2012 -- yasaka@ywesee.com
# ODDB::TestSession -- oddb.org -- 24.06.2011 -- mhatakeyama@ywesee.com
# ODDB::TestSession -- oddb.org -- 22.10.2002 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'util/session'

module ODDB
  class TestSession <Minitest::Test
    include FlexMock::TestCase
    def setup
      @unknown_user = flexmock('unknown_user',
                               :valid? => false)
      @app = flexmock('app',
                      :unknown_user     => @unknown_user,
                      :sorted_fachinfos => [],
                      :sorted_feedbacks => [])
      @validator = flexmock('validator',
                            :reset_errors => 'reset_errors',
                            :validate     => 'validate')
      @session = ODDB::Session.new('key', @app, @validator)
    end
    def test_login_token
      @session.set_cookie_input(:email, 'email')
      @session.set_cookie_input(:remember, 'remember')
      user_via_token = flexmock('user_via_token',
                                :generate_token => 'generate_token')
      flexmock(@app, :login_token => user_via_token)
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
      assert_kind_of(ODDB::State::Drugs::Init, @session.active_state)
    end
    def test_allowed?
      flexmock(@unknown_user, :allowed? => true)
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
      assert_equal(nil, @session.limit_queries)
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
      request = flexmock('request',
                         :unparsed_uri   => 'unparsed_uri',
                         :user_agent     => "",
                         :request_method => 'request_method',
                         :params         => ['params'],
                         :cookies        => 'cookies')
      assert_equal('', @session.process(request))
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
      # process
      request = flexmock('request',
                         :unparsed_uri   => 'unparsed_uri',
                         :user_agent     => '',
                         :request_method => 'request_method',
                         :params         => ['params'],
                         :cookies        => 'cookies')
      @session.process(request)
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
    def test_get_currency_rate
      flexmock(@app, :get_currency_rate => 'get_currency_rate')
      assert_equal('get_currency_rate', @session.get_currency_rate('CHF'))
    end
    def test_interaction_basket
      @session.should_receive(:user_input).with(:substance_ids).and_return(nil)
      assert_equal([], @session.interaction_basket)
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
    def test_analysis_alphabetical
      flexmock(@app, :search_analysis_alphabetical => 'search_analysis_alphabetical')
      assert_equal('search_analysis_alphabetical', @session.analysis_alphabetical('range'))
    end
    def test_migel_alphabetical
      flexmock(@app, :search_migel_alphabetical => 'search_migel_alphabetical')
      assert_equal('search_migel_alphabetical', @session.migel_alphabetical('range'))
    end
    def test_navigation
      expected = [
        ODDB::State::User::Preferences,
        :help_link,
        :faq_link,
        ODDB::State::Admin::Login,
        ODDB::State::User::YweseeContact,
        ODDB::State::Drugs::Init]
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
      assert_equal(nil, ODDB::Session.reset_query_limit('ip'))
    end
  end
end # ODDB
