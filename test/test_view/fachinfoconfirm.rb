#!/usr/bin/env ruby
# TestFachinfoConfirm -- oddb -- 24.10.2003 -- rwaltert@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'view/fachinfoconfirm'
require 'stub/cgi'

module ODDB
	class FachinfoConfirmForm < FormList
		attr_accessor :grid
	end
end

class TestFachinfoConfirm < Test::Unit::TestCase
	class StubSession
		attr_writer :error, :warning
		attr_accessor :event, :base_url
		def error?
			@error
		end
		def event_url(event)
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
		@form = ODDB::FachinfoConfirmForm.new(nil, @session)
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
end
