#!/usr/bin/env ruby
# encoding: utf-8
# 20121130

# Please set your environments
mail = ''
# default
DEVELOPER_MAIL = (mail.empty? ? `git config --get user.email`.chomp : mail)

puts
puts "loading testenvironment2"
puts
puts "DEVELOPER_MAIL = #{DEVELOPER_MAIL}"
puts

