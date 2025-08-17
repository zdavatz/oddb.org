#!/usr/bin/env ruby
# encoding: utf-8
# require 'simplecov'
# SimpleCov.start
# begin  require 'debug'; rescue LoadError; end # ignore error when debug cannot be loaded

require 'date'
require 'page-object'
require 'fileutils'
require 'page-object'
require 'fileutils'
require 'watir'
require 'minitest/spec/expect'

RSpec.configure do |config|
  config.mock_with :flexmock
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.after :suite do
    $browser.close if $browser && !$browser.closed?
  end
end

STDOUT.sync = true
begin
  require 'debug'
rescue LoadError
  # ignore error for .github actions
end
$LOAD_PATH << File.join(File.dirname(File.dirname(__FILE__)), 'src')

ODDB_URL = ENV['ODDB_URL'] ? ENV['ODDB_URL'] : 'http://127.0.0.1:8012'
MAIN_SERVER_URL="https://ch.oddb.org"

def testing_ch_oddb_org
  ODDB_URL.eql?(MAIN_SERVER_URL)
end

PROJECT_ROOT = testing_ch_oddb_org ? "/var/www/oddb.org" : File.dirname(File.dirname(__FILE__))
Oddb_log_file ||= File.join(PROJECT_ROOT, "log/oddb/debug/#{Date.today.year}/#{sprintf('%02d', Date.today.month)}.log")

homeUrl ||= ENV['ODDB_URL']
homeUrl ||= "http://oddb-ci2.dyndns.org"
Flavor    = ODDB_URL.match(/just-medical/) ?  'just-medical' : 'gcc'
ImageDest = File.join(Dir.pwd, 'images')
FileUtils.makedirs(ImageDest, :verbose => true) unless File.exist?(ImageDest)

browsers2test ||= [ ENV['ODDB_BROWSER'] ] if ENV['ODDB_BROWSER']
browsers2test = [ :chrome ] unless browsers2test and browsers2test.size > 0 # could be any combination of :ie, :firefox,

Browser2test = browsers2test
RegExpTwoMedis = /\/,?\d{13}[,\/]\d{13}(\?|)$/
RegExpOneMedi  = /\/,?\d{13}(\?|)$/
TwoMedis = [ 'Nolvadex', 'Losartan' ]
DownloadDir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'downloads'))
GlobAllDownloads  = File.join(DownloadDir, '*')
ADMIN_USER         = ENV['admin_user'] || 'ngiger@ywesee.com'
ADMIN_PASSWORD     = ENV['admin_password']
A_USER_NAME       = 'Müller'
A_USER_FIRST_NAME = 'Cécile'
raise "Must define env variable ADMIN_PASSWORD" unless ENV['admin_password'] && ADMIN_PASSWORD.size > 0
ViewerUser        = 'info@desitin.ch'
ViewerPassword    = 'desitin'
LeeresResult      =  /hat ein leeres Resultat/
Date_Regexp = /\d{2}.\d{2}.\d{4}/

SNAP_IKSNR = 40501
SNAP_NAME = 'Lubex®'

def setup_browser
  return if @browser && !@browser.closed?
  FileUtils.makedirs(DownloadDir)
  # drivers will be cached under $HOME/.webdrivers
  if Browser2test[0].to_s.eql?('firefox')
    browser_path = `which firefox`
    if browser_path.length > 0
      Selenium::WebDriver::Firefox.path =  browser_path.chomp
    else
      Selenium::WebDriver::Firefox.path = '/usr/bin/firefox'
    end
    require 'webdrivers/geckodriver'
    @browser_options = Selenium::WebDriver::Firefox::Options.new
  else
    browser_path = `which chromium`
    if browser_path.length > 0
      Selenium::WebDriver::Chrome.path = browser_path.chomp
    else
      Selenium::WebDriver::Chrome.path = '/usr/bin/google-chrome-beta'
    end
    @browser_options = Selenium::WebDriver::Chrome::Options.new
  end
  @browser_options.add_argument('--disable-popup-blocking')
  @browser_options.add_argument('--disable-translate')
  prefs = [
    prompt_for_download: false,
    default_directory: DownloadDir
  ]

  @browser_options.add_preference(:download, prefs)
  if Browser2test[0].to_s.eql?('firefox')
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['browser.download.dir'] = DownloadDir
    profile['browser.download.folderList'] = 2
    profile['browser.default_directory.dir'] = DownloadDir
    profile['browser.download.prompt_for_download'] = false
    profile['browser.download.directory_upgrade'] = true
    profile['browser.download.folderList'] = 2
    profile['browser.helperApps.alwaysAsk.force'] = false
    profile['security.insecure_password.ui.enabled'] = false
    profile['browser.helperApps.neverAsk.saveToDisk'] = "application/zip;application/octet-stream;application/x-zip;application/x-zip-compressed;text/csv;test/semicolon-separated-values,application/pd"
    [ '/usr/bin/firefox-bin',  '/usr/bin/firefox'].each do |binary|
      if File.exist?(binary)
        Selenium::WebDriver::Firefox.path= binary
        break
      end
    end
    browser_opts = {accept_insecure_certs: true,
                page_load_timeout: 100,
                script_timeout: 30}
    @browser = Watir::Browser.new :firefox, options: {profile: profile}

  elsif Browser2test[0].to_s.eql?('chrome')
    Selenium::WebDriver::Chrome.path = `which chromium`.chomp
    @browser = Watir::Browser.new :chrome, options: @browser_options
    Selenium::WebDriver::Chrome::Options #add_preference
  elsif Browser2test[0].to_s.eql?('ie')
    puts "Trying unknown browser type Internet Explorer"
    @browser = Watir::Browser.new :ie
  else
    puts "Trying unknown browser type #{Browser2test[0]}"
    @browser = Watir::Browser.new Browser2test[0]
  end
  Watir.default_timeout = 5

  $browser = @browser
