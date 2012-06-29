#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::AssignDivision -- oddb.org -- 29.06.2012 -- yasaka@ywesee.com

require 'state/global_predefine'
require 'state/admin/assign_deprived_sequence'
require 'view/admin/assign_division'

module ODDB
  module State
    module Admin
class AssignDivision < AssignDeprivedSequence
  VIEW = View::Admin::AssignDivision
  def assign
    input = @session.user_input :pointer_list
    pointers = input.values.map do |p_str|
      if match = p_str.match(/\:\!registration,(\d+)\!sequence,(\d+)\./)
        if reg = match.to_a[1] and seq = match.to_a[2] \
          and sequence = @session.app.registration(reg).sequence(seq)
            sequence.pointer
        end
      end
    end if input
    if pointers \
       && pointers.any? { |pointer| !allowed?(pointer.resolve(@session)) }
      @errors.store(
        :pointers,
        create_error('e_not_allowed', :pointers, nil)
      )
    end
    unless error?
      args = { :division => nil }
      if div = @model.sequence.division
        args.store(:division, div.pointer)
      end
      pointers.each do |pointer|
        @session.app.update pointer, args, unique_email
      end
    end
    self
  end
  def assign_deprived_sequence
    if allowed?(@model.sequence) &&
       !@session.error? && 
       (pointer = @session.user_input(:division_pointer))
      @session.app.update(@model.pointer, {:division => pointer}, unique_email)
      @previous
    else
      err = create_error(:e_no_sequence_selected, :pointers, nil)
      @errors.store(:pointers, err)
      self
    end
  end
end
    end
  end
end

