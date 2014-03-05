#!/usr/bin/env ruby
# encoding: utf-8
# FiParse::TestPatinfoHpricot -- oddb -- 09.04.2012 -- yasaka@ywesee.com
# FiParse::TestPatinfoHpricot -- oddb -- 17.08.2006 -- hwyss@ywesee.com

require 'hpricot'

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path('../../../src', File.dirname(__FILE__))
$: << File.expand_path('../../../test', File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'fachinfo_hpricot'
require 'fiparse'
require 'textinfo_pseudo_fachinfo'
require 'plugin/text_info'
require 'stub/cgi'
require 'flexmock'

module ODDB
  module FiParse
    class TestPseudoFachinfoDocument <Minitest::Test
      def test_fachinfo_simple
        @@path = File.expand_path('data/docx/simple.docx', File.dirname(__FILE__))
        @@writer = TextinfoPseudoFachinfo.new
        open(@@path) { |fh| @@fachinfo = @@writer.extract(fh)}
        assert_instance_of(PseudoFachinfoDocument, @@fachinfo)
        assert_equal('Sinovial® HighVisc 1,6%' , @@fachinfo.name)
        assert_equal(2, @@fachinfo.composition.paragraphs.size)
        assert_equal('Zusammensetzung', @@fachinfo.composition.heading.to_s)
        assert_equal('1 vorgefüllte 2,25 ml-Einweg-Fertigspritze aus Glas enthält: 32 mg Hyaluronsäure-Natriumsalz in 2 ml gepufferter physiologischer Lösung.', @@fachinfo.composition.paragraphs.first.to_s)
        assert_equal('Der Inhalt der Spritzen ist steril und pyrogenfrei.', @@fachinfo.composition.paragraphs[1].to_s)
        assert_equal('Stand der Information', @@fachinfo.date.heading.to_s)
        assert_equal('April 2010.', @@fachinfo.date.paragraphs.first.to_s)
        yaml =  @@fachinfo.to_yaml
        File.open(@@path.sub('.docx','.yaml'), 'w+') { |fi| fi.puts yaml }
        assert_equal(2, yaml.scan(/\sheading:/).size, 'Must find exactly 2 headings')
        assert_equal(2, yaml.scan(/\ssubheading:/).size, 'Must find exactly 2  subheading')
      end
      def test_fachinfo_sinovial_FR
        @@path = File.expand_path('data/docx/Sinovial_FR.docx', File.dirname(__FILE__))
        @@writer = TextinfoPseudoFachinfo.new
        open(@@path) { |fh| @@fachinfo = @@writer.extract(fh)}
        assert_instance_of(PseudoFachinfoDocument, @@fachinfo)
        assert(@@fachinfo.date)
        assert_equal('Sinovial® HighVisc 1,6%' , @@fachinfo.name)
        assert_equal( @@fachinfo.date.paragraphs.first.to_s, 'Avril 2010.')
        assert_equal('Douleurs ou limitations de la mobilité dues à des affections dégénératives, post-traumatiques ou à des altérations de l’articulation.', @@fachinfo.indications.paragraphs.first.to_s)
        ODDB::PseudoFachinfoDocument::CHAPTERS.each {
          |chapter|
            next if chapter == :unwanted_effects
            cmd ="assert(@@fachinfo.#{chapter.to_s} != nil, '@@fachinfo.#{chapter.to_s} may not be nil')"
            eval cmd
        }
        assert_equal(["7612291078458", "7612291078472"], @@fachinfo.iksnrs)
        assert_equal( 2, @@fachinfo.composition.paragraphs.size)
        assert_equal('7612291078458, seringue prête 2 ml', @@fachinfo.packages.paragraphs.first.to_s)
      end
      def test_fachinfo_sinovial_DE
        @@path = File.expand_path('data/docx/Sinovial_DE.docx', File.dirname(__FILE__))
        @@writer = TextinfoPseudoFachinfo.new
        open(@@path) { |fh| @@fachinfo = @@writer.extract(fh)}
        assert_instance_of(PseudoFachinfoDocument, @@fachinfo)
        assert_equal('Sinovial® HighVisc 1,6%' , @@fachinfo.name)
        assert_equal( @@fachinfo.date.paragraphs.first.to_s, 'April 2010.')
        assert_equal('Schmerzen oder eingeschränkte Beweglichkeit bei degenerativen oder traumatisch bedingten Erkrankungen oder Gelenksveränderungen.', @@fachinfo.indications.paragraphs.first.to_s)
        ODDB::PseudoFachinfoDocument::CHAPTERS.each {
          |chapter|
            next if chapter == :unwanted_effects
            cmd ="assert(@@fachinfo.#{chapter.to_s} != nil, '@@fachinfo.#{chapter.to_s} may not be nil')"
            eval cmd
        }
        assert_equal(["7612291078458", "7612291078472"], @@fachinfo.iksnrs)
        assert_equal( 2, @@fachinfo.composition.paragraphs.size)
        owner = 'IBSA Institut Biochimique SA, 6903 Lugano.'
        assert_equal( owner, @@fachinfo.distributor.paragraphs.first.text)
        assert_equal( owner, @@fachinfo.registration_owner)
      end
    end
  end
end
