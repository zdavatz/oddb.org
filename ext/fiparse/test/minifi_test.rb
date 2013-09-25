#!/usr/bin/env ruby
# encoding: utf-8
# FiParse::TestMiniFi -- oddb.org -- 23.04.2007 -- hwyss@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'minifi'

module ODDB
  module FiParse
    class TestMiniFiHandler <Minitest::Test
      def setup
        @writer = MiniFi::Handler.new
      end
      def test_smj_02_2003
        eval(File.read(File.expand_path('data/smj_02_2003.rb',
                                        File.dirname(__FILE__))))
        assert_equal(2, @writer.minifis.size)
        expected = [
          "Ceprotin", "Spiriva",
        ] 
        assert_equal(expected, 
                     @writer.minifis.collect { |mini| mini[:name] })
        mini1, mini2 = @writer.minifis

        assert_equal "Erstzulassung eines neuen Wirkstoffs: Ceprotin\256", mini1[:de].heading
        assert_equal "Autorisation d\351livr\351e pour un nouveau principe actif: Ceprotin\256", mini1[:fr].heading
      end
      def test_smj_05_2003
        eval(File.read(File.expand_path('data/smj_05_2003.rb',
                                        File.dirname(__FILE__))))
        assert_equal(2, @writer.minifis.size)
        expected = [
          "Cetrotide", "Ospolot",
        ] 
        assert_equal(expected, 
                     @writer.minifis.collect { |mini| mini[:name] })
        mini1, mini2 = @writer.minifis

        assert_equal "Zulassung eines neuen Wirkstoffes: Cetrorelix (Cetrotide®)", mini1[:de].heading
        assert_equal <<-EOS.strip, mini1[:de].sections.first.to_s
Am 30. April 2003 wurde das Präparat Cetrotide®, Pulver und Lösungsmittel zur Herstellung einer Injektionslösung mit dem Wirkstoff Cetrorelix für folgende Indikation zugelassen:
        EOS
        assert_equal <<-EOS.strip, mini1[:de].sections.last.to_s
Cetrotide, soll nur von Spezialisten mit Erfahrung auf diesem Gebiet verordnet werden.
Cetrotide, wird als subkutane Injektion verabreicht, entweder als t\344gliche Injektion von 0.25 mg oder als Einmaldosis zu 3 mg (bei Bedarf evtl. gefolgt von t\344glichen Injektionen zu 0.25 mg). Eine Wiederholung der Behandlung mit Cetrotide\256 \374ber mehrere Zyklen wurde nicht untersucht.
Cetrotide ist kontraindiziert im Falle einer \334berempfindlichkeit gegen\374ber Cetrorelix, anderen strukturellen Gonadorelin-Analoga, exogenen Peptidhormonen oder einem der Hilfsstoffe gem\344ss Zusammensetzung (Mannitol) sowie bei Patientinnen mit eingeschr\344nkter Leber- oder Nierenfunktion. Bei Frauen mit Neigung zu schweren Allergien wird von einer Behandlung mit Cetrotide abgeraten.
Wie bei anderen Behandlungen zur ovariellen Stimulation mit Gonadotropinen kann ein ovarielles Hyperstimulationssyndrom auftreten. Lokale Reaktionen an der Injektionsstelle, anaphylaktische/pseudoallergische Reaktionen geh\366ren zu den weiteren unerw\374nschten Wirkungen.
        EOS
        assert_equal "Autorisation délivrée pour un nouveau principe actif: Cétrorélix (Cetrotide®)", mini1[:fr].heading
        assert_equal <<-EOS.strip, mini1[:fr].sections.first.to_s
La préparation Cetrotide®, poudre et solvant pour solution injectable, comportant comme principe actif le cétrorélix, a obtenu une autorisation de mise sur le marché le 30e avril 2003 pour l'indication suivante:
        EOS
        assert_equal <<-EOS.strip, mini1[:fr].sections.last.to_s
C\351tror\351lix est un antagoniste du facteur de lib\351ration de l'hormone lut\351inisante (LHRH). Le c\351tror\351lix entre en comp\351tition avec la LHRH endog\350ne au niveau des r\351cepteurs membranaires des cellules hypophysaires. La s\351cr\351tion des gonadotrophines (LH et FSH) peut ainsi \352tre contr\364l\351e.
La suppression de FSH et LH et la dur\351e d'action sont d\351pendantes de la dose. Chez la femme, le pic de LH est par cons\351quent retard\351, ce qui emp\352che une ovulation pr\351matur\351e survenant avant une maturation folliculaire suffisante. La suppression se produit presque imm\351diatement et sans effet stimulant initial, contrairement aux agonistes de la LHRH.
Cetrotide ne sera prescrit que par un sp\351cialiste de l'indication concern\351e.
Cetrotide est administr\351e en injection sous-cutan\351e, et est disponible soit pour une dose journali\350re de 0,25 mg soit pour une administration unique de 3 mg (\351ventuellement compl\351t\351es par la suite par des doses journali\350res de 0,25 mg).
Des administrations r\351p\351t\351es sur plusieurs cycles n'ont pas \351t\351 \351tudi\351es.
Cetrotide est contre-indiqu\351 en cas d'hypersensibilit\351 au c\351tror\351lix ou \340 tout autre analogue structural de la gonador\351line, aux hormones peptidiques exog\350nes ou aux excipients (mannitol), ainsi que chez les patientes pr\351sentant une insuffisance r\351nale ou h\351patique. Le traitement par Cetrotide n'est pas recommand\351 chez les femmes souffrant d'\351pisodes allergiques graves. Comme lors de tout processus de stimulation ovarienne par des gonadotrophines, un syndrome d'hyperstimulation ovarienne peut survenir. Des r\351actions au site d'injection et des r\351actions pseudo-allergiques / anaphylactiques ont \351galement \351t\351 observ\351es.
        EOS

        assert_equal "Zulassung eines neuen Wirkstoffes: Sultiam (Ospolot® Filmtabletten 50mg/200mg)", mini2[:de].heading
        assert_equal <<-EOS.strip, mini2[:de].sections.first.to_s
