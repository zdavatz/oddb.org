#!/usr/bin/env ruby
# OddbServer

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../..", File.dirname(__FILE__))

require 'drb/drb'
require 'util/oddbapp'
require 'etc/db_connection'

while arg = ARGV.shift
  case arg
  when '--detach'
    $detach = true
  when /^--pidfile=(.+)/
    $pidfile = $1
  else
    STDERR.puts "usage: #$0 [--detach] [--pidfile=PIDFILE] [--env]"
    exit 1
  end
end

if $pidfile
	if pidfile = open($pidfile, "w")
		pidfile.puts $$
		pidfile.close
		
		END { File.unlink $pidfile }
	end
end

if $detach
	puts "detaching"
  Process.fork and exit!(0)
  Process.setsid
  Process.fork and exit!(0)
  
  trap("INT") { }
end

#trap("HUP") { puts "caught HUP signal, shutting down\n"; exit }
trap("USR1") { 
	puts "caught USR1 signal, clearing Sessions\n"
	$oddb.clear 
}
trap("USR2") { 
	puts "caught USR2 signal, flushing stdout...\n"
	$stdout.flush
}
#trap("TERM") { puts "caught TERM signal, exiting immediately\n"; exit }

$oddb = ODDB::App.new

#require 'profile'

$0 = "Oddb (OddbApp)"

DRb.start_service(ODDB::SERVER_URI, $oddb)
#puts "drb-service started in #{seconds} seconds"

DRb.thread.join
