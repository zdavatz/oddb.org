#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestUser -- oddb.org -- 07.07.2011 -- hwyss@ywesee.com 
# ODDB::TestUser -- oddb.org -- 23.07.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'stub/odba'
gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'model/user'
require 'digest/md5'

module ODDB
  class YusStub
    YUS_SERVER = FlexMock.new 'yus_server'
  end
  class TestUnknownUser <Minitest::Test
    include FlexMock::TestCase
    def setup
      @user = UnknownUser.new
    end
    def test_allowed
      assert_equal false, @user.allowed?(:anything)
    end
    def test_cache_html
      assert_equal true, @user.cache_html?
    end
    def test_creditable
      assert_equal false, @user.creditable?(:anything)
    end
    def test_model
      assert_nil @user.model
    end
    def test_valid
      assert_equal(false, @user.valid?)
    end
  end
  class TestYusStub <Minitest::Test
    include FlexMock::TestCase
    def setup
      @stub = YusStub.new 'test@mail.ch'
      @session = flexmock 'yus-session'
    end
    def test_yus_name
      assert_equal 'test@mail.ch', @stub.yus_name
    end
    def test_method_missing
      YusStub::YUS_SERVER.should_receive(:autosession)\
        .times(1).and_return do |domain, block| block.call @session end
      @session.should_receive(:get_entity_preference)\
        .with('test@mail.ch', :something).and_return do
        assert true
        'a result'
      end
      assert_equal 'a result', @stub.something
    end
    def test_equal
      assert_equal false, @stub == YusStub.new('other@mail.ch')
      assert_equal true, @stub == YusStub.new('test@mail.ch')
      assert_equal false, @stub.eql?(YusStub.new('other@mail.ch'))
      assert_equal true, @stub.eql?(YusStub.new('test@mail.ch'))
    end
  end
  class TestYusUser <Minitest::Test
    include FlexMock::TestCase
    def setup
      @session = flexmock 'yus-session'
      @user = YusUser.new @session
    end
    def test_allowed
      require 'model/activeagent'
      require 'model/company'
      require 'model/fachinfo'
      require 'model/package'
      require 'model/registration'
      require 'model/sequence'

      company = Company.new
      company.pointer = Persistence::Pointer.new [:company, 123]
      comp_privilege = 'org.oddb.model.!company.123'
      @session.should_receive(:allowed?).with('company', comp_privilege).times(1)\
        .and_return do assert true; 'from company' end
      assert_equal 'from company', @user.allowed?('company', company)

      registration = Registration.new '12345'
      registration.pointer = Persistence::Pointer.new [:registration, '12345']
      reg_privilege = 'org.oddb.model.!registration.12345'
      @session.should_receive(:allowed?).with('registration', nil).times(1)\
        .and_return do assert true; false end
      @session.should_receive(:allowed?).with('registration', reg_privilege)\
        .times(1).and_return do assert true; 'from registration' end
      assert_equal 'from registration',
                   @user.allowed?('registration', registration)
      registration.company = company
      @session.should_receive(:allowed?).with('registration', comp_privilege)\
        .times(1).and_return do assert true; 'from registration' end
      assert_equal 'from registration',
                   @user.allowed?('registration', registration)

      sequence = Sequence.new '01'
      sequence.registration = registration
      @session.should_receive(:allowed?).with('sequence', comp_privilege)\
        .times(1).and_return do assert true; 'from sequence' end
      assert_equal 'from sequence', @user.allowed?('sequence', sequence)

      package = Package.new '001'
      package.sequence = sequence
      @session.should_receive(:allowed?).with('package', comp_privilege)\
        .times(1).and_return do assert true; 'from package' end
      assert_equal 'from package', @user.allowed?('package', package)

      fachinfo = Fachinfo.new
      fachinfo.registrations.push registration
      @session.should_receive(:allowed?).with('fachinfo', comp_privilege)\
        .times(1).and_return do assert true; 'from fachinfo' end
      assert_equal 'from fachinfo', @user.allowed?('fachinfo', fachinfo)

      agent = ActiveAgent.new 'substance'
      agent.sequence = sequence
      @session.should_receive(:allowed?).with('activeagent', comp_privilege)\
        .times(1).and_return do assert true; 'from activeagent' end
      assert_equal 'from activeagent', @user.allowed?('activeagent', agent)
    end
    def test_creditable
      require 'model/activeagent'
      require 'model/company'
      require 'model/fachinfo'
      require 'model/package'
      require 'model/registration'
      require 'model/sequence'

      privilege = 'org.oddb.FlexMock'
      @session.should_receive(:allowed?).with('credit', privilege).times(1)\
        .and_return do assert true; 'creditable from class' end
      assert_equal 'creditable from class', @user.creditable?(FlexMock.new)
      privilege = 'org.oddb.Registration'
      @session.should_receive(:allowed?).with('credit', privilege).times(1)\
        .and_return do assert true; 'creditable from string' end
      assert_equal 'creditable from string', @user.creditable?(privilege)
    end
    def test_expired
      @session.should_receive(:ping).and_return do assert true; true end
      assert_equal false, @user.expired?
    end
    def test_expired__error
      @session.should_receive(:ping).and_raise(RangeError)
      assert(@user.expired?)
    end
    def stderr_null
      require 'tempfile'
      $stderr = Tempfile.open('stderr')
      yield
      $stderr.close
      $stderr = STDERR
    end
    def test_remote_call
      flexmock(@session).should_receive(:method_name).and_raise(RangeError)
      stderr_null do 
        assert_nil(@user.remote_call(:method_name, 'args'))
      end
    end
    def test_fullname
      @session.should_receive(:get_preference).with(:name_first).and_return do
        assert true
        'FirstName'
      end
      @session.should_receive(:get_preference).with(:name_last).and_return do
        assert true
        'LastName'
      end
      assert_equal 'FirstName LastName', @user.fullname
    end
    def test_groups
      ent1 = flexmock :name => 'PowerUser'
      ent2 = flexmock :name => 'test@mail.ch'
      ent3 = flexmock :name => 'AdminUser'
      ent4 = flexmock :name => 'other@mail.ch'
      @session.should_receive(:entities).and_return [ent1, ent2, ent3, ent4]
      assert_equal [ent1, ent3], @user.groups
    end
    def test_method_missing
      block_arg = nil
      @session.should_receive(:something).with('an argument', Proc).times(1)\
        .and_return do |arg, block|
        assert true
        block.call 'a block-argument'
      end
      @user.something('an argument') do |arg| block_arg = arg end
      assert_equal 'a block-argument', block_arg
    end
    def test_model
      ODBA.cache = flexmock 'odba cache'
      ODBA.cache.should_receive(:fetch).with('an odba id', @user)\
                                       .and_return 'an object'
      @session.should_receive(:get_preference).with('association')\
        .and_return 'an odba id'
      assert_equal 'an object', @user.model
    ensure
      ODBA.cache = nil
    end
    def test_name
      @session.should_receive(:name).and_return 'test@email.ch'
      assert_equal 'test@email.ch', @user.name
      assert_equal 'test@email.ch', @user.email
      assert_equal 'test@email.ch', @user.unique_email
    end
    def test_set_preferences
      prefs = {
        :salutation    => 'Salutation',
        :name_first    => 'NameFirst',
        :name_last     => 'NameLast',
        :address       => 'Address',
        :city          => 'City',
        :plz           => 'PLZ',
        :company_name  => 'CompanyName',
        :business_area => 'BusinessArea',
        :phone         => 'Phone',
        :poweruser_duration => 'PoweruserDuration',
        :unknown_key   => 'UnknownKey',
      }
      expected = {
        :salutation    => 'Salutation',
        :name_first    => 'NameFirst',
        :name_last     => 'NameLast',
        :address       => 'Address',
        :city          => 'City',
        :plz           => 'PLZ',
        :company_name  => 'CompanyName',
        :business_area => 'BusinessArea',
        :phone         => 'Phone',
        :poweruser_duration => 'PoweruserDuration',
      }
      @session.should_receive(:set_preferences).with(expected).and_return do
        assert true
      end
      @user.set_preferences prefs
    end
  end
  class TestUserObserver <Minitest::Test
    include FlexMock::TestCase
    class Observer
      attr_reader :saved
      include UserObserver
      def odba_store
        @saved = true
      end
    end
    def setup
      @observer = Observer.new
    end
    def test_add_user
      user = flexmock 'user'
      @observer.add_user nil
      assert_equal [], @observer.users
      @observer.add_user user
      assert_equal [user], @observer.users
      assert_equal true, @observer.saved
      @observer.add_user user
      assert_equal [user], @observer.users
      @observer.add_user nil
      assert_equal [user], @observer.users
    end
    def test_contact_email
      assert_nil @observer.contact_email
      @observer.users.push flexmock(:yus_name => 'test@email.ch')
      assert_equal 'test@email.ch', @observer.contact_email
      @observer.users.push flexmock(:yus_name => 'other@email.ch')
      assert_equal 'test@email.ch', @observer.contact_email
    end
    def test_has_user
      assert_equal false, @observer.has_user?
      @observer.users.push flexmock(:yus_name => 'test@email.ch')
      assert_equal true, @observer.has_user?
    end
    def test_invoice_email
      assert_nil @observer.invoice_email
      @observer.users.push flexmock(:yus_name => 'test@email.ch')
      assert_equal 'test@email.ch', @observer.invoice_email
      @observer.users.push flexmock(:yus_name => 'other@email.ch')
      assert_equal 'test@email.ch', @observer.invoice_email
      @observer.invoice_email = 'other@email.ch'
      assert_equal 'other@email.ch', @observer.invoice_email
    end
    def test_remove_user
      user = flexmock 'user'
      @observer.users.push user
      other = flexmock 'other'
      @observer.remove_user other
      assert_equal [user], @observer.users
      assert_nil @observer.saved
      @observer.remove_user user
      assert_equal [], @observer.users
      assert_equal true, @observer.saved
    end
  end
end
