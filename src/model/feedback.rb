#!/usr/bin/env ruby
# encoding: utf-8
# Feedback -- oddb -- 02.11.2004 -- jlang@ywesee.com

require 'util/persistence'

module ODDB
	class Feedback
		include Persistence
    attr_accessor :name, :email, :message, :show_email, :experience,
      :recommend, :impression, :helps, :time
    attr_reader :item
		def init(app=nil)
			super
			@pointer.append(@oid)
		end
    def item=(item)
      if(@item.respond_to?(:remove_feedback))
        @item.remove_feedback(self)
      end
      if(item.respond_to?(:add_feedback))
        item.add_feedback(self)
      end
      @item = item
    end
	end
end
