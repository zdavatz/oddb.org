#/bin/bash -v
set -x
export PATH=/usr/local/bin:$PATH
gem --version
gem update --system 2.2.1
gem --version
# thinpower had on july-4-2015 2.2.1, did not work on oddb-ci wiht version 2.4.8

gem install activesupport --version=3.1.0
gem install archive-tarsimple --version=1.1.1
gem install bigdecimal --version=1.1.0
gem install builder --version=3.2.2
gem install dbd-pg --version=0.3.9
gem install deprecated --version=2.0.1
gem install facets --version=1.8.54
gem install fastthread --version=1.0.7
gem install flickraw --version=0.9.8
gem install gruff --version=0.5.1
gem install hpricot --version=0.8.6
gem install htmlentities --version=4.3.1
gem install htmlgrid --version=1.0.6
gem install httpi --version=0.9.7
gem install i18n --version=0.6.9
gem install json --version=1.8.1
gem install mail --version=2.2.7
gem install mechanize --version=2.7.3
gem install mime-types --version=2.1
gem install money --version=3.7.1
gem install multi_json --version=1.8.4
gem install needle --version=1.3.0
gem install net-http-digest_auth --version=1.4
gem install net-http-persistent --version=2.9.3
gem install nokogiri --version=1.6.2.1
gem install odba --version=1.1.0
gem install oddb2tdat --version=1.1.2
gem install paypal --version=2.0.0
gem install pg --version=0.12.0
gem install rclconf --version=1.0.0
gem install rdoc --version=4.1.1
gem install rmagick --version=2.13.4
gem install rmail --version=1.0.0
gem install rubyntlm --version=0.5.1
gem install ruby-ole --version=1.2.11.7

gem install rpdf2txt --version=0.8.4
gem install rubyXL --version=3.3.1
gem install rubyzip --version=1.1.6
gem install zip-zip --version=0.3
# wasabi must be installed before savon or it installing savon will fail
gem install wasabi --version=2.3.0
gem install savon --version=2.11.1
gem install sax-machine --version=1.3.0
gem install sbsm --version=1.2.3
gem install spreadsheet --version=0.9.7
gem install swissmedic-diff --version=0.1.9
gem install webrobots --version=0.1.1
gem install ydim --version=1.0.0
gem install ydocx --version=1.2.3
gem install yus --version=1.0.0
# The following gems are only needed for tests and development
# gem install "rake"
# gem install 'hoe'
# gem install 'hoe-travis'
# gem install 'minitest'
# gem install 'racc'
# gem install 'simplecov'
# gem install 'travis-lint'
# gem install 'rspec'
# gem install 'watir'
# gem install 'watir-webdriver'
# gem install 'page-object'
# gem install 'pry'
# gem install 'pry-debugger'

echo '
	You must manually install the dbi gem from https://github.com/zdavatz/ruby-dbi.git (if not already installed), e.g.
git clone https://github.com/ngiger/ruby-dbi.git
cd ruby-dbi
git checkout .
gem install --no-ri --no-rdoc deprecated --version=2.0.1
gem install --no-ri --no-rdoc rdoc
rake dbi
# or when installing a second time
cd $HOME/ruby-dbi && gem install --no-ri --no-rdoc pkg/dbi-0.4.5.gem
'
