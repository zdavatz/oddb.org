#!/usr/bin/env ruby

# State::User::DownloadExport -- oddb -- 20.09.2004 -- mhuggler@ywesee.com

require "state/global_predefine"
require "state/user/checkout"
require "view/user/download_export"
require "model/invoice"

module ODDB
  module State
    module User
      class DownloadExport < State::User::Global
        VIEW = View::User::DownloadExport
        DIRECT_EVENT = :download_export
        ## Number of Days during which a paid file may be downloaded
        def self.duration(file)
          DOWNLOAD_EXPORT_DURATIONS[fuzzy_key(file)].to_i
        end

        def self.fuzzy_key(file)
          DOWNLOAD_EXPORT_PRICES.each_key { |key|
            if file.index(key)
              return key
            end
          }
          nil
        end

        def self.price(file)
          DOWNLOAD_EXPORT_PRICES[fuzzy_key(file)].to_f
        end

        def self.subscription_duration(file)
          DOWNLOAD_EXPORT_SUBSCRIPTION_DURATIONS[fuzzy_key(file)].to_i
        end

        def self.subscription_price(file)
          DOWNLOAD_EXPORT_SUBSCRIPTION_PRICES[fuzzy_key(file)].to_f
        end
      end
    end
  end
end