Am 15. Mai 2003 wurde das Präparat Ospolot® mit dem Wirkstoff Sultiam für folgende Indikation zugelassen: ḋRolando-Epilepsie (benigne Epilepsie des Kindesalters mit zentrotemporalen spikes). Hinweis: Bei der Indikationsstellung für den Einsatz von Sultiam sollte berücksichtigt werden, dass die Rolando-Epilepsie eine hohe Rate an Spontanremissionen aufweist und - auch ohne medikamentöse Behandlung - zumeist einen guten Verlauf und eine gute Prognose besitzt.Ṡ
        EOS
        assert_equal <<-EOS.strip, mini2[:de].sections.last.to_s
Bei der Verwendung von Ospolot ist zu beachten, dass die Dosierung individuell durch eine/n in der Epilepsiebehandlung erfahrene/n Neuropädiater/in festzulegen und zu kontrollieren ist.
Unter den in der Fachinformation umfassender dargestellten Kontraindikationen, Warnhinweisen und Vorsichtsmassnahmen ist die kontraindizierte Verwendung nicht nur in der Schwangerschaft, sondern auch bei allen Mädchen und Frauen im gebärfähigen Alter besonders hervorzuheben. Während der Behandlung sind insbesondere regelmässig Blutbild und Nierenfunktionsparameter zu kontrollieren. Häufige unerwünschte Wirkungen sind insbesondere zu Therapiebeginn u.a. (weitere und Deatils siehe FI) Tachypnoe (auf respiratorische Alkalose achten!) oder Dyspnoe, Nausea, Vomitus, Müdigkeit, Schwindel und Kopfschmerzen. Schwerwiegendere, aber wesentlich seltenere sind Neutropenie, Stevens-Johnson- oder Lyell-Syndrom.
Sultiam kann mit einigen anderen Arzneistoffen, insbesondere auch anderen Antikonvulsiva interagieren, wodurch es auch zu toxischen Erscheinungen kommen kann. Bei einigen Kombinationen, insbesondere mit Phenytoin müssen daher die Plasmaspiegel von Sultiam und /oder den damit zusammen verabreichten Arzneistoffen kontrolliert werden.
        EOS
        assert_equal "Autorisation délivrée pour un nouveau principe actif: Sultiame (Ospolot®) comprimés petticulés 50mg/200mg)", mini2[:fr].heading
        assert_equal <<-EOS.strip, mini2[:fr].sections.first.to_s
Le 15 mai 2003, Ospolot® (principe actif: sultiame) a été autorisé pour l'indication suivante: ḋEpilepsie à paroxysmes rolandiques (épilepsie bénigne de l'enfance avec pointes centro-temporales). Remarque: Si on envisage d'employer le sultiame, il faut tenir compte du fait que l'épilepsie à paroxysmes rolandiques présente un taux élevé de rémissions spontanées et a - même sans traitement médicamenteux - une évolution le plus souvent favorable et un bon pronostic.Ṡ
        EOS
        assert_equal <<-EOS.strip, mini2[:fr].sections.last.to_s
