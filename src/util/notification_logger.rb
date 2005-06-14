#!/usr/bin/env ruby
# NotificationLogger -- oddb -- 21.04.2005 -- jlang@ywesee.com

require 'csvparser'
require 'date'
require 'util/persistence'

module ODDB
	class NotificationLogger
		class LogEntry
			attr_reader :sender, :recipient, :time
			def initialize(sender, recipient, time)
				@sender = sender
				@recipient = recipient
				@time = time 
			end
			def month
				@time.month
			end
			def year
				@time.year
			end
			def <=>(other)
				if(other.respond_to?(:time))
					other = other.time
				end
				@time <=> other
			end
		end
		include ODBA::Persistable
		ODBA_SERIALIZABLE = ['@logs']
		attr_reader :logs, :lines
		def initialize
			super
			@logs = {}
		end
		def log(iksnr, sender, recipient, time)
			entry = LogEntry.new(sender, recipient, time)
			(@logs[iksnr.to_s] ||= []).push(entry)
			entry
		end
		def total_count
			@logs.size
		end
		def total_count_iksnr(iksnr)
			(@logs[iksnr.to_s] ||= []).size
		end
		def first_month
			entry = @logs.collect { |key, entries|
				entries.first
			}.compact.min || Time.now
			Date.new(entry.year, entry.month)
		end
		def last_month
			entry = @logs.collect { |key, entries|
				entries.last
			}.compact.max || Time.now
			Date.new(entry.year, entry.month)
		end
		def create_csv(app)
			csv_lines(app).collect { |line|
				CSVLine.new(line).to_s(false, ';')
			}.join("\n") << "\n"
		end
		def range_lines(month_range, entries, arguments)
			entries.collect { |entry| 
				csv_line(month_range, entry, entries, arguments)
			}
		end
		def csv_line(month_range, entry, entries, arguments)
			line = [
				arguments[:iksnr].to_s,
				arguments[:name].to_s,
				arguments[:packagesize].to_s,
				entry.sender.to_s,
				entry.recipient.to_s,
				entries.size.to_s,
			]
			month = month_range.first
			while(month <= month_range.last)
				count = entries.select { |val| 
					val.time.year == month.year && val.time.mon == month.mon
				}.size
				line.push(count.to_s)
				month = month >> 1
			end
			line
		end
		def csv_lines(app)
			header = [
				"IKSNr.",
				"Name",
				"Packungsgrösse",
				"Sender",
				"Empfänger",
				"Total",
			]
			month_range = (first_month)..(last_month)
			month = month_range.first
			while(month <= month_range.last)
				header.push("#{month.strftime("%B")} #{month.year}")
				month = month >> 1
			end
			lines = []
			@logs.each { |key, entries| 
				iksnr = [key[0..4], key[5..8]]
				name = app.registration(iksnr[0]).package(iksnr[1]).name
				packagesize = app.registration(iksnr[0]).package(iksnr[1]).size
				arguments = {
					:name         => name,
					:packagesize  => packagesize,
					:iksnr        => key, 
					:entries  		=> entries, 
				}
				lines += range_lines(month_range, entries, arguments)
			}
			lines.sort.unshift(header)
		end
	end
end
