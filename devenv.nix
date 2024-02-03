{ inputs, pkgs, ... }:

let
  pkgs-old = import inputs.nixpkgs-old { system = pkgs.stdenv.system; };
in
{
  packages = [ pkgs.git pkgs.libyaml pkgs.imagemagick pkgs.firefox pkgs.chromium  pkgs.chromedriver];

  enterShell = ''
    echo This is the devenv shell for the webbrowser ch.oddb.org
    git --version
    ruby --version
    psql --version
    echo Look at pgupgrade-pg-cluster and OLDDATA here in devenv.nix if you want to upgrade your old database
  '';

  env.FREEDESKTOP_MIME_TYPES_PATH = "${pkgs.shared-mime-info}/share/mime/packages/freedesktop.org.xml";
  env.ODDB_URL = "127.0.0.1:8012"; # for running the watir spec tests

  languages.ruby.enable = true;
  languages.ruby.versionFile = ./.ruby-version;
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
   scripts.pgupgrade-pg-cluster.exec = ''
      set -eux
      export OLDDATA="/var/lib/postgresql/11.1"
      echo Checking wether we can read the OLDDATA directory of your postgres database
      ls -lrt $OLDDATA
      export OLDBIN="${pkgs-old.postgresql_10}/bin"

      # XXX it's perhaps advisable to stop all services that depend on postgresql
      systemctl stop postgresql

      export NEWDATA="/var/lib/postgresql/${pkgs.postgresql_16.psqlSchema}"
      export NEWBIN="${pkgs.postgresql_16}/bin"

      install -d -m 0700 -o postgres -g postgres "$NEWDATA"
      cd "$NEWDATA"
      sudo -u postgres $NEWBIN/initdb -D "$NEWDATA"

      sudo -u postgres $NEWBIN/pg_upgupgrade \
        --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
        --old-bindir $OLDBIN --new-bindir $NEWBIN \
        "$@"
    '';
}
