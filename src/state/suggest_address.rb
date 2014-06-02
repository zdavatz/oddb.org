#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::SuggestAddress -- oddb.org -- 19.12.2011 -- mhatakeyama@ywesee.com
# ODDB::State::SuggestAddress -- oddb.org -- 04.08.2005 -- jlang@ywesee.com

require 'view/suggest_address'
require 'state/suggest_address_confirm'
require 'util/mail'

module ODDB
	module State
		class SuggestAddress < State::Global
			VIEW = View::SuggestAddress
			def address_send
				if(sugg = save_suggestion)
					send_notification(sugg)
					AddressConfirm.new(@session, sugg)
				end
			end
			def save_suggestion
				pointer = Persistence::Pointer.new(:address_suggestion)
				mandatory = [:name, :email]
				keys = [:additional_lines, :address, :location,
					:fon, :fax, :title, :canton, :message, 
					:address_type, :email_suggestion] + mandatory
				input = user_input(keys, mandatory)
				input[:fax] = input[:fax].to_s.split(/\s*,\s*/u)
				input[:fon] = input[:fon].to_s.split(/\s*,\s*/u)
        if msg = input[:message]
          input[:message] = msg[0,500]
        end
				lns = input[:additional_lines].to_s
				input.store(:additional_lines, 
					lns.split(/[\n\r]+/u))
				input.store(:type, input.delete(:address_type))
				input.store(:address_pointer, @model.pointer)
				input.store(:address_instance, @model)
        @parent = if ean_or_oid = @session.persistent_user_input(:oid) and parent = (@session.search_doctor(ean_or_oid) || @session.search_doctors(ean_or_oid).first) 
                   parent
                 elsif ean = @session.persistent_user_input(:ean) and parent = @session.search_hospital(ean)
                   parent
                 else
                   @model.parent(@session)
                 end
        input.store(:parent, @parent)
				input.store(:fullname, @parent.fullname)
				input.store(:time, Time.now)
				unless error?
					@session.set_cookie_input(:email, input[:email])
					addr_sugg = @session.app.update(pointer.creator, input, unique_email)
          @url = if @parent.is_a?(ODDB::Doctor)
                  @session.lookandfeel._event_url(:address_suggestion, [:doctor, (@parent.ean13 || @parent.oid), :oid, addr_sugg.oid])
                elsif @parent.is_a?(ODDB::Hospital)
                  @session.lookandfeel._event_url(:address_suggestion, [:hospital, @parent.ean13, :oid, addr_sugg.oid])
                else
                  @session.lookandfeel._event_url(:resolve, {:pointer => addr_sugg.pointer})
                end
          input.store(:url, @url)
					@session.app.update(pointer, input, unique_email)
				end
			end
			def send_notification(suggestion)
				Util.send_mail('suggest_address',
				              "#{@session.lookandfeel.lookup(:address_subject)} #{suggestion.fullname}",
				              [ @url, ].join("\n"),
				              suggestion.email_suggestion
				             )
			end
		end
	end
end
