#!/usr/bin/env ruby

conn = Apache.request.connection
sleep 10
$stderr << conn.aborted? << $/
