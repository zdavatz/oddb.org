#!/usr/bin/env ruby
# encoding: utf-8
# require 'simplecov'
# SimpleCov.start

require 'date'
require 'webdrivers'

RSpec.configure do |config|
  config.mock_with :flexmock
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

BreakIntoPry = false
STDOUT.sync = true
begin
  require 'pry'
rescue LoadError
  # ignore error for Travis-CI
end
$LOAD_PATH << File.join(File.dirname(File.dirname(__FILE__)), 'src')

for_running_in_irb = %(
require 'watir'; require 'pp'
homeUrl ||= "http://oddb-ci2.dyndns.org"
OddbUrl = homeUrl
@browser = Watir::Browser.new(:chrome)
@browser.goto OddbUrl
@browser.link(visible_text: 'Interaktionen').click
id = 'home_interactions'
medi = 'Losartan'
chooser = @browser.text_field(id: id)
)

Oddb_log_file ||= File.join("/var/www/oddb.org/log/oddb/debug/#{Date.today.year}/#{sprintf('%02d', Date.today.month)}.log")

require 'page-object'
require 'fileutils'
require 'page-object'
require 'fileutils'
require 'pp'
require 'watir'
require 'watir-scroll'
require 'minitest/spec/expect'

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
end
Browser2test = browsers2test
RegExpTwoMedis = /\/,?\d{13}[,\/]\d{13}(\?|)$/
RegExpOneMedi  = /\/,?\d{13}(\?|)$/
TwoMedis = [ 'Nolvadex', 'Losartan' ]
DownloadDir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'downloads'))
GlobAllDownloads  = File.join(DownloadDir, '*')
AdminUser         = ENV['admin_user'] || 'ngiger@ywesee.com'
AdminPassword     = ENV['admin_password']
A_USER_NAME       = 'Müller'
A_USER_FIRST_NAME = 'Cécile'
raise "Must define env variable admin_password" unless ENV['admin_password'] && AdminPassword.size > 0
ViewerUser        = 'info@desitin.ch'
ViewerPassword    = 'desitin'
LeeresResult      =  /hat ein leeres Resultat/
Date_Regexp = /\d{2}.\d{2}.\d{4}/

SNAP_IKSNR = 40501
SNAP_NAME = 'Lubex®'

def setup_browser
  return if @browser
  FileUtils.makedirs(DownloadDir)
  # drivers will be cached under $HOME/.webdrivers
  if Browser2test[0].to_s.eql?('firefox')
    Selenium::WebDriver::Firefox.path = '/usr/bin/firefox'
    require 'webdrivers/geckodriver'
    @browser_options = Selenium::WebDriver::Firefox::Options.new
  else
    Selenium::WebDriver::Chrome.path = '/usr/bin/google-chrome-beta'
    require 'webdrivers/chromedriver'
    puts "with webdrivers and using #{Selenium::WebDriver::Chrome.path}"
    @browser_options = Selenium::WebDriver::Chrome::Options.new
  end
  @browser_options.add_argument('--ignore-certificate-errors')
  @browser_options.add_argument('--disable-popup-blocking')
  @browser_options.add_argument('--disable-translate')
  prefs = {
    prompt_for_download: false,
    default_directory: DownloadDir
  }
  @browser_options.add_preference(:download, prefs)
  if Browser2test[0].to_s.eql?('firefox')
    puts "Setting upd default profile for firefox"
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['browser.download.dir'] = DownloadDir
    profile['browser.download.folderList'] = 2
    profile['browser.helperApps.alwaysAsk.force'] = false
    profile['security.insecure_password.ui.enabled'] = false
    profile['browser.helperApps.neverAsk.saveToDisk'] = "application/zip;application/octet-stream;application/x-zip;application/x-zip-compressed;text/csv;test/semicolon-separated-values"
    [ '/usr/bin/firefox-bin',  '/usr/bin/firefox'].each do |binary|
      if File.exist?(binary)
        Selenium::WebDriver::Firefox.path= binary
        puts "Using #{binary}"
        break
      end
    end
    # @browser_options.add_preference(:profile, profile)
    #@browser = Watir::Browser.new  :firefox
    pp @browser_options
    @browser = Watir::Browser.new :firefox,  options: @browser_options
  elsif Browser2test[0].to_s.eql?('chrome')
    puts "Setting up a default profile for chrome"
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
end

def login_link
  @browser.link(name: 'login_form')
end

def login(user = ViewerUser, password=ViewerPassword, remember_me=true)
  @saved_user ||= 'unbekannt'
  setup_browser
  @browser.goto OddbUrl
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
  # puts "Login with #{@browser.text_field(name: , 'email').value} and #{@browser.text_field(name: 'pass').value}"
  if remember_me
    @browser.checkbox(name: "remember_me").set
  else
    @browser.checkbox(name: "remember_me").clear
  end
  @browser.button(name: "login").click
  sleep 1 unless @browser.button(name: "logout").exists?
  if login_link.exists?
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
  logout_btn = @browser.link(name: 'logout')
  sleep(0.1) unless login_link.exists?
  return unless  logout_btn.exists?
  logout_btn.click
rescue Selenium::WebDriver::Error::ServerError => error
  puts "logout with error #{error}"
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
  plus_link =  @browser.link(name: 'search_instant')
  plus_link.click if plus_link.exist? && plus_link.present? && /Plus/i.match(plus_link.text)
  puts "Took #{(endTime - startTime).round} seconds for for #{OddbUrl} to be ready. First answer was after #{@seconds} seconds." if (endTime - startTime).round > 2
rescue => error
  puts "error #{error} visiting #{url}"
  raise error
  # require 'pry'; binding.pry
end

def small_delay
  sleep(0.1)
end

def createScreenshot(browser, added=nil)
  return
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

def select_product_by_trademark(name)
  if false
    @browser.goto create_url_for(name, 'st_sequence')
  else
    begin
      @browser.goto OddbUrl
      @browser.link(name: 'search_instant').click unless   @browser.link(name: 'search_instant').text.eql?('Instant')
      @browser.select_list(name: "search_type").select("Markenname")
      @browser.text_field(name: "search_query").set(name)
      small_delay; @browser.button(name: "search").click
    rescue => error
      # require 'pry'; binding.pry
    end
  end
  @text = @browser.text.clone
  return @text if LeeresResult.match(@text)
  begin
    if (res = @browser.element(id: 'ikscat_1').wait_until(&:present?))
      expect(@browser.url.index(OddbUrl).to_i).to eq 7
      expect(@browser.url.index("/de/gcc").to_i).not_to eq 0
    end
  rescue => error
  end
ensure
  @text = @browser.text.clone
end


def create_url_for(query, stype= 'st_combined')
  "#{OddbUrl}/de/gcc/search/zone/drugs/search_query/#{URI.encode(query)}/search_type/#{stype}"
end
