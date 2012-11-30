#!/usr/bin/env ruby
# encoding: utf-8
# 20121130

# Please set your environments
host  = ''
mail = ''
# default
DEVELOPER_HOST = (host.empty? ? "ch.oddb.#{ENV['USER']}.org" : host)
DEVELOPER_MAIL = (mail.empty? ? `git config --get user.email`.chomp : mail)

puts
puts "loading testenvironment"
puts
puts "DEVELOPER_HOST = #{DEVELOPER_HOST}"
puts "DEVELOPER_MAIL = #{DEVELOPER_MAIL}"
puts

module ODDB
  {
    :SERVER_NAME     => DEVELOPER_HOST,
    :SMTP_SERVER     => 'localhost',
    :PAYPAL_SERVER   => 'www.sandbox.paypal.com',
    :PAYPAL_RECEIVER => DEVELOPER_MAIL,
  }.each_pair do |const, value|
    remove_const const
    const_set const, value
  end
  class App < SBSM::DRbServer
    remove_const :RUN_UPDATER
    RUN_UPDATER = false
    puts "disabling UPDATER"
  end
  class Log
    remove_const :MAIL_TO
    MAIL_TO = [ DEVELOPER_MAIL ]
  end
  class Updater
    remove_const :RECIPIENTS
    RECIPIENTS = [ DEVELOPER_MAIL ]
    remove_const :LOG_RECIPIENTS
    LOG_RECIPIENTS = {
      :powerlink        =>  [],
      :passthru         =>  [],
      :sponsor_gcc      =>  [],
      :sponsor_generika =>  [],
    }
  end
  class SwissmedicJournalPlugin < Plugin
    remove_const :RECIPIENTS
    RECIPIENTS = [ DEVELOPER_MAIL ]
  end
  class OuwerkerkPlugin < Plugin
    remove_const :RECIPIENTS
    RECIPIENTS = [ DEVELOPER_MAIL ]
  end
  class Invoicer
    remove_const :RECIPIENTS
    RECIPIENTS = [ DEVELOPER_MAIL ]
  end
  class PatinfoInvoicer
    RECIPIENTS = [ DEVELOPER_MAIL ]
  end
  class FachinfoInvoicer
    RECIPIENTS = [ DEVELOPER_MAIL ]
  end
  class DownloadInvoicer
    RECIPIENTS = [ DEVELOPER_MAIL ]
  end
  class CsvExportPlugin < Plugin
    remove_const :ODDB_RECIPIENTS
    ODDB_RECIPIENTS = [ DEVELOPER_MAIL ]
    remove_const :ODDB_RECIPIENTS_EXTENDED
    ODDB_RECIPIENTS_EXTENDED = [ DEVELOPER_MAIL ]
  end
  class BsvXmlPlugin < Plugin
    remove_const :RECIPIENTS
    RECIPIENTS = [ DEVELOPER_MAIL ]
    remove_const :BSV_RECIPIENTS
    BSV_RECIPIENTS = [ DEVELOPER_MAIL ]
  end
  class XlsExportPlugin < Plugin
    remove_const :RECIPIENTS
    RECIPIENTS = [ DEVELOPER_MAIL ]
  end
  module State
    class SuggestAddress < State::Global
      remove_const :RECIPIENTS
      RECIPIENTS = [ DEVELOPER_MAIL ]
    end
    module Admin
      class Sequence
        remove_const :RECIPIENTS
        RECIPIENTS = [ DEVELOPER_MAIL ]
      end
    end
  end
end
