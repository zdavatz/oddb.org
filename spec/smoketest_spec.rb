#!/usr/bin/env ruby

require "spec_helper"
require "paypal_helper"
@workThread = nil

# found via  @browser.links.collect{|x| x.href if x.visible?}.find_all{|x| x.size > 0}
LINKS_2_CHECK = [
  "#{ODDB_URL}/de/gcc/atc_chooser/",
  "#{ODDB_URL}/de/gcc/home/",
  "#{ODDB_URL}/de/gcc/home_companies/",
  "#{ODDB_URL}/de/gcc/home_doctors/",
  "#{ODDB_URL}/de/gcc/home_hospitals/",
  "#{ODDB_URL}/de/gcc/home_interactions/",
  "#{ODDB_URL}/de/gcc/home_migel/",
  "#{ODDB_URL}/de/gcc/home_pharmacies/",
  "#{ODDB_URL}/de/gcc/home_user/",
  "#{ODDB_URL}/de/gcc/limitation_texts/",
  "#{ODDB_URL}/de/gcc/logout/",
  "#{ODDB_URL}/de/gcc/narcotics/",
  "#{ODDB_URL}/de/gcc/preferences/",
  "#{ODDB_URL}/de/gcc/recent_registrations/",
  "#{ODDB_URL}/de/gcc/rss/channel/feedback.rss",
  "#{ODDB_URL}/de/gcc/rss/channel/hpc.rss",
  "#{ODDB_URL}/de/gcc/rss/channel/price_cut.rss",
  "#{ODDB_URL}/de/gcc/rss/channel/price_rise.rss",
  "#{ODDB_URL}/de/gcc/rss/channel/recall.rss",
  "#{ODDB_URL}/de/gcc/rss/channel/sl_introduction.rss",
  "#{ODDB_URL}/de/gcc/sequences/",
  "#{ODDB_URL}/de/gcc/vaccines/",
  "#{ODDB_URL}/en/",
  "#{ODDB_URL}/fr/",
  "http://itunes.apple.com/us/app/generika/id520038123?ls=1&mt=8",
  "http://www.whocc.no/atcddd/",
  "https://github.com/zdavatz/oddb.org",
  "https://play.google.com/store/apps/details?id=org.oddb.generika",
  "https://www.ywesee.com/",
  "https://ywesee.com/ODDB/Legal"
  # "#{ODDB_URL}/de/gcc/home/search_form/instant",
]

