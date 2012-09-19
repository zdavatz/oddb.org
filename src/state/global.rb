#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Global -- oddb.org -- 21.09.2012 -- yasaka@ywesee.com
# ODDB::State::Global -- oddb.org -- 14.02.2012 -- mhatakeyama@ywesee.com
# ODDB::State::Global -- oddb.org -- 25.11.2002 -- hwyss@ywesee.com

require 'htmlgrid/urllink'
require 'state/http_404'
require 'state/admin/login'
require 'state/ajax/ddd_price'
require 'state/ajax/ddd_chart'
require 'state/ajax/matches'
require 'state/ajax/swissmedic_cat'
require 'state/analysis/init'
require 'state/analysis/group'
require 'state/analysis/position'
require 'state/analysis/alphabetical'
require 'state/analysis/result'
require 'state/analysis/limitationtext'
require 'state/companies/company'
require 'state/companies/companylist'
require 'state/drugs/atcchooser'
require 'state/drugs/api_search'
require 'state/drugs/compare'
require 'state/drugs/compare_search'
require 'state/drugs/ddd'
require 'state/drugs/ddd_price'
require 'state/drugs/fachinfo'
require 'state/drugs/fachinfo_search'
require 'state/drugs/fachinfos'
require 'state/drugs/feedbacks'
require 'state/drugs/minifi'
require 'state/drugs/notify'
require 'state/drugs/package'
require 'state/drugs/register_download'
require 'state/drugs/registration'
require 'state/drugs/init'
require 'state/drugs/limitationtext'
require 'state/drugs/limitationtexts'
require 'state/drugs/vaccines'
require 'state/admin/orphaned_patinfos'
require 'state/admin/orphaned_patinfo'
require 'state/admin/patinfo_deprived_sequences'
require 'state/admin/password_lost'
require 'state/admin/password_reset'
require 'state/drugs/patinfo'
require 'state/drugs/patinfos'
require 'state/drugs/price_history'
require 'state/drugs/recentregs'
require 'state/drugs/result'
require 'state/drugs/prescription'
require 'state/drugs/sequence'
require 'state/drugs/sequences'
require 'state/drugs/shorten_path'
require 'state/drugs/narcotics'
require 'state/drugs/photo'
require 'state/doctors/init'
require 'state/hospitals/init'
require 'state/doctors/doctorlist'
require 'state/hospitals/hospitallist'
require 'state/drugs/patinfo'
require 'state/exception'
require 'state/interactions/basket'
require 'state/interactions/init'
require 'state/interactions/result'
require 'state/interactions/interactions'
require 'state/migel/init'
require 'state/migel/alphabetical'
require 'state/migel/limitationtext'
require 'state/migel/group'
require 'state/migel/subgroup'
require 'state/migel/product'
require 'state/migel/notify'
require 'state/migel/feedbacks'
require 'state/migel/items'
require 'state/substances/init'
require 'state/substances/result'
require 'state/suggest_address'
require 'state/user/download'
require 'state/user/download_item'
require 'state/user/download_export'
require 'state/user/fipi_offer_input'
require 'state/user/fipi_offer_confirm'
require	'state/user/help'
require 'state/user/mailinglist'
require 'state/user/passthru'
require 'state/user/register_poweruser'
require 'state/paypal/return'
require 'state/rss/passthru'
require 'state/user/paypal_thanks'
require 'state/user/powerlink'
require 'state/user/plugin'
require 'state/user/init'
require 'state/user/sponsorlink'
require 'util/umlautsort'
require 'sbsm/state'


