#!/usr/bin/env ruby
# encoding: utf-8
# TestOddbApp -- oddb.org -- 09.04.2012 -- yasaka@ywesee.com
# TestOddbApp -- oddb.org -- 19.01.2012 -- mhatakeyama@ywesee.com
# TestOddbApp -- oddb.org -- 16.02.2011 -- mhatakeyama@ywesee.com, zdavatz@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

begin
  require 'pry'
rescue LoadError
  # ignore error when pry cannot be loaded (for Jenkins-CI)
end

require 'syck'
require 'stub/odba'
require 'stub/config'

require 'minitest/autorun'
require 'digest/md5'
require 'util/persistence'
require 'model/substance'
require 'model/atcclass'
require 'model/orphan'
require 'model/epha_interaction'
require 'model/galenicform'
require 'util/language'
require 'flexmock/minitest'
require 'util/oddbapp'
require 'stub/oddbapp'
require 'util/latest'

class TestOddbApp3 <MiniTest::Unit::TestCase
  @@port_id ||= 23000
	def setup
    GC.start # start a garbage collection
    ODDB::GalenicGroup.reset_oids
    ODBA.storage.reset_id
    dir = File.expand_path('../data/prevalence', File.dirname(__FILE__))
    @app = ODDB::App.new(server_uri: "druby://localhost:#{@@port_id}", unknown_user: ODDB::UnknownUser.new)
    @@port_id += 1
    flexmock('epha', ODDB::EphaInteractions).should_receive(:read_from_csv).and_return([])
    @session = flexmock('session') do |ses|
      ses.should_receive(:grant).with('name', 'key', 'item', 'expires')\
        .and_return('session').by_default
      ses.should_receive(:entity_allowed?).with('email', 'action', 'key')\
        .and_return('session').by_default
      ses.should_receive(:create_entity).with('email', 'pass')\
        .and_return('session').by_default
      ses.should_receive(:get_entity_preference).with('name', 'key')\
        .and_return('session').by_default
      ses.should_receive(:get_entity_preference).with('name', 'association')\
        .and_return('odba_id').by_default
      ses.should_receive(:get_entity_preferences).with('name', 'keys')\
        .and_return('session').by_default
      ses.should_receive(:get_entity_preferences).with('error', 'error')\
        .and_raise(Yus::YusError).by_default
      ses.should_receive(:reset_entity_password).with('name', 'token', 'password')\
        .and_return('session').by_default
      ses.should_receive(:set_entity_preference).with('name', 'key', 'value', 'domain')\
        .and_return('session').by_default
    end
    flexmock(ODDB::App::YUS_SERVER) do |yus|
      yus.should_receive(:autosession).and_yield(@session).by_default
    end
    flexmock(ODBA.storage) do |sto|
      sto.should_receive(:remove_dictionary).by_default
      sto.should_receive(:generate_dictionary).with('language')\
        .and_return('generate_dictionary').by_default
      sto.should_receive(:generate_dictionary).with('french')\
        .and_return('french_dictionary').by_default
      sto.should_receive(:generate_dictionary).with('german')\
        .and_return('german_dictionary').by_default
    end
  end
  def teardown
    ODBA.storage = nil
    super
  end
  def same?(o1, o2)
    h1 = {}
    h2 = {}
    if o1.instance_variables.sort == o2.instance_variables.sort
      o1.instance_variables.each do |v|
        if v.to_s == '@atc_classes' # actually atc_classes should also be checked
          h1[v.to_sym] = o1.atc_classes.size
          h2[v.to_sym] = o2.atc_classes.size
        else
          h1[v.to_sym] = o1.instance_variable_get(v)
          h2[v.to_sym] = o2.instance_variable_get(v)
        end
      end
    else
      return false
    end
    return (h1 == h2)
  end
  def test_update_feedback_rss_feed
    flexstub(@app) do |app|
      app.should_receive(:async).and_yield
    end
    assert_nil(@app.update_feedback_rss_feed)
  end
  def test_update_feedback_rss_feed__error
    flexstub(@app) do |app|
      app.should_receive(:async).and_yield
    end
    flexstub(ODDB::Plugin) do |plg|
      plg.should_receive(:new).and_raise(StandardError)
    end
    assert_nil(@app.update_feedback_rss_feed)
  end
end
