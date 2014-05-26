#!/usr/bin/env ruby
# encoding: utf-8
# Simple stub for for the mail gem

module Mail
	class Message
		attr_reader :has_content_type, :multipart, :inspect
		def initialize(param)
		end
		def []
			self
		end
			def add
		end
	end
end
