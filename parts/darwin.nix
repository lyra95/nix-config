{
  config,
  inputs,
  lib,
  ...
}: let
  profile = {
    userName = "95hyouka";
    hostName = "jo-macbook-air";
    arch = "aarch64-darwin";
  };
in {
  perSystem = {system, ...}: {
    checks =
      lib.mapAttrs' (name: host:
        lib.nameValuePair "darwin-${name}" host.system)
      (lib.filterAttrs (_: host: host.pkgs.stdenv.hostPlatform.system == system)
        config.flake.darwinConfigurations);
  };

  flake.darwinConfigurations.${profile.hostName} = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      (import ../modules/darwin/system.nix profile inputs)
      (import ../modules/darwin/homebrew profile inputs)
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
      ../modules/darwin/aerospace
      (import ../modules/darwin/sioyek profile)
    ];
  };
}
