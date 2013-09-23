#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::TestGlobal -- oddb.org -- 09.04.2012 -- yasaka@ywesee.com
# ODDB::State::TestGlobal -- oddb.org -- 09.11.2011 -- mhatakeyama@ywesee.com
# ODDB::State::TestGlobal -- oddb.org -- 13.10.2003 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'stub/odba'
gem 'minitest'
require 'minitest/autorun'
require 'state/global'
require 'util/language'
require 'sbsm/state'
require 'flexmock'
require 'state/user/yweseecontact'
require 'state/user/register_download'
require 'state/migel/result'

module ODDB
	module State
		module Admin
class TransparentLogin < State::Admin::Login
	def init
		@session.app.state_transp_called = true
		super
	end
end
		end
		class Global < SBSM::State
			attr_accessor :model
		end
		class TestGlobal <Minitest::Test
      include FlexMock::TestCase
      class StubSession
				attr_accessor :user_input, :request_path, :lookandfeel, :flavor
        def initialize(lookandfeel)
          @lookandfeel = lookandfeel
        end
				def app
					@app ||= StubApp.new
				end
				def user_input(*keys)
					if(keys.size > 1)
						res = {}
						keys.each { |key|
							res.store(key, user_input(key))
						}
						res
					else
						key = keys.first
						(@user_input ||= {
							:pointer	=>	StubPointer.new
						})[key]
					end
				end
				def allowed?(foo, bar)
					true
				end
				def user
					self
				end
				def request_path
					# disable self-caching for tests
					@rp = @rp.to_i.next
				end
        def cookie_set_or_get(*args)
        end
        def set_cookie_input(*args)
        end
        def set_persistent_user_input(key, value)
        end
			end
			class StubApp
				attr_accessor :companies, :galenic_groups, :fachinfos
				attr_accessor :state_transp_called
				def initialize
					@state_transp_called = false
					@companies ||= {}
				end
				def company(oid)
					@companies[oid.to_i]
				end
				def galenic_group(oid)
					@galenic_groups[oid.to_i]
				end
				def fachinfo(oid)
					@fachinfos[oid]
				end
        def package_by_ikskey(iksnr)
        end
			end
			class StubPointer; end
			class StubCompany; end
			class StubGalenicGroup
				attr_accessor :galenic_forms
				def galenic_form(oid)
					@galenic_forms[oid.to_i]
				end
			end
			class StubGalenicForm
				include Language
			end
      
 			def setup
        @lnf = flexmock('lookandfeel', :zones => [:analysis, :doctors, :interactions, :drugs, :migel, :user , :hospitals, :companies], :flavor => nil)
        @session = StubSession.new(@lnf)
				@state = State::Global.new(@session, @session)
			end
			def teardown
				ODBA.storage = nil
			end
			def test_resolve1
				@company = StubCompany.new
				@session.app.companies = { 
					4	=>	@company, 
				}
        pointer = flexmock('pointer') do |ptr|
          ptr.should_receive(:is_a?).and_return(true)
          ptr.should_receive(:resolve).and_return('model')
          ptr.should_receive(:skeleton).and_return([:company])
        end
        flexstub(@session) do |s|
          s.should_receive(:user_input).once.with(:pointer).and_return(pointer) 
          s.should_receive(:user_input).once.with(:reg).and_return(nil) 
          s.should_receive(:user_input).once.with(:seq).and_return(nil) 
          s.should_receive(:user_input).once.with(:pack).and_return(nil) 
        end
				newstate = @state.resolve
				assert_instance_of(State::Companies::Company, newstate)
			end
			def test_aa_resolve__print1
				@session.app.fachinfos = { 0	=>	:foo}
        pointer = flexmock('pointer') do |ptr|
          ptr.should_receive(:is_a?).and_return(true)
          ptr.should_receive(:resolve).and_return('model')
          ptr.should_receive(:skeleton).and_return([:fachinfo])
        end
        flexstub(@session) do |s|
          s.should_receive(:user_input).and_return(pointer) 
        end

				newstate = @state.print
				assert_instance_of(State::Drugs::FachinfoPrint, newstate)
			end
			def test_user_input1
				@session.user_input = {
					:good => 'foo', 
					:bad => SBSM::InvalidDataError.new('e_invalid_bad', :bad, 'bar')
				}
				result = @state.user_input([:good, :bad])
				expected = {:good => 'foo'}
				assert_equal(expected, result)
				assert_equal(true, @state.errors.has_key?(:bad))
				assert_instance_of(SBSM::InvalidDataError, @state.error(:bad))
			end
			def test_user_input2
				@session.user_input = {
					:good => 'foo', 
					:bad => SBSM::InvalidDataError.new('e_invalid_bad', :bad, 'bar')
				}
				@state.model = Persistence::CreateItem.new()
				@state.user_input([:good, :bad])
				assert_instance_of(Persistence::CreateItem, @state.model)
				assert_equal('foo', @state.model.good)
				assert_equal('bar', @state.model.bad)
			end

      def test_add_to_interaction_basket
        pointer = flexmock('pointer') do |ptr|
          ptr.should_receive(:resolve).and_return('object')
        end
        flexmock(@session) do |ses|
          ses.should_receive(:user_input).and_return(pointer)
          ses.should_receive(:add_to_interaction_basket)
        end
        assert_equal(@state, @state.add_to_interaction_basket)
      end
      def test_allowed?
        model = flexmock('model') do |mod|
          mod.should_receive(:is_a?).and_return(true)
          mod.should_receive(:parent)
        end
        flexmock(@session) do |ses|
          ses.should_receive(:allowed?).and_return('allowed?')
        end
        assert_equal('allowed?', @state.allowed?(model))
      end
      def test_atc_chooser
        flexmock(@session.app) do |app|
          app.should_receive(:atc_chooser)
        end
        assert_kind_of(State::Drugs::AtcChooser, @state.atc_chooser)
      end
      def test_checkout__user
        flexmock(@session) do |ses|
          ses.should_receive(:zone).and_return(:user)
        end
        flexmock(@state) do |sta|
          sta.should_receive(:"proceed_download.checkout").and_return('proceed_download.checkout')
        end
        assert_equal('proceed_download.checkout', @state.checkout)
      end
      def test_checkout__drugs
        flexmock(@session) do |ses|
          ses.should_receive(:zone).and_return(:drugs)
        end
        flexmock(@state) do |sta|
          sta.should_receive(:"export_csv.checkout").and_return('export_csv.checkout')
        end
        assert_equal('export_csv.checkout', @state.checkout)
      end
      def test_clear_interaction_basket
        flexmock(@session) do |ses|
          ses.should_receive(:clear_interaction_basket)
        end
        assert_kind_of(State::Interactions::EmptyBasket, @state.clear_interaction_basket)
      end
      def test_creditable?
        flexmock(@session.user) do |usr|
          usr.should_receive(:creditable?).and_return('creditable?')
        end
        assert_equal('creditable?', @state.creditable?)
      end
      def test_direct_request_path
        flexmock(@state) do |sta|
          sta.should_receive(:direct_event).and_return('event')
        end
        flexmock(@session) do |ses|
          ses.should_receive(:lookandfeel).and_return(flexmock('lookandfeel') do |look|
            look.should_receive(:_event_url).and_return('_event_url')
          end)
        end
        assert_equal('_event_url', @state.direct_request_path)
      end
      def test_direct_request_path__else
        flexmock(@state) do |s|
          s.should_receive(:request_path).and_return('request_path')
        end
        assert_equal('request_path', @state.direct_request_path)
      end
      def test_doctorlist
        flexmock(@session) do |s|
          s.should_receive(:doctors).and_return({'key' => 'model'})
        end
        assert_kind_of(State::Doctors::DoctorList, @state.doctorlist)
      end
      def test_download__init
        flexmock(@session) do |s|
          s.should_receive(:is_crawler?).and_return(true)
        end
        assert_kind_of(State::Drugs::Init, @state.download)
      end
      def test_download__download
        item = flexmock('item') do |i|
          i.should_receive(:expired?).and_return(false)
        end
        invoice = flexmock('invoice') do |i|
          i.should_receive(:yus_name).and_return('email')
          i.should_receive(:payment_received?).and_return(true)
          i.should_receive(:item_by_text).and_return(item)
        end
        flexmock(@session) do |s|
          s.should_receive(:is_crawler?).and_return(false)
          s.should_receive(:get_cookie_input).and_return('email')
          s.should_receive(:invoice).and_return(invoice)
        end
        assert_kind_of(State::User::Download, @state.download)
      end
      def test_download__return
        flexmock(@session) do |s|
          s.should_receive(:is_crawler?).and_return(false)
          s.should_receive(:get_cookie_input)
          s.should_receive(:invoice)
        end
        assert_kind_of(State::PayPal::Return, @state.download)
      end
      def test_hospitallist
        flexmock(@session) do |s|
          s.should_receive(:hospitals).and_return({'key' => 'model'})
        end
        assert_kind_of(State::Hospitals::HospitalList, @state.hospitallist)
      end
      def test_export_csv
        flexmock(@session) do |s|
          s.should_receive(:zone).and_return(:drugs)
        end
        state = flexmock('state') do |s|
          s.should_receive(:is_a?).and_return(true)
          s.should_receive(:export_csv).and_return('export_csv')
        end
        flexmock(@state) do |s|
          s.should_receive(:search).and_return(state)
        end
        assert_equal('export_csv', @state.export_csv)
      end
      def test_export_csv__nil
        flexmock(@session) do |s|
          s.should_receive(:zone)
        end
        assert_equal(nil, @state.export_csv)
      end
      def test_extend
        mod = flexmock(Module.new) do |m|
          m.should_receive(:constants).and_return(['VIRAL'])
        end
        assert_equal(@state, @state.extend(mod))
      end
      def test_fachinfo
        flexmock(@session) do |s|
          s.should_receive(:user_input).and_return('iksnr')
        end
        registration = flexmock('registration') do |r|
          r.should_receive(:fachinfo).and_return('fachinfo')
        end
        flexmock(@session.app) do |app|
          app.should_receive(:registration).and_return(registration)
        end
        assert_kind_of(State::Drugs::Fachinfo, @state.fachinfo)
      end
      def test_fachinfo__http404
        assert_kind_of(Http404, @state.fachinfo)
      end
      def test_feedbacks__package
        item = flexmock('item') do |i|
          i.should_receive(:odba_instance).and_return(ODDB::Package.new('ikscd'))
        end
        pointer = flexmock('pointer') do |ptr|
          ptr.should_receive(:is_a?).and_return(true)
          ptr.should_receive(:resolve).and_return(item)
        end
        flexmock(@session) do |s|
          s.should_receive(:user_input).and_return(pointer)
        end
        package      = flexmock('package')
        sequence     = flexmock('sequence', :package => package)
        registration = flexmock('registration', :sequence => sequence)
        flexmock(@session.app, :registration => registration)
        assert_kind_of(State::Drugs::Feedbacks, @state.feedbacks)
      end
      def test_feedbacks__product
        item = flexmock('item') do |i|
          i.should_receive(:odba_instance).and_return(ODDB::State::Migel::Product.new('code', 'atc_code'))
        end
        pointer = flexmock('pointer') do |ptr|
          ptr.should_receive(:is_a?).and_return(true)
          ptr.should_receive(:resolve).and_return(item)
        end
        flexmock(@session) do |s|
          s.should_receive(:user_input).and_return(pointer)
        end
        package      = flexmock('package')
        sequence     = flexmock('sequence', :package => package)
        registration = flexmock('registration', :sequence => sequence)
        flexmock(@session.app, :registration => registration)
        assert_kind_of(State::Drugs::Feedbacks, @state.feedbacks)
      end
      def test_feedbacks__nil
        sequence     = flexmock('sequence', :package => nil)
        registration = flexmock('registration', :sequence => sequence)
        flexmock(@session.app, :registration => registration)
        assert_equal(nil, @state.feedbacks)
      end
      def test_notify__package
        item = flexmock('item') do |i|
          i.should_receive(:odba_instance).and_return(ODDB::Package.new('ikscd'))
        end
        pointer = flexmock('pointer') do |ptr|
          ptr.should_receive(:is_a?).and_return(true)
          ptr.should_receive(:resolve).and_return(item)
        end
        flexmock(@session) do |s|
          s.should_receive(:user_input).and_return(pointer)
        end
        skip("Avoid NoMethodError: undefined method `notify' for #<ODDB::State::Global:0x000000030b9f98>")
        assert_kind_of(State::Drugs::Notify, @state.notify)
      end
      def test_notify__product
        item = flexmock('item') do |i|
          i.should_receive(:odba_instance).and_return(ODDB::State::Migel::Product.new(@session, 'code'))
        end
        pointer = flexmock('pointer') do |ptr|
          ptr.should_receive(:is_a?).and_return(true)
          ptr.should_receive(:resolve).and_return(item)
        end
        flexmock(@session) do |s|
          s.should_receive(:user_input).and_return(pointer)
        end
        skip("Avoid NoMethodError: undefined method `notify' for #<ODDB::State::Global:0x00000005f787a8>")
        assert_kind_of(State::Drugs::Notify, @state.notify)
      end
      def test_notify__nil
        sequence     = flexmock('sequence', :package => nil)
        registration = flexmock('registration', :sequence => sequence)
        flexmock(@session.app, :registration => registration)
        skip("Avoid NoMethodError: undefined method `notify' for #<ODDB::State::Global:0x000000030b9f98>")
        assert_equal(nil, @state.notify)
      end
      def test_help_navigation
        expected = [
          :help_link,
          :faq_link
        ]
        assert_equal(expected, @state.help_navigation)
      end
      def test_home_state
        assert_equal(State::Global::HOME_STATE, @state.home_state)
      end
      def test_home_navigation
        expected = [State::Global::HOME_STATE]
        assert_equal(expected, @state.home_navigation)
      end
      def test_interaction_basket__empty
        flexmock(@session) do |s|
          s.should_receive(:interaction_basket).and_return([])
        end
        assert_kind_of(State::Interactions::EmptyBasket, @state.interaction_basket)
      end
      def test_interaction_basket__not_empty
        flexmock(@session) do |s|
          s.should_receive(:interaction_basket).and_return(['basket'])
        end
        assert_kind_of(State::Interactions::Basket, @state.interaction_basket)
      end
      def test_limited?
        assert_equal(false, @state.limited?)
      end
      def test_limit_state
        assert_kind_of(State::User::Limit, @state.limit_state)
      end
      def test_logout
        flexmock(@session) do |s|
          s.should_receive(:logout).and_return('user')
        end
        assert_kind_of(State::Drugs::Init, @state.logout)
      end
      def test_user_navigation
        expected = [State::Admin::Login, State::User::YweseeContact]
        assert_equal(expected, @state.user_navigation)
      end
      
      def test_navigation
        expected = [:help_link, :faq_link,
                    ODDB::State::Admin::Login,
                    ODDB::State::User::YweseeContact,
                    ODDB::State::Drugs::Init]
        skip("Avoid Error NameError: uninitialized constant ODDB::State::Global::Session")
        assert_equal(expected, @state.navigation)
      end
      def test_password_reset
        flexmock(@state) do |s|
          s.should_receive(:error?).and_return(false)
        end
        flexmock(@session) do |s|
          s.should_receive(:yus_allowed?).and_return(true)
        end
        assert_kind_of(State::Admin::PasswordReset, @state.password_reset)
      end
      def test_paypal_return
        flexmock(@session) do |s|
          s.should_receive(:is_crawler?).and_return(true)
        end
        assert_kind_of(State::Drugs::Init, @state.paypal_return)
      end
      def test_paypal_return__user_input
        invoice = flexmock('invoice') do |i|
          i.should_receive(:"types.all?").and_return(true)
        end
        user = flexmock('user') do |u|
          u.should_receive(:is_a?).and_return(true)
        end
        flexmock(@session) do |s|
          s.should_receive(:is_crawler?).and_return(false)
          s.should_receive(:user_input).and_return('id')
          s.should_receive(:invoice).and_return(invoice)
          s.should_receive(:allowed?).and_return(true)
          s.should_receive(:desired_state).and_return('desired_state')
          s.should_receive(:user).and_return(user)
        end
        flexmock(@state) do |s|
          s.should_receive(:reconsider_permissions)
        end
        assert_equal('desired_state', @state.paypal_return)
      end
      def test_paypal_return__else
        flexmock(@session) do |s|
          s.should_receive(:is_crawler?).and_return(false)
          s.should_receive(:user_input)
        end
        assert_kind_of(State::PayPal::Return, @state.paypal_return)
      end
      def test_powerlink
        pointer = flexmock('pointer') do |ptr|
          ptr.should_receive(:resolve)
        end
        flexmock(@session) do |s|
          s.should_receive(:user_input).and_return(pointer)
        end
        flexmock(@state) do |s|
          s.should_receive(:error?).and_return(false)
        end
        assert_kind_of(State::User::PowerLink, @state.powerlink)
      end
      def test_proceed_download
        flexmock(File) do |f|
          f.should_receive(:exist?).and_return(true)
        end
        input = {
          :compression => 'compr_gz',
          :download => {'filename' => 'val'},
          :months => {'filename' => '12'}
        }
        flexmock(@state) do |s|
          s.should_receive(:user_input).and_return(input)
        end
        assert_kind_of(State::User::RegisterDownload, @state.proceed_download)
      end
      def test_proceed_download__zip
        input = {
          :compression => 'zip',
          :download => {'filename' => 'val'},
          :months => {'filename' => '12'}
        }
        flexmock(@state) do |s|
          s.should_receive(:user_input).and_return(input)
        end
        assert_kind_of(State::User::RegisterDownload, @state.proceed_download)
      end
      def test_proceed_download__error
        assert_equal(@state, @state.proceed_download)
      end
      def test_proceed_poweruser
        flexmock(@state) do |s|
          s.should_receive(:error?).and_return(false)
        end
        assert_kind_of(State::User::RenewPowerUser, @state.proceed_poweruser)
      end
      def test_proceed_poweruser__else
        flexmock(@state) do |s|
          s.should_receive(:error?).and_return(false)
        end
        flexmock(@session) do |s|
          s.should_receive(:user_input).and_return(nil)
        end
        assert_kind_of(State::User::RegisterPowerUser, @state.proceed_poweruser)
      end
      def test_proceed_poweruser__error
        assert_equal(nil, @state.proceed_poweruser)
      end
      def test_resolve
        @state.request_path = 1
        assert_equal(@state, @state.resolve)
      end
      def test_resolve__else_pointer
        pointer = flexmock('pointer') do |ptr|
          ptr.should_receive(:is_a?).and_return(true)
          ptr.should_receive(:resolve).and_return('model')
        end
        flexmock(@session) do |s|
          s.should_receive(:user_input).once.with(:pointer).and_return(pointer)
          s.should_receive(:user_input).once.with(:reg).and_return(nil)
          s.should_receive(:user_input).once.with(:seq).and_return(nil)
          s.should_receive(:user_input).once.with(:pack).and_return(nil)
        end
        flexmock(@state) do |s|
          s.should_receive(:resolve_state)
        end
        assert_kind_of(ODDB::State::Admin::TransparentLogin, @state.resolve)
      end
      def test_resolve__else_package
        pointer = flexmock('pointer') do |ptr|
          ptr.should_receive(:is_a?).and_return(true)
          ptr.should_receive(:resolve).and_return('model')
        end
        package      = flexmock('package', :pointer => pointer)
        sequence     = flexmock('sequence',
                                :package  => package,
                                :pointer  => pointer
                               )
        registration = flexmock('registration', 
                                :sequence => sequence,
                                :pointer  => pointer
                               )
        flexmock(@session.app, :registration => registration)
        flexmock(@session) do |s|
          s.should_receive(:user_input).once.with(:reg).and_return('iksnr')
          s.should_receive(:user_input).once.with(:seq).and_return('seqnr')
          s.should_receive(:user_input).once.with(:pack).and_return('ikscd')
        end
        flexmock(@state) do |s|
          s.should_receive(:resolve_state)
        end
        assert_kind_of(ODDB::State::Admin::TransparentLogin, @state.resolve)
      end
      def test_resolve__else_sequence
        pointer = flexmock('pointer') do |ptr|
          ptr.should_receive(:is_a?).and_return(true)
          ptr.should_receive(:resolve).and_return('model')
        end
        package      = flexmock('package', :pointer => pointer)
        sequence     = flexmock('sequence',
                                :package  => package,
                                :pointer  => pointer
                               )
        registration = flexmock('registration', 
                                :sequence => sequence,
                                :pointer  => pointer
                               )
        flexmock(@session.app, :registration => registration)
        flexmock(@session) do |s|
          s.should_receive(:user_input).once.with(:reg).and_return('iksnr')
          s.should_receive(:user_input).once.with(:seq).and_return('seqnr')
          s.should_receive(:user_input).once.with(:pack).and_return(nil)
        end
        flexmock(@state) do |s|
          s.should_receive(:resolve_state)
        end
        assert_kind_of(ODDB::State::Admin::TransparentLogin, @state.resolve)
      end
      def test_resolve__else_registration
        pointer = flexmock('pointer') do |ptr|
          ptr.should_receive(:is_a?).and_return(true)
          ptr.should_receive(:resolve).and_return('model')
        end
        package      = flexmock('package', :pointer => pointer)
        sequence     = flexmock('sequence',
                                :package  => package,
                                :pointer  => pointer
                               )
        registration = flexmock('registration', 
                                :sequence => sequence,
                                :pointer  => pointer
                               )
        flexmock(@session.app, :registration => registration)
        flexmock(@session) do |s|
          s.should_receive(:user_input).once.with(:reg).and_return('iksnr')
          s.should_receive(:user_input).once.with(:seq).and_return(nil)
          s.should_receive(:user_input).once.with(:pack).and_return(nil)
        end
        flexmock(@state) do |s|
          s.should_receive(:resolve_state)
        end
        assert_kind_of(ODDB::State::Admin::TransparentLogin, @state.resolve)
      end
      def test_resolve__self
        flexmock(@session) do |s|
          s.should_receive(:request_path).and_return('request_path')
        end
        @state.instance_eval('@request_path = "request_path"')
        assert_equal(@state, @state.resolve)
      end
      def test_resolve__nil
        assert_equal(nil, @state.resolve)
      end
      def test_rss
        flexmock(@session) do |s|
          s.should_receive(:user_input).and_return('channel')
          s.should_receive(:"lookandfeel.enabled?").and_return(true)
        end
