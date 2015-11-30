#!/usr/bin/env ruby
# encoding: utf-8
require 'spec_helper'

@workThread = nil

describe "ch.oddb.org snapback" do
 
 before :all do
  @idx = 0
  waitForOddbToBeReady(@browser, OddbUrl)
 end

 before :each do
  @browser.goto OddbUrl
 end

 after :each do
  @idx += 1
  createScreenshot(@browser, '_'+@idx.to_s)
  # sleep
  @browser.goto OddbUrl
 end

 SnapbackTestStep = Struct.new(:search_type, :search_value, :link_to_click, :expect_url, :expect_snapback_text, :next_step)
 TODO = true
 Search_URL=  TODO ? /search_query\/58392|de\/gcc$|home_drugs\/$/ : /search_query\/58392/
 Search_Snap = /Sie befinden sich in - ,58392,01,001/
 Search_SnapBack = TODO ?  /Suchresultat|Home/ : 'Suchresultat'
 FI_url  = 'de/gcc/fachinfo/reg/58392'
 FI_Snap = TODO ? /Sie befinden sich in - ,Fachinformation zu Losartan Actavis|Sie befinden sich in - ,Suchresultat,Fachinformation zu Losartan Actavis/ :
              /Sie befinden sich in - ,Suchresultat,Fachinformation zu Losartan Actavis/

 test_1_6 = SnapbackTestStep.new( nil, nil, 'PI',
      'de/gcc/patinfo/reg/58392/seq/01',
      /Sie befinden sich in - Home,Patienteninformation zu Losartan/,
      nil)
 test_1_5 = SnapbackTestStep.new( nil, nil, Search_SnapBack, Search_URL, Search_Snap, test_1_6)
 test_1_4 = SnapbackTestStep.new( nil, nil, 'FI', FI_url, FI_Snap, test_1_5)
 test_1_3 = SnapbackTestStep.new( nil, nil, Search_SnapBack, Search_URL, Search_Snap, test_1_4)
 test_1_2 = SnapbackTestStep.new( nil, nil, 'FI', FI_url, FI_Snap, test_1_3)
 FirstTest = SnapbackTestStep.new(/Swissmedic/, '58392', nil,  Search_URL, Search_Snap, test_1_2)
 Snapback_Registration = { '63184' => 'Celecoxib Helvepharm'}
 FI_Link = /\/fachinfo\/swissmedicnr\/(\d+)$/
 class SnapbackTestStep
  def to_s
   "Search #{search_type} #{search_value} link: #{link_to_click} #{expect_url} #{expect_snapback_text} #{@next_step.class}"
  end
 end
 it "should work follow correctly the expected paths" do
  login(ViewerUser,  ViewerPassword)
  if @browser.link(:name, 'drugs').exists?
   @browser.link(:name, 'drugs').click; small_delay
  end
  nr = 0
  current= FirstTest
  prev_url = nil
  while current
   nr += 1
   puts "Running test step #{nr}"
   puts current.to_s
   if current.link_to_click
    puts "Clicking link #{current.link_to_click} -> #{@browser.link(:text => current.link_to_click).href}"
    @browser.link(:text => current.link_to_click).click
   elsif  current.search_value
    puts "Searching #{current.search_type} for #{ current.search_value}"
    @browser.text_field(:name, "search_query").value = current.search_value
    @browser.select_list(:name, "search_type").select(current.search_type)
   end
   puts "#{__LINE__}: Got URL #{@browser.url}"
   puts " Should #{current.expect_url}"
   expect(@browser.url).to match current.expect_url
   check_pointer_steps(current.expect_snapback_text)
   # TODO: Use @browser.back and @browser.forward to test previous and next url
   prev_url = @browser.url.clone
   current = current.next_step
  end
 end

 it "should work following a fachinfo" do
  @browser.goto OddbUrl
  expect(@browser.url).to match OddbUrl
  link = @browser.link(:href => FI_Link)
  iksnr = FI_Link.match(link.href)[1]
  link.click

  steps = @browser.tds.find_all{ |x| x.class_name.eql? 'th-pointersteps'}
  text = steps.collect{ |y| y.text }.join('').clone
  expect(text).to match /Sie befinden sich/
 end

 it "should work following a search via IKSNR" do
   iksnr = Snapback_Registration.keys.first
   name = Snapback_Registration.values.first
  @browser.goto OddbUrl
  login
  if @browser.link(:name, 'drugs').exists?
   @browser.link(:name, 'drugs').click; small_delay
  end
  @browser.select_list(:name, "search_type").select(/Swissmedic/)
  @browser.text_field(:name, "search_query").value = iksnr
  @browser.text_field(:name, "search_query").send_keys :enter

  check_pointer_steps(/Sie befinden sich in - ,#{iksnr}/)

  expect(@browser.text).not_to match LeeresResult
  expect(@browser.text).to match /Deutsche Bezeichnung|Präparat/
  expect(@browser.text).to match name
  @browser.link(:name => 'square_fachinfo').click
  check_pointer_steps(/Sie befinden sich in\s+-\s+,Fachinformation zu #{name}/)
  @browser.link(:name => 'change_log').click
  binding.pry
  check_pointer_steps(/Sie befinden sich in\s+-\s+,Fachinformation zu #{name} - ,Änderungen/)
  @browser.link(:name => 'change_log').click
  binding.pry
  check_pointer_steps(/Sie befinden sich in\s+-\s+,Fachinformation zu #{name} - ,Änderungen - ,\d{2}\.\d{2}\.\d{4}/)
 end

 def check_pointer_steps(expected)
  steps = @browser.tds.find_all{ |x| x.class_name.eql? 'th-pointersteps'}
  text = steps.collect{ |y| y.text }.join(',').clone
  puts "#{__LINE__}: Steps are #{text}"
  puts "  should #{expected}"
  expect(text).to match expected
 end

 after :all do
  @browser.close
 end
end
