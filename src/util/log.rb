#!/usr/bin/env ruby
# encoding: utf-8
# Log -- oddb -- 23.05.2003 -- hwyss@ywesee.com 

require 'util/persistence'
require 'config'
require 'cgi'
require 'date'
require 'mail'

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
      LogFile.append('oddb/debug', " getin Log.notify (SL-Update)", Time.now) if subject =~ /SL-Update/

			subj = [
				'ch.ODDB.org Report', 
				subject, 
				(@date_str || @date.strftime('%m/%Y')),
			].compact.join(' - ')

			text = text_part(@report)

			parts = @parts.nil? ? [] : @parts.dup
      LogFile.append('oddb/debug', " @files=" + @files.inspect.to_s, Time.now)
			unless(@files.nil?)
				@files.each { |path, (mime, iconv)|
					begin
            content = File.read(path)
            if iconv
              content = Iconv.new(iconv, 'UTF-8').iconv content
            end
						parts.push([mime, File.basename(path), content])
					#rescue Errno::ENOENT
					rescue Errno::ENOENT => e
            LogFile.append('oddb/debug', " " + e.inspect.to_s + "\n" + e.backtrace.inspect.to_s, Time.now)
					end
				}
			end
      LogFile.append('oddb/debug', " start outgoing process", Time.now)
			outgoing = if(parts.empty?)
				text
			else
				multipart = Mail.new
				multipart.parts << text
				parts.each { |mime, name, content|
          multipart.attachments[name] = {:mime_type => mime, :content => content}
				}
				multipart
			end
			
			outgoing.from = @mail_from || self::class::MAIL_FROM
      if reply_to
        outgoing.reply_to = reply_to
      end
      LogFile.append('oddb/debug', " @recipients=" + @recipients.inspect.to_s, Time.now)
      LogFile.append('oddb/debug', " self::class::MAIL_TO=" + self::class::MAIL_TO.to_s, Time.now)
      LogFile.append('oddb/debug', " self::class=" + self::class.to_s, Time.now)
			@recipients = (@recipients + self::class::MAIL_TO).uniq
			outgoing.subject = subj
			outgoing.date = Time.now
			outgoing['User-Agent'] = 'ODDB Updater'

      LogFile.append('oddb/debug', " before send_mail(outgoing)", Time.now)
			send_mail(outgoing)
		end
		def notify_attachment(attachment, headers)
			multipart = Mail.new
			subject = headers[:subject]
			multipart.parts << text_part(subject)
			mime = (headers[:mime_type] || 'text/plain')
      multipart.attachments[headers[:filename]] = {:mime_type => mime, :content => attachment}
      # This is also fine. but the full file path is necessary
      #multipart.add_file('/home/masa/work/test.xls')
			multipart.from = @mail_from || self::class::MAIL_FROM
			@recipients = (@recipients + self::class::MAIL_TO).uniq
			multipart.to = @recipients
			multipart.subject = subject
			multipart.date = Time.now
			
			send_mail(multipart)
		end
		def text_part(body)
			text = Mail::Part.new
      text.body = body
			text
		end
		def send_mail(multipart)
      LogFile.append('oddb/debug', " getin send_mail", Time.now)
      LogFile.append('oddb/debug', " @recipients=" + @recipients.inspect.to_s, Time.now)

      config = ODDB.config
      LogFile.append('oddb/debug', " config.smtp_server=" + config.smtp_server.inspect.to_s, Time.now)
      LogFile.append('oddb/debug', " config.smtp_port=" + config.smtp_port.inspect.to_s, Time.now)
      LogFile.append('oddb/debug', " config.smtp_domain=" + config.smtp_domain.inspect.to_s, Time.now)
      LogFile.append('oddb/debug', " config.smtp_user=" + config.smtp_user.inspect.to_s, Time.now)
      LogFile.append('oddb/debug', " config.smtp_pass=" + config.smtp_pass.inspect.to_s, Time.now)
      LogFile.append('oddb/debug', " config.smtp_authtype=" + config.smtp_authtype.inspect.to_s, Time.now)
      Net::SMTP.start(config.smtp_server, config.smtp_port, config.smtp_domain,
                      config.smtp_user, config.smtp_pass,
                      config.smtp_authtype) { |smtp|
      LogFile.append('oddb/debug', " getin Net::SMTP", Time.now)
        
				@recipients.each { |recipient|
          LogFile.append('oddb/debug', " recipient=" + recipient.to_s, Time.now)
					multipart.to = [recipient]
					smtp.sendmail(multipart.encoded, 
												@mail_from || config.smtp_user, recipient)
				}
			}
		end
	end
end
