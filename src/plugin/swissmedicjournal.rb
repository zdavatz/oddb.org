#!/usr/bin/env ruby
# SwissmedicJournalPlugin -- oddb -- 19.02.2003 -- hwyss@ywesee.com 

require 'date'
require 'plugin/plugin'
require 'mechanize'

module ODDB
	class SwissmedicJournalPlugin < Plugin
		RECIPIENTS = [
			'matthijs.ouwerkerk@just-medical.com',
		]
		def report
			atcless = @app.atcless_sequences.collect { |sequence|
				resolve_link(sequence.pointer)	
			}.sort
			lines = [
				"ODDB::SwissmedicJournalPlugin - Report #{@month}",
				"Total Sequences without ATC-Class: #{atcless.size}",
				atcless,
			]
			lines.flatten.join("\n")
		end
		def update(month)
      agent = Mechanize.new
      main = agent.get 'http://www.swissmedic.ch/org/00064/00065/index.html'
      link = main.links.find do |node|
        /Swissmedic\s*Journal/iu.match node.attributes['title']
      end or raise 'unable to identify url for Swissmedic-Journal'
      smj = link.click

      latest = File.join(ARCHIVE_PATH, 'pdf', 'Swissmedic-Journal-latest.pdf')
      unless File.exist?(latest) && File.read(latest) == smj.body
        filename = month.strftime('%m_%Y.pdf')
        target = File.join(ARCHIVE_PATH, 'pdf', filename)
        if File.exist?(target) && File.read(target) != smj.body
          raise "Safety-catch: cannot overwrite #{target} with data from #{link.attributes['href']}"
        end
        smj.save latest
        smj.save target
      end
    rescue Mechanize::ResponseCodeError
		end
	end
end
