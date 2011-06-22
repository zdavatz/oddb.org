#!/usr/bin/env ruby
# ODDB::State::Admin::TestSponsor- oddb.org -- 21.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/admin/sponsor'
require 'fileutils'

module ODDB
	module State
		module Admin

class TestSponsor < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    company  = flexmock('company', :pointer => 'pointer')
    @app     = flexmock('app', :company_by_name => company)
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    user_input = {:company_name => 'company_name'}
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :user_input  => user_input,
                        :app         => @app
                       )
    @model   = flexmock('model')
    @state   = ODDB::State::Admin::Sponsor.new(@session, @model)
  end
  def test_update__company
    assert_equal(@state, @state.update)
  end
  def test_update__empty_name
    flexmock(@session, :user_input => {:company_name => ''})
    assert_equal(@state, @state.update)
  end
  def test_update__else
    flexmock(@app, :company_by_name => nil)
    assert_equal(@state, @state.update)
  end
  def test_update__logo
    flexmock(@session, 
             :user_input => {
                :company_name => 'company_name', 
                :logo_file    => 'logo_file', 
                :logo_fr      => 'logo_fr'
              }
            )
    assert_equal(@state, @state.update)
  end
  def test_store_logo
    flexmock(File) do |file|
      file.should_receive(:exist?).and_return(true)
      file.should_receive(:delete)
      file.should_receive(:open).and_yield('')
    end
    flexmock(FileUtils, :mkdir_p => nil)
    flexmock(@session, :flavor => 'flavor')
    io = flexmock('io', 
                  :original_filename => 'original_filename',
                  :read => 'read'
                 )
    assert_equal("flavor_key_original_filename", @state.store_logo(io, 'key', 'oldname'))
  end

end

		end # Admin
	end # State
end # ODDB
