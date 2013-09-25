#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::User::TestMailingList -- oddb.org -- 24.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/user/mailinglist'


module ODDB
  module View
    module User

class TestMailingListForm <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @form    = ODDB::View::User::MailingListForm.new(@model, @session)
  end
  def test_subscribe
    assert_kind_of(HtmlGrid::Submit, @form.subscribe(@model, @session))
  end
end

class TestMailingListInnerComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :base_url   => 'base_url'
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :warning?    => nil,
                          :error?      => nil,
                          :info?       => nil
                         )
    @model     = flexmock('model')
    @composite = ODDB::View::User::MailingListInnerComposite.new(@model, @session)
  end
  def test_init
    assert_nil(@composite.init)
  end
end

class TestMailingListComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :base_url   => 'base_url'
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :warning?    => nil,
                          :error?      => nil,
                          :info?       => nil
                         )
    @model     = flexmock('model')
    @composite = ODDB::View::User::MailingListComposite.new(@model, @session)
  end
  def test_score
    assert_equal('&nbsp;-&nbsp;', @composite.score(@model, @session))
  end
end

    end # User
  end # View
end # ODDB
