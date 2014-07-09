#!/usr/bin/env ruby
# encoding: utf-8
require 'simplecov'
SimpleCov.start

if RUBY_PLATFORM.match(/mingw/)
  require 'watir'
  browsers2test = [ :ie ]
else
  browsers2test ||= [ ENV['ODDB_BROWSER'] ] if ENV['ODDB_BROWSER']
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
ImageDest = File.join(Dir.pwd, 'images')
FileUtils.makedirs(ImageDest, :verbose => true) unless File.exists?(ImageDest)

Browser2test = browsers2test
RegExpTwoMedis = /\/\d{13},\d{13}(\?|)$/
RegExpOneMedi  = /\/\d{13}(\?|)$/
TwoMedis = [ 'Nolvadex', 'Losartan' ]

def login(user = 'ngiger@ywesee.com', password='ng1234')
  @browser = Watir::Browser.new(browsers2test[0]) unless @browser
  @browser.goto OddbUrl
  return unless  @browser.link(:text=>'Anmeldung').exists?
  @browser.link(:text=>'Anmeldung').click
  @browser.text_field(:name, 'email').set(user)
  @browser.text_field(:name, 'pass').set(password)
  @browser.button(:value,"Anmelden").click
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
  0.upto(maxWait).each{
    |idx|
    browser.goto OddbUrl
    break unless /Es tut uns leid/.match(browser.text)
    if idx == 0
      $stdout.write "Waiting max #{maxWait} seconds for #{url} to be ready"; $stdout.flush
    else
      $stdout.write('.'); $stdout.flush
    end
    sleep 1
  }
  endTime = Time.now
  @browser.link(:text=>'Plus').click if @browser.link(:text=>'Plus').exists?
  puts "Took #{(endTime - startTime).round} seconds for for #{OddbUrl} to be ready" if (endTime - startTime).round > 2
end

def createScreenshot(browser, added=nil)
  if browser.url.index('?')
    name = File.join(ImageDest, File.basename(browser.url.split('?')[0]))
  else
    name = File.join(ImageDest, browser.url.split('/')[-1])
  end
  name = "#{name}#{added}.png"
  browser.screenshot.save (name)
  puts "createScreenshot: #{name} done" if $VERBOSE
end

