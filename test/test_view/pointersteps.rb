#!/usr/bin/env ruby
# View::TestPointerSteps -- oddb -- 02.04.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'view/pointersteps'
require 'stub/cgi'

module ODDB
	module View	
		class StubPointerStepsModel
			attr_writer :ancestors, :pointer_descr_enable
			def initialize
				@pointer_descr_enable = true
			end
			def ancestors(arg=nil)
				@ancestors
			end
			def pointer_descr
				'bon'
			end
			def respond_to?(symbol)
				if symbol==:pointer_descr
					@pointer_descr_enable
				else
					super
				end
			end
			def pointer
				self
			end
		end
		class StubPointerStepsAncestor
			attr_reader :pointer_descr
			def initialize(pointer_descr)
				@pointer_descr = pointer_descr
			end
			def pointer
				"-" + @pointer_descr + "-"
			end
		end
		class StubPointerStepsSession
			attr_reader :app
			def attributes(key)
				{}
			end
			def direct_event
				'bon'
			end
			def _event_url(*args)
				(['http://www.oddb.org/de/gcc'] + args).join('/')
			end
			def language
				'de'
			end
			def lookandfeel
				self
			end
			def lookup(key)
				key.to_s.capitalize unless /_title$/.match(key)
			end
			def zone
				'drugs'
			end
		end
		class StubPointerStepsContainer
			def snapback
				"backsnap"
			end
		end

		class TestPointerSteps < Test::Unit::TestCase
			def setup 
				@model = StubPointerStepsModel.new
				@session = StubPointerStepsSession.new
				@container = StubPointerStepsContainer.new
			end
			def test_to_html1
				@model.ancestors = []
				steps = View::PointerSteps.new(@model, @session, @container)
				expected = <<-EOS
<TABLE cellspacing="0">
  <TR>
    <TD class="th-pointersteps">
      Th_pointer_descr
    </TD>
    <TD>
      <A href="http://www.oddb.org/de/gcc/backsnap/zone/drugs" name="backsnap" class="th-pointersteps">
        Backsnap
      </A>
    </TD>
    <TD>
      #{View::PointerSteps::STEP_DIVISOR}
    </TD>
    <TD class="th-pointersteps">
      bon
    </TD>
  </TR>
</TABLE>
				EOS
				assert_equal(expected, CGI.pretty(steps.to_html(CGI.new)))
			end
			def test_to_html2
				@model.ancestors = [
					StubPointerStepsAncestor.new('foo'),
				]
				steps = View::PointerSteps.new(@model, @session, @container)
				expected = <<-EOS
<TABLE cellspacing="0">
<TR>
<TD class="th-pointersteps">Th_pointer_descr</TD>
<TD>
<A href="http://www.oddb.org/de/gcc/backsnap/zone/drugs" name="backsnap" class="th-pointersteps">Backsnap</A>
</TD>
<TD>#{View::PointerSteps::STEP_DIVISOR}</TD>
<TD class="th-pointersteps">
<A href="http://www.oddb.org/de/gcc/resolve/pointer-foo-" name="pointer_descr" class="list">foo</A>
</TD>
<TD>#{View::PointerSteps::STEP_DIVISOR}</TD>
<TD class="th-pointersteps">bon</TD>
</TR>
</TABLE>
				EOS
				assert_equal(expected.tr("\n", ""), steps.to_html(CGI.new))
			end
			def test_to_html3
				@model.ancestors = [
					StubPointerStepsAncestor.new('foo'),
					StubPointerStepsAncestor.new('bar'),
					StubPointerStepsAncestor.new('baz'),
				]
				steps = View::PointerSteps.new(@model, @session, @container)
				expected = <<-EOS
<TABLE cellspacing="0">
<TR>
<TD class="th-pointersteps">Th_pointer_descr</TD>
<TD>
<A href="http://www.oddb.org/de/gcc/backsnap/zone/drugs" name="backsnap" class="th-pointersteps">Backsnap</A>
</TD>
<TD>#{View::PointerSteps::STEP_DIVISOR}</TD>
<TD class="th-pointersteps">
<A href="http://www.oddb.org/de/gcc/resolve/pointer-foo-" name="pointer_descr" class="list">foo</A>
</TD>
<TD>#{View::PointerSteps::STEP_DIVISOR}</TD>
<TD class="th-pointersteps">
<A href="http://www.oddb.org/de/gcc/resolve/pointer-bar-" name="pointer_descr" class="list">bar</A>
</TD>
<TD>#{View::PointerSteps::STEP_DIVISOR}</TD>
<TD class="th-pointersteps">
<A href="http://www.oddb.org/de/gcc/resolve/pointer-baz-" name="pointer_descr" class="list">baz</A>
</TD>
<TD>#{View::PointerSteps::STEP_DIVISOR}</TD>
<TD class="th-pointersteps">bon</TD>
</TR>
</TABLE>
				EOS
				assert_equal(expected.tr("\n", ""), steps.to_html(CGI.new))
			end
			def test_to_html4
				@model.ancestors = []
				@model.pointer_descr_enable = false
				steps = View::PointerSteps.new(@model, @session, @container)
				expected = <<-EOS
<TABLE cellspacing="0">
<TR>
<TD class="th-pointersteps">Th_pointer_descr</TD>
<TD>
<A href="http://www.oddb.org/de/gcc/backsnap/zone/drugs" name="backsnap" class="th-pointersteps">Backsnap</A>
</TD>
</TR>
</TABLE>
				EOS
				assert_equal(expected.tr("\n", ""), steps.to_html(CGI.new))
			end
		end
	end
end
