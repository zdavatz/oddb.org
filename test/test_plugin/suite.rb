#!/usr/bin/env ruby
# encoding: utf-8
# OneDirSuite -- oddb -- 08.02.2011 -- yasaka@ywesee.com
# OneDirSuite -- oddb -- 08.02.2011 -- mhatakeyama@ywesee.com

must_be_run_separately = Dir.glob(File.join(File.dirname(__FILE__), "*.rb")).collect{|x| x.sub(File.dirname(__FILE__)+'/', '')}.sort
must_be_run_separately.delete(File.basename(__FILE__))

must_be_run_separately.delete('hospitals.rb')
must_be_run_separately.delete('refdata_partner.rb')
must_be_run_separately.delete('medwin.rb')
must_be_run_separately.delete('ouwerkerk.rb')

require File.join(File.expand_path(File.dirname(File.dirname(__FILE__))), 'helpers.rb')
runner = OddbTestRunner.new(File.dirname(__FILE__), must_be_run_separately)
runner.run_isolated_tests

if true
  puts "Manully excluded some problematic files (hospitals, medreg, medwin, ouwerkerk"
else
  runner.run_normal_tests
end

runner.show_results_and_exit

