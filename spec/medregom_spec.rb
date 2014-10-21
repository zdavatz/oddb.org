#!/usr/bin/env ruby
# encoding: utf-8

# This is the most important integration test, which ensures that handling payment via paypal works
# It requires the following setup:
# * must be run on the server (to be able to check in the log for the URL for new users)
# * etc/oddb.yml must be configured to use the sandbox (check here in the code)
# * test-account on developer.paypal.com must exist and specified correctly
#

require 'spec_helper'
require 'pry'
require 'nokogiri'
 
describe "ch.oddb.org" do
  # MedRegormURL = "http://www.medregom.admin.ch/"
#  MedRegormURL = 'https://www.medreg.admin.ch'
  MedRegormURL = 'https://www.medreg.admin.ch/MedReg/PersonenSuche.aspx'
  GLN_Abanto   = "7601000813282"
  before :all do
#    waitForOddbToBeReady(@browser, MedRegormURL)
  end

  before :each do
#    @browser.goto MedRegormURL
  end

  TestSearchUrl = 'http://www.medregom.admin.ch/de/Suche/Detail/?gln=7601000813282&vorname=Dora+Carmela&name=ABANTO+PAYER'
  LimitSearchRegExp = /.*Bitte grenzen Sie die Suche ein.*/i
      
  it "should be possible to find a doctors detail info via medregom" do
#    browser = Watir::Browser.start TestSearchUrl
#   browser = Watir::Browser.start "http://www.medregom.admin.ch/"
    waitForOddbToBeReady(@browser, TestSearchUrl)
    @browser.goto TestSearchUrl
    doc = Nokogiri::HTML(@browser.html)
    puts @browser.text.match(/Kein.*tref.*/i)
    @browser.text.match(/.*Kein.*tref.*/i).should be nil
    puts __LINE__
    puts @browser.text.match(LimitSearchRegExp).inspect
    $stdout.sync    
    sleep 5 if @browser.text.match(LimitSearchRegExp)
    doc = Nokogiri::HTML(@browser.html)
    @browser.text.match(LimitSearchRegExp).should be nil
    puts "#{__LINE__} nationality, gln"
    puts doc.xpath('//p/text()').text
# => "Nationalität: Schweiz (CH)GLN: 7601000813282"
    puts "#{__LINE__} address-item active"
    puts doc.css('li[class="address-item active"]').text
#=> "A.\n\t\t\t  zahnarztzentrum.chBahnhofstrasse 415000 AarauTelefon: 062 832 32 01Fax: 062 832 32 01"
  # doc.css('li[class="address-item"]').text
#=> "B.\n\t\t\t  CABINET DENTAIRE VRBICA VESELINAvenue du Bois-De-La-Chapelle 991213 OnexTelefon: 022.793.29.60Fax: 022.793.29.63"
    puts __LINE__
    puts doc.css('h4').last.text  if false # Addressen 
    puts "#{__LINE__} resultContainer"
    puts doc.css('div[id="resultContainer"]').text
