source "https://rubygems.org"
gem 'dbi', :git => 'https://github.com/zdavatz/ruby-dbi'
gem 'odba', "1.1.9"

# Worksround for ruby 3.1,https://stackoverflow.com/questions/70500220/rails-7-ruby-3-1-loaderror-cannot-load-such-file-net-smtp
# https://github.com/mikel/mail/pull/1439
gem 'net-smtp', require: false
gem 'net-imap', require: false
gem 'net-pop', require: false

gem 'rubyXL'
gem 'xsv'
gem 'cmath'
gem 'minitar'
gem 'webrick'
gem 'rss'
gem 'bigdecimal'
gem 'builder'
gem 'clogger'
gem 'ydbd-pg'
gem 'ydiffy'
gem 'deprecated'
gem 'flickraw'
gem 'gruff', '0.8'; #, '0.13' #, '0.8' # version 0.9/0.10  fail if now max given
gem 'hpricot'
gem 'sax-machine'
gem 'htmlentities'
gem 'htmlgrid'
gem 'httpi'
gem 'i18n'
gem 'json'
gem 'mail'
gem 'mechanize'
gem 'mime-types'
gem 'money'
gem 'multi_json'
gem 'needle'
gem 'net-http-digest_auth'
gem 'net-http-persistent'
gem 'nokogiri'
gem 'ox'
gem 'oddb2tdat'
gem 'activesupport', '<7.0'
gem 'paypal'
gem 'parslet'
gem 'pg'
gem 'rclconf'
gem 'rmagick', '4.2.4'
gem 'racc'
gem 'rack'
gem 'rackup'
gem 'ruby-units'
gem "rubyntlm"
gem "rubyzip", :require => 'zip'
gem 'savon'
gem 'sbsm'
gem 'spreadsheet'
gem 'swissmedic-diff', '0.2.8'
gem 'optimist'
gem 'webrobots'
gem 'ydocx'
gem 'yus'

group :development, :test do
  gem "standard"
  gem "rake"
  gem 'flexmock'
  gem 'simplecov'
  gem 'travis-lint'
end

gem 'diff-lcs'

group :test do
  gem 'rspec'
  gem 'rspec-core'
  gem 'minitest'
  gem 'minitest-hooks'
  gem 'minitest-should_syntax'
  gem 'minitest-spec-expect'
  gem 'watir'
  gem 'page-object'
  gem 'vcr'
  gem 'webmock'
  gem 'rack-test'
end

group :debugger do
  gem 'rbs'
  gem 'typeprof'
  gem 'debug'
end
