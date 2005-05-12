#!/usr/bin/env ruby
# TestNotifyLog -- oddb -- 20.04.2005 -- jlang@ywesee.com

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
			expected = {
				"30785010"	=> [time1],
			}
			@log.log(30785010, time1)
			assert_equal(expected, @log.logs)
			time2 = Time.local(2005, 5, 21, 15, 54)
			expected = {
				"30785010"	=> [time1],
				"30785011"	=> [time2],
			}
			@log.log(30785011, time2)
			assert_equal(expected, @log.logs)
			time3 = Time.local(2005, 6, 21, 15, 54)
			expected = {
				"30785010"	=> [time1, time3],
				"30785011"	=> [time2],
			}
			@log.log(30785010, time3)
			assert_equal(expected, @log.logs)
		end
		def test_total_count
			time1 = Time.local(2005, 4, 21, 15, 54)
			@log.log(30785010, time1)
			@log.log(30785011, time1)
			assert_equal(2, @log.total_count)
		end
		def test_total_count_iksnr
			time1 = Time.local(2005, 4, 21, 15, 54)
			time2 = Time.local(2005, 5, 21, 15, 54)
			time3 = Time.local(2005, 6, 21, 15, 54)
			@log.log(30785010, time1)
			@log.log(30785010, time2)
			@log.log(30785010, time3)
			assert_equal(3, @log.total_count_iksnr(30785010))
			assert_equal(0, @log.total_count_iksnr(30785016))
		end
		def test_months_count
			time1 = Time.now
			time2 = Time.now
			time3 = Time.local(2005, 6, 21, 15, 54)
			time4 = Time.now
			time5 = Time.now
			time6 = Time.local(2004, 4, 21, 15, 54)
			time7 = Time.local(2003, 5, 21, 15, 54)
			@log.log(30785010, time1)
			@log.log(30785010, time2)
			@log.log(30785010, time3)
			@log.log(30785010, time4)
			@log.log(30785011, time5)
			@log.log(30785010, time6)
			assert_equal(3, @log.months_count(30785010))
			assert_equal(1, @log.months_count(30785010, time3))
			assert_equal(0, @log.months_count(30785010, time7))
			assert_equal(1, @log.months_count(30785011))
			assert_equal(0, @log.months_count(30785012))
			assert_equal(0, @log.months_count(39787072))
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
			result = @log.csv_line("Ponstan", '23487012', 
				logs, month_range)
			line = ["Ponstan", "23487012", "4", "2", "0", "2"]
			assert_equal(line, result)
		end
		def test_csv_line__2
			time1 = Time.local(2005, 2, 6, 12, 34)
			time2 = Time.local(2005, 2, 26, 18)
			time3 = Time.local(2005, 4, 7, 2, 4)
			time4 = Time.local(2005, 4, 6, 12, 34)
			logs = [time1, time2, time3, time4]
			month_range = Date.new(2005, 1)..Date.new(2005, 5)
			result = @log.csv_line("Ponstan", '23487012', 
				logs, month_range)
			line = ["Ponstan", "23487012", "4", "0", "2", 
				"0", "2", "0"]
			assert_equal(line, result)
		end
		def test_csv_lines
			time1 = Time.local(2005, 1, 6, 12, 34)
			time2 = Time.local(2005, 1, 6, 12, 34)
			time3 = Time.local(2005, 2, 26, 18)
			time4 = Time.local(2005, 4, 7, 2, 4)

			time5 = Time.local(2004, 12, 24, 23, 44)
			time6 = Time.local(2005, 1, 12, 12, 34)
			time7 = Time.local(2005, 2, 4, 12, 34)
			logs = {
				'23487012'	=> [time1, time2, time3, time4],
				'30785007'	=> [time5, time6, time7],
			}
			lines = [
			["IKSNr.", "Name", "Total", "December 2004", "January 2005", "February 2005", "March 2005", "April 2005"], 
			  ["Mefanzid", "30785007", "3", "1", "1", "1", "0", "0"],
			  ["Ponstan", "23487012", "4", "0", "2", "1", "0", "1"],
			]
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
				'Mefanzid'
			}
			package2.mock_handle(:name) {
				'Ponstan'
			}
			assert_equal(lines, @log.csv_lines(@app))
		end
		def test_create_csv
			time1 = Time.local(2005, 1, 6, 12, 34)
			time2 = Time.local(2005, 1, 6, 12, 34)
			time3 = Time.local(2005, 2, 26, 18)
			time4 = Time.local(2005, 4, 7, 2, 4)

			time5 = Time.local(2004, 12, 24, 23, 44)
			time6 = Time.local(2005, 1, 12, 12, 34)
			time7 = Time.local(2005, 2, 4, 12, 34)
			logs = {
				'23487012'	=> [time1, time2, time3, time4],
				'30785007'	=> [time5, time6, time7],
			}
			string = <<-EOS
IKSNr.;Name;Total;December 2004;January 2005;February 2005;March 2005;April 2005
"Mefanzid; Tabletten";30785007;3;1;1;1;0;0
Ponstan;23487012;4;0;2;1;0;1
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
			package2.mock_handle(:name) {
				'Ponstan'
			}
			assert_equal(string, @log.create_csv(@app))
		end
	end
end
