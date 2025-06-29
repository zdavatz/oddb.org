{ inputs, pkgs, config, lib, ... }:

let
  pkgs-old = import inputs.nixpkgs-old { system = pkgs.stdenv.system; };
  pkgs-unstable = import inputs.nixpkgs-unstable { system = pkgs.stdenv.system; };
in
{
  packages = [ pkgs.git pkgs.libyaml pkgs.imagemagick pkgs.firefox pkgs-unstable.chromedriver
  pkgs.ruby.devEnv pkgs.chromium
  ];

  enterShell = ''
    echo This is the devenv shell for the webbrowser ch.oddb.org
    git --version
    ruby --version
    psql --version
  '';

  env.FREEDESKTOP_MIME_TYPES_PATH = "${pkgs.shared-mime-info}/share/mime/packages/freedesktop.org.xml";
  env.ODDB_PSQL_PORT = "5433";
  env.ODDB_PORT = "8012";
  env.ODDB_URL = "127.0.0.1:${config.env.ODDB_PORT}"; # for running the watir spec tests
  env.ODDB_DB_BACKUP = "../db_ch_oddb_backup.bz2";
  env.ODDB_DB_BACKUP_URL = "http://sl_errors.oddb.org/db/22:00-postgresql_database-ch_oddb-backup.bz2";

  languages.ruby.enable = true;
  languages.ruby.version = "3.2.7";
  services.postgres = {
    enable = true;
    package = pkgs-old.postgresql_10;
    listen_addresses = "0.0.0.0";
    port = 5433;

    initialDatabases = [
      { name = "migel"; }
      { name = "yus"; }
      { name = "ch_oddb"; }
      { name = "ch_oddb_test"; }
    ];

    initdbArgs =
      [
        "--locale=C"
        "--encoding=UTF8"
      ];

    initialScript = ''
      create role migel superuser login password null;
      create role yus superuser login password null;
      create role oddb superuser login password null;
      create role ch_oddb superuser login password null;
      create role postgres superuser login password null;
      \connect ch_oddb;
    '';
  };
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
      status = Timeout::timeout(maxWait.to_i) do
        while !connected?(port)
            sleep 1
            puts "port: #{port} open? #{connected?(port)}"
        end
      end
      puts "port: #{port} maxWait #{maxWait} is now connected status was #{status}"
    '';
  };

  scripts.start_oddb_daemons.exec = ''
    set -veux
    set -eux
    devenv processes start --detach
    wait_for_port_open ${config.env.ODDB_PSQL_PORT} 30
    tail -n1 .devenv/processes.log # just to be sure
    bundle install
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


  scripts.load_database_backup.exec = ''
    set -veux
    devenv up --detach
    start-postgres &
    wait_for_port_open ${config.env.ODDB_PSQL_PORT} 30
    get_database_backup
    ${pkgs.bzip2}/bin/bzcat ${config.env.ODDB_DB_BACKUP} | ${pkgs-old.postgresql_10}/bin/psql ch_oddb
  '';

  scripts.dump_database.exec = ''
    date
    # --clean --if-exists
    ${pkgs-old.postgresql_10}/bin/pg_dump -f my_db_backup ch_oddb
    date
  '';

  scripts.run_integration_test.exec = ''
    set -evux
    date
    netstat -tulpen | grep 33000 || echo "You must start migel for the tests"
    netstat -tulpen | grep  9997 || echo "You must start   yus for the tests"
    devenv up --detach
    start-postgres &
    wait_for_port_open ${config.env.ODDB_PSQL_PORT} 30
    bundle exec ruby ext/export/bin/exportd 2>&1 | tee exportd.log &
    wait_for_port_open 10005 30
    echo "Started exportd"
    bundle exec ruby ext/fiparse/bin/fiparsed 2>&1 | tee fiparsed.log &
    wait_for_port_open 10002 30
    bundle exec ruby ext/refdata/bin/refdatad 2>&1 | tee refdatad.log &
    wait_for_port_open 50001 30
    echo "Started ext/fiparse/bin/fiparsed"
    bundle exec rackup --host 127.0.0.1 -p 8012 2>&1 | tee rackup.log &
    echo "Started rackup"
    wait_for_port_open 8012 30
    wait_for_port_open 10000 30
    echo "Now rackup, fiparse, refdatad and exportd should be running"
    echo "Removing latest files"
    rm -f data/csv/interactions_de_utf8-latest.csv data/xlsx/nomarketing-latest.xlsx data/xls/Packungen-latest.xlsx
    rm -f data/xml/XMLPublications-latest.zip data/xml/AipsDownload_latest.xml data/xml/swissmedicinfo.zip
    bundle exec ruby jobs/import_daily 2>&1 | tee import_daily.log
    bundle exec ruby jobs/import_bsv 2>&1 | tee import_bsv.log
  '';
}
