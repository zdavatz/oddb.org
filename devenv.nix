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
  ODDB_CI_DATA = "./ci_data";
  ODDB_URL = "127.0.0.1:${ODDB_PORT}"; # for running the watir spec tests
  ODDB_CI_LOG = "./ci_log";
  ODDB_CI_SAVE_MAIL_IN = "${ODDB_CI_LOG}/mail";
  ODDB_CI_ARCHIVE = "./ci_archive";
  fPortIsOpen = ''
function port_is_open
    argparse 'h/help'  'p/port=' -- $argv
    if test "$_flag_port" = ""
      echo "No port defined"
      exit 8
    end
    ss -tunlp -4 | grep -w "$_flag_port" >/dev/null
end
      '';

in {
  packages = with pkgs;
    [
      git
      lsof
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
      iproute2 # for ss
    ]
    ++ [
      pkgs-unstable.chromedriver
    ];

  env = {
    inherit ODDB_URL ODDB_PORT ODDB_PSQL_PORT ODDB_CI_DATA ODDB_CI_LOG ODDB_CI_ARCHIVE ODDB_CI_SAVE_MAIL_IN;
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
      package = pkgs.fish;
      exec = ''
        ${fPortIsOpen}
        argparse 'h/help' 'p/port=' 't/timeout=' -- $argv
        or return
        set idx 0
        set -l maxWait 30
        set -ql _flag_timeout[1]
        and set maxWait $_flag_timeout[-1]
        while not port_is_open --port="$_flag_port"
          set idx (math $idx + 1)
          sleep 1
          if test $idx -eq $maxWait
            echo (date): Port $_flag_port was not open after $idx seconds
            return 2
          end
        end
      '';
    };

    check_setup = {
      package = pkgs.fish;
      exec = ''
        set -f files ${ODDB_CI_DATA}/migel.yml \
        ${ODDB_CI_DATA}/oddb.yml \
        ${ODDB_CI_DATA}/pg-db-ch_oddb-backup.bz2 \
        ${ODDB_CI_DATA}/pg-db-migel-backup.bz2 \
        ${ODDB_CI_DATA}/pg-db-yus-backup.bz2 \
        ~/.yus/yus.crt \
        ~/.yus/yus.key \
        ~/.yus/yus.yml

        set found true
        # Check that DB backup files and configs for yus/migel exist
        for datei in $files
          if ! test -f $datei
            set missing "$missing $datei"
            set found false
          end
        end

        # Check yaml file for oddb. We must be able to send an email
        set yaml_file  etc/oddb.yml
        set defs smtp_server smtp_domain smtp_user smtp_pass smtp_port
        if ! test -f $yaml_file
          echo "Missing yaml file $yaml_file"
          set found false
        else
          for a_def in $defs
            if ! grep $a_def $yaml_file >/dev/null
              echo "Missing definition for $a_def in $yaml_file"
              set found false
            end
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

    ensure_pg_running = {
      package = pkgs.fish;
      exec = ''
        ${fPortIsOpen}
        wait_for_port -p ${toString ODDB_PSQL_PORT} -t 1
        if test 0 -eq $status
          echo "Postgres is running on port ${toString ODDB_PSQL_PORT} status $status"
          exit 0
        end
        run_and_log -l pgd.log -s 1 -c "devenv processes start --detach"
        wait_for_port -p ${toString ODDB_PSQL_PORT} -t 30 # Here we often get timeout errors
        grep listening .devenv/processes.log | tail -n1
        tail -n1 .devenv/processes.log # just to be sure
        if port_is_open --port=${toString ODDB_PSQL_PORT}
          echo "Postgres is running on port ${toString ODDB_PSQL_PORT} status $status"
          exit 0
        else
          echo "Postgres is NOT running on port ${toString ODDB_PSQL_PORT}"
          exit 2
        end
      '';
    };
    run_and_log = {
      package = pkgs.fish;
      exec = ''
        argparse 'h/help'  'l/log_file=' 's/spawn=' 'c/cmd=' -- $argv
        or return
        set -l mustSpawn 1
        set startTime (date "+%s")
        mkdir -vp ${ODDB_CI_LOG}
        set log_file  ${ODDB_CI_LOG}/$_flag_log_file
        if test $_flag_spawn -eq 0
          eval "$_flag_cmd &> $log_file &"
          echo "Logging into $_flag_log_file for spawned $_flag_cmd"
          return 0
        else
          eval "$_flag_cmd &> $log_file"
          set endTime (date "+%s")
          set took "took " (math $endTime - $startTime) " seconds"
          echo "   Log in $_flag_log_file. $took with $status." | tee -a  ci_run.log
          return 0
        end      '';
    };
    spawn_and_log_for_port = {
      package = pkgs.fish;
      exec = ''
        ${fPortIsOpen}
        argparse 'h/help' 'p/port=' 'l/log_file=' 'c/cmd=' -- $argv
        or return
        if port_is_open --port="$_flag_port"
          echo "Program for port $_flag_port is already running"
        else
            echo "Starting for port $_flag_port into $_flag_log_file using $_flag_cmd"
            run_and_log -l $_flag_log_file  -s 0 -c $_flag_cmd
        end
        wait_for_port -p $_flag_port -t 30
        if test 0 -ne $status
            echo (date)": $_flag_log_file did not open port port $_flag_port Failing as status $status"
            exit 3
        else
          echo (date)": Started program "(basename $_flag_cmd)" for $_flag_port log goes to $_flag_log_file "
        end
      '';
    };
    start_oddb_daemons = {
      package = pkgs.fish;
      exec = ''
        echo (date) start_oddb_daemons | tee -a ci_run.log

        if test -d migel
          echo assuming migel is installed | tee -a ci_run.log
        else
          git clone https://github.com/zavatz/migel.git
          echo cloned migel | tee -a ci_run.log
        end
        bundle install
        ensure_pg_running

        # ports must be kept in sync with src/config.rb
        set yusd (which yusd)
        echo "yusd lives at $yusd"
        spawn_and_log_for_port -p 9997 -l yusd.log -c "bundle exec ruby $yusd"
        spawn_and_log_for_port -p 33000 -l migeld.log -c "bundle exec ruby migel/bin/migeld"
        spawn_and_log_for_port -p 8012 -l ch_oddb.log -c "bundle exec rackup --host 127.0.0.1 -p ${ODDB_PORT}"
        spawn_and_log_for_port -p 10002 -l fiparsed.log -c "bundle exec ruby ext/fiparse/bin/fiparsed"
        spawn_and_log_for_port -p 10005 -l exportd.log -c "bundle exec ruby ext/export/bin/exportd"
        spawn_and_log_for_port -p 10006 -l meddatad.log -c "bundle exec ruby ext/meddata/bin/meddatad"
        spawn_and_log_for_port -p 10007 -l swissregd.log -c "bundle exec ruby ext/swissreg/bin/swissregd"
        spawn_and_log_for_port -p 50001 -l refdatad.log -c "bundle exec ruby ext/refdata/bin/refdatad"
        spawn_and_log_for_port -p 50002 -l swissindexd.log -c "bundle exec ruby ext/swissindex/bin/swissindexd"
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

    load_database_backup = {
      package = pkgs.fish;
      exec = let
        psql = lib.getExe' pkgs-old.postgresql_10 "psql";
      in ''
        rm -f ci_run.log
        echo (date) started load_database_backup | tee ci_run.log
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
            if test 0 -eq $status
              echo (date) $db: got get_database_backup status $status 2>&1 | tee -a ci_run.log
            else
              echo (date) $db: unable to get file status $status | tee -a ci_run.log
              exit 1
            end
          else
            echo "Skipping download $DB_BACKUP_URL  does not found"
          end
          if  test -f $DB_BACKUP
            echo dropping and reloading $db from  $DB_BACKUP | tee -a ci_run.log
          else
            echo "Backup for $db via $DB_BACKUP not found. Exiting"
            exit 3
          end
          psql -c "drop database if exists $db;" postgres
          psql -c "create database $db;" postgres
          run_and_log -l create_{$db}_d.log -s 1 -c "bzcat  $DB_BACKUP | psql $db"
          echo (date) Select number of object create to ensure backup was run | tee -a ci_run.log
          psql $db -t -c "select count(*) from object;" | head -n1 | grep -v -w 0
          if test 0 -eq $status
            echo (date) Finished load_database_backup $db status $status | tee -a ci_run.log
          else
            echo (date) Loading $db status $status from $DB_BACKUP failed | tee -a ci_run.log
            exit 3
          end
        end
        echo (date) Finished loading all databases | tee -a ci_run.log
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
        echo (date) Updating latest files | ci_run.log
        if test -d oddb-test
          cd oddb-test && git pull && cd ..
        else
          git clone https://git.sr.ht/~ngiger/oddb-test
        end
        rsync -av oddb-test/data/ data/
        echo (date) Updated latest files status $status | tee -a ci_run.log
      '';
    };
    run_integration_test = {
      package = pkgs.fish;
      exec = ''
        set needed admin_password SANDOZ_ADMIN_PASSWD
        for variable in $needed
          set env_val (env | grep $variable)
          if test "" = "$env_val"
            echo "  $variable is undefined"
            echo "Please define the environment variables:"
            string collect $needed
            exit 3
          end
        end
        echo (date) Started run_integration_test | tee ci_run.log
        ensure_pg_running
        psql ch_oddb -t -c "select count(*) from object;" | head -n1 | grep -v -w 0
        if test 0 -eq $status
          echo "DB ch_oddb seems to be okay" | tee -a ci_run.log
        else
          load_database_backup
          echo (date) Finished load_database_backup | tee -a ci_run.log
        end
        update_latest
        echo (date) Finished update_latest | tee -a ci_run.log
        start_oddb_daemons
        echo (date) Started ODDB daemons | tee -a ci_run.log

        run_and_log -l import_daily.log -s 1 -c "bundle exec ruby jobs/import_daily"
        echo  (date) Finished import_daily status $status | tee -a ci_run.log

        run_and_log -l import_bsv.log -s 1 -c "bundle exec ruby jobs/import_bsv"
        echo  (date) Finished import_bsv status $status | tee -a ci_run.log

        run_and_log -l suite.log -s 1 -c "bundle exec ruby test/suite.rb"
        echo  (date) Finished test/suite.rb $status | tee -a ci_run.log

        run_and_log -l rspec.log -s 1 -c "bundle exec rspec spec"
        echo  (date) Finished running rspec $status | tee -a ci_run.log

        run_and_log -l import_swissmedic.log -s 1 -c "bundle exec ruby jobs/import_swissmedic"
        echo  (date) Finished import_swissmedic status $status | tee -a ci_run.log

        run_and_log -l import_swissmedic_fix.log -s 1 -c "bundle exec ruby jobs/import_swissmedic fix_galenic_form"
        echo  (date) Finished import_swissmedic_fix status $status | tee -a ci_run.log

        run_and_log -l import_swissmedic_update.log -s 1 -c "bundle exec ruby jobs/import_swissmedic update_compositions"
        echo  (date) Finished import_swissmedic_update status $status | tee -a ci_run.log

        set dest ${ODDB_CI_ARCHIVE}'/run_'(date '+%Y-%m-%d-%H')
        mkdir -pv $dest
        mv -v ${ODDB_CI_LOG} $dest
        echo  (date) Finished you will find all logs under $dest
        mv -v ci_run.log $dest
        exit 0
      '';
    };
    run_watir_tests = {
      package = pkgs.fish;
      exec = ''
        echo (date) Started run_watir_tests > ci_run.log
        date
        ensure_pg_running
        start_oddb_daemons
        wait_for_port -p 8012 -t 30
        wait_for_port -p 10000 -t 30
        bundle exec rake rspec spec/smoketest_spec.rb 2>&1 | tee rspec.log
        echo  (date) Finished rspec status $status | tee -a ci_run.log
        exit
      '';
    };
  };
}
