#!/usr/bin/env ruby
# ODDB::View::TestPointerSteps -- oddb.org -- 28.04.2011 -- hwyss@ywesee.com 
# ODDB::View::TestPointerSteps -- oddb.org -- 02.04.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
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
			attr_reader :app, :state
      def initialize
        @state = StubPointerStepsState.new
      end
      def allowed?(key, data)
        true
      end
			def attributes(key)
				{}
			end
      def enabled?(key)
        true
      end
			def direct_event
				'bon'
			end
      def disabled?(key)
        false
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
				key.to_s.capitalize unless /_title$/.match(key.to_s)
			end
      def user_agent
        'TEST'
      end
			def zone
				'drugs'
			end
		end
		class StubPointerStepsState
      attr_accessor :snapback_model
		end
		class StubPointerStepsContainer
			def snapback
				["backsnap", "url"]
			end
		end

		class TestPointerSteps < Test::Unit::TestCase
      include FlexMock::TestCase
			def setup 
				@model = StubPointerStepsModel.new
				@session = StubPointerStepsSession.new
				@container = StubPointerStepsContainer.new
			end
			def test_to_html1
				steps = View::PointerSteps.new(@model, @session, @container)
				expected = <<-EOS
<TABLE cellspacing="0">
  <TR>
    <TD class="th-pointersteps">
      Th_pointer_descr
    </TD>
    <TD>
      <A href="url" name="backsnap" class="th-pointersteps">
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
        @session.state.snapback_model = StubPointerStepsAncestor.new('foo')
				steps = View::PointerSteps.new(@model, @session, @container)
				expected = <<-EOS
<TABLE cellspacing="0">
<TR>
<TD class="th-pointersteps">Th_pointer_descr</TD>
<TD>
<A href="url" name="backsnap" class="th-pointersteps">Backsnap</A>
</TD>
<TD>#{View::PointerSteps::STEP_DIVISOR}</TD>
<TD class="th-pointersteps">
<A name="pointer_descr" href="http://www.oddb.org/de/gcc/resolve/pointer-foo-" class="list">foo</A>
</TD>
<TD>#{View::PointerSteps::STEP_DIVISOR}</TD>
<TD class="th-pointersteps">bon</TD>
</TR>
</TABLE>
				EOS
				assert_equal(expected.tr("\n", ""), steps.to_html(CGI.new))
			end
			def test_to_html3
				@model.pointer_descr_enable = false
				steps = View::PointerSteps.new(@model, @session, @container)
				expected = <<-EOS
<TABLE cellspacing="0">
<TR>
<TD class="th-pointersteps">Th_pointer_descr</TD>
<TD>
<A href="url" name="backsnap" class="th-pointersteps">Backsnap</A>
</TD>
</TR>
</TABLE>
				EOS
				assert_equal(expected.tr("\n", ""), steps.to_html(CGI.new))
			end
      def test_compose
        flexmock(@model, :structural_ancestors => [@model])
				steps = ODDB::View::PointerSteps.new(@model, @session, @container)
        assert_equal('th-pointersteps', steps.compose(@model))
      end
      def test_compose_footer
        flexmock(@model, :is_a? => true)
				steps = ODDB::View::PointerSteps.new(@model, @session, @container)
        assert_equal('th-pointersteps', steps.compose_footer)
      end
      def test_compose_snapback
        flexmock(@session, :lookup => nil)
        offset = [0,0]
				steps = ODDB::View::PointerSteps.new(@model, @session, @container)
        assert_equal([1, 0], steps.compose_snapback(offset))
      end
      def test_pointer_descr
        flexmock(@session, :allowed? => nil)
				steps = ODDB::View::PointerSteps.new(@model, @session, @container)
        assert_kind_of(ODDB::View::PointerLink, steps.pointer_descr(@model, @session))
      end

      class StubSnapback
        include ODDB::View::Snapback
        def initialize(model, session)
          @model   = model
          @session = session
        end
      end
      def test_snapback
        previous_state = flexmock('previous_state', 
                                  :snapback_event      => 'snapback_event',
                                  :direct_request_path => 'direct_request_path',
                                  :previous            => nil
                                 )
        state     = flexmock('state', 
                             :direct_event   => nil,
                             :previous       => previous_state,
                             :snapback_event => 'snapback_event'
                            )
        @session  = flexmock('session', :state => state)
        @model    = flexmock('model')
        @snapback = ODDB::View::TestPointerSteps::StubSnapback.new(@model, @session)
        expected = ["snapback_event", "direct_request_path"]
        assert_equal(expected, @snapback.snapback)
      end

		end
	end
end
