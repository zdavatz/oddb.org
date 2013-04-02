$: << Dir.pwd # for ruby 1.9.2 and newer
require 'lib/quanty/parse.rb'
require 'lib/quanty/fact.rb'

Quanty::Fact::mkdump ARGV[0]
