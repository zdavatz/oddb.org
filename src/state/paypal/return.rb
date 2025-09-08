#!/usr/bin/env ruby

# State::PayPal::Return -- ODDB -- 21.04.2005 -- hwyss@ywesee.com

require "state/global_predefine"
require "view/paypal/return"
require "delegate"

module ODDB
  module State
    module PayPal
      class Return < State::Global
        class InvoiceWrapper < SimpleDelegator
          attr_accessor :items
        end

        class ItemWrapper < SimpleDelegator
          attr_accessor :email, :oid
        end
        VIEW = View::PayPal::Return
        def init
          if @model
            invoice = @model
            @model = InvoiceWrapper.new(invoice)
            @model.items = invoice.items.values.collect { |item|
              wrap = ItemWrapper.new(item)
              wrap.email = invoice.yus_name
              wrap.oid = invoice.oid
              if item.type == :poweruser
                @session.yus_grant(invoice.yus_name, "login", "org.oddb.PowerUser", item.expiry_time)
                @session.yus_grant(invoice.yus_name, "view", "org.oddb", item.expiry_time)
                @session.yus_set_preference(invoice.yus_name, "poweruser_duration", invoice.max_duration)
              elsif item.type == :download
                @session.yus_grant(invoice.yus_name, "download", item.text, item.expiry_time)
              elsif item.type == :csv_export
                @session.yus_grant(invoice.yus_name, "download", item.text, item.expiry_time)
              else
                $stdout.puts "State::PayPal::Return unhandled type #{item.type}"
              end
              wrap
            }
          end
          @model.payment_received!
          reconsider_permissions(@session.user, self)
          super
        end

        def back
          @previous.previous if @previous.respond_to?(:previous)
        end

        def paypal_return
          if @model && @model.types.all? { |type| type == :poweruser } \
            && @model.payment_received? && (des = @session.desired_state)
            des
          else
            self
          end
        end
      end
    end
  end
end
