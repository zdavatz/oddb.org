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
    pkgs.libyaml
    pkgs.imagemagick
    pkgs.firefox
    pkgs-unstable.chromedriver
    pkgs.ruby.devEnv
    pkgs.chromium
    pkgs.noto-fonts
    pkgs.courier-prime
    pkgs.screen
    pkgs.bzip2
  ];
  env.ODDB_PSQL_PORT = "5433";
  env.ODDB_PORT = "8012";
  env.ODDB_URL = "127.0.0.1:${config.env.ODDB_PORT}"; # for running the watir spec tests

  enterShell = ''
    echo This is the devenv shell for the webbrowser ch.oddb.org
    git --version
    ruby --version
    psql --version
  '';

  env.FREEDESKTOP_MIME_TYPES_PATH = "${pkgs.shared-mime-info}/share/mime/packages/freedesktop.org.xml";
  scripts.wait_for_port_open = {
    package = config.languages.ruby.package;

    exec = ''
      require 'open-uri'
      def connected?(port)
        res = `netstat -tulpen 2>/dev/null| grep #{port}`
        return false unless res&.length > 0
        found = /\:#{port}\s/.match(res)
        return found && (found.length > 0)
      end

      port = ARGV[0]
      while !connected?(port)
          sleep 1
          puts "port: #{port} open? #{connected?(port)}"
      end
        puts "port: #{port} is now connected"
    '';
  };

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
      \connect ch_oddb;
      \i ../22:00-postgresql_database-ch_oddb-backup
    '';
  };
  scripts.start_oddb_daemons.exec = ''
    set -eux
    devenv processes start --detach
    wait_for_port_open ${config.env.ODDB_PSQL_PORT}
    tail -n1 .devenv/processes.log # just to be sure
    bundle install
    # must be kept in sync with src/config.rb
    netstat -tulpen | grep 10002 || bundle exec ext/fiparse/bin/fiparsed &
    netstat -tulpen | grep 10005 || bundle exec ext/refdata/bin/refdatad &
    netstat -tulpen | grep 10005 || bundle exec ext/export/bin/exportd &
    netstat -tulpen | grep 10006 || bundle exec ext/meddata/bin/meddatad &
    netstat -tulpen | grep 10007 || bundle exec ext/swissreg/bin/swissregd &
    netstat -tulpen | grep 50002   bundle exec ext/swissindexd/bin/swissindexd &
    netstat -tulpen | grep ${config.env.ODDB_PORT} || bundle exec rackup --host 127.0.0.1 -p ${config.env.ODDB_PORT} &
    wait_for_port_open ${config.env.ODDB_PORT}
    echo Do not forget to start yus and migeld
  '';
    scripts.load_oddb.exec = ''
      set -v
      pg_lao -Z9 -f ch_oddb_dump.gz ch_oddb
    '';
    # /usr/local/pg-10_1/bin/pg_dump -U postgres -p 5432 -h localhost --clean --if-exists yus | gzip > /home/ywesee/migration/yus.gz
    scripts.dump_oddb.exec = ''
      set -v
      pg_dump --if-exists --jobs=10 -Z9 -f ch_oddb_dump.gz ch_oddb
    '';

}
