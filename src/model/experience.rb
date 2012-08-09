#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Experience -- oddb -- 09.08.2012 -- yasaka@ywesee.com

require 'util/persistence'

module ODDB
  class Experience
    include Persistence
    attr_accessor :title, :description, :hidden, :time
    attr_reader :doctor
    def initialize
      @title = ''
      @description = ''
      @hidden = true
      @time = Time.now
      super
    end
    def init(app)
      @pointer.append(@oid)
    end
    def doctor=(doctor)
      if(@doctor.respond_to?(:remove_experience))
        @doctor.remove_experience(self)
      end
      if(doctor.respond_to?(:add_experience))
        doctor.add_experience(self)
      end
      @doctor = doctor
    end
  end
end