#=> "\n\t\t\n\t\t\tlnkDetail\n\t\t\t\n\t\t\t\tTrefferliste\n\t\t\t\t\tMerkliste \n\t\t\t\tDora Carmela ABANTO PAYER\n\t\t\t\n\t\t\n\t\t\n\t\t\t\n\t\t\t\tDie Suche ergab 76122  Treffer, aber es werden nur die ersten 100 angezeigt. Bitte grenzen Sie die Suche ein!\n\t\t\t\n\t\t\tABANTO PAYER\n\t\t\tDora Carmela\n\t\t\tAvenue du Bois-De-La-Chapelle 99Bahnhofstrasse 41\n\t\t\t12135000\n\t\t\tOnexAarau\n\t\t\tZahnärztin/Zahnarzt \n\t\t\t\n\t\t\t\n\t\t\t\t \n\t\t\t\n\t\t\t\n\t\t\n\t\t\t\tNachname\n\t\t\t\n\t\t\t\n\t\t\t\tVorname\n\t\t\t\n\t\t\t\n\t\t\t\tStrasse\n\t\t\t\n\t\t\t\n\t\t\t\tPLZ\n\t\t\t\n\t\t\t\n\t\t\t\tOrt\n\t\t\t\n\t\t\t\n\t\t\t\tBeruf\n\t\t\t\n\t\t\t\n\t\t\t\tWeiterbildung(en)\n\t\t\t\n\t\t\t\n\t\t\t\n\t\t\n\t\t\t\t\n\t\t\t\t\tTreffer 1 von 100\n\t\t\t\t\n\t\t\t\t\n\t\t\t\t\t\n\t\t\t\t\t\n\t\t\t\t\t\tzurück\n\t\t\t\t\t\n\t\t\t\t\t\n\t\t\t\t\t\tweiter\n\t\t\t\t\t\n\t\t\t\t\t\n\t\t\t\t\n\t\t\t\n\t\t\n\t\t\t\tDie Suche ergab keine Treffer.\n\t\t\t\n\t\t\n\t\t\n\t\t\t\n\t\t\t\tSie haben keine Personen in ihrer Merkliste.\n\t\t\t\n\t\t\n\t\n\n  \n    ABANTO PAYER, Dora Carmela (F)\n     \n    \n      \n    \n    \n      \n        Direktlink\n        \n    \n    \n  \n  Nationalität: Schweiz (CH)GLN: 7601000813282 \n\n\n  \n    \n  \n  Bahnhofstrasse 415000 AarauKartendatenKartendaten © 2014 GoogleKartendatenKartendaten © 2014 GoogleKartendaten © 2014 GoogleNutzungsbedingungenFehler bei Google Maps meldenKarteKarteSatellitGelände45°Beschriftungen\n\n\n  Zahnärztin/Zahnarzt\n  \n    \n      Beruf\n            Jahr\n            Land\n          Zahnärztin/Zahnarzt\n            2004\n            Schweiz\n          Weiterbildungstitel \n            \n            \n          Keine Angaben vorhanden\n          Weitere Qualifikationen (privatrechtliche Weiterbildung)\n            \n            \n          Keine Angaben vorhanden\n          \n    Berufsausübungsbewilligung Bewilligung erteilt für Kanton(e): Aargau \n          (2012)\n        , Genf \n          (2004)\n        Direktabgabe von Arzneimitteln gemäss kant. Bestimmungen (Selbstdispensation) keine SelbstdispensationBezug von Betäubungsmitteln Berechtigung erteilt für Kanton(e): Aargau, GenfAdresse(n)Bewilligungskanton: AargauA.\n\t\t\t  zahnarztzentrum.chBahnhofstrasse 415000 AarauTelefon: 062 832 32 01Fax: 062 832 32 01Bewilligungskanton: GenfB.\n\t\t\t  CABINET DENTAIRE VRBICA VESELINAvenue du Bois-De-La-Chapelle 991213 OnexTelefon: 022.793.29.60Fax: 022.793.29.63\n\n\n\n"
    puts "#{__LINE__} name, first name, sex"
 puts doc.css('div[id="resultContainer"]').css('h3').text
#=> "ABANTO PAYER, Dora Carmela (F)"
    puts "#{__LINE__} diploma"
 puts doc.css('div[id="resultContainer"]').css('div li[class="active"]').text
# => "Zahnärztin/Zahnarzt"
    puts "#{__LINE__} nationality, gln"
  puts doc.css('div[id="resultContainer"]').css('p').text
#   => "Nationalität: Schweiz (CH)GLN: 7601000813282 "
    puts "#{__LINE__} ac-detail-data"
  puts doc.css('div[id="resultContainer"]').css('div[class="ac-detail-data"]').text
