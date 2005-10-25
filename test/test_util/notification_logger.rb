#!/usr/bin/env ruby
# TestNotifyLog -- oddb -- 21.04.2005 -- jlang@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'util/notification_logger'
require 'flexmock'

module ODDB
	class TestNotificationLogger < Test::Unit::TestCase
		def setup
			@log = NotificationLogger.new
			@app = FlexMock.new
		end
		def test_log__1
			time1 = Time.local(2005, 4, 21, 15, 54)
			entry1 = @log.log('30785010', "usenguel@ywesee.com", 
				"jlang@ywesee.com", time1)
			logs = @log.logs
			assert_equal(1, logs.size)
			entries = logs['30785010']
			assert_instance_of(Array, entries)
			assert_equal([entry1], entries)
			assert_instance_of(NotificationLogger::LogEntry, entry1)
			assert_equal(time1, entry1.time)
			assert_equal('usenguel@ywesee.com', entry1.sender)
			assert_equal('jlang@ywesee.com', entry1.recipient)

			time2 = Time.local(2005, 5, 21, 15, 54)
			entry2 = @log.log('30785011', "usenguel@ywesee.com", 
				"jlang@ywesee.com", time2)
			expected = {
				"30785010"	=> [entry1],
				"30785011"	=> [entry2],
			}
			assert_equal(expected, @log.logs)

			time3 = Time.local(2005, 6, 21, 15, 54)
			entry3 = @log.log(30785010, 'usenguel@ywesee.com', 'jlang@ywesee.com', time3)
			expected = {
				"30785010"	=> [entry1, entry3],
				"30785011"	=> [entry2],
			}
			assert_equal(expected, @log.logs)
		end
		def test_total_count
			time1 = Time.local(2005, 4, 21, 15, 54)
			@log.log('30785010', "usenguel@ywesee.com", "jlang@ywesee.com", time1)
	  	@log.log('30785011', "usenguel@ywesee.com", "jlang@ywesee.com", time1)
			assert_equal(2, @log.total_count)
		end
		def test_total_count_iksnr
			time1 = Time.local(2005, 4, 21, 15, 54)
			time2 = Time.local(2005, 5, 21, 15, 54)
			time3 = Time.local(2005, 6, 21, 15, 54)
			@log.log('30785010', "usenguel@ywesee.com", "jlang@ywesee.com", time1)
			@log.log('30785010', "usenguel@ywesee.com", "jlang@ywesee.com", time2)
			@log.log('30785010', "usenguel@ywesee.com", "jlang@ywesee.com", time3)
			assert_equal(3, @log.total_count_iksnr(30785010))
			assert_equal(0, @log.total_count_iksnr(30785016))
		end
		def test_first_month
			time1 = Time.local(2005, 1, 6, 12, 34)
			time2 = Time.local(2005, 2, 26, 18)
			time3 = Time.local(2005, 4, 7, 2, 4)
			time4 = Time.local(2005, 1, 6, 12, 34)
			time5 = Time.local(2004, 12, 24, 23, 44)
			time6 = Time.local(2005, 1, 12, 12, 34)
			time7 = Time.local(2005, 2, 4, 12, 34)
			logs = {
				'23487012'	=> [time1, time2, time3, time4],
				'30785007'	=> [time5, time6, time7],
			}
			@log.instance_variable_set('@logs', logs)
			assert_equal(Date.new(2004, 12), @log.first_month)
		end
		def test_last_month
			time1 = Time.local(2005, 1, 6, 12, 34)
			time2 = Time.local(2005, 2, 26, 18)
			time3 = Time.local(2005, 4, 7, 2, 4)
			time4 = Time.local(2005, 1, 6, 12, 34)
			time5 = Time.local(2004, 12, 24, 23, 44)
			time6 = Time.local(2005, 1, 12, 12, 34)
			time7 = Time.local(2005, 2, 4, 12, 34)
			logs = {
				'23487012'	=> [time1, time2, time3, time4],
				'30785007'	=> [time5, time6, time7],
			}
			@log.instance_variable_set('@logs', logs)
			assert_equal(Date.new(2005, 2), @log.last_month)
		end
		def test_csv_line
			time1 = Time.local(2005, 2, 6, 12, 34)
			time2 = Time.local(2005, 2, 26, 18)
			time3 = Time.local(2005, 4, 7, 2, 4)
			time4 = Time.local(2005, 4, 6, 12, 34)
			logs = [time1, time2, time3, time4]
			month_range = Date.new(2005, 2)..Date.new(2005, 4)
			entry = @log.log('30785010', "usenguel@ywesee.com", "jlang@ywesee.com", time1)
			entries = [entry, entry, entry]
			arguments = {
				:name         => "Ponstan",
				:size  => "12 Tabletten",
				:iksnr        => "30785010", 
				:entries  		=> entries, 
			}
			result = @log.csv_line(month_range, entry, entries, arguments)
			line = ["30785010", "Ponstan", "12 Tabletten", "usenguel@ywesee.com", "jlang@ywesee.com", "3", "3", "0", "0"]
			assert_equal(line, result)
		end
		def test_csv_line__2
			time1 = Time.local(2005, 2, 6, 12, 34)
			time2 = Time.local(2005, 2, 26, 18)
			time3 = Time.local(2005, 4, 7, 2, 4)
			time4 = Time.local(2005, 4, 6, 12, 34)
			logs = [time1, time2, time3, time4]
			month_range = Date.new(2005, 1)..Date.new(2005, 5)
			entry = @log.log('30785010', "usenguel@ywesee.com", "jlang@ywesee.com", time1)
			entries = [entry, entry, entry]
			arguments = {
				:name         => "Ponstan",
				:size  => "12 Tabletten",
				:iksnr        => "30785010", 
				:entries  		=> entries, 
			}
			result = @log.csv_line(month_range, entry, entries, arguments)
			line = ["30785010", "Ponstan", "12 Tabletten", "usenguel@ywesee.com", "jlang@ywesee.com", "3", "3", "0", "0"]
		end
		def test_create_csv
			time1 = Time.local(2005, 1, 6, 12, 34)
			time2 = Time.local(2005, 1, 6, 12, 34)
			time3 = Time.local(2005, 2, 26, 18)
			time4 = Time.local(2005, 4, 7, 2, 4)

			time5 = Time.local(2004, 12, 24, 23, 44)
			time6 = Time.local(2005, 1, 12, 12, 34)
			time7 = Time.local(2005, 2, 4, 12, 34)


			entry1 = NotificationLogger::LogEntry.new("jlang@ywesee.com", "usenguel@ywesee.com", time1)
			entry2 = NotificationLogger::LogEntry.new("jlang@ywesee.com", "usenguel@ywesee.com", time2)
			entry3 = NotificationLogger::LogEntry.new("jlang@ywesee.com", "usenguel@ywesee.com", time3)
			entry4 = NotificationLogger::LogEntry.new("jlang@ywesee.com", "usenguel@ywesee.com", time4)
			entry5 = NotificationLogger::LogEntry.new("jlang@ywesee.com", "usenguel@ywesee.com", time5)
			entry6 = NotificationLogger::LogEntry.new("jlang@ywesee.com", "usenguel@ywesee.com", time5)
			entry7 = NotificationLogger::LogEntry.new("jlang@ywesee.com", "usenguel@ywesee.com", time7)
			logs = {
				'23487012'	=> [entry1, entry2, entry3, entry4],
				'30785007'	=> [entry5, entry6, entry7],
			}
			string = <<-EOS
