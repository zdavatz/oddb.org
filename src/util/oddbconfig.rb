#!/usr/bin/env ruby
# OddbConfig -- oddb -- 09.04.2003 -- hwyss@ywesee.com 

# Do not require any Application-Internals in this file
require 'drb'

module DRb
	class DRbConn
		remove_const :POOL_SIZE
		POOL_SIZE = 4
	end
end

module ODDB
	SERVER_NAME = 'www.oddb.org'
	SERVER_URI = "druby://localhost:10000"
	FIPARSE_URI = "druby://localhost:10002"
	FIPDF_URI = "druby://localhost:10003"
	DOCPARSE_URI = "druby://localhost:10004"
	PROJECT_ROOT = File.expand_path('../..', File.dirname(__FILE__))
end
