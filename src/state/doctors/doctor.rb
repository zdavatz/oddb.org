#!/usr/bin/env ruby
# encoding: utf-8
# ODDBOOState::Doctors::Doctor -- oddb -- 09.08.2012 -- yasaka@ywesee.com
# ODDB::State::Doctors::Doctor -- oddb -- 27.05.2003 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'state/doctors/global'
require 'view/doctors/doctor'
require 'view/confirm'
require 'rmail'
require 'util/smtp_tls'

module ODDB
  module State
    module Doctors
class Confirm < State::Admin::Global
  VIEW = View::Confirm
end
class AcceptExperience < State::Doctors::Global
  def init
    @model.doctor.experience(@model.odba_id).hidden = false
    @model = @session.app.update(@model.pointer, {:hidden => false}, unique_email)
    @session.app.update(@model.doctor.pointer, {}, unique_email)
    args = {:ean => @model.doctor.ean13}
    self.http_headers = {
      'Status'   => '303 See Other',
      'Location' => @session.lookandfeel._event_url(:doctor, args)
    }
    super
  end
end
class Doctor < State::Doctors::Global
  VIEW = View::Doctors::Doctor
  LIMITED = false
  def init
    @current_experience = nil
    super
  end
  def update_experience
    keys = [:title, :description]
    unless @passed_turing_test
      keys.push :captcha
    end
    input = user_input(keys)
    answer = ODDB::LookandfeelBase::DICTIONARIES[@session.language][:captcha_answer]
    if(@passed_turing_test)
      # do nothing
    elsif(input[:captcha] == answer)
      @passed_turing_test = true
    else
      @errors.store(:captcha, create_error('e_failed_turing_test', :captcha, nil))
    end
    unless(error?)
      exp = @session.app.create(model.pointer + :experience)
      @session.app.update(exp.pointer, input, unique_email)
      @current_experience = exp
      experience_request
    else
      self
    end
  end
  def experience_request
    email = @model.email
    unless(error?)
      token = Digest::MD5.hexdigest(rand.to_s)
      time = Time.now + 48 * 60 * 60
      # TODO
      # use token
      #@session.yus_grant(email, 'accept_experience', token, time)
      notify_user(email, token, time)
      Confirm.new(@session, :experience_request_confirm)
    end
  rescue Yus::UnknownEntityError
    @errors.store(:email, create_error('e_unknown_user', :email, email))
    self
  end
  def notify_user(email, token, time)
    lnf = @session.lookandfeel
    config = ODDB.config
    mail = RMail::Message.new
    header = mail.header
    recipient = header.to = email
    header.from = config.mail_from
    header.subject = lnf.lookup(:experience_mail_subject) + email
    args = {:token => token, :email => email, :oid => @current_experience.odba_id}
    url  = lnf._event_url(:accept_experience, args)
    exp_text = [
      @current_experience.title,
      @current_experience.description,
    ].join("\n")
    mail.body = lnf.lookup(
      :experience_mail_body,
      recipient,
      exp_text,
      url,
      time.strftime(lnf.lookup(:time_format_long))
    )
    Net::SMTP.start(
      config.smtp_server, config.smtp_port, config.smtp_domain,
      config.smtp_user, config.smtp_pass, config.smtp_authtype
    ) { |smtp|
      smtp.sendmail(mail.to_s, config.smtp_user, recipient)
    }
    recipient
  end
end
class RootDoctor < Doctor
  VIEW = View::Doctors::RootDoctor
  def update
    mandatory = [:title, :name_first, :name]
    keys = mandatory + [
      :specialities, :capabilities,
      :correspondence, :exam, :ean13, :email
    ]
    input = user_input(keys, mandatory)
    unless(error?)
      @model = @session.app.update(@model.pointer, input)
    end
    self
  end
end
    end
  end
end
