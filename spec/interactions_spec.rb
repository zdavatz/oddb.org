#!/usr/bin/env ruby
# encoding: utf-8
# kate: space-indent on; indent-width 2; mixedindent off; indent-mode ruby;
require 'spec_helper'
require 'pp'

@workThread = nil
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

DrugDescription = Struct.new(:name, :iksnr, :ean13, :atc_code, :wirkstoff)
# http://oddb-ci2.dyndns.org/de/gcc/home_interactions/7680583920013,7680591310011,7680390530399,7680586430014
# http://matrix.epha.ch/#/58392,59131,39053,58643
MephaExamples = [
  DrugDescription.new('Losartan', 	'58392', '7680583920013', 'C09CA01', 'Losartan'),
  DrugDescription.new('Metoprolol', '59131', '7680591310011', 'C07AB02', 'metoprololi tartras'),
  DrugDescription.new('Nolvadex', 	'39053', '7680390530399', 'L02BA01', 'Tamoxifen'),
  DrugDescription.new('Paroxetin',	'58643', '7680586430014', 'N06AB05', 'paroxetinum' ),
]

MephaInteractions = [ # given drugs defined above
  /C07AB02: Metoprolol => C09CA01: Losartan Verstärkte Blutdrucksenkung/,
  /N06AB05: Paroxetin => L02BA01: Tamoxifen Wirkungsverringerung von Tamoxifen/,
  /N06AB05: Paroxetin => C07AB02: Metoprolol Erhöhte Metoprololspiegel/,
  /N06AB05: Paroxetin => C09CA01: Losartan Vermutlich keine relevante Interaktion/,
]

Inderal   = 'Inderal 10 mg'
Ponstan   = 'Ponstan 125 mg'
Viagra    = 'Viagra 100 mg'
Marcoumar = 'Marcoumar'
Aspirin   = 'Aspirin Cardio 100'
# http://oddb-ci2.dyndns.org/de/gcc/home_interactions/7680317061142,7680353520153,7680546420673,7680193950301,7680517950680
OrderExample = [ Inderal, Ponstan, Viagra, Marcoumar, Aspirin, ]
OrderOfInteractions = [
  /#{Inderal}.+ - /,
  /#{Ponstan}.+ - /, # M01AG01
  /M01AG01: Mefenaminsäure => B01AA04: Phenprocoumon Erhöhtes .*Blutungsrisiko/,
  /#{Viagra}.+ - /,  # G04BE03
  /G04BE03: Sildenafil => B01AC06: Acetylsalicylsäure Keine Interaktion./,
  /#{Marcoumar}.+ - /, # B01AA04
  /B01AA04: Phenprocoumon => M01AG01: Mefenaminsäure Erhöhtes .*Blutungsrisiko/,
  /B01AA04: Phenprocoumon => B01AC06: Acetylsalicylsäure Erhöhtes .*Blutungsrisiko/,
  /#{Aspirin}.+ - /, # B01AC06
  /B01AC06: Acetylsalicylsäure => M01AG01: Mefenaminsäure Erhöhtes .*Blutungsrisiko/,
  /B01AC06: Acetylsalicylsäure => B01AA04: Phenprocoumon Erhöhtes .*Blutungsrisiko/,
  /B01AC06: Acetylsalicylsäure => G04BE03: Sildenafil Keine Interaktion/,
  ]
BlutungsRisiko = 'Erhöhtes GIT-Blutungsrisiko'

