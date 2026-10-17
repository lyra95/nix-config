{
  config,
  inputs,
  lib,
  withSystem,
  ...
}: {
  imports = [inputs.home-manager.flakeModules.default];

  perSystem = {system, ...}: {
    checks = lib.optionalAttrs (system == "x86_64-linux") (
      lib.mapAttrs' (name: home:
        lib.nameValuePair "home-${name}" home.activationPackage)
      config.flake.homeConfigurations
    );
  };

  flake.homeConfigurations = withSystem "x86_64-linux" (perSystem @ {
    system,
    inputs',
    ...
  }: let
    # Home Manager allows unfree packages; development shells keep their defaults.
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    mkHome = name: modules:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules =
          modules
          ++ [
            (import ./profiles/home.nix {
              inherit inputs inputs' name;
              nvimPackage = perSystem.config.packages.nvim;
              inherit (config.flake) homeModules;
            })
          ];
      };
    work = mkHome "jo" [
      {
        home.packages = [pkgs.stu pkgs.claude-code];
        aws.enable = true;
        git.enable = true;
        git.wsl = true;
        rclone.enable = true;
        kind.enable = true;
      }
    ];
  in {
    inherit work;
    home = work;
    dell = work;

    jonuc = mkHome "jo" [
      {
        aws.enable = false;
        git.enable = true;
        home.packages = [pkgs.k9s];
        programs.bash = {
          shellAliases.k = "kubectl";
          sessionVariables.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
        };
      }
    ];

    container = mkHome "root" [
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
  });
}
