#!/usr/bin/env ruby

# ODDB::View::TestPersonal -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "htmlgrid/urllink"
require "view/personal"
require "stub/cgi"

module ODDB
  module View
    class StubPersonal
      include ODDB::View::Personal
      def initialize(model, session)
        @model = model
        @session = session
        @lookandfeel = session.lookandfeel
      end
    end

    class TestPersonal < Minitest::Test
      def setup
        @lnf = flexmock("lookandfeel",
          attributes: {},
          lookup: "lookup",
          resource_global: "resource_global")
        @yus_model = flexmock("yus_model",
          name: "name",
          url: "url",
          logo_filename: "logo_filename")
        @app = flexmock("app", yus_model: @yus_model)
        @user = flexmock("user",
          is_a?: true,
          name: "name",
          name_first: "name_first",
          name_last: "name_last")
        @session = flexmock("session",
          lookandfeel: @lnf,
          app: @app,
          user: @user)
        @model = flexmock("model")
        @view = ODDB::View::StubPersonal.new(@model, @session)
      end

      def test_welcome
        assert_kind_of(HtmlGrid::Div, @view.personal(@model, @session))
        assert_kind_of(String, @view.personal(@model, @session).to_html(CGI.new))
        assert_equal('<DIV class="personal">lookup</DIV>', @view.personal(@model, @session).to_html(CGI.new))
      end
    end
  end # View
end # ODDB
