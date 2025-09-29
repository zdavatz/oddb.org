#!/usr/bin/env fish

function show_suite_errors
    set logFile $argv[1]
    set res (grep "returned false" $logFile | grep -v suite.rb | sort | uniq)
    if ! test "$res" = ""
      echo
      echo
      echo "    # Show errors/failures found in $logFile"
      echo
      echo
      echo "## Found the following errors in $logFile"
      egrep -A3 ") Failure|) Error" $logFile
    end
end

function check_suite
    set logFile $argv[1]
    set res (grep "returned false" $logFile | grep -v suite.rb | sort | uniq)
    if test "$res" = ""
      echo "## No errors found in $logFile"
    else
      echo "## Found the following errors in $logFile"
      string collect $res
    end
end

function check_rspec
    set logFile $argv[1]
    set res (grep -E "[0-9]+) |Watir::Wait::TimeoutError|[0-9] examples" $logFile)
    if test "$res" = ""
      echo "## No errors found in $logFile"
    else
      echo "## Found errors in $logFile"
      string collect $res
      set nr_errors (grep -c 'rspec .' $logFile)
      echo "Found $nr_errors rspec errors in $logFile. Expected 69"

      set expectedSmokeErrors 31
      set smokeErrors (grep -c 'rspec ./spec/smoketest_spec.rb' $logFile)
      if test $expectedSmokeErrors -eq $smokeErrors
        echo "Expected smokeTestErrors $smokeErrors found"
      else if test "$expectedSmokeErrors" -lt "$smokeErrors"
        echo ""
        echo "Found too many $smokeErrors Smoketest Errors! We expected only $expectedSmokeErrors"
        echo "  Wherefrom stem the" (math $smokeErrors - $expectedSmokeErrors) "new smoketest errors???"
        echo ""
      else
        echo "Good found only $smokeErrors Smoketest Errors! We expected $expectedSmokeErrors"
        echo "Please reduce in " (status -f) " expectedSmokeErrors to $smokeErrors"
      end
    end
end

function check_import
    echo
    set logFile $argv[1]
    set mails (grep -o 'log notify.*'  $logFile | grep -v Error:)
    echo "## " (basename $logFile)
    echo
    echo "The following mails were found in $logFile"
    string collect $mails
    set res (egrep -o 'log notify Error:.*' $logFile)
    if test "$res" = ""
      echo "No Error mails sent in $logFile"
    else
      echo "The following error mails were sent in $logFile"
      string collect $res
    end
    set res (grep Interrupted $logFile)
    if ! test "$res" = ""
      echo
      echo (basename $logFile) " Import was interruped! "
      echo
    end
end

set dir2check $argv[1]
if test "$dir2check" = ""
  set dir2check "."
end

set full (path resolve $dir2check)
echo "# Creating report for $full" ( date '+%Y.%m.%d %H:%M:%S')
echo
echo Distribution (lsb_release -d)
echo Ruby (ruby --version)
echo Host was (hostname)
echo Memory (free -mh | tail -n2 | head -n1 | cut -c10-19)

check_suite $dir2check/ci_log/suite.log
show_suite_errors $dir2check/ci_log/suite.log
for logFile in $dir2check/ci_log/import_*
  check_import $logFile
end
check_rspec $dir2check/ci_log/rspec.log
