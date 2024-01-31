{ pkgs, ... }:

{
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = [ pkgs.git pkgs.libyaml pkgs.imagemagick];

  enterShell = ''
    echo This is the devenv shell for oddb2xml
    git --version
    ruby --version
  '';

  env.FREEDESKTOP_MIME_TYPES_PATH = "${pkgs.shared-mime-info}/share/mime/packages/freedesktop.org.xml";

  # https://devenv.sh/languages/
  # languages.nix.enable = true;

  languages.ruby.enable = true;
  languages.ruby.versionFile = ./.ruby-version;
  services.postgres = {
    enable = true;
    package = pkgs.postgresql_16;
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
      \i 22:00-postgresql_database-ch_oddb-backup
    '';
  };


  # https://devenv.sh/pre-commit-hooks/
  # pre-commit.hooks.shellcheck.enable = true;

  # https://devenv.sh/processes/
  # processes.ping.exec = "ping example.com";

  # See full reference at https://devenv.sh/reference/options/
}
