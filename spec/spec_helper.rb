#!/usr/bin/env ruby
# encoding: utf-8
require 'simplecov'
SimpleCov.start

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

BreakIntoPry = false
require 'pry' if BreakIntoPry
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

if RUBY_PLATFORM.match(/mingw/)
  require 'watir'
  browsers2test = [ :ie ]
else
  browsers2test ||= [ ENV['ODDB_BROWSER'] ] if ENV['ODDB_BROWSER']
#  browsers2test = [ :firefox ]
  browsers2test = [ :chrome ] unless browsers2test and browsers2test.size > 0 # could be any combination of :ie, :firefox, :chrome
  require 'watir-webdriver'
end
require 'page-object'
require 'fileutils'
require 'page-object'
require 'fileutils'
require 'pp'

homeUrl ||= ENV['ODDB_URL']
homeUrl ||= "http://oddb-ci2.dyndns.org"
OddbUrl = homeUrl
Flavor    = OddbUrl.match(/just-medical/) ?  'just-medical' : 'gcc'
ImageDest = File.join(Dir.pwd, 'images')
FileUtils.makedirs(ImageDest, :verbose => true) unless File.exists?(ImageDest)

Browser2test = browsers2test
RegExpTwoMedis = /\/,?\d{13}[,\/]\d{13}(\?|)$/
RegExpOneMedi  = /\/,?\d{13}(\?|)$/
TwoMedis = [ 'Nolvadex', 'Losartan' ]
DownloadDir = File.join(Dir.home, 'Downloads')
GlobAllDownloads  = File.join(DownloadDir, '*')
AdminUser         = 'ngiger@ywesee.com'
AdminPassword     = 'ng1234'
    
def login(user = AdminUser, password=AdminPassword, remember_me=false)
  @browser = Watir::Browser.new(browsers2test[0]) unless @browser
  @browser.goto OddbUrl
  return true unless  @browser.link(:text=>'Anmeldung').exists?
  @browser.link(:text=>'Anmeldung').click
  @browser.text_field(:name, 'email').set(user)
  @browser.text_field(:name, 'pass').set(password)
  if remember_me
    @browser.checkbox(:name, "remember_me").set
  else
    @browser.checkbox(:name, "remember_me").clear
  end
  @browser.button(:name,"login").click
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
  @browser = Watir::Browser.new(browsers2test[0]) unless @browser
  @browser.goto OddbUrl
  return unless  @browser.link(:text=>'Abmeldung').exists?
  @browser.link(:text=>'Abmeldung').click
end

def waitForOddbToBeReady(browser = nil, url = OddbUrl, maxWait = 30)
  unless browser
    browser = Watir::Browser.new(Browser2test[0])
    @browser = browser
  end
  startTime = Time.now
  @seconds = -1
  0.upto(maxWait).each{
    |idx|
    browser.goto OddbUrl
    unless /Es tut uns leid/.match(browser.text)
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
  @browser.link(:text=>'Plus').click if @browser.link(:text=>'Plus').exists?
  puts "Took #{(endTime - startTime).round} seconds for for #{OddbUrl} to be ready. First answer was after #{@seconds} seconds." if (endTime - startTime).round > 2
end

def createScreenshot(browser, added=nil)
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