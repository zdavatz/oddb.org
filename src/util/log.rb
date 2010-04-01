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
			'zdavatz@ywesee.com',
			'hwyss@ywesee.com',
		]
		include Persistence
		ODBA_SERIALIZABLE = ['@change_flags', '@pointers', '@recipients',
			'@files']
		attr_accessor :report, :pointers, :recipients, :change_flags, 
			:files, :parts, :date_str, :mail_from
		attr_reader :date

		def initialize(date)
			@date = date
			@report = ''
			@pointers = []
			@files = {}
			@parts = []
			@recipients = []
		end
		def notify(subject = nil, reply_to = nil)
			subj = [
				'ODDB Report', 
				subject, 
				(@date_str || @date.strftime('%m/%Y')),
			].compact.join(' - ')
			
			text = text_part(@report)

			parts = @parts.nil? ? [] : @parts.dup
			unless(@files.nil?)
				@files.each { |path, (mime, iconv)|
					begin
            content = File.read(path)
            if iconv
              content = Iconv.new(iconv, 'UTF-8').iconv content
            end
						parts.push([mime, File.basename(path), content])
					rescue Errno::ENOENT
					end
				}
			end
			outgoing = if(parts.empty?)
				text
			else
				multipart = TMail::Mail.new
				multipart.parts << text
				parts.each { |mime, name, content|
					mtype, stype = mime.split('/')
					multipart.parts << file_part(mtype, stype, name, content)
				}
				multipart
			end
			
			outgoing.from = @mail_from || self::class::MAIL_FROM
      if reply_to
        outgoing.reply_to = reply_to
      end
			@recipients = (@recipients + self::class::MAIL_TO).uniq
			outgoing.subject = subj
			outgoing.date = Time.now
			outgoing['User-Agent'] = 'ODDB Updater'

			send_mail(outgoing)
		end
		def notify_attachment(attachment, headers)
			multipart = TMail::Mail.new
			subject = headers[:subject]
			multipart.parts << text_part(subject)
			type1, type2 = (headers[:mime_type] || 'text/plain').split('/')
			multipart.parts << file_part(type1, type2, headers[:filename], attachment)
			multipart.from = @mail_from || self::class::MAIL_FROM
			@recipients = (@recipients + self::class::MAIL_TO).uniq
			multipart.to = @recipients
			multipart.subject = subject
			multipart.date = Time.now
			
			send_mail(multipart)
		end
		def text_part(body)
			text = TMail::Mail.new
			text.set_content_type('text', 'plain', 'charset'=>'UTF-8')
			text.body = body
			text
		end
		def send_mail(multipart)
      config = ODDB.config
      Net::SMTP.start(config.smtp_server, config.smtp_port, config.smtp_domain,
                      config.smtp_user, config.smtp_pass,
                      config.smtp_authtype) { |smtp|
				@recipients.each { |recipient|
					multipart.to = [recipient]
					smtp.sendmail(multipart.encoded, 
												@mail_from || config.smtp_user, recipient)
				}
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