Mis à part un certain nombre d'investigations qui n'étaient pas tellement systématiques, l'efficacité clinique du sultiame dans l'épilepsie à paroxysmes rolandiques n'a été démontrée que dans une seule étude contrôlée de faible envergure - (31 patients âgés de 3 à 11 ans sous verum, 35 patients sous placebo) (Publication de cette étude: Rating D, Wolf C, Thomas B: Sulthiame as Monotherapy in Children with benign Childhood Epilepsy with Centrotemporal Spikes: A 6-Month Randomized, Double-Blind, Placebo-Controlled Study. In: Epilepsia 41 (10): 1284-1288, 2000). Durant le traitement de 6 mois, quatre crises ont été observées dans le groupe des enfants traités au sultiame contre 21 crises dans le groupe placebo, une différence statistiquement significative. Pour juger des résultats de cette étude, il faut tenir compte du fait que seuls ont été inclus dans l'étude des enfants sélectionnés pour des formes d'épilepsie à paroxysmes rolandiques à évolution relativement grave, ceci parce que, comme indiqué plus haut, l'épilepsie à paroxysmes rolandiques ne requiert souvent pas de traitement.
Pour utiliser Ospolot, il faut veiller à ce que la posologie soit fixée et contrôlée individuellement pour chaque patient par un neuropédiatre expérimenté dans le traitement de l'épilepsie.
Dans les contre-indications, mises en garde et mesures de précaution présentées de manière exhaustive dans l'information professionnelle, on relèvera tout particulièrement que son utilisation est contre-indiquée non seulement durant la grossesse, mais également pour toutes les jeunes filles et les femmes en âge de procréer. Au cours du traitement, il faut surtout contrôler régulièrement l'hémogramme et les paramètres de la fonction rénale.
Les effets indésirables fréquents, surtout en début de traitement, sont entre autres (l'information professionnelle les mentionne tous en détail): la tachypnée (attention à l'alcalose respiratoire!) ou la dyspnée, les nausées, les vomissements, la fatigue, les vertiges et les céphalées. Plus graves, mais nettement plus rares sont la neutropénie, le syndrome de Stevens-Johnson ou le syndrome de Lyell.
Le sultiame peut interagir avec quelques autres médicaments, en particulièrement d'autres anticonvulsifs, pouvant provoquer des phénomènes toxiques. Pour quelques associations, en particulier celles avec la phénytoïne, les taux plasmatiques du sultiame et/ou des médicaments co-prescrits doivent par conséquent être contrôlés.
        EOS
      end
      def test_smj_08_2003
        eval(File.read(File.expand_path('data/smj_08_2003.rb',
                                        File.dirname(__FILE__))))
        assert_equal(2, @writer.minifis.size)
        expected = [
          "Fabrazyme", "Forsteo",
        ] 
        assert_equal(expected, 
                     @writer.minifis.collect { |mini| mini[:name] })
        mini1, mini2 = @writer.minifis

        assert_equal "Zulassung eines Arzneimittels mit neuem Wirkstoff: Fabrazyme® (Agalsidase Beta)", mini1[:de].heading
        assert_equal <<-EOS.strip, mini1[:de].sections.first.to_s
Am 25. Juli 2003 wurde das Präparat Fabrazyme® mit dem Wirkstoff Agalsidase Beta für folgende Indikation zugelassen:
        EOS
        assert_equal <<-EOS.strip, mini1[:de].sections.last.to_s
Die klinischen Effekte wurden in einer placebo-kontrollierten Studie gezeigt. Histologische Untersuchungen ergaben, dass nach 20 Behandlungswochen mit Fabrazyme GL-3 aus dem vaskulären Endothel entfernt wurde. Diese GL-3-Clearance wurde bei 69% der mit Fabrazyme behandelten Patienten erreicht im Vergleich zu keinem der Patienten unter Placebo. Die Behandlung mit Fabrazyme muss durch einen Arzt mit Erfahrung in der Behandlung von Morbus Fabry oder anderen erblichen Stoffwechselkrankheiten überwacht werden. Die empfohlene Dosis beträgt 1 mg/kg Körpergewicht bei Anwendung einmal alle zwei Wochen als intravenöse Infusion. Weitere Details zur Dosierung können der Fachinformation entnommen werden.
Fabrazyme ist kontraindiziert bei lebensbedrohlicher Überempfindlichkeit gegenüber Agalsidase Beta. 83% der Patienten entwickelten in der klinischen Studie IgG-Antikörper gegen Agalsidase Beta. Patienten mit Antikörpern gegen Agalsidase Beta haben ein erhöhtes Risiko für Überempfindlichkeitsreaktionen. Patienten, bei denen während der Behandlung mit Fabrazyme im Rahmen von klinischen Studien Überempfindlichkeitsreaktionen auftraten, konnten nach Reduktion der Infusionsrate und einer Vorbehandlung mit Antihistaminika, Paracetamol, Ibuprofen und /oder Kortikosteroiden die Therapie weiterführen. Bei ungefähr der Hälfte der Patienten traten am Infusionstag Überempfindlichkeitsreaktionen auf. Dazu gehörten u.a. Fieber, Schüttelfrost, Engegefühl in der Hals- und Brustgegend, Rötung, Juckreiz und Bronchokonstriktion.
        EOS
        assert_equal "Autorisation délivrée pour un médicament avec un nouveau principe actif: Fabrazyme® (Agalsidase bêta)", mini1[:fr].heading
        assert_equal <<-EOS.strip, mini1[:fr].sections.first.to_s
Le 25 juilllet 2003, la préparation Fabrazyme®, avec pour principe actif la Agalsidase bêta, a été autorisée dans l'indication suivante:
        EOS
        assert_equal <<-EOS.strip, mini1[:fr].sections.last.to_s
