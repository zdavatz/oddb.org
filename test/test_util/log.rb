#!/usr/bin/env ruby
# TestLog -- oddb -- 26.05.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'util/log'

module Net
	class SMTP
		class << self
			def start(mailserver)
				yield $stub_log_smtp
			end
		end
	end
end

class TestLog < Test::Unit::TestCase
	class StubSmtp
		def sendmail(*args)
			(@sent ||= []).push(args)
		end
		def sent
			@sent
		end
	end

	def setup
		@log = ODDB::Log.new(Date.new(1975,8,21))
		$stub_log_smtp = StubSmtp.new
	end
	def test_notify
		hash = {
			:recipients	=>	['hwyss@ywesee.com'],
			:pointers => ['aPointer'],
			:report =>	["a lengthy report.\n"]
		}
		@log.update_values(hash)
		@log.notify

		report = <<-EOS
From: update@oddb.org\r
To: hwyss@ywesee.com\r
Subject: ODDB Report - 08/1975\r
Content-Type: text/plain; charset=ISO-8859-1\r
User-Agent: ODDB Updater\r
\r
a lengthy report.\r
			EOS
		expected = [
			report.strip,
			'update@oddb.org',
			['hwyss@ywesee.com'],
		]
		result = $stub_log_smtp.sent
		result[0][0] = result[0][0].split("\n")[1..-1].join("\n")
		assert_equal([expected], result)
	end
	def test_notify_date_str
		hash = {
			:recipients	=>	['hwyss@ywesee.com'],
			:pointers => ['aPointer'],
			:report =>	["a lengthy report.\n"],
			:date_str =>	'Today',
		}
		@log.update_values(hash)
		@log.notify('Subject')

		report = <<-EOS
From: update@oddb.org\r
To: hwyss@ywesee.com\r
Subject: ODDB Report - Subject - Today\r
Content-Type: text/plain; charset=ISO-8859-1\r
User-Agent: ODDB Updater\r
\r
a lengthy report.\r
			EOS
		expected = [
			report.strip,
			'update@oddb.org',
			['hwyss@ywesee.com'],
		]
		result = $stub_log_smtp.sent
		result[0][0] = result[0][0].split("\n")[1..-1].join("\n")
		assert_equal([expected], result)
	end
	def test_notify_file
		file = File.expand_path('data/txt/log.txt', File.dirname(__FILE__))
		hash = {
			:recipients	=>	['hwyss@ywesee.com'],
			:pointers => ['aPointer'],
			:report =>	["a lengthy report.\n"],
			:files =>	{ file =>	'application/vnd.ms-excel' },
		}
		@log.update_values(hash)
		assert_nothing_raised {
			@log.notify
		}
	end
end
