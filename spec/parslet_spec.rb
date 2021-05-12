VERBOSE_MESSAGES = false
if File.exists?("#{Dir.pwd}/lib/oddb2xml/parslet_compositions.rb")
  require_relative "../lib/oddb2xml/parslet_compositions"
else
  puts :ParseFailed
  require_relative "../src/plugin/parslet_compositions"
end

require "parslet/rig/rspec"
require "socket"

hostname = Socket.gethostbyname(Socket.gethostname).first
RUN_ALL_COMPOSITION_TESTS = false # /travis|localhost/i.match(hostname) != nil # takes about five minutes to run!
puts "hostname is #{hostname} RUN_ALL_COMPOSITION_TESTS #{RUN_ALL_COMPOSITION_TESTS}"
# Testing whether 8937 composition lines can be parsed. Found 380 errors in 293 seconds
# 520 examples, 20 failures, 1 pending

describe ParseComposition do
  context "should handle 66540 Tektrotyd, Markierungsbesteck" do
    string = "conserv.: E 216, E 218, excipiens pro suppositorio."
    composition = ParseComposition.from_string(string)
    # active_agent = ["hynic-[d-phe(1)", "tyr(3)-octeotridum]trifluoroacetum", "acidum ethylendiamini-n,n'-diaceticum"]
    active_substance = "HYNIC-[D-Phe(1)"
    composition_text = "II) Durchstechflasche 2: acidum ethylendiamini-N,N'-diaceticum 10 mg, dinatrii phosphas dodecahydricus, natrii hydroxidum, pro vitro."
    composition = ParseUtil.parse_compositions(composition_text, active_substance).first

    specify { expect(composition.substances.size).to eq 3 }
    specify { expect(composition.label).to eq "II" }
    specify { expect(composition.excipiens.name).to match(/pro vitro/i) }
    specify { expect(composition.substances.first.name).to eq "Acidum Ethylendiamini-n,n'-diaceticum" }
  end

  context "should handle excipiens" do
    string = "conserv.: E 216, E 218, excipiens pro suppositorio."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 2 }
    specify { expect(composition.label).to eq nil }
    specify { expect(composition.excipiens.name).to match(/excipiens pro suppositorio/i) }
    specify { expect(composition.substances.first.name).to eq "E 216" }
  end

  context "Shire Subcuvia" do
    #   def initialize(column_c = nil, size = nil, unit = nil, active_substance = nil, composition= nil)
    active_substance = "immunoglobulinum humanum normale"
    composition_text = "proteina 160 mg cum immunoglobulinum humanum normale min. 95 %, glycinum, natrii chloridum, aqua ad iniectabilia, q.s. ad solutionem pro 1 ml."
    composition = ParseUtil.parse_compositions(composition_text, active_substance).first
    specify { expect(composition.substances.size).to eq 4 }
    specify { expect(composition.label).to eq nil }
    specify { expect(composition.label_description).to eq nil }
    specify { expect(composition.substances[0].name).to eq "Proteina" }
    specify { expect(composition.substances[1].name).to eq "Cum Immunoglobulinum Humanum Normale" }
    specify { expect(composition.substances[0].is_active_agent).to eq false }
    specify { expect(composition.substances[1].is_active_agent).to eq true }
  end

  context "Shire Fosrenol" do
    #   def initialize(column_c = nil, size = nil, unit = nil, active_substance = nil, composition= nil)
    active_substance = "lanthanum"
    composition_text = "lanthanum 500 mg ut lanthani (III) carbonas hydricum, excipiens pro compresso."
    composition = ParseUtil.parse_compositions(composition_text, active_substance).first
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.label).to eq nil }
    specify { expect(composition.label_description).to eq nil }
    specify { expect(composition.substances[0].is_active_agent).to eq true }
    specify { expect(composition.substances[0].name).to eq "Lanthanum 500 Mg Ut Lanthani (iii) Carbonas Hydricum" }
  end

  context "should return label with description" do
    string = "I) Glucoselösung: glucosum anhydricum 240 g ut glucosum monohydricum, calcii chloridum dihydricum 600 mg, acidum citricum monohydricum, aqua ad iniectabilia q.s. ad solutionem pro 500 ml."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 3 }
    specify { expect(composition.label).to eq "I" }
    specify { expect(composition.label_description).to eq "Glucoselösung" }
  end

  context "should handle label-description for Cyclacur" do
    # 37987 1   Cyclacur, Dragées
    string = "I) Weisse Dragées: estradioli valeras 2 mg, excipiens pro compresso obducto."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.label).to eq "I" }
    specify { expect(composition.label_description).to eq "Weisse Dragées" }
    specify { expect(composition.substances.first.name).to eq "Estradioli Valeras" }
  end

  context "should handle label-description for Moviprep" do
    # 61631   1   Moviprep Orange, Pulver
    string = "A): macrogolum 3350 100 g, natrii sulfas anhydricus 7.5 g, natrii chloridum 2.691 g, kalii chloridum 1.015 g, arom.: aspartamum et alia, excipiens ad pulverem pro charta."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 6 }
    specify { expect(composition.label).to eq "A" }
    specify { expect(composition.label_description).to eq nil }
    specify { expect(composition.substances.first.name).to eq "Macrogolum 3350" }
  end

  context "should handle 'LA 2x%" do
    # 48473 1   Wala Echinacea-Mundspray, anthroposophisches Arzneimittel
    string = "echinacea pallida ex herba LA 20% TM 10 g"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.name).to eq "Echinacea Pallida Ex Herba La 20% Tm" }
  end

  context "should handle 'CRM 197" do
    # 1 Prevenar 13, Suspension in Fertigspritzen
    string = "proteinum corynebacteriae diphtheriae CRM 197 ca. 32 µg"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.name).to eq "Proteinum Corynebacteriae Diphtheriae Crm 197" }
  end

  context "should handle ', Corresp. '" do
    # 65427 1   Adlers Bronchialpastillen, Pastillen
    string = "liquiritiae extractum ethanolicum liquidum corresp. acidum glycyrrhizinicum 2.0-2.6 mg, DER: 1.8-2.1:1, Corresp. massa siccata 19.67 mg, droserae extractum ethanolicum liquidum, ratio: 0.6:1, Corresp. massa siccata 0.42 mg, plantaginis folii extractum ethanolicum liquidum, ratio: 0.51:1, Corresp. massa siccata 1.9 mg, aromatica, natrii cyclamas, excipiens pro pastillo"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 6 }
    specify { expect(composition.substances.first.name).to eq "Liquiritiae Extractum Ethanolicum Liquidum" }
  end

  context "should handle ',,'" do
    # 52433 1   Botox 100 Allergan-Einheiten, Pulver zur Herstellung einer Injektionslösung
    string = "Praeparatio cryodesiccata: toxinum botulinicum A 100 U. Botox,, albuminum humanum, natrii chloridum, pro vitro."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 3 }
    specify { expect(composition.substances.first.name).to eq "Toxinum Botulinicum A" }
    specify { expect(composition.excipiens.name).to match(/vitro/i) }
  end

  context "should handle corresp. excipiens" do
    string = "petasina 8 mg corresp. excipiens pro compresso obducto"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.name).to eq "Petasina" }
    specify { expect(composition.excipiens.name).to match(/excipiens/i) }
  end

  context "should handle missing Label A:) in pollinis allergeni extractu" do
    # 62573   2   Staloral 300 3 Bäume (300 IR/ml) , sublinguale Lösung
    string = "III): pro usu: I) et II) recenter radioactivatum 99m-technetio ut natrii pertechnetas"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.size).to eq 0 }
    specify { expect(composition.label).to eq nil }
    specify { expect(composition.corresp).to eq "III): pro usu: I) et II) recenter radioactivatum 99m-technetio ut natrii pertechnetas" }
  end

  context "should handle Tela cum praeparatione" do
    string = "Tela cum praeparatione (Panel 1): niccoli sulfas 0.16 mg, alcoholes adipis lanae 0.81 mg, neomycini sulfas 0.49 mg, kalii dichromas 44 µg, Cain-mix: benzocainum 0.364 mg, cinchocaini hydrochloridum 73 µg, tetracaini hydrochloridum 73 µg, Parfum-Mix: amylcinnamaldehydum 15 µg, isoeugenolum 15 µg, cinnamaldehydum 34 µg, eugenolum 34 µg, alcohol cinnamylicus 54 µg, hydroxycitronellalum 54 µg, geraniolum 70 µg, evernia prunastri 70 µg, colophonium 0.97 mg, E 320, E 321, Paraben-Mix: E 218 0.16 mg, E 214 0.16 mg, E 216 0.16 mg, butylis parahydroxybenzoas 0.16 mg, benzylis parahydroxybenzoas 0.16 mg, Negativ-Kontrolle, balsamum peruvianum 0.65 mg, ethylendiamini dihydrochloridum 41 µg, cobalti dichloridum 16 µg, excipiens pro praeparatione"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.first.name).to eq "Niccoli Sulfas" }
    specify { expect(composition.label).to eq "Tela cum praeparatione (Panel 1):" }
  end

  context "should handle '&' and 'deklr.'" do
    string = "TM: cardiospermum halicacabum 100 mg, cetearyl octanoat & isopropylmyristat deklar., alcohol benzylicus, aqua q.s. ad unguentum pro"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.first.name).to eq "Tm: Cardiospermum Halicacabum" }
  end

  context "should handle '150 U.I. hFSH et 150 U.I. hLH'" do
    string = "Praeparatio cryodesiccata: menotropinum 150 U.I. hFSH et 150 U.I. hLH, gonadotropinum chorionicum 7-21 U.I. hCG, lactosum monohydricum, pro vitro"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.first.name).to eq "Menotropinum" }
    specify { expect(composition.substances.first.dose.to_s).to eq "150 U.I. hFSH et 150 U.I. hLH" }
  end

  context "should handle missing arom.: before excipiens" do
    string = "nicotinum 4 mg ut nicotini resinas, aromatica, antiox.: E 321, arom.: excipiens pro praeparatione"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.size).to eq 3 }
    specify { expect(composition.substances.first.name).to eq "Nicotinum" }
  end

  context "should handle missing Label A:) in pollinis allergeni extractu" do
    # 62573   2   Staloral 300 3 Bäume (300 IR/ml) , sublinguale Lösung
    string = "pollinis allergeni extractum (alnus glutinosa, betula alba, corylus avellana) 300 U.: excipiens ad solutionem pro 1 ml"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.name).to eq "Pollinis Allergeni Extractum (alnus Glutinosa, Betula Alba, Corylus Avellana)" }
    specify { expect(composition.label).to eq nil }
  end

  context "handle 39541 A. Vogel Entspannungs-Tropfen" do
    string = "passiflorae herbae recentis tinctura, ratio: 1:12, corresp. ethanolum 65 % V/V"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.name).to eq "Passiflorae Herbae Recentis Tinctura" }
    specify { expect(composition.substances.first.more_info).to eq "ratio: 1:12" }
  end

  context "handle II) Aprotininlösung:" do
    string = "II) Aprotininlösung: aprotininum 1000 U.K.I., natrii chloridum, aqua q.s. ad solutionem, pro vitro 1 ml"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 2 }
    specify { expect(composition.substances.first.name).to eq "Aprotininum" }
  end

  context "handle ut aqua ad" do
    string = "natrii oleas ut aqua ad iniectabilia q.s. ad emulsionem pro 250 ml"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.name).to eq "Natrii Oleas" }
  end

  context "find unit for aqua q.s. ad emulsionem pro 250 ml" do
    string = "natrii oleas, aqua q.s. ad emulsionem pro 250 ml."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.excipiens.dose.to_s).to eq "250 ml" }
    specify { expect(composition.excipiens.name).to match(/emulsionem/i) }
  end

  context "should handle '150 U.I. hFSH et 150 U.I. hLH'" do
    string = "Praeparatio cryodesiccata: menotropinum 150 U.I. hFSH et 150 U.I. hLH, gonadotropinum chorionicum 7-21 U.I. hCG, lactosum monohydricum, pro vitro"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.first.name).to eq "Menotropinum" }
    specify { expect(composition.substances.first.dose.to_s).to eq "150 U.I. hFSH et 150 U.I. hLH" }
  end

  context "should handle per centum" do
    string = "acidum nitricum 70 per centum 537 mg, acidum aceticum glaciale 20.4 mg, acidum oxalicum dihydricum 58.6 mg, zinci nitras hexahydricus 6 mg, excipiens ad solutionem pro 1 ml"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.first.name).to eq "Acidum Nitricum 70 Per Centum" }
  end

  context "should handle 'potenziert mit: excipiens pro compresso'" do
    string = "ambra grisea D6 30 mg, conium maculatum D3 30 mg, anamirta cocculus D4 210 mg, petroleum rectificatum D8 30 mg, potenziert mit: excipiens pro compresso"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.label).to eq nil }
    specify { expect(composition.label_description).to eq nil }
    specify { expect(composition.galenic_form).to eq nil }
    specify { expect(composition.route_of_administration).to eq nil }
    specify { expect(composition.substances.first.name).to eq "Ambra Grisea D6" }
  end

  context "allow ut followed by et" do
    # 49417 1   Burgerstein EPA-Kapseln 500mg, Kapseln
    string =
      "piscis oleum 500 mg corresp. acida carboxylica omega-3 oligoinsaturata 150 mg ut acidum eicosapentaenoicum 90 mg et acidum docosahexaenoicum 60 mg, excipiens pro capsula."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.first.name).to eq "Piscis Oleum" } # TODO:
    specify { expect(composition.substances.first.chemical_substance.name).to eq "Acida Carboxylica Omega-3 Oligoinsaturata" } # TODO:
    specify { expect(composition.substances.size).to eq 2 }
    specify { expect(composition.substances.first.salts.size).to eq 0 }
    specify { expect(composition.substances.first.chemical_substance.salts.size).to eq 1 }
    specify { expect(composition.substances.first.chemical_substance.salts.first.name).to eq "Acidum Eicosapentaenoicum" }
  end

  context "find correct result Solvens (i.m.)" do
    string = "Solvens (i.m.): aqua ad iniectabilia 2 ml pro vitro"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 0 }
    specify { expect(composition.corresp).to eq "aqua ad iniectabilia 2 ml pro vitro" }
  end

  context "allow substancename with 'ethanol.'" do
    string = "mandragora ethanol. decoctum D1 30 mg"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.name).to eq "Mandragora Ethanol. Decoctum D1" }
    specify { expect(composition.substances.first.dose.to_s).to eq "30 mg" }
  end

  context "allow substance complicated, calculated dose '6.0 +/-1.2 µg'" do
    string =
      "enzephalitidis japanensis virus antigenum (Stamm: SA-14-2) 6.0 +/-1.2 µg, aluminium ut aluminii oxidum hydricum, kalii dihydrogenophosphas, dinatrii phosphas anhydricus, natrii chloridum, aqua q.s. ad solutionem pro 0.5 ml"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.first.name).to eq "Enzephalitidis Japanensis Virus Antigenum (stamm: Sa-14-2)" }
    specify { expect(composition.substances.first.chemical_substance).to eq nil }
    specify { expect(composition.substances.first.dose.to_s).to eq "6.0 +/-1.2 µg/0.5 ml" }
    specify { expect(composition.substances.size).to eq 5 }
  end

  context "should handle 'aqua ad iniectabilia ad solutionem'" do
    string = "aqua ad iniectabilia ad solutionem"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 0 }
    specify { expect(composition.corresp).to match(/ad iniectabilia/) }
  end

  context "should handle Corresp. ca. 8370 kJ" do
    string = "Corresp. ca. 8370 kJ"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 0 }
    specify { expect(composition.corresp).to match(/8370 kJ/i) }
  end

  context "should handle Praeparatio sicca and polysorbatum" do
    string = "Praeparatio sicca cum solvens: praeparatio sicca: albiglutidum 66.95 mg, trehalosum dihydricum, mannitolum, dinatrii phosphas anhydricus, natrii dihydrogenophosphas monohydricus, polysorbatum 80, solvens: aqua ad iniectabilia 0.65 ml pro vitro"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.first.name).to eq "Albiglutidum" }
    specify { expect(composition.label).to eq "Praeparatio sicca cum solvens: praeparatio sicca:" }
  end

  context "handle placebo compressa: excipiens pro compresso obducto" do
    string = "II) placebo compressa: excipiens pro compresso obducto"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 0 }
    specify { expect(composition.label).to eq "II" }
    specify { expect(composition.label_description).to eq "placebo compressa" }
  end

  context "handle 46489 Polvac Gräser+Roggen" do
    string = "A): pollinis allergeni extractum 300 U. (secali cereale cum 12 gramina: Arrhenatherum elatius, Cynosurus cristatus, Dactylis glomerata, Lolium spp., Poa pratensis, Anthoxanthum odoratum, Festuca pratensis, Agrostis tenuis, Bromus ssp., Alopecurus pratensis, Phleum pratense, Holcus lanatus), tyrosinum, natrii chloridum, glycerolum, conserv.: phenolum 2.5 mg, aqua ad iniectabilia q.s. ad solutionem pro 0.5 ml."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 5 }
    tyrosinum = composition.substances.find { |x| /Tyrosinum/i.match(x.name) }
    specify { expect(composition.substances.first.name).to eq "Pollinis Allergeni Extractum 300 U. (secali Cereale Cum 12 Gramina: Arrhenatherum Elatius, Cynosurus Cristatus, Dactylis Glomerata, Lolium Spp., Poa Pratensis, Anthoxanthum Odoratum, Festuca Pratensis, Agrostis Tenuis, Bromus Ssp., Alopecurus Pratensis, Phleum Pratense, Holcus Lanatus)" }
    specify { expect(tyrosinum.name).to eq "Tyrosinum" }
    specify { expect(composition.label).to eq "A" }
  end

  context "handle ratio" do
    string =
      "digestio aquosa 500 mg ex dryopteris filix-mas ex herba recenti 40 mg, pteridium aquilinum ex herba recenti 40 mg, polypodium vulgare ex herba recenti 10 mg, Phyllitis scolopendrium ex herba recenti 10 mg, ratio: 1:4,1, extractum ethanolicum 400 mg ex salicis albae folium recens 20 mg, salicis purpureae folium recens 20 mg, salicis viminalis folium recens 40 mg, salicis vitellinae folium recens 20 mg, ratio: 1:3,1, excipiens ad solutionem pro 1 g, corresp. 10 guttae, corresp. ethanolum 25 % V/V"
    composition = ParseComposition.from_string(string)
    substance = composition.substances.find { |x| /Scolopendrium/i.match(x.name) }
    specify { expect(substance.name).to eq "Phyllitis Scolopendrium Ex Herba Recenti" }
    specify { expect(substance.more_info).to eq "ratio: 1:4,1" }
  end

  context "should skip lines containing I) et II)" do
    string = "I) et II) et III) corresp.: aminoacida 48 g/l, carbohydrata 150 g/l, materia crassa 50 g/l, in emulsione recenter mixta 1250 ml"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.size).to eq 0 }
    specify { expect(composition.corresp).to eq string }
  end

  context "should handle dose with /" do
    string = "poly(dl-lactidum-co-glycolidum) 75/25"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.first.name).to eq "Poly(dl-lactidum-co-glycolidum)" }
    specify { expect(composition.substances.first.dose.to_s).to eq "75/25" }
  end

  context "should handle dose with +/-" do
    string = "enzephalitidis japanensis virus antigenum (Stamm: SA-14-2) 6.0 +/-1.2 µg, aluminium ut aluminii oxidum hydricum, kalii dihydrogenophosphas, dinatrii phosphas anhydricus, natrii chloridum, aqua q.s. ad solutionem pro 0.5 ml"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.first.name).to eq "Enzephalitidis Japanensis Virus Antigenum (stamm: Sa-14-2)" }
    specify { expect(composition.substances.first.dose.to_s).to eq "6.0 +/-1.2 µg/0.5 ml" }
  end

  context "should handle label Praeparatio cryodesiccata (Thrombin)" do
    string = "Praeparatio cryodesiccata (Thrombin): thrombinum humanum 500 U.I., natrii chloridum, natrii citras dihydricus, pro vitro"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.first.name).to eq "Thrombinum Humanum" }
    specify { expect(composition.label).to eq "Praeparatio cryodesiccata (Thrombin):" }
  end