Agalsidase bêta est produite par génie génétique à l'aide de cultures de cellules de mammifères (Chinese Hamster Ovary-, CHO-Zellen); la séquence des aminoacides de la forme recombinante, ainsi que la séquence nucléotidique qui l'a encodée sont identique à la forme naturelle de l'a-galactosidase. L'a-galactosidase est une hydrolase lysosomale, qui agit en tant que catalysateur de l'hydrolyse des glycosphingolipides, notamment le globotriaosylcéramide (GL-3) en galactose terminal et céramid dihexoside. L'activité réduite ou nulle de l'a-galactosidase entraîne une accumulation de GL-3 dans de nombreux types de cellules, dont les cellules endothéliales et parenchymateuses. L'objectif du traitement enzymatique substitutif par Fabrazyme® est de rétablir un niveau d'activité enzymatique suffisant pour hydroliser le substrat accumulé.
Lors d'un essai contrôlé contre placebo les effets cliniques de Fabrazyme® à éliminer GL-3 de l'endothélium vasculaire a été constaté par des analyses histologique après 20 semaines de traitement. Cette elimination de GL-3 a été observée chez 69% de patients traités par Fabrazyme®, mais chez aucun des patients recevant le placebo.
Le traitement par Fabrazyme® doit être supervisé par un médecin ayant l'experience de la prise en charge des patients atteints par la maladie de Fabry ou une autre maladie métabolique héréditaire. La dose recommandé est de 1 mg/kg de poids corporel, administrée une fois toutes les deux semaines par perfusion intraveneuse. Pour des plus amples informations concernant le dosage l'information professionnelle publiée doit être consultée.
Fabrazyme® est contre-indiqué chez les patients présentant une hypersensibilité à l'agalsidase bêta. Lors de l'essai clinique, 83% des patients ont développé des anticorps IgG contre l'agalsidase bêta. Les patients possédant des anticorps présentent un risque superieure de réactions d'hypersensibilité. Les patients ayant connu des réactions d'hypersensibilité lors du traitement par Fabrazyme® durant les essais cliniques ont poursuivi le traitement après réduction de la vitesse de perfusion et prétraitement par antihistaminiques, paracétamol, ibuprofène et/ou corticostéroïdes. Environ la moitié des patients ont ressenti des réactions d'hypersensibilité le jour de la perfusion. Les réactions les plus couremment rapportées ont été entre autres fièvre, frissons, sensation de constriction du pharynx, oppression thoracique, prurit, urticaire et constriction bronchique.
        EOS

        assert_equal "Zulassung eines Arzneimittels mit neuem Wirkstoff: Forsteo® (Teriparatid)", mini2[:de].heading
        assert_equal <<-EOS.strip, mini2[:de].sections.first.to_s
Am 8. August 2003 wurde das Präparat Forsteo® mit dem Wirkstoff Teriparatid für folgende Indikationen zugelassen:
        EOS
        assert_equal <<-EOS.strip, mini2[:de].sections.last.to_s
Forsteo erhöht die Calciumausscheidung im Urin. Es kam nicht zu relevanten Veränderungen der Nierenfunktion. Es liegen keine Erfahrungen vor bei Patienten mit schwerer Niereninsuffizienz, unter Dialyse oder nach Nierentransplantation.
Die meisten Nebenwirkungen in den klinischen Studien waren geringen Schweregrades und betrafen in erster Linie Nausea, Schwindel und Beinkrämpfe. Bei 2,8% der mit Forsteo behandelten Frauen wurden Antikörper nachgewiesen, die mit Teriparatid kreuzreagierten.
        EOS
        assert_equal "Autorisation délivrée pour un médicament avec un nouveau principe actif: Forsteo® (tériparatide)", mini2[:fr].heading
        assert_equal <<-EOS.strip, mini2[:fr].sections.first.to_s
Le 8 août 2003, la préparation Forsteo®, avec pour principe actif la tériparatide, a été autorisée dans les indications suivantes:
        EOS
        assert_equal <<-EOS.strip, mini2[:fr].sections.last.to_s
