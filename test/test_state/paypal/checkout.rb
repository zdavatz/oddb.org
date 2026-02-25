#!/usr/bin/env ruby

# ODDB::State::PayPal::TestCheckout -- oddb.org -- 19.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

module ODDB
  module State
    module PayPal
      module Checkout
      end
    end
  end
end

require "minitest/autorun"
require "flexmock/minitest"
require "state/paypal/checkout"

module ODDB
  module State
    module PayPal
      class StubSuper
        def user_input(keys, mandatory)
          {pass: "pass"}
        end
      end

      class StubCheckout < StubSuper
        include Checkout
        def initialize(session, model)
          @session = session
          @model = model
          @errors = {}
        end
      end
    end
  end
end

module ODDB
  module State
    module PayPal
      class TestStubCheckout < Minitest::Test
        def setup
          @app = flexmock("app")
          @session = flexmock("session", app: @app)
          @model = flexmock("model")
          @checkout = ODDB::State::PayPal::StubCheckout.new(@session, @model)
        end

        def test_checkout_mandatory
          flexmock(@session, logged_in?: nil)
          expected = [:salutation, :name_last, :name_first, :email, :pass, :set_pass_2]
          assert_equal(expected, @checkout.checkout_mandatory)
        end

        def test_checkout_keys
          flexmock(@session, logged_in?: nil)
          expected = [:salutation, :name_last, :name_first, :email, :pass, :set_pass_2]
          assert_equal(expected, @checkout.checkout_keys)
        end

        def test_ajax_autofill
          flexmock(@session,
            user_input: "email",
            yus_get_preferences: {"key" => "value"},
            logged_in?: nil)
          assert_kind_of(ODDB::State::PayPal::AjaxCheckout, @checkout.ajax_autofill)
        end

        def test_currency
          assert_equal("CHF", @checkout.currency)
        end

        def test_user_input
          error = flexmock("error",
            message: "e_missing_",
            value: "value")
          flexmock(@checkout, create_error: error)
          expected = {pass: "pass"}
          assert_equal(expected, @checkout.user_input("keys", "mandatory"))
        end

        def test_user_input__no_error
          @checkout.instance_eval('@user = "user"', __FILE__, __LINE__)
          expected = {pass: "pass"}
          assert_equal(expected, @checkout.user_input("keys", "mandatory"))
        end

        def test_create_user
          # create_user is now a no-op (Swiyu credential flow)
          input = {"key" => "value"}
          assert_nil(@checkout.create_user(input))
        end

        def test_create_invoice
          abstract = flexmock("abstract",
            text: "text",
            duration: 1.23,
            price: "price",
            type: "type",
            data: "data",
            quantity: 1)
          flexmock(@model, items: [abstract])
          pointer = flexmock("pointer", creator: "creator")
          flexmock(pointer, :+ => pointer)
          invoice = flexmock("invoice", pointer: pointer)
          flexmock(@app, update: invoice)
          input = {email: "email"}
          flexmock(@checkout, unique_email: "unique_email")
          assert_equal(invoice, @checkout.create_invoice(input))
        end

        def test_checkout
          checkout_user = flexmock("checkout_user", email: "email")
          flexmock(@session,
            input_keys: ["input_key"],
            logged_in?: true,
            user: checkout_user,
            force_login: "force_login",
            set_cookie_input: "set_cookie_input")
          user = flexmock("user",
            set_preferences: "set_preferences",
            allowed?: nil,
            email: "email",
            valid?: true)
          abstract = flexmock("abstract",
            text: "text",
            duration: 1.23,
            price: "price",
            type: "type",
            data: "data",
            quantity: 1)
          flexmock(@model, items: [abstract])
          pointer = flexmock("pointer", creator: "creator")
          flexmock(pointer, :+ => pointer)
          invoice = flexmock("invoice", pointer: pointer)
          flexmock(@app,
            yus_create_user: user,
            update: invoice)
          flexmock(@checkout,
            error?: @checkout.instance_eval("@errors", __FILE__, __LINE__).empty? ? false : true,
            unique_email: "unique_email")
          assert_kind_of(ODDB::State::PayPal::Redirect, @checkout.checkout)
        end

        def test_checkout__missing_keys_empty
          user = flexmock("user",
            set_preferences: "set_preferences",
            allowed?: nil,
            valid?: true,
            email: "email")
          flexmock(@session,
            input_keys: [:email, :pass],
            logged_in?: true,
            user: user,
            login: user,
            force_login: "force_login",
            set_cookie_input: "set_cookie_input")
          abstract = flexmock("abstract",
            text: "text",
            duration: 1.23,
            price: "price",
            type: "type",
            data: "data",
            quantity: 1)
          flexmock(@model, items: [abstract])
          pointer = flexmock("pointer", creator: "creator")
          flexmock(pointer, :+ => pointer)
          invoice = flexmock("invoice", pointer: pointer)
          flexmock(@app,
            yus_create_user: user,
            update: invoice)
          flexmock(@checkout,
            error?: @checkout.instance_eval("@errors", __FILE__, __LINE__).empty? ? false : true,
            unique_email: "unique_email")
          assert_kind_of(ODDB::State::PayPal::Redirect, @checkout.checkout)
        end

        # Yus authentication error test removed — Yus auth replaced by Swiyu OID4VP

        def test_checkout__sbsm_processing_error
          flexmock(@session) do |s|
            s.should_receive(:input_keys).and_return([])
            s.should_receive(:logged_in?).and_raise(SBSM::ProcessingError.new("message", "key", "value"))
          end
          assert_equal(@checkout, @checkout.checkout)
        end
      end
    end # PayPal
  end # State
end # ODDB
