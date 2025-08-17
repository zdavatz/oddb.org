# Purpose

Using a devenv enviroment from https://devenv.sh/ should enable new and seasoned developers to bring up a running local ODDB-webbrowser by typing only a few lines in a command shell.

But downloading all the components and backup of databases will take some times as several gigabytes are shuffled around

2013 and earlier it took new developers a few days to bring up a test environment.

# Decisions

We use the Nixos packages for the various ruby version from https://github.com/bobvanderlinden/nixpkgs-ruby (seen devenv.yaml).

We define the used ruby-version in the file [.ruby-version](./ruby-version) and use an expression like `3.2` to get the latest version in  this series, e.g 3.2.3 at the moment

We use the postgreSQL version as running under ch.oddb.org. As postgres 10 is no longer supported in nixos-23.11 we added an input `nixpkgs-old`using
`NixOS/nixpkgs/nixos-22.05`. See file [devenv.yaml](./devenv.yaml), where we also define an pg upgrade shell script `pgupgrade-pg-cluster` if you want to upgrade your database from postgres 10 to the latest postgres version 16.

We document here the devenv environment for the components yus, migel and oddb.org. We assume below here that all stuff is placed under `/opt/path_to_oddb` where you need about GB to run.

We use a separate postgres server for the three databases envolved. Each is listening to a different port. This allows us to test a new postgres version for each of the three databases (we use port 5435 for yus, 5434 for migel and 5433 for oddb.org)

The .ruby-version file in each git checkout defines the Ruby version being used.

A unzipped backup of each of the databases yus, migel and ch_oddb must be placed into `/opt/path_to_oddb`, where they are references in each `devenv.nix`file via a relativ path to `../<name>.backup`.

