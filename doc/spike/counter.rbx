#!/usr/bin/env ruby
# Counter
require 'cgi/session'
require 'drb/drb'

DRb.start_service

cgi = CGI.new("html4Tr")
properties = {
    "session_key"       =>  "counter",
}
session = CGI::Session.new(cgi, properties)
begin
counter = DRbObject.new(nil, "druby://localhost:7640")
#str = "goodbye world" 
session["my_id"] ||= rand(0).to_s
counter.out(cgi, session["my_id"])
=begin
cgi.out {
        cgi.html {
            cgi.center { 
                "hello world<br>" +
                session["my_id"] +
                "<br>" + 
                counter.next(session["my_id"]).to_s +
                "<br>" + 
                counter.last(session["my_id"]).to_s +
                "<br>" + 
                counter.next(session["my_id"]).to_s
            }
        }
    #session.to_s
    #p session["my_id"].to_s
    #p 
    #p counter.last(session["my_id"]).to_s
    #p counter.next(session["my_id"]).to_s
}
=end
ensure
session.close
end