#=> "\n    \n      Beruf\n            Jahr\n            Land\n          Zahnärztin/Zahnarzt\n            2004\n            Schweiz\n          Weiterbildungstitel \n            \n            \n          Keine Angaben vorhanden\n          Weitere Qualifikationen (privatrechtliche Weiterbildung)\n            \n            \n          Keine Angaben vorhanden\n          \n    Berufsausübungsbewilligung Bewilligung erteilt für Kanton(e): Aargau \n          (2012)\n        , Genf \n          (2004)\n        Direktabgabe von Arzneimitteln gemäss kant. Bestimmungen (Selbstdispensation) keine SelbstdispensationBezug von Betäubungsmitteln Berechtigung erteilt für Kanton(e): Aargau, GenfAdresse(n)Bewilligungskanton: AargauA.\n\t\t\t  zahnarztzentrum.chBahnhofstrasse 415000 AarauTelefon: 062 832 32 01Fax: 062 832 32 01Bewilligungskanton: GenfB.\n\t\t\t  CABINET DENTAIRE VRBICA VESELINAvenue du Bois-De-La-Chapelle 991213 OnexTelefon: 022.793.29.60Fax: 022.793.29.63"
    puts "#{__LINE__} ac-detail-data thead"
puts doc.css('div[id="resultContainer"]').css('div[class="ac-detail-data"] thead').text
# => "Beruf\n            Jahr\n            Land\n          "
    puts "#{__LINE__} ac-detail-data tbody"
  puts doc.css('div[id="resultContainer"]').css('div[class="ac-detail-data"] tbody').text
# => "Zahnärztin/Zahnarzt\n            2004\n            Schweiz\n          Weiterbildungstitel \n            \n            \n          Keine Angaben vorhanden\n          Weitere Qualifikationen (privatrechtliche Weiterbildung)\n            \n            \n          Keine Angaben vorhanden\n         
  binding.pry
    puts "#{__LINE__} done"
  end
  
  it "should be possible to find a doctors detail info via medreg" do
    binding.pry
    @browser.goto 'https://www.medreg.admin.ch/MedReg/PersonenSuche.aspx'
    @browser.text_field(:id, "ctl00_ContentPlaceHolder2_TextBoxGln").set(GLN_Abanto)
    doc = Nokogiri::HTML(browser.html)

    @browser.link(:text, "Detail").click
    info = @browser.td(:id => /ctl00_PanelMasterContentPlaceHolderTwo/).text
# => "Zusammenfassung\nAnrede Name, Vorname\nNationalität\nGLN\nUID\nFrau ABANTO PAYER, Dora Carmela\nSchweiz\n7601000813282\nCHE416376281\nBerufe (Diplome), Erteilungsland\n- Zahnärztin/Zahnarzt, 07.05.2004, Schweiz\nWeiterbildung*1, Erteilungsland\nKeine Angaben vorhanden\nPrivatrechtliche Weiterbildung*1\nKeine Angaben vorhanden\nBewilligungskanton\nAdresse\n- Aargau, Zahnärztin/Zahnarzt, Erteilt, 14.08.2012\nzahnarztzentrum.ch, Bahnhofstrasse 41, 5000 Aarau\nBerechtigung Selbstdispensation *2: Nein\nBerechtigung zum Bezug von Betäubungsmitteln\n  - Genf, Zahnärztin/Zahnarzt, Erteilt, 28.07.2004\nCABINET DENTAIRE VRBICA VESELIN, Avenue du Bois-De-La-Chapelle 99, 1213 Onex\nBerechtigung Selbstdispensation *2: Nein\nBerechtigung zum Bezug von Betäubungsmitteln\n  Meldekanton für 90-Tage-Dienstleister\nAdresse\nKeine Angaben vorhanden\nBemerkungen\n*1: Sowohl bei den Diplomen wie bei den Weiterbildungstiteln wird unterschieden zwischen eidgenössischen Titeln und solchen, die aufgrund des Freizügigkeitsabkommens anerkannt werden. Für Titelträger aus Nicht-EU –Ländern besteht unter bestimmten Voraussetzungen (Art. 36 MedBG) die Möglichkeit, dass ihre Titel als gleichwertig erklärt werden.\n*2: Selbstdispensation bedeutet, dass die Medizinalperson zur direkten Abgabe von Medikamenten berechtigt ist.\nBundesamt für Gesundheit (BAG)\nRechtliche Grundlagen"
  end if false
  

  after :all do
    @browser.close
  end if false
end
