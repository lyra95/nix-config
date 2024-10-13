inputs @ {
  nixpkgs,
  nixos-wsl,
  ...
}: {
  name,
  system,
  userName,
  modules,
}: let
  commonModules = {
    nix = {pkgs, ...}: {
      nixpkgs.hostPlatform = system;
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      environment.systemPackages = with pkgs; [git vim file];
      environment.variables.EDITOR = "vim";
    };

    wsl = {
      imports = [
        nixos-wsl.nixosModules.wsl
      ];
      wsl.enable = true;
      wsl.defaultUser = userName;
      wsl.wslConf.network.hostname = name;
    };
  };
in
  nixpkgs.lib.nixosSystem {
    specialArgs = {};
    modules =
      modules
      ++ (builtins.attrValues commonModules);
  }