The applications must be started manually and should be similar to their invocation in their /services/*/run. Eg. converting the relevant line from `/services/yus` is `sudo -u apache bundle-320 exec ruby-320 bin/yusd` and gives us
`bundle exec ruby bin/yusd`

The `bundle install` must be called manually (for unknown reasons sometimes even twice.)

It is your responsability that the port (default 5433) used for the postgres database is in sync between this file (devenv.nix) and [etc/db_connection.rb](./etc/db_connection.rb). It could look like this

      require 'dbi'
      require 'odba/connection_pool'
      require 'pg'
      ODBA.storage.dbi = ODBA::ConnectionPool.new('DBI:Pg:dbname=ch_oddb;host=localhost;port=5433', 'postgres', '')



# Setup

You must create a `.ruby-version`-file with the desired Ruby version. This file is not under git control, to not interfere with Zeno's rbenv setup.

## Installing and bringing up a yus server

### Installing
Execute in a command shell the following command
* `mkdir /opt/path_to_oddb` and assure that the user you are has
* `cd /opt/path_to_oddb`
* `git clone git@github.com:zdavatz/yus.git`
* `cd yus`
   You will get an error like ``direnv: error /opt/path_to_oddb/yus/.envrc is blocked. Run `direnv allow` to approve its content``
* `direnv allow`
* `devenv up`

### Running unit tests

Now you are able to open a new command window and run there the unit tests for yus by executing the following commands
* `cd /opt/path_to_oddb/yus`
* `devenv shell`
* `bundle install`
* `bundle exec rake test`

### Running the yus server

Now you are confident that the yus server will work in a new command window. Execute the following commands
* `cd /opt/path_to_oddb/yus`
* `bundle install`
* `bundle exec ruby bin/yusd`

## Installing and bringing up a migel server

### Installing

Same as in previous example, but replace all occurrences from yus by migel

### Running unit tests

Same as in under yus, but replace all occurrences from yus by oddb.org. But the command for executing tests is

* `bundle exec rake spec`

### Running the migel server

Now you are confident that the migel server will work in a new command window. Execute the following commands
* `cd /opt/path_to_oddb/migel`
* `bundle install`
* `bundle exec ruby bin/migeld`


## Installing and bringing up a ch-oddb web server

### Installing

Same as in under yus, but replace all occurrences from yus by oddb.org. But be aware that the `devenv up` command will take around 12 minutes to complete (depends heavily on your machine).

### Running unit tests

Same as in under yus, but replace all occurrences from yus by oddb.org. but the command for executing tests is

* `bundle exec ruby test/suite.rb`

These tests take a long time, about 20 minutes under github.

### Running the ch-oddb web server

Now you are confident that the ch-oddb web server will work in a new command window. Execute the following commands
* `cd /opt/path_to_oddb/oddb.org`
* `bundle install`
* `ulimit -v 10240000; bundle exec rackup --host 127.0.0.1 -p 8012 --quiet # or use --debug to see some more information`

Now you should be able to point your browser to http://127.0.0.1:8012.

Caveat: If your bundle update exits silently after emitting something like `/opt/path_to_oddb/oddb.org/ext/refdata/src/refdata.rb:45:in '<module:Archiver>': Refdata: Starting debugging using REFDATA_BASE_URI http://refdatabase.refdata.ch`, then I recommend to clean the bundler cache by calling `rm -rf .devenv/state/.bundle`, verifying that you are in the devenv shell (where pg ist 10) and calling `bundle install` again.

### Running import jobs

Besides the webbrowser the following services may be used by. Here there port number and the command to start them
* 9997 `cd ../yus; bundle exec ruby bin/yusd`
* 33000 `cd ../migel; bundle exec ruby bin/migeld`
* 10005 `bundle exec ruby ext/export/bin/exportd`
* 10006 `bundle exec ruby ext/meddata/bin/meddatad`
* 10007 `bundle exec ruby ext/swissreg/bin/swissregd`
* 50001 `bundle exec ruby ext/refdata/bin/refdatad`
* 50002 `bundle exec ruby ext/swissindex/bin/swissindexd`

Devenv creates a script called `start_oddb_daemons` to start all `ext/*/*d` and the oddb rack server in the background.


### Running the spec tests with watir

We added chromium and firefox to the imported packages. The tests are run calling in a devenv shell `bundle exec rspec spec`.
There is an error in the exit handling, which leaves the program running, after showing the result and the rspec process must be killed via `kill -9 <processid>`

Be aware that you must define some environment variables to run these tests. I do this by creating a `devenv.local.nix`file (not to be added to git!) which looks like this

      { inputs, pkgs, ... }:
      {
            # for running the watir spec tests
            env.admin_user = "admin@user.com"
            env.admin_password_ = "top_secret";
            env.sandoz_admin_password _ = "top_secret";
      }

It happens frequently, that some watir tests fails, because the content of ODDB database changed. Also rspec runs different tests when

* The URL to be tested is `ch.oddb.org` (eg. we do not a new PDF via the admin interface)
* The URL is different. Then we cannot test all sub-domains, but we log in as admin

Look for occurrences of the method `testing_ch_oddb_org` in the files below spec.

If you want you can also develop new test using `irb`. Eg. this snippet should work to select the hospitals in Glarus.

      require 'watir'
      OddbUrl = 'http://127.0.0.1:8012'
      @browser = Watir::Browser.new(:chrome)
      @browser.goto OddbUrl
      @browser.link(visible_text: 'Spital').click
      @browser.text_field(id: 'searchbar').set 'Glarus'
      @browser.button(value: "Suchen").click
      
# containers

One can run the commands in a container. But starting up take a lot of time (over 7 minutes on my machine).
Tested via `time echo exit | devenv container run shell`

# TODO:

* Should we create etc/db_connection automatically. it is quite simple

      require 'dbi'
      require 'odba/connection_pool'
      require 'pg'
      ODBA.storage.dbi = ODBA::ConnectionPool.new('DBI:Pg:dbname=ch_oddb;host=localhost;port=5433', 'postgres', '')


## devenv.nix

# Notes

* Niklaus uses the fish shell from https://fishshell.com/
* Niklaus is working on a https://ch.starlabs.systems/pages/starbook laptop having 32 GB of RAM and a 2TB SSD-HD
* Nixos 25.05 from https://nixos.org/ installed.
* If you want to drop into the ruby debugger just insert a line `require 'debug'; debugger`
* If you want to reload a database dump, just stop the process up job and call `rm -rfv .devenv/state/postgres`

## Fish shell cheatsheets
* https://devhints.io/fish-shell
* https://github.com/mbyio/fish_shell_cheatsheet/blob/master/cheatsheet.pdf

## Nix language cheatsheets
* https://github.com/kquick/nix-cheatsheet/blob/master/nix-cheatsheet.org

