#!/usr/bin/env ruby

cgi = CGI.new('html4Tr')
cgi.out {
	CGI.pretty(
	cgi.html {
		cgi.body {
=begin
			params = cgi.params.collect { |p| 
				p.join(': ')
			}.join('<br>')
			#Apache.request.server.log_alert(params)
=end
			methods = cgi.public_methods.sort.collect { |m|
				res = begin
					cgi.send(m)
				rescue Exception => e
					e.message
				end
				[m, res].join('=>')
			}.join('<br>')
=begin
			[
				:accept_encoding, 
				:server_name, 
				:server_protocol, 
				:user_agent, 
				:from, 
				:accept,
				:accept_encoding, 
				:accept_language,
				:user_agent, 
				:referer, 
				:pragma, 
			].collect { |m|
				[m,cgi.send(m)].join('=>')
			}.join("<br><br>\n\n")
=end
			#cgi.cookies.collect { |var| var.join('=>') }.join('<br>')
			#(Apache.request.methods - Object.new.methods).sort.join('<br>')
			#Apache.request.headers_in.collect { |var| var.join('=>') }.join('<br>')
		}
	})
}
