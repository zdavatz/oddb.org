# Purpose

Using a devenv enviroment from https://devenv.sh/ should enable new and seasoned developers to bring up a running local ODDB-webbrowser by typing only a few lines in a command shell.

But downloading all the components and backup of databases will take some times as several gigabytes are shuffled around

2013 and earlier it took new developers a few days to bring up a test environment.

# Decisions

We use the Nixos packages for the various ruby version from https://github.com/bobvanderlinden/nixpkgs-ruby (seen devenv.yaml)

We document here the devenv environment for the components yus, migel and oddb.org. We assume below here that all stuff is placed under `/opt/path_to_oddb` where you need about GB to run.

We use a separate postgres server for the three databases envolved. Each is listening to a different port. This allows us to test a new postgres version for each of the three databases (port 5433 for yus, 5434 for migel and 5435 for oddb.org)

As nixos only supports Postgres 12 and later, we use for the testing Postgres 16 and not Postgres 10 (January 2024) as on the ch.oddb.org website.

The .ruby-version file in each git checkout defines the Ruby version being used.

A unzipped backup of each of the databases yus, migel and ch_oddb must be placed into ^`/opt/path_to_oddb`.

The applications must be started manually and should be similar to their invocation in their /services/*/run. Eg. converting the relevant line from `/services/yus` is `sudo -u apache bundle-330 exec ruby-330 bin/yusd` and gives us
`bundle exec ruby bin/yusd`
The `bundle install` must be called manually.

# Setup

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
Seeing the following `psql:22:00-postgresql_database-ch_oddb-backup:787: ERROR:  tables declared WITH OIDS are not supported`

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

# TODO:

The following steps could be intergrated into the devenv.nix
* `bundle install`
* Use the downloaded bz2 backup file directly
* Always use `bundle exec rake test` to execute the tests. Instead of checking always `.github/workflows/ruby.yml`

# Notes

* Niklaus uses the fish shell from https://fishshell.com/
* Niklaus is working on a https://ch.starlabs.systems/pages/starbook laptop having 32 GB of RAM and a 2TB SSD-HD
* Nixos 23.11 from https://nixos.org/ installed
* If you want to drop into the ruby debugger just insert a line `require 'debug'; debugger`
* If you want to reload a database dump, just stop the process up job and call `rm -rfv .devenv/state/postgres`
