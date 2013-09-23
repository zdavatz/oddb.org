#!/usr/bin/env ruby
# encoding: utf-8
# suite.rb -- oddb.org -- 09.04.2012 -- yasaka@ywesee.com
# suite.rb -- oddb.org -- 29.03.2011 -- mhatakeyama@ywesee.com 

require 'find'
gem 'minitest'
require 'minitest/autorun'

$: << here = File.expand_path(File.dirname(__FILE__))

Find.find(here) { |file|
	if file.match(/\.rb$/) && !file.match(/suite\.rb/)
    require file
	end
}



#
# tested file list
#
=begin
dir =  File.expand_path(File.dirname(__FILE__))
require File.join(dir, "user/fipi_offer_input.rb")
require File.join(dir, "user/download_export.rb")
require File.join(dir, "substances/substance.rb")
require File.join(dir, "paypal/checkout.rb")
require File.join(dir, "page_facade.rb")
require File.join(dir, "notify.rb")
require File.join(dir, "interactions/result.rb")
require File.join(dir, "interactions/basket.rb")
require File.join(dir, "global.rb")
require File.join(dir, "drugs/test_result.rb")
require File.join(dir, "drugs/register_download.rb")
require File.join(dir, "drugs/init.rb")
require File.join(dir, "define_empty_class.rb")
require File.join(dir, "companies/mergecompanies.rb")
require File.join(dir, "companies/companylist.rb")
require File.join(dir, "companies/company.rb")
require File.join(dir, "admin/sequence.rb")
require File.join(dir, "admin/root.rb")
require File.join(dir, "admin/registration.rb")
require File.join(dir, "admin/patinfo_stats.rb")
require File.join(dir, "admin/package.rb")
require File.join(dir, "admin/mergegalenicform.rb")
require File.join(dir, "admin/login.rb")
require File.join(dir, "admin/galenicgroup.rb")
require File.join(dir, "admin/galenicform.rb")
require File.join(dir, "admin/fachinfoconfirm.rb")
require File.join(dir, "admin/entity.rb")
require File.join(dir, "admin/companyuser.rb")
require File.join(dir, "admin/assign_deprived_sequence.rb")
require File.join(dir, "admin/address_suggestion.rb")
require File.join(dir, "admin/activeagent.rb")
=end

#
# Conflict Memo
#
# Debug procedure if a conflict happens
# 1. uncomment the line one by one 
# 2. check which file causes the conflict
#
# 29.04.2011
# The user_input method in admin/activeagent.rb calles one in src/state/global.rb
# but if src/state/global.rb is not required, the user_input method in SBSM library is called
#