Forsteo augmente l'excrétion urinaire du calcium. Par contre, aucune modification significative de la fonction rénale n'a été observée. Enfin, aucune donnée n'est disponible pour les patients souffrant d'une insuffisance rénale sévère, sous dialyse ou ayant subi une transplantation rénale.
Les effets secondaires les plus fréquemment rapportés au cours des études cliniques étaient bénins. Il s'agissait principalement de nausées, de vertiges et de douleurs dans les membres inférieurs. On a enfin mis en évidence chez 2,8 % des femmes traitées par Forsteo des anticorps présentant une réaction croisée avec la tériparatide.
        EOS
      end
      def test_smj_12_2004
        eval(File.read(File.expand_path('data/smj_12_2004.rb',
                                        File.dirname(__FILE__))))
        assert_equal(5, @writer.minifis.size)
        expected = [
          "Avastin", "Emtriva", "Primovist", "Exanta", "Relestat",
        ] 
        assert_equal(expected, 
                     @writer.minifis.collect { |mini| mini[:name] })
        mini1, mini2, mini3, mini4, mini5 = @writer.minifis

        assert_equal "Zulassung des ersten Angiogenese Inhibitors gegen metastasiertes Karzinom des Kolons oder Rektums: Avastin\256 (Bevacizumab)", mini1[:de].heading
        assert_equal "Autorisation du premier inhibiteur de l'angiogenèse dans le traitement du cancer colo-rectal métastatique: Avastin® (bévacizumab)", mini1[:fr].heading

        assert_equal "Wirkmechanismus:\n", 
                     mini2[:de].sections.last.subheading

        paragraph = mini2[:fr].sections.last.paragraphs.first
        format = paragraph.formats.at(1)
        assert_equal(1, format.end - format.start, "symbol-explosion")
        format = paragraph.formats.at(2)
        assert_equal(false, format.symbol?)
        assert_equal(-1, format.end)

        assert_equal "Zulassung eines Arzneimittels mit einem neuen Wirkstoff: Relestat\256 (Epinastin), Augentropfen 0,5mg/ml", mini5[:de].heading
        assert_equal "Autorisation d'un médicament contenant un nouveau principe actif: Relestat® (épinastine), collyre 0,5mg/ml", mini5[:fr].heading
        assert_equal <<-EOS.strip, mini5[:fr].sections.last.to_s
Contre-indications et limitations d'utilisation:

Relestat® est contre-indiqué chez les patients présentant une hypersensibilité à ce produit. Cette préparation contient en outre du chlorure de benzalkonium, un agent conservateur susceptible de causer des effets indésirables (kératopathies) qui restent cependant rares. Enfin, il convient de tenir compte du fait que le benzalkonium peut s'accumuler dans les lentilles de contact (souples) hydrophiles.
        EOS
      end
      def test_smj_02_2007
        eval(File.read(File.expand_path('data/smj_02_2007.rb',
                                        File.dirname(__FILE__))))
        assert_equal(3, @writer.minifis.size)
        expected = [
          "Sprycel", "Thyrogen", "Forthyron, ad us. vet.", 
        ] 
        assert_equal(expected, 
                     @writer.minifis.collect { |mini| mini[:name] })
        mini1, mini2, mini3 = @writer.minifis

        assert_equal "Zulassung eines Arzneimittels mit neuem Wirkstoff: Sprycel, Filmtabletten (Dasatinib)", mini1[:de].heading
        assert_equal <<-EOS.strip, mini1[:de].sections.first.to_s
Am 2. Februar 2007 wurde Sprycel, Filmtabletten 20 mg, 50 mg und 70 mg (Dasatinib) im beschleunigten Zulassungsverfahren zugelassen.
        EOS
        assert_equal <<-EOS.strip, mini1[:de].sections.last.to_s
Kontraindikationen bzw. Warnhinweise und Vorsichtsmassnahmen, Interaktionen

Kontraindikationen sind Überempfindlichkeit gegenüber dem Wirkstoff oder einem der Hilfsstoffe, Schwangerschaft und Stillen.
Die häufigsten und dosislimitierenden unerwünschten Wirkungen von Dasatinib sind Neutropenie Grad 3/4 und Thrombozytopenie Grad 3/4.
Erfahrungen bei Patienten mit Knochenmarktransplantation nach Sprycel liegen bisher nicht vor.
Schwere gastrointestinale Hämorrhagien traten bei 5% der Patienten auf und erforderten im Allgemeinen ein Absetzen der Behandlung sowie Transfusionen.
Patienten unter Behandlung mit Thrombozytenaggregationshemmern oder Antikoagulantien wurden von der Teilnahme an klinischen Studien mit Sprycel ausgeschlossen. Dasatinib sollte nicht gleichzeitig mit anderen das Blutungsrisiko erhöhenden Arzneimitteln verabreicht werden.
Flüssigkeitsretention war bei 7% der Patienten schwer ausgeprägt und Pleura- und Perikardergüsse, Aszites, generalisierte Ödeme und Lungenödeme nicht-kardialer Genese wurden beobachtet. Bei Atemnot sollte eine unverzügliche Abklärung und angepasste Behandlung erfolgen.
Eine QT-Verlängerung wurde in klinischen Studien beobachtet. Vor Beginn der Behandlung sollte daher eine Abklärung durch ein Elektrokardiogramm erfolgen. Bei Patienten mit kongenitalem Long-QT-Syndrom oder bei gleichzeitiger Behandlung mit QT-verlängernden Arzneimitteln oder Antiarrhythmika sollte Dasatinib nur mit sehr grosser Vorsicht angewandt werden. Elektrolytstörungen wie Hypokaliämie oder Hypomagnesiämie sollten vorher korrigiert werden.
Patienten mit einer unkontrollierten oder relevanten Herzkreislauferkrankung wurden nicht in die klinischen Studien aufgenommen. Daher sollten diese Patienten mit Vorsicht behandelt werden.
Dasatinib ist ein Substrat von CYP 3A4 und PGP sowie ein Inhibitor von CYP 3A4 und CYP 2C8. Daher kann es bei Koadministration mit anderen Arzneimitteln, welche primär durch CYP 3A4 oder CYP 2C8 metabolisiert werden oder welche die Aktivität von CYP 3A4 und PGP beeinflussen, zu Interaktionen kommen.
Detaillierte Angaben sind der Arzneimittel-Fachinformation zu entnehmen.
        EOS
        assert_equal "Autorisation d'un médicament contenant un nouveau principe actif: Sprycel, comprimés filmés (dasatinib)", mini1[:fr].heading
        assert_equal <<-EOS.strip, mini1[:fr].sections.first.to_s
