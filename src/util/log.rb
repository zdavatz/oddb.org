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
			
			text = text_part(@report)

			outgoing = if(@files.nil? || @files.empty?)
				text
			else
				multipart = TMail::Mail.new
				multipart.parts << text
				@files.each { |path, mime|
					begin
						mtype, stype = mime.split('/')
						multipart.parts << file_part(mtype, stype, File.basename(path), File.read(path))
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

			send_mail(multipart)
		end
		def notify_attachment(attachment, subject, type1, type2)
			multipart = TMail::Mail.new
			multipart.parts << text_part(subject)
			multipart.parts << file_part(type1, type2, 'notifications.csv', attachment)
			multipart.from = self::class::MAIL_FROM
			@recipients = (@recipients + self::class::MAIL_TO).uniq
			multipart.to = @recipients
			multipart.subject = subject
			multipart.date = Time.now
			
			send_mail(multipart)
		end
		def text_part(body)
			text = TMail::Mail.new
			text.set_content_type('text', 'plain', 'charset'=>'ISO-8859-1')
			text.body = body
			text
		end
		def send_mail(multipart)
			Net::SMTP.start(SMTP_SERVER) { |smtp|
				smtp.sendmail(multipart.encoded, self::class::MAIL_FROM, @recipients)
			}
		end
		def file_part(type1, type2, filename, attachment)
			file = TMail::Mail.new
			file.set_content_type(type1, type2, 'name' => filename)
			file.disposition = 'attachment'
			file.transfer_encoding = 'base64'
			file.body = [attachment].pack('m')
			file
		end
	end
end
