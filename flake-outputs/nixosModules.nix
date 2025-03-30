{...}: let
  modules = {
    tailscale = ../modules/nixos/tailscale;
    xrdp = ../modules/nixos/xrdp;
    cifs = ../modules/nixos/cifs;
    k3s = ../modules/nixos/k3s;
    bug-fix = ../modules/nixos/bug-fix;
  };
  wslModules = {
    vscode = ../modules/wsl/vscode.nix;
    podman = ../modules/wsl/podman.nix;
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