Le 2 février 2007, Sprycel, comprimés filmés 20 mg, 50 mg et 70 mg (dasatinib) a été autorisé au terme d'une procédure rapide d'autorisation.
        EOS
        assert_equal <<-EOS.strip, mini1[:fr].sections.last.to_s
Contre-indications, mises en garde et précautions, interactions

Les contre-indications sont l'hypersensibilité au principe actif ou à l'un des excipients, la grossesse et l'allaitement.
Les effets indésirables les plus fréquents du dasatinib et qui obligent à limiter la dose administrée sont la neutropénie de degré 3 ou 4 et la thrombocytopénie de degré 3 ou 4.
On ne dispose d'aucune expérience chez les patients ayant subi une transplantation de moelle osseuse après un traitement par Sprycel.
De graves hémorragies gastro-intestinales sont survenues chez 5 % des patients, qui ont nécessité en général la suspension du traitement et des transfusions.
Les patients traités avec des antiagrégants plaquettaires ou des anticoagulants ont été exclus des études cliniques conduites avec Sprycel. Le dasatinib ne doit pas être administré en même temps que d'autres médicaments qui augmentent le risque hémorragique.
Une rétention hydrique sévère a été observée chez 7 % des patients, incluant des épanchements pleuraux et péricardiaques, des ascites, des oedèmes généralisés et des oedèmes pulmonaires non cardiogéniques. En cas de dyspnée, il faut immédiatement effectuer un examen médical et administrer un traitement adapté.
Un allongement de l'intervalle QT a été observé lors des études cliniques. Il convient donc d'effectuer un électrocardiogramme avant de débuter le traitement. Par ailleurs, le dasatinib ne doit être administré qu'avec la plus grande précaution aux patients qui présentent un syndrome d'allongement congénital de l'intervalle QT ou qui sont traités par des médicaments antiarythmiques ou d'autres médicaments susceptibles d'entraîner un allongement de l'intervalle QT. Les éventuelles anomalies des électrolytes, telles que l'hypokaliémie ou l'hypomagnésémie, doivent être corrigées avant le début du traitement par dasatinib.
Les patients présentant des maladies cardiovasculaires incontrôlées ou significatives n'ont pas été inclus dans les études cliniques. Aussi convient-il de faire preuve de prudence avec ces patients.
Le dasatinib est un substrat du CYP 3A4 et de la PGP et un inhibiteur du CYP 3A4 et du CYP 2C8. Par conséquent, il existe un risque potentiel d'interaction avec les médicaments principalement métabolisés par le CYP 3A4 ou le CYP 2C8 ou qui influencent l'activité du CYP 3A4 et de la PGP.
Pour de plus amples informations, il convient de consulter l'information professionnelle sur le médicament.
        EOS

        assert_equal "Zulassung eines Arzneimittels mit neuem Wirkstoff: Thyrogen®, Pulver zur Herstellung einer Injektionslösung, 0.9 mg (Thyrotropin alfa)", mini2[:de].heading
        assert_equal <<-EOS.strip, mini2[:de].sections.first.to_s
Das Präparat Thyrogen® mit dem Wirkstoff Thyrotropin alfa wurde am 9. Februar 2007 für folgende Indikation zugelassen:
        EOS
        assert_equal <<-EOS.strip, mini2[:de].sections.last.to_s
Warnhinweise und Vorsichtsmassnahmen:

Thyrogen darf nicht intravenös verabreicht werden.
Für vollständige Informationen zum Präparat soll die Fachinformation konsultiert werden.
        EOS
        assert_equal "Autorisation d'un médicament contenant un nouveau principe actif: Thyrogen ®, poudre pour solution injectable, 0.9 mg (thyrotropine alfa)", mini2[:fr].heading
        assert_equal <<-EOS.strip, mini2[:fr].sections.first.to_s
La préparation Thyrogen® comportant le principe actif thyrotropine alfa a été autorisée le 9 février 2007 pour l'indication suivante:
        EOS
        assert_equal <<-EOS.strip, mini2[:fr].sections.last.to_s
Mises en garde et précautions:

Thyrogen ne doit pas être administré par voie intraveineuse.
Pour de plus amples informations, veuillez consulter l'information sur le médicament.
        EOS

        assert_equal "Zulassung eines Arzneimittels mit neuem Wirkstoff: Forthyron, ad us. vet., Tabletten (Levothyroxin)", mini3[:de].heading
        assert_equal(4, mini3[:de].sections.size)
        assert_equal <<-EOS.strip, mini3[:de].sections.first.to_s
