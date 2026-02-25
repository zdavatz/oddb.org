#!/usr/bin/env ruby

# ODDB::TestUser -- oddb.org -- 07.07.2011 -- hwyss@ywesee.com
# ODDB::TestUser -- oddb.org -- 23.07.2003 -- hwyss@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "stub/odba"

require "minitest/autorun"
require "flexmock/minitest"
require "model/user"
require "digest/md5"

module ODDB
  class TestUnknownUser < Minitest::Test
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

  class TestSwiyuStub < Minitest::Test
    def setup
      @stub = SwiyuStub.new "test@mail.ch"
    end

    def test_yus_name
      assert_equal "test@mail.ch", @stub.yus_name
    end

    def test_equal
      assert_equal false, @stub == SwiyuStub.new("other@mail.ch")
      assert_equal true, @stub == SwiyuStub.new("test@mail.ch")
      assert_equal false, @stub.eql?(SwiyuStub.new("other@mail.ch"))
      assert_equal true, @stub.eql?(SwiyuStub.new("test@mail.ch"))
    end

    def test_yus_stub_alias
      # YusStub should be an alias for SwiyuStub for ODBA compatibility
      assert_equal SwiyuStub, YusStub
    end
  end

  class TestSwiyuUser < Minitest::Test
    def setup
      @roles_config = {
        "roles" => ["org.oddb.CompanyUser"],
        "permissions" => [
          {"action" => "login", "key" => "org.oddb.CompanyUser"},
          {"action" => "edit", "key" => "org.oddb.model.!company.123"},
          {"action" => "credit", "key" => "org.oddb.FlexMock"},
          {"action" => "credit", "key" => "org.oddb.Registration"}
        ],
        "association" => nil,
        "preferences" => {
          "name_first" => "Hans",
          "name_last" => "Mueller"
        }
      }
      @user = SwiyuUser.new(
        gln: "7601234567890",
        first_name: "Hans",
        last_name: "Mueller",
        roles_config: @roles_config
      )
    end

    def test_allowed
      require "model/activeagent"
      require "model/company"
      require "model/fachinfo"
      require "model/package"
      require "model/registration"
      require "model/sequence"

      company = Company.new
      company.pointer = Persistence::Pointer.new [:company, 123]
      assert_equal true, @user.allowed?("edit", company)

      registration = Registration.new "12345"
      registration.pointer = Persistence::Pointer.new [:registration, "12345"]
      registration.company = company
      assert_equal true, @user.allowed?("edit", registration)

      sequence = Sequence.new "01"
      sequence.registration = registration
      assert_equal true, @user.allowed?("edit", sequence)

      package = Package.new "001"
      package.sequence = sequence
      assert_equal true, @user.allowed?("edit", package)

      fachinfo = Fachinfo.new
      fachinfo.registrations.push registration
      assert_equal true, @user.allowed?("edit", fachinfo)

      agent = InactiveAgent.new "inactive_substance"
      agent.sequence = sequence
      assert_equal true, @user.allowed?("edit", agent)

      agent = ActiveAgent.new "substance"
      agent.sequence = sequence
      assert_equal true, @user.allowed?("edit", agent)
    end

    def test_allowed_root_user
      root_config = {"roles" => ["org.oddb.RootUser"]}
      root_user = SwiyuUser.new(gln: "7601111111111", first_name: "Root", last_name: "User", roles_config: root_config)
      assert_equal true, root_user.allowed?("login", "org.oddb.RootUser")
      assert_equal true, root_user.allowed?("edit", "anything")
    end

    def test_allowed_login
      assert_equal true, @user.allowed?("login", "org.oddb.CompanyUser")
      assert_equal false, @user.allowed?("login", "org.oddb.RootUser")
    end

    def test_creditable
      assert_equal true, @user.creditable?(FlexMock.new)
      assert_equal true, @user.creditable?("org.oddb.Registration")
    end

    def test_expired
      assert_equal false, @user.expired?
    end

    def test_fullname
      assert_equal "Hans Mueller", @user.fullname
    end

    def test_groups
      assert_equal [], @user.groups
    end

    def test_model
      assert_nil @user.model
    end

    def test_model_with_association
      config_with_assoc = @roles_config.merge("association" => 42)
      user = SwiyuUser.new(gln: "7601234567890", first_name: "Hans", last_name: "Mueller", roles_config: config_with_assoc)
      ODBA.cache = flexmock "odba cache"
      ODBA.cache.should_receive(:fetch).with(42, user).and_return "an object"
      assert_equal "an object", user.model
    ensure
      ODBA.cache = nil
    end

    def test_name
      assert_equal "Hans Mueller", @user.name
    end

    def test_email
      assert_equal "7601234567890", @user.email
      assert_equal "7601234567890", @user.unique_email
    end

    def test_valid
      assert_equal true, @user.valid?
    end

    def test_valid_empty_gln
      user = SwiyuUser.new(gln: "", first_name: "Hans", last_name: "Mueller")
      assert_equal false, user.valid?
    end

    def test_valid_nil_gln
      user = SwiyuUser.new(gln: nil, first_name: "Hans", last_name: "Mueller")
      assert_equal false, user.valid?
    end

    def test_preferences
      assert_equal "Hans", @user.name_first
      assert_equal "Mueller", @user.name_last
    end

    def test_set_preferences_noop
      # Should not raise
      @user.set_preferences(name_first: "Test")
    end

    def test_generate_token
      assert_nil @user.generate_token
    end

    def test_cache_html
      assert_equal false, @user.cache_html?
    end
  end

  class TestUserObserver < Minitest::Test
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
      user = flexmock "user"
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
      @observer.users.push flexmock(yus_name: "test@email.ch")
      assert_equal "test@email.ch", @observer.contact_email
      @observer.users.push flexmock(yus_name: "other@email.ch")
      assert_equal "test@email.ch", @observer.contact_email
    end

    def test_has_user
      assert_equal false, @observer.has_user?
      @observer.users.push flexmock(yus_name: "test@email.ch")
      assert_equal true, @observer.has_user?
    end

    def test_invoice_email
      assert_nil @observer.invoice_email
      @observer.users.push flexmock(yus_name: "test@email.ch")
      assert_equal "test@email.ch", @observer.invoice_email
      @observer.users.push flexmock(yus_name: "other@email.ch")
      assert_equal "test@email.ch", @observer.invoice_email
      @observer.invoice_email = "other@email.ch"
      assert_equal "other@email.ch", @observer.invoice_email
    end

    def test_remove_user
      user = flexmock "user"
      @observer.users.push user
      other = flexmock "other"
      @observer.remove_user other
      assert_equal [user], @observer.users
      assert_nil @observer.saved
      @observer.remove_user user
      assert_equal [], @observer.users
      assert_equal true, @observer.saved
    end
  end
end
