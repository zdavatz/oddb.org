= oddb.org

* http://scm.ywesee.com/?p=oddb.org/.git;a=summary
* http://choddb.rubyforge.org/

== DESCRIPTION:

Open Drug Database for Switzerland. See the live version at http://ch.oddb.org

== FEATURES/PROBLEMS:

* Some email-Addresses are still hardcoded. That needs to be fixed and placed into etc/oddb.yml
* If you install oddb.org via gem please also see these instructions:
  * http://dev.ywesee.com/wiki.php/Choddb/Gem

== REQUIREMENTS:

* see Guide.txt

== TESTS:

* to run the Tests you need to do
  * bundle install
  * rake test
  * look at the index.html in the coverage directory
  
* There are some Selenium/Watir based GUI integration tests. For details on how to use them have
  a look at tests_watir.textile

== LOCAL DOCUMENTATION:

* To build your local documentation do:
  * rdoc1.9 --op documentation

== INSTALL:

* sudo gem install oddb.org

== DEVELOPERS:

* Zeno R.R. Davatz
* Masaomi Hatakeyama
* Yasuhiro Asaka 
* Niklaus Giger
* Hanney Wyss (up to Version 1.0)

== FRENCH TRANSLATION HELP

* Herve Robin

== LICENSE:

* GPLv2.1
* Licensed under the MIT license from http://www.opensource.org/licenses/mit-license.php:
** doc/resources/javascript/qrcode.js

== Trademarks
The word "QR Code" is registered trademark of DENSO WAVE INCORPORATED. see http://www.denso-wave.com/qrcode/faqpatent-e.html
