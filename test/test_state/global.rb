#!/usr/bin/env ruby
# State::TestGlobal -- oddb -- 03.04.2011 -- mhatakeyama@ywesee.com
# State::TestGlobal -- oddb -- 13.10.2003 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'stub/odba'
require 'test/unit'
require 'state/global'
require 'mock'
require 'util/language'
require 'sbsm/state'
require 'flexmock'

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
		class TestGlobal < Test::Unit::TestCase
      include FlexMock::TestCase
			class StubSession
				attr_accessor :user_input, :request_path
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
				@session = StubSession.new
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
          s.should_receive(:user_input).and_return(pointer) 
        end
				newstate = @state.resolve
				assert_instance_of(State::Companies::Company, newstate)
			end
			def test_resolve__print1
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
        assert_kind_of(State::Drugs::Feedbacks, @state.feedbacks)
      end
      def test_feedbacks__product
        item = flexmock('item') do |i|
          i.should_receive(:odba_instance).and_return(ODDB::Migel::Product.new('code'))
        end
        pointer = flexmock('pointer') do |ptr|
          ptr.should_receive(:is_a?).and_return(true)
          ptr.should_receive(:resolve).and_return(item)
        end
        flexmock(@session) do |s|
          s.should_receive(:user_input).and_return(pointer)
        end
        assert_kind_of(State::Migel::Feedbacks, @state.feedbacks)
      end
      def test_feedbacks__nil
        assert_equal(nil, @state.feedbacks)
      end
		end
	end
end
