#!/usr/bin/env ruby

# TestIndexingCheck -- oddb.org -- 2026
# Covers the log parsing and reporting behind jobs/check_indexing, plus the
# service-account JWT the Search Console client signs.

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "stub/odba"
require "fileutils"
require "tmpdir"
require "util/indexing_check"

module ODDB
  class TestIndexingCheckUrls < Minitest::Test
    def teardown
      FileUtils.rm_rf(@dir) if @dir
      ODBA.storage = nil
      super
    end

    def setup
      @dir = Dir.mktmpdir("indexing_check")
    end

    def log(*lines)
      path = File.join(@dir, "oddb_log")
      File.write(path, lines.join("\n") + "\n")
      path
    end

    def line(url, status, method = "GET")
      %(1.2.3.4, 127.0.0.1 - - [23/Aug/2026 21:50:27] "#{method} #{url} HTTP/1.1" #{status} 1234 0.1 "Mozilla/5.0")
    end

    def test_collects_only_failing_urls
      path = log(
        line("https://ch.oddb.org/de/gcc/broken", 500),
        line("https://ch.oddb.org/de/gcc/fine", 200),
        line("https://ch.oddb.org/de/gcc/missing", 404)
      )
      assert_equal({"ch.oddb.org" => ["https://ch.oddb.org/de/gcc/broken"]},
        IndexingCheck.failing_urls(path))
    end

    def test_groups_by_host_and_deduplicates
      path = log(
        line("https://ch.oddb.org/a", 500),
        line("https://ch.oddb.org/a", 500),
        line("https://generika.cc/b", 500)
      )
      result = IndexingCheck.failing_urls(path)
      assert_equal(["ch.oddb.org", "generika.cc"], result.keys.sort)
      assert_equal(["https://ch.oddb.org/a"], result["ch.oddb.org"])
    end

    # Our own curl checks hit localhost and would otherwise pollute the list -
    # and Search Console would reject them as outside the property anyway.
    def test_skips_localhost
      path = log(
        line("http://localhost:8012/de/gcc/broken", 500),
        line("https://ch.oddb.org/de/gcc/broken", 500)
      )
      assert_equal(["ch.oddb.org"], IndexingCheck.failing_urls(path).keys)
    end

    def test_honours_the_limit_per_host
      path = log(*(1..5).collect { |i| line("https://ch.oddb.org/#{i}", 500) })
      assert_equal(2, IndexingCheck.failing_urls(path, 2)["ch.oddb.org"].size)
    end

    def test_ignores_missing_log_files
      assert_empty(IndexingCheck.failing_urls(File.join(@dir, "does_not_exist")))
    end

    def test_reads_several_files
      first = log(line("https://ch.oddb.org/a", 500))
      second = File.join(@dir, "oddb_log2")
      File.write(second, line("https://ch.oddb.org/b", 500) + "\n")
      assert_equal(2, IndexingCheck.failing_urls([first, second])["ch.oddb.org"].size)
    end
  end

  class TestIndexingCheckReport < Minitest::Test
    SITE_URLS = {"ch.oddb.org" => "sc-domain:oddb.org"}

    def teardown
      ODBA.storage = nil
      super
    end

    def stub_client(responses)
      client = flexmock("client")
      client.should_receive(:inspect_urls).and_return { |urls, _site, *_rest, &block|
        urls.each do |url|
          value = responses[url]
          if value.is_a?(GoogleSearchConsole::Error)
            block.call(url, nil, value)
          else
            block.call(url, value, nil)
          end
        end
      }
      client
    end

    def test_reports_a_fixed_url_as_successful
      check = IndexingCheck.new(stub_client(
        "https://ch.oddb.org/a" => {"pageFetchState" => "SUCCESSFUL", "verdict" => "PASS"}
      ))
      report = check.check({"ch.oddb.org" => ["https://ch.oddb.org/a"]}, SITE_URLS)
      assert_match("1 urls inspected", report)
      assert_match("SUCCESSFUL", report)
      refute_match("still failing", report)
    end

    def test_lists_urls_google_still_sees_as_failing
      check = IndexingCheck.new(stub_client(
        "https://ch.oddb.org/a" => {"pageFetchState" => "SERVER_ERROR",
                                    "verdict" => "FAIL",
                                    "lastCrawlTime" => "2026-08-20T10:00:00Z"},
        "https://ch.oddb.org/b" => {"pageFetchState" => "SUCCESSFUL", "verdict" => "PASS"}
      ))
      report = check.check(
        {"ch.oddb.org" => ["https://ch.oddb.org/a", "https://ch.oddb.org/b"]}, SITE_URLS
      )
      assert_match("still failing for Google (1)", report)
      assert_match("SERVER_ERROR 2026-08-20T10:00:00Z https://ch.oddb.org/a", report)
    end

    def test_counts_soft_404_and_redirect_errors_as_failing
      check = IndexingCheck.new(stub_client(
        "https://ch.oddb.org/a" => {"pageFetchState" => "SOFT_404"},
        "https://ch.oddb.org/b" => {"pageFetchState" => "REDIRECT_ERROR"}
      ))
      report = check.check(
        {"ch.oddb.org" => ["https://ch.oddb.org/a", "https://ch.oddb.org/b"]}, SITE_URLS
      )
      assert_match("still failing for Google (2)", report)
    end

    # A 403 for one url (quota, permissions) must not abort the whole run.
    def test_survives_api_errors
      check = IndexingCheck.new(stub_client(
        "https://ch.oddb.org/a" => GoogleSearchConsole::Error.new("403 quota exceeded"),
        "https://ch.oddb.org/b" => {"pageFetchState" => "SUCCESSFUL"}
      ))
      report = check.check(
        {"ch.oddb.org" => ["https://ch.oddb.org/a", "https://ch.oddb.org/b"]}, SITE_URLS
      )
      assert_match("api errors (1)", report)
      assert_match("403 quota exceeded", report)
      assert_match("SUCCESSFUL", report)
    end

    def test_skips_hosts_without_a_configured_property
      check = IndexingCheck.new(stub_client({}))
      report = check.check({"unknown.example" => ["https://unknown.example/a"]}, SITE_URLS)
      assert_match("no Search Console property configured", report)
    end
  end

  class TestIndexingCheckSiteUrl < Minitest::Test
    SITE_URLS = {
      "oddb.org" => "sc-domain:oddb.org",
      "generika.cc" => "sc-domain:generika.cc",
      "i.ch.oddb.org" => "https://i.ch.oddb.org/"
    }

    def resolve(host)
      IndexingCheck.site_url_for(host, SITE_URLS)
    end

    def test_exact_host_wins_over_the_domain_property
      assert_equal("https://i.ch.oddb.org/", resolve("i.ch.oddb.org"))
    end

    # sc-domain: covers every subdomain.
    def test_subdomains_fall_back_to_the_domain_property
      assert_equal("sc-domain:oddb.org", resolve("ch.oddb.org"))
      assert_equal("sc-domain:oddb.org", resolve("oekk.oddb.org"))
      assert_equal("sc-domain:oddb.org", resolve("desitin.oddb.org"))
      assert_equal("sc-domain:oddb.org", resolve("oddb.org"))
    end

    def test_unknown_hosts_resolve_to_nothing
      assert_nil(resolve("unknown.example"))
      assert_nil(resolve(nil))
      assert_nil(resolve(""))
    end

    # Crawlers send truncated Host headers ("chahmer.ch" for nachahmer.ch);
    # those must not be mistaken for a property and spend quota.
    def test_mangled_hosts_do_not_match_a_property
      assert_nil(resolve("chahmer.ch"))
      assert_nil(resolve("ahmer.ch"))
      assert_nil(resolve(".oddb.org"))
      assert_nil(resolve("notoddb.org"))
    end
  end

  class TestGoogleSearchConsoleAuth < Minitest::Test
    def teardown
      FileUtils.rm_rf(@dir) if @dir
      ODBA.storage = nil
      super
    end

    def setup
      @dir = Dir.mktmpdir("gsc")
      @key = OpenSSL::PKey::RSA.new(2048)
      @key_file = File.join(@dir, "service_account.json")
      File.write(@key_file, JSON.generate(
        "type" => "service_account",
        "client_email" => "oddb@example.iam.gserviceaccount.com",
        "private_key" => @key.to_pem
      ))
    end

    def test_reads_the_client_email
      assert_equal("oddb@example.iam.gserviceaccount.com",
        GoogleSearchConsole.new(@key_file).client_email)
    end

    def test_rejects_a_missing_key_file
      error = assert_raises(GoogleSearchConsole::Error) do
        GoogleSearchConsole.new(File.join(@dir, "nope.json"))
      end
      assert_match("not found", error.message)
    end

    def test_rejects_a_key_without_private_key
      path = File.join(@dir, "incomplete.json")
      File.write(path, JSON.generate("client_email" => "a@b.c"))
      error = assert_raises(GoogleSearchConsole::Error) { GoogleSearchConsole.new(path) }
      assert_match("private_key", error.message)
    end

    # The assertion must be a real RS256 JWT or Google rejects it, so verify
    # the signature rather than just the shape.
    def test_signs_a_verifiable_rs256_jwt
      client = GoogleSearchConsole.new(@key_file)
      token = client.send(:signed_jwt, {"iss" => "oddb@example.iam.gserviceaccount.com"})
      header, payload, signature = token.split(".")
      assert_equal({"alg" => "RS256", "typ" => "JWT"},
        JSON.parse(Base64.urlsafe_decode64(header)))
      assert_equal("oddb@example.iam.gserviceaccount.com",
        JSON.parse(Base64.urlsafe_decode64(payload))["iss"])
      assert(@key.verify(OpenSSL::Digest.new("SHA256"),
        Base64.urlsafe_decode64(signature), [header, payload].join(".")),
        "signature must verify against the service account key")
    end

    # Base64url, no padding - a "=" would make the token invalid.
    def test_jwt_segments_carry_no_padding
      client = GoogleSearchConsole.new(@key_file)
      token = client.send(:signed_jwt, {"iss" => "x"})
      refute_match("=", token)
    end
  end
end
