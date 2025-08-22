#!/usr/bin/env ruby

# OneDirSuite -- oddb -- 08.02.2011 -- yasaka@ywesee.com
# OneDirSuite -- oddb -- 08.02.2011 -- mhatakeyama@ywesee.com

must_be_run_separately = Dir.glob(File.join(File.dirname(__FILE__), "*.rb")).collect { |x| x.sub(File.dirname(__FILE__) + "/", "") }.sort
must_be_run_separately.delete(File.basename(__FILE__))

must_be_run_separately.delete("refdata_partner.rb")
must_be_run_separately.delete("ouwerkerk.rb")
must_be_run_separately.delete("medical_products.rb")
must_be_run_separately.delete("swissmedic.rb")
must_be_run_separately.delete("swissmedic_xlsx.rb")

require File.join(File.expand_path(File.dirname(__FILE__, 2)), "helpers.rb")
runner = OddbTestRunner.new(File.dirname(__FILE__), must_be_run_separately)
runner.run_isolated_tests

puts "Manully excluded some problematic files like ouwerkerk"

runner.show_results_and_exit