Code;Name;Grösse;Sender;Empfänger;Total;December 2004;January 2005;February 2005;March 2005;April 2005
23487012;Ponstan;50 Tabletten;jlang@ywesee.com;usenguel@ywesee.com;4;0;2;1;0;1
23487012;Ponstan;50 Tabletten;jlang@ywesee.com;usenguel@ywesee.com;4;0;2;1;0;1
23487012;Ponstan;50 Tabletten;jlang@ywesee.com;usenguel@ywesee.com;4;0;2;1;0;1
23487012;Ponstan;50 Tabletten;jlang@ywesee.com;usenguel@ywesee.com;4;0;2;1;0;1
30785007;\"Mefanzid; Tabletten\";20 Tabletten;jlang@ywesee.com;usenguel@ywesee.com;3;2;0;1;0;0
30785007;\"Mefanzid; Tabletten\";20 Tabletten;jlang@ywesee.com;usenguel@ywesee.com;3;2;0;1;0;0
30785007;\"Mefanzid; Tabletten\";20 Tabletten;jlang@ywesee.com;usenguel@ywesee.com;3;2;0;1;0;0
			EOS
			@log.instance_variable_set('@logs', logs)
			assert_equal(4, @log.last_month.mon)
			registration1 = FlexMock.new
			registration2 = FlexMock.new
			@app.mock_handle(:registration) { |iksnr| 
				case iksnr
				when '30785'
					registration1
				when '23487'
					registration2
				else
					flunk("unexpected iksnr: #{iksnr}")
				end
			}
			package1 = FlexMock.new
			package2 = FlexMock.new
			registration1.mock_handle(:package) { |iksnr| 
				assert_equal('007', iksnr)
				package1
			}
			registration2.mock_handle(:package) { |iksnr| 
				assert_equal('012', iksnr)
				package2
			}
			package1.mock_handle(:name) {
				'Mefanzid; Tabletten'
			}
			package1.mock_handle(:size) {
				'20 Tabletten'
			}
			package2.mock_handle(:name) {
				'Ponstan'
			}
			package2.mock_handle(:size) {
				'50 Tabletten'
			}
			assert_equal(string, @log.create_csv(@app))
		end
	end
end
