#!/usr/bin/env ruby
# encoding: utf-8
require 'spec_helper'
require 'paypal_helper'

@workThread = nil

describe "ch.oddb.org" do

  before :all do
    @idx = 0
    setup_browser
  end

  before :each do
  end

  after :each do
    @idx += 1
  end
DOMAINS= [
'ch.oddb.org',
'anthroposophika.ch',
'anthroposophika.oddb.org',
'anthroposophy.oddb.org',
'desitin.ch.oddb.org',
'desitin.oddb.org',
'epilepsie-therapie.ch',
'generika.cc',
'generika.oddb.org',
'homeopathy.oddb.org',
'homoeopathika.oddb.org',
'i.ch.oddb.org',
'i.oddb.org',
'just-medical.oddb.org',
'mobile.ch.oddb.org',
'mobile.oddb.org',
'nachahmer.ch',
'new.ch.oddb.org',
'oddb.org',
'oekk.oddb.org',
'phyto-pharma.ch',
'phyto-pharma.oddb.org',
'phytotherapeutika.ch',
'ramaze.ch.oddb.org',
'santesuisse.oddb.org',
'www.anthroposophica.ch',
'www.anthroposophika.ch',
'www.ch.oddb.org',
'www.oddb.org',
'www.phyto-pharma.ch',
'www.phytotherapeutika.ch',
'www.xn--homopathika-tfb.ch',
'xn--homopathika-tfb.ch',
'xn--homopathika-tfb.oddb.org',
  ]
DOMAINS_TO_BE_ADDED = [
'webalizer.anthroposophika.ch',
'webalizer.anthroposophika.oddb.org',
'webalizer.ch.oddb.org',
'webalizer.desitin.ch.oddb.org',
'webalizer.generika.cc',
'webalizer.generika.oddb.org',
'webalizer.homoeopathika.oddb.org',
'webalizer.i.ch.oddb.org',
'webalizer.i.mobile.oddb.org',
'webalizer.i.oddb.org',
'webalizer.just-medical.oddb.org',
'webalizer.mobile.oddb.org',
'webalizer.oddb.org',
'webalizer.oekk.oddb.org',
'webalizer.phyto-pharma.ch',
'webalizer.phyto-pharma.oddb.org',
'webalizer.phytotherapeutika.ch',
'webalizer.santesuisse.oddb.org',
  ]
  DOMAINS.each do |domain|
    url = "https://#{domain}"
    it "should workd with #{url}" do
      @browser.goto(url)
      expect(@browser.text_field(:name, "search_query").exist?).to eql true
    end
  end
  after :all do
    @browser.close if @browser
  end
end
