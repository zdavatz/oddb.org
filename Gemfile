source "http://rubygems.org"
if /^2/.match(RUBY_VERSION)
  gem 'dbi', :git => 'https://github.com/ngiger/ruby-dbi'
  gem 'syck'
else
  ruby "1.9.3"
  gem 'dbi', :git => 'https://github.com/ngiger/ruby-dbi'
end

gem 'activesupport', '3.1.0'
gem 'archive-tarsimple', '1.1.1'
gem 'bigdecimal', '1.1.0'
gem 'builder', '3.2.2'
gem 'dbd-pg', '0.3.9'
gem 'deprecated', '2.0.1'
gem 'facets', '1.8.54'
gem 'fastthread', '1.0.7'
gem 'flickraw', '0.9.8'
gem 'gruff', '0.5.1'
gem 'hpricot', '0.8.6'
gem 'sax-machine'
gem 'htmlentities', '4.3.1'
gem 'htmlgrid', '1.0.6'
gem 'httpi', '2.4.1'
gem 'i18n', '0.6.9'
gem 'json', '1.8.1'
gem 'mail' , '2.2.7'
gem 'mechanize', '2.7.3'
gem 'mime-types' # , '2.1'
gem 'money', '3.7.1'
gem 'multi_json', '1.0.4'
gem 'needle', '1.3.0'
gem 'net-http-digest_auth', '1.2'
gem 'net-http-persistent', '2.7'
gem 'nokogiri', '1.6.1'
gem 'odba', '1.1.0'
gem 'oddb2tdat', '1.1.2'
gem 'paypal', '2.0.0'
gem 'parslet', '1.7.0'
gem 'pg', '0.12.0'
gem 'rclconf', '1.0.0'
gem 'rdoc', '3.9.4'
gem 'rmail', '1.0.0'
gem 'rmagick', '2.13.4' # cannot build 2.13.2 on oddb-ci2
gem 'rpdf2txt', '0.8.4'
gem 'racc', '1.4.11'
gem 'rubyXL', '3.3.1'
gem "rubyntlm", '0.5.1'
gem "rubyzip", ">= 1.1.6" , :require => 'zip'
gem 'savon', '~>2.11.1'
gem 'sbsm',  '1.2.3' # , :git => 'https://github.com/ngiger/sbsm.git'
gem 'spreadsheet', '0.9.7'
# gem 'swissmedic-diff', '0.2.1', :git => 'https://github.com/ngiger/swissmedic-diff.git'
gem 'swissmedic-diff', '0.2.1'
gem 'webrobots', '0.1.1'
gem 'ydim', '1.0.0'
gem 'ydocx', '1.2.5'
gem 'yus', '1.0.0'

group :development, :test do
  gem "rake"
  gem 'flexmock','~> 1.3.0'
  gem 'hoe'
  gem 'hoe-travis'
  gem 'minitest', '>=5.0'
  gem 'simplecov', '~> 0.7.1'
  gem 'travis-lint'
end

group :test do
  gem 'rspec'
  gem 'rspec-core'
  gem 'minitest-should_syntax'
  gem 'watir'
  gem 'watir-webdriver'
  gem 'page-object'
  gem 'vcr'
  gem 'webmock'
end

group :debugger do
if /^2/.match(RUBY_VERSION)
  gem 'pry-byebug'
else
  gem 'pry-debugger'
end
end
