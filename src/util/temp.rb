#!/usr/bin/env ruby
# -- oddb -- 13.05.2003 -- hwyss@ywesee.com 

require 'date'

class Logarchive < Hash
	def update_from
		self.keys.max
	end
end

in class App
	logarchives = {
		"bsv"					=>	Logarchive.new
		"swissmedic"	=>	Logarchive.new
		"sl"					=>	Logarchive.new
	} 

# beim updaten3
def update_swissmedicjournal
	plug = SwissmedicJournalPlugin.new(@app)
	from = logarchives[swissmedic].update_from >> 1
	dates = alle daten von from bis Date.today
	dates.each { | date |
	plug.update_registrations(date)
	logarchives[swissmedic][date] = plug.report
}
end
