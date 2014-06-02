#!/bin/env/which ruby

# small module which allows to run some unit-test seprately
#
# Some unit tests of ODDB work fine when called as individual files, but fail miserably
# when all other unit tests are included.
# To work aroung this bug, we run some files separately

require 'simplecov'; # configuration is done in file .simplcov
group = File.basename(File.dirname(File.expand_path($0)))
SimpleCov.command_name group
SimpleCov.start

class OddbTestRunner
  DryRun = false

  def initialize(root_dir, tests_to_run_in_isolation = [])
    @rootDir = root_dir
    @tests_to_run_in_isolation = []
    tests_to_run_in_isolation.each {
      |file|
    @tests_to_run_in_isolation << File.expand_path(File.join(root_dir, file))  }
  end
                 
  @@directories =  Hash.new

  def run_isolated_tests
    @tests_to_run_in_isolation.each {
      |path, res|
      result =true
      rubyExe = 'bundle exec ruby'
      puts "\n#{Time.now}: OddbTestRunner::Now testing #{path} #{res} using #{rubyExe}\n"
      base = File.basename(path).sub('.rb', '')
      group_name = File.basename(File.dirname(path), '.rb').sub('test_','')
      group_name += ':'+base unless base.eql?('suite')
      cmd = "#{rubyExe} -e\"require 'simplecov'; SimpleCov.maximum_coverage_drop 99; SimpleCov.command_name '#{group_name}'; SimpleCov.start; require '#{path}'\""
      # cmd = "#{rubyExe} -e\"require '#{path}'\""
      if DryRun
        puts "would exec #{cmd}"
      else
        result = system(cmd)
        puts "#{Time.now}: OddbTestRunner::Running #{path} failed  " unless result
      end      
      @@directories[path] = result
    }
  end

  def run_normal_tests(tests2Run = Dir.glob(File.join(@rootDir, '**', '*.rb')))
    return
    tests2Run.each do
      |file|
        next if File.basename(file).eql?('suite.rb')
        next if File.expand_path(file).sub(File.expand_path(@rootDir), '').index('/src/')
        next if File.expand_path(file).sub(File.expand_path(@rootDir), '').index('/data/')
        if @tests_to_run_in_isolation.index(File.expand_path(file))
            puts "Skipping file #{file}" if DryRun
            next
        elsif DryRun
          puts "Would require #{File.expand_path(file)}"
        else
          # puts "require #{File.expand_path(file)}"
          require File.expand_path(file)
        end
    end
  end

  def show_results_and_exit
    okay = true
    @@directories.each{
      |path,res|
        puts "#{path} returned #{res}"
        okay = false unless res
    }
    puts "#{Time.now}: OddbTestRunner::Overall result for #{@rootDir} is #{okay}"
    exit 2 unless okay
    okay
  end
end

