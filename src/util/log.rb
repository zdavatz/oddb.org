#!/usr/bin/env ruby
# encoding: utf-8
# Log -- oddb -- 23.05.2003 -- hwyss@ywesee.com 

require 'util/persistence'
require 'config'
require 'cgi'
require 'date'
require 'util/mail'

module ODDB
	class Log
		include Persistence
		ODBA_SERIALIZABLE = ['@change_flags', '@pointers', '@recipients',
			'@files']
		attr_accessor :report, :pointers, :recipients, :change_flags, 
			:files, :parts, :date_str
		attr_reader :date
    LOG_RECIPIENTS = 'log'
		def initialize(date)
			@date = date
			@report = ''
			@pointers = []
			@files = {}
			@parts = []
			@recipients = []
		end
		def notify(subject = nil)
      LogFile.append('oddb/debug', " start outgoing process", Time.now)
			subj = [
				'ch.ODDB.org Report', 
				subject, 
				(@date_str || @date.strftime('%m/%Y')),
			].compact.join(' - ')
      attachments = []
      @files.each { |path, (mime, iconv)|
        begin
          content = File.read(path)
          if iconv
            content = Iconv.new(iconv, 'UTF-8').iconv content
          end
          attachments << { :filename => File.basename(path), :mime_type => mime, :content => content }
        rescue Errno::ENOENT => e
          LogFile.append('oddb/debug', " " + e.inspect.to_s + "\n" + e.backtrace.inspect.to_s, Time.now)
        end
      }
      if attachments.size > 0
        Util.send_mail_with_attachments(@recipients, subj, @report, attachments)
      else
        Util.send_mail(@recipients, subj, @report, ODDB::Util.mail_from)
      end
		end
	end
end
