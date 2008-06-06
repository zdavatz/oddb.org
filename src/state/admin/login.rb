#!/usr/bin/env ruby
# State::Admin::Login -- oddb -- 25.11.2002 -- hwyss@ywesee.com 

require 'state/global_predefine'
require 'state/admin/root'
require 'state/user/invalid_user'
require 'view/admin/login'

module ODDB
  module State
    module Admin
module LoginMethods
  def login
    autologin(@session.login)
  rescue Yus::UnknownEntityError
    @errors.store(:email, create_error(:e_authentication_error, :email, nil))
    self
  rescue Yus::AuthenticationError
    @errors.store(:pass, create_error(:e_authentication_error, :pass, nil))
    self
  end
  def autologin(user, default=@previous)
    newstate = if(user.valid?)
      des = @session.desired_state
      @session.desired_state = nil
      @session.valid_input.update(@desired_input) if(@desired_input)
      des || default || trigger(:home)
    else
      State::User::InvalidUser.new(@session, user)
    end
    reconsider_permissions(user, newstate)
  end
  private
  def reconsider_permissions(user, state)
    viral_modules(user) { |mod|
      state.extend(mod)
    }
    state
  end
  def viral_modules(user)
    [ 
      ['org.oddb.RootUser', State::Admin::Root],
      ['org.oddb.AdminUser', State::Admin::Admin],
      ['org.oddb.PowerUser', State::Admin::PowerUser],
      ['org.oddb.CompanyUser', State::Admin::CompanyUser],
      ['org.oddb.PowerLinkUser', State::Admin::PowerLinkUser],
    ].each { |key, mod|
      if(user.allowed?("login", key))
        yield mod
      end
    }
  end
end
class Login < State::Global
  DIRECT_EVENT = :login_form
  VIEW = View::Admin::Login
  SNAPBACK_EVENT = nil
  ## LoginMethods are included in State::Global
end
class TransparentLogin < State::Admin::Login
  attr_accessor :desired_event
  def login
    autologin(@session.login, self)
    if(@model.respond_to?(:pointer))
      klass = resolve_state(@model.pointer)
      newstate = klass.new(@session, @model)
      newstate.extend(@viral_module)
      newstate
    else
      trigger(@desired_event)
    end
  rescue Yus::UnknownEntityError
    @errors.store(:email, create_error(:e_authentication_error, :email, nil))
    self
  rescue Yus::AuthenticationError
    @errors.store(:pass, create_error(:e_authentication_error, :pass, nil))
    self
  end
end
    end
  end
end
