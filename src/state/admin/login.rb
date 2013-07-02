#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::Login -- oddb -- 02.07.2012 -- yasaka@ywesee.com
# ODDB::State::Admin::Login -- oddb -- 29.04.2012 -- yasaka@ywesee.com
# ODDB::State::Admin::Login -- oddb -- 25.11.2002 -- hwyss@ywesee.com

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
    newstate = if !user.nil? and user.valid?
      des = @session.desired_state
      @session.desired_state = nil
      @session.valid_input.update(@desired_input) if(@desired_input)
      nextstate = (des || default || trigger(:home))
      entrances = [ # login redirect
        ODDB::State::Drugs::ResultLimit,
        ODDB::State::Admin::Login,
        ODDB::State::Admin::TransparentLogin
      ]
      if entrances.include?(self.class)
        location = nextstate.request_path
        if location.nil? or
           location =~ /logout/ or
           nextstate.class == self.class
          location = '/'
        end
      else
        location = self.request_path
      end
      _state = self
      if self.class == ODDB::State::Drugs::ResultLimit or
         nextstate.request_path == self.request_path
        _state = nextstate
      else
        _state.http_headers = { # replace with self to prevent request loop
          'Status'   => '303 See Other',
          'Location' => location
        }
      end
      _state
    else
      State::User::InvalidUser.new(@session, user)
    end
    if newstate.respond_to?(:augment_self)
      reconsider_permissions(user, newstate.augment_self)
    else
      reconsider_permissions(user, newstate)
    end
  end
  private
  def reconsider_permissions(user, state)
    if user.valid?
      viral_modules(user) { |mod|
        state.extend(mod)
      }
    end
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
      if (user.allowed?("login", key))
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
  # LoginMethods has login redirect
end
    end
  end
end
