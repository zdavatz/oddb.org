#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::TestFAchinfoConfirm -- oddb.org -- 23.06.2011 -- mhatakeyama@ywesee.com
# ODDB::View::Drugs::TestFachinfoConfirm -- oddb.org -- 24.10.2003 -- rwaltert@ywesee.com

$: << File.expand_path("../..", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'view/admin/fachinfoconfirm'
require 'stub/cgi'
require 'flexmock'

module ODDB
	module View
		module Admin
      class FachinfoConfirmForm < View::FormList
	      attr_accessor :grid
      end
		end
	end
end
class TestFachinfoConfirmForm <Minitest::Test
  include FlexMock::TestCase
	class StubSession
		attr_writer :error, :warning
		attr_accessor :event, :base_url
		def error?
			@error
		end
		def event_url(event, *args)
			event.to_s
		end
		def warning?
		end
		def lookandfeel
			self
		end
		def lookup(*args)
			'lookup'
		end
		def attributes(*args)
			{}
		end
		def flavor
			"gcc"
		end
		def language
			'de'
		end
		def state
			self
		end
	end
	def setup
		@session = StubSession.new
    flexstub(@session) do |ses|
      ses.should_receive(:zone)
    end
		@form = ODDB::View::Admin::FachinfoConfirmForm.new(nil, @session)
	end
	def test_compose_footer1
		grid = @form.grid = HtmlGrid::Grid.new()
		grid.add(nil, 3,0)
		@form.compose_footer([0,0])
		html = @form.to_html(CGI.new)
		expected = [
			'<FORM ACCEPT-CHARSET="ISO-8859-1" NAME="stdform" METHOD="POST" ENCTYPE="application/x-www-form-urlencoded"><TABLE cellspacing="0" class="composite"><TR><TD colspan="4">',
			'<INPUT name="back" onClick="document.location.href=\'back\';" type="button" value="lookup">',
			'<INPUT name="update" type="submit" value="lookup">',
		]
		expected.each { |line| 
			assert(html.index(line), "missing: #{line}\nin:\n#{html}")
		}
	end
	def test_compose_footer2
		grid = @form.grid = HtmlGrid::Grid.new
		grid.add(nil, 3,0)
		@session.error = true
		@form.compose_footer([0,0])
		html = @form.to_html(CGI.new)
		expected = [
			'<FORM ACCEPT-CHARSET="ISO-8859-1" NAME="stdform" METHOD="POST" ENCTYPE="application/x-www-form-urlencoded"><TABLE cellspacing="0" class="composite"><TR><TD colspan="4">',
			'<INPUT name="back" onClick="document.location.href=\'back\';" type="button" value="lookup">',
		]
		expected.each { |line| 
			assert(html.index(line), "missing: #{line}\nin:\n#{html}")
		}
		line = '<INPUT name="update" type="submit" value="lookup">'
		assert_nil(html.index(line), "found: #{line}\nin:\n#{html}\n...but it should not be there!")
	end
  def test_iksnrs
    flexmock(@session, :iksnrs => ['iksnr'])
    model = flexmock('model')
    assert_equal('iksnr', @form.iksnrs(model, @session))
  end
  def test_language
    model = flexmock('model')
    assert_equal('lookup', @form.language(model, @session))
  end
  def test_preview
    model = flexmock('model')
    assert_kind_of(HtmlGrid::PopupLink, @form.preview(model, @session))
  end
end

