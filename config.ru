#\ -w -p 8012
# 8012 is the port used to serve
# vim: ai ts=2 sts=2 et sw=2 ft=ruby
begin
  require 'pry'
rescue LoadError
end
$stdout.sync = true

lib_dir = File.expand_path(File.join(File.dirname(__FILE__), 'src').untaint)
$LOAD_PATH << lib_dir

require 'sbsm/logger'
require 'rubyntlm'
require 'net/ntlm'
require 'net/ntlm/version'

require 'util/currency'
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

ODBA.cache.setup
ODBA.cache.clean_prefetched

require 'rack'
require 'rack/static'
require 'rack/show_exceptions'
require 'rack'
require 'webrick'
SBSM.logger= ChronoLogger.new(ODDB.config.log_pattern)

use Rack::CommonLogger, SBSM.logger
use(Rack::Static, urls: ["/doc/"])
use Rack::ContentLength
SBSM.info "Starting Rack::Server with log_pattern #{ODDB.config.log_pattern}"

$stdout.sync = true
VERSION = `git rev-parse HEAD`
puts msg = "Used version: sbsm #{SBSM::VERSION} and oddb.org #{VERSION}"
SBSM.logger.info(msg)

my_app = ODDB::Util::RackInterface.new(app: ODDB::App.new)
app = Rack::ShowExceptions.new(Rack::Lint.new(my_app))
run app
