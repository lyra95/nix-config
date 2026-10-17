{agenix}: {
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [agenix.homeManagerModules.default];
  xdg.enable = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin true;
  # SSH cannot expand the shell command in agenix's default Darwin path.
  age.secretsDir = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin "${config.xdg.cacheHome}/agenix";
}
