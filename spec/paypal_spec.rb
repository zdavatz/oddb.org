#!/usr/bin/env ruby
# encoding: utf-8

# This is the most important integration test, which ensures that handling payment via paypal works
# It requires the following setup:
# * must be run on the server (to be able to check in the log for the URL for new users)
# * etc/oddb.yml must be configured to use the sandbox (check here in the code)
# * test-account on developer.paypal.com must exist and specified correctly
#

require 'spec_helper'
require 'paypal_helper'

@workThread = nil

describe "ch.oddb.org" do
  before :all do
    @idx = 0
    @act_id = Time.now.strftime('%Y%m%d-%H%M%S')
    waitForOddbToBeReady(@browser, OddbUrl)
  end

  before :each do
    @browser.goto OddbUrl
    @customer_1 = PaypalUser.new('customer-1@ywesee.com', '12345678', 'Müller', 'Cécile') # Use UTF-8 to check encoding
    @customer_1.ywesee_user = "#{@act_id}@ywesee.com"
    @customer_2 = PaypalUser.new('poor_soul@ywesee.com', '87654321', 'Stürmer', 'Léopold')
  end

  after :each do
    @idx += 1
    createScreenshot(@browser, '_'+@idx.to_s)
  end

  def choose_medi_and_csv_display(customer)
    test_medi = PaypalUser::Six_Test_Drug_Names.first
    if customer
      if res = login(customer.email, customer.password)
        expect(@browser.link(:name => 'login_form').exist?).to eql false
        puts "Login for customer successful"
      else
        puts "Login for customer failed first_time"
        logout
      end
    end
    @browser.text_field(:name, "search_query").set(test_medi)
    @browser.button(:name, "search").click; small_delay
    @browser.button(:value,"Resultat als CSV Downloaden").click
  end

  def search_for_medi(name)
    waitForOddbToBeReady(@browser, OddbUrl)
    @browser.text_field(:name, "search_query").set(name)
    @browser.button(:name, "search").click; small_delay
  end

  def select_poweruser(duration = PaypalUser::OneDay)
    waitForOddbToBeReady(@browser, OddbUrl)
    logout
    res = false
    saved = @idx
    PaypalUser::Six_Test_Drug_Names.each {
      |name|
        search_for_medi(name)
        if /Abfragebeschränkung auf 5 Abfragen pro Tag/.match(@browser.text)
          res = true
          break
        end
        @idx += 1
    }
    expect(@idx - saved).to be <= 5
    search_for_medi(PaypalUser::Six_Test_Drug_Names.first) # I want a medi with few packages
    sleep(1) # delay a little
    if duration == PaypalUser::OneYear
      @browser.radio(:name => 'days', :value => PaypalUser::OneYear.to_s).set
    elsif duration ==  PaypalUser::OneMonth
      @browser.radio(:name => 'days', :value => PaypalUser::OneMonth.to_s).set
    else
      @browser.radio(:name => 'days', :value => PaypalUser::OneDay.to_s).set
    end
    sleep 5
  end

  it "should be possible to checkout oddb.csv via paypal" do
    waitForOddbToBeReady(@browser, OddbUrl)
		logout
		@browser.link(:name, "user").click; small_delay
    sleep(1) # is needed, don't know how to wait for link
		@browser.link(:name, "download_export").click; small_delay; small_delay
    @browser.select_list(:name, "compression").select("TAR/GZ")
		@browser.link(:name, "directlink_oddb_csv").click; small_delay # 500
    expect(@customer_1.init_paypal_checkout(@browser)).to eql true
    @browser.select_list(:name, "business_area").select("Medi-Information")
		@browser.text_field(:name, "address").set 'Rue César' # Use UTF-8 to check encoding
		@browser.text_field(:name, "plz").set '8077'
		@browser.text_field(:name, "city").set 'Zürich'
		@browser.text_field(:name, "phone").set '055 12345678'
    puts "email #{@customer_1.ywesee_user}: URL before preceeding to paypal was #{@browser.url}"
    @browser.button(:name => /checkout/).click; small_delay
    skip("Paypal login page is no longer usable with Watir")
    expect(@customer_1.paypal_buy(@browser)).to eql true
    expect(@browser.url).to match /sandbox.paypal.com/
    expect(@browser.text).not_to match PaymentUnconfirmed
    expect(@browser.text).to match /Vielen Dank! Sie können jetzt mit dem untigen Link die Daten downloaden./
    createScreenshot(@browser, 'paypal_oddb_csv')
    link = @browser.link(:name => 'download')
    expect(link.exists?).to be true
    link.click; small_delay
    expect(@browser.url).not_to match  /errors/
    expect(@browser.url).not_to match /appdown/
  end

  it 'should show the poweruser dialog with the top left logo' do
    logout
    expect(@browser.link(:name => 'login_form').exist?).to eql true
    PaypalUser::Six_Test_Drug_Names.each do |name|
      select_product_by_trademark(name)
      if /Abfragebeschränkung/i.match(@browser.text)
        break
      end
    end
    @browser.radio(:name => 'days', :value => PaypalUser::OneDay.to_s).set
    @browser.button(:name, "proceed_poweruser").click; small_delay
    # expect logo to be at the top left
    expect(@browser.images.first.wd.location.x).to be < 20
    expect(@browser.images.first.wd.location.y).to be < 20
    expect(@browser.element(:id => 'aswift_0_expand').visible?).to be true
    expect(@browser.images.first.alt).to eq 'ch.oddb.org'
  end

  it "should be checkout via paypal as poweruser for one day" do
    select_poweruser(PaypalUser::OneDay)
    puts "email #{@customer_1.ywesee_user}: URL before preceeding to paypal was #{@browser.url}"
    @browser.button(:name, "proceed_poweruser").click; small_delay
    expect(@customer_1.init_paypal_checkout(@browser)).to eql true
    @browser.button(:name => 'checkout').click; small_delay
    expect(@browser.url).to match /sandbox.paypal.com/
    expect(@browser.text).not_to match PaymentUnconfirmed
    skip("Paypal login page is no longer usable with Watir")
    expect(@customer_1.paypal_buy(@browser)).to eql true
    forward_to_home = @browser.link(:name => /forward_to_home|back_to_home/)
    puts "PayPal: Payment okay? #{forward_to_home.exists?}  #{forward_to_home.exists? ? forward_to_home.href : 'no href'}"
    expect(forward_to_home.exists?).to be true
    createScreenshot(@browser, 'paypal_poweruser')
    expect(@browser.url).not_to match /appdown/
    forward_to_home.click; small_delay
    expect(@browser.url).to match OddbUrl
    saved = @idx
    # ensure that login a new power user works and that he can visit as many drugs as he wants
    logout
    login(@customer_1.email, @customer_1.password)
    expect(@browser.link(:name => 'login_form').exist?).to eql false
    PaypalUser::Six_Test_Drug_Names.each {
      |name|
        search_for_medi(name)
        expect(@browser.text).not_to match /Abfragebeschränkung auf 5 Abfragen pro Tag/
    }
  end

  it "should return a correct link to a CSV file if the payment is okay" do
    skip("Paypal login page is no longer usable with Watir")
    puts "email #{@customer_1.ywesee_user}: URL before preceeding to paypal was #{@browser.url}"
    choose_medi_and_csv_display(nil)
    expect(@customer_1.init_paypal_checkout(@browser)).to eql true
    @browser.button(:name => /checkout/).click; small_delay
    expect(@customer_1.paypal_buy(@browser)).to eql true
    filesBeforeDownload =  Dir.glob(GlobAllDownloads)
    expect(@browser.url).to match /sandbox.paypal.com/
    expect(@browser.text).not_to match PaymentUnconfirmed
    expect(@browser.url).not_to match  /errors/
    expect(@browser.text).to match /Vielen Dank! Sie können jetzt mit dem untigen Link die Daten downloaden./
    createScreenshot(@browser, 'paypal_csv_okay')
    link = @browser.link(:name => 'download')
    expect(link.exists?).to be true
    link.click; small_delay
    expect(@browser.url).not_to match /errors/
    expect(@browser.url).not_to match /appdown/
    sleep(1) # it takes some time to download the file
    filesAfterDownload =  Dir.glob(GlobAllDownloads)
    diffFiles = (filesAfterDownload - filesBeforeDownload)
    expect(diffFiles.size).to eq(1)
    expect(IO.read(diffFiles.first)).to match /#{PaypalUser::Six_Test_Drug_Names.first}/i
  end

  it "should not download a CSV file if the payment was not accepted" do
    skip("Paypal login page is no longer usable with Watir")
    filesBeforeDownload =  Dir.glob(GlobAllDownloads)
    choose_medi_and_csv_display(@customer_2)
    expect(@customer_2.init_paypal_checkout(@browser)).to eql true
    @browser.button(:name => PaypalUser::CheckoutName).click; small_delay
    expect(@customer_2.paypal_buy(@browser)).to eql true
    expect(@browser.url).to match /sandbox.paypal.com/
    expect(@browser.text).not_to match PaymentUnconfirmed
    expect(@browser.url).not_to match  /errors/
    sleep(1) # it takes some time to download the file
    filesAfterDownload =  Dir.glob(GlobAllDownloads)
    diffFiles = (filesAfterDownload - filesBeforeDownload)
    expect(diffFiles.size).to eq(0)
  end

  it "should be possible to cancel a paypal before login" do
    skip("Paypal login page is no longer usable with Watir")
    choose_medi_and_csv_display(@customer_1)
    expect(@customer_1.init_paypal_checkout(@browser)).to eql true
    @browser.button(:name => PaypalUser::CheckoutName).click; small_delay
    expect(@customer_1.paypal_buy(@browser, PaypalUser::CancelCheckoutEarly)).to eql true
    puts "URL after #{@browser.url} OddbUrl"
    createScreenshot(@browser, 'paypal_csv_payment_cancelled')
    expect(@browser.url).to match /sandbox.paypal.com/
    expect(@browser.text).not_to match PaymentUnconfirmed
    expect(@browser.url.index(OddbUrl)).not_to be nil
  end

  it "should be possible to cancel a paypal after login but before paying" do
    skip("Paypal login page is no longer usable with Watir")
    choose_medi_and_csv_display(@customer_1)
    expect(@customer_1.init_paypal_checkout(@browser)).to eql true
    @browser.button(:name => PaypalUser::CheckoutName).click; small_delay
    expect(@customer_1.paypal_buy(@browser, PaypalUser::CancelCheckoutLater)).to eql true
    puts "URL after #{@browser.url} OddbUrl"
    expect(@browser.url).to match /sandbox.paypal.com/
    expect(@browser.text).not_to match PaymentUnconfirmed
    expect(@browser.url.index(OddbUrl)).not_to be nil
  end

  it "should be checkout via paypal as poweruser for one day sing a new credit card and login name" do
    skip("Paypal login page is no longer usable with Watir")
    id = Time.now.to_i
    new_customer = PaypalUser.new("tst-#{id}@ywesee.com", "pw_#{id}", "last_#{id}", "first_#{id}")
    puts "Created @ywesee_user #{new_customer.ywesee_user} with ywesee_password #{new_customer.ywesee_password}"
    select_poweruser(PaypalUser::OneDay)
    puts "email #{new_customer.ywesee_user}: URL before preceeding to paypal was #{@browser.url}"
    @browser.button(:name, "proceed_poweruser").click; small_delay
    expect(new_customer.init_paypal_checkout(@browser)).to eql true
    @browser.button(:name => 'checkout').click; small_delay
    expect(@browser.url).to match /sandbox.paypal.com/
    expect(@browser.text).not_to match PaymentUnconfirmed
    expect(new_customer.paypal_buy(@browser)).to eql true
    forward_to_home = @browser.link(:name => /forward_to_home|back_to_home/)
    puts "PayPal: Payment okay? #{forward_to_home.exists?}  #{forward_to_home.exists? ? forward_to_home.href : 'no href'}"
    expect(forward_to_home.exists?).to be true
    createScreenshot(@browser, 'paypal_poweruser')
    expect(@browser.url).not_to match /appdown/
    forward_to_home.click; small_delay
    expect(@browser.url).to match OddbUrl
    saved = @idx
    # ensure that login a new power user works and that he can visit as many drugs as he wants
    logout
    login(new_customer.email, new_customer.password)
    expect(@browser.link(:name => 'login_form').exist?).to eql false
    PaypalUser::Six_Test_Drug_Names.each {
      |name|
        search_for_medi(name)
        expect(@browser.text).not_to match /Abfragebeschränkung auf 5 Abfragen pro Tag/
    }
  end

  after :all do
    @browser.close
  end
end unless ['just-medical'].index(Flavor)
