#!/bin/bash
spec_file=(${1//:/ })
log_file=xvfb_`basename -s .rb $spec_file`.log
Xvfb :1 -screen 5 1280x1024x24 -nolisten tcp 2>/dev/null
export DISPLAY=:1.5
bundle exec rspec $1 2>&1 | tee $log_file
status=$?
echo "Result ist $status for $1"
killall Xvfb 2> /dev/null