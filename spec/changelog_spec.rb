#!/usr/bin/env ruby
require 'spec_helper'

@workThread = nil

describe "ch.oddb.org change_log" do

  before :all do
    @idx = 0
    waitForOddbToBeReady(@browser, OddbUrl)
    login(ViewerUser,  ViewerPassword)
  end

  before :each do
    @browser.goto OddbUrl
  end

  after :each do
    @idx += 1
    @browser.goto OddbUrl
  end


  def check_home_links
    @browser.links.find_all{|x| x.text.eql? 'Home' }.each do |link|
      home_pattern = /\/home|/
      expect(link.exist?).to be true
      expect(link.href).to match home_pattern
    end
  end

  { 'Fachinformation'      => "/de/gcc/show/fachinfo/40501/diff",
    'Patienteninformation' => "/fr/gcc/show/patinfo/66418/01/001/diff"}.each do |type, diff_url|
    it "should have a working link to Änderungen from the #{type} diff" do
      @browser.goto(OddbUrl + diff_url)
      check_home_links
      link = @browser.link(:text => Date_Regexp)
      expect(link.visible?).to be true
      saved_url = @browser.url.to_s.clone
      saved_text = @browser.text
      link.click
      check_home_links
      link = @browser.link(:text => /Änderungen|Changements/)
      expect(link.visible?).to be true
      link.click
      check_home_links
      expect(@browser.url.to_s).to eql saved_url.to_s
      expect(@browser.text[0..100]).to eql saved_text[0..100]
      expect(@browser.text).to eql saved_text
    end
    
    it "should have a working link to  #{type}information from the #{type} diff" do
      @browser.goto(OddbUrl + diff_url)
      check_home_links
      link = @browser.link(:text => Date_Regexp)
      expect(link.visible?).to be true
      saved_url = @browser.url.to_s.clone
      saved_text = @browser.text
      link.click
      check_home_links
      link = @browser.link(:text => /Information/i)
      expect(link.visible?).to be true
      link.click
      saved_text2 = @browser.text
      if  /Pat/i.match(type)
        expect(saved_text2.match(/Home.* Information.*patient/)).not_to be nil
      else
        expect(saved_text2.match(/Home.* #{type}/)).not_to be nil
      end
      expect(/L'information demandée n'est malheureusement plus accessible./.match(saved_text2)).to be nil
      check_home_links
    end
  end

  after :all do
    @browser.close
  end
end