#        skip("Somebody moved Migel around without updating the corresponding test, here")
        skip("Avoid Error NameError: uninitialized constant ODDB::State::Global::Session")
        assert_kind_of(State::Rss::PassThru, @state.rss)
      end
      def test_rss__http404
        flexmock(@session) do |s|
          s.should_receive(:user_input).and_return('channel')
          s.should_receive(:"lookandfeel.enabled?").and_return(false)
        end
        assert_kind_of(State::Http404, @state.rss)
      end
      def test_rss__nil
        assert_equal(nil, @state.rss)
      end
      def setup_search(zone)
        query = flexmock('query') do |q|
            q.should_receive(:is_a?).and_return(false)
        end
        flexmock(@session) do |s|
          s.should_receive(:zone).and_return(zone.to_sym)
          s.should_receive(:persistent_user_input).and_return(query)
          s.should_receive("search_#{zone}".to_sym)
        end
        flexmock(ODDB) do |o|
          #o.should_receive(:search_term).and_return('query')
          o.should_receive(:search_term)
        end
      end
      def test_search__hospitals
=begin
        query = flexmock('query') do |q|
            q.should_receive(:is_a?).and_return(false)
        end
        flexmock(@session) do |s|
          s.should_receive(:zone).and_return(:hospitals)
          s.should_receive(:persistent_user_input).and_return(query)
          s.should_receive(:search_hospitals)
        end
        flexmock(ODDB) do |o|
          o.should_receive(:search_term).and_return('query')
        end
