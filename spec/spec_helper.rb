#!/usr/bin/env ruby
# encoding: utf-8
# require 'simplecov'
# SimpleCov.start

RSpec.configure do |config|
  config.mock_with :flexmock
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

BreakIntoPry = false
begin
  require 'pry'
rescue LoadError
  # ignore error for Travis-CI
end
$LOAD_PATH << File.join(File.dirname(File.dirname(__FILE__)), 'src')

for_running_in_irb = %(
require 'watir'; require 'pp'
homeUrl ||= "oddb-ci2.dyndns.org"
OddbUrl = homeUrl
@browser = Watir::Browser.new(:chrome)
@browser.goto OddbUrl
@browser.link(:text=>'Interaktionen').click
id = 'home_interactions'
medi = 'Losartan'
chooser = @browser.text_field(:id, id)
)

Oddb_log_file ||= File.join("/var/www/oddb.org/log/oddb/debug/#{Date.today.year}/#{sprintf('%02d', Date.today.month)}.log")

require 'page-object'
require 'fileutils'
require 'page-object'
require 'fileutils'
require 'pp'
require "watir-webdriver/wait"

homeUrl ||= ENV['ODDB_URL']
homeUrl ||= "http://oddb-ci2.dyndns.org"
OddbUrl = homeUrl
Flavor    = OddbUrl.match(/just-medical/) ?  'just-medical' : 'gcc'
ImageDest = File.join(Dir.pwd, 'images')
FileUtils.makedirs(ImageDest, :verbose => true) unless File.exists?(ImageDest)

if RUBY_PLATFORM.match(/mingw/)
  require 'watir'
  browsers2test = [ :ie ]
else
  browsers2test ||= [ ENV['ODDB_BROWSER'] ] if ENV['ODDB_BROWSER']
  browsers2test = [ :chrome ] unless browsers2test and browsers2test.size > 0 # could be any combination of :ie, :firefox, :chrome
  require 'watir-webdriver'
end
Browser2test = browsers2test
RegExpTwoMedis = /\/,?\d{13}[,\/]\d{13}(\?|)$/
RegExpOneMedi  = /\/,?\d{13}(\?|)$/
TwoMedis = [ 'Nolvadex', 'Losartan' ]
DownloadDir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'downloads'))
GlobAllDownloads  = File.join(DownloadDir, '*')
AdminUser         = 'ngiger@ywesee.com'
AdminPassword     = 'ng1234'
ViewerUser        = 'info@desitin.ch'
ViewerPassword    = 'desitin'
LeeresResult      =  /hat ein leeres Resultat/
SNAP_IKSNR = 40501
SNAP_NAME = 'Lubex®'

def setup_browser
  return if @browser
  FileUtils.makedirs(DownloadDir)
  if Browser2test[0].to_s.eql?('firefox')
    puts "Setting upd default profile for firefox"
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['browser.download.dir'] = DownloadDir
    profile['browser.download.folderList'] = 2
    profile['browser.helperApps.alwaysAsk.force'] = false
    profile['browser.helperApps.neverAsk.saveToDisk'] = "application/zip;application/octet-stream;application/x-zip;application/x-zip-compressed;text/csv;test/semicolon-separated-values"

    @browser = Watir::Browser.new :firefox, :profile => profile
  elsif Browser2test[0].to_s.eql?('chrome')
    puts "Setting up a default profile for chrome"
    prefs = {
      :download => {
        :prompt_for_download => false,
        :default_directory => DownloadDir
      }
    }
    @browser = Watir::Browser.new :chrome, :prefs => prefs
  elsif Browser2test[0].to_s.eql?('ie')
    puts "Trying unknown browser type Internet Explorer"
    @browser = Watir::Browser.new :ie
  else
    puts "Trying unknown browser type #{Browser2test[0]}"
    @browser = Watir::Browser.new Browser2test[0]
  end
end

