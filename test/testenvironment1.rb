#!/usr/bin/env ruby
# encoding: utf-8
# 20121130

# Please set your environments
host  = ''
mail = ''
# default
DEVELOPER_HOST = (host.empty? ? "ch.oddb.#{ENV['USER']}.org" : host)
DEVELOPER_MAIL = (mail.empty? ? `git config --get user.email`.chomp : mail)

puts
puts "loading testenvironment"
puts
puts "DEVELOPER_HOST = #{DEVELOPER_HOST}"
puts "DEVELOPER_MAIL = #{DEVELOPER_MAIL}"
puts

module ODDB
  {
    :SERVER_NAME     => DEVELOPER_HOST,
    :PAYPAL_SERVER   => 'www.sandbox.paypal.com',
    :PAYPAL_RECEIVER => DEVELOPER_MAIL,
  }.each_pair do |const, value|
    remove_const const
    const_set const, value
  end
  class App < SBSM::DRbServer
    remove_const :RUN_UPDATER
    RUN_UPDATER = false
    puts "disabling UPDATER"
  end
end
