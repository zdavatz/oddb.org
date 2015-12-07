#!/usr/bin/env ruby
# encoding: utf-8
require 'spec_helper'

@workThread = nil

describe "ch.oddb.org" do

  Evidentia_URL = 'http://evidentia.oddb-ci2.dyndns.org'
  HomeURL       = "#{Evidentia_URL}/de/gcc/home_drugs/"
  Lamivudin     = 'Lamivudin-Zidovudin-Mepha'
  Sevikar       = 'Sevikar HCT'
  Duodopa       = 'Duodopa'

  before :all do
    @idx = 0
    waitForOddbToBeReady(@browser, Evidentia_URL)
    login
  end

  before :each do
    @browser.goto Evidentia_URL
  end

  after :each do
    @idx += 1
    createScreenshot(@browser, '_'+@idx.to_s)
  end

  def select_product_by_trademark(name)
    url = "#{Evidentia_URL}/de/evidentia/search/zone/drugs/search_query/#{name}?"
    @browser.goto url
    @browser.element(:id => 'ikscat_1').wait_until_present
    expect(@browser.url.index(Evidentia_URL)).to eq 0
    expect(@browser.url.index('/de/evidentia')).not_to eq 0
    @text = @browser.text.clone
  end

  it 'should list all SL products before the Non-SL' do
    select_product_by_trademark('Levetiracetamum')
    text = @browser.text.clone
    text.gsub!('SL = Spezialitätenliste', '')
    # File.open('Levetiracetamum.text', 'w+'){|f| f.write text } ; binding.pry
    drugs = @browser.trs.find_all{|x| x.elements[1].title.eql?('Fachinformation') }.collect{|x| x.text.clone}
    [ 'Tabletten', 'Flasche' ].each do |gal_group|
      last_SL = -1
      drugs.each_with_index{ |drug, index| last_SL = index if /^.*#{gal_group}.* SL/im.match(drug)}; last_SL
      first_B = -1
      drugs.each_with_index{ |drug, index| first_B = index if /^.*#{gal_group}.* B$/im.match(drug)}; first_B
      last_SL_SG = -1
      drugs.each_with_index{ |drug, index| last_SL_SG = index if /^.*#{gal_group}.* SL \/ SG/im.match(drug)}; last_SL_SG
      puts "#{@browser.url} #{gal_group}: #{drugs.size} drugs first_B is #{first_B} last_SL #{last_SL} last_SL_SG #{last_SL_SG}"
      expect(last_SL).not_to eql -1
      expect(last_SL_SG).not_to eql -1
      expect(first_B).not_to eql -1
      expect(first_B).to be > last_SL
      expect(first_B).to be > last_SL_SG
    end
  end

  it "should not contain a column Fachinfo" do
    select_product_by_trademark(Lamivudin)
    fi = @browser.td(:class_name => /list /, :text => 'FI')
    expect(fi.exist?).to eq false
  end

  it "should not have a link to the fachinfo when there is no fachinfo (e.g. Cyramza)" do
    @browser.goto "#{Evidentia_URL}/de/evidentia/search/zone/drugs/search_query/Cyramza?"
    link = @browser.link(:href => /fachinfo/)
    expect(link.exist?).to be false
  end

  it "should contain a link to the limiation in Sevikar HCT preparation" do
    select_product_by_trademark(Sevikar)
    link = @browser.link(:text => 'L')
    expect(link.href.index('limitation_text')).to be > 0
    expect(link.text).to eq 'L'
    td = @browser.td(:class =>/^list/, :text => /#{Sevikar}.*- L/)
    expect(td.exist?).to eq true
    expect(td.link(:href => /fachinfo/).exist?).to eq true
    expect(td.link(:href => /limitation_text/).exist?).to eq true
  end

  it "should contain a link to the price comparision in price public" do
    # http://ch.oddb.org/de/gcc/search/zone/drugs/search_query/sevikar%20hct/search_type/st_sequence?#best_result
    select_product_by_trademark(Sevikar)
    pubprice = @browser.td(:class_name => /pubprice/)
    expect(pubprice.exist?).to eq true
    expect(pubprice.text).to match /^\d+\.\d+/
    pubprice_link = @browser.link(:name => /compare/)
    expect(pubprice_link.title).to eq 'Preisvergleich'
  end

  it "should contain a link to the FI for the drug when in price comparison" do
    @browser.goto "#{Evidentia_URL}/de/evidentia/compare/ean13/7680615190018"

    # name of preparation should link to the fachinfo
    td = @browser.td(:class =>/^list/, :text => /^Sevikar/)
    td.wait_until_present
    expect(td.links.size).to eq 1
    expect(td.links.first.href).to match /\/fachinfo\//

    # pp should link to the new compare
    td2 = @browser.td(:class =>/pubprice/)
    expect(td2.links.size).to eq 1
    expect(td2.links.first.href).to match /\/compare\//
    expect(td2.text).to match /\d+\.\d+/ # valid price
  end

  it "should contain a link to the fachinfo for Lamivudin-Zidovudin" do
    select_product_by_trademark(Lamivudin)
    link = @browser.link(:text => Lamivudin)
    expect(link.exists?)
    expect(link.href.index('ean')).to eq(nil)
    expect(link.href.index('fachinfo')).to be > 0
  end

  it "should display a limitation link for #{Sevikar}" do
    select_product_by_trademark(Sevikar)
    expect(@browser.element(:id => 'ikscat_1').text).to eq 'B / SL'
    span = @browser.element(:id => 'deductible_1')
    expect(span.exist?).to eq true
    expect(span.text).to match /\d+%/
    expect(@browser.link(:text => 'L').exists?).to eq true
    expect(@browser.link(:text => 'L').href).to match /limitation_text\/reg/
    expect(@browser.link(:text => 'FI').exists?).to eq false
    expect(@browser.link(:text => 'PI').exists?).to eq false
    expect(@browser.td(:text => 'A').exists?).to eq false
    expect(@browser.td(:text => 'C').exists?).to eq false
  end

  it "should display lamivudin with SO and SG in category (price comparision)" do
    select_product_by_trademark('lamivudin')
    expect(@browser.tds.find{ |x| x.text.eql?('A / SL / SO')}.exists?).to eq true
    expect(@browser.tds.find{ |x| x.text.eql?('A / SL / SG')}.exists?).to eq true
  end

  # Inhaltstoffe, z.B. Carbidopa
  it "should list trademark first e.g. Duodopa" do
    select_product_by_trademark(Duodopa)
    link = @browser.link(:text => Duodopa)
    expect(link.exists?)
    expect(link.href.index('ean')).to eq(nil)
    expect(link.href.index('fachinfo')).to be > 0
    text = @browser.text.clone
    expect(/Präparate.*\n.*\n/.match(text)[0]).to match Duodopa
  end

  after :all do
    @browser.close
  end
end
