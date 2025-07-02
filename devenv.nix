{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (builtins) toString;
  inherit (pkgs.stdenv) system;
  pkgs-old = inputs.nixpkgs-old.legacyPackages.${system};
  pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${system};

  ODDB_PSQL_PORT = 5433;
  ODDB_PORT = "8012";
  ODDB_URL = "127.0.0.1:${ODDB_PORT}"; # for running the watir spec tests
  ODDB_CI_DATA = "./oddb_ci_data";
in {
  packages = with pkgs;
    [
      git
      nettools # for netstat
      libyaml
      imagemagick
      firefox
      (ruby.devEnv)
      chromium
      noto-fonts
      courier-prime
      rsync
      screen
      bzip2
    ]
    ++ [
      pkgs-unstable.chromedriver
    ];

  env = {
    inherit ODDB_URL ODDB_PORT ODDB_PSQL_PORT;
    FREEDESKTOP_MIME_TYPES_PATH = "${pkgs.shared-mime-info}/share/mime/packages/freedesktop.org.xml";
  };

  languages.ruby = {
    enable = true;
    version = "3.4";
  };

  services.postgres = {
    enable = true;
    package = pkgs-old.postgresql_10;
    listen_addresses = "0.0.0.0";
    port = ODDB_PSQL_PORT;

    initialDatabases = [
      {
        name = "yus";
      }
      {
        name = "migel";
      }
      {
        name = "ch_oddb";
      }
      {
        name = "ch_oddb_test";
      }
    ];

    initdbArgs = [
      "--locale=C"
      "--encoding=UTF8"
    ];

    initialScript = ''
      create role yus superuser login password null;
      create role migel superuser login password null;
      create role oddb superuser login password null;
      create role ch_oddb superuser login password null;
      create role postgres superuser login password null;
    '';
  };

  enterShell = ''
    echo This is the devenv shell for the webbrowser ch.oddb.org
    git --version
    ruby --version
    psql --version
    check_setup
 '';

  scripts = {
    wait_for_port = {
      package = config.languages.ruby.package;
      exec = ''
        require 'open-uri'
        require 'timeout'
        def connected?(port)
          res = `netstat -tulpen 2>/dev/null| grep #{port}`
          return false unless res&.length > 0
          found = /\:#{port}\s/.match(res)
          return found && (found.length > 0)
        end
        port = ARGV[0]
        maxWait = ARGV[1]
        maxWait ||= 1
        waited=0
        begin
          status = Timeout::timeout(maxWait.to_i) do
            while !connected?(port)
                sleep 1
                waited+=1
                puts "port: #{port} open? #{connected?(port)} waited #{waited} seconds"
            end
          end
        rescue => error
          puts "Timeout"
          exit 3
        end
        puts "port: #{port} maxWait #{maxWait} is now connected status was #{status} after #{waited} seconds (ODDB.ORG)"
      '';
    };

    check_setup = {
      package = pkgs.fish;
      exec = ''
        #!/usr/bin/env fish
        set -f files ${ODDB_CI_DATA}/migel.yml \
        ${ODDB_CI_DATA}/oddb.yml \
        ${ODDB_CI_DATA}/pg-db-ch_oddb-backup-2025.05.29.bz2  \
        ${ODDB_CI_DATA}/pg-db-ch_oddb-backup.bz2 \
        ${ODDB_CI_DATA}/pg-db-migel-backup.bz2 \
        ${ODDB_CI_DATA}/pg-db-yus-backup.bz2 \
        ~/.yus/yus.crt \
        ~/.yus/yus.key \
        ~/.yus/yus.yml

        set found true
        for datei in $files
          if ! test -f $datei
            set missing "$missing $datei"
            set found false
          end
        end
        if $found
          echo "You have setup everything to call run_integration_test"
        else
          echo To run the command run_integration_test you must first create/get
          echo the following files:
          string split ' ' $missing
        end
      '';
      };
    kill_by_port = {
      package = pkgs.fish;
      exec = ''
        set -f my_pid (lsof -t -i tcp:$argv[1])
        if test -z "$my_pid";
          echo Could not find process for TCP port $argv[1]
          exit 0
        else
          echo Killing process $my_pid for TCP port $argv[1]
          kill $my_pid
        end
      '';
    };

    ensure_pg_running.exec = ''
      set -veux
      devenv processes start --detach
      start-postgres &
      wait_for_port ${toString ODDB_PSQL_PORT} 30
      tail -n1 .devenv/processes.log # just to be sure
    '';

    start_oddb_daemons = {
      package = pkgs.fish;
      exec = ''
        function start_and_log_if_necessary
          set port $argv[1]
          set logfile $argv[2]
          set cmd $argv[3]
          wait_for_port $port
          if ! test $status
            echo "Program for port $port is already running"
          else
            rm -f $logfile
            echo "Starting for port $port into $logfile using $cmd"
            eval "$cmd &> $logfile &"
          end
          wait_for_port $port
          if ! test $status
            echo "$logfile did not open port port $port Failing"
            exit 3
          end
        end

        echo (date) start_oddb_daemons | tee -a steps_1.log

        if test -d migel
          echo assuming migel is installed | tee -a steps_1.log
        else
          git clone https://github.com/zavatz/migel.git
          echo cloned migel | tee -a steps_1.log
        end
        bundle install
        ensure_pg_running

        # ports must be kept in sync with src/config.rb
        set yusd (which yusd)
        echo "yusd lives at $yusd"
        start_and_log_if_necessary 9997 yusd.log "bundle exec ruby $yusd"
        start_and_log_if_necessary 33000 migeld.log "bundle exec ruby migel/bin/migeld"
        start_and_log_if_necessary 8012 ch_oddb.log "bundle exec rackup --host 127.0.0.1 -p ${ODDB_PORT}"
        start_and_log_if_necessary 10002 fiparsed.log "bundle exec ext/fiparse/bin/fiparsed"
        start_and_log_if_necessary 10005 exportd.log "bundle exec ext/export/bin/exportd"
        start_and_log_if_necessary 10006 meddatad.log "bundle exec ext/meddata/bin/meddatad"
        start_and_log_if_necessary 10007 swissregd.log "bundle exec ext/swissreg/bin/swissregd"
        start_and_log_if_necessary 50001 refdatad.log "bundle exec ext/refdata/bin/refdatad"
        start_and_log_if_necessary 50002 swissindexd.log "ext/swissindex/bin/swissindexd"
      '';
      };
    stop_oddb_daemons.exec = ''
      kill_by_port ${ODDB_PORT}
      kill_by_port 9997
      kill_by_port 10000
      kill_by_port 10002
      kill_by_port 10005
      kill_by_port 10006
      kill_by_port 10007
      kill_by_port 33000
      kill_by_port 50001
      kill_by_port 50002
    '';

    # curl -z/--time-cond db_ch_oddb_backup.bz2
    load_database_backup = {
      package = pkgs.fish;
      exec = let
        psql = lib.getExe' pkgs-old.postgresql_10 "psql";
      in ''
        rm -f steps_1.log
        echo (date) started load_database_backup | tee steps_1.log
        stop_oddb_daemons
        ensure_pg_running
        start-postgres &
        for db in yus migel ch_oddb
          psql -c "create role $db superuser login password null;" postgres | echo Done
          set -f DB_BACKUP_URL "http://sl_errors.oddb.org/db/22:00-postgresql_database-$db-backup.bz2"
          set -f DB_BACKUP "${ODDB_CI_DATA}/pg-db-$db-backup.bz2"
          if curl --output /dev/null --silent --head --fail "$DB_BACKUP_URL"
            echo "URL exists: $DB_BACKUP_URL"
            if test -f $DB_BACKUP
              echo I am testing whether I have to update $DB_BACKUP
                curl -z $DB_BACKUP $DB_BACKUP_URL
            else
              echo Must download the file $DB_BACKUP
              curl -o $DB_BACKUP $DB_BACKUP_URL
            end
            if test $status
              echo (date) $db: got get_database_backup status $status 2>&1 | tee -a steps_1.log
            else
              echo (date) $db: unable to get file status $status | tee -a steps_1.log
              exit 1
            end
          else
            echo "Skipping download $DB_BACKUP_URL  does not found"
          end
          if  test -f $DB_BACKUP
            echo dropping and reloading $db from  $DB_BACKUP | tee -a steps_1.log
          else
            echo "Backup for $db via $DB_BACKUP not found. Exiting"
            exit 3
          end
          psql -c "drop database if exists $db;" postgres
          psql -c "create database $db;" postgres
          bzcat  $DB_BACKUP | psql $db
          echo (date) Select number of object crete to ensure backup was run | tee -a steps_1.log
          psql $db -t -c "select count(*) from object;" | head -n1 | grep -v -w 0
          if test $status
            echo (date) Finished load_database_backup $db status $status | tee -a steps_1.log
          else
            echo (date) Loading $db status $status from $DB_BACKUP failed | tee -a steps_1.log
            exit 3
          end
        end
        echo (date) Finished loading all databases | tee -a steps_1.log
      '';
    };

    dump_database.exec = ''
      date
      ensure_pg_running
      # --clean --if-exists
      ${pkgs-old.postgresql_10}/bin/pg_dump -f my_db_backup ch_oddb
      date
    '';

    update_latest = {
      package = pkgs.fish;
      exec = ''
        echo (date) Updating latest files | steps_2.log
        if test -d oddb-test
          cd oddb-test && git pull && cd ..
        else
          git clone https://git.sr.ht/~ngiger/oddb-test
        end
        rsync -av oddb-test/data/ data/
        echo (date) Updated latest files status $status | tee -a steps_2.log
      '';
    };
    run_integration_test = {
      package = pkgs.fish;
      exec = ''
        echo (date) Started run_integration_test | tee steps_3.log
        date
        ensure_pg_running
        psql ch_oddb -t -c "select count(*) from object;" | head -n1 | grep -v -w 0
        if test $status
          echo "DB ch_oddb seems to be okay"
        else
          echo "Please call load_database_backup first"
          exit 3
        end
        start_oddb_daemons
        wait_for_port 8012 30
        wait_for_port 10000 30
        echo (date) Started ODDB daemons | tee -a steps_3.log
        bundle exec ruby jobs/import_swissmedic
        echo  (date) Finished import_swissmedic status $status | tee -a steps_3.log
        bundle exec ruby jobs/import_daily
        echo  (date) Finished import_daily status $status | tee -a steps_3.log
        bundle exec ruby jobs/update_drugshortage
        echo  (date) Finished update_drugshortage status $status | tee -a steps_3.log
        bundle exec ruby jobs/import_bsv
        echo  (date) Finished import_bsv status $status | tee -a steps_3.log
        exit
      '';
    };
    run_watir_tests = {
      package = pkgs.fish;
      exec = ''
        echo (date) Started run_watir_tests > steps_3.log
        date
        ensure_pg_running
        start_oddb_daemons
        wait_for_port 8012 30
        wait_for_port 10000 30
        bundle exec rake rspec spec/smoketest_spec.rb 2>&1 | tee rspec.log
        echo  (date) Finished rspec status $status | tee -a steps_3.log
        exit
      '';
    };
  };
  #  enterTest = ''
  #    echo Entered shell
  #    pwd
  # bundle install
  # update_latest
  # load_database_backup
  # run_integration_test
  # TODO: bundle exec ruby test/suite.rb
  # TODO: bundle exec rspec spec/smoketest_spec.rb
  #  '';
}
