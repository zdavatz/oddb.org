#!/usr/bin/env ruby
# TestGroup -- oddb -- 13.09.2005 -- spfenninger@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'model/migel/group'

module ODDB
	module Migel
		class TestGroup < Test::Unit::TestCase
			def setup
				@group = ODDB::Migel::Group.new('02')
			end
			def test_create__subgroup
				subgroup = @group.create_subgroup('02')
				assert_instance_of(Subgroup, subgroup)
				assert_equal({'02' => subgroup}, @group.subgroups)
				assert_equal('02', @group.code)
				assert_equal(@group, subgroup.group)
				assert_equal(subgroup, @group.subgroup('02'))
			end
		end
	end
end

