{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (config.flake) darwinModules;
  profile = {
    userName = "95hyouka";
    hostName = "jo-macbook-air";
    arch = "aarch64-darwin";
  };
in {
  flake.darwinModules = {
    system =
      lib.setDefaultModuleLocation ../modules/darwin/system.nix
      (import ../modules/darwin/system.nix profile inputs);
    homebrew =
      lib.setDefaultModuleLocation ../modules/darwin/homebrew/default.nix
      (import ../modules/darwin/homebrew profile inputs);
    aerospace = ../modules/darwin/aerospace;
    sioyek = lib.modules.importApply ../modules/darwin/sioyek/default.nix profile;

    default = {
      imports = with darwinModules; [system homebrew aerospace sioyek];
    };
  };

  perSystem = {system, ...}: {
    checks =
      lib.mapAttrs' (name: host:
        lib.nameValuePair "darwin-${name}" host.system)
      (lib.filterAttrs (_: host: host.pkgs.stdenv.hostPlatform.system == system)
        config.flake.darwinConfigurations);
  };

  flake.darwinConfigurations.${profile.hostName} = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      darwinModules.default
      ({pkgs, ...}: {
        networking.hostName = profile.hostName;

        fonts.packages = [pkgs.d2coding];

        environment.systemPackages = [
          pkgs.vim
          pkgs.git
          pkgs.direnv
          pkgs.home-manager
          pkgs.uv
        ];

        system.primaryUser = profile.userName;

        system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
        system.defaults.NSGlobalDomain.AppleShowAllFiles = true;

        system.defaults.screencapture.target = "clipboard";

        nix.settings.experimental-features = "nix-command flakes";

        security.pam.services.sudo_local.touchIdAuth = true;

        system.defaults.finder = {
          AppleShowAllExtensions = true;
          AppleShowAllFiles = true;
        };
      })
    ];
  };
}