describe "ch.oddb.org" do
  VALID_ONLY_TRADEMARK_EXAMPLE = "Norvasc"

  before :all do
    @idx = 0
    @all_search_limitations = ["search_limitation_A", "search_limitation_B", "search_limitation_C", "search_limitation_D", "search_limitation_E",
      "search_limitation_SL_only", "search_limitation_valid"]
    waitForOddbToBeReady(@browser, ODDB_URL)
    @browser.link(name: "search_instant").click unless @browser.link(name: "search_instant").text.eql?("Instant")
    @direktvergleich = "Für den Direktvergleich klicken Sie"
  end

  before :each do
    @browser.goto ODDB_URL
  end

  after :each do
    @idx += 1
    createScreenshot(@browser, "_" + @idx.to_s)
  end

  def check_nutriflex_56091(text)
    expect(text).to match(/Bezeichnung/i)
    expect(text).to match(/Galenische Form/i)
    expect(text).to match(/Excipiens/i)
    expect(text).to match(/Wirkstoff/i)
    expect(text).to match(/Isoleucin/i)
    expect(text).to match(/Hilfsstoff/i)
    expect(text).to match(/Citratsäure/i)
  end

  describe "main links" do
    before :each do
      @browser.goto ODDB_URL
      unless /#{A_USER_NAME}/o.match?(@browser.text)
        # logout/login if necessary
        logout
        login
      end
    end

    it "should be possible use follow recent_registrations  " do
      @browser.goto ODDB_URL
      link1 = @browser.link(href: /recent_registrations/).wait_until(&:present?)
      link1.click
      expect(@browser.text.clone).not_to match TraceBack
      @browser.link(href: /#{ODDB_URL}/o).wait_until(timeout: 10, &:present?)
      text = @browser.text.clone
      expect(text).not_to match LeeresResult
      expect(text).not_to match TraceBack
    end

    LINKS_2_CHECK.each do |link2follow|
      if link2follow.size == 0 || /rss$/.match(link2follow) || /goo.gl|youtube/.match(link2follow)
        skip "Skipping #{link2follow}"
        next
      end
      it "should be possible use follow#{link2follow}" do
        unless @browser.link(href: link2follow).visible?
          skip "Cannot check#{link2follow} as it is not visible"
        end
        @browser.goto ODDB_URL
        link1 = @browser.link(href: link2follow).wait_until(&:present?)
        link1.click
        expect(@browser.text.clone).not_to match TraceBack
        if /#{ODDB_URL}/o.match?(link2follow)
          puts "waiting for to appear #{link2follow}" if $VERBOSE
          @browser.link(href: /#{ODDB_URL}/o).wait_until(timeout: 10, &:present?)
        end
        text = @browser.text.clone
        expect(text).not_to match LeeresResult
        expect(text).not_to match TraceBack
      end
    end
  end

  describe "admin" do
    before :all do
    end
    before :each do
      skip "We do not run these tests when testing_ch_oddb_org" unless testing_ch_oddb_org
      @browser.goto ODDB_URL
      logout
      login(ADMIN_USER, ADMIN_PASSWORD)
    end
    after :all do
      logout
    end

    it "admin should edit package info" do
      @browser.goto "#{ODDB_URL}/de/#{Flavor}/drug/reg/56091/seq/02/pack/04"
      @browser.windows.size
      expect(@browser.url).to match ODDB_URL
      text = @browser.text.clone
      skip "check_nutriflex_56091 only works with sequence, not with package"
      check_nutriflex_56091(text)
      expect(text).to match(/Patinfo aktivieren/i)
      expect(text).to match(/Braun Medical/i)
      expect(text).to match(/Nutriflex Lipid/i)
      expect(@browser.url).to match ODDB_URL
    end

    it "admin should edit sequence info" do
      @browser.goto "#{ODDB_URL}/de/#{Flavor}/drug/reg/56091/seq/02"
      @browser.windows.size
      expect(@browser.url).to match ODDB_URL
      text = @browser.text.clone
      expect(text).to match(/Patinfo aktivieren/i)
      expect(text).to match(/Braun Medical/i)
      expect(text).to match(/Nutriflex Lipid/i)
      expect(text).to match(/Wirkstoffe.+Arginin.+Isoleucin/im) # correct sort order
      check_nutriflex_56091(text)
      expect(@browser.url).to match ODDB_URL
    end

    it "admin should edit registration info" do
      @browser.goto "#{ODDB_URL}/de/#{Flavor}/drug/reg/56091"
      @browser.windows.size
      expect(@browser.url).to match ODDB_URL
      text = @browser.text.clone
      expect(text).to match(/Fachinfo-Upload/i)
      expect(text).to match(/Braun Medical/i)
      expect(text).to match(/Nutriflex Lipid/i)
      expect(@browser.url).to match ODDB_URL
    end
  end
  describe "desitin" do
    before :each do
      login
    end

    # bin/admin command: packages.find{|x| x.ikscat.eql?('A+')}.name
    MEDI_Aplus_SL = "Palexia"
    it "should display the correct color #{MEDI_Aplus_SL}" do
      @browser.select_list(name: "search_type").select("Markenname")
      @browser.text_field(name: "search_query").set(MEDI_Aplus_SL)
      @browser.element(name: "search").wait_until(&:present?)
      @browser.button(name: "search").click
      @browser.element(id: "ikscat_1").wait_until(&:present?)
      expect(@browser.element(id: "ikscat_1").text).to match(/^A\+ \/ SL/)
      expect(@browser.link(visible_text: "FI").exists?).to eq true
      expect(@browser.link(visible_text: "PI").exists?).to eq true
      expect(@browser.td(visible_text: "A+").exists?).to eq true
      expect(@browser.td(visible_text: "C").exists?).to eq false
      expect(@browser.link(visible_text: "FB").exists?).to eq true
      td = @browser.td(visible_text: /#{MEDI_Aplus_SL}/io)
      expect(td.style("background-color")).to match(/0, 0, 0, 0/)
      @browser.span(text: /A+.+\/.+SL/).present?
      @browser.span(text: /A+.+\/.+SL/).wait_until(&:present?)
    end

    # bin/admin command
    #  packages.find{|x| x.ikscat.eql?('B') && /^I/.match(x.name) && x.generic_type.eql?(:generic)}.name
    MEDI_B_SL_SO = "Inegy"

    it "should display a limitation link for #{MEDI_B_SL_SO}" do
      @browser.select_list(name: "search_type").select("Markenname")
      @browser.element(name: "search").wait_until(&:present?)
      @browser.text_field(name: "search_query").set(MEDI_B_SL_SO)
      @browser.button(name: "search").click
      @browser.element(id: "ikscat_1").wait_until(&:present?)
      td = @browser.td(class: /^list/, visible_text: /^#{MEDI_B_SL_SO}/o)
      expect(td.exist?).to eq true
      expect(td.links.size).to eq 1
      expect(@browser.element(id: "ikscat_1").text).to eq "B / SL / SO"
      expect(@browser.link(visible_text: "L").exists?).to eq true
      expect(@browser.link(visible_text: "L").href).to match(/limitation_text\/reg/)
      expect(@browser.link(visible_text: "FI").exists?).to eq true
      expect(@browser.link(visible_text: "PI").exists?).to eq true
      expect(@browser.td(visible_text: "A").exists?).to eq false
      expect(@browser.td(visible_text: "C").exists?).to eq false
      expect(@browser.link(visible_text: "FB").exists?).to eq true
    end

    # bin/admin: packages.find{|x| x.ikscat.eql?('A') && x.generic_type.eql?(:generic)}.name
    MEDI_A_SL_SO_OR_SG = "Lamivudinum"
    it "should display #{MEDI_A_SL_SO_OR_SG} with SO and SG in category (price comparision)" do
      select_product_by_component(MEDI_A_SL_SO_OR_SG)
      expect(@browser.tds.find { |x| x.text.eql?("A / SL / SG") }.exists?).to eq true
      expect(@browser.tds.find { |x| x.text.eql?("A / SL / SO") }.exists?).to eq true

      # Check link to price history for price public
      expect(@browser.link(name: /price/).visible?)
      expect(@browser.link(name: /pubprice/).visible?)
      expect(@browser.link(name: /price_history/).visible?)
      @browser.link(name: /price_history/).click
      @browser.link(name: /th_public/).wait_until(&:present?)
    end

    it "should display Für den Preisvergleich in search result at the bottom" do
      medi = "lamivudin"
      select_product_by_component(medi)
      inhalt = @browser.text.clone
      expect(/#{@direktvergleich}[^\n]*\nWillkommen #{A_USER_FIRST_NAME} #{A_USER_NAME}/i).to match(inhalt)
      expect(/#{medi}.*#{@direktvergleich}/im).to match(inhalt)
      expect(/#{@direktvergleich}.*#{medi}/im).not_to match(inhalt)
    end

    it "should display Für den Preisvergleich in the price comparision" do
      medi = "lamivudin"
      select_product_by_trademark(medi)
      expect(@browser.link(name: "best_result").present?).to be true
      @browser.link(name: "best_result").click
      inhalt = @browser.text.clone
      expect(/#{@direktvergleich}[^\n]*\nWillkommen #{A_USER_FIRST_NAME} #{A_USER_NAME}/i).to match(inhalt)
      expect(/#{medi}.*#{@direktvergleich}/im).to match(inhalt)
      expect(/#{@direktvergleich}.*#{medi}/im).not_to match(inhalt)
    end

    it "should display two differnt prices for 55717 daTSCAN TM 123 I-Ioflupane " do
      @browser.goto "#{ODDB_URL}/de/#{Flavor}/price_history/reg/55717/seq/01/pack/002"
      inhalt = @browser.text.clone
      first_index = inhalt.index(/01.03.2012.*936.61.*1149.20/)
      second_index = inhalt.index(/01.03.2010.*1070.00.*1294.25/)
      expect(first_index).not_to be nil
      expect(second_index).not_to be nil
      expect(first_index < second_index)
    end

    it "should show a registration info" do
      @browser.goto "#{ODDB_URL}/de/#{Flavor}/show/reg/56091"
      @browser.windows.size
      expect(@browser.url).to match ODDB_URL
      text = @browser.text.clone
      expect(text).to match(/Braun Medical/i)
      expect(text).to match(/Nutriflex Lipid/i)
      expect(@browser.url).to match ODDB_URL
    end

    it "should show a sequence info" do
      @browser.goto "#{ODDB_URL}/de/#{Flavor}/show/reg/56091/seq/02"
      @browser.windows.size
      expect(@browser.url).to match ODDB_URL
      check_nutriflex_56091(@browser.text.clone)
      expect(@browser.url).to match ODDB_URL
    end

    it "should show a package info" do
      @browser.goto "#{ODDB_URL}/de/#{Flavor}/show/reg/56091/seq/02/pack/04"
      @browser.windows.size
      expect(@browser.url).to match ODDB_URL
      check_nutriflex_56091(@browser.text.clone)
      expect(@browser.url).to match ODDB_URL
    end

    it "should contain Open Drug Database" do
      waitForOddbToBeReady(@browser, ODDB_URL)
      expect(@browser.url).to match ODDB_URL unless ["just-medical"].index(Flavor)
      expect(@browser.title).to match(/Open Drug Database/i)
    end

    it "should not be offline" do
      expect(@browser.text).not_to match(/Es tut uns leid/)
    end

    unless ["just-medical"].index(Flavor)
      it "should have a link to the migel" do
        @browser.link(visible_text: "MiGeL").click
        @browser.link(name: "migel_alphabetical").wait_until(&:present?)
        expect(@browser.text).to match(/Pflichtleistung/)
        expect(@browser.text).to match(/Mittel und Gegenst/) # Mittel und Gegenstände
      end
    end

    it "should find Aspirin" do
      select_product_by_trademark("Aspirin")
      expect(@browser.text).to match(/Aspirin 500|ASS Cardio Actavis 100 mg|Aspirin Cardio 300/)
    end

    it "should find inderal" do
      select_product_by_trademark("inderal")
      expect(@browser.text).to match(/Inderal 10 mg/)
      expect(@browser.text).to match(/Inderal 40 mg/)
    end

    it "should display plus/minus signs for feedbacks" do
      # Found an example with + and - sign via bin/admin
      # sorted_feedbacks.find_all{ |x| !x.experience && x.time.year > 2010}.first.item.sequence
      @browser.goto(ODDB_URL + "/de/gcc/feedbacks/reg/62126/seq/02/pack/005")
      text = @browser.text.dup
      expect(text).to match(/Persönliche Erfahrung.+-.+Empfehlung/m)
      expect(text).to match(/Empfehlung.+\+.+Persönlicher Eindruck/m)
    end

    # TODO: Niklaus: 2024.02.29 I do not have the energy to setup the watri chrome correctly
    it "should find redirect an iphone to the mobile flavor" do
      iphone_ua = "Mozilla/5.0 (iPhone; CPU iPhone OS 10_2_1 like Mac OS X) AppleWebKit/602.4.6 (KHTML, like Gecko) Version/10.0 Mobile/14D27 Safari/602.1"
      new_options = @browser_options.clone
      new_options.args << "--user-agent=#{iphone_ua}"
      iphone_browser = Watir::Browser.new :chrome, options: new_options
      iphone_browser.goto "http://www.useragentstring.com/"
      txt = iphone_browser.text.clone
      expect(iphone_browser.textarea(id: "uas_textfeld").value).to eql iphone_ua
      expect(txt).to match(/AppleWebKit/)
      expect(txt).to match(/Mobile/)
      expect(txt).not_to match(/Fachinfo-Online/)
      expect(txt).not_to match(/Feedback/)
      iphone_browser.goto ODDB_URL
    ensure
      iphone_browser.close if iphone_browser
    end

    unless ["just-medical"].index(Flavor)
      it "should trigger the limitation after maximal 5 queries" do
        logout
        names = ["ipramol", "inderal", "Sintrom", "Prolia", "Certican", "Marcoumar", "Augmentin"]
        res = false
        names.each { |name|
          waitForOddbToBeReady(@browser, ODDB_URL)
          @browser.select_list(name: "search_type").select("Markenname")
          @browser.text_field(name: "search_query").set(name)
          @browser.button(name: "search").click
          if /Abfragebeschränkung auf 5 Abfragen pro Tag/.match?(@browser.text)
            res = true
            break
          end
          @browser.link(name: "ddd_count_text").wait_until(&:present?)
          createScreenshot(@browser, "_" + @idx.to_s)
          @idx += 1
        }
        expect(res).to eql true
      ensure
        login
      end
    end

    unless ["just-medical"].index(Flavor)
      it "should have a link to the english language versions" do
        @browser.goto ODDB_URL
        english = @browser.link(visible_text: "English")
        english.wait_until(&:present?)
        english.click
        @browser.button(name: "search").wait_until(&:present?)
        expect(@browser.text).to match(/Search for your favorite drug fast and easy/)
      end
    end

    unless ["just-medical"].index(Flavor)
      it "should have a link to the french language versions" do
        @browser.link(visible_text: /Français|French/i).wait_until(&:visible?)
        @browser.link(visible_text: /Français|French/i).click
        @browser.button(name: "search").wait_until(&:present?)
        expect(@browser.text).to match(/Comparez simplement et rapidement les prix des médicaments/)
      end
    end

    unless ["just-medical"].index(Flavor)
      it "should have a link to the german language versions" do
        @browser.link(visible_text: /Deutsch|German/).click
        @browser.link(text: "Abmelden").wait_until(&:present?)
        @browser.link(name: "ddd_count_text").wait_until(&:present?)
        expect(@browser.text).to match(/Vergleichen Sie einfach und schnell Medikamentenpreise./)
      end
    end

    it "should open print patinfo in a new window" do
      @browser.goto "#{ODDB_URL}/de/#{Flavor}/patinfo/reg/51795/seq/01"
      @browser.link(name: "print").wait_until(&:present?)
      windowSize = @browser.windows.size
      expect(@browser.url).to match ODDB_URL
      @browser.link(name: "print").click
      @browser.window(url: /print/).wait_until(&:present?)
      expect(@browser.windows.size).to eq(windowSize + 1)
      @browser.window(url: /print/).use
      expect(@browser.text).to match(/^Ausdruck.*Patienteninformation/im)
      expect(@browser.url).to match ODDB_URL
      @browser.window(url: ODDB_URL).close
    end

    it "should open a sequence specific patinfo" do # 15219 Zymafluor
      @browser.goto "#{ODDB_URL}/de/#{Flavor}/show/reg/15219"
      @browser.link(visible_text: "PI").wait_until(&:present?)
      expect(@browser.link(visible_text: "PI").exist?).to eq true
      @browser.link(visible_text: "PI").click
      @browser.window(url: /patinfo/).wait_until(&:present?)
      expect(@browser.url).to match(/patinfo/i)
    end

    it "should have a valid link for a Preis Anfrage" do
      login
      @browser.goto "#{ODDB_URL}/de/#{Flavor}/show/reg/45572/seq/01/pack/013"
      @browser.link(visible_text: "PA").wait_until(&:present?)
      @browser.link(visible_text: "PA").click
      expect(is_link_valid?(@browser.link(visible_text: "PA").href)).to eq true
    end

    it "should open a package specific patinfo" do # 43788 Tramal
      @browser.goto "#{ODDB_URL}/de/#{Flavor}/show/reg/43788/seq/01/pack/019"
      @browser.link(visible_text: "PI").wait_until(&:present?)
      expect(@browser.link(visible_text: "PI").exist?).to eq true
      @browser.link(visible_text: "PI").click
      # As this opens a new window we must focus on it
      @browser.windows.last.use if @browser.windows.size > 1
      expect(@browser.url).to match(/patinfo/i)
      expect(@browser.text).not_to match(/Die von Ihnen gewünschte Information ist leider nicht mehr vorhanden./)
      @browser.windows.last.close if @browser.windows.size > 1
    end

    it "should show the changelog" do
      select_product_by_trademark("Solmucol")
      @browser.link(name: "square_patinfo").click
      @browser.link(name: "change_log").click
      expect(@browser.text).to match "Anzahl Änderungen"
      @browser.link(name: "change_log").click
      expect(@browser.text).to match "Änderungen an"
    end

    it "should work for two patinfo in two different registration" do
      ["/de/gcc/patinfo/reg/57489/seq/01",
        "/de/gcc/patinfo/reg/55297/seq/04"].each do |pi_url|
        @browser.goto "#{ODDB_URL}/#{pi_url}"
        expect(/NoMethodError/i.match(@browser.text)).to be nil
        expect(@browser.link(name: "effects").present?).to be true
        expect(@browser.link(name: "print").present?).to be true
        @browser.link(name: "effects").click
        expect(@browser.url).to match(/effects$/)
        expect(@browser.text).to match(/Was ist.*und wann wird es angewendet/)
      end
    end

    it "should show correct Tramal Tropfen Lösung zum Einnehmen mit Dosierpumpe (4788/01/035)" do
      @browser.goto "#{ODDB_URL}/de/#{Flavor}/show/reg/43788/seq/01/pack/035"
      @browser.link(visible_text: "PI").wait_until(&:present?)
      expect(@browser.link(visible_text: "PI").exist?).to eq true
      @browser.link(visible_text: "PI").click
      @browser.link.wait_until(&:present?)
      expect(@browser.url).to match(/patinfo/i)
      text = @browser.text.clone
      expect(text).to match(/Was sind Tramal Tropfen Lösung zum Einnehmen und wann werden sie angewendet/)
      expect(text).not_to match(/Tramal Tropfen Lösung zum Einnehmen mit Dosierpumpe/)
    end

    it "should show correct Tramal Tropfen Lösung zum Einnehmen ohne Dosierpumpe(4788/01/086)" do
      @browser.goto "#{ODDB_URL}/de/#{Flavor}/show/reg/43788/seq/01/pack/086"
      @browser.link(visible_text: "PI").wait_until(&:present?)
      expect(@browser.link(visible_text: "PI").exist?).to eq true
      @browser.link(visible_text: "PI").click
      @browser.link.wait_until(&:present?)
      expect(@browser.url).to match(/patinfo/i)
      text = @browser.text.clone
      expect(text).to match(/Tramal Tropfen Lösung zum Einnehmen mit Dosierpumpe/)
      expect(text).not_to match(/Was sind Tramal Tropfen Lösung zum Einnehmen und wann werden sie angewendet/)
    end

    it "should open print fachinfo in a new window" do
      @browser.goto "#{ODDB_URL}/de/#{Flavor}/fachinfo/reg/51795"
      @browser.link(visible_text: /Drucken/i).wait_until(&:present?)
      expect(@browser.url).to match ODDB_URL
      windowSize = @browser.windows.size
      @browser.link(visible_text: /Drucken/i).click
      expect(@browser.windows.size).to eq(windowSize + 1)
      @browser.switch_window
      expect(@browser.text[0..200]).to match(/^Ausdruck.*Fachinformation/im)
      expect(@browser.url).to match ODDB_URL
      @browser.window(url: ODDB_URL).close
    end

    it "should be possible to request a new password" do
      @browser.link(visible_text: "Abmelden").click if @browser.link(visible_text: "Abmelden").visible?
      @browser.link(visible_text: "Anmeldung").wait_until(&:present?)
      @browser.link(visible_text: "Anmeldung").click
      @browser.link(name: "password_lost").wait_until(&:present?)
      @browser.link(name: "password_lost").click
      @browser.text_field(name: "email").wait_until(&:present?)
      @browser.text_field(name: "email").set "ngiger@ywesee.com"
      skip "Cannot test this on local host" if /127.0.0.1/.match?(@browser.url)
      @browser.button(name: "password_request").click
      url = @browser.url
      text = @browser.text
      expect(url).not_to match(/error/i)
      expect(text).to match(/Bestätigung/)
      expect(text).to match(/Vielen Dank. Sie erhalten in Kürze ein E-Mail mit weiteren Anweisungen./)
    end

    unless ["just-medical"].index(Flavor)
      it "should download the results of a search after paying with PayPal" do
        skip("Paypal login page is no longer usable with Watir")
        test_medi = "Aspirin"
        filesBeforeDownload = Dir.glob(GlobAllDownloads)
        @browser.text_field(name: "search_query").set(test_medi)
        @browser.button(name: "search").click
        @browser.button(value: "Resultat als CSV Downloaden").wait_until(&:present?)
        @browser.button(value: "Resultat als CSV Downloaden").click
        @browser.text_field(name: /name_last/i).value = "Mustermann"
        @browser.text_field(name: /name_first/i).wait_until(&:present?)
        @browser.text_field(name: /name_first/i).value = "Max"
        paypal_user = PaypalUser.new
        @browser.button(name: PaypalUser::CheckoutName).click
        expect(paypal_user.paypal_buy(@browser)).to eql true
        expect(@browser.url).not_to match(/errors/)
        @browser.link(name: "download").wait_until(&:present?)
        @browser.link(name: "download").click
        sleep(1) # Downloading might take some time
        filesAfterDownload = Dir.glob(GlobAllDownloads)
        diffFiles = (filesAfterDownload - filesBeforeDownload)
        expect(diffFiles.size).to eq(1)
      end
    end

    # ebenfallsc chlägt fehl Suche nach Inhaltsstoff Ascorbin
    # Nicht jedoch nach adenosin
    unless ["just-medical"].index(Flavor)
      it "should show ATC-Code A11EX for Ascorbin" do
        @browser.link(name: "drugs").click
        @browser.select_list(name: "search_type").select("Inhaltsstoff")
        @browser.text_field(name: "search_query").value = "Ascorbin"
        @browser.button(name: "search").wait_until(timeout: 10, &:present?)
        @browser.button(name: "search").click
        @browser.link(name: "square_fachinfo").wait_until(timeout: 60, &:present?)
        text = @browser.text.clone
        expect(text).not_to match LeeresResult
        expect(text).to match(/Liste\s+für\s+"Ascorbin"/)
        expect(text).to match("A11EX")
      end
    end

    unless ["just-medical"].index(Flavor)
      it "should be possible to find drugs from Sandoz via Zulassungsinhaber" do
        @browser.link(name: "drugs").click
        @browser.text_field(name: "search_query").wait_until(&:present?)
        @browser.select_list(name: "search_type").select(/Zulassungsin/) # st_company
        @browser.text_field(name: "search_query").value = "Sandoz"
        @browser.button(name: "search").wait_until(timeout: 10, &:present?)
        @browser.button(name: "search").click
        @browser.link(name: "square_fachinfo").wait_until(timeout: 120, &:present?)
        text = @browser.text.clone
        expect(text).not_to match LeeresResult
        expect(text).not_to match TraceBack
        expect(text).to match(/Sandoz.*ortierung nach/)
        expect(text).to match(/Pharmaceuticals AG/)
        expect(text).to match(/Seite \d+\s*von\s+\d+/)
        /Seite \d+\s*von\s+\d+/.match(text)
      end
    end

    it "should be possible use see New registrations" do
      @browser.link(name: "new_registrations").click
      text = @browser.text.clone
      expect(text).not_to match LeeresResult
      expect(text).not_to match TraceBack
    end

    unless ["just-medical"].index(Flavor)
      it "should be possible to find drugs from Ferring via Zulassungsinhaber single page" do
        @browser.link(name: "drugs").click
        @browser.text_field(name: "search_query").wait_until(&:present?)
        @browser.select_list(name: "search_type").select(/Zulassungsin/) # st_company
        @browser.text_field(name: "search_query").value = "Ferring"
        @browser.button(name: "search").click
        @browser.link(name: "square_fachinfo").wait_until(timeout: 30, &:present?)
        text = @browser.text.clone
        expect(text).not_to match LeeresResult
        expect(text).not_to match TraceBack
        expect(text).to match(/Ferring.*ortierung nach/)
        expect(text).to match(/Ferring AG/)
        expect(text).not_to match "Seite"
      end
    end

    def check_search_with_type
      query = @browser.text_field(name: "search_query")
      expect(query.exists?).to eq true
      search_type = @browser.select_list(name: "search_type")
      expect(search_type.exists?).to eq true
    end

    it "should display search and search_type for fachinfo diff of 28.11.2015" do
      diff_url = "/show/fachinfo/#{SNAP_IKSNR}/diff/28.11.2015"
      @browser.goto(ODDB_URL + "/de/gcc" + diff_url)
      check_search_with_type
    end

    it "should display search and search_type for fachinfo diff" do
      diff_url = "/show/fachinfo/#{SNAP_IKSNR}/diff"
      @browser.goto(ODDB_URL + "/de/gcc" + diff_url)
      check_search_with_type
      link = @browser.link(name: "change_log")
      expect(link.exists?).to eq true
      link.click
      check_search_with_type
    end

    # this is very tricky!`
    def select_medi_via_instant(medi)
      @browser.link(visible_text: "Instant").click if @browser.link(visible_text: "Instant").exists?
      expect(@browser.text).to match(/Art der Suche:\s*$\s*Plus/im)
      0.upto(10).each { |idx|
        begin
          chooser = @browser.text_field(id: "searchbar")
          chooser.set(medi)
          sleep idx * 0.1
          chooser.send_keys(:down)
          sleep idx * 0.1
          value = chooser.value
          medi.match(value)
          sleep 0.5
          break if /#{medi}/i.match(value) and value.length > medi.length
        rescue => e
          puts "in rescue"
          createScreenshot(@browser, "rescue_#{medi}_#{__LINE__}")
          puts e.inspect
          puts caller[0..5]
          next
        end
      }
    end

    ["Inderal",
      "Augmentin"].each do |medi|
      it "should have a working instant search for #{medi} and going back" do
        skip("backtrace does not work with Augmentin which contains ( in the link") if /Augmentin/i.match?(medi)
        select_medi_via_instant(medi)
        @browser.url
        inhalt = @browser.text
        expect(inhalt).to match(/Preisvergleich für/i)
        expect(inhalt).to match(/#{medi}/i)
        expect(inhalt).to matgbgch(/Zusammensetzung/i)
        back_to_list = @browser.link(visible_text: /Liste/)
        @browser.text.clone
        expect(back_to_list.present?)
        # visit price_history
        price_history = @browser.link(href: /price_history/)
        price_history.click
        back_to_list = @browser.link(visible_text: /Liste/)
        expect(back_to_list.present?)
        back_to_list.click
        expect(@browser.text).to match medi
        expect(@browser.text).not_to match LeeresResult
      end
    end

    ["status_oddb"].each do |name|
      it "should have a working status page #{name}" do
        @browser.goto(ODDB_URL + "/resources/downloads/" + name)
        url = @browser.url
        inhalt = @browser.text
        m = /sessions:\s+(\d+).+threads:\s+(\d+).+memory:\s+(\d+)/.match(inhalt)
        expect(m).not_to be nil
        expect(m[1].to_i).to be >= 0 # sessions can be 0
        expect(m[2].to_i).to be > 0 # we must have at least one thread
        expect(m[3].to_i).to be > 0 # memory
        m2 = /^\s*(\d+)-(\d+)-(\d+)\s+(\d+):(\d+):(\d+):/.match(inhalt)
        expect(m2).not_to be nil
        time = Time.parse(m2[0])
        diff_seconds = Time.now.to_i - time.to_i
        # * less than 5 minutes
        puts "status page #{url} is too old #{time}" unless diff_seconds < 310
        expect(diff_seconds).to be < 310
      end
    end
    #   'status_just-medical',.each do |name|
    it "should have a working status page #{name}" do
      @browser.goto(ODDB_URL + "/resources/downloads/" + name)
      url = @browser.url
      inhalt = @browser.text
      m = /sessions:\s+(\d+).+threads:\s+(\d+).+memory:\s+(\d+)/.match(inhalt)
      skip("status page for #{name} may be absent when running under devenv") unless m
      expect(m).not_to be nil
      expect(m[1].to_i).to be >= 0 # sessions can be 0
      expect(m[2].to_i).to be > 0 # we must have at least one thread
      expect(m[3].to_i).to be > 0 # memory
      m2 = /^\s*(\d+)-(\d+)-(\d+)\s+(\d+):(\d+):(\d+):/.match(inhalt)
      expect(m2).not_to be nil
      time = Time.parse(m2[0])
      diff_seconds = Time.now.to_i - time.to_i
      # * less than 5 minutes
      puts "status page #{url} is too old #{time}" unless diff_seconds < 310
      expect(diff_seconds).to be < 310
    end
  end

  def verify_search_preferences(prefs)
    @user_pref_url = ODDB_URL + "/de/gcc/preferences"
    @browser.goto(@user_pref_url)
    for limitation in prefs do
      expect(@browser.checkbox(id: limitation.to_s).visible?)
      expect(@browser.checkbox(id: limitation.to_s).value).to match(/1|true/)
    end
    @browser.back
  end

  def set_search_preferences(prefs)
    @user_pref_url = ODDB_URL + "/de/gcc/preferences"
    @browser.goto(@user_pref_url)
    @all_search_limitations.each { |id| @browser.checkbox(id: id).clear }
    for limitation in prefs do
      expect(@browser.checkbox(id: limitation.to_s).visible?)
      @browser.checkbox(id: limitation.to_s).set(true)
      expect(@browser.checkbox(id: :search_limitation_valid.to_s).value).to eql "1"
    end
    @browser.button(name: "update").click
  end

  def get_nr_items
    return 0 if LeeresResult.match(@browser.text)
    list_title = @browser.span(class: "breadcrumb", visible_text: /\(.*\)/).text
    /\((\d+)\)/.match(list_title)[1].to_i
  end
  # found using the following bin/admin (There are less < 1% of these cases)
  it "should not display expired drugs, when search says active drugs only" do
    login
    set_search_preferences([])
    select_product_by_trademark(VALID_ONLY_TRADEMARK_EXAMPLE)
    nr_unrestricted_products = get_nr_items
    puts "found #{nr_unrestricted_products} unrestricted products for #{VALID_ONLY_TRADEMARK_EXAMPLE}"
    set_search_preferences([:search_limitation_valid])
    verify_search_preferences([:search_limitation_valid])
    select_product_by_trademark(VALID_ONLY_TRADEMARK_EXAMPLE)
    nr_restricted_products = get_nr_items
    puts "found #{nr_restricted_products} restricted products for #{VALID_ONLY_TRADEMARK_EXAMPLE}"
    expect(nr_unrestricted_products).to be > 0
    # TODO: Niklaus August 2026. This is a real error
    # 	Becozym forte	20 Dragée(s)	2.88	5.30	10%		Dragées: 7 Wirkstoffe	Bayer (Schweiz) AG	D / SL
    expect(nr_unrestricted_products).to be > nr_restricted_products
    puts "Limit to only valid products succeeded for #{VALID_ONLY_TRADEMARK_EXAMPLE}" if nr_unrestricted_products > nr_restricted_products
  end

  # To find examples we used the following bin/admin snippet

  tests = [
    [:search_limitation_A, "Fosfolag", false],
    [:search_limitation_B, "Allergo-X", true],
    # [:search_limitation_C,  'Allergo-X', true], #skipping per 22.1.2021
    [:search_limitation_D, "Elmex", true],
    [:search_limitation_E, "Holunder", true],
    [:search_limitation_SL_only, "Soolantra 10 mg", true],
    [:search_limitation_SL_only, "Methotrexat", true],
    [:search_limitation_SL_only, "mephadolor", false],
    [:search_limitation_SL_only, "Omeprazol MUT Sandoz", true]
    # Done in separate spec test, as one has to search often for an actual valid example
    #  :search_limitation_valid => VALID_ONLY_TRADEMARK_EXAMPLE,
  ]
  # if you want to run a subset of the tests

  tests.each do |example|
    limitation = example[0]
    drug_name = example[1]
    must_be_greater = example[2]
    it "limiting the search to #{limitation} using #{drug_name}" do
      login
      set_search_preferences([])
      select_product_by_trademark(drug_name)
      nr_unrestricted_first = get_nr_items
      expect(nr_unrestricted_first).to be > 0

      set_search_preferences([limitation])
      verify_search_preferences([limitation])
      @browser.goto(ODDB_URL)
      @browser.goto(@user_pref_url)
      expect(@browser.checkbox(id: limitation.to_s).set?).to be true
      select_product_by_trademark(drug_name)
      nr_restriced = get_nr_items
      categories = @browser.elements(id: /ikscat_\d+$/).collect { |x| x.text }
      categories.each { |category| expect(/^|\sA[$|\s]/.match(category)).not_to be nil }
      expect(categories.size).to eq nr_restriced
      expect(nr_restriced).to be > 0

      # Reset preferences to zero
      set_search_preferences([])
      select_product_by_trademark(drug_name)
      nr_unrestricted_second = get_nr_items
      puts "Testing nr items found with #{limitation} for #{drug_name} which returned #{nr_unrestricted_first}/#{nr_restriced}/#{nr_unrestricted_second} items. must_be_greater is #{must_be_greater}"
      expect(nr_unrestricted_second).to be > 0
      expect(nr_unrestricted_second).to eql nr_unrestricted_first
      expect(nr_unrestricted_first).to be > nr_restriced if must_be_greater
    end
  end
  it "should display a result for homeopathy Similasan Arnica" do
    # August 2025: This test does not work for running on 127.0.0.1:8012, but without problem on ch.oddb.org
    url = ODDB_URL + "/de/homeopathy"
    @browser.goto(url)
    @browser.select_list(name: "search_type").select("Markenname")
    @browser.text_field(name: "search_query").set("Similasan Arnica")
    @browser.button(name: "search").click
    @browser.link(visible_text: "PI").wait_until(&:visible?)
    text = @browser.text.clone
    expect(text[0..1000]).not_to match(/traceback/i)
    expect(text[0..1000]).to match(/Homöopathika für Muskeln und Skelett/i)
  end

  it "should display the ATC-Browser, way down to H05AA02" do
    @browser.link(name: "atc_chooser").click
    text = @browser.text.clone
    expect(text[0..1000]).to match(/\(A\)/)
    expect(text[0..1000]).to match(/\(V\)/)
    @browser.link(text: /.*\(H\)/).click
    @browser.link(text: /.*\(H05\)/).click
    @browser.link(text: /.*\(H05A\)/).click
    @browser.link(text: /.*\(H05AA\)/).click
    @browser.link(text: /.*\(H05AA02\)/).click
    text = @browser.text.clone
    expect(text[0..1000]).to match(/Forsteo/)
  end

  it "help and legal_note links must be present" do
    @browser.link(name: /^log/).wait_until(&:visible?)
    expect(@browser.link(visible_text: "Home").wait_until(&:visible?))
    expect(@browser.link(visible_text: /Home/).visible?).to be true
    expect(@browser.link(visible_text: /FAQ/).visible?).to be false
    expect(@browser.link(visible_text: /Hilfe/).visible?).to be true
    expect(@browser.link(visible_text: /Rechtlicher/).visible?).to be true
    help_url = "https://ywesee.com/ODDB/Legal"
    expect(@browser.link(visible_text: /Hilfe/).href).to eql help_url
    expect(@browser.link(visible_text: /Rechtlicher/).href).to eql help_url
  end

  after :all do
    @browser.close if @browser
  end
end
