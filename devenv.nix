{ pkgs, ... }:

{
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = [ pkgs.git pkgs.libyaml pkgs.postgresql_14 pkgs.imagemagick];

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
  # https://devenv.sh/pre-commit-hooks/
  # pre-commit.hooks.shellcheck.enable = true;

  # https://devenv.sh/processes/
  # processes.ping.exec = "ping example.com";

  # See full reference at https://devenv.sh/reference/options/
}
