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
  ODDB_PORT = 8012;
  ODDB_URL = "127.0.0.1:${toString ODDB_PORT}"; # for running the watir spec tests
  ODDB_DB_BACKUP = "../db_ch_oddb_backup.bz2";
  ODDB_DB_BACKUP_URL = "http://sl_errors.oddb.org/db/22:00-postgresql_database-ch_oddb-backup.bz2"; #2025-03-12 09:49 	2.6G
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
    inherit ODDB_PORT ODDB_PSQL_PORT;
    inherit ODDB_URL ODDB_DB_BACKUP ODDB_DB_BACKUP_URL;

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
        name = "ch_oddb";
      }
    ];

    initdbArgs = [
      "--locale=C"
      "--encoding=UTF8"
    ];

    initialScript = ''
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
  '';

  scripts = {
    wait_for_port_open = {
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
        status = Timeout::timeout(maxWait.to_i) do
          while !connected?(port)
              sleep 1
              waited+=1
              puts "port: #{port} open? #{connected?(port)} waited #{waited} seconds"
          end
        end
        puts "port: #{port} maxWait #{maxWait} is now connected status was #{status} after #{waited} seconds"
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
      wait_for_port_open ${toString ODDB_PSQL_PORT} 30
      tail -n1 .devenv/processes.log # just to be sure
    '';

    start_oddb_daemons.exec = ''
      bundle install
      ensure_pg_running
      # must be kept in sync with src/config.rb
      netstat -tulpen | grep 10002 || bundle exec ext/fiparse/bin/fiparsed &
      netstat -tulpen | grep 10005 || bundle exec ext/export/bin/exportd &
      netstat -tulpen | grep 10006 || bundle exec ext/meddata/bin/meddatad &
      netstat -tulpen | grep 10007 || bundle exec ext/swissreg/bin/swissregd &
      netstat -tulpen | grep 50001 || bundle exec ext/refdata/bin/refdatad &
      netstat -tulpen | grep 50002 || bundle exec ext/swissindex/bin/swissindexd &
      netstat -tulpen | grep "${toString ODDB_PORT}" || bundle exec rackup --host 127.0.0.1 -p "${toString ODDB_PORT}" &
      wait_for_port_open ${toString ODDB_PORT}
      echo Do not forget to start yus and migeld
    '';

    stop_oddb_daemons.exec = ''
      kill_by_port 10000
      kill_by_port 10002
      kill_by_port 10005
      kill_by_port 10006
      kill_by_port 10007
      kill_by_port 50001
      kill_by_port 50002
    '';

    # curl -z/--time-cond db_ch_oddb_backup.bz2
    get_database_backup.exec = ''
      set -veux
      if [ ! -f ${ODDB_DB_BACKUP} ]; then
        echo Must download the file ${ODDB_DB_BACKUP}
        ${pkgs.curl}/bin/curl -o ${ODDB_DB_BACKUP} ${ODDB_DB_BACKUP_URL}
      else
        echo I am testing whether I have to update ${ODDB_DB_BACKUP}
        ${pkgs.curl}/bin/curl -z ${ODDB_DB_BACKUP} ${ODDB_DB_BACKUP_URL}
      fi
      ls -l ${ODDB_DB_BACKUP}
    '';

    load_database_backup = {
      package = pkgs.fish;
      exec = let
        psql = lib.getExe' pkgs-old.postgresql_10 "psql";
      in ''
        echo (date) started load_database_backup > steps_1.log
        get_database_backup
        echo (date) got get_database_backup status $status >> steps_1.log
        stop_oddb_daemons
        ensure_pg_running
        start-postgres &
        ${psql} -c "create role postgres superuser login password null;" postgres | echo Done
        ${psql} -c "drop database if exists ch_oddb;" postgres
        ${psql} -c "create database ch_oddb;" postgres
        ${pkgs.bzip2}/bin/bzcat ${ODDB_DB_BACKUP} | ${psql} ch_oddb
        ${psql} ch_oddb -c "select count(*) from object;" # ensure that load_database_backup was run
        echo (date) Finished load_database_backup status $status >> steps_1.log
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
        echo (date) Updating latest files > steps_2.log
        if test -d oddb-test
          cd oddb-test && git pull && cd ..
        else
          git clone https://git.sr.ht/~ngiger/oddb-test
        end
        rsync -av oddb-test/data/ data/
        echo (date) Updated latest files status $status >> steps_2.log
      '';
    };

    remove_two_odba_ids_with_problems.exec = ''
      # Niklaus Giger, 22.03.2025. Helper script to remove ODBA_ID 55882644 and 55882674
      echo Remove ODBA_ID 55882644 and 55882674 which caused problems, see https://github.com/zdavatz/oddb.org/issues/301#issuecomment-2717357867
      bundle exec rackup --host 127.0.0.1 -p 8012&
      wait_for_port_open 10000 30
      echo "ODBA.cache.delete(ODBA.cache.fetch(55882644))" | bundle exec ruby bin/admin
      echo "ODBA.cache.delete(ODBA.cache.fetch(55882674))" | bundle exec ruby bin/admin
    '';

    run_integration_test = {
      package = pkgs.fish;
      exec = ''
        echo (date) Started run_integration_test > steps_3.log
        date
        ensure_pg_running
        # netstat -tulpen | grep 33000 || echo "You must start migel for the tests"
        # netstat -tulpen | grep  9997 || echo "You must start   yus for the tests"
        psql ch_oddb -c "select count(*) from object;" # ensure that load_database_backup was run
        remove_two_odba_ids_with_problems
        start_oddb_daemons
        wait_for_port_open 8012 30
        wait_for_port_open 10000 30
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
  };
  enterTest = ''
    bundle install
    update_latest
    load_database_backup
    run_integration_test
    # TODO: bundle exec ruby test/suite.rb
    # TODO: bundle exec rspec spec/smoketest_spec.rb
  '';
}
