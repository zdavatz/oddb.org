#!/usr/bin/env ruby
# encoding: utf-8
# Small helper class to unify sending mails
require 'mail'
require 'util/config'

module ODDB
  module Util
		# one time initialisation for delivering according to setup in etc/oddb.yml
		@mail_configured = false
		def Util.configure_mail
			return if @mail_configured
			# config = defined?(ODDB.config) ? ODDB.config : ODDB::Config.new
			config = ODDB.config
			Mail.defaults do
				delivery_method :smtp, {
					:address => config.smtp_server,
					:port => config.smtp_port,
					:domain => config.smtp_domain,
					:user_name => config.smtp_user,
					:password => config.smtp_pass,
					:authentication => defined?(config.smtp_auth) ? config.smtp_auth : nil,
				}
			end
			system("logger '#{__FILE__}: Configured email using #{config.class}'")
			@mail_configured = true
		end

		# Parts must be of form content_type => body, e.g. 'text/html; charset=UTF-8' => '<h1>This is HTML</h1>'
		def Util.send_mail(recipients, mail_subject, mail_body, override_from = nil, parts = {})
			if ODDB.config.testenvironment1 and File.exist?(ODDB.config.testenvironment1)
				recipients = ODDB::State::Admin::Sequence::RECIPIENTS
			end
			Util.configure_mail
			config = ODDB::Config.new
			config = ODDB.config
			res = Mail.deliver do
				from    override_from ? override_from : config.mail_from
				to      recipients
				subject mail_subject
				body    mail_body
				parts.each { |part_type, part_body|
					html_part do
						content_type part_type
						body         part_body
					end
				}
			end
			msg = "#{__FILE__}: send_mail to #{recipients} #{mail_subject} res #{res.inspect}"
			system("logger '#{msg}'")
			'sendmail'
		end
	end
end