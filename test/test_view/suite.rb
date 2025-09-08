#!/usr/bin/env ruby

# OneDirSuite -- oddb -- 09.04.2012 -- yasaka@ywesee.com
# OneDirSuite -- oddb -- 08.02.2011 -- mhatakeyama@ywesee.com
$: << __dir__

run_isolated = ["searchbar.rb",
  "personal.rb",
  "navigationfoot.rb",
  "admin/fachinfoconfirm.rb",
  "drugs/fachinfo.rb",
  "drugs/fachinfo_change_logs.rb",
  "interactions/interaction_chooser.rb"]
require File.join(File.expand_path(File.dirname(__FILE__, 2)), "helpers.rb")
runner = OddbTestRunner.new(File.dirname(__FILE__), run_isolated)
runner.run_isolated_tests
runner.run_normal_tests
runner.show_results_and_exit