end

def login_link
  @browser.link(name: 'login_form')
end

def login(user = ViewerUser, password=ViewerPassword, remember_me=true)
  @saved_user ||= 'unbekannt'
  setup_browser
  @browser.goto ODDB_URL
  sleep 0.5 unless login_link.exists?
  if @saved_user.eql?(user) &&
      login_link.exists? &&
      !login_link.present?
    return true
  end
  logout unless login_link.exist? && login_link.present?
  login_link.click
  @browser.text_field(name: 'email').set(user)
  @browser.text_field(name: 'pass').set(password)
  if remember_me
    @browser.checkbox(name: "remember_me").set
  else
    @browser.checkbox(name: "remember_me").clear
  end
  @browser.button(name: "login").click
  if login_link.exists?
    @browser.goto(ODDB_URL)
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
  @browser.goto ODDB_URL
  logout_btn = @browser.link(name: 'logout')
  sleep(0.1) unless login_link.exists?
  return unless  logout_btn.exists?
  logout_btn.click
rescue Selenium::WebDriver::Error::ServerError => error
  puts "logout with error #{error}"
end

def waitForOddbToBeReady(browser = nil, url = ODDB_URL, maxWait = 30)
  setup_browser
  startTime = Time.now
  @seconds = -1
  0.upto(maxWait).each{
    |idx|
   @browser.goto ODDB_URL
    if /Internal Server Error/.match(@browser.text)
      raise "InternalServerError"
    end
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
  plus_link =  @browser.link(name: 'search_instant')
  plus_link.click if plus_link.exist? && plus_link.present? && /Plus/i.match(plus_link.text)
  puts "Took #{(endTime - startTime).round} seconds for for #{ODDB_URL} to be ready. First answer was after #{@seconds} seconds." if (endTime - startTime).round > 2
rescue => error
  puts "error #{error} visiting #{url}"
#  binding.break
  raise error
end

def createScreenshot(browser, added=nil)
  return
  if browser.url.index('?')
    name = File.join(ImageDest, File.basename(browser.url.split('?')[0]).gsub(/\W/, '_'))
  else
    name = File.join(ImageDest, browser.url.split('/')[-1].gsub(/\W/, '_'))
  end
  name = "#{name}#{added}.png"
  browser.screenshot.save (name)
  puts "createScreenshot: #{name} done" if $VERBOSE
end

def run_bin_admin(cmd)
  ENV['RUBYOPT']=nil
  # puts "running bin/admin #{cmd}"
  bin_admin_file = "#{PROJECT_ROOT}/bin/admin"
  skip "bin/admin not found" unless File.exist?(bin_admin_file)
  bin_admin = "/usr/bin/env ruby #{bin_admin_file}"
  full_cmd = "/usr/bin/env echo \"#{cmd}\" | #{bin_admin}"
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

def is_link_valid?(url)
  uri = URI.parse url
  res = Net::HTTP.start(uri.host, uri.port, {read_timeout: 1, open_timeout: 1})
  return !res.nil?
end

def select_product_by_trademark(name)
  begin
    @browser.goto ODDB_URL
    @browser.link(name: 'search_instant').click unless   @browser.link(name: 'search_instant').text.eql?('Instant')
    @browser.select_list(name: "search_type").select("Markenname")
    @browser.text_field(name: "search_query").set(name)
    @browser.button(name: "search").wait_until(&:present?)
    @browser.button(name: "search").click
  rescue => error
  end
  @text = @browser.text.clone
  return @text if LeeresResult.match(@text)
  begin
    if (res = @browser.element(id: 'ikscat_1').wait_until(&:present?))
      expect(@browser.url.index(ODDB_URL).to_i).to eq 7
      expect(@browser.url.index("/de/gcc").to_i).not_to eq 0
    end
  rescue => error
  end
ensure
  @text = @browser.text.clone
end

def create_url_for(query, stype= 'st_combined')
  "#{ODDB_URL}/de/gcc/search/zone/drugs/search_query/#{URI.encode(query)}/search_type/#{stype}"
end

def enter_search_to_field_by_name(search_text, field_name)
  @browser.text_field(name: field_name).wait_until(&:present?)
  chooser = @browser.text_field(name: field_name)
  chooser.set(search_text)
  chooser.send_keys(:enter)
  @browser.link(name: 'preferences').wait_until(&:present?)
  expect(@browser.text).not_to match LeeresResult
end
