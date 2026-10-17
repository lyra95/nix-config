{
  config,
  inputs,
  lib,
  withSystem,
  ...
}: let
  mkHome = {
    name,
    system,
    stateVersion,
  }: modules:
    withSystem system (perSystem @ {
      inputs',
      pkgsUnfree,
      ...
    }:
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsUnfree;
        modules =
          modules
          ++ [
            (import ../modules/home-manager/profiles {
              inherit inputs name stateVersion;
              homeManagerPackage = inputs'.home-manager.packages.default;
              nvimPackage = perSystem.config.packages.nvim;
            })
          ];
      });

  work =
    mkHome {
      name = "jo";
      system = "x86_64-linux";
      stateVersion = "24.05";
    } [
      ../modules/home-manager/profiles/work.nix
    ];
in {
  imports = [inputs.home-manager.flakeModules.default];

  flake.homeModules = {
    aws = ../modules/home-manager/aws;
    git = ../modules/home-manager/git;
    gitui = ../modules/home-manager/gitui;
    starship = ../modules/home-manager/starship;
    k8s = ../modules/home-manager/k8s.nix;
    nvim = ../modules/home-manager/nvim.nix;
    rclone = ../modules/home-manager/rclone;
    kind = ../modules/home-manager/kind.nix;

    default = lib.modules.importApply ../modules/home-manager/default.nix {inherit (inputs) agenix;};
    shell = ../modules/home-manager/shell.nix;
    modern-cli = ../modules/home-manager/modern-cli.nix;
    darwin = ../modules/home-manager/darwin.nix;
  };

  # Preserve the existing public output alongside Home Manager's homeModules.
  flake.homeManagerModules = config.flake.homeModules;

  perSystem = {system, ...}: {
    checks =
      lib.mapAttrs' (name: home:
        lib.nameValuePair "home-${name}" home.activationPackage)
      (lib.filterAttrs (_: home: home.pkgs.stdenv.hostPlatform.system == system)
        config.flake.homeConfigurations);
  };

  flake.homeConfigurations = {
    inherit work;
    home = work;
    dell = work;

    jo-macbook-air =
      mkHome {
        name = "95hyouka";
        system = "aarch64-darwin";
        stateVersion = "25.05";
      } [
        {git.enable = true;}
      ];

    jonuc =
      mkHome {
        name = "jo";
        system = "x86_64-linux";
        stateVersion = "24.05";
      } [
        ../modules/home-manager/profiles/k3s.nix
      ];

    container =
      mkHome {
        name = "root";
        system = "x86_64-linux";
        stateVersion = "24.05";
      } [
        ../modules/home-manager/profiles/container.nix
      ];
  };
}
