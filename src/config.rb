#!/usr/bin/env ruby

# @config -- oddb.org -- 18.04.2012 -- yasaka@ywesee.com
# @config -- oddb.org -- 29.02.2012 -- mhatakeyama@ywesee.com
# @config -- oddb.org -- 08.09.2006 -- hwyss@ywesee.com

require "rclconf"
require "util/workdir"

module ODDB
  SERVER_URI ||= "druby://127.0.0.1:10000"
  SERVER_NAME ||= "ch.oddb.org"
  SERVER_URI_FOR_CRAWLER ||= "druby://127.0.0.1:10001"
  SERVER_URI_FOR_GOOGLE_CRAWLER ||= "druby://127.0.0.1:10008"
  FIPARSE_URI ||= "druby://127.0.0.1:10002"
  FIPDF_URI ||= "druby://127.0.0.1:10003"
  DOCPARSE_URI ||= "druby://127.0.0.1:10004"
  EXPORT_URI ||= "druby://127.0.0.1:10005"
  MEDDATA_URI ||= "druby://127.0.0.1:10006"
  SWISSREG_URI ||= "druby://127.0.0.1:10007"
  READONLY_URI ||= "druby://127.0.0.1:10013"
  MIGEL_URI ||= "druby://127.0.0.1:33000"

  oddb_dir = ODDB::PROJECT_ROOT
  default_dir = File.expand_path("etc", oddb_dir)
  default_config_files = [
    File.join(default_dir, "oddb.yml"),
    "/etc/oddb/oddb.yml"
  ]
  defaults = {
    "config"	=> default_config_files,
    "data_dir" => ODDB::WORK_DIR,
    "log_dir" => ODDB::LOG_DIR,
    "log_pattern" => File.join(ODDB::LOG_DIR, "/%Y/%m/%d/app_log"),
    "url_bag_sl_zip" => "https://www.spezialitaetenliste.ch/File.axd?file=XMLPublications.zip",
    "bsv_archives" => '(?:PR|BSV_per_20)(0[3-8])[\d.]+(?:txt|xls)',
    "server_url" => SERVER_URI,
    "migel_base_url" => "https://migel_base_url.net/wsv/wv_getMigel.aspx?Lang=DE&Query", # non working default
    "smtp_authtype" => :plain,
    "smtp_domain" => "oddb.org",
    "smtp_server" => "localhost",
    "smtp_user" => nil,
    "smtp_pass" => nil,
    "smtp_port" => 587,
    "text_info_searchform" => nil,
    "text_info_searchform2" => nil,
    "text_info_max_retry" => 5,
    "text_info_newssource" => nil,
    "mail_from" => '"ODDB-Mails" <mail@oddb.org>',
    "invoice_from" => '"ODDB-Invoices" <cfo@oddb.org>',
    "reply_to" => "reply_to@oddb.org",
    "mail_to" => [],
    "testenvironment1" => "",
    "testenvironment2" => "",
    "flickr_api_key" => "",
    "flickr_shared_secret" => "",
    "app_user_agent" => "", # as Regexp
    "paypal_server" => "www.paypal.com",     # or www.sandbox.paypal.com
    "paypal_receiver" => "zdavatz@ywesee.com", # or test_paypal@ywesee.com
    "refdata_api_key" => nil,
    "refdata_api_key_secondary" => nil,
    "drugshortage_hmac_secret" => nil,
    # Path to a Google service account key for jobs/check_indexing - either the
    # JSON key or a legacy .p12 (recognised by the extension). The account must
    # be a Full user of the Search Console properties below.
    "gsc_service_account_json" => nil,
    # Only needed for a .p12 key: unlike the JSON key it carries no metadata,
    # so the ...iam.gserviceaccount.com address has to be given here.
    "gsc_service_account_email" => nil,
    # Search Console property per domain, spelled as in Search Console itself:
    # either "sc-domain:oddb.org" or "https://ch.oddb.org/" with the slash.
    # A sc-domain: property covers its subdomains, so the oddb.org entry also
    # serves ch.oddb.org, i.ch.oddb.org, oekk.oddb.org and desitin.oddb.org -
    # IndexingCheck.site_url_for resolves a host to the longest matching entry.
    # Hosts without an entry are skipped instead of spending quota on them.
    # Override in etc/oddb.yml once you know which properties really exist.
    "gsc_site_urls" => {
      "oddb.org" => "sc-domain:oddb.org",
      "generika.cc" => "sc-domain:generika.cc",
      "nachahmer.ch" => "sc-domain:nachahmer.ch",
      "anthroposophika.ch" => "sc-domain:anthroposophika.ch"
    }
  }

  config = RCLConf::RCLConf.new(ARGV, defaults)
  config.load(config.config)
  @config = config
  def self.config
    @config
  end
end
