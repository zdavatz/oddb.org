#!/usr/bin/env ruby
# DownloadUserTest -- oddb -- 21.12.2004 -- hwyss@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))
$: << File.expand_path('..', File.dirname(__FILE__))

require 'admin/download_user'
require 'test/unit'
require 'stub/odba'

module ODDB
	module Admin
		class DownloadUser
			class Challenge
				AGE_LIMIT = 1
			end
		end
		class ChallengeTest < Test::Unit::TestCase
			def setup
				@challenge = DownloadUser::Challenge.new
			end
			def test_authenticated
				assert_equal(false, @challenge.authenticated?)
				@challenge.authenticate!
				assert_equal(true, @challenge.authenticated?)
			end
			def test_recent
				assert_equal(true, @challenge.recent?)
				sleep(0.6)
				assert_equal(true, @challenge.recent?)
				sleep(0.6)
				assert_equal(false, @challenge.recent?)
				@challenge.authenticate!
				assert_equal(true, @challenge.recent?)
				sleep(0.6)
				assert_equal(true, @challenge.recent?)
				sleep(0.6)
				assert_equal(false, @challenge.recent?)
				@challenge.authenticate!
				assert_equal(false, @challenge.recent?)
			end
		end
		class DownloadUserTest < Test::Unit::TestCase
			def setup
				@user = DownloadUser.new
			end
			def test_create_challenge
				challenge = @user.create_challenge
				assert_instance_of(DownloadUser::Challenge, challenge)
				assert_equal(challenge, @user.challenge(challenge.key))
			end
			def test_authenticated
				assert_equal(false, @user.authenticated?)
				challenge = @user.create_challenge
				assert_equal(false, @user.authenticated?)
				challenge.authenticate!
				assert_equal(true, @user.authenticated?)
				sleep(0.6)
				assert_equal(true, @user.authenticated?)
				sleep(0.6)
				assert_equal(false, @user.authenticated?)
			end
			def test_authenticate
				assert_equal(false, @user.authenticated?)
				challenge = @user.create_challenge
				assert_equal(false, @user.authenticated?)
				@user.authenticate!(challenge.key)
				assert_equal(true, @user.authenticated?)
			end
			def test_authenticate_2
				assert_equal(false, @user.authenticated?)
				challenge = @user.create_challenge
				assert_equal(false, @user.authenticated?)
				assert_nothing_raised {
					@user.authenticate!(challenge.key.next)
				}
				assert_equal(false, @user.authenticated?)
			end
		end
	end
end
