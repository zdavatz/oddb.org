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
		MAIL_FROM = 'update@oddb.org'
		MAIL_TO = [
			'zdavatz@ywesee.com',
			'yasaka@ywesee.com',
		]
		include Persistence
		ODBA_SERIALIZABLE = ['@change_flags', '@pointers', '@recipients',
			'@files']
		attr_accessor :report, :pointers, :recipients, :change_flags, 
			:files, :parts, :date_str, :mail_from, :mail_to
		attr_reader :date

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
        Util.send_mail_with_attachments(subj, @report, attachments)
      else
        Util.send_mail(@recipients, subj, @report, @mail_from || self::class::MAIL_FROM)
      end
		end
	end
end
