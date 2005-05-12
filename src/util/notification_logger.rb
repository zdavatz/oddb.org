#!/usr/bin/env ruby
# NotificationLogger -- oddb -- 21.04.2005 -- jlang@ywesee.com

require 'csvparser'
require 'date'
require 'util/persistence'

module ODDB
	class NotificationLogger
		include ODBA::Persistable
		ODBA_SERIALIZABLE = ['@logs']
		attr_reader :logs, :lines
		def initialize
			super
			@logs = {}
		end
		def log(iksnr, time)
			(@logs[iksnr.to_s] ||= []).push(time)
		end
		def total_count
			@logs.size
		end
		def total_count_iksnr(iksnr)
			(@logs[iksnr.to_s] ||= []).size
		end
		def months_count(iksnr, date=nil)
			count = []
			time = date || time = Time.now
			if(logs = @logs[iksnr.to_s])
				logs.each { |val| 
					if(val.year == time.year && val.mon == time.mon)
						count.push(val)
					end
				}
			end
			count.size
		end
		def first_month
			time = @logs.collect { |key, times|
				times.first
			}.min
			Date.new(time.year, time.month)
		end
		def last_month
			time = @logs.collect { |key, times|
				times.last
			}.max
			Date.new(time.year, time.month)
		end
		def create_csv(app)
			csv_lines(app).collect { |line|
				CSVLine.new(line).to_s(false, ';')
			}.join("\n") << "\n"
		end
		def csv_line(name, key, times, month_range)
			line = [
				name.to_s,
				key.to_s,
				times.size.to_s,
			]
			month = month_range.first
			while(month <= month_range.last)
				count = times.select { |val| 
					val.year == month.year && val.mon == month.mon
				}
				line.push(count.size.to_s)
				month = month >> 1
			end
			line
		end
		def csv_lines(app)
			header = [
				"IKSNr.",
				"Name",
				"Total",
			]
			month_range = (first_month)..(last_month)
			month = month_range.first
			while(month <= month_range.last)
				header.push("#{month.strftime("%B")} #{month.year}")
				month = month >> 1
			end
			lines = @logs.collect { |key, val| 
				iksnr = [key[0..4], key[5..8]]
				name = app.registration(iksnr[0]).package(iksnr[1]).name
				csv_line(name, key, val, month_range)
			}.sort.unshift(header)
		end
	end
end