Das Präparat Forthyron ad us.vet. wurde am 6. Februar 2007 als Tierarzneimittel für Hunde zugelassen.
        EOS
        assert_equal <<-EOS.strip, mini3[:de].sections.last.to_s
Das Präparat darf bei nicht korrigierter NNR-Insuffizienz nicht angewendet werden. Bei digitalisierten Hunden kann eine Anpassung der Digitalsidosis erforderlich sein. Bei Hunden mit Diabetis mellitus wird eine besonders sorgfältige Überwachung des Blutzuckerspiegels nötig.
        EOS
        assert_equal "Autorisation d'un médicament contenant un nouveau principe actif: Forthyron ad us.vét., comprimés (lévothyroxine)", mini3[:fr].heading
        assert_equal(4, mini3[:fr].sections.size)
        assert_equal <<-EOS.strip, mini3[:fr].sections.first.to_s
La préparation Forthyron ad us. vét. a été autorisée le 6 février 2007 en tant que médicament vétérinaire pour les chiens.
        EOS
        assert_equal <<-EOS.strip, mini3[:fr].sections.last.to_s
Ce médicament ne doit en revanche pas être administré en cas d'insuffisance cortico-surrénalienne. Chez les chiens digitalisés, une adaptation de la dose de digitaline peut par ailleurs s'avérer nécessaire. Enfin, chez les chiens souffrant de diabète sucré, une surveillance particulièrement étroite de la glycémie est impérative.
        EOS
      end
      def test_smj_03_2007
        eval(File.read(File.expand_path('data/smj_03_2007.rb',
                                        File.dirname(__FILE__))))
        assert_equal(5, @writer.minifis.size)
        expected = [
          "Acomplia", "Elaprase", "Procoralan", "Cortavance ad us. vet.",
          "Prac-tic ad us. vet.",
        ] 
        assert_equal(expected, 
                     @writer.minifis.collect { |mini| mini[:name] })

        mini1, mini2, mini3, mini4, mini5 = @writer.minifis
        assert_equal "Zulassung eines Arzneimittels mit neuem Wirkstoff: Acomplia®, Kapseln 20 mg (Rimonabant)", mini1[:de].heading
        assert_equal(12, mini1[:de].sections.size)
        assert_equal <<-EOS.strip, mini1[:de].sections.first.to_s
Am 15. März 2007 wurden Acomplia® Kapseln 20mg von Swissmedic für folgende Indikation zugelassen:
        EOS
        assert_equal <<-EOS.strip, mini1[:de].sections.last.to_s
Swissmedic hat das Nutzen-Risiko-Verhältnis von Acomplia® für die zugelassene Indikation als günstig beurteilt, unter der Voraussetzung, dass die in der Fachinformation erwähnten Warnhinweise und Vorsichtsmassnamen konsequent beachtet werden.
        EOS
        assert_equal "Autorisation d'un médicament contenant un nouveau principe actif: Acomplia®, gélules 20 mg (rimonabant)", mini1[:fr].heading
        assert_equal(10, mini1[:fr].sections.size)
        assert_equal <<-EOS.strip, mini1[:fr].sections.first.to_s
Le 15 mars 2007, la préparation Acomplia® gélules à 20 mg a été autorisée par Swissmedic dans l'indication suivante:
        EOS
        assert_equal <<-EOS.strip, mini1[:fr].sections.last.to_s
Swissmedic a estimé que le rapport bénéficerisque d'Acomplia® était favorable pour l'indication autorisée, à condition toutefois que les mises en garde et précautions mentionnées dans l'information professionnelle soient dûment prises en compte.
        EOS

        assert_equal "Zulassung eines Arzneimittels mit neuem Wirkstoff: Elaprase®, Injektionskonzentrat, 2 mg/ml (Idursulfase)", mini2[:de].heading
        assert_equal <<-EOS.strip, mini2[:de].sections.first.to_s
Das Präparat Elaprase® mit dem Wirkstoff Idursulfase wurde am 20. März 2007 für folgende Indikation zugelassen:
        EOS
        assert_equal <<-EOS.strip, mini2[:de].sections.last.to_s
Warnhinweise und Vorsichtsmassnahmen:

Mit Idursulfase behandelte Patienten können Reaktionen im Zusammenhang mit der Infusion entwickeln. Während der klinischen Studien waren die häufigsten Reaktionen im Zusammenhang mit der Infusion Hautreaktionen (Ausschlag, Pruritus, Urtikaria), Pyrexie, Kopfschmerzen, Hypertonie und Rötung.
Für vollständige Informationen zum Präparat soll die Fachinformation konsultiert werden.
        EOS
        assert_equal "Autorisation d'un médicament contenant un nouveau principe actif: Elaprase®, solution à diluer pour perfusion, 2 mg/ml (idursulfase)", mini2[:fr].heading
        assert_equal <<-EOS.strip, mini2[:fr].sections.first.to_s