module ODDB
  module State
    class Global < SBSM::State
      class StubProduct
        attr_reader :items
        def initialize(items)
          @items = items
        end
      end
      class StubItems
        def initialize(product, sortvalue = nil, reverse = nil)
          if product and items = product.items
            @sortvalue = sortvalue
            @list = items.values
            @reverse = reverse
          else
            @list = []
          end
        end
        def empty?
          @list.empty?
        end
        def sort_by(&block)
          # This is called at the first time when a search result is shown
          @list.sort_by(&block)
        end
        def sort!
          # This is called when a header key is clicked
          @list.sort! do |a,b|
            yield(a,b)
          end
        end
        def reverse!
          @list.reverse!
        end
        def each_with_index
          @list.each_with_index do |record, i|
            yield(record, i)
          end
        end
        def each
          @list.each do |record|
            yield record
          end
        end
        def first
          @list.first
        end
        def at(index)
          @list[index]
        end
        def length
          @list.length
        end
        def [](*args)
          @list[*args]
        end
      end

      include UmlautSort
      include Admin::LoginMethods
        attr_reader :model, :snapback_model
        DIRECT_EVENT = nil
        GLOBAL_MAP = {
          :ajax_ddd_price         => State::Ajax::DDDPrice,
          :ajax_matches           => State::Ajax::Matches,
          :ajax_swissmedic_cat    => State::Ajax::SwissmedicCat,
          :api_search             => State::Drugs::ApiSearch,
          :analysis_alphabetical  => State::Analysis::Alphabetical,
          :data                   => State::User::DownloadItem,
          :companylist            => State::Companies::CompanyList,
          :compare                => State::Drugs::Compare,
          :compare_search         => State::Drugs::CompareSearch,
          :ddd                    => State::Drugs::DDD,
          :ddd_chart              => State::Ajax::DDDChart,
          :ddd_price              => State::Drugs::DDDPrice,
          :download_export        => State::User::DownloadExport,
          :fachinfo_search        => State::Drugs::FachinfoSearch,
          :fachinfos              => State::Drugs::Fachinfos,
          :fipi_offer_input       => State::User::FiPiOfferInput,
          :help                   => State::User::Help,
          :home                   => State::Drugs::Init,
          :home_admin             => State::Admin::Init,
          :home_analysis          => State::Analysis::Init,
          :home_companies         => State::Companies::Init,
          :home_doctors           => State::Doctors::Init,
          :home_hospitals         => State::Hospitals::Init,
          :home_drugs             => State::Drugs::Init,
          :home_interactions      => State::Interactions::Init,
          :home_migel             => State::Migel::Init,
          :home_substances        => State::Substances::Init,
          :home_user              => State::User::Init,
          :hospitallist           => State::Hospitals::HospitalList,
          :limitation_text        => State::Drugs::LimitationText,
          :limitation_texts       => State::Drugs::LimitationTexts,
          :limitation_analysis    => State::Analysis::LimitationText,
          :listed_companies       => State::Companies::CompanyList,
          :login_form             => State::Admin::Login,
          :mailinglist            => State::User::MailingList,
          :migel_alphabetical     => State::Migel::Alphabetical,
          :minifi                 => State::Drugs::MiniFi,
          :password_lost          => State::Admin::PasswordLost,
          :patinfos               => State::Drugs::Patinfos,
          :foto                   => State::Drugs::Photo,
          :narcotics              => State::Drugs::Narcotics,
          :plugin                 => State::User::Plugin,
          :passthru               => State::User::PassThru,
          :paypal_thanks          => State::User::PayPalThanks,
          :price_history          => State::Drugs::PriceHistory,
          :recent_registrations   => State::Drugs::RecentRegs,
          :rezept                 => State::Drugs::Prescription,
          :sequences              => State::Drugs::Sequences,
          :shorten_path           => State::Drugs::ShortenPath,
          :vaccines               => State::Drugs::Vaccines,
        }	
        HOME_STATE = State::Drugs::Init
        LIMITED = false
        RESOLVE_STATES = {
          [ :analysis_group, :position ]                                      => State::Analysis::Position,
          [ :analysis_group ]                                                 => State::Analysis::Group,
          [ :company ]                                                        => State::Companies::Company,
          [ :doctor ]                                                         => State::Doctors::Doctor,
          [ :hospital ]                                                       => State::Hospitals::Hospital,
          [ :fachinfo ]                                                       => State::Drugs::Fachinfo,
          [ :foto ]                                                           => State::Drugs::Photo,
          [ :registration, :sequence, :package, :sl_entry, :limitation_text ] => State::Drugs::LimitationText,
          [ :migel_group, :subgroup, :product ]                               => State::Migel::Product,
          [ :migel_group, :subgroup]                                          => State::Migel::Subgroup,
          [ :migel_group]                                                     => State::Migel::Group,
          [ :migel_group, :subgroup, :product, :limitation_text ]             => State::Migel::LimitationText,
          [ :migel_group, :subgroup, :limitation_text ]                       => State::Migel::LimitationText,
          [ :migel_group, :limitation_text ]                                  => State::Migel::LimitationText,
          [ :minifi ]                                                         => State::Drugs::MiniFi,
          [ :patinfo ]                                                        => State::Drugs::Patinfo,
          [ :rezept ]                                                         => State::Drugs::Prescription,
        }	
        READONLY_STATES = RESOLVE_STATES.dup.update({
          [ :registration ]                       => State::Drugs::Registration,
          [ :registration, :sequence, ]           => State::Drugs::Sequence,
          [ :registration, :sequence, :package ]  => State::Drugs::Package, 
        })
        PRINT_STATES = {
          [ :fachinfo ]                           => State::Drugs::FachinfoPrint,
          [ :patinfo ]                            => State::Drugs::PatinfoPrint,
          [ :rezept ]                             => State::Drugs::PrescriptionPrint,
        }
        REVERSE_MAP = {}
        VIEW = View::Search
        ZONE_NAVIGATION = []

        # If the URL contains old pointer link then go to the latest view in the session.
        # Once the Internet start to forget the old pointer links, this is not needed anymore.
        class << self
          def skip_event_pointer_link(global_map_event)
            global_map_event.each do |event, state|
              define_method(event) do
                if @session.user_input(:pointer)
                  self
                else
                  state.new(@session, @model)
                end
              end
            end
          end
        end
        skip_event_pointer_link(GLOBAL_MAP)
			def add_to_interaction_basket
				pointer = @session.user_input(:pointer)
				if(object = pointer.resolve(@session.app))
					@session.add_to_interaction_basket(object)
				end
				self
			end
			def allowed?(test = @model)
				if(test.is_a?(Persistence::CreateItem)) 
					test = test.parent(@session.app)
				end
				@session.allowed?('edit', test)
			end
			def atc_chooser
				mdl = @session.app.atc_chooser
				State::Drugs::AtcChooser.new(@session, mdl)
			end
      def atc_class
        if model = @session.app.atc_class(@session.user_input(:atc_code))
          if @session.allowed?('edit', 'org.oddb.model.!atc_class.*')
            State::Admin::AtcClass.new(@session, model)
          else
            State::Admin::TransparentLogin.new(@session, model)
          end
        end
      end
			def checkout
				case @session.zone
				when :user
					proceed_download.checkout
				when :drugs
					export_csv.checkout
				end
			end
      def company
        if (oid = @session.user_input(:oid) and model = @session.app.company(oid)) \
          or (ean = @session.user_input(:ean) and model = @session.search_companies(ean).sort_by{|c| c.oid.to_i}.last)
            State::Companies::Company.new(@session, model)
        end
      end
			def clear_interaction_basket
				@session.clear_interaction_basket
				State::Interactions::EmptyBasket.new(@session, [])
			end
      def interactions
        State::Interactions::Interactions.new(@session, [])
      end
      def interaction_detail
        State::Interactions::InteractionDetail.new(@session, [])
      end
			def creditable?(item = @model)
				@session.user.creditable?(item)
			end
			def direct_request_path
				if(event = self.direct_event)
					@session.lookandfeel._event_url(event)
				else
					self.request_path
				end
			end
			def doctorlist
				model = @session.doctors.values
				State::Doctors::DoctorList.new(@session, model)
			end
			def download
				if(@session.is_crawler?)
					return State::Drugs::Init.new(@session, nil)
				end
				email = @session.user_input(:email)
				email ||= @session.get_cookie_input(:email)
				oid = @session.user_input(:invoice)
				file = @session.user_input(:filename)
				if((invoice = @session.invoice(oid)) \
          && invoice.yus_name == email \
					&& invoice.payment_received? \
					&& (item = invoice.item_by_text(file)) \
					&& !item.expired?)
					State::User::Download.new(@session, item)
				else
					State::PayPal::Return.new(@session, invoice)
				end
			end
      def hospital
        if ean = @session.user_input(:ean) and model = @session.app.hospital(ean)
          State::Hospitals::Hospital.new(@session, model)
        end
      end
			def hospitallist
				model = @session.hospitals.values
				State::Hospitals::HospitalList.new(@session, model)
			end
			def export_csv
				if(@session.zone == :drugs)
					state = self.search
					if(state.is_a?(State::Drugs::Result))
						state.export_csv
					end
				end
			end
			def extend(mod)
				if(mod.constants.include?('VIRAL'))
					@viral_module = mod 
				end
				super
			end
      def fachinfo
        if (iksnr = @session.user_input(:reg) || @session.user_input(:swissmedicnr)) \
          && (reg = @session.app.registration(iksnr)) \
          && fachinfo = reg.fachinfo
          if @session.allowed?('edit', fachinfo)
            State::Drugs::RootFachinfo.new(@session, fachinfo)
          else
            State::Drugs::Fachinfo.new(@session, fachinfo)
          end
        else
          Http404.new(@session, nil)
        end
      end
      def patinfo
        if (iksnr = @session.user_input(:reg) || @session.user_input(:swissmedicnr)) \
          && (seqnr = @session.user_input(:seq)) \
          && (reg = @session.app.registration(iksnr)) \
          && (seq = reg.sequence(seqnr)) \
          && (patinfo = seq.patinfo) \
          && (!patinfo.descriptions.empty?)
          State::Drugs::Patinfo.new(@session, patinfo)
        else
          Http404.new(@session, nil)
        end
      end
			def feedbacks
        if @session.user_input(:pointer)
          self
        else
          iksnr = @session.user_input(:reg)
          seqnr = @session.user_input(:seq)
          ikscd = @session.user_input(:pack)
          if reg = @session.app.registration(iksnr) and seq = reg.sequence(seqnr) and pack = seq.package(ikscd)
            State::Drugs::Feedbacks.new(@session, pack)
          #elsif migel_code = @session.user_input(:migel_product) and migel_product = @session.search_migel_products(migel_code).first
            # Actually, migel_product is an instance of Migel::Model::Migelid
          #  State::Migel::Feedbacks.new(@session, migel_product)
          end
        end
			end
			def help_navigation
				[
					:help_link,
					:faq_link,
				]
			end
			def home_navigation
				[
					self.home_state
				]
			end
			def home_state
				self::class::HOME_STATE
			end
			def interaction_basket
				if((array = @session.interaction_basket).empty?)
					State::Interactions::EmptyBasket.new(@session, array)
				else
					State::Interactions::Basket.new(@session, array)
				end
			end
			def limited?
				self.class.const_get(:LIMITED)
			end
			def limit_state
				State::User::Limit.new(@session, nil)
			end
			def logout
				user = @session.logout
				nextstate = State::Drugs::Init.new(@session, user)
        location = nextstate.request_path
        if location.nil?
          location = '/'
        end
        nextstate.http_headers = {
          'Status'   => '303 See Other',
          'Location' => location
        }
        nextstate
			end
			def navigation
				#+ zone_navigation \
				help_navigation \
				+ user_navigation \
				+ home_navigation
			end
			def password_reset
				keys = [:token, :email]
				input = user_input(keys, keys)
				unless(error?)
          email = input[:email]
          token = input[:token]
					if(@session.yus_allowed?(email, 'reset_password', token))
            model = OpenStruct.new
            model.token = token
            model.email = email
						State::Admin::PasswordReset.new(@session, model)
					end
				end
			end
			def paypal_return
				if(@session.is_crawler?)
					State::Drugs::Init.new(@session, nil)
				elsif((id = @session.user_input(:invoice)) \
					&& (invoice = @session.invoice(id)))
          state = State::PayPal::Return.new(@session, invoice)
					if(invoice.types.all? { |type| type == :poweruser } \
						&& @session.allowed?('view', 'org.oddb') \
						&& (des = @session.desired_state))
            # since the permissions of the current User may have changed, we
            # need to reconsider his viral modules
            if((user = @session.user).is_a?(YusUser))
              reconsider_permissions(user, des)
            end
            state = des
					end
          state
				else
					State::PayPal::Return.new(@session, nil)
				end
			end
      def foto
        if (iksnr = @session.user_input(:reg) || @session.user_input(:swissmedicnr)) \
          && (seqnr = @session.user_input(:seq)) \
          && (ikscd = @session.user_input(:pack)) \
          && (reg = @session.app.registration(iksnr)) \
          && (seq = reg.sequence(seqnr)) \
          && (package = seq.package(ikscd))
          State::Drugs::Photo.new(@session, package)
        else
          Http404.new(@session, nil)
        end
      end
			def powerlink
				pointer = @session.user_input(:pointer)
				unless(error?)
					comp = pointer.resolve(@session.app)
					State::User::PowerLink.new(@session, comp)
				end
			end
      def print
        if @session.user_input(:prescription) and
           ean13 = @session.user_input(:ean) and
           pack = @session.app.package_by_ikskey(ean13.to_s[4,8])
          State::Drugs::PrescriptionPrint.new(@session, pack)
        elsif @session.user_input(:pointer)
          self
        elsif iksnr = @session.user_input(:reg) and
              reg = @session.app.registration(iksnr) and
              seq = reg.sequence(@session.user_input(:seq)) and
              pi = seq.patinfo
          State::Drugs::PatinfoPrint.new(@session, pi)
        elsif iksnr = @session.user_input(:fachinfo) and
              reg = @session.app.registration(iksnr) and
              fi = reg.fachinfo
          State::Drugs::FachinfoPrint.new(@session, fi)
        end
      end
			def proceed_download
				keys = [:download, :months, :compression]
				input = user_input(keys, keys) 
				items = []
				dir = File.expand_path('../../data/downloads', 
					File.dirname(__FILE__))
				compression = input[:compression]
				if(files = input[:download])
					files.each { |filename, val|
						if(val)
							item = AbstractInvoiceItem.new
              suffix = ''
              unless DOWNLOAD_UNCOMPRESSED.include?(filename)
                suffix = case compression
                when 'compr_gz'
                  ['.gz', '.tar.gz'].select { |sfx|
                    File.exist?(File.join(dir, filename + sfx))
                  }.first
                else
                  '.zip'
                end
              end
							item.text = filename + suffix
							item.type = :download
							item.unit = 'Download'
							item.vat_rate = VAT_RATE
							months = input[:months][filename]
							item.quantity = months.to_f
							price_mth = 'price'
							duration_mth = 'duration'
							if(months == '12')
								price_mth = 'subscription_' << price_mth
								duration_mth = 'subscription_' << duration_mth
							end
							klass = State::User::DownloadExport
							item.total_netto = klass.send(price_mth, filename)
							item.duration = klass.send(duration_mth, filename)
							items.push(item)
						end
					}
				end
				if(items.empty?)
					@errors.store(:download, create_error('e_no_download_selected', 
						:download, nil))
				end
				if(error?)
					self
				else
					pointer = Persistence::Pointer.new(:invoice)
					invoice = Persistence::CreateItem.new(pointer)
					invoice.carry(:items, items)
          # experimental Implementation of Invoiced Download. 
          # Does not work yet, because an Invoice-Id is needed for downloading,
          # but no invoice is created until the next run of DownloadInvoicer
          #if(creditable?('org.oddb.download'))
          #  State::User::PaymentMethod.new(@session, invoice)
          #else
            State::User::RegisterDownload.new(@session, invoice)
          #end
				end
			end
			def proceed_poweruser
				keys = [:days]
				input = user_input(keys, keys)
				unless(error?)
					days = input[:days].to_i
					item = AbstractInvoiceItem.new
					item.text = "unlimited access"
					item.type = :poweruser
					item.vat_rate = VAT_RATE
					item.quantity = days
					item.duration = days
					item.total_netto = State::Limit.price(days)
					pointer = Persistence::Pointer.new(:invoice)
					invoice = Persistence::CreateItem.new(pointer)
					invoice.carry(:items, [item])
					if(usr = @session.user_input(:pointer))
						State::User::RenewPowerUser.new(@session, invoice)
					else
						State::User::RegisterPowerUser.new(@session, invoice)
					end
				end
			end
      def rezept
        if ean13 = @session.user_input(:ean) and
           pack  = @session.app.package_by_ikskey(ean13.to_s[4,8])
          State::Drugs::Prescription.new(@session, pack)
        end
      end
      def migel_search
        @session.set_cookie_input(:resultview, '')
        sortvalue = @session.user_input(:sortvalue) || @session.user_input(:reverse)
        reverse  = @session.user_input(:reverse)
        if migel_code = @session.user_input(:migel_code) and result = @session.app.search_migel_items_by_migel_code(migel_code, sortvalue, reverse)
          product = StubProduct.new(result)
          @session.set_cookie_input(:resultview, 'pages') if items = product.items and items.length > ODDB::State::Migel::Items::ITEM_LIMIT
          ODDB::State::Migel::Items.new(@session, StubItems.new(product))
        elsif migel_code = @session.user_input(:migel_product) and product = @session.search_migel_products(migel_code).first
          ODDB::State::Migel::Product.new(@session, product)
        elsif migel_code = @session.user_input(:migel_subgroup) and subgroup = @session.app.search_migel_subgroup(migel_code)
          ODDB::State::Migel::Subgroup.new(@session, subgroup)
        elsif migel_code = @session.user_input(:migel_group) and group = @session.app.search_migel_group(migel_code)
          ODDB::State::Migel::Group.new(@session, group)
        elsif migel_code = @session.user_input(:migel_limitation) and limitation_text = @session.app.search_migel_limitation(migel_code)
          ODDB::State::Migel::LimitationText.new(@session, limitation_text)
        else 
          self
        end
      end
      def galenic_group
        if oid = @session.user_input(:oid) and model = @session.app.galenic_group(oid)
          if @session.allowed?('edit', 'org.oddb.model.!galenic_group.*')
            ODDB::State::Admin::GalenicGroup.new(@session, model)
          else
            ODDB::State::Admin::TransparentLogin.new(@session, model)
          end
        end
      end
      def galenic_form
        if group_oid = @session.user_input(:goid) and group = @session.app.galenic_group(group_oid) and model = group.galenic_form(@session.user_input(:foid))
          if @session.allowed?('edit', 'org.oddb.model.!galenic_group.*')
            ODDB::State::Admin::GalenicForm.new(@session, model)
          else
            ODDB::State::Admin::TransparentLogin.new(@session, model)
          end
        end
      end
      def commercial_form
        if oid = @session.user_input(:oid) and model = @session.app.commercial_form(oid)
          ODDB::State::Admin::TransparentLogin.new(@session, model)
        end
      end
      def indication
        if oid = @session.user_input(:oid) and model = @session.app.indication(oid)
          ODDB::State::Admin::TransparentLogin.new(@session, model)
        end
      end
      def analysis
        if group_cd = @session.user_input(:group) and group = @session.app.analysis_group(group_cd) 
          if position = group.position(@session.user_input(:position))
            State::Analysis::Position.new(@session, position)
          else
            State::Analysis::Group.new(@session, group)
          end
        end
      end
      def doctor
        model = if ean = @session.user_input(:ean)
                   @session.search_doctors(ean).first
                 elsif oid = @session.user_input(:oid)
                   @session.search_doctor(oid)
                 end
        if model
          State::Doctors::Doctor.new(@session, model)
        end
      end
      def vcard
        if @session.user_input(:pointer)
          self
        else
          doctor = if ean_or_oid = @session.user_input(:doctor)
                     @session.search_doctor(ean_or_oid) or @session.search_doctors(ean_or_oid).first
                   elsif pointer = @session.user_input(:pointer)
                     pointer.resolve(@session)
                   end
          hospital = if ean = @session.user_input(:hospital)
                       @session.app.hospital(ean)
                     elsif pointer = @session.user_input(:pointer)
                       pointer.resolve(@session)
                     end
          if doctor
            State::Doctors::VCard.new(@session, doctor)
          elsif hospital
            State::Hospitals::VCard.new(@session, hospital)
          end
        end
      end
      def substance
        if oid = @session.user_input(:oid) and substance = @session.app.substance(oid)
          State::Admin::TransparentLogin.new(@session, substance)
        end
      end
       def sl_entry
         if iksnr = @session.user_input(:reg) and seqnr = @session.user_input(:seq) and ikscd = @session.user_input(:pack)\
           and package = @session.app.registration(iksnr).sequence(seqnr).package(ikscd) and model = package.sl_entry
           State::Admin::TransparentLogin.new(@session, model)
         end
       end
			def resolve
				if(@session.request_path == @request_path)
					self
        else
          iksnr = @session.user_input(:reg)
          seqnr = @session.user_input(:seq) 
          ikscd = @session.user_input(:pack)
          @session.set_persistent_user_input(:reg, iksnr) if iksnr
          @session.set_persistent_user_input(:seq, seqnr) if seqnr
          pointer = if iksnr and seqnr and ikscd and reg=@session.app.registration(iksnr)\
                      and seq=reg.sequence(seqnr) and pac=seq.package(ikscd)
                      pac.pointer
                    elsif iksnr and seqnr and reg=@session.app.registration(iksnr)\
                      and seq=reg.sequence(seqnr)
                      seq.pointer
                    elsif iksnr and reg=@session.app.registration(iksnr)
                      reg.pointer
                    end
          if pointer.is_a?(Persistence::Pointer) \
					&& (model = pointer.resolve(@session.app))
            if(klass = resolve_state(pointer))
              klass.new(@session, model)
            else
              State::Admin::TransparentLogin.new(@session, model)
            end
          end
				end
			end
      alias :drug :resolve

			def resolve_state(pointer, type=:standard)
				state_map = {
					:standard	=>	self::class::RESOLVE_STATES,
					:readonly	=>	self::class::READONLY_STATES,
					:print		=>	self::class::PRINT_STATES,
				}
				type = :standard unless(state_map.include?(type))
				state_map[type][pointer.skeleton]
			end
      def rss
        if(channel = @session.user_input(:channel))
          key = channel.gsub('.', '_').to_sym
          if(@session.lookandfeel.enabled?(key))
            Rss::PassThru.new(@session, channel)
          else
            Http404.new(@session, nil)
          end
        end
      end
			def search
				zone = @session.zone
				query = @session.persistent_user_input(:search_query)
				if(query.is_a? RuntimeError)
					State::Exception.new(@session, query)
				elsif(!query.nil?)
          if zone == :migel
            query = query.to_s.gsub(//u,'')
          else
					  query = ODDB.search_term(query)
          end
					case zone
					when :hospitals
						result = @session.search_hospitals(query)
						State::Hospitals::HospitalResult.new(@session, result)
					when :doctors
						result = @session.search_doctors(query)
						State::Doctors::DoctorResult.new(@session, result)
					when :companies
						result = @session.search_companies(query)
						State::Companies::CompanyResult.new(@session, result)
					when :interactions
						result = @session.search_interactions(query)
						State::Interactions::Result.new(@session, result)
					when :substances
						result = @session.search_substances(query)
						State::Substances::Result.new(@session, result)
					when :migel
            unless @session.lookandfeel.zones.include?(:migel)
              switch_flavor(:gcc)
              self
            else
              sortvalue = @session.user_input(:sortvalue) || @session.user_input(:reverse)
              reverse   = @session.user_input(:reverse)
              if result = @session.search_migel_products(query) and !result.empty?
                State::Migel::Result.new(@session, result)
              elsif result = @session.app.search_migel_items(query, @session.language, sortvalue, reverse) and !result.empty?
                product = StubProduct.new(result)
                if items = product.items and items.length > ODDB::State::Migel::Items::ITEM_LIMIT
                  @session.set_cookie_input(:resultview, 'pages')
                else
                  @session.set_cookie_input(:resultview, '')
                end
                ODDB::State::Migel::Items.new(@session, StubItems.new(product))
              else
                State::Migel::Result.new(@session, [])
              end
            end
					when :analysis
						result = @session.search_analysis(query, @session.language)
						State::Analysis::Result.new(@session, result)
					else
						query = query.to_s.downcase.gsub(/\s+/u, ' ')
						stype = @session.user_input(:search_type) 
						_search_drugs_state(query, stype)
					end
				else
					self
				end
      rescue ODBA::OdbaResultLimitError
        exception = SBSM::InvalidDataError.new(:e_huge_search_result,
                                               :search_query, query)
        State::Exception.new(@session, exception)
			end
			alias :result :search
			def _search_drugs(query, stype)
				case stype
				when 'st_sequence'
					@session.search_exact_sequence(query)
				when 'st_substance'
					@session.search_exact_substance(query)
				when 'st_company'
					@session.search_exact_company(query)
				when 'st_indication'
					@session.search_exact_indication(query)
				when 'st_interaction'
					@session.search_by_interaction(query, @session.language)
				when 'st_unwanted_effect'
					@session.search_by_unwanted_effect(query, @session.language)
				else
					@session.search_oddb(query)
				end
			end
			def _search_drugs_state(query, stype)
        if(stype == "st_registration" && (reg = @session.registration(query)))
          if(allowed?(reg))
            State::Admin::Registration.new(@session, reg)
          elsif(pac = reg.active_packages.sort_by { |pc| pc.ikscd }.first)
            State::Drugs::Package.new(@session, pac)
          else
            State::Drugs::Registration.new(@session, reg)
          end
        elsif(stype == "st_pharmacode" && (pac = @session.package(query)))
          if(allowed?(pac))
            State::Admin::Package.new(@session, pac)
          else
            State::Drugs::Package.new(@session, pac)
          end
        else
          result = _search_drugs(query, stype)
          if @session.lookandfeel.has_result_filter?
            lnf = @session.lookandfeel
            filter_proc = Proc.new do |seq| lnf.result_filter seq end
            result.filter! filter_proc
          end
          @session.set_cookie_input(:resultview, 'pages') if @session.flavor == 'desitin'
          state = State::Drugs::Result.new(@session, result)
          state.search_query = query
          state.search_type = stype
          state
        end
			end
			def show
				if(@session.request_path == @request_path)
					self
        else
          iksnr = @session.user_input(:reg)
          seqnr = @session.user_input(:seq)
          ikscd = @session.user_input(:pack)
          pointer = if (iksnr && seqnr && ikscd) and reg = @session.app.registration(iksnr) \
                      and seq = reg.sequence(seqnr) and pack = seq.package(ikscd)
                      pack.pointer
                    elsif (iksnr && seqnr) and reg = @session.app.registration(iksnr) \
                      and seq = reg.sequence(seqnr)
                      seq.pointer
                    elsif iksnr and reg = @session.app.registration(iksnr)
                      reg.pointer
                    end
          if pointer.is_a?(Persistence::Pointer) \
					&& (model = pointer.resolve(@session.app)) \
					&& klass = resolve_state(pointer, :readonly)
            klass.new(@session, model)
          end
				end
			end
			def snapback_event
				if(defined?(self.class::SNAPBACK_EVENT))
					self.class::SNAPBACK_EVENT
				else
					self.class::DIRECT_EVENT
				end
			end
			def sort
				return self unless @model.is_a? Array
				get_sortby!
				@model.sort! { |a, b| compare_entries(a, b) }
				@model.reverse! if(@sort_reverse)
				self
			end
			def sponsorlink
				if((sponsor = @session.sponsor) && sponsor.valid?)
					State::User::SponsorLink.new(@session, sponsor)
				end
			end
			def suggest_address
        doctor = if oid_or_ean = @session.user_input(:doctor)
                   @session.search_doctor(oid_or_ean) || @session.search_doctors(oid_or_ean).first
                 end
        hospital = if ean = @session.user_input(:hospital)
                     @session.search_hospital(ean)
                   end
        if (doctor and addr = doctor.address(@session.user_input(:address))) \
          or (hospital and addr = hospital.address(@session.user_input(:address)))
          SuggestAddress.new(@session, addr)
        elsif doctor # create a new address
          addr = Address2.new
          addr.name = doctor.fullname
          addr.pointer = doctor.pointer + [:address, @session.user_input(:address)]
          SuggestAddress.new(@session, addr)
        #elsif hospital # TODO create a new address for a hospital
        end
			end
      def address_suggestion
        if (ean_or_oid = @session.user_input(:doctor) and (doctor = @session.search_doctor(ean_or_oid) || @session.search_doctors(ean_or_oid).first)) \
          or (ean = @session.user_input(:hospital) and hospital = @session.search_hospital(ean))
          if oid = @session.user_input(:oid) and model = @session.app.address_suggestion(oid) 
            State::Admin::TransparentLogin.new(@session, model)
          end
        end
      end
			def switch
				state = self.trigger(self.direct_event)
				if(state.zone == @session.zone)
					state
				else
					event = [ 'home', @session.zone ].compact.join('_').intern
					self.trigger(event)
				end
			end
      def _trigger(event)
        super || Http404.new(@session, nil)
      rescue Persistence::UninitializedPathError
        Http404.new(@session, nil)
      end
			def unique_email
				user = @session.user
				if(user.respond_to?(:unique_email))
					user.unique_email
				end
			end
			def user_input(keys=[], mandatory=[])
				keys = [keys] unless keys.is_a?(Array)
				mandatory = [mandatory] unless mandatory.is_a?(Array)
				hash = @session.user_input(*keys)
				hash ||= {}
				unless(hash.is_a?(Hash))
					hash = {keys.first => hash}
				end
				keys.each { |key| 
					carryval = nil
					value = hash[key]
					if(value.is_a? RuntimeError)
						carryval = value.value
						@errors.store(key, hash.delete(key))
					elsif(mandatory.include?(key) && mandatory_violation(value))
						error = create_error('e_missing_' << key.to_s, key, value)
						@errors.store(key, error)
						hash.delete(key)
					else
						carryval = value
					end
					if(@model.is_a? Persistence::CreateItem)
						@model.carry(key, carryval)
					end
				}
				hash
			end
			def user_navigation
				[
					State::Admin::Login,
					State::User::YweseeContact,
				]
			end
			def ywesee_contact
				model = nil
				State::User::YweseeContact.new(@session, model)
			end
			def zones
			[ :analysis, :doctors, :interactions, :drugs, :migel, :user , :hospitals, :companies]
			end
			def zone_navigation
				self::class::ZONE_NAVIGATION
			end
			private
			def compare_entries(a, b)
				@sortby.each { |sortby|
					aval, bval = nil
					begin
						aval = umlaut_filter(a.send(sortby))
						bval = umlaut_filter(b.send(sortby))
					rescue
						next
					end
					res = if (aval.nil? && bval.nil?)
						0
					elsif (aval.nil?)
						1
					elsif (bval.nil?)
						-1
					else 
						aval <=> bval
					end
          if !res
            return 0
          elsif res != 0
            return res
          end
				}
				0
			end
			def get_sortby!
				@sortby ||= []
				sortvalue = @session.user_input(:sortvalue)
				if(sortvalue.is_a? String)
					sortvalue = sortvalue.intern
				end
				if(@sortby.first == sortvalue)
					@sort_reverse = !@sort_reverse 
				else
					@sort_reverse = self.class::REVERSE_MAP[sortvalue] 
				end
				@sortby.delete_if { |sortby| sortby == sortvalue }
				@sortby.unshift(sortvalue)
			end
			def mandatory_violation(value)
				value.nil? || (value.respond_to?(:empty?) && value.empty?)
			end
      def switch_flavor(flavor=:gcc)
        location = @session.request_path.gsub(/\/#{@session.lookandfeel.flavor}\//u, "/#{flavor.to_s}/")
        self.http_headers = {
          'Status'   => '303 See Other',
          'Location' => location
        }
      end
		end
	end
end
