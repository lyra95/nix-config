{
  inputs,
  homeManagerPackage,
  nvimPackage,
  name,
  stateVersion,
}: {
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../default.nix
    ../shell.nix
    ../modern-cli.nix
    ../darwin.nix
    (import ../agenix.nix {inherit (inputs) agenix;})
  ];
  nvim.pkg = nvimPackage;
  nvim.enableBashIntegration = true;
  home.username = name;
  home.homeDirectory = lib.mkDefault (
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${name}"
    else "/home/${name}"
  );
  home.packages = [homeManagerPackage];
  home.stateVersion = stateVersion;
  home.sessionPath = ["$HOME/.local/bin"];
  programs.home-manager.enable = true;
  manual.manpages.enable = false;
}
