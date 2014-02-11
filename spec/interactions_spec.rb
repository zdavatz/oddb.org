#!/usr/bin/env ruby
# encoding: utf-8
# kate: space-indent on; indent-width 2; mixedindent off; indent-mode ruby;
require 'spec_helper'
require 'pp'
# require Dir.pwd + '/spec/spec_helper.rb'
@workThread = nil
for_running_in_irb = %(
require 'watir'; require 'pp'
homeUrl ||= "oddb-ci2.dyndns.org"
OddbUrl = homeUrl
@browser = Watir::Browser.new
@browser.goto OddbUrl
@browser.link(:text=>'Interaktionen').click
id = 'home_interactions'
medi = 'Losartan'
chooser = @browser.text_field(:id, id)
)

DrugDescription = Struct.new(:name, :iksnr, :ean13, :atc_code, :wirkstoff)
MephaExamples = [
  DrugDescription.new('Losartan', 	'58392', '7680583920013', 'C09CA01', 'Losartan'),
  DrugDescription.new('Metoprolol', '59131', '7680591310011', 'C07AB02', 'metoprololi tartras'),
  DrugDescription.new('Nolvadex', 	'39053', '7680390530399', 'L02BA01', 'Tamoxifen'),
  DrugDescription.new('Paroxetin',	'58643', '7680586430014', 'N06AB05', 'paroxetinum' ),
]
MephaInteractions = [ # given drugs defined above
  /C09CA01: Losartan => C07AB02: Metoprolol Verstärkte Blutdrucksenkung\nB:/,
  /C07AB02: Metoprolol => C09CA01: Losartan Verstärkte Blutdrucksenkung\nB:/,
  /C09CA01: Losartan => L02BA01: Tamoxifen Keine bekannte Interaktion\nA:/,
  /N06AB05: Paroxetin => C09CA01: Losartan Vermutlich keine relevante Interaktion.\nB:/,
  /N06AB05: Paroxetin => C07AB02: Metoprolol Erhöhte Metoprololspiegel\nC:/,
  /N06AB05: Paroxetin => L02BA01: Tamoxifen Wirkungsverringerung von Tamoxifen\nX:/,
]
SearchBar = 'interaction_chooser_searchbar'

describe "ch.oddb.org" do
 
  def add_one_drug_by(name)
    @browser.url.should match ('/de/gcc/home_interactions/')
    chooser = @browser.text_field(:id, SearchBar)
    0.upto(10).each{ |idx|
                    chooser.set(name)
                    sleep idx*1
                    chooser.send_keys(:down)
                    sleep idx*0.1
                    chooser.send_keys(:enter)
                    sleep idx*0.1
                    value = chooser.value
                    break unless /#{name}/.match(value)
                    sleep 1
                    }
    chooser.set(chooser.value + "\n")
    createScreenshot(@browser, "_#{name}_#{__LINE__}")
  end

  def check_url_with_epha_example_interaction(url)
    puts "check_url_with_epha_example_interaction #{url}" if $VERBOSE
    @browser.goto url
    @browser.url.should match ('/de/gcc/home_interactions/')
    inhalt = @browser.text
    MephaInteractions.each{ |interaction| inhalt.should match (interaction) }
    @browser.link(:name => 'delete').click
  end    

  before :all do
    @idx = 0
    @browser = Watir::Browser.new
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

  it "should show interactions having given iksnr,ean13,atc_code,iksnr" do
    url = "#{OddbUrl}/de/gcc/home_interactions/"
    url += MephaExamples[0].iksnr + ','
    url += MephaExamples[1].ean13 + ','
    url += MephaExamples[2].atc_code + ','
    url += MephaExamples[3].iksnr
    check_url_with_epha_example_interaction(url)
  end

  it "should show interactions having given atc_codes" do
    atc_codes = MephaExamples.collect{ |x| x.atc_code}
    check_url_with_epha_example_interaction("#{OddbUrl}/de/gcc/home_interactions/#{atc_codes.join(',')}")
  end

  it "should show interactions having given ean13s" do
    ean13s = MephaExamples.collect{ |x| x.ean13}
    check_url_with_epha_example_interaction("#{OddbUrl}/de/gcc/home_interactions/#{ean13s.join(',')}")
  end

  it "should show interactions having given iksnrs" do
    iksnrs = MephaExamples.collect{ |x| x.iksnr}
    check_url_with_epha_example_interaction("#{OddbUrl}/de/gcc/home_interactions/#{iksnrs.join(',')}")
  end

  it "should show interactions for epha example medicaments added manually" do
    @browser.goto OddbUrl
    @browser.link(:text=>'Interaktionen').click
    @browser.url.should match ('/de/gcc/home_interactions/')
    MephaExamples.each{
                |medi|
              chooser = @browser.text_field(:id, SearchBar)
              0.upto(10).each{ |idx|
                              chooser.set(medi.name)
                              sleep idx*1
                              chooser.send_keys(:down)
                              sleep idx*0.1
                              chooser.send_keys(:enter)
                              sleep idx*0.1
                              value = chooser.value
                              break unless /#{medi.name}/.match(value)
                              sleep 1
                              }
              chooser.set(chooser.value + "\n")
              createScreenshot(@browser, "_#{medi.name}_#{__LINE__}")
              @browser.url.should_not match ('/,')
              }
    sleep 1
    createScreenshot(@browser, "_interactions_#{__LINE__}")
    inhalt = @browser.text
    MephaInteractions.each{ |interaction| inhalt.should match (interaction) }
  end

  it "after delete all drugs a new search must be possible" do
    test_medi = 'Losartan'
    @browser.goto OddbUrl
    @browser.link(:text=>'Interaktionen').click
    @browser.url.should match ('/de/gcc/home_interactions/')
    add_one_drug_by(test_medi)
    @browser.text.should match (test_medi)
    @browser.link(:name => 'delete').click
    @browser.text.should_not match (test_medi)
    add_one_drug_by(test_medi)
    @browser.text.should match (test_medi)
  end

  it "after adding a single medicament there should be no ',' in the URL" do
    test_medi = 'Losartan'
    @browser.goto OddbUrl
    @browser.link(:text=>'Interaktionen').click
    @browser.url.should match ('/de/gcc/home_interactions/')
    @browser.link(:name => 'delete').click if @browser.link(:name => 'delete').exists?
    @browser.text.should_not match (test_medi)
    add_one_drug_by(test_medi)
    @browser.text.should match (test_medi)
    @browser.url.should_not match ('/,')
  end


  after :all do
    @browser.close
  end
 
end
