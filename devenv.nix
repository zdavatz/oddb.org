{ inputs, pkgs, ... }:

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
  env.ODDB_URL = "127.0.0.1:8012"; # for running the watir spec tests

  languages.ruby.enable = true;
  languages.ruby.version = "3.3";
  services.postgres = {
    enable = true;
    package = pkgs-old.postgresql_10;
    listen_addresses = "0.0.0.0";
    port = 5433;

    initialDatabases = [
      { name = "ch_oddb"; }
    ];

    initdbArgs =
      [
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
      bundle exec ruby ext/export/bin/exportd &
      bundle exec ruby ext/fiparse/bin/fiparsed &
      bundle exec ruby ext/meddata/bin/meddatad &
      bundle exec ruby ext/refdata/bin/refdatad &
      bundle exec ruby ext/swissindex/bin/swissindexd &
      bundle exec ruby ext/swissreg/bin/swissregd &
      bundle exec rackup --host 127.0.0.1 -p 8012 &
    '';
}
