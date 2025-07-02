source "https://rubygems.org"
gem 'dbi', :git => 'https://github.com/zdavatz/ruby-dbi'
# Worksround for ruby 3.1,https://stackoverflow.com/questions/70500220/rails-7-ruby-3-1-loaderror-cannot-load-such-file-net-smtp
# https://github.com/mikel/mail/pull/1439
gem 'yus', "1.0.6"

gem 'net-smtp', require: false
gem 'net-imap', require: false
gem 'net-pop', require: false
gem 'odba', "1.1.9"
gem 'htmlgrid', '1.2.2'
gem 'sbsm', '1.6.1'
gem 'ydbd-pg', '0.5.9'
gem 'ydbi', '0.5.9'
gem 'gruff','0.8.0' # to be backward compatible with Ruby 3.2
gem 'rmagick', '4.2.4' # to be backward compatible with Ruby 3.2
gem 'observer'
gem 'csv'
gem 'logger'

gem 'simple_xlsx_reader'
gem 'rubyXL'
gem 'xsv'
gem 'cmath'
gem 'minitar'
gem 'webrick'
gem 'rss'
gem 'bigdecimal'
gem 'builder'
gem 'clogger'
gem 'chrono_logger'
gem 'ydiffy'
gem 'deprecated'
gem 'flickraw'
gem 'hpricot'
gem 'sax-machine'
gem 'htmlentities'
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
gem 'activesupport'
gem 'paypal'
gem 'parslet'
gem 'pg'
gem 'rclconf'
gem 'racc'
gem 'rack'
gem 'rackup'
gem 'ruby-units'
gem "rubyntlm"
gem "rubyzip", :require => 'zip'
gem 'savon'
gem 'spreadsheet'
gem 'swissmedic-diff'
gem 'optimist'
gem 'webrobots'
gem 'ydocx'

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
  gem 'getoptlong' # for starting yusd via gem: bundle exec ruby (which yusd)
end

group :debugger do
  gem 'rbs'
  gem 'typeprof'
  gem 'debug'
end
