#!/usr/bin/env ruby
# DoctorsServer -- oddb -- 21.09.2004 -- jlang@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))
$: << File.dirname(__FILE__)

require 'drb/drb'
require 'util/oddbconfig'
require 'emh'

parser = ODDB::DoctorParser.new
DRb.start_service(ODDB::DOCPARSE_URI, parser)

DRb.thread.join