describe "ch.oddb.org" do
 
  def add_one_drug_to_interactions(name)
    @browser.url.should match ('/de/gcc/home_interactions')
    chooser = @browser.text_field(:id, 'interaction_chooser_searchbar')
    value = nil
    0.upto(10).each{ |idx|
                     begin
                        chooser.set(name)
                        sleep idx*0.1
                        chooser.send_keys(:down)
                        sleep idx*0.1
                        chooser.send_keys(:enter)
                        sleep idx*0.1
                        value = chooser.value
                        break unless /#{name}/.match(value)
                        sleep 0.5
                   rescue StandardError => e
                        # return if e.is_a? Selenium::WebDriver::Error::StaleElementReferenceError
                        puts e.inspect
                        puts caller[0..5]
                        createScreenshot(@browser, "rescue_#{name}_#{__LINE__}")
                        return
                   end
                    }
    # require 'pry'; binding.pry
    chooser.set(value + "\n")
    sleep(1)
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
    waitForOddbToBeReady(@browser, OddbUrl)
  end

  before :each do
    @browser.goto OddbUrl
    login
  end

  after :each do
    @idx += 1
    createScreenshot(@browser, '_'+@idx.to_s)
    # sleep
    @browser.goto OddbUrl
  end

  it "should show both interaction direction for marcoumar and ponstan" do
     found_using = %(
grep M01AG01 interactions_de_utf8.csv | grep B01AA04
"B01AA04";"Phenprocoumon";"M01AG01";"Mefenaminsäure";"#{BlutungsRisiko}";"Antiphlogistika hemmen die Thrombozytenaggregation und dadurch kommt es zu einer additiven Wirkung auf die Blutgerinnung. Zusätzlich verdrängt Mefenaminsäure Antikoagulantien des Coumarintyps aus der Eiweissbindung.";"Bei der Kombination von Antikoagulantien mit Antiphlogistika ist das Blutungsrisiko erhöht. Gastrointestinale Blutungen werden durch die schleimhautschädigende Wirkung der NSAIDs zusätzlich begünstigt.";"Die Kombination von Antiphlogistika mit Antikoagulantien vermeiden. Ist die kombinierte Anwendung unumgänglich, den Patienten insbesondere auf Symptome einer gastrointestinalen Blutung überwachen und Blutgerinnungsparameter engmaschig monitorisieren. Wenn möglich NSAIDs nur lokal anwenden oder Wechsel der Analgesie auf Paracetamol oder Opioide.";"D"
"M01AG01";"Mefenaminsäure";"B01AA04";"Phenprocoumon";"#{BlutungsRisiko}";"Antiphlogistika hemmen die Thrombozytenaggregation und dadurch kommt es zu einer additiven Wirkung auf die Blutgerinnung. Zusätzlich verdrängt Mefenaminsäure Antikoagulantien des Coumarintyps aus der Eiweissbindung.";"Bei der Kombination von Antikoagulantien mit Antiphlogistika ist das Blutungsrisiko erhöht. Gastrointestinale Blutungen werden durch die schleimhautschädigende Wirkung der NSAIDs zusätzlich begünstigt.";"Die Kombination von Antiphlogistika mit Antikoagulantien vermeiden. Ist die kombinierte Anwendung unumgänglich, den Patienten insbesondere auf Symptome einer gastrointestinalen Blutung überwachen und Blutgerinnungsparameter engmaschig monitorisieren. Wenn möglich NSAIDs nur lokal anwenden oder Wechsel der Analgesie auf Paracetamol oder Opioide.";"D"
)
    medis = [ 'Ponstan', 'Marcoumar']
    url = "#{OddbUrl}/de/gcc/home_interactions"
    @browser.goto url
    medis.each { | medi| add_one_drug_to_interactions(medi) }
    inhalt = @browser.text
    inhalt.should match(/B01AA04: Phenprocoumon => M01AG01: Mefenaminsäure #{BlutungsRisiko}/i)
    inhalt.should match(/B01AA04: Phenprocoumon => M01AG01: Mefenaminsäure #{BlutungsRisiko}/i)
  end

  drugs_to_ean = { 'Aspirin' => '7680576730049', 'Ponstan' => '7680353520153', 'Marcoumar' => '7680193950301' }
  orders_to_test = [
    [ 'Ponstan', 'Marcoumar', 'Aspirin'],
    [ 'Ponstan', 'Aspirin', 'Marcoumar'],
    [ 'Marcoumar', 'Ponstan', 'Aspirin'],
    [ 'Marcoumar', 'Aspirin', 'Ponstan'],
    [ 'Aspirin', 'Ponstan', 'Marcoumar'],
    [ 'Aspirin', 'Marcoumar', 'Ponstan'],
    ]
  orders_to_test.each { |medis|
    it "should show all interactions for #{medis[0]} #{medis[1]} #{medis[2]}" do
      url = "#{OddbUrl}/de/gcc/home_interactions/"
      medis.each { | medi| url += drugs_to_ean[medi] + ',' }
      url = url.sub(/,$/,'')
      @browser.goto url
      inhalt = @browser.text
      inhalt.should match(/B01AA04: Phenprocoumon => M01AG01: Mefenaminsäure #{BlutungsRisiko}/i)
      inhalt.should match(/B01AA04: Phenprocoumon => M01AG01: Mefenaminsäure #{BlutungsRisiko}/i)
      inhalt.should match(/N02BA01: Acetylsalicylsäure => M01AG01: Mefenaminsäure #{BlutungsRisiko}/i)
      inhalt.should match(/N02BA01: Acetylsalicylsäure => B01AA04: Phenprocoumon Erhöhtes Blutungsrisiko/)
      inhalt.should match(/B01AA04: Phenprocoumon => N02BA01: Acetylsalicylsäure Erhöhtes Blutungsrisiko/)
    end
  }

  it "should show work without a trailing slash after home_interactions" do
    url = "#{OddbUrl}/de/gcc/home_interactions"
    @browser.goto url
    add_one_drug_to_interactions(TwoMedis.first)
  end
  it "should show be able to use the delete_all" do
    url = "#{OddbUrl}/de/gcc/home_interactions/"
    @browser.goto url
    @browser.url.should match ('/de/gcc/home_interactions/')
    add_one_drug_to_interactions(TwoMedis.first)
    add_one_drug_to_interactions(TwoMedis.last)
    url = @browser.url
    url.should match(RegExpTwoMedis)
    inhalt = @browser.text
    inhalt.should match(/#{TwoMedis.first}/i)
    inhalt.should match(/#{TwoMedis.last}/i)
    @browser.link(:text => /Alle löschen/i).click
    sleep(0.5)
    url = @browser.url
    inhalt = @browser.text
    url.should_not match(RegExpOneMedi)
    url.should_not match(RegExpTwoMedis)
    inhalt.should_not match(/#{TwoMedis.first}/i)
    inhalt.should_not match(/#{TwoMedis.last}/i)
  end
  it "should show the correct url after deleting a medicament" do
    url = "#{OddbUrl}/de/gcc/home_interactions/"
    @browser.goto url
    @browser.url.should match ('/de/gcc/home_interactions/')
    add_one_drug_to_interactions(TwoMedis.first)
    url = @browser.url
    url.match(RegExpTwoMedis).should be nil
    url.match(RegExpOneMedi).should_not be nil
    add_one_drug_to_interactions(TwoMedis.last)
    url = @browser.url
    url.match(RegExpTwoMedis).should_not be nil
    url.match(RegExpOneMedi).should be nil
    inhalt = @browser.text
    TwoMedis.each{ |name|
                inhalt.match(/#{name}/i).should_not be nil
              }
    @browser.link(:title => /Löschen/i).click
    sleep(2)
    url = @browser.url
    inhalt = @browser.text
    inhalt.should match(/#{TwoMedis.last}/i)
    inhalt.should_not match(/#{TwoMedis.first}/i)
    url.should_not match(RegExpTwoMedis)
    url.should match(RegExpOneMedi)
    @browser.link(:title => /Löschen/i).click
    sleep(0.5)
    url = @browser.url
    inhalt = @browser.text
    url.should_not match(RegExpOneMedi)
    url.should_not match(RegExpTwoMedis)
    inhalt.should_not match(/#{TwoMedis.first}/i)
    inhalt.should_not match(/#{TwoMedis.last}/i)
  end
  it "should should not contain Wechselwirkungen" do
    url = "#{OddbUrl}/de/gcc/home_interactions/"
    @browser.goto url
    @browser.url.should match ('/de/gcc/home_interactions/')
    @browser.text.should_not match /Wechselwirkungen/
  end

  it "should show interactions in the correct order just below the triggering drug" do
# OrderExample = [ Inderal, Ponstan, Viagra, Marcoumar, Aspirin, ]
# OrderOfInteractions [
    url = "#{OddbUrl}/de/gcc/home_interactions/"
    @browser.goto url
    @browser.url.should match ('/de/gcc/home_interactions/')
    OrderExample.each{ |name| add_one_drug_to_interactions(name) }
    inhalt = @browser.text
    lastPos = -1
    OrderExample.each{ |name| inhalt.index(name).should_not be nil }
    OrderOfInteractions.each{ |pattern| pattern.match(inhalt).should_not be nil }
    OrderOfInteractions.each{
      |pattern|
          m = pattern.match(inhalt)
          m.should_not be nil
          actPos = inhalt.index(m[0])
          actPos.should be > lastPos
          lastPos = actPos
          
        }
    @browser.link(:name => 'delete').click
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
    MephaExamples.each{ |medi| add_one_drug_to_interactions(medi.name) }
    inhalt = @browser.text
    MephaInteractions.each{ |interaction| inhalt.should match (interaction) }
  end

  it "after delete all drugs a new search must be possible" do
    test_medi = 'Losartan'
    @browser.goto OddbUrl
    @browser.link(:text=>'Interaktionen').click
    @browser.url.should match ('/de/gcc/home_interactions/')
    add_one_drug_to_interactions(test_medi)
    @browser.text.should match (test_medi)
    @browser.link(:name => 'delete').click
    @browser.text.should_not match (test_medi)
    add_one_drug_to_interactions(test_medi)
    @browser.text.should match (test_medi)
  end
  it "after adding a single medicament there should be no ',' in the URL" do
    test_medi = 'Losartan'
    @browser.goto OddbUrl
    @browser.link(:text=>'Interaktionen').click
    @browser.url.should match ('/de/gcc/home_interactions/')
    @browser.link(:name => 'delete').click if @browser.link(:name => 'delete').exists?
    @browser.text.should_not match (test_medi)
    add_one_drug_to_interactions(test_medi)
    @browser.text.should match (test_medi)
    @browser.url.should_not match ('/,')
  end

  after :all do
    @browser.close
  end
end
