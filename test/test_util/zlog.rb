#!/usr/bin/env ruby
# encoding: utf-8
# TestLog -- oddb -- 26.05.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'util/log'
require 'stub/odba'
require 'flexmock'
require 'util/logfile'

module Net
	class SMTP
		class << self
			def start(*args)
				yield $stub_log_smtp
			end
		end
	end
end
module ODDB
	class Log
    remove_const :MAIL_FROM
    remove_const :MAIL_TO
		MAIL_FROM = 'update@oddb.org'
		MAIL_TO = [
			'hwyss@ywesee.com',
		]
	end
	class TestLog < Test::Unit::TestCase
    include FlexMock::TestCase
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

      flexstub(ODDB) do |oddb|
        oddb.should_receive(:config).and_return(flexmock('config') do |conf|
          conf.should_receive(:mail_to).and_return(MAIL_TO)
          conf.should_receive(:smtp_server).and_return('smtp_server')
          conf.should_receive(:smtp_port).and_return('smtp_port')
          conf.should_receive(:smtp_domain).and_return('smtp_domain')
          conf.should_receive(:smtp_user).and_return('admin@ywesee.com')
          conf.should_receive(:smtp_pass).and_return('smtp_pass')
          conf.should_receive(:smtp_authtype).and_return('smtp_authtype')
        end)
      end
      flexstub(LogFile) do |logfile|
        logfile.should_receive(:append)
      end
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
Subject: ch.ODDB.org Report - 08/1975\r
Content-Type: text/plain; charset=UTF-8\r
User-Agent: ODDB Updater\r
\r
a lengthy report.\r
				EOS
			expected = [
				report.strip,
				'admin@ywesee.com',
				'hwyss@ywesee.com',
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
Subject: ch.ODDB.org Report - Subject - Today\r
Content-Type: text/plain; charset=UTF-8\r
User-Agent: ODDB Updater\r
\r
a lengthy report.\r
				EOS
			expected = [
				report.strip,
				'admin@ywesee.com',
				'hwyss@ywesee.com',
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
end
