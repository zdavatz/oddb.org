#!/usr/bin/env ruby

# kate: space-indent on; indent-width 2; mixedindent off; indent-mode ruby;
require "spec_helper"
require "pp"
require "open-uri"

describe "ch.oddb.org" do
  before :all do
    @idx = 0
    waitForOddbToBeReady(@browser, ODDB_URL)
    login(ADMIN_USER, ADMIN_PASSWORD)
  end

  before :each do
    @browser.goto ODDB_URL
    if @browser.link(visible_text: "Plus").exists?
      puts "Going from instant to plus"
      @browser.link(visible_text: "Plus").click
    end
  end

  after :each do
    @idx += 1
    createScreenshot(@browser, "_" + @idx.to_s)
    # sleep
    @browser.goto ODDB_URL
  end

  after :all do
    @browser.close if @browser
  end

  def session_uniq_email
    "#{get_session_timestamp}@ywesee.com"
  end

  def create_or_update_user(email = session_uniq_email, yus_rights = ["yus_privileges[login|org.oddb.CompanyUser]"])
    @browser.link(visible_text: "Admin").click
    @browser.link(visible_text: "Benutzer").click
    @browser.button(name: "new_user").click
    if @browser.link(visible_text: /#{email}/).exists?
      @browser.goto ODDB_URL
    end
    @browser.text_field(name: "name").set email
    @browser.text_field(name: "name_last").set "Familie #{get_session_timestamp}"
    @browser.text_field(name: "name_first").set "Hans"
    @browser.text_field(name: "address").set "Im Dorf"
    @browser.text_field(name: "plz").set Time.now.strftime("%H%M")
    @browser.text_field(name: "city").set "Irgendwo"
    yus_rights.each { |right| @browser.checkbox(name: right).set }
    @browser.button(name: "update").click
    @browser.goto ODDB_URL
    @browser.link(visible_text: "Admin").click
    @browser.link(visible_text: "Benutzer").click
    expect(@browser.link(visible_text: /#{email}/).exists?).to eq(true)
    @browser.goto ODDB_URL
  end

  def select_patinfo_via_iksnr(iksnr)
    @browser.goto ODDB_URL
    @browser.link(name: "drugs").click
    @browser.select_list(name: "search_type").select("Swissmedic-# (5-stellig)")
    @browser.text_field(id: "searchbar").set(iksnr.to_s)
    @browser.button(value: "Suchen").click
    @browser.link(name: "seqnr").wait_until(&:present?)
    @browser.link(name: "seqnr").click
    @browser.link(name: "ikscd").wait_until(&:present?)
    @browser.link(name: "ikscd").click
  end

  def upload_pat_info(original)
    iksnr = 43788
    expect(File.exist?(original)).to be true
    FileUtils.cp(original, DownloadDir, verbose: true)
    select_patinfo_via_iksnr(iksnr)
    # @browser.button(name: "delete_patinfo").wait_until(&:present?)
    @browser.button(text: /Speichern/).wait_until(&:present?)
    if @browser.button(name: "delete_patinfo").exists?
      @browser.button(name: "delete_patinfo").click
    end
    @browser.button(text: /Speichern/).wait_until(&:present?)
    expect(@browser.link(visible_text: "PI").exists?).to be false
    @browser.button(name: "delete_patinfo").click if @browser.button(name: "delete_patinfo").exist?
    expect(@browser.button(name: "delete_patinfo").exist?).to eq false
    @browser.file_field(name: "patinfo_upload").wait_until(&:present?)
    @browser.file_field(name: "patinfo_upload").set(original)
    # Here we get an error
    # Here I do not know how to activate the upload
    @browser.button(name: "update").wait_until(&:present?)
    @browser.button(name: "update").click
    select_patinfo_via_iksnr(iksnr)
    @browser.back
    @browser.link(visible_text: "PI").wait_until(&:present?)
    expect(@browser.link(visible_text: "PI").exists?).to be true
    new_content = URI.open(@browser.link(visible_text: "PI").href, "rb", ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
    # org_content = URI.open(original, 'rb').read;
    org_content = File.read(original)
    expect(org_content.size).to eq new_content.size
    expect(org_content).to eq new_content
  end

  def check_sort(link_name)
    expect(@browser.link(name: link_name).exists?).to be true
    @browser.link(name: link_name).click
    text_before = @browser.text
    expect(text_before).not_to match(/RangeError/i)
    expect(text_before.size).to be > 100
    expect(@browser.link(name: link_name).exists?).to be true
    @browser.link(name: link_name).click
    text_after = @browser.text
    expect(text_after).not_to match(/RangeError/i)
    expect(text_after.size).to be > 100
    expect(text_after).not_to eql? text_before
  end

  # we do this upload_pat_info be ensure that the upload really was done
  originals = [
    File.expand_path(File.join(__FILE__, "../../test/data/dummy_patinfo.pdf")),
    File.expand_path(File.join(__FILE__, "../../test/data/dummy_patinfo_2.pdf"))
  ]
  originals.each { |original|
    it "should be possible to upload #{File.basename(original)} to a given package" do
      skip "Do not test it when testing_ch_oddb_org" if testing_ch_oddb_org
      expect(FileUtils.compare_file(originals[0], originals[1])).not_to be true
      upload_pat_info(original)
    end
  }

  it "should be possible to create a CompanyUser" do
    skip("login as admin user does not work at the moment")
    create_or_update_user
  end

  ["th_affiliations", "th_name_first", "th_name_last", "th_email"].each { |link_name|
    it "should be possible to sort users by #{link_name.sub("th_", "")}" do
      # pending # does not work (september 2014)
      @browser.link(visible_text: "Admin").click
      @browser.link(visible_text: "Benutzer").click
      check_sort(link_name)
    end
  }
end
