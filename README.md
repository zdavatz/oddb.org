# oddb.org

* https://github.com/zdavatz/oddb.org
* http://choddb.rubyforge.org/

## Description
Open Drug Database for Switzerland. See the live version at http://ch.oddb.org

## Features/Problems
* Some email-Addresses are still hardcoded. That needs to be fixed and placed into etc/oddb.yml
* If you install oddb.org via gem please also see these instructions:
  * http://dev.ywesee.com/wiki.php/Choddb/Gem

## Requirements
* see Guide.txt

## Tests

* to run the Tests you need to do
  * bundle install
  * rake test
  * look at the index.html in the coverage directory
  
* There are some Selenium/Watir based GUI integration tests. For details on how to use them have
  a look at tests_watir.textile

* There is test/wrk_performance.lua allows a stress test with a typical load. See test/wrk_performance.lua for details on howto run it

## Local Documentation

* To build your local documentation do:
  * rdoc1.9 --op documentation

## Install

* sudo gem install oddb.org

## Developers

* Zeno R.R. Davatz 2002-present
* Niklaus Giger 2012-present
* Masaomi Hatakeyama 2009-2011
* Yasuhiro Asaka 2008-2009
* Hannes Wyss 2002-2008

## French Translation Help

* Herve Robin. Thank you Herve!

## License
### oddb.org
* GPLv3.0
### Dojo Toolkit
* Licensed under the MIT license from http://www.opensource.org/licenses/mit-license.php:
** doc/resources/javascript/qrcode.js

## Trademarks
The word "QR Code" is registered trademark of DENSO WAVE INCORPORATED. see http://www.denso-wave.com/qrcode/faqpatent-e.html

Issues at https://github.com/zdavatz/oddb.org/issues
