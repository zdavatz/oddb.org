#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::TestPrescription -- oddb.org -- 06.08.2012 -- yasaka@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'

class TestJavaScript <Minitest::Test
  def test_simple_logging
    assert_equal("testing\n", `nodejs -e "console.log('testing');"`);
  end

  def test_prescription
    dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..','src', 'view', 'drugs'))
    
    ENV['NODE_PATH']=dir
    expected = 'http://2dmedication.org/|1.0|4dd33f59-1fbb-4fc9-96f1-488e7175d761|TriaMed|3.9.3.0|7601000092786|K2345.33||20131104|Beispiel|Susanne|3073|19460801|7601003000382;|2014236||1||0.00-0.00-0.00-0.00|||1|||SPEZIALVERBAND|1|20131214|0.00-0.00-0.00-0.00||40|0|7680456740106|||1||1.00-1.00-1.00-0.00|zu Beginn der Mahlzeiten mit mindestens einem halben Glas Wasser einzunehmen||0;27834'
    assert_equal(expected, `nodejs #{__FILE__.sub('.rb','.js')}`.chomp);
  end
end

