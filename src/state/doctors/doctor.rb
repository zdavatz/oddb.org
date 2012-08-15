#!/usr/bin/env ruby
# encoding: utf-8
# ODDBOOState::Doctors::Doctor -- oddb -- 15.08.2012 -- yasaka@ywesee.com
# ODDB::State::Doctors::Doctor -- oddb -- 27.05.2003 -- mhuggler@ywesee.com

require 'state/doctors/global'
require 'view/doctors/doctor'

module ODDB
  module State
    module Doctors
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
      AcceptExperience.new(@session, exp)
    else
      self
    end
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
