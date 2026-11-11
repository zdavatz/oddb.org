#!/usr/bin/env ruby

# A delivery method for the mail gem that sends through the Gmail REST API.
#
# Until 11.11.2026 every report mail of the application went out by SMTP
# through smtp.gmail.com as admin@ywesee.com with a stored password. That
# morning Gmail answered "535-5.7.8 Username and Password not accepted",
# and the FI/PI and drug shortage reports were lost - the jobs themselves ran.
# The OAuth refresh token that bin/oddb_mail already uses (gmail.compose,
# which includes sending) does not depend on a password.
#
# Switched on by `mail_delivery: gmail_api` in etc/oddb.yml. With
# gmail_send_mailbox and gmail_send_refresh_token (bin/oddb_mail authorize
# --send=admin@oddb.org) the mails go out of that mailbox; without them out
# of gmail_draft_mailbox with the drafts token. Gmail sends as the
# authenticated mailbox: a From of admin@ywesee.com is kept only if that
# address is a "send mail as" alias of the mailbox, otherwise Gmail puts the
# mailbox address there.

require "util/gmail_api"

module ODDB
  class GmailApiDelivery
    attr_accessor :settings

    def initialize(settings = {})
      @settings = settings
    end

    def deliver!(mail)
      api = (settings[:api_factory] || ->(box) { GmailApi.new(box, nil, nil, settings[:refresh_token]) }).call(settings[:mailbox])
      id = api.send_raw(mail.encoded)
      mail.message_id ||= id
      id
    end
  end
end
