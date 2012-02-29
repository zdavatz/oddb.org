#!/usr/bin/env ruby
# encoding: utf-8
# 20120229

puts 'loading testenvironment'

module ODDB
	class App < SBSM::DRbServer
		puts "disabling UPDATER"
		remove_const :RUN_UPDATER
		RUN_UPDATER = false
	end
	class Log
		MAIL_TO = [
			'mhatakeyama@ywesee.com',
		]
	end
	remove_const :SERVER_NAME
	SERVER_NAME = 'oddb.masa.org'
	PAYPAL_SERVER = 'www.sandbox.paypal.com'
	PAYPAL_RECEIVER = 'mhatakeyama@ywesee.com'
	SMTP_SERVER = 'localhost'
	class Updater
		remove_const :RECIPIENTS
		RECIPIENTS = ['mhatakeyama@ywesee.com']
		remove_const :LOG_RECIPIENTS
		LOG_RECIPIENTS = {
			:powerlink				=>	[],
			:passthru					=>	[],	
			:sponsor_gcc			=>	[],	
			:sponsor_generika	=>	[],	
		}
	end
	class SwissmedicJournalPlugin < Plugin
		remove_const :RECIPIENTS
		RECIPIENTS = []
	end
	class OuwerkerkPlugin < Plugin
		remove_const :RECIPIENTS
		RECIPIENTS = [ ]
	end
	class Invoicer
		RECIPIENTS = [ 
			'mhatakeyama@ywesee.com', 
		]
	end
	class PatinfoInvoicer
		RECIPIENTS = [ 
			'mhatakeyama@ywesee.com', 
		]
	end
	class FachinfoInvoicer
		RECIPIENTS = [ 
			'mhatakeyama@ywesee.com', 
		]
	end
	class DownloadInvoicer 
		RECIPIENTS = [ 
			'mhatakeyama@ywesee.com', 
		]
	end
	class CsvExportPlugin < Plugin
		remove_const :ODDB_RECIPIENTS
    ODDB_RECIPIENTS = [ "mhatakeyama@ywesee.com" ]
		remove_const :ODDB_RECIPIENTS_EXTENDED
    ODDB_RECIPIENTS_EXTENDED = [ "mhatakeyama@ywesee.com" ]
  end
  class BsvXmlPlugin < Plugin
		remove_const :RECIPIENTS
		RECIPIENTS = [ ]
		remove_const :BSV_RECIPIENTS
		BSV_RECIPIENTS = [ 'mhatakeyama@ywesee.com' ]
  end
  class XlsExportPlugin < Plugin
		remove_const :RECIPIENTS
		RECIPIENTS = [ ]
  end
  module State
    class SuggestAddress < State::Global
      remove_const :RECIPIENTS
      RECIPIENTS = [ 'mhatakeyama@ywesee.com' ]
    end
    module Admin
      class Sequence
        remove_const :RECIPIENTS
        RECIPIENTS = [
          'mhatakeyama@ywesee.com'
        ]
      end
    end
  end
end
