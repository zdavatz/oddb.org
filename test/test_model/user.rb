#!/usr/bin/env ruby
# TestUser -- oddb -- 23.07.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/user'
require 'digest/md5'

module ODDB
	class User < SBSM::KnownUser
		public :adjust_types
	end
end

class TestOddbUser < Test::Unit::TestCase
	class StubApp
		attr_accessor :users
		def user_by_email(email)
			@users.values.select { |user| user.unique_email == email }.first
		end
	end

	def setup
		@app = StubApp.new
		@root = ODDB::RootUser.new
		@root.unique_email = 'hwyss@ywesee.com'
		@root.pass_hash = Digest::MD5.hexdigest('test')
		@user = ODDB::User.new
		@app.users = { @root.oid => @root, @user.oid =>	@user }	
	end
	def test_unique_email
		assert_nothing_raised {
			@user.adjust_types({:unique_email=>'zdavatz@ywesee.com'}, @app)
		}
		assert_raises(RuntimeError) {
			@user.adjust_types({:unique_email=>'hwyss@ywesee.com'}, @app)
		}
		@user.unique_email = 'zdavatz@ywesee.com'
		assert_nothing_raised {
			@user.adjust_types({:unique_email=>'zdavatz@ywesee.com'}, @app)
		}
	end
	def test_identified_by
		assert_equal(true, @root.identified_by?('hwyss@ywesee.com', @root.pass_hash))
		assert_equal(false, @root.identified_by?('hwyss@ywesee.com', '12345'))
		assert_equal(false, @root.identified_by?('badmaash@hotmail.com', @root.pass_hash))
		assert_equal(false, @root.identified_by?('badmaash@hotmail.com', '12345'))
	end
end
