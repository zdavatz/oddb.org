#!/usr/bin/env ruby

require 'zlib'

cgi = CGI.new
headers = {}
output = if(cgi.accept_encoding && cgi.accept_encoding.index('deflate'))
	headers.store("Content-Encoding", "gzip")
	Zlib::Deflate.deflate("Hello Small World\n")
else
	"Hello Big World\n"
end

cgi.out(headers) { output }