La préparation Elaprase® comportant le principe actif idursulfase a été autorisée le 20 mars 2007 pour l'indication suivante:
        EOS
        assert_equal <<-EOS.strip, mini2[:fr].sections.last.to_s
Mises en garde et précautions:

Les patients traités par idursulfase sont susceptibles de développer des réactions associées à la perfusion. Au cours des études cliniques, les réactions associées à la perfusion les plus fréquemment observées comprenaient: réactions cutanées (éruption, prurit, urticaire), pyrexie, céphalées, hypertension et bouffées vasomotrices.
Pour de plus amples informations, veuillez consulter l'information sur le médicament.
        EOS

        assert_equal "Zulassung eines Arzneimittels mit neuem Wirkstoff: Procoralan, Filmtabletten zu 5mg bzw. 7.5mg (Ivabradin)", mini3[:de].heading
        assert_equal <<-EOS.strip, mini3[:de].sections.first.to_s
Das Präparat Procoralan mit dem Wirkstofff Ivabradin wurde am 19. März 2007 für folgende Indikation zugelassen:
        EOS
        assert_equal <<-EOS.strip, mini3[:de].sections.last.to_s
Eigenschaften/Wirkungen:

Ivabradin senkt aktivitätsabhängig die Herzfrequenz: Ivabradin hemmt den Herzfrequenzregulierenden If-Kanal an den Schrittmacherzellen am Sinusknoten des Herzens.
Für vollständige Informationen zum Präparat Procoralan soll die Fachinformation konsultiert werden.
        EOS
        assert_equal "Autorisation d'un médicament contenant un nouveau principe actif: Procoralan 5mg respectivement 7.5mg, comprimé pelliculé (ivabradine)", mini3[:fr].heading
        assert_equal <<-EOS.strip, mini3[:fr].sections.first.to_s
La préparation Procoralan contenant le principe actif ivabradine a été autorisée le 19 mars 2007 pour l'indication suivante:
        EOS
        assert_equal <<-EOS.strip, mini3[:fr].sections.last.to_s
Propriétés/effets:

L'ivabradine agit par inhibition sélective du courant pacemaker cardiaque If qui contrôle la dépolarisation diastolique spontanée au niveau du noeud sinusal et régule la fréquence cardiaque.
Pour des plus amples informations relatives à la préparation, veuillez consulter l'information professionnelle.
        EOS

        assert_equal "Zulassung eines Arzneimittels mit neuem Wirkstoff: Cortavance ad us. vet., (Hydrocortisonaceponat) Hautspray für Hunde", mini4[:de].heading

        assert_equal "Zulassung eines Arzneimittels mit neuem Wirkstoff: Prac-tic ad us. vet., Spot-on Lösung (Pyriprol); topisches Antiektoparasitikum gegen Zecken und Flöhe für Hunde", mini5[:de].heading
        assert_equal "Autorisation d'un médicament contenant un nouveau principe actif: Prac-tic ad us. vet., solution spot-on (pyriprole); ectoparasiticide à usage topique contre les tiques et les puces chez les chiens", mini5[:fr].heading
      end
      def test_smj_07_2007
        eval(File.read(File.expand_path('data/smj_07_2007.rb',
                                        File.dirname(__FILE__))))
        assert_equal(1, @writer.minifis.size)
        expected = [ "Umckaloabo", ] 
        assert_equal(expected, 
                     @writer.minifis.collect { |mini| mini[:name] })

        mini1, = @writer.minifis
        assert_equal "Zulassung eines pflanzlichen Arzneimittels mit neuem Wirstoff: Umckaloabo®, Lösung (Ethanolischer Flüssigextrakt aus den Wurzeln von Pelargonium sidoides)", mini1[:de].heading
        assert_equal "Autorisation d'un phytom\351dicament contenant un nouveau principe actif: Umckaloabo\256, solution (extrait \351thanolique liquide de racines de pelargonium sidoides)", mini1[:fr].heading
      end
      def test_smj_03_2008
        eval(File.read(File.expand_path('data/smj_03_2008.rb',
                                        File.dirname(__FILE__))))
        assert_equal(1, @writer.minifis.size)
        expected = [ "Theraflex MB Plasma", ] 
        assert_equal(expected, 
                     @writer.minifis.collect { |mini| mini[:name] })

        mini1, = @writer.minifis
        assert_equal "Zulassung von ,,Theraflex MB Plasma\", einem Methylenblau-Verfahren zur Inaktivierung von beh\374llten Viren in Plasma zur Transfusion unter der Zulassungsnummer 00706 (Zulassung eines Verfahrens nach Art. 19 VAM)", mini1[:de].heading
        assert_equal "Autorisation de \253Theraflex MB Plasma\273, un proc\351d\351 utilisant le bleu de m\351thyl\350ne pour l'inactivation de virus envelopp\351s pr\351sents dans le plasma destin\351 \340 la transfusion; n\260 d'autorisation 00706 (autorisation d'un proc\351d\351 selon l'art. 19 OM\351d)", mini1[:fr].heading
      end
    end
  end
end
