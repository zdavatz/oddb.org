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

    it "should work with Giotrif" do
      select_product_by_trademark('Giotrif')
      check_home_links
      link = @browser.links.find{|x| /patinfo.*seq\/02/.match(x.href)}
      link.click
      check_home_links
      link = @browser.link(:text => /Änderungen|Changements/)
      expect(link.visible?).to be true
      link.click
      check_home_links
      saved_url = @browser.url.to_s.clone
      saved_text = @browser.text
      link = @browser.link(:text => /Information/i)
      expect(link.visible?).to be true
      link.click
      check_home_links
    end

    it "should have a working link to Änderungen " do
      @browser.goto(OddbUrl + '/de/gcc/patinfo/reg/66343/seq/01/pack/001')
      check_home_links
      link = @browser.link(:text => /Änderungen|Changements/)
      expect(link.visible?).to be true
      link.click
      check_home_links
      saved_url = @browser.url.to_s.clone
      saved_text = @browser.text
      link = @browser.link(:text => /Information/i)
      expect(link.visible?).to be true
      link.click
      check_home_links
    end
  
  { 'Fachinformation'      => "/de/gcc/show/fachinfo/40501/diff",
    'Patienteninformation' => "/fr/gcc/show/patinfo/58081/01/002/diff"}.each do |type, diff_url|
    
    it "should have a working link to  #{type}information from the #{type} diff" do
      @browser.goto(OddbUrl + diff_url)
      check_home_links
      @browser.link(:text => Date_Regexp).wait_until_present(timeout: 3)
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
