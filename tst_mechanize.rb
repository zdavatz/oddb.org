#!/usr/bin/env ruby
# encoding: utf-8
# Doctors -- oddb -- 21.09.2004 -- jlang@ywesee.com
require 'mechanize'
require 'pry'
require 'logger'

Personen_XLSX = File.expand_path(File.join(__FILE__, '../../../data/xls/Personen_latest.xlsx'))
Personen_YAML  = File.expand_path(File.join(__FILE__, "../../../data/txt/doctors_#{Time.now.strftime('%Y.%m.%d')}.yaml"))
Regexp = /^Merkliste \n(.*)\nBundesamt f.*r Gesundheit \(BAG\)\nRechtliche Grundlagen/m
RegexpAdressen = /^Adresse\(n\)\n(.*)\nBundesamt f.*r Gesundheit \(BAG\)\nRechtliche Grundlagen/m

def log(msg)
  $stdout.puts "#{Time.now}:  MedregDoctorPlugin #{msg}"; $stdout.flush
end

def look_for_details(where, what)
  puts where.match(/#{what}.*/)
  res = where.match(Regexp)
  if res
    detail = where.match(Regexp)[1]
    puts detail.split("\n")
  else
    puts "Could not find #{what}"
  end
end

def run_mechanize_test(gln, family_name, firstname)  
  @agent = Mechanize.new
  @agent.log = Logger.new "mech.log"
  @agent.user_agent = 'Mozilla/5.0 (X11; Linux x86_64; rv:31.0) Gecko/20100101 Firefox/31.0 Iceweasel/31.1.0'
  @agent.redirect_ok         = :all
  @agent.follow_meta_refresh_self = true
  @agent.follow_meta_refresh = :everwhere
  @agent.redirection_limit   = 55
  @agent.follow_meta_refresh = true
  @agent.ignore_bad_chunking = true
  # http://www.medregom.admin.ch/de/Suche/Detail/?gln=7601000813282&vorname=Dora+Carmela&name=ABANTO+PAYER
  url = "http://www.medregom.admin.ch/de/Suche/Detail/?gln=#{gln.to_s}&vorname=#{firstname}&name=#{family_name}"
  $stderr.puts "url to search is #{url}"
  # File.open('tst.html', 'w+'){|f| f.write page_1.to_html }

  @agent.get(url) do |page_1|
    look_for_details(page_1.content, family_name)
  data = [
    ['Name', 'Casal'],
    ['Vorname', 'Margret'],
    ['Gln', '7601000786418'],
    ['AutomatischeSuche', 'True'],
    ]
    res_2 = @agent.post('http://www.medregom.admin.ch/Suche/GetSearchCount', data)
    look_for_details(res_2.content, family_name)
    res_3  = @agent.get('http://www.medregom.admin.ch/de/Suche/ResultTemplate?_=1413961127336')
    look_for_details(res_3.content, family_name)
    data2 = [
        ['currentpage', '1'],
        ['pagesize', '10'],
        ['sortfield', ''],
        ['sortorder', 'Ascending'],
        ['pageraction', ''],
        ['filter', ''      ],
      ]
    res_4 = @agent.post('http://www.medregom.admin.ch/de/Suche/GetSearchData', data2)
    look_for_details(res_4.content, family_name)
    
    data_3 = [
      ['currentpage', '1'],
      ['pagesize', '10'],
      ['sortfield', ''],
      ['sortorder', 'Ascending'],
      ['pageraction', ''],
      ['filter', ''      ],
      ['Name', 'Casal'],
      ['Vorname', 'Margret'],
      ['Gln', '7601000786418'],
      ['AutomatischeSuche', 'True'],
    ]
    res_5 = @agent.post('http://www.medregom.admin.ch/de/Suche/GetSearchData', data)
    look_for_details(res_5.content, family_name)
  end
  puts "URL was #{url}"
  return 
  page_1 = @agent.get(url)
# => "Bundesverwaltung admin.ch\nEidgenössisches Departement des Innern EDI\nBundesamt für Gesundheit BAG\nStartseite\nDeutsch | Français | Italiano\nVersion: 1.4.2.36\nMedizinalberuferegister\nSuchen nach\nBeruf\nÄrztin/Arzt(0)\nChiropraktorin/Chiropraktor(0)\nZahnärztin/Zahnarzt(1)\nApothekerin/Apotheker(0)\nTierärztin/Tierarzt(0)\n  Name\nVorname\nStrasse\nPlz\nKanton\nAlle Kantone\nAargau\nAppenzell Ausserrhoden\nAppenzell Innerrhoden\nBasel-Land\nBasel-Stadt\nBern\nFreiburg\nGenf\nGlarus\nGraubünden\nJura\nLuzern\nNeuenburg\nNidwalden\nObwalden\nSchaffhausen\nSchwyz\nSolothurn\nSt. Gallen\nTessin\nThurgau\nUri\nWaadt\nWallis\nZug\nZürich\nGln\n        Weitere Sucheinschränkungen\nEgal \nSpezialisierung / Fachtitel\n\n\nWeiterbildungen\n\n\nTrefferliste\nMerkliste \nDora Carmela ABANTO PAYER\n\n\nABANTO PAYER, Dora Carmela (F)\n  Nationalität: Schweiz (CH)\nGLN: 7601000813282 \nBahnhofstrasse 41\n5000 Aarau\nKartendaten\nNutzungsbedingungen\nFehler bei Google Maps melden\nKarte\nZahnärztin/Zahnarzt\nBeruf Jahr Land\nZahnärztin/Zahnarzt 2004 Schweiz\nWeiterbildungstitel \nKeine Angaben vorhanden\nWeitere Qualifikationen (privatrechtliche Weiterbildung)\nKeine Angaben vorhanden\nBerufsausübungsbewilligung \nBewilligung erteilt für Kanton(e): Aargau  (2012) , Genf  (2004)\nDirektabgabe von Arzneimitteln gemäss kant. Bestimmungen (Selbstdispensation) \nkeine Selbstdispensation\nBezug von Betäubungsmitteln \nBerechtigung erteilt für Kanton(e): Aargau, Genf\nAdresse(n)\nBewilligungskanton: Aargau\nA. zahnarztzentrum.ch\nBahnhofstrasse 41\n5000 Aarau\nTelefon: 062 832 32 01\nFax: 062 832 32 01\nBewilligungskanton: Genf\nB. CABINET DENTAIRE VRBICA VESELIN\nAvenue du Bois-De-La-Chapelle 99\n1213 Onex\nTelefon: 022.793.29.60\nFax: 022.793.29.63\nBundesamt für Gesundheit (BAG)\nRechtliche Grundlagen"
  unless page_1.text.match(Regexp)
    log "No Detail found"
    return
  end
  infos = []
  nrWaits = 0
  while infos.size <= 1 && nrWaits < 10
    detail = @agent.text.match(Regexp)[1].clone
    infos = detail.split("\n")
    log "#{Time.now}: Found #{infos.size} infos for #{info}"
    break if infos.size > 1
    sleep(1)
    nrWaits += 1
  end
  if infos.size <= 1 or infos.index("Die Suche ergab keine Treffer.")
    log "#{Time.now}: Unable to find #{gln}  via #{info} and url #{url}"
    @doctors_skipped += 1
    return
  end
  doctor = Hash.new
  doctor[:ean13] =  gln.to_s.clone
  doctor[:name] =  infos[3].split(', ')[0].clone
  doctor[:firstname] =  infos[3].split(', ')[1].split(' (')[0].clone
  
  idx = infos.index('Beruf Jahr Land')
  doctor[:exam] =  infos[idx+1].split(' ')[1].clone
  idx = infos.index('Berufsausübungsbewilligung ')
  
  idx=infos.index('Weiterbildungstitel ')
  idx2=infos.index('Weitere Qualifikationen (privatrechtliche Weiterbildung)')
  specialities = infos[idx+1..idx2-1].join(", ")          
  doctor[:specialities] = specialities unless specialities.match(/Keine Angaben vorhanden/)
  # Selbstdispensation = infos.index("Direktabgabe von Arzneimitteln gemäss kant. Bestimmungen (Selbstdispensation) ") != nil
  # idx = infos.index("Bezug von Betäubungsmitteln ")
  # may_dispense_drugs = infos[idx+1].match(/Berechtigung erteilt für Kanton/) != nil
  # doctor[:email]
  # :language,
  # :praxis,
  # :title,
  # :salutation, # könnte via https://www.medreg.admin.ch/MedReg/Summary.aspx?IdPerson=4633 gefunden werden
  idx = infos.index("Adresse(n)")
  addresses = get_addresses_from_medregob(@agent.text.match(RegexpAdressen)[1])
                    
#          text = "Bewilligungskanton: Aargau\nA. zahnarztzentrum.ch\nBahnhofstrasse 41\n5000 Aarau\nTelefon: 062 832 32 01\nFax: 062 832 32 01\nBewilligungskanton: Genf\nB. CABINET DENTAIRE VRBICA VESELIN\nAvenue du Bois-De-La-Chapelle 99\n1213 Onex\nTelefon: 022.793.29.60\nFax: 022.793.29.63"
#          addresses = get_addresses_from_medregob(text)
  log addresses
  log doctor
end

run_mechanize_test(7601000019080, 'Zwingli', 'Martin')
#  http://www.medregom.admin.ch/de/Suche/Detail/?gln=7601000786418&vorname=Margret&name=Casal
# run_mechanize_test(7601000786418, 'Casal', 'Margret')