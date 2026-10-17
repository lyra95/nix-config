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
            (import ./profiles/home.nix {
              inherit inputs inputs' name stateVersion;
              nvimPackage = perSystem.config.packages.nvim;
              inherit (config.flake) homeModules;
            })
          ];
      });

  work =
    mkHome {
      name = "jo";
      system = "x86_64-linux";
      stateVersion = "24.05";
    } [
      ({pkgs, ...}: {
        home.packages = [pkgs.stu pkgs.claude-code];
        aws.enable = true;
        git.enable = true;
        git.wsl = true;
        rclone.enable = true;
        kind.enable = true;
      })
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

    default = {
      imports = with config.flake.homeModules; [aws git gitui k8s kind nvim rclone starship];
    };
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
        ({pkgs, ...}: {
          aws.enable = false;
          git.enable = true;
          home.packages = [pkgs.k9s];
          programs.bash = {
            shellAliases.k = "kubectl";
            sessionVariables.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
          };
        })
      ];

    container =
      mkHome {
        name = "root";
        system = "x86_64-linux";
        stateVersion = "24.05";
      } [
        {
          aws.enable = lib.mkForce false;
          git.enable = lib.mkForce false;
          gitui.enable = lib.mkForce false;
          rclone.enable = lib.mkForce false;
          kind.enable = lib.mkForce false;
          k8s.enable = lib.mkForce false;
          home.homeDirectory = lib.mkForce "/root";
        }
      ];
  };
}
