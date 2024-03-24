#!/usr/bin/env ruby
# encoding: utf-8
require 'spec_helper'
require 'paypal_helper'

@workThread = nil

describe "ch.oddb.org" do

  before :all do
    @idx = 0
    setup_browser
    unless @browser.name.eql?(:chrome)
      fail "This test works only with the chrome browser!"
    end
  end

  before :each do
  end

  after :each do
    @idx += 1
  end
DOMAINS= [
'anthroposophika.ch',
'ch.oddb.org',
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
  DOMAINS.each do |domain|
    url = "https://#{domain}"
    it "should work with #{url}" do
      pending "https://github.com/zdavatz/oddb.org/issues/267: Zur Zeit werden die nicht vermarktet, die werden nur weitergeleitet."
      unless is_link_valid?(url)
        fail "URL #{url} does not respond"
      end
      @browser.goto(url)
      if  @browser.text.match(/ERR_CERT_COMMON_NAME_INVALID/)
        @browser.button(text: /Erweitert/).click
        m = @browser.text.match(/Sein Sicherheitszertifikat stammt von (.+ )/)
        host = m[1].match(/[^ ]+/)[0]
        fail "URL #{url} does not have a correct certificate. It comes from #{host}"
      end
      expect(@browser.text_field(name: "search_query").exist?).to eql true
    end unless /oddb-ci/.match(Socket.gethostname)
  end
  after :all do
    @browser.close if @browser
  end
end if ARGV.first.index(File.basename(__FILE__))
