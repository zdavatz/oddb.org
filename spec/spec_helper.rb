#!/usr/bin/env ruby
# encoding: utf-8

require 'watir-webdriver'
require 'page-object'
require 'fileutils'
require 'pp'

homeUrl ||= ENV['ODDB_URL']
homeUrl ||= "172.25.1.75"
OddbUrl = homeUrl
ImageDest = File.join(Dir.pwd, 'images')
FileUtils.makedirs(ImageDest, :verbose => true) unless File.exists?(ImageDest)
browsers2test ||= [ ENV['ODDB_BROWSER'] ]
browsers2test ||= [ :firefox ] # could be any combination of :ie, :firefox, :chrome
Browser2test = browsers2test

def waitForOddbToBeReady(browser = Browser2test, url = OddbUrl, maxWait = 30)
  0.upto(maxWait).each{
    |idx|
    browser.goto OddbUrl
    break unless /Es tut uns leid/.match(browser.text)
    puts "Waiting #{idx} of max #{maxWait} for #{url} to be ready"
    sleep 1
  }
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

