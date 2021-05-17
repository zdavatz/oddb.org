VERBOSE_MESSAGES = false
if File.exists?("/home/niklaus/git/oddb.org/lib/oddb2xml/parslet_compositions.rb")
  require_relative "../lib/oddb2xml/parslet_compositions"
else
  puts :ParseFailed
  require_relative "../src/plugin/parslet_compositions"
end
require "parslet/rig/rspec"
describe ParseComposition do


  it "should handle isknr 00485" do
      string = "haemagglutininum influenzae A (H1N1) (Virus-Stamm A/Brisbane/02/2018 (H1N1)-like: reassortant virus A/Brisbane/02/2018, IVR-190) 15 µg, haemagglutininum influenzae A (H3N2) (Virus-Stamm A/Kansas/14/2017 (H3N2)-like: reassortant virus A/Kansas/14/2017, NYMC X-327) 15 µg, haemagglutininum influenzae B (Virus Stamm B/Colorado/06/2017-like: reassortant virus B/Maryland/15/2016 NYMC BX-69A) 15 µg, kalii chloridum, kalii dihydrogenophosphas, dinatrii phosphas dihydricus, natrii chloridum, calcii chloridum dihydricum, magnesii chloridum hexahydricum, residui: natrii citras dihydricus max. 1 mg, cetrimidum max. 15 µg, formaldehydum max. 10 µg, gentamicini sulfas max. 1 ng, tylosini tartras nihil, hydrocortisonum nihil, polysorbatum 80 nihil, ovalbuminum max. 0.1 µg, aqua ad iniectabilia q.s. ad suspensionem pro 0.5 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 00598" do
      string = "escherichiae coli lysati filtratum 6 mg, E 310, natrii hydrogenoglutamas anhydricus, amylum pregelificatum, magnesii stearas, mannitolum, matériel de la capsule: E 172 (rubrum), E 172 (flavum), E 171, gelatina, pro capsula corresp. natrium 2.85 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 00637" do
      string = "toxoidum diphtheriae ≥ 2 U.I., toxoidum tetani ≥ 20 U.I., toxoidum pertussis 8 µg, haemagglutininum filamentosum 8 µg, pertactinum 2.5 µg, aluminium ut aluminii phosphas et aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum corresp. natrium 1.8 mg, aqua ad iniectabilia q.s. ad suspensionem pro 0.5 ml, residui: formaldehydum, polysorbatum 80, glycinum."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 00638" do
      string = "toxoidum diphtheriae min. 30 U.I., toxoidum tetani min. 40 U.I., toxoidum pertussis 25 µg, haemagglutininum filamentosum (B. pertussis) 25 µg, pertactinum (B. pertussis) 8 µg, virus poliomyelitis typus 1 inactivatus (Mahoney) 40 U.I., virus poliomyelitis typus 2 inactivatus (MEF1) 8 U.I., virus poliomyelitis typus 3 inactivatus (Saukett) 32 U.I., aluminium 0.5 mg ut aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum corresp. natrium 1.8 mg, medium 199, aqua ad iniectabile ad suspensionem pro 0.5 ml, residui: polysorbatum 80, formaldehydum, neomycini sulfas, polymyxini B sulfas."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 00675" do
      string = "enterococci faecalis lysatum 15-45 Mio U., escherichiae coli lysatum 15-45 Mio U., lactosum 4.66 mg ut lactosum monohydricum, natrii carbonas decahydricus, natrii chloridum, magnesii sulfas heptahydricus, kalii chloridum, calcii chloridum dihydricum, magnesii chloridum hexahydricum, caseini peptonum, faecis extractum, natrii chloridum, glucosum 0.018 mg ut glucosum monohydricum, aqua purificata ad suspensionem pro 1 ml corresp. natrium 1.697 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 00676" do
      string = "enterococcus faecalis vivus 15-45 Mio U., lactosum monohydricum corresp. lactosum 0.914 mg, cystinum, natrii carbonas decahydricus et natrii chloridum corresp. natrium 1.674 mg, magnesii sulfas heptahydricus, kalii chloridum, calcii chloridum dihydricum, magnesii chloridum hexahydricum, aqua purificata, caseini peptonum, faecis extractum, glucosum monohydricum corresp. glucosum 0.009 mg, ad suspensionem pro 1 ml corresp. 12 guttae."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 00677" do
      string = "escherichia coli viva 15 - 45 Mio. U., natrii chloridum corresp. natrium 2.382 mg, magnesii sulfas heptahydricus, kalii chloridum, calcii chloridum dihydricum, magnesii chloridum hexahydricum, aqua purificata ad suspensionem pro 1 ml, corresp. 14 guttae."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 00681" do
      string = "toxoidum diphtheriae ≥ 2 U.I., toxoidum tetani ≥ 20 U.I., toxoidum pertussis 8 µg, haemagglutininum filamentosum von Bordetella pertussis 8 µg, pertactinum von Bordetella pertussis 2.5 µg, virus poliomyelitis typus 1 inactivatus 40 U., virus poliomyelitis typus 2 inactivatus 8 U., virus poliomyelitis typus 3 inactivatus 32 U., natrii chloridum corresp. natrium 1.8 mg, aluminium 0.5 mg ut aluminii hydroxidum hydricum ad adsorptionem et aluminii phosphas, medium 199, aqua ad iniectabile, q.s. ad suspensionem pro 0.5 ml, residui: formaldehydum, polysorbatum 80, neomycini sulfas, polymyxini B sulfas."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 08653" do
      string = "hamamelidis aqua (Hamamelis virginiana L, folium et cortex aut ramunculus) 62.5 mg ratio: 1:1.12-2.08 Destillationsmittel: Ethanolum 7.5 % m/m, vaselinum album, adeps lanae 165 mg, glyceroli mono/di/triadipas/alcanoas(C8,C10)/isostearas, alcohol cetylicus et stearylicus 20 mg, paraffinum microcristallinum, acidum citricum, glyceroli mono-oleas, glyceroli monostearas 40-55, E 304, E 307, lecithinum, propylenglycolum 50 mg, aqua purificata, dinatrii edetas, paraffinum liquidum, ad unguentum pro 1 g."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 12548" do
      string = "levomentholum 2.5 mg, anisi stellati aetheroleum 5 mg, eucalypti aetheroleum 23 mg, gaultheriae aetheroleum 10 mg, citronellae aetheroleum 7 mg, menthae piperitae aetheroleum 8.5 mg, rosmarini aetheroleum 28 mg, arnicae floris extractum oleosum 17 mg corresp. sojae oleum raffinatum q.s., alcohol cetylicus et stearylicus 33.325 mg, macrogolglyceroli ricinoleas 6.45 mg, natrii cetylo- et stearylosulfas, helianthi oleum, maydis embryonis oleum, tritici embryonis oleum, natrii alginas, silica colloidalis anhydrica, acidum citricum monohydricum, aqua purificata, E 219 2 mg, E 214, E 216, E 218, butylis/isobutylis parahydroxybenzoas 1.4 mg, phenoxyethanolum, imidazolidinylureum, ad emulsionem pro 1 g."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 18022" do
      string = "uvae ursi folium (Arctostaphylos uva-ursi (L.) Spreng., folium) 0.46 g, orthosiphonis folium (Orthosiphon aristatus (Blume) Miq. var. aristatus (syn. Orthosiphon stamineus Benth., folium) 0.260 g, betulae folium (Betula pendula Roth and/or Betula pubescens Ehrh., folium) 0.260 g, juniperi galbulus (Juniperus communis L., pseudofructus) 0.130 g, levistici radix (Levisticum officinale Koch, radix et rhizoma) 0.130 g, menthae piperitae folium (Mentha × piperita L., folium), pro charta 1.3 g."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 19137" do
      string = "zinci oxidum 80 mg, diphenhydramini hydrochloridum 10 mg, camphora racemica 1 mg, E 172 (rubrum), E 172 (flavum), carmellosum natricum, glycerolum (85 per centum), ethanolum 96 per centum 19.35 mg, acidum hydrochloridum, aromatica cum eugenolum, lilialum, amylis cinnamaldehydum, geraniolum, cumarinum, linaloolum, citralum, citronellolum, alcohol benzylicus, benzylis benzoas, aqua, ad suspensionem pro 1 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 22958" do
      string = "dialysatum deproteinatum sanguinis vituli siccum 85 mg, E 218, propylis parahydroxybenzoas, E 214, acidum parahydroxybenzoicum, aqua ad iniectabile q.s., ad solutionem pro 2 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 30724" do
      string = "echinaceae purpureae herbae recentis tinctura 860 mg ratio: 1:12 Auszugsmittel Ethanolum 57.3% m/m, echinaceae purpureae radicis recentis tinctura 45 mg ratio: 1:11 Auszugsmittel Ethanolum 57.3% m/m, ad solutionem pro 1 ml corresp. ethanolum 62-70 % V/V."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 31567" do
      string = "dexamethasonum 1 mg, neomycinum 3.5 mg ut neomycini sulfas 4.6 mg, polymyxini B sulfas 6000 U.I., natrii chloridum, polysorbatum 20, acidum hydrochloridum aut natrii hydroxidum, hypromellosum, aqua purificata, benzalkonii chloridum 40 µg, ad suspensionem pro 1 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 33422" do
      string = "extractum aquosum liquidum 7056,00 mg ex gentianae radix (Gentiana lutea L., radix) 254,60 mg et absinthii herba (Artemisia absinthium L., herba) 195.80 mg et zingiberis rhizoma (Zingiber officinale Roscoe, rhizoma) 156.41 mg et calami rhizoma (Acorus calamus L., rhizoma) 23.52 mg et piperis nigri fructus (Piper nigrum L, fructus) 4.70 mg, DER: 1:11, Auszugsmittel aqua ad extracta praeparanda, saccharum 4704.00 mg, ad solutionem pro 10 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 34755" do
      string = "hippocastani extractum ethanolicum siccum 240-290 mg corresp. aescinum 50 mg, DER: 4.5-5.5:1, Auszugsmittel Ethanolum 50% V/V, color.: E 104, E 132, excipiens pro capsula."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 36355" do
      string = "aluminii oxidum hydricum 375 mg, magnesii hydroxidum 175 mg, sorbitolum liquidum non cristallisabile 575 mg, glycerolum, ethanolum 188 mg, silica colloidalis anhydrica, aqua purificata, aromatica, saccharinum natricum corresp. natrium 28 µg, propylis parahydroxybenzoas 2.55 mg, E 218 17 mg ad suspensionem pro 5 ml corresp. ethanolum 4.9 % V/V."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 36896" do
      string = "carbamazepinum 100 mg, macrogoli 8 stearas typus I, hydroxyethylcellulosum, cellulosum microcristallinum, carmellosum natricum, sorbitolum liquidum non cristallisabile 1.25 g, propylenglycolum 125 mg, aqua purificata, aromatica (Caramel), saccharinum natricum, E 200, propylis parahydroxybenzoas 1.5 mg, E 218 6 mg ad suspensionem pro 5 ml corresp. natrium 0.57 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 38178" do
      string = "cinnarizinum 75 mg, cellulosum microcristallinum et carmellosum natricum corresp. natrium 0.01 mg, ethanolum 20 mg corresp. ethanolum 2.5 % V/V, polysorbatum 20, sorbitolum liquidum cristallisabile 530 mg, aromatica (Banane), propylis parahydroxybenzoas 500 µg, E 218 2 mg, aqua purificata ad suspensionem pro 1 ml corresp. 25 guttae."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 38695" do
      string = "betamethasonum 0.5 mg ut betamethasoni dipropionas, gentamicinum 1.0 mg ut gentamicini sulfas, natrii dihydrogenophosphas dihydricus, acidum phosphoricum, paraffinum liquidum, alcohol cetylicus et stearylicus 72 mg, macrogoli aether cetostearylicus, vaselinum album, natrii hydroxidum, aqua purificata, chlorocresolum 1 mg ad emulsionem pro 1 g."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 39036" do
      string = "hydroxocobalaminum 0.5 mg, l-O-phosphothreoninum 10 mg, glutaminum 60 mg, l-O-phosphoserinum 40 mg, arginini hydrochloridum 100 mg, sorbitolum liquidum non cristallisabile 9 g, E 211 30 mg, natrii hydroxidum, aromatica, aqua ad solutionem pro vitro 10 ml corresp. natrium 8.1 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 39639" do
      string = "dextromethorphanum 25 mg ut dextromethorphani hydrobromidum, magnesium aluminium silicate, ethanolum 96 per centum 50 mg, acidum citricum monohydricum, natrii citras dihydricus, cellulosum microcristallinum et carmellosum natricum, sorbitolum liquidum non cristallisabile 5.5 g, aqua purificata, aromatica, propylenglycolum 8.6 mg, natrii cyclamas 2-ethyl-3-hydroxy-4-pyronum, E 150a, propylis parahydroxybenzoas 3 mg, E 218 10 mg ad suspensionem pro 10 ml corresp. natrium 31.7 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 40231" do
      string = "levomenolum 0.35 mg, matricariae extractum ethanolicum liquidum 999.65 mg, DER: 1:1.5-2.8 corresp. aetherolea 2.0-2.3 mg, Auszugsmittel: ethanolum 96 per centum et ammoniae solutio concentrata et aqua purificata 51:1:48 ad solutionem pro 1 g corresp. ethanolum 422 mg/ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 41905" do
      string = "domperidonum 1 mg, sorbitolum liquidum non cristallisabile corresp. sorbitolum 318.5 mg, cellulosum microcristallinum et carmellosum natricum, E 218 1.8 mg, propylis parahydroxybenzoas 0.2 mg, polysorbatum 20, natrii hydroxidum, saccharinum natricum aqua purificata ad suspensionem pro 1 ml corresp. natrium 0.11 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 42407" do
      string = "acida oligoinsaturata 5 mg, phenoxyethanolum, carbomerum, cera alba, decylis oleas, glyceroli monostearas 40-55, macrogoli aether cetostearylicus, acidum stearicum, trometamolum, aqua purificata, ad emulsionem pro 1 g."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 42408" do
      string = "acida oligoinsaturata 8.15 mg, cera alba, adeps solidus, sorbitani stearas, alcohol cetylicus et stearylicus 19.5 mg, arachidis oleum hydrogenatum 19.5 mg, alcoholes adipis lanae, paraffinum liquidum, adeps lanae 39 mg, E 321 q.s., vaselinum album, decylis oleas, arachidis oleum raffinatum 111 mg, E 160(a), helianthi annui oleum raffinatum, aqua purificata, paraffinum microcristallinum, aluminii monostearas, magnesii stearas, paraffinum solidum, ad emulsionem pro 1 g."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 42414" do
      string = "camphora racemica 20 mg, methylis salicylas 10.24 mg, benzylis nicotinas 0.75 mg, pini silvestris aetheroleum 20.48 mg, alcohol isopropylicus 300 mg, natrii hydroxidum, alcohol cetylicus et stearylicus 15.4 mg, macrogolglyceroli ricinoleas 6.6 mg, decylis oleas, carbomerum 974P, aqua purificata, ad emulsionem pro 1 g."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 42496" do
      string = "isoconazoli nitras 10 mg, diflucortoloni valeras 1 mg, polysorbatum 60, sorbitani stearas, alcohol cetylicus et stearylicus 50 mg, paraffinum liquidum, vaselinum album, dinatrii edetas, aqua ad unguentum pro 1 g."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 42894" do
      string = "metoclopramidi hydrochloridum 4 mg, aqua purificata, saccharinum natricum, E 218 1.8 mg, propylis parahydroxybenzoas 0.2 mg, ad suspensionem pro 1 ml corresp. 12 gutta corresp. natrium 0.11 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 43679" do
      string = "retinoli palmitas 330 U.I., ergocalciferolum 20 U.I., int-rac-alpha-tocopherolum 0.91 mg, phytomenadionum 15 µg, sojae oleum fractionatum, lecithinum fractionatum ex vitello ovi, glycerolum, aqua ad iniectabile q.s. ad emulsionem pro 1 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 46180" do
      string = "matricariae extractum ethanolicum liquidum 20 mg corresp. matricariae aetheroleum 200 µg et levomenolum 70 µg, DER: 2.7-5.5:1, Auszugsmittel EtOH 95.4% V/V (Ethanol 99.04%, gereinigtes Wasser, Ph.Eur. 0.62%, Natriumacetat*3H2O, Ph.Eur. 0.22%, Natriumhydroxid, Ph.Eur. 0.13%, alcoholes adipis lanae, conserv.: propylis parahydroxybenzoas, E 218, excipiens ad unguentum pro 1 g."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 47162" do
      string = "propofolum 20 mg, sojae oleum 100 mg, phosphatidum ovi depuratum, glycerolum, dinatrii edetas, natrii hydroxidum, aqua ad iniectabile q.s. ad emulsionem pro 1 ml corresp. natrium 0.086 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 47726" do
      string = "Praeparatio cryodesiccata: proteina 20-160 mg ex illo factor IX coagulationis humanus 600 U.I. et factor X coagulationis humanus 600-1200 U.I., heparinum ≤ 200 U.I., antithrombinum III humanum, glycinum, calcii chloridum anhydricum, natrii chloridum, natrii citras anhydricus, natrii hydroxidum, acidum hydrochloridum pro vitro corresp. natrium 56 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 48473" do
      string = "echinacea pallida ex herba rec. LA 20% LA 20% TM 10 g, calendula officinalis e floribus rec. LA 20% LA 20% TM 10 g, salvia officinalis LA 20% TM 10 g, argenti nitras aquos. D13 1 g, eucalyptus globulus ferm D1 1 g, gingiva bovis Gl GI D4 1 g, gingiva bovis Gl GI D8 1 g, tonsillae palatinae bovis Gl GI D4 1 g, tonsillae palatinae bovis Gl GI D8 1 g, excipiens ad solutionem, corresp. ethanolum 18 % V/V et propellentia ad aerosolum pro 100 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 49366" do
      string = "diclofenacum resinatum 43.7 mg corresp. diclofenacum natricum 15 mg, ricini oleum hydrogenatum 4 mg, paraffinum liquidum, resina polystyrenolica cationica mitis, aromatica (tutti frutti), saccharinum natricum, ad suspensionem pro 1 ml, corresp. 30 gutta corresp. natrium 1.86 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 50725" do
      string = "mesalazinum 1 g, dinatrii edetas, natrii acetas trihydricus, acidum hydrochloridum, aqua, E 223, ad suspensionem pro dosi."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 50766" do
      string = "dexamethasonum 1 mg, tobramycinum 3 mg, dinatrii edetas, natrii chloridum, natrii sulfas, tyloxapolum, hydroxyethylcellulosum, aqua, natrii hydroxidum aut acidum sulfuricum, benzalkonii chloridum 0.1 mg, ad suspensionem pro 1 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 52618" do
      string = "I) Kleberprotein-Lösung gefroren: fibrinogenum humanum 144-220 mg, factor XIII 1.2-20 U., aprotininum syntheticum 4500-7500 U., albuminum humanum, histidinum, nicotinamidum, polysorbatum 80, natrii citras dihydricus, aqua ad iniectabile q.s. ad solutionem pro 2 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 52715" do
      string = "Praeparatio cryodesiccata: factor VIII coagulationis humanus 1000 U.I., corresp. Specific activity (albumin-corrected) 70 ± 30 U.I. pro proteina 1 mg, corresp. von Willebrand factor activity (VWF:CBA) ca. 75 U.I./ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 52838" do
      string = "betaxololum 2.5 mg ut betaxololi hydrochloridum, natrii polystyrensulfonas, carbomerum 974P, mannitolum, acidum hydrochloridum aut natrii hydroxidum, aqua, ad suspensionem pro 1 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 52852" do
      string = "oxcarbazepinum 60 mg, aqua purificata, sorbitolum liquidum non cristallisabile 250 mg, propylenglycolum 25 mg, cellulosum dispergibile, macrogoli 8 stearas typus I, aromatica, saccharinum natricum, E 300, E 200, propylis parahydroxybenzoas 0.3 mg, E 218 1.2 mg ad suspensionem pro 1 ml corresp. natrium < 23 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 52969" do
      string = "dorzolamidum 20 mg ut dorzolamidi hydrochloridum 22.26 mg, hydroxyethylcellulosum, mannitolum, natrii citras dihydricus, natrii hydroxidum, aqua ad iniectabile, benzalkonii chloridum 75 µg, ad solutionem pro 1 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 53211" do
      string = "sevofluranum 100%, pro vitro."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 53675" do
      string = "latanoprostum 50 µg, natrii chloridum, natrii dihydrogenophosphas monohydricus et dinatrii phosphas corresp. phosphas 6.34 mg, aqua ad iniectabile, benzalkonii chloridum 0.2 mg, ad solutionem pro 1 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 53904" do
      string = "fentanylum 2.1 mg, acrylates et vinylis acetatis polymerisatum, Trägermaterial: polyesterum, Drucktinte (Orange): ad praeparationem pro 5.25 cm², cum liberatione 12.5 µg/h."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 53915" do
      string = "dinoprostonum 10 mg, macrogolum 8000, 1,2,6-hexantriolum, dicyclohexylmethani 4,4'-diisocyanas, ferri chloridum, polyesterum, pro praeparatione."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 53943" do
      string = "propofolum 10 mg, sojae oleum 100 mg, phosphatidum ovi depuratum, glycerolum, dinatrii edetas, natrii hydroxidum, aqua ad iniectabile q.s. ad emulsionem pro 1 ml corresp. natrium 0.086 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 54036" do
      string = "citrullini malas 1.00 g, natrii hydroxidum corresp. natrium 30 mg, aromatica cum ethanolum 74.4-88.2 mg corresp. ethanolum 0.7-0.9 % m/V, aqua ad solutionem pro dosi 10 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 54539" do
      string = "hederae helicis extractum ethanolicum siccum 15.35 mg, DER: 6.5:1, solvant d'extraction Ethanolum 40% m/m, aromatica, conserv.: E 202, E 211, excipiens ad solutionem pro 5 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 54634" do
      string = "acidum ursodeoxycholicum 250 mg, aqua purificata, xylitolum, glycerolum, cellulosum microcristallinum et carmellosum natricum, propylenglycolum 50 mg, natrii citras dihydricus, acidum citricum, natrii chloridum, natrii cyclamas, aromatica (Lemon), E 210 7.5 mg ad suspensionem pro 5 ml corresp. natrium 11.1 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 54994" do
      string = "celecoxibum 200 mg, lactosum monohydricum 49.8 mg, natrii laurilsulfas, povidonum K 30, carmellosum natricum conexum, magnesii stearas, Kapselhülle: gelatina, E 171, Drucktinte: lacca, propylenglycolum, E 172 (flavum), pro capsula corresp., natrium 0.71 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 55052" do
      string = "methylphenidati hydrochloridum 20 mg, lactosum monohydricum 90 mg, alcohol cetylicus et stearylicus, magnesii stearas, Überzug: Überzug: hypromellosum, macrogolglyceroli hydroxystearas 0.132 mg, talcum, E 171, Drucktinte: cera carnauba, lacca, lacca, E 171, E 171, pro compresso obducto."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 55070" do
      string = "imiquimodum 50 mg, acidum isostearicum, alcohol cetylicus 22 mg, alcohol stearylicus 31 mg, vaselinum album, polysorbatum 60, sorbitani stearas, alcohol benzylicus 20 mg, E 218 2 mg, propylis parahydroxybenzoas 0.2 mg, glycerolum, xanthani gummi, aqua purificata, ad emulsionem pro 1 g."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 55119" do
      string = "ureum 100 mg, PEG-45/dodecyl glycol copolymer, methoxy PEG-22/dodecyl glycol copolymer, sorbitani isostearas, ricini oleum hydrogenatum, PEG-2 hydrogenated castor oil 4.1 mg, ozokeritum, PEG-7 hydrogenated castor oil 25 mg, paraffinum perliquidum, isopropylis palmitas, triglycerida media, octyldodecanolum, glycerolum (85 per centum), natrii lactatis solutio, acidum lacticum, magnesii sulfas heptahydricus, dimeticonum, aqua purificata, alcohol benzylicus 12 mg, ad emulsionem pro 1 g."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 55236" do
      string = "brinzolamidum 10 mg, dinatrii edetas, natrii chloridum, mannitolum, tyloxapolum, carbomerum 974P, acidum hydrochloridum aut natrii hydroxidum, aqua purificata, benzalkonii chloridum 100 µg, ad suspensionem pro 1 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 55375" do
      string = "diclofenacum natricum 10 mg, ethanolum 96 per centum, polyacrylamide, C13-C14 isoparaffine, laureth-7, dimeticonum 350, glyceroli tripalmitas/stearas, aqua purificata, sojae oleum 0.5 mg, E 306, ad emulsionem pro 1 g."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 55423" do
      string = "buprenorphinum 40 mg, oleylis oleas, povidonum K 90, acidum laevulinicum, acrylates et vinylis acetatis polymerisatum (vernetzt), poly(ethylenis terephthalas), acrylates et vinylis acetatis polymerisatum (nicht vernetzt), Trägermaterial: poly(ethylenis terephthalas), ad praeparationem pro 50 cm², cum liberatione 70 µg/h."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 55470" do
      string = "trolaminum, ethylenglycoli monopalmitostearas, acidum stearicum, cetylis palmitas, paraffinum solidum, paraffinum perliquidum, squalanum, avocado oleum, propylenglycolum 23 mg, trolamini alginas et natrii alginas, aromatica cum 3-methyl-4-(2,6,6-trimethylcyclohex-2-en-1-yl)but-3-en-2-onum, benzylis benzoas, citralum, citronellolum, limonenum, eugenolum, geraniolum, hexylis cinnamaldehydum, hydroxycitronellalum, rac-(1R)-4-(4-hydroxy-4-methylpentyl)cyclohex-3-en-1-carbaldehydum, isoeugenolum et linaloolum, E 202 1.34 mg, propylis parahydroxybenzoas natricus 0.5 mg, E 219 1 mg, aqua, ad emulsionem pro 1.0 g."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 55581" do
      string = "tolterodini l-tartras 4 mg corresp. tolterodinum 2.74 mg, sacchari sphaerae corresp. saccharum 80.66 – 118.10 mg et maydis amylum, hypromellosum, ethylcellulosum, triglycerida media, acidum oleicum, Kapselhülle: gelatina, E 132, E 171, Drucktinte: lacca, E 171, propylenglycolum, simethiconum, pro capsula."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 55695" do
      string = "valerianae extractum ethanolicum siccum 600 mg, DER: 3-6:1, solvant d'extraction Ethanol 70% V/V, excipiens pro compresso obducto."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 55812" do
      string = "tacalcitolum monohydricum 4.17 µg corresp. tacalcitolum 4 µg, paraffinum perliquidum, propylenglycolum 100 mg, triglycerida media, octyldodecanolum, macrogoli 21 aether stearylicus, diisopropylis adipas, dinatrii phosphas dodecahydricus, xanthani gummi, kalii dihydrogenophosphas, dinatrii edetas, aqua purificata, E 312, phenoxyethanolum, ad emulsionem pro 1 g."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 55931" do
      string = "methylphenidati hydrochloridum 10 mg, sacchari sphaerae corresp. saccharum max. 56.48 mg et saccharum mg et maydis amylum, maydis amylum, macrogolum 6000, ammonio methacrylatis copolymerum B, acidi methacrylici et methylis methacrylatis polymerisatum 1:1, talcum, triethylis citras, Kapselhülle: gelatina, E 171, E 172 (flavum), E 172 (nigrum), E 172 (rubrum), E 172 (flavum), E 172 (rubrum), E 172 (nigrum), Drucktinte: Drucktinte: lacca, lacca, propylenglycolum, propylenglycolum, kalii hydroxidum, ammoniae solutio 28 per centum, E 171, kalii hydroxidum, E 171, E 172 (rubrum), E 172 (rubrum), E 172 (flavum), E 172 (flavum), pro capsula, pro capsula."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 55938" do
      string = "cynarae extractum ethanolicum liquidum 414 mg, DER: 1:30, Auszugsmittel EtOH 65% v/v taraxaci radicis cum herba extractum ethanolicum liquidum 414 mg, DER: 1:17, Auszugsmittel EtOH 51% v/v boldo extractum ethanolicum liquidum 64 mg, DER: 1:10, Auszugsmittel EtOH 70% v/v menthae piperitae extractum ethanolicum liquidum 28 mg, DER: 1:18, Auszugsmittel EtOH 65% v/v ad solutionem pro 1 ml, corresp. ethanolum 60 % V/V."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 56046" do
      string = "ibuprofenum 100 mg, acidum citricum monohydricum, xanthani gummi, dinatrii edetas, polysorbatum 80, ethanolum anhydricum 16.8 mg, aromatica (orange), natrii cyclamas, saccharum 2.5 g, sorbitolum liquidum non cristallisabile 500 mg, E 211 12.5 mg, aqua, ad suspensionem corresp. natrium 3.4 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 56149" do
      string = "Lösung nach Rekonstitution (1:1): calcii chloridum anhydricum 0.1942 g ut calcii chloridum dihydricum, natrii chloridum 5.786 g, magnesii chloridum anhydricum 0.0476 g ut magnesii chloridum hexahydricum, glucosum 22.73 g ut glucosum monohydricum, natrii hydrogenocarbonas 2.94 g, aqua ad iniectabile q.s. ad solutionem pro 1000 ml, Corresp. natrium 134 mmol, calcium 1.75 mmol, magnesium 0.5 mmol, chloridum 104.5 mmol, hydrogenocarbonas 34 mmol, glucosum 126.1 mmol."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 56933" do
      string = "cimicifugae extractum ethanolicum siccum (Cimicifuga racemosa (L.) NUTT., rhizoma) 13 mg, DER: 4.5-8.5:1, Auszugsmittel EtOH 60% (V/V), povidonum K 29-32, carmellosum natricum conexum corresp. natrium 0.33-0.65 mg, cellulosum microcristallinum, lactosum monohydricum 44 mg, magnesii stearas, silica colloidalis anhydrica, pro compresso."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 56983" do
      string = "duloxetinum 60 mg ut duloxetini hydrochloridum, saccharum, hypromellosi acetas succinas, hypromellosum, sacchari sphaerae, talcum, triethylis citras, E 171, matériel de la capsule: E 132, E 171, gelatina, natrii laurilsulfas, E 172 (flavum), encre: lacca, propylenglycolum, natrii hydroxidum, povidonum, E 171, pro capsula corresp. saccharum 111 mg, natrium 0.0086 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 57029" do
      string = "propofolum 20 mg, sojae oleum 50 mg, triglycerida media, glycerolum, phospholipida purificata ex ovo, acidum oleicum, natrii hydroxidum, aqua ad iniectabile ad emulsionem pro 1 ml corresp. natrium 0.06 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 57051" do
      string = "harpagophyti radicis extractum ethanolicum siccum 480 mg, DER: 1.5-3:1, Auszugsmittel Ethanolum 60% V/V, excipiens pro compresso obducto."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 57231" do
      string = "sojae oleum 60 g, triglycerida media 60 g, olivae oleum 50 g, piscis oleum 30 g, lecithinum purificatum ex vitello ovi, glycerolum, natrii oleas, antiox.: E 307 163-225 mg, aqua ad iniectabile q.s. ad emulsionem pro 1000 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 57263" do
      string = "nystatinum 100000 U.I., glycerolum (85 per centum), silica colloidalis anhydrica, aqua purificata, saccharum 567.19 mg, aromatica (Himbeer) cum propylenglycolum et ethanolum, propylis parahydroxybenzoas 200 µg, E 218 1.8 mg, ad suspensionem pro 1 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 57417" do
      string = "rotigotinum 18.00 mg, silicone adhesive, povidonum K 90, E 223, E 304, E 307, poly(ethylenis terephthalas), ad praeparationem pro 40 cm², cum liberatione 8 mg/24h."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 57650" do
      string = "clobetasoli-17 propionas 0.5 mg, ethanolum 96 per centum, coco-betaine 30% aqueous solution, natrii laurilsulfas 70% aqueous solution 170 mg, polyquaternium-10, natrii citras dihydricus, acidum citricum monohydricum, aqua purificata, ad solutionem pro 1 g."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 57814" do
      string = "proteinum L1 papillomaviri humani typus 16 20 µg, proteinum L1 papillomaviri humani typus 18 20 µg, Adeps A 3-O-desacyl-4’-monophosphorylatus, aluminium ut aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum, natrii dihydrogenophosphas dihydricus, aqua ad iniectabilia q.s. ad suspensionem pro 0.5 ml corresp. natrium 1.82 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 57850" do
      string = "pollinis allergeni extractum (phleum pratense) 75000 SQ-T, pro dosi."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 58078" do
      string = "rivastigminum 27 mg, butyl methacrylate/methyl methacrylate copolymer, acrylic adhesive, int-rac-alpha-tocopherolum, silicone adhesive, dimeticonum, Trägermaterial: poly(ethylenis terephthalas), Drucktinte (Beige): ad praeparationem pro 15 cm², cum liberatione 13.3 mg/24h."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 58900" do
      string = "ginkgonis extractum siccum raffinatum et quantificatum 120 mg corresp. flavonglycosida ginkgo 26.4-32.4 mg et terpenlactona ginkgo 6.0-8.4 mg, DER: 35-67:1, Auszugsmittel acetonum 60% m/m, conserv.: E 200, excipiens pro compresso obducto."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 58943" do
      string = "human keratinocytes 33 %, human fibroblasts 67%, collagena, Dulbecco's modified eagle medium, Ham's F12, natrii hydrogenocarbonas, calcii chloridum dihydricum, glutaminum, adeninum, acidum selenicum, ethanolaminum, phosphatidylethanolaminum, hydrocortisonum, insulinum humanum (emp) (Rekombinates Human Insulinanalogon), aqua ad iniectabilia, pro praeparatione."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 58945" do
      string = "autologous cultured chondrocytes (entspricht 0.75 Mio Zellen/qcm) 8.25 - 44 Mio/11 cm², collagenum ex pericardio bovis (Matrize), Dulbecco's modified eagle medium /F12 (kommerziell hergestelltes Medium mit vertraglich vereinbarter Rezeptur), folgende Komponenten sind enthalten in den 14.8 ml acidum ascorbicum, chondroitini sulfas natricus, insulinum humanum (emp), diboterminum alfa, albuminum seri humani, glucosum, calcii pantothenas, acidum folicum, inositolum, nicotinamidum, pyridoxini hydrochloridum, riboflavinum, thiamini hydrochloridum, acidum (+)-alpha-liponicum, biotinum, ethylis linolenas, cyanocobalaminum Hypoxanthin, Thymidin, Putrescin, alaninum, arginini hydrochloridum, asparaginum monohydricum, acidum glutamicum, cysteini hydrochloridum monohydricum, acidum glutamicum, histidini hydrochloridum monohydricum, isoleucinum , Leucin, lysini hydrochloridum, methioninum, phenylalaninum, prolinum, serinum, threoninum, tryptophanum , Thyrosin, valinum, cystinum, glycinum, glutaminum, acidum hydroxyethylpiperazinethansulfonicum, natrii pyruvas, natrii chloridum, kalii chloridum , MgSo4, natrii dihydrogenophosphas, natrii hydrogenocarbonas, ferrosi sulfas heptahydricus , Eisen(III)-nitrat, dinatrii hydrogenophosphas, cupri sulfas pentahydricus, zinci sulfas heptahydricus, magnesii chloridum anhydricum, calcii chloridum anhydricum, cholini chloridum, aqua ad iniectabilia, saccharum (in BMP-2 (Stocklösung) enthalten), natrii hydroxidum (in BMP-2 (Stocklösung) enthalten), polysorbatum 80 (in BMP-2 (Stocklösung) enthalten), albumini humani solutio (in BMP-2 (Stocklösung) enthalten), caprylas (in BMP-2 (Stocklösung) enthalten), N-acetyltryptophanum (in BMP-2 (Stocklösung) enthalten), metacresolum (im Humaninsulin enthalten), glycerolum (im Humaninsulin enthalten), pro dosi."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 59263" do
      string = "budesonidum 2 mg, propylenglycolum 600.3 mg, alcohol cetylicus et stearylicus 12.6-15.12 mg, polysorbatum 60, macrogoli 10 aether stearylicus, alcohol cetylicus 8.4 mg, acidum citricum monohydricum, dinatrii edetas, aqua purificata ad emulsionem pro dosi, propellentia: butanum, isobutanum, propanum."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 59777" do
      string = "mesalazinum 1000 mg, polysorbatum 60, alcohol cetylicus et stearylicus 9.1 mg, dinatrii edetas, propylenglycolum 3436 mg, E 223, nitrogenium, propanum et butanum et isobutanum, propellentia et ad suspensionem pro dosi."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 59959" do
      string = "ciclopiroxum olaminum 10 mg, octyldodecanolum, paraffinum perliquidum, alcohol stearylicus 57.5 mg, alcohol cetylicus 57.5 mg, myristyl alcohol, sorbitani stearas, polysorbatum 60, cocamide dea, alcohol benzylicus 10 mg, acidum lacticum, aqua purificata, ad emulsionem pro 1000 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60469" do
      string = "somatropinum ADNr 15 mg corresp. 45 U.I., mannitolum, histidinum, poloxamerum 188, phenolum, acidum hydrochloridum, natrii hydroxidum corresp. natrium max. 0.x mg, aqua ad iniectabile q.s. ad solutionem pro 1.5 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60544" do
      string = "mometasoni-17 furoas 1 mg corresp. mometasonum mg, aqua purificata, vaselinum album cum E 321 50 ppm, paraffinum liquidum, hexylene glycol, cetylanum 72 mg, macrogoli aether cetostearylicus, alcohol cetylicus 10 mg, glycerolum, acidum citricum, natrii citras dihydricus, xanthani gummi, ad unguentum pro 1 g."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60606" do
      string = "acari allergeni extractum 5000 U. ut acari allergeni extractum (Dermatophagoides farinae) 50 % et acari allergeni extractum (Dermatophagoides pteronyssinus) 50 %, aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum, natrii hydrogenocarbonas, phenolum, aqua ad iniectabile ad suspensionem pro 1 ml corresp. natrium 3.5 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60608" do
      string = "acari allergeni extractum (Dermatophagoides farinae) 5000 U., aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum, natrii hydrogenocarbonas, phenolum, aqua ad iniectabile ad suspensionem pro 1 ml corresp. natrium 3.5 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60609" do
      string = "acari allergeni extractum (Dermatophagoides pteronyssinus) 5000 U., aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum, natrii hydrogenocarbonas, phenolum, aqua ad iniectabile ad suspensionem pro 1 ml corresp. natrium 3.5 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60621" do
      string = "pollinis allergeni extractum 10000 U. ut pollinis allergeni extractum (Dactylis glomerata) 10 % et pollinis allergeni extractum (Festuca pratensis) 10 % et pollinis allergeni extractum (Holcus lanatus) 10 % et pollinis allergeni extractum (Lolium perenne) 10 % et pollinis allergeni extractum (Phleum pratense) 10 % et pollinis allergeni extractum (Poa pratensis) 10 % et pollinis allergeni extractum (Artemisia vulgaris) 20 % et pollinis allergeni extractum (Secale cereale) 20 %, aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum, natrii hydrogenocarbonas, phenolum, aqua ad iniectabile ad suspensionem pro 1 ml corresp. natrium 3.5 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60623" do
      string = "pollinis allergeni extractum 10000 U. ut pollinis allergeni extractum (Dactylis glomerata) 10 % et pollinis allergeni extractum (Festuca pratensis) 10 % et pollinis allergeni extractum (Holcus lanatus) 10 % et pollinis allergeni extractum (Lolium perenne) 10 % et pollinis allergeni extractum (Phleum pratense) 10 % et pollinis allergeni extractum (Poa pratensis) 10 % et pollinis allergeni extractum (Betula spec.) 20 % et pollinis allergeni extractum (Secale cereale) 20 %, aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum, natrii hydrogenocarbonas, phenolum, aqua ad iniectabile ad suspensionem pro 1 ml corresp. natrium 3.5 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60624" do
      string = "pollinis allergeni extractum 10000 U. ut pollinis allergeni extractum (Alnus glutinosa) 50 % et pollinis allergeni extractum (Corylus avellana) 50 %, aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum, natrii hydrogenocarbonas, phenolum, aqua ad iniectabile ad suspensionem pro 1 ml corresp. natrium 3.5 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60625" do
      string = "pollinis allergeni extractum 10000 U. ut pollinis allergeni extractum (Dactylis glomerata) 7.3 % et pollinis allergeni extractum (Festuca pratensis) 7.3 % et pollinis allergeni extractum (Holcus lanatus) 7.3 % et pollinis allergeni extractum (Lolium perenne) 7.3 % et pollinis allergeni extractum (Phleum pratense) 7.3 % et pollinis allergeni extractum (Poa pratensis) 7.3 % et pollinis allergeni extractum (Hordeum vulgare) 8 % et pollinis allergeni extractum (Avena sativa) 8 % et pollinis allergeni extractum (Secale cereale) 12 % et pollinis allergeni extractum (Triticum sativum) 8 % et pollinis allergeni extractum (Plantago lanceolata) 20 %, aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum, natrii hydrogenocarbonas, phenolum, aqua ad iniectabile ad suspensionem pro 1 ml corresp. natrium 3.5 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60626" do
      string = "pollinis allergeni extractum 10000 U. ut pollinis allergeni extractum (Dactylis glomerata) 7.3 % et pollinis allergeni extractum (Festuca pratensis) 7.3 % et pollinis allergeni extractum (Holcus lanatus) 7.3 % et pollinis allergeni extractum (Lolium perenne) 7.3 % et pollinis allergeni extractum (Phleum pratense) 7.3 % et pollinis allergeni extractum (Poa pratensis) 7.3 % et pollinis allergeni extractum (Hordeum vulgare) 8 % et pollinis allergeni extractum (Avena sativa) 8 % et pollinis allergeni extractum (Secale cereale) 12 % et pollinis allergeni extractum (Triticum sativum) 8 % et pollinis allergeni extractum (Artemisia vulgaris) 20 %, aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum, natrii hydrogenocarbonas, phenolum, aqua ad iniectabile ad suspensionem pro 1 ml corresp. natrium 3.5 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60627" do
      string = "pollinis allergeni extractum 10000 U. ut pollinis allergeni extractum (Dactylis glomerata) 7.3 % et pollinis allergeni extractum (Festuca pratensis) 7.3 % et pollinis allergeni extractum (Holcus lanatus) 7.3 % et pollinis allergeni extractum (Lolium perenne) 7.3 % et pollinis allergeni extractum (Phleum pratense) 7.3 % et pollinis allergeni extractum (Poa pratensis) 7.3 % et pollinis allergeni extractum (Hordeum vulgare) 8 % et pollinis allergeni extractum (Avena sativa) 8 % et pollinis allergeni extractum (Secale cereale) 12 % et pollinis allergeni extractum (Triticum sativum) 8 % et pollinis allergeni extractum (Betula spec.) 20 %, aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum, natrii hydrogenocarbonas, phenolum, aqua ad iniectabile ad suspensionem pro 1 ml corresp. natrium 3.5 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60628" do
      string = "pollinis allergeni extractum 10000 U. ut pollinis allergeni extractum (Dactylis glomerata) 10 % et pollinis allergeni extractum (Festuca pratensis) 10 % et pollinis allergeni extractum (Holcus lanatus) 10 % et pollinis allergeni extractum (Lolium perenne) 10 % et pollinis allergeni extractum (Phleum pratense) 10 % et pollinis allergeni extractum (Poa pratensis) 10 % et pollinis allergeni extractum (Secale cereale) 40 %, aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum, natrii hydrogenocarbonas, phenolum, aqua ad iniectabile ad suspensionem pro 1 ml corresp. natrium 3.5 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60629" do
      string = "pollinis allergeni extractum 10000 U. ut pollinis allergeni extractum (Dactylis glomerata) 13.3 % et pollinis allergeni extractum (Festuca pratensis) 13.3 % et pollinis allergeni extractum (Holcus lanatus) 13.3 % et pollinis allergeni extractum (Lolium perenne) 13.3 % et pollinis allergeni extractum (Phleum pratense) 13.3 % et pollinis allergeni extractum (Poa pratensis) 13.3 % et pollinis allergeni extractum (Secale cereale) 20 %, aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum, natrii hydrogenocarbonas, phenolum, aqua ad iniectabile ad suspensionem pro 1 ml corresp. natrium 3.5 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60630" do
      string = "pollinis allergeni extractum 10000 U. ut pollinis allergeni extractum (Dactylis glomerata) 9.2 % et pollinis allergeni extractum (Festuca pratensis) 9.2 % et pollinis allergeni extractum (Holcus lanatus) 9.2 % et pollinis allergeni extractum (Lolium perenne) 9.2 % et pollinis allergeni extractum (Phleum pratense) 9.2 % et pollinis allergeni extractum (Poa pratensis) 9.2 % et pollinis allergeni extractum (Hordeum vulgare) 10 % et pollinis allergeni extractum (Avena sativa) 10 % et pollinis allergeni extractum (Secale cereale) 15 % et pollinis allergeni extractum (Triticum sativum) 10 %, aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum, natrii hydrogenocarbonas, phenolum, aqua ad iniectabile ad suspensionem pro 1 ml corresp. natrium 3.5 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60631" do
      string = "pollinis allergeni extractum 10000 U. ut pollinis allergeni extractum (Dactylis glomerata) 16.7 % et pollinis allergeni extractum (Festuca pratensis) 16.7 % et pollinis allergeni extractum (Holcus lanatus) 16.7 % et pollinis allergeni extractum (Lolium perenne) 16.7 % et pollinis allergeni extractum (Phleum pratense) 16.7 % et pollinis allergeni extractum (Poa pratensis) 16.7 %, aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum, natrii hydrogenocarbonas, phenolum, aqua ad iniectabile ad suspensionem pro 1 ml corresp. natrium 3.5 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60632" do
      string = "pollinis allergeni extractum (Plantago lanceolata) 10000 U., aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum, natrii hydrogenocarbonas, phenolum, aqua ad iniectabile ad suspensionem pro 1 ml corresp. natrium 3.5 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60633" do
      string = "pollinis allergeni extractum (Alnus glutinosa) 10000 U., aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum, natrii hydrogenocarbonas, phenolum, aqua ad iniectabile ad suspensionem pro 1 ml corresp. natrium 3.5 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60634" do
      string = "pollinis allergeni extractum 10000 U. ut pollinis allergeni extractum (Dactylis glomerata) 8.3 % et pollinis allergeni extractum (Festuca pratensis) 8.3 % et pollinis allergeni extractum (Holcus lanatus) 8.3 % et pollinis allergeni extractum (Lolium perenne) 8.3 % et pollinis allergeni extractum (Phleum pratense) 8.3 % et pollinis allergeni extractum (Poa pratensis) 8.3 % et pollinis allergeni extractum (Betula spec.) 20 % et pollinis allergeni extractum (Secale cereale) 15 % et pollinis allergeni extractum (Plantago lanceolata) 15 %, aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum, natrii hydrogenocarbonas, phenolum, aqua ad iniectabile ad suspensionem pro 1 ml corresp. natrium 3.5 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60635" do
      string = "pollinis allergeni extractum 10000 U. ut pollinis allergeni extractum (Dactylis glomerata) 8.3 % et pollinis allergeni extractum (Festuca pratensis) 8.3 % et pollinis allergeni extractum (Holcus lanatus) 8.3 % et pollinis allergeni extractum (Lolium perenne) 8.3 % et pollinis allergeni extractum (Phleum pratense) 8.3 % et pollinis allergeni extractum (Poa pratensis) 8.3 % et pollinis allergeni extractum (Artemisia vulgaris) 20 % et pollinis allergeni extractum (Secale cereale) 15 % et pollinis allergeni extractum (Plantago lanceolata) 15 %, aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum, natrii hydrogenocarbonas, phenolum, aqua ad iniectabile ad suspensionem pro 1 ml corresp. natrium 3.5 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60636" do
      string = "pollinis allergeni extractum 10000 U. ut pollinis allergeni extractum (Betula spec.) 35 % et pollinis allergeni extractum (Alnus glutinosa) 30 % et pollinis allergeni extractum (Corylus avellana) 35 %, aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum, natrii hydrogenocarbonas, phenolum, aqua ad iniectabile ad suspensionem pro 1 ml corresp. natrium 3.5 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60637" do
      string = "pollinis allergeni extractum 10000 U. ut pollinis allergeni extractum (Dactylis glomerata) 10 % et pollinis allergeni extractum (Festuca pratensis) 10 % et pollinis allergeni extractum (Holcus lanatus) 10 % et pollinis allergeni extractum (Lolium perenne) 10 % et pollinis allergeni extractum (Phleum pratense) 10 % et pollinis allergeni extractum (Poa pratensis) 10 % et pollinis allergeni extractum (Plantago lanceolata) 20 % et pollinis allergeni extractum (Secale cereale) 20 %, aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum, natrii hydrogenocarbonas, phenolum, aqua ad iniectabile ad suspensionem pro 1 ml corresp. natrium 3.5 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60638" do
      string = "pollinis allergeni extractum (Secale cereale) 10000 U., aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum, natrii hydrogenocarbonas, phenolum, aqua ad iniectabile ad suspensionem pro 1 ml corresp. natrium 3.5 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60639" do
      string = "pollinis allergeni extractum (Corylus avellana) 10000 U., aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum, natrii hydrogenocarbonas, phenolum, aqua ad iniectabile ad suspensionem pro 1 ml corresp. natrium 3.5 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60640" do
      string = "pollinis allergeni extractum (Parietaria officinalis) 10000 U., aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum, natrii hydrogenocarbonas, phenolum, aqua ad iniectabile ad suspensionem pro 1 ml corresp. natrium 3.5 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60641" do
      string = "pollinis allergeni extractum (Artemisia vulgaris) 10000 U., aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum, natrii hydrogenocarbonas, phenolum, aqua ad iniectabile ad suspensionem pro 1 ml corresp. natrium 3.5 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60642" do
      string = "pollinis allergeni extractum (Betula spec.) 10000 U., aluminii hydroxidum hydricum ad adsorptionem, natrii chloridum, natrii hydrogenocarbonas, phenolum, aqua ad iniectabile ad suspensionem pro 1 ml corresp. natrium 3.5 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60689" do
      string = "I) Glucoselösung 42 %: glucosum 62.5 g ut glucosum monohydricum, aqua ad iniectabile q.s. ad solutionem pro 149 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 60951" do
      string = "acari allergeni extractum 10 U. ut acari allergeni extractum (Dermatophagoides pteronyssinus) 50% et acari allergeni extractum (Dermatophagoides farinae) 50%, natrii chloridum corresp. natrium 3.6 mg, phenolum, aluminii hydroxidum hydricum ad adsorptionem, mannitolum, aqua ad iniectabile q.s. ad suspensionem pro 1 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 61359" do
      string = "acidum fusidicum anhydricum 20 mg ut acidum fusidicum, vaselinum album, E 307, alcohol cetylicus 100 mg, paraffinum liquidum, polysorbatum 60, aqua purificata, glycerolum (85 per centum), acidum hydrochloridum dilutum, E 320 0.5 mg, E 202 2.75 mg, ad emulsionem pro 1 g."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 61514" do
      string = "olanzapinum 15 mg, lactosum 75% + cellulosum 25% corresp. lactosum monohydricum 255.38 mg, amylum pregelificatum, maydis amylum, silica colloidalis anhydrica, magnesii stearas, pro compresso."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 62104" do
      string = "xylometazolini hydrochloridum 0.14 mg, dinatrii edetas, natrii dihydrogenophosphas dihydricus, dinatrii phosphas dodecahydricus, sorbitolum, aqua ad iniectabile ad solutionem pro dosi corresp. natrium 0.14 mg, doses pro vase 107."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 62675" do
      string = "azelastini hydrochloridum 0.137 mg, fluticasoni propionas 0.05 mg, dinatrii edetas, glycerolum, cellulosum microcristallinum et carmellosum natricum, polysorbatum 80, benzalkonii chloridum 0.014 mg, alcohol phenylethylicus, aqua purificata, ad suspensionem pro dosi."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 62827" do
      string = "uvae ursi folii extractum ethanolicum siccum (Arctostaphylos uva-ursi (L.) Spreng, folium) 238.7-297.5 mg corresp. arbutinum 21% DER: 3.5-5.5:1 Auszugsmittel Ethanolum 60 % V/V, lactosum monohydricum 73.1-45.5 mg, silica colloidalis anhydrica, cellulosum microcristallinum, magnesii stearas, Überzug: partialglycerida longicatenalia, magnesii stearas, hypromellosum, color.: E 104, macrogolum 6000, E 132, E 171, aluminii oxidum hydricum, pro compresso obducto."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 62874" do
      string = "propofolum 20 mg, sojae oleum 50 mg, triglycerida media, glycerolum, phospholipida purificata ex ovo, acidum oleicum, natrii hydroxidum, aqua ad iniectabile q.s. ad emulsionem pro 1 ml corresp. natrium 0.06 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 63165" do
      string = "imiquimodum 37.5 mg, acidum isostearicum, alcohol benzylicus 20.0 mg, alcohol cetylicus 22.0 mg, alcohol stearylicus 31.0 mg, vaselinum album, polysorbatum 60, sorbitani stearas, glycerolum, xanthani gummi, E 218 2.0 mg, propylis parahydroxybenzoas 0.2 mg, aqua purificata, ad emulsionem pro 1 g."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 63180" do
      string = "dinatrii phosphas dihydricus 453 mg et natrii dihydrogenophosphas dihydricus 75 mg corresp. natrium 128.13 mg et phosphas 288 mg = 3 mmol, silica colloidalis anhydrica, amylum pregelificatum, magnesii stearas, Kapselhülle: gelatina, titanii dioxidum, E 129 29 µg, pro capsula."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65080" do
      string = "strontium(82-Sr) 3.7 GBq, stanni(II) oxidum, natrii chloridum corresp. natrium 10.65 g, trometamolum, ammoniae solutio 30 per centum, acidum hydrochloridum ad pH, natrii hydroxidum ad pH, aqua ad iniectabile q.s. pro vitro."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65094" do
      string = "extractum spissum ex: echinaceae purpureae herbae recentis tinctura 1.140 g, DER: 1:12, Auszugsmittel Ethanol 57.3% m/m, et echinaceae purpureae radicis recentis tinctura 0.060 g, DER: 1:11, Auszugsmittel Ethanol 57.3% m/m, saccharum, E 202, excipiens ad solutionem pro 5 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65095" do
      string = "celecoxibum 100 mg, lactosum monohydricum 149.7 mg, natrii laurilsulfas, povidonum K 30, carmellosum natricum conexum, magnesii stearas, Kapselhülle: gelatina, E 171, Drucktinte: lacca, propylenglycolum, E 132, pro capsula corresp., natrium 0.71 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65193" do
      string = "cucurbitae oleum 227.3 mg, extracta aquosa sicca: 80 mg ex, rhois aromaticae arboris cortex 56 mg DER: 5-7:1, glucosum liquidum, extracta aquosa sicca: 20 mg ex lupuli strobulus 18 mg DER: 5.5-6.5:1, maltodextrinum, excipiens pro capsula."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65219" do
      string = "Kapsel: orlistatum 120 mg, cellulosum microcristallinum, carboxymethylamylum natricum A, silica colloidalis anhydrica, natrii laurilsulfas, Kapselhülle: gelatina, E 171, E 132, pro capsula corresp., natrium 1.92 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65371" do
      string = "mercaptopurinum monohydricum 20 mg, xanthani gummi, aspartamum 3 mg, rubi idaei succus concentratus cum saccharum max. 32 mg et E 220 max. 0.24 mg, E 219 1.15 mg, E 215 0.57 mg, E 202, natrii hydroxidum, aqua purificata ad suspensionem pro 1 ml corresp. natrium max. 0.68 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65381" do
      string = "darunavirum 100 mg ut darunavirum ethanolum, hydroxypropylcellulosum, cellulosum microcristallinum, carmellosum natricum, acidum citricum monohydricum, sucralosum, acidum hydrochloridum concentratum, aromatica (Geschmacksüberdeckungsaroma), aromatica (Erdbeer), E 219 3.43 mg, aqua purificata ad suspensionem pro 1 ml corresp. natrium 570 µg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65608" do
      string = "ibuprofenum 150 mg, saccharum 3.75 g, sorbitolum liquidum non cristallisabile 750 mg, xanthani gummi, polysorbatum 80, acidum citricum monohydricum, dinatrii edetas, ethanolum anhydricum 25.2 mg, aromatica (orange), natrii cyclamas, E 211 18.8 mg, aqua ad suspensionem corresp. natrium 5.17 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65642" do
      string = "arnica montana ex herba spag. Zimpel TM 0.150 ml, arnica montana e radice spag. Zimpel TM 0.0166 ml, belladonna (Ph.Eur.Hom.) spag. Zimpel D4 0.166 ml, ferrum phosphoricum (HAB) spag. Glückselig D6 0.166 ml, phytolacca americana spag. Zimpel D4 0.166 ml, salvia officinalis spag. Zimpel TM 0.166 ml, tropaeolum majus ex herba recens spag. Zimpel TM 0.166 ml, 1 ml corresp., corresp. ethanolum 23.0 % m/V."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65726" do
      string = "I) Glucoselösung: glucosum 90 g ut glucosum monohydricum, acidum citricum monohydricum, aqua ad iniectabile q.s. ad pH, q.s. ad solutionem pro 250 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65745" do
      string = "Praeparatio cryodesiccata: bothrops sp. venensis antitoxinum equis F(ab')2 Neutralisierungskapazität NLT: 780 LD50, crotalus sp. venensis antitoxinum equis F(ab')2 Neutralisierungskapazität NLT: 780 LD50, conserv.: metacresolum ≤ 0.4 % m/m, pro vitro."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65746" do
      string = "Praeparatio cryodesiccata: bothrops sp. venensis antitoxinum equis F(ab')2 Neutralisierungskapazität NLT: 780 LD50, crotalus sp. venensis antitoxinum equis F(ab')2 Neutralisierungskapazität NLT: 220 LD50, lachesis sp. venensis antitoxinum equis F(ab')2 Neutralisierungskapazität NLT: 200 LD50, conserv.: metacresolum ≤ 0.4 % m/m, pro vitro."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65748" do
      string = "Lösung: immunoglobulinum monovalentum equis pseudechis australis 18000 U.I., natrii chloridum, conserv.: phenolum ≤ 0.22 % m/V, aqua ad iniectabilia q.s. ad solutionem."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65749" do
      string = "Lösung: immunoglobulinum monovalentum equis pseudonaja textilis 1000 U.I., natrii chloridum, conserv.: phenolum ≤ 0.22 % m/V, aqua ad iniectabilia q.s. ad solutionem."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65750" do
      string = "Praeparatio cryodesiccata: naja naja kaouthia venensis antitoxinum equis F(ab')2 Neutralisierungskapazität 6 mg Schlangengift, glycinum, natrii chloridum, conserv.: phenolum ≤ 0.25 % m/m, pro vitro."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65752" do
      string = "Lösung: immunoglobulinum monovalentum equis acanthophis antarcticus 6000 U.I. natrii chloridum, conserv.: phenolum ≤ 0.22 % m/V, aqua ad iniectabilia q.s. ad solutionem."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65753" do
      string = "Praeparatio cryodesiccata: trimeresurus albolabris venensis antitoxinum equis F(ab')2 Neutralisierungskapazität 7 mg Schlangengift, glycinum, natrii chloridum, conserv.: phenolum ≤ 0.25 % m/m, pro vitro."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65754" do
      string = "Praeparatio cryodesiccata: ophiophagus hannah venensis antitoxinum equis F(ab')2 Neutralisierungskapazität 8 mg Schlangengift, glycinum, natrii chloridum, conserv.: phenolum ≤ 0.25 % m/m, pro vitro."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65755" do
      string = "Praeparatio cryodesiccata: calloselasma rhodostoma venensis antitoxinum equis F(ab')2 Neutralisierungskapazität 16 mg Schlangengift, glycinum, natrii chloridum, conserv.: phenolum ≤ 0.25 % m/m, pro vitro."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65756" do
      string = "Lösung: bitis arietans venensis antitoxinum equis F(ab')2 Neutralisierungskapazität NLT: 250 LD50, cerastes cerastes venensis antitoxinum equis F(ab')2 Neutralisierungskapazität NLT: 250 LD50, echis carinatus venensis antitoxinum equis F(ab')2 Neutralisierungskapazität NLT: 250 LD50, echis coloratus venensis antitoxinum equis F(ab')2 Neutralisierungskapazität NLT: 250 LD50, naja haje venensis antitoxinum equis F(ab')2 Neutralisierungskapazität NLT: 250 LD50, walterinnesia aegyptia venensis antitoxinum equis F(ab')2 Neutralisierungskapazität NLT: 250 LD50, conserv.: metacresolum ≤ 35 mg, natrii chloridum, aqua ad iniectabilia q.s. ad solutionem pro 10 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65757" do
      string = "Lösung: immunoglobulinum monovalentum equis latrodectus hasselti 500 U. Neutralisierungskapazität 5 mg Spinnengift, natrii chloridum, conserv.: phenolum ≤ 0.22 % m/V, aqua ad iniectabilia q.s. ad solutionem."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65758" do
      string = "Praeparatio cryodesiccata: daboia russelii siamensis venensis antitoxinum equis F(ab')2 Neutralisierungskapazität 6 mg Schlangengift, glycinum, natrii chloridum, conserv.: phenolum ≤ 0.25 % m/m, pro vitro."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65759" do
      string = "Lösung: immunoglobulinum monovalentum equis dispholidus typus gemäss FI, natrii chloridum, conserv.: metacresolum ≤ 0.35 % m/V, aqua ad iniectabilia q.s. ad solutionem pro 10 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65761" do
      string = "Lösung: immunoglobulinum equis bitis arietans, immunoglobulinum equis bitis gabonica, immunoglobulinum equis hemachatus haemachatus, immunoglobulinum equis dendroaspis angusticeps, immunoglobulinum equis dendroaspis jamesoni, immunoglobulinum equis dendroaspis polylepis, immunoglobulinum equis naja nivea, immunoglobulinum equis naja melanoleuca, immunoglobulinum equis naja annulifera, immunoglobulinum equis naja mossambica, Für alle Globuline: Dosierung gemäss FI, natrii chloridum, conserv.: metacresolum ≤ 0.35 % m/V, aqua ad iniectabilia, q.s. ad solutionem."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65778" do
      string = "I) Radionuklidgenerator: molybdenum(99-Mo) zum Kalibrierungszeitpunkt 2.3-57.1 GBq aluminii oxidum, natrii chloridum corresp. natrium 0.71 g, acidum nitricum, natrii hydroxidum, aqua ad iniectabile, q.s. pro praeparatione."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65781" do
      string = "Kapsel: duloxetinum 60 mg ut duloxetini hydrochloridum, sacchari sphaerae, hypromellosum, saccharum 17.22 mg, talcum, triethylis citras, hypromellosi acetas succinas, ammonii hydroxidum, hypromellosum, E 171, talcum, Kapselhülle: gelatina, E 132, E 171, E 172 (flavum) pro capsula corresp. saccharum 131.76 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65795" do
      string = "Kapsel: duloxetinum 60 mg ut duloxetini hydrochloridum, sacchari sphaerae, maydis amylum, hydroxypropylcellulosum, hypromellosum, hypromellosi acetas succinas, saccharum, talcum, E 171, Kapselhülle: gelatina, E 132, E 171, E 172 (flavum) pro capsula corresp. saccharum 132.46 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65823" do
      string = "Praeparatio cryodesiccata: acari allergeni extractum (dermatophagoides pteronyssinus, dermatophagoides farinae) 12 U., gelatina, mannitolum 12.7 mg, natrii hydroxidum corresp. natrium 0.14 mg, pro dosi."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 65862" do
      string = "1 ml corresp. dilutio spag. Baumann D1 ex angelica archangelica et coffea arabica et crataegus et datura stramonium et valeriana officinalis et leonurus cardiaca et melissa officinalis et ana partes ad solutionem, corresp. ethanolum 22-27 % V/V."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 66093" do
      string = "ciclosporinum 1 mg, triglycerida media, tyloxapolum, glycerolum, poloxamerum 188, cetalkonii chloridum, natrii hydroxidum, aqua ad iniectabile, ad emulsionem pro 1 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 66156" do
      string = "haemagglutininum influenzae A (H5N1) et neuraminidasum inactivatum (Virus-Stamm A/Vietnam/1194/2004 NIBRG-14) 7.5 µg, adjuvans MF59C.1: squalenum, polysorbatum 80, sorbitani trioleas, natrii citras dihydricus, acidum citricum monohydricum, excipiens: natrii chloridum, kalii chloridum, kalii dihydrogenophosphas, dinatrii phosphas dihydricus, magnesii chloridum hexahydricum, calcii chloridum dihydricum, aqua ad iniectabilia q.s. ad suspensionem pro 0.5 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 66161" do
      string = "haemagglutininum influenzae A (H5N1) et neuraminidasum inactivatum (Virus-Stamm A/Vietnam/1194/2004 NIBRG-14) 7.5 µg, adjuvans MF59C.1: squalenum, polysorbatum 80, sorbitani trioleas, natrii citras dihydricus, acidum citricum monohydricum, excipiens: natrii chloridum, kalii chloridum, kalii dihydrogenophosphas, dinatrii phosphas dihydricus, magnesii chloridum hexahydricum, calcii chloridum dihydricum, conserv.: thiomersalum 50 µg, aqua ad iniectabilia, q.s. ad suspensionem pro 0.5 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 66174" do
      string = "arctostaphylos uvae-ursi herbae recentis tinctura 715.0 mg, DER: 1:4, Auszugsmittel ethanolum 50.6% V/V, echinaceae purpureae herbae recentis tinctura 240.0 mg, DER: 1:12, Auszugsmittel ethanolum 65.1% V/V, excipiens ad solutionem, corresp. ethanolum 50-58 % V/V."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 66427" do
      string = "haemagglutininum influenzae A (H1N1) (Virus souche A/Guangdong-Maonan/SWL1536/2019 (H1N1)-pdm09: reassortant virus CNIC-19 derived from A/Guangdong-Maonan/SWL1536/2019) 15 µg, haemagglutininum influenzae A (H3N2) (Virus souche A/Hong Kong/2671/2019 (H3N2)-like: reassortant virus IVR-208 derived from A/Hong Kong/2671/2019) 15 µg, haemagglutininum influenzae B (Virus souche B/Washington/02/2019 (Victoria lineage)) 15 µg, haemagglutininum influenzae B (Virus souche B/Phuket/3073/2013 (Yamagata lineage)) 15 µg, natrii chloridum, kalii chloridum, dinatrii phosphas dihydricus, kalii dihydrogenophosphas, aqua ad iniectabilia q.s. ad suspensionem pro 0.5 ml corresp. natrium 1.72 mg, kalium 0.08 mg, residui: formaldehydum, octoxinolum-9, neomycinum, ovalbuminum."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 66540" do
      string = "I) Durchstechflasche 1: HYNIC-[D-Phe(1), Tyr(3)-octreotidi]trifluoroacetum 16 µg, tricinum, stannosi chloridum dihydricum, mannitolum, pro vitro."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 66731" do
      string = "acidum fusidicum anhydricum 20 mg ut acidum fusidicum, betamethasonum 1 mg ut betamethasoni valeras, macrogol 21 aether stearylicus, alcohol cetylicus et stearylicus 55.000 mg, paraffinum liquidum, vaselinum album, E 307, hypromellosum, acidum citricum monohydricum, propylis parahydroxybenzoas 0.16 mg, E 218 0.8 mg, E 202 2.5 mg, aqua ad unguentum pro 1 g."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 66742" do
      string = "Filmtablette Morgendosis (ivacaftorum/tezacaftorum): ivacaftorum 150 mg, tezacaftorum 100 mg, hypromellosi acetas succinas, natrii laurilsulfas, hypromellosum, cellulosum microcristallinum, carmellosum natricum conexum, magnesii stearas, Überzug: hypromellosum, hydroxypropylcellulosum, talcum, E 171, E 172 (flavum) pro compresso obducto corresp. natrium 2.74 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 66778" do
      string = "Beutel: tisagenlecleucelum CAR-positive lebensfähige T-Zellen. Enthält genetisch veränderte Zellen 1,2x10e6–6,0x10e8 pro dosi, natrium, chloridum, magnesium, acetas, gluconas, glucosum, 5-hydroxymethylfurfuralum, albuminum, N-acetyltryptophanum natricum, caprylas, aluminium, dextranum 40, dimethylis sulfoxidum, dimethylis sulfonum, q.s. pro 50 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 66852" do
      string = "ibuprofenum 200 mg, polysorbatum 80, glycerolum, maltitolum liquidum 2.226 g, saccharinum natricum, acidum citricum monohydricum, natrii citras anhydricus, xanthani gummi, natrii chloridum, aromatica (Erdbeer), propylenglycolum 16.5 mg, domipheni bromidum, aqua purificata, ad suspensionem pro 5 ml corresp. natrium 9.35 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 66988" do
      string = "dextromethorphanum 25 mg ut dextromethorphani hydrobromidum, magnesium aluminium silicate, ethanolum 96 per centum 50 mg, acidum citricum monohydricum, natrii citras dihydricus, cellulosum microcristallinum et carmellosum natricum, sorbitolum liquidum non cristallisabile 5.5 g, aqua purificata, aromatica, propylenglycolum 8.6 mg, natrii cyclamas 2-ethyl-3-hydroxy-4-pyronum, E 150(a), propylis parahydroxybenzoas 3 mg, E 218 10 mg ad suspensionem pro 10 ml corresp. natrium 31.7 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 67275" do
      string = "Praeparatio cryodesiccata: pollinis allergeni extractum (Betula verrucosa) 12 U., pro dosi."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 67295" do
      string = "latanoprostum 50 µg, timololum 5 mg corresp. timololi maleas 6.830 mg, macrogolglyceroli hydroxystearas, sorbitolum, glyceroli monostearas, macrogoli 4000 monostearas, carbomerum, dinatrii edetas, natrii hydroxidum, aqua ad iniectabile, nitrogenium, ad solutionem pro 1 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 67366" do
      string = "posaconazolum 200 mg, macrogolglyceroli hydroxystearas 25 mg, natrii citras dihydricus, acidum citricum monohydricum, dimeticonum, silica colloidalis hydrica, methylcellulosum, acidum sorbicum, polysorbatum 65, macrogoli stearas, xanthani gummi, glucosum liquidum 1.75 g, glycerolum, acidum benzoicum < 12 µg, acidum sulfuricum, aromatica (Erdbeeraroma), propylenglycolum 10.86 mg, E 171, E 211 11.4 mg, aqua purificata, ad suspensionem pro 5 ml corresp., natrium 2.52 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 67378" do
      string = "natrii alginas 500 mg, natrii hydrogenocarbonas 213 mg, calcii carbonas 325 mg, carbomerum 974P, natrii hydroxidum, aqua purificata, saccharinum natricum, aromatica, propylis parahydroxybenzoas 6 mg, E 218 40 mg, ad suspensionem pro dosi corresp. natrium 127.25 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 67379" do
      string = "natrii alginas 500 mg, natrii hydrogenocarbonas 213 mg, calcii carbonas 325 mg, carbomerum 974P, natrii hydroxidum, aqua purificata, saccharinum natricum, aromatica, propylis parahydroxybenzoas 6 mg, E 218 40 mg ad suspensionem pro 10 ml corresp. natrium 127.25 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 67503" do
      string = "exenatidum 2 mg, saccharum, poly(lactidum-co-glycolidum) 50/50 (0.40 - 0.49 dl/g), triglycerida media, ad suspensionem pro dosi."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 67515" do
      string = "iodum 2.5 mg ut povidonum iodinatum, isopropylis myristas, pentanum, propellentia: butanum, isobutanum, propanum, ad suspensionem pro 1 g."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 67540" do
      string = "aucklandiae radicis pulvis (Saussurea costus (Falc.) Lipsch., radix) 40 mg, lichenis islandici pulvis (Cetraria islandica (L.) Acharius s.l., thallus) 40 mg, azadirachtae indicae fructus pulvis (Azadirachta indica A.Juss., fructus) 35 mg, cardamomi fructus pulvis (Elettaria cardamomum (L.) Maton, fructus) 30 mg, myrobalani fructus pulvis (Terminalia chebula Retz., fructus) 30 mg, pimentae fructus pulvis (Pimenta dioica (L.) Merr., fructus) 25 mg, marmeli fructus pulvis (Aegle marmelos (L.) Corrêa, fructus) 20 mg, calcii sulfas hemihydricus 20 mg, aquilegiae vulgaris herbae pulvis (Aquilegia vulgaris L., herba) 15 mg, liquiritiae radicis pulvis (Glycyrrhiza glabra L. und/oder Glycyrrhiza inflata Bat. und/oder Glycyrrhiza uralensis Fisch., radix) 15 mg, plantaginis lanceolatae folii pulvis (Plantago lanceolata L. s.l., folium) 15 mg, polygoni avicularis herbae pulvis (Polygonum aviculare L. s.l., herba) 15 mg, potentillae aureae herbae pulvis (Potentilla aurea L., herba) 15 mg, caryophylli floris pulvis (Syzygium aromaticum (L.) Merr. & L.M.Perry, flos) 12 mg, kaempferiae galangae rhizomatis pulvis (Kaempferia galanga L., rhizoma) 10 mg, sidae cordifoliae herbae pulvis (Sida cordifolia L., herba) 10 mg, valerianae radicis pulvis (Valeriana officinalis L. s.l., radix) 10 mg, lactucae sativae folii pulvis (Lactuca sativa var. capitata L., folium) 6 mg, calendulae floris cum calyce pulvis (Calendula officinalis L., flos cum calyce) 5 mg, dextrocamphora 4 mg, tuberis aconiti pulvis (Aconitum napellus L., tuber) 1 mg, silica colloidalis anhydrica, mannitolum 0-0.7 mg, Kapselhülle: hypromellosum, pro capsula."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 67594" do
      string = "posaconazolum 200 mg, polysorbatum 80, xanthani gummi, natrii benzoas 10 mg, acidum citricum monohydricum, natrii citras dihydricus, glycerolum, glucosum liquidum 1.75 g, E 171, simeticonum, polysorbatum 65, methylcellulosum, macrogoli stearas, mono/diglycerida, E 200, E 210 0.045 mg, acidum sulfuricum, aromatica (Kirschen), alcohol benzylicus 0.0875 mg, aqua purificata ad suspensionem pro 5 ml corresp. natrium 3.4 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 67596" do
      string = "indacaterolum 150 µg ut indacateroli acetas, glycopyrronium 50 µg ut glycopyrronii bromidum, mometasoni-17 furoas 160 µg, lactosum monohydricum 24..567 mg, magnesii stearas, Kapselhülle: hypromellosum, carrageen, kalii chloridum, E 172 (flavum), E 132, aqua purificata, cera carnauba, Drucktinte: aqua purificata, E 172 (nigrum), alcohol isopropylicus, propylenglycolum, hypromellosum pro capsula."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 67641" do
      string = "mometasoni-17 furoas monohydricus 0.5173 mg, benzalkonii chloridum 0.20 mg, glycerolum, polysorbatum 80, cellulosum microcristallinum et carmellosum natricum, acidum citricum monohydricum, natrii citras anhydricus, aqua purificata ad suspensionem pro 1 g corresp. mometasoni-17 furoas 50 µg pro dosi, doses pro vase 140."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 67773" do
      string = "Filmtablette Morgendosis (elexacaftorum 100 mg / tezacaftorum 50 mg / ivacaftorum 75 mg): elexacaftorum 100 mg, tezacaftorum 50 mg, ivacaftorum 75 mg, hypromellosum, hypromellosi acetas succinas, natrii laurilsulfas, carmellosum natricum conexum, cellulosum microcristallinum, magnesii stearas, Überzug: hypromellosum, hydroxypropylcellulosum, E 171, talcum, E 172 (flavum), E 172 (rubrum) pro compresso obducto corresp. natrium 2.67 mg."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 67808" do
      string = "hederae folii extractum ethanolicum siccum (Hedera helix L., folium) 35.0 mg DER: 4-8:1 Auszugsmittel Ethanolum 30% m/m, E 202, xanthani gummi, maltitolum liquidum 3600.0 mg, acidum citricum, aromatica (Kirschenaroma), aromatica (Himbeeraroma), aqua purificata, ad solutionem pro 5 ml."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 68005" do
      string = "etonogestrelum 11.7 mg cum liberatione 0.12 mg/24h, ethinylestradiolum 2.7 mg cum liberatione 0.015 mg/24h, ethyleni et vinylis acetatis polymerisatum, magnesii stearas pro praeparatione."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 68087" do
      string = "haemagglutininum influenzae A (H1N1) (Virus-Stamm A/Guangdong-Maonan/SWL1536/2019 (H1N1)-pdm09: reassortant virus CNIC-1909 derived from A/Guangdong-Maonan/SWL1536/2019) 15 µg, haemagglutininum influenzae A (H3N2) (Virus-Stamm A/Hong Kong/2671/2019 (H3N2)-like: reassortant virus IVR-208 derived from A/Hong Kong/2671/2019) 15 µg, haemagglutininum influenzae B (Virus-Stamm B/Washington/02/2019 (Victoria lineage)) 15 µg, haemagglutininum influenzae B (Virus-Stamm B/Phuket/3073/2013 (Yamagata lineage)) 15 µg, kalii chloridum, kalii dihydrogenophosphas, dinatrii phosphas dihydricus, natrii chloridum, calcii chloridum dihydricum, magnesii chloridum hexahydricum, aqua ad iniectabilia q.s. ad suspensionem pro 0.5 ml corresp. natrium 2.0 mg, kalium 0.1 mg, residui: cetrimidum, formaldehydum, gentamicini sulfas, polysorbatum 80, ovalbuminum."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

  it "should handle isknr 68235" do
      string = "Suspension: Ad26.COV2-S 8,92 log10 infekt. Einheiten, hydroxypropylbetadexum, acidum citricum monohydricum, 1-(4-tolyl)-ethanolum, acidum hydrochloridum, polysorbatum 80, natrii chloridum, natrii hydroxidum, trinatrii citras dihydricus, aqua ad iniectabile, pro dosi."
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end

end
