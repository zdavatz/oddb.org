#!/usr/bin/env ruby
# Log -- oddb -- 23.05.2003 -- hwyss@ywesee.com 

require 'util/persistence'
require 'cgi'
require 'date'
#require 'net/smtp'
require 'tmail'
require 'plugin/patinfo'

module ODDB
	class Log
		MAIL_FROM = 'update@oddb.org'
		MAIL_TO = [
			'hwyss@ywesee.com',
			'zdavatz@ywesee.com', 
			'mwalder@ywesee.com', 
			'rwaltert@ywesee.com'
		]
		include Persistence
		ODBA_SERIALIZABLE = ['@change_flags', '@pointers', '@recipients',
			'@files']
		attr_accessor :report, :pointers, :recipients, :change_flags, :files
		attr_accessor :date_str
		attr_reader :date
		def initialize(date)
			@date = date
			@report = ''
			@pointers = []
			@files = {}
			@recipients = []
		end
		def notify(subject = nil)
			subj = [
				'ODDB Report', 
				subject, 
				(@date_str || @date.strftime('%m/%Y')),
			].compact.join(' - ')
		
			
			text = TMail::Mail.new
			text.set_content_type('text', 'plain', 'charset'=>'ISO-8859-1')
			text.body = @report

			outgoing = if(@files.nil? || @files.empty?)
				text
			else
				multipart = TMail::Mail.new
				multipart.parts << text
				@files.each { |path, mime|
					begin
						file = TMail::Mail.new
						mtype, stype = mime.split('/')
						file.set_content_type(mtype, stype, 'name'=>File.basename(path))
						file.disposition = 'attachment'
						file.transfer_encoding = 'base64'
						file.body = [File.read(path)].pack('m')
						multipart.parts << file
					rescue Errno::ENOENT
					end
				}
				multipart
			end
			
			outgoing.from = self::class::MAIL_FROM
			@recipients = (@recipients + self::class::MAIL_TO).uniq
			outgoing.to = @recipients
			outgoing.subject = subj
			outgoing.date = Time.now
			outgoing['User-Agent'] = 'ODDB Updater'

			Net::SMTP.start('mail.ywesee.com') { |smtp|
				smtp.sendmail(outgoing.encoded, self::class::MAIL_FROM, @recipients)
			}
		end
	end
end