end

describe ParseComposition do
  context "allow 2,2'-methylen-bis(6-tert.-butyl-4-methyl-phenolum)" do
    string = "2,2'-methylen-bis(6-tert.-butyl-4-methyl-phenolum)"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.first.name).to eq "2,2'-methylen-bis(6-tert.-butyl-4-methyl-phenolum)" }
    specify { expect(composition.substances.size).to eq 1 }
  end

  context "allow substancename with 90 % " do
    string =
      "acidum nitricum 70 per centum 580.66 mg, acidum aceticum glaciale 41.08 mg, acidum oxalicum dihydricum 57.32 mg, acidum lacticum 90 % 4.55 mg, cupri(II) nitras trihydricus 0.048 mg, excipiens ad solutionem pro 1 ml"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 5 }
    substance = composition.substances.find { |x| /lacticum/i.match(x.name) }
    specify { expect(composition.substances.first.name).to eq "Acidum Nitricum 70 Per Centum" }
    specify { expect(composition.substances.first.dose.to_s).to eq "580.66 mg/ml" }
    specify { expect(substance.name).to eq "Acidum Lacticum 90 %" }
    specify { expect(substance.dose.to_s).to eq "4.55 mg/ml" }
  end

  context "allow substance with two corresp" do
    string = "magnesii aspartas dihydricus 3.895 g corresp. magnesium 292 mg corresp. 12 mmol, arom.: bergamottae aetheroleum et alia, natrii cyclamas, saccharinum natricum, excipiens ad granulatum pro charta"
    composition = ParseComposition.from_string(string)
    context "with correct names" do
      skip { expect(composition.substances.first.name).to eq "Magnesii Aspartas Dihydricus" }
      skip { expect(composition.substances.first.chemical_substance.name).to eq "Magnesium" }
    end
    specify { expect(composition.substances.size).to eq 6 }
  end

  context "allow substances containing ut, corresp, arom," do
    string = "calcii carbonas 3 g corresp. calcium 1.2 g, cholecalciferolum 800 U.I. ut cholecalciferoli pulvis corresp. arom.: saccharinum, natrii cyclamas et alia, excipiens pro compresso"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 4 }
  end

  context "allow substances containing 'A + '" do
    string = "sennosida 20 mg corresp. sennosida A + B calcica 12 mg, excipiens pro compresso obducto"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.name).to eq "Sennosida" }
    specify { expect(composition.substances.first.chemical_substance.name).to eq "Sennosida A + B Calcica" }
  end

  context "allow substances separted by ', et'" do
    string = "extractum spissum ex: echinaceae purpureae herbae recentis tinctura 1140 mg, ratio: 1:12, et echinaceae purpureae radicis recentis tinctura 60 mg, ratio: 1:11, excipiens pro compresso"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 2 }
    specify { expect(composition.substances.first.name).to eq "Echinaceae Purpureae Herbae Recentis Tinctura" }
    specify { expect(composition.substances.last.name).to eq "Echinaceae Purpureae Radicis Recentis Tinctura" }
  end

  context "find kalium 40 mmol/l" do
    string = "kalium 40 mmol/l, chloridum 194 mmol/l, natrium 154 mmol/l, aqua ad iniectabilia q.s. ad solutionem pro 1000 ml"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 3 }
    specify { expect(composition.substances.first.name).to eq "Kalium" }
    specify { expect(composition.substances.first.dose.to_s).to eq "40 mmol/l/1000 ml" }
  end

  context "find  corresp doses pro vase." do
    string = "farfarae folii recentis succus ratio: 1:0.68-0.95"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.last.name).to eq "Farfarae Folii Recentis Succus" }
    specify { expect(composition.substances.last.more_info).to eq "ratio: 1:0.68-0.95" }
  end

  context "find  corresp doses pro vase." do
    string = "doses pro vase 30/60"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 0 }
    specify { expect(composition.corresp).to match(/pro vase/i) }
  end

  context "find  corresp. ca." do
    string = "sal ems 100 % m/m, corresp. ca., natrium 308.7 mg/g"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.last.name).to eq "Sal Ems" }
  end

  context "find correct result Solvens (i.m.)" do
    string = "Solvens (i.v.): aqua ad iniectabilia 5 ml, corresp. 20 mg, pro 5 ml"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.first).to eq nil }
  end

  context "find correct result for dose 1 Mio U.I." do
    string = "phenoxymethylpenicillinum kalicum 1 Mio U.I., conserv.: E 200, excipiens pro compresso obducto"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 2 }
    specify { expect(composition.substances.first.name).to eq "Phenoxymethylpenicillinum Kalicum" }
    specify { expect(composition.substances.first.dose.to_s).to eq "1 Mio U.I." }
    specify { expect(composition.substances.last.name).to eq "E 200" }
  end

  context "find dose with max." do
    string = "residui: formaldehydum max. 100 µg"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.last.name).to eq "Formaldehydum" }
  end

  context "handle Corresp. 4000 kJ." do
    composition = ParseComposition.from_string("Corresp. 4000 kJ.")
    specify { expect(composition.substances.size).to eq 0 }
    specify { expect(composition.corresp).to eq "4000 kJ" }
  end

  context "handle dose dose with g/dm²" do
    string = "Tela cum unguento 14 g/dm²"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.dose.to_s).to eq "14 g/dm²" }
    specify { expect(composition.substances.first.name).to eq "Tela Cum Unguento" }
  end

  context "handle dose  2*10^9 CFU," do
    string = "saccharomyces boulardii cryodesiccatus 250 mg corresp. cellulae vivae 2*10^9 CFU, excipiens pro capsula"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.chemical_substance.dose.to_s).to eq "2*10^9 CFU" }
    specify { expect(composition.substances.first.name).to eq "Saccharomyces Boulardii Cryodesiccatus" }
  end

  context "handle dose followed by ratio" do
    # 43996 1   Keppur, Salbe
    string = "symphyti radicis recentis extractum ethanolicum liquidum 280 mg ratio: 1:3-4"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.name).to eq "Symphyti Radicis Recentis Extractum Ethanolicum Liquidum" }
  end

  context "find correct result Überzug: E 132" do
    string = "olanzapinum 15 mg, Überzug: E 132, excipiens pro compresso obducto."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 2 }
    specify { expect(composition.substances.first.name).to eq "Olanzapinum" }
    specify { expect(composition.substances.last.name).to eq "E 132" }
    specify { expect(composition.substances.last.more_info).to eq "Überzug" }
  end

  context "should handle ut followed by corresp. " do
    # 65302 1   Exviera 250 mg, Filmtabletten
    string = "dasabuvirum 250 mg ut dasabuvirum natricum corresp. dasabuvirum natricum monohydricum 270.26 mg, excipiens pro compresso obducto"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.label).to eq nil }
    specify { expect(composition.label_description).to eq nil }
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.name).to eq "Dasabuvirum" }
    specify { expect(composition.substances.first.salts.size).to eq 1 }
    specify { expect(composition.substances.first.salts.first.name).to eq "Dasabuvirum Natricum" }
    specify { expect(composition.substances.first.salts.first.chemical_substance.name).to eq "Dasabuvirum Natricum Monohydricum" }
  end

  context "find correct result for ut excipiens" do
    string = "drospirenonum 3 mg, ethinylestradiolum 20 µg ut excipiens pro compresso obducto"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 2 }
    specify { expect(composition.substances.last.name).to eq "Ethinylestradiolum" }
  end

  context "find correct result compositions for DER: followed by corresp." do
    # 16863 1   Salvia Wild, Tropfen
    string = "salviae extractum ethanolicum liquidum, DER: 1:4.2-5.0 corresp. ethanolum 40 % V/V"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 2 }
    specify { expect(composition.substances[1].name).to eq "DER: 1:4.2-5.0" }
  end

  context "find correct result compositions for 00613 Pentavac" do
    line_1 = "I) DTPa-IPV-Komponente (Suspension): toxoidum diphtheriae 30 U.I., toxoidum tetani 40 U.I., toxoidum pertussis 25 µg et haemagglutininum filamentosum 25 µg, virus poliomyelitis typus 1 inactivatum (D-Antigen) 40 U., virus poliomyelitis typus 2 inactivatum (D-Antigen) 8 U., virus poliomyelitis typus 3 inactivatum (D-Antigen) 32 U., aluminium ut aluminii hydroxidum hydricum ad adsorptionem, formaldehydum 10 µg, conserv.: phenoxyethanolum 2.5 µl, residui: neomycinum, streptomycinum, polymyxini B sulfas, medium199, aqua q.s. ad suspensionem pro 0.5 ml."
    line_2 = "II) Hib-Komponente (Lyophilisat): haemophilus influenzae Typ B polysaccharida T-conjugatum 10 µg, trometamolum, saccharum, pro praeparatione."
    txt = "#{line_1}\n#{line_2}"
    # composition = ParseComposition.from_string(line_1)
    # composition = ParseComposition.from_string(line_2)
    info = ParseUtil.parse_compositions(txt)

    specify { expect(info.first.label).to eq "I" }
    specify { expect(info.size).to eq 2 }
    specify { expect(info.first.substances.size).to eq 14 }
    toxoidum = info.first.substances.find { |x| x.name.match(/Toxoidum Diphtheriae/i) }
    specify { expect(toxoidum.class).to eq ParseSubstance }
    if toxoidum
      specify { expect(toxoidum.name).to eq "Toxoidum Diphtheriae" }
      specify { expect(toxoidum.qty.to_f).to eq 30.0 }
      specify { expect(toxoidum.unit).to eq "U.I./0.5 ml" }
    end
  end

  context "find correct result compositions for fluticasoni with chemical_dose" do
    string = "fluticasoni-17 propionas 100 µg, lactosum monohydricum q.s. ad pulverem pro 25 mg."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 2 }
    fluticasoni = composition.substances.find { |x| x.name.match(/Fluticasoni/i) }
    specify { expect(fluticasoni.name).to eq "Fluticasoni-17 Propionas" }
    specify { expect(fluticasoni.qty.to_f).to eq 100.0 }
    specify { expect(fluticasoni.unit).to eq "µg/25 mg" }
    specify { expect(fluticasoni.dose.to_s).to eq "100 µg/25 mg" }
    lactosum = composition.substances.find { |x| x.name.match(/Lactosum/i) }
    specify { expect(lactosum.name).to eq "Lactosum Monohydricum" }
    skip { expect(lactosum.dose.to_s).to eq "25 mg" }
  end

  context "find correct result Solvens (i.m.)" do
    string = "Solvens (i.m.): aqua ad iniectabilia 2 ml pro vitro"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 0 }
    specify { expect(composition.corresp).to eq "aqua ad iniectabilia 2 ml pro vitro" }
  end

  context "should handle Iscador" do
    # 56829 sequence 3 Iscador M
    string = "extractum aquosum liquidum fermentatum 0.05 mg ex viscum album (mali) recens 0.01 mg, natrii chloridum, aqua q.s. ad solutionem pro 1 ml."
    composition = ParseComposition.from_string(string)
    viscum = composition.substances.find { |x| x.name.match(/viscum/i) }
    specify { expect(viscum.name).to eq "Extractum Aquosum Liquidum Fermentatum 0.05 Mg Ex Viscum Album (mali) Recens" }
    specify { expect(viscum.qty).to eq 0.01 } # 0.0001 mg/ml
    specify { expect(viscum.unit).to eq "mg/ml" } # 0.0001 mg/ml
    specify { expect(viscum.dose.qty).to eq 0.01 } # 0.0001 mg/ml
    specify { expect(viscum.dose.unit).to eq "mg/ml" } # 0.0001 mg/ml
    specify { expect(viscum.dose.to_s).to eq "0.01 mg/ml" } # 0.0001 mg/ml
    specify { expect(composition.source).to eq string }
  end

  context "find correct result compositions for poloxamerum" do
    # 47657   1   Nanocoll, Markierungsbesteck
    string = "I): albuminum humanum colloidale 0.5 mg, stanni(II) chloridum dihydricum 0.2 mg, glucosum anhydricum, dinatrii phosphas monohydricus, natrii fytas (9:1), poloxamerum 238, q.s. ad pulverem pro vitro."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 6 }
    poloxamerum = composition.substances.find { |x| x.name.match(/poloxamerum/i) }
    specify { expect(poloxamerum.name).to eq "Poloxamerum 238" }
    specify { expect(poloxamerum.qty.to_f).to eq 0.0 }
    specify { expect(poloxamerum.unit).to eq nil }
  end

  context "should handle DER followed by corresp" do
    # 54024 1   Nieren- und Blasendragées S
    string = "DER: 4-5:1, corresp. arbutinum 24-30 mg"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.label).to eq nil }
    specify { expect(composition.label_description).to eq nil }
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.name).to eq "DER: 4-5:1" }
    specify { expect(composition.substances.first.chemical_substance.name).to eq "Arbutinum" }
  end

  context "should handle 'A): macrogolum 3350 100 g'" do
    # 57900 1   Moviprep, Pulver
    string = "A): macrogolum 3350 100 g, natrii sulfas anhydricus 7.5 g"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.label).to eq "A" }
    specify { expect(composition.label_description).to eq nil }
    specify { expect(composition.substances.size).to eq 2 }
    specify { expect(composition.substances.first.name).to eq "Macrogolum 3350" }
    specify { expect(composition.substances.first.qty).to eq 100 }
    specify { expect(composition.substances.first.unit).to eq "g" }
  end

  context "should able to handle a simple ratio" do
    string = "allii sativi maceratum oleosum 270 mg, ratio: 1:10, excipiens pro capsula."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.name).to eq "Allii Sativi Maceratum Oleosum" }
    specify { expect(composition.substances.first.more_info).to eq "ratio: 1:10" }
  end

  context "should able to handle multiple ratio" do
    # 25273   1   Schoenenberger naturreiner Heilpflanzensaft, Thymian
    string = "thymi herbae recentis extractum aquosum liquidum, ratio: 1:1.5-2.4."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.name).to eq "Thymi Herbae Recentis Extractum Aquosum Liquidum" }
    specify { expect(composition.substances.first.more_info).to eq "ratio: 1:1.5-2.4" }
  end

  context "should handles lines containing V): mannitolum 40 mg pro dosi" do
    string = "V): mannitolum 40 mg pro dosi"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.label).to eq "V" }
    specify { expect(composition.substances.size).to eq 1 }
  end

  context "should treat correctly CFU units" do
    # 56015 Perskindol Cool avec consoude, gel
    string = "lactobacillus acidophilus cryodesiccatus min. 10^9 CFU"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.first.name).to eq "Lactobacillus Acidophilus Cryodesiccatus" }
    specify { expect(composition.substances.first.qty).to eq "10^9" }
    specify { expect(composition.substances.first.unit).to eq "CFU" }
  end

  context "should pass several () inside a name" do
    composition = nil
    strings = [
      "a(eine klammer) und nachher",
      "(eine klammer) und nachher",
      "haemagglutininum influenzae A (eine klammer)",
      "haemagglutininum influenzae A (eine klammer) und nachher",
      "haemagglutininum influenzae A (H1N1) (in Klammer)",
      "haemagglutininum influenzae A (H1N1) or (H5N3) (in Klammer) more",
      "haemagglutininum influenzae A (H1N1) eins (second) even more",
      "ab (H1N1)-like: dummy",
      "Virus-Stamm A/California/7/2009 (H1N1)-like: reassortant virus NYMC X-179A",
      "haemagglutininum influenzae A (H1N1) (Virus-Stamm A/California/7/2009 (H1N1)-like: reassortant virus NYMC X-179A)"
    ].each { |string|
      composition = ParseComposition.from_string(string)
    }
    composition = ParseComposition.from_string(strings.last + " 15 µg")
    specify { expect(composition.substances.first.name.downcase).to eq strings.last.downcase }
    specify { expect(composition.substances.first.qty).to eq 15 }
    specify { expect(composition.substances.first.unit).to eq "µg" }
  end

  context "should emit correct unit when excipiens contains pro X ml" do
    string = "glatiramerum acetas 20 mg corresp. glatiramerum 18 mg, mannitolum, aqua ad iniectabilia q.s. ad solutionem pro 0.5 ml."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.first.name).to eq "Glatiramerum Acetas" }
    specify { expect(composition.substances.first.qty).to eq 20 }
    specify { expect(composition.substances.first.unit).to eq "mg/0.5 ml" }
    specify { expect(composition.substances.first.chemical_substance.unit).to eq "mg/0.5 ml" }
    specify { expect(composition.substances.first.chemical_substance.name).to eq "Glatiramerum" }
    specify { expect(composition.substances.first.chemical_substance.qty).to eq 18 }
    specify { expect(composition.substances.first.chemical_substance.unit).to eq "mg/0.5 ml" }
  end

  context "should handle substance with a range" do
    string = "glyceroli monostearas 40-55"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.name).to eq "Glyceroli Monostearas" }
    specify { expect(composition.substances.first.dose.to_s).to eq "40-55" }
  end

  context "should handle mineralia with alia" do
    string = "mineralia: calcium 160 ut alia: ginseng extractum 50 mg"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 2 }
    specify { expect(composition.substances.first.salts.size).to eq 0 }
    specify { expect(composition.substances.first.name).to eq "Calcium" } # TODO:
    specify { expect(composition.substances.last.name).to eq "Ginseng Extractum" } # TODO:
    # TODO: specify { expect(composition.substances.first.dose.to_s).to eq '9 g/L 5 ml' }
  end

  context "should handle mineralia" do
    string = "mineralia: calcium 160 mg ut magnesium 120 mg ut ferrum 5.6 mg ut cuprum 1 mg ut manganum 1.4 mg ut iodum 60 µg ut molybdenum 60 µg"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.more_info).to eq "mineralia" }
    specify { expect(composition.substances.first.salts.size).to eq 6 }
    substance = composition.substances.first.salts.find { |x| /Magnesium/i.match(x.name) }
    specify { expect(substance.name).to eq "Magnesium" }
    specify { expect(substance.qty).to eq 120.0 }
    specify { expect(substance.unit).to eq "mg" }
    specify { expect(composition.substances.first.name).to eq "Calcium" } # TODO:
    # TODO: specify { expect(composition.substances.first.dose.to_s).to eq '9 g/L 5 ml' }
  end

  context "should handle Solvens line" do
    string = "Solvens: natrii chloridi solutio 9 g/L 5 ml."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 0 }
    specify { expect(composition.corresp).to eq "natrii chloridi solutio 9 g/L 5 ml" }
    skip { expect(composition.excipiens.substance.name).to eq "Natrii Chloridi Solutio" }
  end

  context "should parse a complex composition" do
    composition = ParseUtil.parse_compositions(
      "globulina equina (immunisé avec coeur) 8 mg",
      "globulina equina (immunisé avec coeur)"
    ).first
    specify { expect(composition.substances.size).to eq 1 }
    globulina = composition.substances.find { |x| /globulina/i.match(x.name) }
    specify { expect(globulina.name).to eq "Globulina Equina (immunisé Avec Coeur)" }
    specify { expect(globulina.is_active_agent).to eq true }
    specify { expect(globulina.qty).to eq 8 }
    specify { expect(globulina.unit).to eq "mg" }
  end

  context "should parse globulina equina (immunise" do
    composition = ParseUtil.parse_compositions(
      "globulina equina (immunisé avec coeur, Tissu Pulmonaire, Reins De Porcins) 8 mg",
      "globulina equina (immunisé avec coeur, Tissu Pulmonaire, Reins De Porcins)"
    ).first
    specify { expect(composition.substances.size).to eq 1 }
    globulina = composition.substances.find { |x| /globulina/i.match(x.name) }
    specify { expect(globulina.name).to eq "Globulina Equina (immunisé Avec Coeur, Tissu Pulmonaire, Reins De Porcins)" }
    specify { expect(globulina.is_active_agent).to eq true }
    specify { expect(globulina.qty).to eq 8 }
    specify { expect(globulina.unit).to eq "mg" }
  end

  context "should return correct composition for containing '(acarus siro)" do
    string = "acari allergeni extractum (acarus siro) 50'000 U., conserv.: phenolum, excipiens ad solutionem pro 1 ml."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.size).to eq 2 } # got only 1
    specify { expect(composition.substances.first.more_info).to eq nil }
    specify { expect(composition.substances.first.name).to eq "Acari Allergeni Extractum (acarus Siro)" }
    specify { expect(composition.substances.last.name).to eq "Phenolum" } # was Acari Allergeni Extractum (acarus Siro)
    specify { expect(composition.substances.last.more_info).to match "conserv" }
  end

  context "should return correct composition for containing 'A): acari allergeni extractum 50 U' (IKSNR 60606)" do
    # Novo-Helisen Depot D. farinae/D. pteronyssinus Kombipackung 1-3, Injektionssuspension
    string =
      "A): acari allergeni extractum 50 U.: dermatophagoides farinae 50 % et dermatophagoides pteronyssinus 50 %, aluminium ut aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum, conserv.: phenolum 4.0 mg, aqua q.s. ad suspensionem pro 1 ml."
    composition = ParseComposition.from_string(string)
    composition.label_description
    specify { expect(composition.label).to eq "A" }
    specify { expect(composition.label_description).to eq "acari allergeni extractum 50 U." }
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.size).to eq 5 }
    pteronyssinus = composition.substances.find { |x| /pteronyssinus/i.match(x.name) }
    specify { expect(composition.substances.first.name).to eq "Dermatophagoides Farinae" }
    specify { expect(pteronyssinus.name).to eq "Dermatophagoides Pteronyssinus" }
    specify { expect(pteronyssinus.more_info).to eq nil }
  end

  context "should return correct composition for containing 'virus rabiei inactivatum" do
    string = "Praeparatio cryodesiccata: virus rabiei inactivatum (Stamm: Wistar Rabies PM/WI 38-1503-3M) min. 2.5 U.I."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.name).to eq "Virus Rabiei Inactivatum (stamm: Wistar Rabies Pm/wi 38-1503-3m)" }
    specify { expect(composition.substances.first.qty).to eq 2.5 }
    specify { expect(composition.substances.first.unit).to eq "U.I." }
    specify { expect(composition.label).to eq "Praeparatio cryodesiccata:" }
  end

  context "should return correct composition for containing Histamin Equivalent Pric. (e.g IKSNR 58566)" do
    # 58566 1   Soluprick SQ Phleum pratense, Lösung
    string = "pollinis allergeni extractum (Phleum pratense) 10 U., natrii chloridum, phenolum, glycerolum, aqua ad iniectabilia q.s. ad solutionem pro 1 ml, U = Histamin Equivalent Prick."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.size).to eq 4 }
    specify { expect(composition.substances.first.name).to eq "Pollinis Allergeni Extractum (phleum Pratense)" }
  end

  context "should handle aqua ad iniectabilia" do
    string = "any_substance, aqua ad iniectabilia q.s. ad solutionem pro 5 ml"
    composition = ParseComposition.from_string(string)
    # substance = composition.substances.last
    specify { expect(composition.excipiens.name).to eq "aqua ad iniectabilia q.s. ad solutionem" }
    specify { expect(composition.excipiens.chemical_substance).to eq nil }
    specify { expect(composition.excipiens.qty).to eq 5.0 }
    specify { expect(composition.excipiens.unit).to eq "ml" }
  end

  context "should return correct substance for 'excipiens ad solutionem pro 1 ml corresp. ethanolum 59.5 % V/V'" do
    string = "any_substance, excipiens ad solutionem pro 1 ml corresp. ethanolum 59.5 % V/V"
    composition = ParseComposition.from_string(string)
    # substance = composition.substances.first
    # TODO: what should we report here? dose = pro 1 ml or 59.5 % V/V, chemical_substance = ethanolum?
    # or does it only make sense as part of a composition?
    skip { expect(composition.excipiens.name).to eq "Ethanolum" }
    specify { expect(composition.excipiens.cdose).to eq nil }
    skip { expect(composition.excipiens.qty).to eq 59.5 }
    skip { expect(composition.excipiens.unit).to eq "% V/V" }
  end

  context "should return correct composition for 'excipiens ad emulsionem'" do
    string = 'something, excipiens ad emulsionem pro 1 g"'
    composition = ParseComposition.from_string(string)
    # substance = composition.substances.first
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.size).to eq 1 }
  end

  context "should return correct substance for 'aqua q.s. ad suspensionem pro 0.5 ml'" do
    string = "natrii dihydrogenophosphas dihydricus, aqua q.s. ad suspensionem pro 0.5 ml."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.excipiens.name).to match(/aqua|excipiens/) }
    specify { expect(composition.excipiens.qty).to eq 0.5 }
    specify { expect(composition.excipiens.unit).to eq "ml" }
  end

  context "should return correct substance for 'excipiens ad solutionem pro 3 ml corresp. 50 µg'" do
    string = "any_substance, excipiens ad solutionem pro 3 ml corresp. 50 µg"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.excipiens.name).to match(/Excipiens/i) }
    specify { expect(composition.excipiens.qty).to eq 3.0 }
    specify { expect(composition.excipiens.unit).to eq "ml" }
    specify { expect(composition.excipiens.cdose.qty).to eq 50.0 }
    specify { expect(composition.excipiens.cdose.unit).to eq "µg" }
  end

  context "should return correct substance for 'excipiens ad pulverem pro 1000 mg'" do
    string = "any_substance, excipiens ad pulverem pro 1000 mg"
    CompositionTransformer.clear_substances
    composition = ParseComposition.from_string(string)
    specify { expect(composition.excipiens.name).to match(/Excipiens/) }
    specify { expect(composition.excipiens.qty).to eq 1000.0 }
    specify { expect(composition.excipiens.unit).to eq "mg" }
  end

  context "should pass with 'etinoli 7900 U.I'" do
    string = "retinoli 7900 U.I."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.qty).to eq 7900.0 }
    specify { expect(composition.substances.first.unit).to eq "U.I." }
    specify { expect(composition.substances.first.name).to eq "Retinoli" }
  end

  context "should return correct composition for containing 'absinthii herba 1.2 g pro charta" do
    string = "absinthii herba 1.2 g pro charta"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.name).to eq "Absinthii Herba" }
  end

  context "should return correct composition for containing 'ad pulverem'" do
    string = "pimpinellae radix 15 % ad pulverem"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.name).to eq "Pimpinellae Radix" }
  end

  context "should return correct composition for 'DER: 6:1'" do
    string = "DER: 6:1"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.name).to eq string }
  end

  context "should return correct composition for containing ' ut procaini hydrochloridum" do
    string =
      "procainum 10 mg ut procaini hydrochloridum"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.name).to eq "Procainum" }
    specify { expect(composition.substances.first.salts.first.name).to eq "Procaini Hydrochloridum" }
  end

  context "should return correct composition for containing 'ad pulverem'" do
    string =
      # "absinthii herba 15 %, anisi fructus 15 %, carvi fructus 15 %, foeniculi fructus 15 %, iuniperi pseudofructus 10 %, millefolii herba 15 %, pimpinellae radix 15 % ad pulverem.\n"
      "pimpinellae radix 15 % ad pulverem.\n"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.name).to eq "Pimpinellae Radix" }
    specify { expect(composition.substances.first.qty).to eq 15.0 }
    specify { expect(composition.substances.first.unit).to eq "%" }
  end

  context "should return correct composition for containing 'excipiens ad globulos" do
    string =
      "abrus precatorius C6, aconitum napellus C6, atropa belladonna C6, calendula officinalis C6, chelidonium majus C6, viburnum opulus C6 ana partes, excipiens ad globulos.\n"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.size).to eq 6 }
    specify { expect(composition.substances.first.name).to eq "Abrus Precatorius C6" }
  end

  context "should return correct composition for containing 'arom.: E 104'" do
    string = "gentianae radix 12 mg, primulae flos 36 mg, rumicis acetosae herba 36 mg, sambuci flos 36 mg, verbenae herba 36 mg, color.: E 104 et E 132, excipiens pro compresso obducto."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.size).to eq 7 }
    e104 = composition.substances.find { |x| x.name.eql?("E 104") }

    specify { expect(e104.name).to eq "E 104" }
    specify { expect(composition.substances.first.name).to eq "Gentianae Radix" }
  end

  context "should return correct composition for containing 'color.: E 160(a)'" do
    string = "color.: E 160(a), E 171"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.size).to eq 2 }
    specify { expect(composition.substances.first.name).to eq "E 160(a)" }
    specify { expect(composition.substances.last.name).to eq "E 171" }
  end

  context "should parse a Praeparatio with a label/galenic form?" do
    string = "Praeparatio cryodesiccata: pollinis allergeni extractum 25'000 U.: urtica dioica"
    composition = ParseComposition.from_string(string)
    # substance = composition.substances.first
    #      specify { expect(substance.name).to eq 'Urtica Dioica' } # TODO: is this okay?
    specify { expect(composition.label).to eq "Praeparatio cryodesiccata:" }
  end

  context "should return correct substance for equis F(ab')2" do
    string = "viperis antitoxinum equis F(ab')2"
    composition = ParseComposition.from_string(string)
    substance = composition.substances.first
    specify { expect(substance.name).to eq "Viperis Antitoxinum Equis F(ab')" }
  end

  context "should return correct substance for with two et substances corresp" do
    string = "viperis antitoxinum equis F(ab')2 corresp. Vipera aspis > 1000 LD50 mus et Vipera berus > 500 LD50 mus et Vipera ammodytes > 1000 LD50 mus"
    composition = ParseComposition.from_string(string)
    substance = composition.substances.last
    specify { expect(substance.name).to eq "Vipera Ammodytes > 1000 Ld50 Mus" }
  end

  context "should return correct substance for 'pyrazinamidum 500 mg'" do
    string = "pyrazinamidum 500 mg"
    CompositionTransformer.clear_substances
    composition = ParseComposition.from_string(string)
    substance = composition.substances.first
    specify { expect(substance.name).to eq "Pyrazinamidum" }
    specify { expect(substance.qty).to eq 500.0 }
    specify { expect(substance.unit).to eq "mg" }
  end

  context "should return correct substance for given with et and corresp. (IKSNR 11879)" do
    string = "calcii lactas pentahydricus 25 mg et calcii hydrogenophosphas anhydricus 300 mg corresp. calcium 100 mg"

    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 2 }
    # calcii = composition.substances.find { |x| /calcii/i.match(x.name) }
    pentahydricus = composition.substances.find { |x| /pentahydricus/i.match(x.name) }
    anhydricus = composition.substances.find { |x| /anhydricus/i.match(x.name) }
    specify { expect(pentahydricus.name).to eq "Calcii Lactas Pentahydricus" }
    specify { expect(pentahydricus.qty).to eq 25.0 }
    specify { expect(pentahydricus.unit).to eq "mg" }
    specify { expect(anhydricus.name).to eq "Calcii Hydrogenophosphas Anhydricus" }
    specify { expect(anhydricus.qty).to eq 300.0 }
    specify { expect(anhydricus.unit).to eq "mg" }
    specify { expect(anhydricus.chemical_substance.name).to eq "Calcium" }
    specify { expect(anhydricus.chemical_substance.qty).to eq 100.0 }
    specify { expect(anhydricus.chemical_substance.unit).to eq "mg" }
  end

  context "should return correct substances for Nutriflex IKSNR 42847" do
    line_1 = "I) Glucoselösung: glucosum anhydricum 240 g ut glucosum monohydricum, calcii chloridum dihydricum 600 mg, acidum citricum monohydricum, aqua ad iniectabilia q.s. ad solutionem pro 500 ml."
    line_2 = "."
    # line_4 = "."
    # line_5 = "I) et II) corresp.: aminoacida 70 g, nitrogenia 10 g, natrium 40.5 mmol, kalium 25.7 mmol, calcium 4.1 mmol, magnesium 5 mmol, chloridum 49.5 mmol, phosphas 14.7 mmol, acetas 22 mmol, in solutione recenter reconstituta 1000 ml."
    # line_6 = "Corresp. 5190 kJ pro 1 l."
    # tst = "glucosum anhydricum 240 g ut glucosum monohydricum, calcii chloridum dihydricum 600 mg, acidum citricum monohydricum"
    # tst2 = "glucosum anhydricum 240 g ut glucosum monohydricum, calcii chloridum dihydricum 600 mg"
    # tst_ut = "glucosum anhydricum 240 g ut glucosum monohydricum"
    composition = ParseComposition.from_string(line_2)
    # line_3 = "II) Aminosäurelösung: aminoacida: isoleucinum 4.11 g, leucinum 5.48 g, lysinum anhydricum 3.98 g ut lysinum monohydricum, methioninum 3.42 g, phenylalaninum 6.15 g, threoninum 3.18 g, tryptophanum 1 g, valinum 4.54 g, argininum 4.73 g, histidinum 2.19 g ut histidini hydrochloridum monohydricum, alaninum 8.49 g, acidum asparticum 2.63 g, acidum glutamicum 6.14 g, glycinum 2.89 g, prolinum 5.95 g, serinum 5.25 g, mineralia: magnesii acetas tetrahydricus 1.08 g, natrii acetas trihydricus 1.63 g, kalii dihydrogenophosphas 2 g, kalii hydroxidum 620 mg, natrii hydroxidum 1.14 g, acidum citricum monohydricum, aqua ad iniectabilia q.s. ad solutionem pro 500 ml."
    # line_3 = "II) Aminosäurelösung: aminoacida: isoleucinum 4.11 g, leucinum 5.48 g"
    line_3 = "aminoacida: isoleucinum 4.11 g, leucinum 5.48 g"
    composition = ParseComposition.from_string(line_3)
    composition = ParseComposition.from_string(line_1)

    composition = ParseComposition.from_string(line_1)
    specify { expect(composition.substances.size).to eq 3 }
    specify { expect(composition.label).to eq "I" }
    specify { expect(composition.label_description).to eq "Glucoselösung" }
    dihydricum = composition.substances.find { |x| /dihydricum/i.match(x.name) }
    monohydricum = composition.substances.find { |x| /monohydricum/i.match(x.name) }

    specify { expect(dihydricum.name).to eq "Calcii Chloridum Dihydricum" }
    specify { expect(dihydricum.chemical_substance).to eq nil }
    specify { expect(dihydricum.qty).to eq 600.0 }
    specify { expect(dihydricum.unit).to eq "mg/500 ml" }

    specify { expect(monohydricum.name).to eq "Acidum Citricum Monohydricum" }
    specify { expect(monohydricum.chemical_substance).to eq nil }
    specify { expect(monohydricum.cdose).to eq nil }
    specify { expect(monohydricum.qty).to eq nil }
    specify { expect(monohydricum.unit).to eq nil }
  end

  context "should return correct substance for 9,11-linolicum " do
    substance = nil
    composition = nil
    ["9,11-linolicum",
      "9,11-linolicum 3.25 mg"].each { |string|
      composition = ParseComposition.from_string(string)
      substance = composition.substances.first
      specify { expect(substance.name).to eq "9,11-linolicum" }
      specify { expect(substance.chemical_substance).to eq nil }
      CompositionTransformer.clear_substances
      composition = ParseComposition.from_string(string)
    }

    specify { expect(substance.qty).to eq 3.25 }
    specify { expect(substance.unit).to eq "mg" }
  end

  context "should return correct substance ut (IKSNR 44744)" do
    string = "zuclopenthixolum 2 mg ut zuclopenthixoli dihydrochloridum, excipiens pro compresso obducto."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.name).to eq "Zuclopenthixolum" }
    specify { expect(composition.substances.first.qty).to eq 2.0 }
    specify { expect(composition.substances.first.salts.size).to eq 1 }
    if composition.substances.first
      salt = composition.substances.first.salts.first
      specify { expect(salt.name).to eq "Zuclopenthixoli Dihydrochloridum" }
      specify { expect(salt.qty).to eq nil }
      specify { expect(salt.unit).to eq nil }
    end
  end

  context "should return correct substance for given with et (IKSNR 11879)" do
    string = "calcii lactas pentahydricus 25 mg et calcii hydrogenophosphas anhydricus 300 mg"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.substances.size).to eq 2 }
    pentahydricus = composition.substances.find { |x| /pentahydricus/i.match(x.name) }
    anhydricus = composition.substances.find { |x| /anhydricus/i.match(x.name) }
    specify { expect(pentahydricus.name).to eq "Calcii Lactas Pentahydricus" }
    specify { expect(pentahydricus.qty).to eq 25.0 }
    specify { expect(pentahydricus.unit).to eq "mg" }
    specify { expect(anhydricus.name).to eq "Calcii Hydrogenophosphas Anhydricus" }
    specify { expect(anhydricus.qty).to eq 300.0 }
    specify { expect(anhydricus.unit).to eq "mg" }
  end

  context "should return correct substance for 'Xenonum(133-xe) 74 -740 Mb'" do
    string = "Xenonum(133-Xe) 74 -740 MBq"
    composition = ParseComposition.from_string(string)
    substance = composition.substances.first
    specify { expect(substance.name).to eq "Xenonum(133-xe)" }
    specify { expect(substance.qty).to eq "74-740" }
    specify { expect(substance.unit).to eq "MBq" }
  end

  context "should return correct substance for 'pyrazinamidum'" do
    string = "pyrazinamidum"
    composition = ParseComposition.from_string(string)
    substance = composition.substances.first
    specify { expect(substance.name).to eq "Pyrazinamidum" }
    specify { expect(substance.qty).to eq nil }
    specify { expect(substance.unit).to eq nil }
  end

  context "should return correct substance for 'E 120'" do
    string = "E 120"
    composition = ParseComposition.from_string(string)
    substance = composition.substances.first
    specify { expect(substance.name).to eq string }
    specify { expect(substance.qty).to eq nil }
    specify { expect(substance.unit).to eq nil }
  end

  context "should return correct substance for 'retinoli palmitas 7900 U.I.'" do
    string = "retinoli palmitas 7900 U.I."
    composition = ParseComposition.from_string(string)
    substance = composition.substances.first
    specify { expect(substance.name).to eq "Retinoli Palmitas" }
    specify { expect(substance.qty).to eq 7900.0 }
    specify { expect(substance.unit).to eq "U.I." }
  end

  context "should return correct substance for 'toxoidum pertussis 8 µg'" do
    string = "toxoidum pertussis 8 µg"
    composition = ParseComposition.from_string(string)
    substance = composition.substances.first
    specify { expect(substance.name).to eq "Toxoidum Pertussis" }
    specify { expect(substance.qty).to eq 8.0 }
    specify { expect(substance.unit).to eq "µg" }
  end

  context "should return correct substance Rote Filmtablett 54819 Beriplast" do
    # string = "A) Rote Filmtablette: estradiolum 1 mg ut estradiolum hemihydricum, excipiens pro compresso obducto"
    string = "estradiolum 1 mg ut estradiolum hemihydricum, excipiens pro compresso obducto"
    composition = ParseComposition.from_string(string)
    substance = composition.substances.first
    specify { expect(composition.substances.size).to eq 1 }
    # specify { expect(composition.substances.last.name).to eq 'Obducto' }
    specify { expect(substance.name).to eq "Estradiolum" }
    specify { expect(composition.substances.first.salts.first.name).to eq "Estradiolum Hemihydricum" }
    specify { expect(substance.cdose.to_s).to eq "" }
    specify { expect(substance.qty).to eq 1.0 }
    specify { expect(substance.unit).to eq "mg" }
  end

  context "should return correct composition for containing ut IKSNR 613" do
    string = "aluminium ut aluminii hydroxidum hydricum ad adsorptionem"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.label).to eq nil }
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.name).to eq "Aluminium" }
    specify { expect(composition.substances.first.salts.first.name).to eq "Aluminii Hydroxidum Hydricum Ad Adsorptionem" }
  end

  context "should return correct substance for 'toxoidum pertussis 25 µg et haemagglutininum filamentosum 25 µg'" do
    string = "toxoidum pertussis 25 µg et haemagglutininum filamentosum 15 µg"
    composition = ParseComposition.from_string(string)
    toxoidum = composition.substances.first
    specify { expect(toxoidum.name).to eq "Toxoidum Pertussis" }
    specify { expect(toxoidum.qty).to eq 25.0 }
    specify { expect(toxoidum.unit).to eq "µg" }
    specify { expect(toxoidum.chemical_substance).to eq nil }
    haemagglutininum = composition.substances.last
    specify { expect(haemagglutininum.name).to eq "Haemagglutininum Filamentosum" }
    specify { expect(haemagglutininum.qty).to eq 15.0 }
    specify { expect(haemagglutininum.unit).to eq "µg" }
  end

  context "should return correct composition for containing parenthesis in substance name abd 40 U. (e.g IKSNR 613)" do
    string = "virus poliomyelitis typus 1 inactivatum (D-Antigen) 40 U."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.name).to eq "Virus Poliomyelitis Typus 1 Inactivatum (d-antigen)" }
  end

  context "should return correct composition for containing parenthesis in substance name (e.g IKSNR 613)" do
    string = "virus poliomyelitis typus inactivatum (D-Antigen)"
    string = "virus poliomyelitis typus 1 inactivatum (d-antigen)"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.size).to eq 1 }
    specify { expect(composition.substances.first.name).to eq "Virus Poliomyelitis Typus 1 Inactivatum (d-antigen)" }
  end

  context "should return correct composition for containing residui (e.g IKSNR 613)" do
    string = "residui: neomycinum, streptomycinum"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.substances.size).to eq 2 }
    specify { expect(composition.substances.first.more_info).to eq "residui" }
    specify { expect(composition.substances.first.name).to eq "Neomycinum" }
    specify { expect(composition.substances.last.name).to eq "Streptomycinum" }
  end

  context "should return correct composition for 'conserv.: E 217, E 219' IKSNR 613" do
    #    string = 'I) DTPa-IPV-Komponente (Suspension): toxoidum diphtheriae 30 U.I., toxoidum tetani 40 U.I., toxoidum pertussis 25 µg et haemagglutininum filamentosum 25 µg, virus poliomyelitis typus 1 inactivatum (D-Antigen) 40 U., virus poliomyelitis typus 2 inactivatum (D-Antigen) 8 U., virus poliomyelitis typus 3 inactivatum (D-Antigen) 32 U., aluminium ut aluminii hydroxidum hydricum ad adsorptionem, formaldehydum 10 µg, conserv.: phenoxyethanolum 2.5 µl, residui: neomycinum, streptomycinum, polymyxini B sulfas, medium199, aqua q.s. ad suspensionem pro 0.5 ml.'
    string =
      "I) DTPa-IPV-Komponente (Suspension): toxoidum diphtheriae 30 U.I., toxoidum tetani 40 U.I., toxoidum pertussis 25 µg et haemagglutininum filamentosum 25 µg, virus poliomyelitis typus 1 inactivatum (D-Antigen) 40 U., virus poliomyelitis typus 2 inactivatum (D-Antigen) 8 U., virus poliomyelitis typus 3 inactivatum (D-Antigen) 32 U., aluminium ut aluminii hydroxidum hydricum ad adsorptionem, formaldehydum 10 µg, conserv.: phenoxyethanolum 2.5 µl, residui: neomycinum, streptomycinum, polymyxini B sulfas, medium199, aqua q.s. ad suspensionem pro 0.5 ml."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.label).to eq "I" }
  end

  context "should return correct composition for 'conserv.: E 217, E 219'" do
    string = "conserv.: E 217, E 219"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.label).to eq nil }
  end

  context "should parse more complicated example" do
    string =
      "I) DTPa-IPV-Komponente (Suspension): toxoidum diphtheriae 30 U.I., toxoidum pertussis 25 µg et haemagglutininum filamentosum 25 µg"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }

    specify { expect(composition.label).to eq "I" }
    specify { expect(composition.label_description).to eq "DTPa-IPV-Komponente (Suspension)" }

    specify { expect(composition.galenic_form).to eq nil }
    specify { expect(composition.route_of_administration).to eq nil }

    toxoidum = composition.substances.find { |x| /toxoidum diphther/i.match(x.name) }
    specify { expect(toxoidum.name).to eq "Toxoidum Diphtheriae" }
    specify { expect(toxoidum.qty).to eq 30 }
    specify { expect(toxoidum.unit).to eq "U.I." }

    haema = composition.substances.find { |x| /Haemagglutininum/i.match(x.name) }
    specify { expect(haema.name).to eq "Haemagglutininum Filamentosum" }
    specify { expect(haema.qty).to eq 25 }
    specify { expect(haema.unit).to eq "µg" }
  end

  context "should return correct composition for 'minoxidilum'" do
    string = "minoxidilum 2.5 mg, pyrazinamidum 500 mg"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.label).to eq nil }
    specify { expect(composition.label_description).to eq nil }
    specify { expect(composition.galenic_form).to eq nil }
    specify { expect(composition.route_of_administration).to eq nil }
    substance = composition.substances.first
    specify { expect(substance.name).to eq "Minoxidilum" }
    specify { expect(substance.qty).to eq 2.5 }
    specify { expect(substance.unit).to eq "mg" }
  end

  context "should return correct composition for 'terra'" do
    string = "terra"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.label).to eq nil }
    specify { expect(composition.label_description).to eq nil }
    specify { expect(composition.galenic_form).to eq nil }
    specify { expect(composition.route_of_administration).to eq nil }
    specify { expect(composition.substances.first.name).to eq "Terra" }
  end

  context "should return correct composition for 'terra silicea spec..'" do
    string = "terra silicea spec. 810 mg, excipiens pro compresso"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.label).to eq nil }
    specify { expect(composition.label_description).to eq nil }
    specify { expect(composition.galenic_form).to eq nil }
    specify { expect(composition.route_of_administration).to eq nil }
    specify { expect(composition.substances.first.name).to eq "Terra Silicea Spec." }
  end

  context "should return correct composition for 'minoxidilum'" do
    string = "minoxidilum 2.5 mg"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.label).to eq nil }
    specify { expect(composition.label_description).to eq nil }
    specify { expect(composition.galenic_form).to eq nil }
    specify { expect(composition.route_of_administration).to eq nil }
    substance = composition.substances.first
    specify { expect(substance.name).to eq "Minoxidilum" }
    specify { expect(substance.qty).to eq 2.5 }
    specify { expect(substance.unit).to eq "mg" }
  end

  context "should return correct composition for 'minoxidilum'" do
    string = "minoxidilum"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.label).to eq nil }
    specify { expect(composition.label_description).to eq nil }
    specify { expect(composition.galenic_form).to eq nil }
    specify { expect(composition.route_of_administration).to eq nil }
    substance = composition.substances.first
    specify { expect(substance.name).to eq "Minoxidilum" }
    specify { expect(substance.qty).to eq nil }
    specify { expect(substance.unit).to eq nil }
  end

  context "should handle 41174" do
    string = "triamcinoloni acetonidum 10 mg, carmellosum natricum, natrii chloridum, polysorbatum 80, conserv.: alcohol benzylicus 9.9 mg, aqua ad iniectabile q.s. ad suspensionem pro 1 ml."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.label).to eq nil }
    specify { expect(composition.substances.size).to be > 1 }
    specify { expect(composition.substances.first.name).to eq "Triamcinoloni Acetonidum" }
    specify { expect(composition.substances.last.name).to eq "Alcohol Benzylicus" }
  end

  context "should handle 67023" do
    string = "noradrenalinum 0.06 mg ut noradrenalini tartras, natrii chloridum, acidum hydrochloridum, aqua ad iniectabile q.s. ad solutionem pro 1 ml corresp. natrium 3.308 mg."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.label).to eq nil }
    specify { expect(composition.substances.size).to be > 1 }
    specify { expect(composition.substances.first.name).to eq "Noradrenalinum" }
    specify { expect(composition.substances.last.name).to eq "Acidum Hydrochloridum" }
  end

  context "should handle 67023" do
    string = "noradrenalinum 0.06 mg ut noradrenalini tartras, natrii chloridum, acidum hydrochloridum, aqua ad iniectabile q.s. ad solutionem pro 1 ml corresp. natrium 3.308 mg."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.label).to eq nil }
    specify { expect(composition.substances.size).to be > 0 }
    specify { expect(composition.substances.first.name).to eq "Noradrenalinum" }
    specify { expect(composition.substances.last.name).to eq "Acidum Hydrochloridum" }
  end

  context "should handle 67689" do
    string = "daratumumabum 1800 mg, hyaluronidasum humanum ADNr, histidinum, histidini hydrochloridum monohydricum, sorbitolum 735.1 mg, methioninum, polysorbatum 20, aqua ad iniectabile ad solutionem pro 15 ml"
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.label).to eq nil }
    specify { expect(composition.substances.size).to be > 0 }
    specify { expect(composition.substances.first.name).to eq "Daratumumabum" }
    specify { expect(composition.substances.last.name).to eq "Polysorbatum 20" }
  end

  context "should handle 66097" do
    string = "acidum acetylsalicylicum 100 mg, cellulosum microcristallinum, maydis amylum, silica colloidalis anhydrica, acidum stearicum, Überzug: acidi methacrylici et ethylis acrylatis polymerisatum 1:1, polysorbatum 80, natrii laurilsulfas corresp. natrium 2 µg, triethylis citras, talcum pro compresso obducto" # fails
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.label).to eq nil }
    specify { expect(composition.substances.first.name).to eq "Acidum Acetylsalicylicum" }
    specify { expect(composition.substances.last.name).to eq "Talcum pro compresso Obducto" }
  end
  context "should handle 65828" do
    string = " esomeprazolum 20 mg ut esomeprazolum magnesicum dihydricum, acidi methacrylici et ethylis acrylatis polymerisati 1:1 dispersio 30 per centum, natrii laurilsulfas, talcum, triethylis citras, hypromellosum, sacchari sphaerae corresp. saccharum 4.73 mg et maydis amylum, magnesii stearas, hydroxypropylcellulosum, glyceroli monostearas 40-55, polysorbatum 80, cellulosum microcristallinum, povidonum K 29-32, macrogolum 6000, crospovidonum, natrii stearylis fumaras, Überzug: hypromellosum, E 171, macrogolum 400, E 172 (rubrum), E 172 (flavum), pro compresso obducto corresp. natrium 0.01 mg."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.label).to eq nil }
    specify { expect(composition.substances.first.name).to eq "Esomeprazolum" }
    specify { expect(composition.substances.last.name).to eq "pro compresso Obducto" }
  end

  context "should return correct composition for 'minoxidilum excipiens'" do
    string = "minoxidilum 2.5 mg, excipiens pro compresso."
    composition = ParseComposition.from_string(string)
    specify { expect(composition.source).to eq string }
    specify { expect(composition.label).to eq nil }
    specify { expect(composition.label_description).to eq nil }
    specify { expect(composition.galenic_form).to eq nil }
    specify { expect(composition.route_of_administration).to eq nil }

    substance = composition.substances.first
    specify { expect(substance.name).to eq "Minoxidilum" }
    specify { expect(substance.qty).to eq 2.5 }
    specify { expect(substance.unit).to eq "mg" }
    skip "what is the correct name for excipiens?" # { expect(composition.substances.last.name).to eq 'Excipiens Pro Compresso' }
  end

  context "find correct result compositions for nutriflex" do
    line_1 = "I) Glucoselösung: glucosum anhydricum 150 g ut glucosum monohydricum, natrii dihydrogenophosphas dihydricus 2.34 g, zinci acetas dihydricus 6.58 mg, aqua ad iniectabilia q.s. ad solutionem pro 500 ml."
    line_2 = "II) Fettemulsion: sojae oleum 25 g, triglycerida saturata media 25 g, lecithinum ex ovo 3 g, glycerolum, natrii oleas, aqua q.s. ad emulsionem pro 250 ml."
    line_3 = "III) Aminosäurenlösung: isoleucinum 2.34 g, leucinum 3.13 g, lysinum anhydricum 2.26 g ut lysini hydrochloridum, methioninum 1.96 g, aqua ad iniectabilia q.s. ad solutionem pro 400 ml."
    line_4 = "I) et II) et III) corresp.: aminoacida 32 g/l, acetas 32 mmol/l, acidum citricum monohydricum, in emulsione recenter mixta 1250 ml."
    line_5 = "Corresp. 4000 kJ."
    text = "#{line_1}\n#{line_2}\n#{line_3}\n#{line_4}\n#{line_5}"
    compositions = ParseUtil.parse_compositions(text, "glucosum anhydricum, zinci acetas dihydricus, isoleucinum, leucinum")
    specify { expect(compositions.first.substances.first.name).to eq "Glucosum Anhydricum" }
    specify { expect(compositions.first.substances.first.salts.first.name).to eq "Glucosum Monohydricum" }
    specify { expect(compositions.size).to eq 5 }
    specify { expect(compositions.first.substances.first.qty.to_f).to eq 150.0 }
    specify { expect(compositions.first.substances.first.unit).to eq "g/500 ml" }

    specify { expect(compositions[0].source).to eq line_1 }
    specify { expect(compositions[0].label).to eq "I" }
    specify { expect(compositions[0].label_description).to eq "Glucoselösung" }
    specify { expect(compositions[1].label).to eq "II" }
    specify { expect(compositions[2].label).to eq "III" }
    glucosum = compositions.first.substances.first
    specify { expect(glucosum.name).to eq "Glucosum Anhydricum" }
    specify { expect(glucosum.qty.to_f).to eq 150.0 }
    specify { expect(glucosum.unit).to eq "g/500 ml" }
    specify { expect(compositions[0].substances.size).to eq 3 }
    specify { expect(compositions[1].substances.size).to eq 5 } # should have  glycerolum, natrii oleas, aqua
    specify { expect(compositions[2].substances.size).to eq 4 }
    specify { expect(compositions[1].source).to eq line_2 }
    specify { expect(compositions[2].source).to eq line_3 }
    specify { expect(compositions[3].source).to eq line_4 }
    specify { expect(compositions[3].corresp).to eq line_4.sub(/\.$/, "") }
    specify { expect(compositions[4].source).to eq line_5 }
    specify { expect(compositions[4].corresp).to eq "4000 kJ" }

    # from II)
    if compositions && compositions[1] && compositions[1].substances
      lecithinum = compositions[1].substances.find { |x| x.name.match(/lecithinum/i) }
      specify { expect(lecithinum).not_to eq nil }
      if lecithinum
        specify { expect(lecithinum.name).to eq "Lecithinum Ex Ovo" }
        specify { expect(lecithinum.qty.to_f).to eq 3.0 }
        specify { expect(lecithinum.unit).to eq "g/250 ml" }
      end

      # From III
      leucinum = compositions[2].substances.find { |x| x.name.eql?("Leucinum") }
      specify { expect(leucinum).not_to eq nil }
      if leucinum
        specify { expect(leucinum.name).to eq "Leucinum" }
        specify { expect(leucinum.qty.to_f).to eq 3.13 }
        specify { expect(leucinum.unit).to eq "g/400 ml" }
      end
      leucinum_i = compositions[0].substances.find { |x| x.name.eql?("Leucinum") }
      specify { expect(leucinum_i).to eq nil }
      leucinum_ii = compositions[1].substances.find { |x| x.name.eql?("Leucinum") }
      specify { expect(leucinum_ii).to eq nil }
      #    aqua =  compositions[2].substances.find{ |x| /aqua ad/i.match(x.name) }
      #   specify { expect(aqua.name).to eq "Aqua Ad Iniectabilia Q.s. Ad Solutionem Pro"}
    end
  end

  describe ParseUtil::HandleSwissmedicErrors do
    context "should handle fixes" do
      replacement = '\1, \2'
      pattern_replacement = {/(sulfuris D6\s[^\s]+\smg)\s([^,]+)/ => replacement}
      test_string = "sulfuris D6 2,2 mg hypericum perforatum D2 0,66"
      expected = "sulfuris D6 2,2 mg, hypericum perforatum D2 0,66"
      handler = ParseUtil::HandleSwissmedicErrors.new(pattern_replacement)
      result = handler.apply_fixes(test_string)
      specify { expect(result).to eq expected }
      specify { expect(handler.report.size).to eq 2 }
      specify { expect(/report/i.match(handler.report[0]).class).to eq MatchData }
      specify { expect(handler.report[1].index(replacement).class).to eq Integer }
    end
  end
end

if RUN_ALL_COMPOSITION_TESTS
  describe ParseComposition do
    context "should parse a complex composition" do
      start_time = Time.now
      specify { expect(File.exist?(AllCompositionLines)).to eq true }
      inhalt = IO.readlines(AllCompositionLines)
      nr = 0
      @nr_errors = 0
      inhalt.each { |line|
        nr += 1
        next if line.length < 5
        puts "#{File.basename(AllCompositionLines)}:#{nr} #{@nr_errors} errors: #{line}" if VERBOSE_MESSAGES
        begin
          ParseComposition.from_string line
        rescue Parslet::ParseFailed
          @nr_errors += 1
          puts "#{File.basename(AllCompositionLines)}:#{nr} parse_error #{@nr_errors} in: #{line}"
        end
      }
      at_exit { puts "Testing whether #{nr} composition lines can be parsed. Found #{@nr_errors} errors in #{(Time.now - start_time).to_i} seconds" }
    end
  end
end
