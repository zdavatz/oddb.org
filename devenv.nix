{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  pkgs-old = import inputs.nixpkgs-old {system = pkgs.stdenv.system;};
  pkgs-unstable = import inputs.nixpkgs-unstable {system = pkgs.stdenv.system;};
in {
  packages = [
    pkgs.git
    pkgs.nettools # for netstat
    pkgs.libyaml
    pkgs.imagemagick
    pkgs.firefox
    pkgs-unstable.chromedriver
    pkgs.ruby.devEnv
    pkgs.chromium
    pkgs.noto-fonts
    pkgs.courier-prime
    pkgs.rsync
    pkgs.screen
    pkgs.bzip2
  ];
  env.ODDB_PSQL_PORT = "5433";
  env.ODDB_PORT = "8012";
  env.ODDB_URL = "127.0.0.1:${config.env.ODDB_PORT}"; # for running the watir spec tests
  env.ODDB_DB_BACKUP = "../db_ch_oddb_backup.bz2";
  env.ODDB_DB_BACKUP_URL = "http://sl_errors.oddb.org/db/22:00-postgresql_database-ch_oddb-backup.bz2"; #2025-03-12 09:49 	2.6G
  env.FREEDESKTOP_MIME_TYPES_PATH = "${pkgs.shared-mime-info}/share/mime/packages/freedesktop.org.xml";

  languages.ruby.enable = true;
  languages.ruby.version = "3.4";
  services.postgres = {
    enable = true;
    package = pkgs-old.postgresql_10;
    listen_addresses = "0.0.0.0";
    port = lib.strings.toInt (config.env.ODDB_PSQL_PORT);

    initialDatabases = [
      {name = "ch_oddb";}
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

  scripts.wait_for_port_open = {
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

  scripts.kill_by_port.package = pkgs.fish;
  scripts.kill_by_port.exec = ''
    set -f my_pid (lsof -t -i tcp:$argv[1])
    if test -z "$my_pid";
      echo Could not find process for TCP port $argv[1]
      exit 0
    else
      echo Killing process $my_pid for TCP port $argv[1]
      kill $my_pid
    end
  '';

  scripts.ensure_pg_running.exec = ''
    set -veux
    devenv processes start --detach
    start-postgres &
    wait_for_port_open ${config.env.ODDB_PSQL_PORT} 30
    tail -n1 .devenv/processes.log # just to be sure
  '';

  scripts.start_oddb_daemons.exec = ''
    bundle install
    ensure_pg_running
    # must be kept in sync with src/config.rb
    netstat -tulpen | grep 10002 || bundle exec ext/fiparse/bin/fiparsed &
    netstat -tulpen | grep 10005 || bundle exec ext/export/bin/exportd &
    netstat -tulpen | grep 10006 || bundle exec ext/meddata/bin/meddatad &
    netstat -tulpen | grep 10007 || bundle exec ext/swissreg/bin/swissregd &
    netstat -tulpen | grep 50001 || bundle exec ext/refdata/bin/refdatad &
    netstat -tulpen | grep 50002 || bundle exec ext/swissindex/bin/swissindexd &
    netstat -tulpen | grep ${config.env.ODDB_PORT} || bundle exec rackup --host 127.0.0.1 -p ${config.env.ODDB_PORT} &
    wait_for_port_open ${config.env.ODDB_PORT}
    echo Do not forget to start yus and migeld
   '';

  scripts.stop_oddb_daemons.exec = ''
    kill_by_port 10000
    kill_by_port 10002
    kill_by_port 10005
    kill_by_port 10006
    kill_by_port 10007
    kill_by_port 50001
    kill_by_port 50002
    '';

  # curl -z/--time-cond db_ch_oddb_backup.bz2
  scripts.get_database_backup.exec = ''
    set -veux
    if [ ! -f ${config.env.ODDB_DB_BACKUP} ]; then
      echo Must download the file ${config.env.ODDB_DB_BACKUP}
      ${pkgs.curl}/bin/curl -o ${config.env.ODDB_DB_BACKUP} ${config.env.ODDB_DB_BACKUP_URL}
    else
      echo I am testing whether I have to update ${config.env.ODDB_DB_BACKUP}
      ${pkgs.curl}/bin/curl -z ${config.env.ODDB_DB_BACKUP} ${config.env.ODDB_DB_BACKUP_URL}
    fi
    ls -l ${config.env.ODDB_DB_BACKUP}
  '';


  scripts.load_database_backup.package = pkgs.fish;
  scripts.load_database_backup.exec = ''
    echo (date) started load_database_backup > steps_1.log
    get_database_backup
    echo (date) got get_database_backup status $status >> steps_1.log
    stop_oddb_daemons
    ensure_pg_running
    start-postgres &
    ${pkgs-old.postgresql_10}/bin/psql -c "create role postgres superuser login password null;" postgres | echo Done
    ${pkgs-old.postgresql_10}/bin/psql -c "drop database if exists ch_oddb;" postgres
    ${pkgs-old.postgresql_10}/bin/psql -c "create database ch_oddb;" postgres
    ${pkgs.bzip2}/bin/bzcat ${config.env.ODDB_DB_BACKUP} | ${pkgs-old.postgresql_10}/bin/psql ch_oddb
    ${pkgs-old.postgresql_10}/bin/psql ch_oddb -c "select count(*) from object;" # ensure that load_database_backup was run
    echo (date) Finished load_database_backup status $status >> steps_1.log
  '';

  scripts.dump_database.exec = ''
    date
    ensure_pg_running
    # --clean --if-exists
    ${pkgs-old.postgresql_10}/bin/pg_dump -f my_db_backup ch_oddb
    date
  '';

  scripts.update_latest.package = pkgs.fish;
  scripts.update_latest.exec = ''
    echo (date) Updating latest files > steps_2.log
    if test -d oddb-test
      cd oddb-test && git pull && cd ..
    else
      git clone https://git.sr.ht/~ngiger/oddb-test
    end
    rsync -av oddb-test/data/ data/
    echo (date) Updated latest files status $status >> steps_2.log
  '';

  scripts.remove_two_odba_ids_with_problems.exec = ''
    # Niklaus Giger, 22.03.2025. Helper script to remove ODBA_ID 55882644 and 55882674
    echo Remove ODBA_ID 55882644 and 55882674 which caused problems, see https://github.com/zdavatz/oddb.org/issues/301#issuecomment-2717357867
    bundle exec rackup --host 127.0.0.1 -p 8012&
    wait_for_port_open 10000 30
    echo "ODBA.cache.delete(ODBA.cache.fetch(55882644))" | bundle exec ruby bin/admin
    echo "ODBA.cache.delete(ODBA.cache.fetch(55882674))" | bundle exec ruby bin/admin
  '';

  scripts.run_integration_test.package = pkgs.fish;
  scripts.run_integration_test.exec = ''
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

  enterTest = ''
    bundle install
    update_latest
    load_database_backup
    run_integration_test
    # TODO: bundle exec ruby test/suite.rb
    # TODO: bundle exec rspec spec/smoketest_spec.rb

  '';

}