def login(user = ViewerUser, password=ViewerPassword, remember_me=false)
  setup_browser
  @browser.goto OddbUrl
  sleep 0.5
  sleep 0.5 unless @browser.link(:name =>'login_form').exists?
  return true unless  @browser.link(:text=>'Anmeldung').exists?
  @browser.link(:text=>'Anmeldung').when_present.click
  @browser.text_field(:name, 'email').when_present.set(user)
  @browser.text_field(:name, 'pass').when_present.set(password)
  # puts "Login with #{@browser.text_field(:name, 'email').value} and #{@browser.text_field(:name, 'pass').value}"
  if remember_me
    @browser.checkbox(:name, "remember_me").set
  else
    @browser.checkbox(:name, "remember_me").clear
  end
  @browser.button(:name,"login").click
  sleep 1 unless @browser.button(:name,"logout").exists?
  if  @browser.button(:name,"login").exists?
    @browser.goto(OddbUrl)
    return false
  else
    return true
  end
end

def get_session_timestamp
  @@timestamp ||= Time.now.strftime('%Y%m%d_%H%M%S')
end

def logout
  setup_browser
  @browser.goto OddbUrl
  sleep(0.1) unless @browser.link(:name=>'logout').exists?
  logout_btn = @browser.link(:name=>'logout')
  return unless  logout_btn.exists?
  logout_btn.click
end

def waitForOddbToBeReady(browser = nil, url = OddbUrl, maxWait = 30)
  setup_browser
  startTime = Time.now
  @seconds = -1
  0.upto(maxWait).each{
    |idx|
   @browser.goto OddbUrl; small_delay
    unless /Es tut uns leid/.match(@browser.text)
      @seconds = idx
      break
    end
    if idx == 0
      $stdout.write "Waiting max #{maxWait} seconds for #{url} to be ready"; $stdout.flush
    else
      $stdout.write('.'); $stdout.flush
    end
    sleep 1
  }
  endTime = Time.now
  sleep(0.2)
  @browser.link(:text=>'Plus').click if @browser.link(:text=>'Plus').exists?
  puts "Took #{(endTime - startTime).round} seconds for for #{OddbUrl} to be ready. First answer was after #{@seconds} seconds." if (endTime - startTime).round > 2
end

def small_delay
  sleep(0.1)
end

def createScreenshot(browser, added=nil)
  small_delay
  if browser.url.index('?')
    name = File.join(ImageDest, File.basename(browser.url.split('?')[0]).gsub(/\W/, '_'))
  else
    name = File.join(ImageDest, browser.url.split('/')[-1].gsub(/\W/, '_'))
  end
  name = "#{name}#{added}.png"
  browser.screenshot.save (name)
  puts "createScreenshot: #{name} done" if $VERBOSE
end

def set_zsr_of_doctor(zsr_id, name = 'Davatz', field_name = 'prescription_zsr_id')
  corrected = zsr_id.gsub(/[ \.]/, '');
  zsr_field = @browser.text_field(:name => field_name)
  zsr_field.set zsr_id
  zsr_field.send_keys :enter
  startTime = Time.now
  while (Time.now - startTime) < 30
    fieldOkay =  zsr_field.value == corrected
    foundName = @browser.text.index(name)
    if (fieldOkay or zsr_field.value == zsr_id) and foundName
      break
    end
    # $stderr.puts "val #{zsr_field.value} #{Time.now - startTime} cond #{fieldOkay} foundName #{foundName.inspect}"
    zsr_field.send_keys :enter if fieldOkay
    sleep(1)
  end
end

def run_bin_admin(cmd)
  ENV['RUBYOPT']=nil
  # puts "running bin/admin #{cmd}"
  bin_admin = "/usr/local/bin/ruby /var/www/oddb.org/bin/admin"
  full_cmd = "/bin/echo \"#{cmd}\" | #{bin_admin}"
  return `#{full_cmd}`
end

# returns downloaded_files
def check_download(element_to_click)
  nrWindowsBeforeDownload = @browser.windows.size
  filesBeforeDownload =  Dir.glob(GlobAllDownloads)
  element_to_click.click
  @browser.windows.last.close if @browser.windows.size > nrWindowsBeforeDownload
  sleep 1 if Dir.glob(GlobAllDownloads).size == filesBeforeDownload.size
  filesAfterDownload =  Dir.glob(GlobAllDownloads)
  diffFiles = filesAfterDownload - filesBeforeDownload
end
