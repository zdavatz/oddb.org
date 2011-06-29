#!/usr/bin/env ruby
# ODDB::TestSmjPlugin -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com
# ODDB::TestSmjPlugin -- oddb.org -- 30.04.2003 -- benfay@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'plugin/swissmedicjournal'

class Object
  @@today = Date.today
end
module ODDB
  class TestSmjPlugin < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      sequence = flexmock('sequence', :pointer => 'pointer')
      @app = flexmock('app', 
                      :registration => nil,
                      :atcless_sequences => [sequence]
                     )
      @plugin = ODDB::SwissmedicJournalPlugin.new(@app)
    end
    def test_report
      expected = "ODDB::SwissmedicJournalPlugin - Report \nTotal Sequences without ATC-Class: 1\nError creating Link for nil"
      assert_equal(expected, @plugin.report)
    end
    def test_update
      smj  = flexmock('smj', :save => 'save')
      node = flexmock('node', 
                      :attributes => {'title' => 'Swissmedic Journal'},
                      :click => smj
                     )
      result = flexmock('result', :links => [node])
      flexmock(Mechanize).new_instances do |agent|
        agent.should_receive(:get).and_return(result)
      end
      assert_equal('save', @plugin.update(Time.local(2011,2,3)))
    end
  end
end
