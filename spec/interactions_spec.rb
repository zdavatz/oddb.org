#!/usr/bin/env ruby
# encoding: utf-8
require 'spec_helper'
require 'pp'
# require Dir.pwd + '/spec/spec_helper.rb'
@workThread = nil

describe "ch.oddb.org" do
 
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
  
  it "should show interactions between epha example in instant view" do
    @browser.goto OddbUrl
    medis = ['Losartan',
              'Metoprolol',
              'Nolvadex',
              'Paroxetin',
             ]
    @browser.link(:text=>'Interaktionen').click
    @browser.url.should match ('/de/gcc/home_interactions/')
    id = 'interaction_searchbar'
    medis.each{
               |medi|
              chooser = @browser.text_field(:id, id)
              0.upto(10).each{ |idx|
                              chooser.set(medi) 
                              sleep idx*1
                              chooser.send_keys(:down)
                              sleep idx*0.1
                              chooser.send_keys(:enter)
                              sleep idx*0.1
                              value = chooser.value
                              break unless /#{medi}/.match(value)
                              sleep 1
                             }
              chooser.set(chooser.value + "\n")
              createScreenshot(@browser, "_#{medi}_#{__LINE__}")
              id = 'interaction_chooser_searchbar'
              }
    sleep 1
    createScreenshot(@browser, "_interactions_#{__LINE__}")
    medis.each{
               |medi|
    @browser.text.should match /#{medi}/
               }            
  end
  it "should show interactions between Aspirin and Marcoumar in old format" do
    @browser.link(:text=>'Interaktionen').click
    @browser.url.should match ('/de/gcc/home_interactions/')
    @browser.link(:text=>'Instant').click
    @browser.button(:value,"Suchen").click
    @browser.url.should match ('/de/gcc/interaction_chooser/')
    @browser.text_field(:id, "searchbar").set("Aspirin")
    @browser.button(:value,"Suchen").click
    @browser.text.should match /Ascorbinsäure/
    @browser.text.should match "Ascorbinsäure"
    @browser.text.should match  "Pseudoephedrin Hydrochlorid"
    @browser.text.should match  /Medikament.e. in der ODDB anzeigen/
    @browser.link(:text, "Acetylsalicylsäure").click
    @browser.text_field(:id, "searchbar").set("Marcoumar")
    @browser.button(:value,"Suchen").click
    @browser.link(:text, "Phenprocoumon").click
    @browser.button(:value,"Interaktionen Epha.ch").click
    @browser.text.should match /B01AA04 .Phenprocoumonum./
    @browser.text.should match 'Erhöhtes Blutungsrisiko'
    @browser.link(:text,"Erhöhtes Blutungsrisiko").click
    @browser.back
    @browser.back
    @browser.button(:value,"Interaktionen Epha.ch in 3D").click
    # cannot match HTML. e-g Übersicht
    # @browser.text "Quelle: Swissmedic\nVersion: 30.10.2013\nÜbersicht\nAlle löschen"
    # @browser.text.should match 'Marcoumar'
    # @browser.text.should match 'Aspirin'
  end if false

  
  after :all do
    @browser.close
  end
 
end
x = %(
1. Suchen Sie nach Medikamentennamen oder Wirkstoff.
2. Auf "Medikamentennamen" klicken -> Medikament wird in den Interaktionskorb gelegt.
3. Auf "Interaktionskorb" klicken.
Ascorbinsäure N02BA01        
Phenprocoumon B01AA04 2A6, 2C8, 2C9, 3A4 und 3A5-7 

http://ch.oddb.org/de/gcc/interaction_basket/substance_ids/3683,6254/atc_code/N02BA01,N02BA01,N02BA01,B01AA04

Substanz  ATC-Klassierung Substrat von  wird angeregt durch wird gehemmt durch  empirisch
Ascorbinsäure N02BA01        
Phenprocoumon B01AA04 2A6, 2C8, 2C9, 3A4 und 3A5-7       
starke Hemmung : verursacht einen > 5-fachen Anstieg von Plasma-AUC-Werten oder eine Clearance-Verminderung von mehr als 80%.
moderate Hemmung : verursacht einen > 2-fachen Anstieg von Plasma-AUC-Werten oder eine Clearance-Verminderung von 50-80%.
schwache Hemmung : verursacht einen > 1.25-fachen Anstieg von Plasma-AUC-Werten oder eine Clearance-Verminderung von 20-50%.

Epha ->
Active  Passive Information Rating
N02BA01 (Acidum Ascorbicum) B01AA04 (Phenprocoumonum) Erhöhtes Blutungsrisiko C
B01AA04 (Phenprocoumonum) N02BA01 (Acidum A
Interaktion Detail
Mechanism Acetylsalicylsäure hemmt die Thrombozytenaggregation und wirkt damit ebenfalls antikoagulatorisch.
Effect  Durch die additive Wirkung beider Substanzen nimmt das Blutungsrisiko zu.
Clinic  Trotz des erhöhten Blutungsrisikos wird die Kombination von oralen Antikoagulantien mit Acetylsäure 100-300mg täglich in bestimmten kardiovaskulären Situationen bewusst eingesetzt. Dabei sollte der Patient klinisch auf ein erhöhtes Blutungsrisiko, insbesondere auf Symptome einer gastrointestinalen Blutung monitorisiert werden. Analgetische Dosierungen von Acetylsalicylsäure sollten nicht mit oralen Antikoagulantien kombiniert werden. INR engmaschig kontrollieren.
References   
Author  Journal Year  Titel
Kastrati A  J Intern Med  2008  Aspirin and clopidogrel with or without phenprocoumon after drug eluting coronary stent placement in patients on chronic oral anticoagulation.
Loew D  Am Heart J  1980  Bleeding during acetylsalicylic acid and anticoagulant therapy in patients with reduced platelet reactivity after aortic valve replacement.
Petersen P  Arch Intern Med 1999  Bleeding during warfarin and aspirin therapy in patients with atrial fibrillation: the AFASAK 2 study. Atrial Fibrillation Aspirin and Anticoagulation.
Schaff HV Am J Cardiol  1983  Trial of combined warfarin plus dipyridamole or aspirin therapy in prosthetic heart valve replacement: danger of aspirin compared with dipyridamo

Epha-3 ->
http://matrix.epha.ch/#N02BA01,B01AA04 Zeigt nichts an, da nicht IKSNR

 )
)