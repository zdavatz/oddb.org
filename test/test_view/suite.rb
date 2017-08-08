#!/usr/bin/env ruby
# encoding: utf-8
# OneDirSuite -- oddb -- 09.04.2012 -- yasaka@ywesee.com
# OneDirSuite -- oddb -- 08.02.2011 -- mhatakeyama@ywesee.com
$: << File.expand_path(File.dirname(__FILE__))

run_isolated =  ['searchbar.rb',
                 'navigationfoot.rb',
                 'admin/fachinfoconfirm.rb',
                 'drugs/fachinfo.rb',
                 'drugs/fachinfo_change_logs.rb',
                 'drugs/javascript.rb',
                 'interactions/interaction_chooser.rb',
                ]
require File.join(File.expand_path(File.dirname(File.dirname(__FILE__))), 'helpers.rb')
runner = OddbTestRunner.new(File.dirname(__FILE__), run_isolated)
runner.run_isolated_tests
runner.run_normal_tests
runner.show_results_and_exit
