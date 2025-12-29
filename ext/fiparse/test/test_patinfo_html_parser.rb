#!/usr/bin/env ruby

$: << File.expand_path("../src", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))
$: << File.expand_path("../../..", File.dirname(__FILE__))
$: << File.expand_path("../../../test", File.dirname(__FILE__))

begin require "debug"; rescue LoadError; end
require "stub/odba"
require "minitest/autorun"
require "flexmock/minitest"
require "patinfo_html_parser"
require "fiparse"
require "plugin/text_info"
require "util/workdir"
$: << File.expand_path("../../../test", File.dirname(__FILE__))
require "stub/cgi"

module ODDB
  module FiParse
    HTML_DIR = File.join(ODDB::PROJECT_ROOT, "ext/fiparse/test/data/html")
    class TestPatinfoHtmlParserCimifeminDe < Minitest::Test
      def setup
        return if defined?(@@path) and defined?(@@patinfo) and @@patinfo
        @@path = File.join(File.dirname(__FILE__), "data", "html", "de", "cimifemin.html")
        assert(File.exist?(@@path))
        @parser = ODDB::FiParse
        @@writer = PatinfoHtmlParser.new
        @@patinfo = FiParse.parse_patinfo_html(File.read(@@path))
      end

      def test_patinfo
        assert_instance_of(PatinfoDocument, @@patinfo)
        assert(!@@patinfo.instance_of?(PatinfoDocument2001))
      end

      def test_name1
        assert_equal("Cimifemin® uno Tabletten", @@patinfo.name.to_s)
      end

      def test_company1
        chapter = @@patinfo.company
        assert_instance_of(ODDB::Text::Chapter, chapter)
        assert_equal("Zulassungsinhaberin", chapter.heading)
        assert_equal(1, chapter.paragraphs.size)
        assert_equal("Zeller Medical AG, CH-8590 Romanshorn", chapter.paragraphs.first.text)
      end

      def test_amzv1
        assert(!@@patinfo.respond_to?(:amzv)) # as it is a PatinfoDocument and not PatinfoDocument2001
      end

      def test_effects1
        chapter = @@patinfo.effects
        assert_instance_of(ODDB::Text::Chapter, chapter)
        assert_equal("Was ist Cimifemin uno und wann wird es angewendet?",
          chapter.heading)
        assert_equal(1, chapter.sections.size)
        section = chapter.sections.first
        assert_equal("", section.subheading)
        assert_equal(2, section.paragraphs.size)
        paragraph = section.paragraphs.first
        expected = "Cimifemin uno enthält einen Trockenextrakt aus Cimicifugawurzelstock (Cimicifuga racemosa (L.) Nutt., rhizoma)."
        assert_equal(expected, paragraph.text)
      end

      def test_amendments1
        chapter = @@patinfo.amendments
        assert_instance_of(ODDB::Text::Chapter, chapter)
        assert_equal("Was sollte dazu beachtet werden?", chapter.heading)
        assert_equal(1, chapter.sections.size)
        section = chapter.sections.first
        assert_equal("", section.subheading)
        assert_equal(3, section.paragraphs.size)
        paragraph = section.paragraphs.at(0)
        expected = "Bei ungewöhnlichem Leistungsabfall, bei Gelbfärbung der Augen oder der Haut, bei dunklem Urin oder entfärbtem Stuhl sollte Cimifemin uno abgesetzt und ein Arzt bzw. eine Ärztin aufgesucht werden."
        assert_equal(expected, paragraph.text)
        paragraph = section.paragraphs.at(1)
        expected = "Bei Spannungs- und Schwellungsgefühl in den Brüsten sowie bei Zwischenblutungen, Schmierblutungen oder bei wiederkehrender Regelblutung sollten Sie Rücksprache mit Ihrem Arzt bzw. Ihrer Ärztin nehmen."
        assert_equal(expected, paragraph.text)
      end

      def test_contra_indications1
        chapter = @@patinfo.contra_indications
        assert_instance_of(ODDB::Text::Chapter, chapter)
        assert_equal("Wann darf Cimifemin uno nicht oder nur mit Vorsicht eingenommen / angewendet werden?",
          chapter.heading)
        assert_equal(1, chapter.sections.size)
        section = chapter.sections.first
        assert_equal("", section.subheading)
        assert_equal(7, section.paragraphs.size)
        paragraph = section.paragraphs.at(0)
        expected = /Cimifemin uno darf bei bekannter Überempfindlichkeit /
        assert_match(expected, paragraph.text)
        paragraph = section.paragraphs.at(1)
        expected = /Cimifemin uno enthält Lactose. Bitte nehmen Sie Cimifemin uno/
        assert_match(expected, paragraph.text)
        paragraph = section.paragraphs.at(2)
        expected = /Dieses Arzneimittel enthält weniger als 1 mmol Natrium/
        assert_match(expected, paragraph.text)
        paragraph = section.paragraphs.at(3)
        expected = /Informieren Sie Ihren Arzt, Apotheker oder Drogist/
        assert_match(expected, paragraph.text)
      end

      def test_usage1
        chapter = @@patinfo.usage
        assert_instance_of(ODDB::Text::Chapter, chapter)
        assert_equal("Wie verwenden Sie Cimifemin uno?", chapter.heading)
        assert_equal(1, chapter.sections.size)
        section = chapter.sections.first
        assert_equal("", section.subheading)
        assert_equal(3, section.paragraphs.size)
        paragraph = section.paragraphs.at(0)
        expected = /Erwachsene: Soweit nicht anders verschrieben/
        assert_match(expected, paragraph.text)
        paragraph = section.paragraphs.at(1)
        expected = /Die Anwendung und Sicherheit von Cimifemin uno bei Kindern /
        assert_match(expected, paragraph.text)
        paragraph = section.paragraphs.at(2)
        expected = /Halten Sie sich an die in der Packungsbeilage angegebene oder/
        assert_match(expected, paragraph.text)
      end

      def test_unwanted_effects1
        chapter = @@patinfo.unwanted_effects
        assert_instance_of(ODDB::Text::Chapter, chapter)
        assert_equal("Welche Nebenwirkungen kann Cimifemin uno haben?", chapter.heading)
        assert_equal(1, chapter.sections.size)
        section = chapter.sections.first
        assert_equal("", section.subheading)
        assert_equal(6, section.paragraphs.size)
        paragraph = section.paragraphs.at(0)
        expected = "Folgende Nebenwirkungen können bei der Einnahme von Cimifemin uno auftreten:"
        assert_equal(expected, paragraph.text)
        paragraph = section.paragraphs.at(1)
        expected = "·in seltenen Fällen Magenbeschwerden, Übelkeit, Sodbrennen und Durchfall."
        assert_equal(expected, paragraph.text)
        paragraph = section.paragraphs.at(2)
        expected = "·in einzelnen Fällen Brustspannen oder –schwellung, Schmier- und Zwischenblutungen oder das Wiederauftreten der Regelblutung."
        assert_equal(expected, paragraph.text)
      end

      def test_general_advice1
        chapter = @@patinfo.general_advice
        assert_instance_of(ODDB::Text::Chapter, chapter)
        assert_equal("Was ist ferner zu beachten?", chapter.heading)
        assert_equal(1, chapter.sections.size)
        section = chapter.sections.first
        assert_equal("", section.subheading)
        assert_equal(6, section.paragraphs.size)
        paragraph = section.paragraphs.at(0)
        expected = "Das Arzneimittel darf nur bis zu dem auf dem Behälter mit «EXP» bezeichneten Datum verwendet werden."
        assert_equal(expected, paragraph.text)
        paragraph = section.paragraphs.at(1)
        expected = "Lagerungshinweis"
        assert_equal(expected, paragraph.text)
        paragraph = section.paragraphs.at(2)
        expected = "Bei Raumtemperatur (15-25 °C) in der Originalverpackung aufbewahren."
        assert_equal(expected, paragraph.text)
      end

      def test_composition1
        chapter = @@patinfo.composition
        assert_instance_of(ODDB::Text::Chapter, chapter)
        assert_equal("Was ist in Cimifemin uno enthalten?", chapter.heading)
        assert_equal(1, chapter.sections.size)
        section = chapter.sections.first
        assert_equal("", section.subheading)
        assert_equal(5, section.paragraphs.size)
        paragraph = section.paragraphs.at(0)
        expected = /Extraktpartikel können in Form von kleinen braunen Punkten au/
        assert_match(expected, paragraph.text)
        paragraph = section.paragraphs.at(1)
        expected = "Wirkstoffe"
        assert_equal(expected, paragraph.text)
      end

      def test_iksnrs1
        chapter = @@patinfo.iksnrs
        assert_instance_of(ODDB::Text::Chapter, chapter)
        assert_equal("Zulassungsnummer", chapter.heading)
        assert_equal(1, chapter.sections.size)
        section = chapter.sections.first
        assert_equal(1, section.paragraphs.size)
        paragraph = section.paragraphs.first
        assert_equal("56933 (Swissmedic)", paragraph.to_s)
      end

      def test_packages1
        chapter = @@patinfo.packages
        assert_instance_of(ODDB::Text::Chapter, chapter)
        assert_equal("Wo erhalten Sie Cimifemin uno? Welche Packungen sind erhältlich?",
          chapter.heading)
        assert_equal(1, chapter.sections.size)
        section = chapter.sections.first
        assert_equal("", section.subheading)
        paragraph = section.paragraphs.at(0)
        expected = "In Apotheken und Drogerien, ohne ärztliche Verschreibung."
        assert_equal(expected, paragraph.text)
        assert_equal(2, section.paragraphs.size)
        paragraph = section.paragraphs.at(1)
        expected = "Blisterpackungen zu 30 und 90 Tabletten."
        assert_equal(expected, paragraph.text)
        assert_equal(1, paragraph.formats.size)
      end

      def test_distribution1
        chapter = @@patinfo.company
        assert_instance_of(ODDB::Text::Chapter, chapter)
        assert_equal("Zulassungsinhaberin", chapter.heading)
        assert_equal(1, chapter.sections.size)
        section = chapter.sections.first
        assert_equal("", section.subheading)
        assert_equal(1, section.paragraphs.size)
        paragraph = section.paragraphs.at(0)
        expected = "Zeller Medical AG, CH-8590 Romanshorn"
        assert_equal(expected, paragraph.text)
      end

      def test_date1
        chapter = @@patinfo.date
        assert_instance_of(ODDB::Text::Chapter, chapter)
        assert_equal("Diese Packungsbeilage wurde im Oktober 2020 letztmals durch die Arzneimittelbehörde (Swissmedic) geprüft.", chapter.heading)
      end
    end

    class TestPatinfoHtmlParserCimifeminFr < Minitest::Test
      def setup
        return if defined?(@@path) and defined?(@@patinfo) and @@patinfo

        @@path = File.join(HTML_DIR, "fr/cimifemin.html")
        @@writer = PatinfoHtmlParser.new
        File.open(@@path) { |fh|
          @@patinfo = @@writer.extract(Nokogiri(fh), :pi, fh.path)
        }
      end

      def test_name2
        assert_equal("Cimifemine®", @@patinfo.name.to_s)
      end

      def test_company2
        chapter = @@patinfo.company
        assert_instance_of(ODDB::Text::Chapter, chapter)
        assert_equal("ZELLER MEDICAL", chapter.heading)
      end

      def test_amzv2
        chapter = @@patinfo.amzv
        assert_instance_of(ODDB::Text::Chapter, chapter)
        assert_equal("OEMéd", chapter.heading)
        assert_equal(0, chapter.sections.size)
      end

      def test_composition2
        chapter = @@patinfo.composition
        assert_instance_of(ODDB::Text::Chapter, chapter)
        assert_equal("Que contient Cimifemine?", chapter.heading)
        assert_equal(1, chapter.sections.size)
        section = chapter.sections.first
        assert_equal("", section.subheading)
        assert_equal(2, section.paragraphs.size)
        paragraph = section.paragraphs.at(0)
        expected = "1 comprimé contient: 0,018–0,026 ml extrait liquide de rhizome "
        expected << "de Cimicifuga (actée à grappes), (RDE: 0,78–1,14:1), agent "
        expected << "d’extraction: isopropanol 40% (v/v)."
        assert_equal(expected, paragraph.text)
        paragraph = section.paragraphs.at(1)
        expected = "Cette préparation contient en outre des excipients."
        assert_equal(expected, paragraph.text)
      end
    end if false

    class TestPatinfoHtmlParserInderalDe < Minitest::Test
      def setup
        return if defined?(@@path) and defined?(@@patinfo) and @@patinfo

        @@path = File.join(HTML_DIR, "de/inderal.html")
        @@writer = PatinfoHtmlParser.new
        File.open(@@path) { |fh|
          @@patinfo = @@writer.extract(Nokogiri(fh), :pi)
        }
      end

      def test_galenic_form3
        assert_nil(@@patinfo.galenic_form)
      end

      def test_contra_indications3
        chapter = @@patinfo.contra_indications
        assert_instance_of(ODDB::Text::Chapter, chapter)
        assert_equal("Wann darf Inderal nicht angewendet werden?",
          chapter.heading)
        assert_equal(1, chapter.sections.size)
        section = chapter.sections.first
        assert_equal("", section.subheading)
        assert_equal(3, section.paragraphs.size)
      end

      def test_precautions3
        chapter = @@patinfo.precautions
        assert_instance_of(ODDB::Text::Chapter, chapter)
        assert_equal("Wann ist bei der Einnahme von Inderal Vorsicht geboten?",
          chapter.heading)
        assert_equal(1, chapter.sections.size)
        section = chapter.sections.first
        assert_equal("", section.subheading)
        assert_equal(12, section.paragraphs.size)
      end

      def test_pregnancy3
        chapter = @@patinfo.pregnancy
        assert_instance_of(ODDB::Text::Chapter, chapter)
        assert_equal("Darf Inderal während einer Schwangerschaft oder in der Stillzeit eingenommen werden?",
          chapter.heading)
        assert_equal(1, chapter.sections.size)
        section = chapter.sections.first
        assert_equal("", section.subheading)
        assert_equal(1, section.paragraphs.size)
      end
    end if false

    class TestPatinfoHtmlParserPonstanDe < Minitest::Test
      def setup
        @@path = File.join(HTML_DIR, "de/ponstan.html")
        @@writer = PatinfoHtmlParser.new
        File.open(@@path) { |fh|
          @@patinfo = @@writer.extract(Nokogiri(fh), :pi)
        }
      end

      def test_composition4
        chapter = @@patinfo.composition
        assert_instance_of(ODDB::Text::Chapter, chapter)
        assert_equal("Was ist in Ponstan enthalten?", chapter.heading)
        assert_equal(5, chapter.sections.size)
        section = chapter.sections.at(0)
        assert_equal("", section.subheading)
        assert_equal(1, section.paragraphs.size)
        paragraph = section.paragraphs.at(0)
        expected = "Wirkstoff: Mefenaminsäure."
        assert_equal(expected, paragraph.text)
        section = chapter.sections.at(1)
        assert_equal("Filmtabletten\n", section.subheading)
        assert_equal(1, section.paragraphs.size)
        paragraph = section.paragraphs.at(0)
        expected = "500 mg Mefenaminsäure sowie Vanillin (Aromaticum) und andere "
        expected << "Hilfsstoffe."
        assert_equal(expected, paragraph.text)
        section = chapter.sections.last
        assert_equal("Suspension\n", section.subheading)
        assert_equal(2, section.paragraphs.size)
        paragraph = section.paragraphs.at(0)
        expected = "5 ml enthalten 50 mg Mefenaminsäure, Konservierungsmittel: "
        expected << "Natriumbenzoat (E 211), Saccharin, Vanillin, Aromatica und "
        expected << "andere Hilfsstoffe."
        assert_equal(expected, paragraph.text)
        paragraph = section.paragraphs.at(1)
        expected = "5 ml enthalten 1 g Zucker (0,1 Brotwert)."
        assert_equal(expected, paragraph.text)
      end
    end if false

    class TestPatinfoHtmlParserNasivinDe < Minitest::Test
      StylesNasivin = "<style>p{margin-top:0pt;margin-right:0pt;margin-bottom:0pt;margin-left:0pt;}table{border-spacing:0pt;border-collapse:collapse;} table td{vertical-align:top;}.s2{font-size:11pt;font-weight:bold;}.s3{font-family:Arial;font-size:12pt;line-height:150%;}.s4{font-size:11pt;}.s5{font-family:Arial;font-size:11pt;line-height:150%;}.s6{font-weight:bold;}.s7{font-size:11pt;font-style:italic;}</style>"
      def setup
        return if defined?(@@path) and defined?(@@patinfo) and @@patinfo

        @@path = File.join(HTML_DIR, "de/nasivin.html")
        @@writer = PatinfoHtmlParser.new
        File.open(@@path) { |fh|
          @@patinfo = @@writer.extract(Nokogiri(fh), :pi, "Nasivin", StylesNasivin)
        }
        FileUtils.makedirs(ODDB::WORK_DIR)
        File.open(File.join(ODDB::WORK_DIR, File.basename(@@path.sub(".html", ".yaml"))), "w+") { |fi| fi.puts @@patinfo.to_yaml }
      end

      def test_composition5
        chapter = @@writer.effects
        assert_instance_of(ODDB::Text::Chapter, chapter)
        assert_equal("Was ist VICKS Nasivin und wann wird es angewendet?", chapter.heading)
        chapter = @@writer.date
        assert_instance_of(ODDB::Text::Chapter, chapter)
        assert_equal("Diese Packungsbeilage wurde im März 2007 letztmals durch die Arzneimittelbehörde (Swissmedic) geprüft.", chapter.to_s)
        chapter = @@writer.composition
        assert_instance_of(ODDB::Text::Chapter, chapter)
        assert_equal("Was ist in VICKS Nasivin enthalten?", chapter.heading)
        chapter = @@writer.packages
        assert_instance_of(ODDB::Text::Chapter, chapter)
        assert_equal("Wo erhalten Sie VICKS Nasivin? Welche Packungen sind erhältlich?", chapter.heading)
        section = chapter.sections.first
        paragraph = section.paragraphs.first
        assert_instance_of(ODDB::Text::Paragraph, paragraph)
        assert_equal("In Apotheken und Drogerien ohne ärztliche Verschreibung:",
          paragraph.text.lines.first.chomp)
      end
    end

    class TestPatinfoHtmlParserChapters < Minitest::Test
      def test_import_chapter
        testCases = [

          # Test cases for specific name with ',' or special signs
          ["7620", "Wann wird Notakehl Salbe angewendet?"],
          ["7620", "Wann wird Traumeel, Salbe angewendet?"],
          ["7680", "Wann darf Notakeh D3, Salbe nicht oder nur mit Vorsicht angewendet werden?"],
          ["7680", "Wann darf Notakehl® D3, Salbe nicht oder nur mit Vorsicht angewendet werden?"],
          [nil, "Information für Patientinnen und Patienten"],
          [nil, "Information destinée aux patients"],

          ["9010", "Name des Präparates"],
          ["9010", "Name des Präparates, Homöopathisches Arzneimittel (Homöopathisch-spagyrisches"],
          ["9010", "Arzneimittel)"],
          ["9010", "Name des Präparates, Anthroposophisches Arzneimittel"],
          ["9010", "Name des Präparates, Arzneimittel auf Grundlage anthroposophischer Erkenntnis"],
          ["9010", "Name des Präparates, Pflanzliches Arzneimittel"],
          ["9010", "Kurzcharakteristikum"],
          ["9010", "Homöopathisches Arzneimittel (Homöopathisch-spagyrisches Arzneimittel)"],
          ["9010", "Anthroposophisches Arzneimittel"],
          ["9010", "Arzneimittel auf Grundlage anthroposophischer Erkenntnis"],
          ["9010", "Pflanzliches Arzneimittel"],
          ["9010", "Nom de la préparation"],
          ["9010", "Nom de la préparation, Médicament homéopathique (médicamenthoméopathique-spagyrique)"],
          ["9010", "Nom de la préparation, Médicament anthroposophique"],
          ["9010", "Nom de la préparation, Médicament basé sur les connaissances anthroposophiques"],
          ["9010", "Nom de la préparation, Médicament phytothérapeutique"],
          ["9010", "Caractéristique à court"],
          ["9010", "Médicament homéopathique (médicament homéopathique-spagyrique)"],
          ["9010", "Médicament anthroposophique"],
          ["9010", "Médicament basé sur les connaissances anthroposophiques"],
          ["9010", "Médicament phytothérapeutique"],

          ["7620", "Was ist PLATZHALTER_MEDI und wann wird es angewendet?"],
          ["7620", "Was sind PLATZHALTER_MEDI und wann werden sie angewendet?"],
          ["7620", "Qu’est-ce que le PLATZHALTER_MEDI et quand doit-il être utilisé?"],
          ["7620", "Qu’est-ce que l' PLATZHALTER_MEDI et quand doit-il être utilisé?"],
          ["7620", "Qu’est-ce que la PLATZHALTER_MEDI et quand doit-elle être utilisée?"],
          ["7620", "Qu’est-ce que l' PLATZHALTER_MEDI et quand doit-elle être utilisée?"],
          ["7620", "Qu’est-ce que PLATZHALTER_MEDI et quand doit-il être utilisé?"],
          ["7620", "Qu’est-ce que PLATZHALTER_MEDI et quand doit-elle être utilisée?"],
          ["7620", "Qu’est-ce que les PLATZHALTER_MEDI et quand doivent-ils être utilisés?"],
          ["7620", "Qu’est-ce que les PLATZHALTER_MEDI et quand doivent-elles être utilisées?"],
          ["7620", "Qu’est-ce que PLATZHALTER_MEDI et quand doivent-ils être utilisés?"],
          ["7620", "Qu’est-ce que PLATZHALTER_MEDI et quand doivent-elles être utilisées?"],

          ["7620", "Wann wird PLATZHALTER_MEDI angewendet?"],
          ["7620", "Wann werden PLATZHALTER_MEDI angewendet?"],
          ["7620", "Quand PLATZHALTER_MEDI est-il utilisé?"],
          ["7620", "Quand PLATZHALTER_MEDI est-elle utilisée?"],
          ["7620", "Quand PLATZHALTER_MEDI sont-ils utilisés?"],
          ["7620", "Quand PLATZHALTER_MEDI sont-elles utilisées?"],
          ["7620", "Qu’est-ce que le PLATZHALTER_MEDI et quand est-il utilisé?"],
          ["7620", "Qu’est-ce que l' PLATZHALTER_MEDI et quand est-il utilisé?"],
          ["7620", "Qu’est-ce que PLATZHALTER_MEDI et quand est-il utilisé?"],
          ["7620", "Qu’est-ce que la PLATZHALTER_MEDI et quand est-elle utilisée?"],
          ["7620", "Qu’est-ce que l' PLATZHALTER_MEDI et quand est-elle utilisée?"],
          ["7620", "Qu’est-ce que PLATZHALTER_MEDI et quand est-elle utilisée?"],
          ["7620", "Qu’est-ce que les PLATZHALTER_MEDI et quand sont-ils utilisés?"],
          ["7620", "Qu’est-ce que les PLATZHALTER_MEDI et quand sont-elles utilisées?"],
          ["7620", "Qu’est-ce que PLATZHALTER_MEDI et quand sont-ils utilisés?"],
          ["7620", "Qu’est-ce que PLATZHALTER_MEDI et quand sont-elles utilisées?"],

          ["7640", "Was sollte dazu beachtet werden?"],
          ["7640", "De quoi faut-il tenir compte en dehors du traitement?"],

          ["7680", "Wann darf PLATZHALTER_MEDI nicht eingenommen/angewendet werden?"],
          ["7680", "Wann darf PLATZHALTER_MEDI nicht eingenommen werden?"],
          ["7680", "Wann darf PLATZHALTER_MEDI nicht angewendet werden?"],
          ["7680", "Quand PLATZHALTER_MEDI ne doit-il pas être pris/utilisé?"],
          ["7680", "Quand PLATZHALTER_MEDI ne doit-elle pas être prise/utilisée?"],
          ["7680", "Quand PLATZHALTER_MEDI ne doit-il pas être pris?"],
          ["7680", "Quand PLATZHALTER_MEDI ne doit-il pas être utilisé?"],
          ["7680", "Quand PLATZHALTER_MEDI ne doit-elle pas être prise?"],
          ["7680", "Quand PLATZHALTER_MEDI ne doit-elle pas être utilisée?"],
          ["7680", "Wann dürfen PLATZHALTER_MEDI nicht eingenommen/angewendet werden?"],
          ["7680", "Wann dürfen PLATZHALTER_MEDI nicht eingenommen werden?"],
          ["7680", "Wann dürfen PLATZHALTER_MEDI nicht angewendet werden?"],
          ["7680", "Wann darf PLATZHALTER_MEDI nicht oder nur mit Vorsicht eingenommen/angewendet werden?"],
          ["7680", "Wann darf PLATZHALTER_MEDI nicht oder nur mit Vorsicht eingenommen werden?"],
          ["7680", "Wann darf PLATZHALTER_MEDI nicht oder nur mit Vorsicht angewendet werden?"],
          ["7680", "Wann dürfen PLATZHALTER_MEDI nicht oder nur mit Vorsicht eingenommen/angewendet werden?"],
          ["7680", "Wann dürfen PLATZHALTER_MEDI nicht oder nur mit Vorsicht eingenommen werden?"],
          ["7680", "Wann dürfen PLATZHALTER_MEDI nicht oder nur mit Vorsicht angewendet werden?"],
          ["7680", "Quand PLATZHALTER_MEDI ne doivent-ils pas être pris/utilisés?"],
          ["7680", "Quand PLATZHALTER_MEDI ne doivent-elles pas être prises/utilisées?"],
          ["7680", "Quand PLATZHALTER_MEDI ne doivent-ils pas être pris?"],
          ["7680", "Quand PLATZHALTER_MEDI ne doivent-elles pas être prises?"],
          ["7680", "Quand PLATZHALTER_MEDI ne doivent-ils pas être utilisés?"],
          ["7680", "Quand PLATZHALTER_MEDI ne doivent-elles pas être utilisées?"],
          ["7680", "Quand PLATZHALTER_MEDI ne doit-il pas être pris/utilisé ou seulement avprécaution?"],
          ["7680", "Quand PLATZHALTER_MEDI ne doit-elle pas être prise/utilisée ou seulement avec précaution?"],
          ["7680", "Quand PLATZHALTER_MEDI ne doit-il pas être pris ou seulement avec précautio?"],
          ["7680", "Quand PLATZHALTER_MEDI ne doit-elle pas être prise ou seulement avec précaution?"],
          ["7680", "Quand PLATZHALTER_MEDI ne doit-elle pas être utilisée ou seulement avec précaution?"],
          ["7680", "Quand PLATZHALTER_MEDI ne doivent-ils pas être pris/utilisés ou seulement aveprécaution?"],
          ["7680", "Quand PLATZHALTER_MEDI ne doivent-elles pas être prises/utilisées ou seulemenavec précaution?"],
          ["7680", "Quand PLATZHALTER_MEDI ne doivent-ils pas être pris ou seulement avec précaution?"],
          ["7680", "Quand PLATZHALTER_MEDI ne doivent-elles pas être prises ou seulement avec précaution?"],
          ["7680", "Quand PLATZHALTER_MEDI ne doivent-ils pas être utilisés ou seulement avec précaution?"],
          ["7680", "Quand PLATZHALTER_MEDI ne doivent-elles pas être utilisées ou seulement avec précaution?"],

          ["7700", "Wann ist bei der Einnahme/Anwendung von PLATZHALTER_MEDI Vorsicht geboten?"],
          ["7700", "Wann ist bei der Einnahme von PLATZHALTER_MEDI Vorsicht geboten?"],
          ["7700", "Wann ist bei der Anwendung von PLATZHALTER_MEDI Vorsicht geboten?"],
          ["7700", "Quelles sont les précautions à observer lors de la prise/de l’utilisation de PLATZHALTER_MEDI?"],
          ["7700", "Quelles sont les précautions à observer lors de la prise de PLATZHALTER_MEDI?"],
          ["7700", "Quelles sont les précautions à observer lors de l’utilisation de PLATZHALTER_MEDI?"],

          ["7720", "Darf PLATZHALTER_MEDI während einer Schwangerschaft oder in der Stillzeit eingenommen/angewendet werden?"],
          ["7720", "Darf PLATZHALTER_MEDI während einer Schwangerschaft oder in der Stillzeit eingenommen werden?"],
          ["7720", "Darf PLATZHALTER_MEDI während einer Schwangerschaft oder in der Stillzeit angewendet werden?"],
          ["7720", "Dürfen PLATZHALTER_MEDI während einer Schwangerschaft oder in der Stillzeit eingenommen/angewendet werden?"],
          ["7720", "Dürfen PLATZHALTER_MEDI während einer Schwangerschaft oder in der Stillzeit eingenommen werden?"],
          ["7720", "Dürfen PLATZHALTER_MEDI während einer Schwangerschaft oder in der Stillzeit angewendet werden?"],
          ["7720", "PLATZHALTER_MEDI peut-il être pris/utilisé pendant la grossesse ou l’allaitement?"],
          ["7720", "PLATZHALTER_MEDI peut-elle être prise/utilisée pendant la grossesse ou l’allaitement?"],
          ["7720", "PLATZHALTER_MEDI peut-il être pris pendant la grossesse ou l’allaitement?"],
          ["7720", "PLATZHALTER_MEDI peut-elle être prise pendant la grossesse ou l’allaitement?"],
          ["7720", "PLATZHALTER_MEDI peut-il être utilisé pendant la grossesse ou l’allaitement?"],
          ["7720", "PLATZHALTER_MEDI peut-elle être utilisée pendant la grossesse ou l’allaitement?"],
          ["7720", "PLATZHALTER_MEDI peuvent-ils être pris/utilisés pendant la grossesse ou l’allaitement?"],
          ["7720", "PLATZHALTER_MEDI peuvent-elles être prises/utilisées pendant la grossesse ou l’allaitement?"],
          ["7720", "PLATZHALTER_MEDI peuvent-ils être pris pendant la grossesse ou l’allaitement?"],
          ["7720", "PLATZHALTER_MEDI peuvent-elles être prises pendant la grossesse ou l’allaitement?"],
          ["7720", "PLATZHALTER_MEDI peuvent-ils être utilisés pendant la grossesse ou l’allaitement?"],
          ["7720", " PLATZHALTER_MEDI peuvent-elles être utilisées pendant la grossesse ou l’allaitement?"],

          ["7740", "Wie verwenden Sie PLATZHALTER_MEDI?"],
          ["7740", "Comment utiliser PLATZHALTER_MEDI?"],

          ["7760", "Welche Nebenwirkungen kann PLATZHALTER_MEDI haben?"],
          ["7760", "Welche Nebenwirkungen können PLATZHALTER_MEDI haben?"],
          ["7760", "Quels effets secondaires PLATZHALTER_MEDI peut-il provoquer?"],
          ["7760", "Quels effets secondaires PLATZHALTER_MEDI peut-elle provoquer?"],
          ["7760", "Quels effets secondaires PLATZHALTER_MEDI peuvent-ils provoquer?"],
          ["7760", "Quels effets secondaires PLATZHALTER_MEDI peuvent-elles provoquer?"],

          ["7780", "Was ist ferner zu beachten?"],
          ["7780", "A quoi faut-il encore faire attention?"],
          ["7780", "À quoi faut-il encore faire attention?"],

          ["7840", "Was ist in PLATZHALTER_MEDI enthalten?"],
          ["7840", "Que contient PLATZHALTER_MEDI?"],

          ["7860", "Zulassungsnummer"],
          ["7860", "Numéro d’autorisation"],

          ["7880", "Wo erhalten Sie PLATZHALTER_MEDI? Welche Packungen sind erhältlich?"],
          ["7880", "Que contiennent PLATZHALTER_MEDI?"],
          ["7880", "Où obtenez-vous PLATZHALTER_MEDI? Quels sont les emballages à disposition sur le marché?"],

          ["9000", "Zulassungsinhaberin"],
          ["9000", "Titulaire de l’autorisation"],

          ["7920", "Herstellerin"],
          ["7920", "Fabricant"],

          ["7940", "Diese Packungsbeilage wurde im PLATZHALTER_MEDI (Monat/Jahr) letztmals durch die Arzneimittelbehörde (Swissmedic) geprüft."],
          ["7940", "Cette notice d’emballage a été vérifiée pour la dernière foisen PLATZHALTER_MEDI (mois/année) par l’autorité de contrôle des médicaments (Swissmedic)."]
        ]

        nrFailures = 0
        testCases.each { |tc|
          unless tc == res = ODDB::FiParse::PatinfoHtmlParser.text_to_chapter(tc[1])
            $stdout.puts "Parsing chapter #{tc[1]} failed, returned #{res[0]} != #{tc[0]}"
            nrFailures += 1
          end
        }
        assert_equal nrFailures, 0
      end
    end

    class TestPatinfoHtmlParser_30785_PonstanDe < Minitest::Test
      CourierStyle = '<SPAN style="padding-bottom: 4px; white-space: normal; line-height: 1.4em;">'
      StylesPonstan = "p{margin-top:0pt;margin-right:0pt;margin-bottom:0pt;margin-left:0pt;}table{border-spacing:0pt;border-collapse:collapse;} table td{vertical-align:top;}.s2{font-family:Arial;font-size:16pt;font-weight:bold;}.s3{line-height:115%;text-align:justify;}.s4{font-family:Arial;font-size:11pt;font-style:italic;font-weight:bold;}.s5{line-height:115%;text-align:right;margin-top:18pt;padding-top:2pt;padding-bottom:2pt;border-top-width:0.5pt;border-top-color:#000000;border-top-style:solid;border-bottom-width:0.5pt;border-bottom-color:#000000;border-bottom-style:solid;}.s6{font-family:Arial;font-size:12pt;font-style:italic;font-weight:bold;}.s7{line-height:115%;text-align:justify;margin-top:8pt;}.s8{font-family:Arial;font-size:11pt;}.s9{line-height:115%;text-align:justify;margin-top:2pt;}.s10{line-height:115%;text-align:justify;margin-top:6pt;}.s11{font-family:Arial;font-size:11pt;font-style:italic;}.s12{font-family:Courier New;font-size:11pt;}.s13{line-height:115%;text-align:left;}.s14{height:6pt;}.s15{font-family:Courier;margin-left:0pt;padding-top:2.25pt;padding-right:2.25pt;padding-bottom:3.75pt;padding-left:3.75pt;border-top-width:0.5pt;border-top-color:#000000;border-top-style:solid;}.s16{font-family:Courier;margin-left:0pt;padding-top:2.25pt;padding-right:2.25pt;padding-bottom:3.75pt;padding-left:3.75pt;}.s17{font-family:Courier;margin-left:0pt;padding-top:2.25pt;padding-right:2.25pt;padding-bottom:3.75pt;padding-left:3.75pt;border-bottom-width:0.5pt;border-bottom-color:#000000;border-bottom-style:solid;}.s18{font-family:Courier;margin-top:2pt;margin-left:-5.4pt;padding-top:0pt;padding-right:5.4pt;padding-bottom:0pt;padding-left:5.4pt;}.s19{font-family:Arial;font-size:11pt;font-weight:bold;}"
      def setup
        return if defined?(@@path) and defined?(@@patinfo) and @@patinfo

        @@path = File.join(HTML_DIR, "de/pi_30785_ponstan.html")
        @@writer = PatinfoHtmlParser.new
        File.open(@@path) { |fh|
          @@patinfo = @@writer.extract(Nokogiri(fh), :pi, "Ponstan", StylesPonstan)
        }
        FileUtils.makedirs(ODDB::WORK_DIR)
        File.open(File.join(ODDB::WORK_DIR, File.basename(@@path.sub(".html", ".yaml"))), "w+") { |fi| fi.puts @@patinfo.to_yaml }
      end

      def test_all_to_html
        @lookandfeel = FlexMock.new "lookandfeel"
        @lookandfeel.should_receive(:section_style).and_return { "section_style" }
        @session = FlexMock.new "@session"
        @session.should_receive(:lookandfeel).and_return { @lookandfeel }
        @session.should_receive(:user_input)
        assert(@session.respond_to?(:lookandfeel))
        @view = View::Chapter.new(:name, nil, @session)
        @view.value = @@patinfo.usage
        result = @view.to_html(CGI.new)
        sleep(0.5)
        unless @@patinfo.usage
          msg = "Niklaus does not know why we have here sometimes a nil value"
          warn("\n#{msg}")
          skip(msg)
        end
        assert_equal("Wie verwenden Sie Ponstan?", @@patinfo.usage.heading)
        unless @@patinfo.usage.paragraphs.size > 8
          msg = "Niklaus does not know why we have here sometimes only 8 lines"
          warn("\n#{msg}")
          skip(msg)
        end
        expected = [/Wie verwenden Sie Ponstan\?/, # heading
          /Alter    Suspension     Kapseln      Zäpfchen/,
          />Alter    Suspension     Kapseln      Zäpfchen/,
          /#{CourierStyle}Alter    Suspension     Kapseln      Zäpfchen/o]
        File.open(File.join(ODDB::WORK_DIR, File.basename(@@path)), "w+") { |x|
          x.puts("<HTML><BODY>")
          x.write(result)
          x.puts("</HTML></BODY>")
        }

        expected.each { |pattern|
          assert(pattern.match(result), "Missing pattern:\n#{pattern}\nin:\n#{result}")
        }
        puts "Sometimes we pass this test. Try at least ten times"
      end
    end if false
  end
end
