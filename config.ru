#!/usr/bin/env ruby
# vim: ai ts=2 sts=2 et sw=2 ft=ruby
begin
  require 'pry'
rescue LoadError
end
$stdout.sync = true
$stdout.puts "#{Time.now} Starting #{$0}"

lib_dir = File.expand_path(File.join(File.dirname(__FILE__), 'src'))
$LOAD_PATH << lib_dir

begin # with a rescue
  require 'sbsm/logger'
  require 'rubyntlm'
  require 'net/ntlm'
  require "config"

  server_uri = ODDB::SERVER_URI
  case APPNAME
  when /google(-|_)crawler/i
    server_uri = ODDB::SERVER_URI_FOR_GOOGLE_CRAWLER
    process = :google_crawler
    $0 = "Oddb (OddbApp:Google-Crawler)"
  when 'crawler'
    server_uri = ODDB::SERVER_URI_FOR_CRAWLER
    process = :crawler
    $0 = "Oddb (OddbApp:Crawler)"
  else
    server_uri = nil
    process = APPNAME.to_sym
    $0 = "Oddb (OddbApp:#{APPNAME.capitalize})"
  end if defined?(APPNAME) && APPNAME
  process ||= :oddb
  if (m = /p\s(\d+)/.match(ENV['SUDO_COMMAND']))
    port =  m[1]
  end

  load 'config.rb'

  ODDB.config.log_pattern.gsub!('app', process.to_s)
  SBSM.logger= ChronoLogger.new(ODDB.config.log_pattern)
  # We want to redirect the standard error also to the logger
  # next line found via https://stackoverflow.com/questions/9637092/redirect-stderr-to-logger-instance
  $stderr.reopen SBSM.logger.instance_variable_get(:@logdev).dev

  SBSM.logger.level = Logger::WARN

  unless defined?(MiniTest) # do real startup
    require 'util/oddbapp'
    require 'util/rack_interface'
    require 'etc/db_connection'

    File.open("/proc/#{Process.pid}/oom_adj", 'w') do |fh|
      fh.puts "15"
    end

    trap("USR1") {
      puts "caught USR1 signal, clearing Sessions\n"
      $oddb.clear
    }
    trap("USR2") {
      puts "caught USR2 signal, flushing stdout...\n"
      $stdout.flush
    }

    require 'rack'
    require 'rack/static'
    require 'rack/show_exceptions'
    require 'rack'
    require 'webrick'
    require "clogger"
    Rack_And_UserAgent = "$ip - $remote_user [$time_local{%d/%b/%Y %H:%M:%S}] " \
                '"$request" $status $response_length $request_time{4}  "$http_user_agent"'

    use Clogger,
        # ours is Combined + $request_time
        #  LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"" combined
        :format =>  Rack_And_UserAgent,
        :logger => SBSM.logger,
        :reentrant => true
    use Clogger, :logger=> $stdout, :reentrant => true
    use(Rack::Static, urls: ["/doc/"])
    use Rack::ContentLength
    SBSM.warn "Starting Rack::Server with log_pattern #{ODDB.config.log_pattern}"

    $stdout.sync = true
    VERSION = `git rev-parse HEAD`
    SBSM.logger.info("process #{process} port #{port} on #{server_uri} sbsm #{SBSM::VERSION} and oddb.org #{VERSION}")


    my_app = ODDB::Util::RackInterface.new(app: ODDB::App.new(server_uri: server_uri, process: process))
  end
rescue => error
  puts "error in startup: #{error}"
  puts "error in startup: #{error.backtrace[0..10].join("\n")}"
  exit(1)
end

unless defined?(MiniTest) # do real startup
  app = Rack::ShowExceptions.new(Rack::Lint.new(my_app))
  run app
end
