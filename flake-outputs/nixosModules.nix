{...}: let
  modules = {
    tailscale = ../modules/nixos/tailscale;
    xrdp = ../modules/nixos/xrdp;
    cifs = ../modules/nixos/cifs;
    k3s = ../modules/nixos/k3s;
  };
  wslModules = {
    docker-desktop-fix = ../modules/wsl/docker-desktop-fix.nix;
    vscode = ../modules/wsl/vscode.nix;
  };
  wsl = {
    imports = builtins.attrValues wslModules;
  };
  all = {
    imports = builtins.attrValues modules;
  };
in
  modules
  // wslModules
  // {
    default = all;
    wsl = wsl;
  }