=end
        setup_search('hospitals')
        assert_kind_of(State::Hospitals::HospitalResult, @state.search)
      end
      def test_search__doctors
        setup_search('doctors')
        assert_kind_of(State::Doctors::DoctorResult, @state.search)
      end
      def test_search__companies
        setup_search('companies')
        assert_kind_of(State::Companies::CompanyResult, @state.search)
      end
      def test_search__interactions
        setup_search('interactions')
        assert_kind_of(State::Interactions::Result, @state.search)
      end
      def test_search__substances
        setup_search('substances')
        assert_kind_of(State::Substances::Result, @state.search)
      end
      def test_search__migel_product
        setup_search('migel')
        flexmock(@session) do |s|
          s.should_receive(:search_migel_products).and_return(['result'])
        end
        assert_kind_of(State::Migel::Result, @state.search)
      end
      def test_search__migel_items
        setup_search('migel')
        flexmock(@session.app, :search_migel_items => {'key' => 'result'})
        flexmock(@session) do |s|
          s.should_receive(:search_migel_products)
          s.should_receive(:language).and_return('de')
        end
        assert_kind_of(State::Migel::Items, @state.search)
      end
      def test_search__migel_items__pages
        setup_search('migel')
        flexmock(@session.app, :search_migel_items => {'key' => 'result'})
        flexmock(@session) do |s|
          s.should_receive(:search_migel_products)
          s.should_receive(:language).and_return('de')
        end
        flexmock(ODDB::State::Global::StubProduct).new_instances do |product|
          key_values = Array.new(1000){|i| i}
          product.should_receive(:items).and_return(Hash[*key_values])
        end
        assert_kind_of(State::Migel::Items, @state.search)
      end
      def test_migel_search__items
        product = flexmock('product', 
                           :items => {'key' => 'item'},
                           :price => 'price',
                           :qty   => 'qty',
                           :unit  => 'unit',
                           :migel_code => 'migel_code'
                          )
        flexmock(@session.app, :search_migel_items_by_migel_code => {'key' => product})
        flexmock(@session) do |s|
          s.should_receive(:user_input).with(:migel_code).and_return('migel_code')
          s.should_receive(:user_input).with(:sortvalue)
          s.should_receive(:user_input).with(:reverse)
        end
        assert_kind_of(State::Migel::Items, @state.migel_search)
      end
      def test_migel_search__product
        product = flexmock('product')
        flexmock(@session) do |s|
          s.should_receive(:user_input).with(:migel_code)
          s.should_receive(:user_input).with(:sortvalue)
          s.should_receive(:user_input).with(:reverse)
          s.should_receive(:user_input).with(:migel_product).and_return('migel_code')
          s.should_receive(:search_migel_products).and_return([product])
        end
        assert_kind_of(State::Migel::Product, @state.migel_search)
      end
      def test_migel_search__subgroup
        subgroup = flexmock('subgroup')
        flexmock(@session.app).should_receive(:search_migel_subgroup).and_return(subgroup)
        flexmock(@session) do |s|
          s.should_receive(:user_input).with(:migel_code)
          s.should_receive(:user_input).with(:sortvalue)
          s.should_receive(:user_input).with(:reverse)
          s.should_receive(:user_input).with(:migel_product)
          s.should_receive(:user_input).with(:migel_subgroup).and_return('migel_code')
        end
        assert_kind_of(State::Migel::Subgroup, @state.migel_search)
      end
      def test_migel_search__group
        group = flexmock('group')
        flexmock(@session.app).should_receive(:search_migel_group).and_return(group)
        flexmock(@session) do |s|
          s.should_receive(:user_input).with(:migel_code)
          s.should_receive(:user_input).with(:sortvalue)
          s.should_receive(:user_input).with(:reverse)
          s.should_receive(:user_input).with(:migel_product)
          s.should_receive(:user_input).with(:migel_subgroup)
          s.should_receive(:user_input).with(:migel_group).and_return('migel_code')
        end
        assert_kind_of(State::Migel::Group, @state.migel_search)
      end
      def test_migel_search__limitation_text
        limitation_text = flexmock('limitation_text')
        flexmock(@session.app).should_receive(:search_migel_limitation).and_return(limitation_text)
        flexmock(@session) do |s|
          s.should_receive(:user_input).with(:migel_code)
          s.should_receive(:user_input).with(:sortvalue)
          s.should_receive(:user_input).with(:reverse)
          s.should_receive(:user_input).with(:migel_product)
          s.should_receive(:user_input).with(:migel_subgroup)
          s.should_receive(:user_input).with(:migel_group)
          s.should_receive(:user_input).with(:migel_limitation).and_return('migel_code')
        end
        assert_kind_of(State::Migel::LimitationText, @state.migel_search)
      end
      def test_migel_search__fail
        flexmock(@session) do |s|
          s.should_receive(:user_input).with(:migel_code)
          s.should_receive(:user_input).with(:sortvalue)
          s.should_receive(:user_input).with(:reverse)
          s.should_receive(:user_input).with(:migel_product)
          s.should_receive(:user_input).with(:migel_subgroup)
          s.should_receive(:user_input).with(:migel_group)
          s.should_receive(:user_input).with(:migel_limitation)
        end
        assert_equal(@state, @state.migel_search)
      end
      def test_search__migel_empty
        setup_search('migel')
        flexmock(@session.app, :search_migel_items => nil)
        flexmock(@session) do |s|
          s.should_receive(:search_migel_products)
          s.should_receive(:language).and_return('de')
        end
        assert_kind_of(State::Migel::Result, @state.search)
      end
      def test_search__analysis
        setup_search('analysis')
        flexmock(@session) do |s|
          s.should_receive(:language)
        end
        assert_kind_of(State::Analysis::Result, @state.search)
      end
      def test_search__else
        setup_search('else')
        flexmock(@state) do |s|
          s.should_receive(:_search_drugs_state).and_return('_search_drugs_state')
        end
        assert_equal('_search_drugs_state', @state.search)
      end
      def test_search__self
        query = flexmock('query') do |q|
          q.should_receive(:is_a?).and_return(false)
        end
        flexmock(@session) do |s|
          s.should_receive(:zone)
          s.should_receive(:persistent_user_input).and_return(nil)
        end
        assert_equal(@state, @state.search)
      end
      def test_search__exception
        query = flexmock('query') do |q|
          q.should_receive(:is_a?).and_return(true)
        end
        flexmock(@session) do |s|
          s.should_receive(:zone)
          s.should_receive(:persistent_user_input).and_return(query)
        end
        assert_kind_of(State::Exception, @state.search)
      end
      def test_search__error
        setup_search('else')
        flexmock(@state) do |s|
          s.should_receive(:_search_drugs_state).and_raise(ODBA::OdbaResultLimitError)
        end
        assert_kind_of(State::Exception, @state.search)
      end
      def test__search_drugs
        flexmock(@session) do |s|
          s.should_receive(:search_oddb).and_return('search_oddb')
        end
        assert_equal('search_oddb', @state._search_drugs('query', 'stype'))
      end
      def test__search_drugs__sequence
        flexmock(@session) do |s|
          s.should_receive(:search_exact_sequence).and_return('search_exact_sequence')
        end
        assert_equal('search_exact_sequence', @state._search_drugs('query', 'st_sequence'))
      end
      def test__search_drugs__substance
        flexmock(@session) do |s|
          s.should_receive(:search_exact_substance).and_return('search_exact_substance')
        end
        assert_equal('search_exact_substance', @state._search_drugs('query', 'st_substance'))
      end
      def test__search_drugs__company
        flexmock(@session) do |s|
          s.should_receive(:search_exact_company).and_return('search_exact_company')
        end
        assert_equal('search_exact_company', @state._search_drugs('query', 'st_company'))
      end
      def test__search_drugs__indication
        flexmock(@session) do |s|
          s.should_receive(:search_exact_indication).and_return('search_exact_indication')
        end
        assert_equal('search_exact_indication', @state._search_drugs('query', 'st_indication'))
      end
      def test__search_drugs__interaction
        flexmock(@session) do |s|
          s.should_receive(:search_by_interaction).and_return('search_by_interaction')
          s.should_receive(:language)
        end
        assert_equal('search_by_interaction', @state._search_drugs('query', 'st_interaction'))
      end
      def test__search_drugs__unwanted_effect
        flexmock(@session) do |s|
          s.should_receive(:search_by_unwanted_effect).and_return('search_by_unwanted_effect')
          s.should_receive(:language)
        end
        assert_equal('search_by_unwanted_effect', @state._search_drugs('query', 'st_unwanted_effect'))
      end
      def test__search_drugs_state__registration
        registration = flexmock('registration')
        flexmock(@session) do |s|
          s.should_receive(:registration).and_return(registration)
        end
        assert_kind_of(State::Admin::Registration, @state._search_drugs_state('query', 'st_registration'))
      end
      def test__search_drugs_state__registration_active_package
        package = flexmock('package') do |pac|
          pac.should_receive(:ikscd)
        end
        registration = flexmock('registration') do |reg|
          reg.should_receive(:active_packages).and_return([package])
        end
        flexmock(@session) do |s|
          s.should_receive(:registration).and_return(registration)
        end
        flexmock(@state) do |s|
          s.should_receive(:allowed?).and_return(false)
        end
        assert_kind_of(State::Drugs::Package, @state._search_drugs_state('query', 'st_registration'))
      end
      def test__search_drugs_state__registration_else
        registration = flexmock('registration') do |reg|
          reg.should_receive(:active_packages).and_return([])
        end
        flexmock(@session) do |s|
          s.should_receive(:registration).and_return(registration)
        end
        flexmock(@state) do |s|
          s.should_receive(:allowed?).and_return(false)
        end
        assert_kind_of(State::Drugs::Registration, @state._search_drugs_state('query', 'st_registration'))
      end
      def test__search_drugs_state__pharmacode
        package = flexmock('package')
        flexmock(@session) do |s|
          s.should_receive(:package).and_return(package)
        end
        assert_kind_of(State::Admin::Package, @state._search_drugs_state('query', 'st_pharmacode'))
      end
      def test__search_drugs_state__pharmacode_else
        package = flexmock('package')
        flexmock(@session) do |s|
          s.should_receive(:package).and_return(package)
        end
        flexmock(@state) do |s|
          s.should_receive(:allowed?).and_return(false)
        end
        assert_kind_of(State::Drugs::Package, @state._search_drugs_state('query', 'st_pharmacode'))
      end
      def test__search_drugs_state__else
        result = flexmock('result') do |r|
          r.should_receive(:filter!)
        end
        flexmock(@state) do |s|
          s.should_receive(:_search_drugs).and_return(result)
        end
        lookandfeel = flexmock('lookandfeel') do |lnf|
          lnf.should_receive(:has_result_filter?).and_return(true)
          lnf.should_receive(:result_filter)
        end
        flexmock(@session) do |s|
          s.should_receive(:lookandfeel).and_return(lookandfeel)
          s.should_receive(:flavor).and_return(nil)
        end
        assert_kind_of(State::Drugs::Result, @state._search_drugs_state('query', 'else'))
      end
      def test_show
        flexmock(@session) do |s|
          s.should_receive(:request_path).and_return('request_path')
        end
        @state.instance_eval('@request_path = "request_path"')
        assert_equal(@state, @state.show)
      end
      def test_show__else_pointer
        klass = flexmock('klass') do |klass|
          klass.should_receive(:new).and_return('klass.new')
        end
        flexmock(@state) do |s|
          s.should_receive(:resolve_state).and_return(klass)
        end
        pointer = flexmock('pointer') do |ptr|
          ptr.should_receive(:is_a?).and_return(true)
          ptr.should_receive(:resolve).and_return('model')
        end
        flexmock(@session) do |s|
          s.should_receive(:user_input).once.with(:pointer).and_return(pointer)
          s.should_receive(:user_input).once.with(:reg).and_return(nil)
          s.should_receive(:user_input).once.with(:seq).and_return(nil)
          s.should_receive(:user_input).once.with(:pack).and_return(nil)
        end
        assert_equal('klass.new', @state.show)
      end
      def test_show__else_package
        klass = flexmock('klass') do |klass|
          klass.should_receive(:new).and_return('klass.new')
        end
        flexmock(@state) do |s|
          s.should_receive(:resolve_state).and_return(klass)
        end
        pointer = flexmock('pointer') do |ptr|
          ptr.should_receive(:is_a?).and_return(true)
          ptr.should_receive(:resolve).and_return('model')
        end
        package      = flexmock('package', :pointer => pointer)
        sequence     = flexmock('sequence', 
                                :package => package,
                                :pointer => pointer
                               )
        registration = flexmock('registration', 
                                :sequence => sequence,
                                :pointer  => pointer
                               )
        flexmock(@session.app, :registration => registration)
        flexmock(@session) do |s|
          s.should_receive(:user_input).once.with(:reg).and_return('iksnr')
          s.should_receive(:user_input).once.with(:seq).and_return('seqnr')
          s.should_receive(:user_input).once.with(:pack).and_return('ikscd')
        end
        assert_equal('klass.new', @state.show)
      end
      def test_show__else_sequence
        klass = flexmock('klass') do |klass|
          klass.should_receive(:new).and_return('klass.new')
        end
        flexmock(@state) do |s|
          s.should_receive(:resolve_state).and_return(klass)
        end
        pointer = flexmock('pointer') do |ptr|
          ptr.should_receive(:is_a?).and_return(true)
          ptr.should_receive(:resolve).and_return('model')
        end
        package      = flexmock('package', :pointer => pointer)
        sequence     = flexmock('sequence', 
                                :package => package,
                                :pointer => pointer
                               )
        registration = flexmock('registration', 
                                :sequence => sequence,
                                :pointer  => pointer
                               )
        flexmock(@session.app, :registration => registration)
        flexmock(@session) do |s|
          s.should_receive(:user_input).once.with(:reg).and_return('iksnr')
          s.should_receive(:user_input).once.with(:seq).and_return('seqnr')
          s.should_receive(:user_input).once.with(:pack).and_return(nil)
        end
        assert_equal('klass.new', @state.show)
      end
      def test_show__else_registration
        klass = flexmock('klass') do |klass|
          klass.should_receive(:new).and_return('klass.new')
        end
        flexmock(@state) do |s|
          s.should_receive(:resolve_state).and_return(klass)
        end
        pointer = flexmock('pointer') do |ptr|
          ptr.should_receive(:is_a?).and_return(true)
          ptr.should_receive(:resolve).and_return('model')
        end
        package      = flexmock('package', :pointer => pointer)
        sequence     = flexmock('sequence', 
                                :package => package,
                                :pointer => pointer
                               )
        registration = flexmock('registration', 
                                :sequence => sequence,
                                :pointer  => pointer
                               )
        flexmock(@session.app, :registration => registration)
        flexmock(@session) do |s|
          s.should_receive(:user_input).once.with(:reg).and_return('iksnr')
          s.should_receive(:user_input).once.with(:seq).and_return(nil)
          s.should_receive(:user_input).once.with(:pack).and_return(nil)
        end
        assert_equal('klass.new', @state.show)
      end
      class StubState < State::Global
        SNAPBACK_EVENT = "snapback_event"
      end
      def test_snapback_event
        state = StubState.new(@session, @session)
        #@state.instance_eval('SNAPBACK_EVENT = "snapback_event"')
        assert_equal('snapback_event', state.snapback_event)
      end
      def test_snapback_event__direct_event
        assert_equal(@state.instance_eval('DIRECT_EVENT'), @state.snapback_event)
      end
      def test_sort
        @state.instance_eval('@model = []')
        assert_equal(@state, @state.sort)
      end
      def test_sponsorlink
        sponsor = flexmock('sponsor') do |s|
          s.should_receive(:valid?).and_return(true)
        end
        flexmock(@session) do |s|
          s.should_receive(:sponsor).and_return(sponsor)
        end
        assert_kind_of(State::User::SponsorLink, @state.sponsorlink)
      end
      def test_suggest_address
        parent = flexmock('parent') do |par|
          par.should_receive(:fullname)
        end
        pointer = flexmock('pointer') do |ptr|
          ptr.should_receive(:resolve)
          ptr.should_receive(:parent).and_return(parent)
        end
        flexmock(parent) do |par|
          par.should_receive(:resolve).and_return(parent)
        end
        input = {:pointer => pointer}
        flexmock(@state) do |s|
          s.should_receive(:user_input).and_return(input)
        end
        assert_kind_of(State::SuggestAddress, @state.suggest_address)
      end
      def test_switch
        flexmock(@session) do |s|
          s.should_receive(:zone)
        end
        assert_equal(@state, @state.switch)
      end
      def test_switch__else
        flexmock(@session) do |s|
          s.should_receive(:zone).and_return('zone')
        end
        assert_equal(@state, @state.switch)
      end
      def test__trigger
        flexmock(@state) do |s|
          s.should_receive(:event).and_return(nil)
        end
        assert_kind_of(Http404, @state._trigger('event'))
      end
      def test_unique_email
        user = flexmock('user') do |u|
          u.should_receive(:unique_email).and_return('unique_email')
        end
        flexmock(@session) do |s|
          s.should_receive(:user).and_return(user)
        end
        assert_equal('unique_email', @state.unique_email)
      end
      def test_unique_email__nil
        assert_equal(nil, @state.unique_email)
      end
      def test_user_input
        flexmock(@session) do |s|
          s.should_receive(:user_input).and_return('hash')
        end
        assert_equal({nil=>"hash"}, @state.user_input)
      end
      def test_ywesee_contact
        assert_kind_of(State::User::YweseeContact, @state.ywesee_contact)
      end
      def test_zones
        expected = [ :analysis, :doctors, :interactions, :drugs, :migel, :user , :hospitals, :companies]
        assert_equal(expected, @state.zones)
      end
      def test_zone_navigation
        assert_equal(@state.instance_eval('ZONE_NAVIGATION'), @state.zone_navigation)
      end
      def test_compare_entries
        @state.instance_eval('@sortby = [:xxx, :sort]')
        assert_equal(-1, @state.instance_eval('compare_entries("a","b")'))
      end
      def test_compare_entries__0
        @state.instance_eval('@sortby = [:chomp!]')
        assert_equal(0, @state.instance_eval('compare_entries("a","b")'))
      end
      def test_compare_entries__plus1
        @state.instance_eval('@sortby = [:chomp!]')
        assert_equal(1, @state.instance_eval('compare_entries("a","b\n")'))
      end
      def test_compare_entries__minus1
        @state.instance_eval('@sortby = [:chomp!]')
        assert_equal(-1, @state.instance_eval('compare_entries("a\n","b")'))
      end
      def test_get_sortby!
        flexmock(@session) do |s|
          s.should_receive(:user_input).and_return('sortvalue')
        end
        assert_equal([:sortvalue], @state.instance_eval('get_sortby!'))
      end
      def test_patinfo
        flexmock(@session) do |s|
          s.should_receive(:user_input).once.with(:reg).and_return('iksnr')
          s.should_receive(:user_input).once.with(:seq).and_return('seqnr')
          s.should_receive(:user_input).once.with(:swissmedicnr).and_return('iksnr')
        end
        patinfo      = flexmock('patinfo', :descriptions => 'descriptions')
        sequence     = flexmock('sequence', :patinfo => patinfo)
        registration = flexmock('registration', :sequence => sequence)
        flexmock(@session.app, :registration => registration)
        assert_kind_of(State::Drugs::Patinfo, @state.patinfo)
      end
      def test_patinfo__http404
        assert_kind_of(Http404, @state.patinfo)
      end
		end
	end
end
