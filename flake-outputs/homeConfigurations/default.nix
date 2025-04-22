inputs @ {nixpkgs, ...}: let
  system = "x86_64-linux";
  homeBuilder = import ./lib.nix inputs;
  pkgs = nixpkgs.legacyPackages.${system};
in let
  work = homeBuilder {
    name = "jo";
    inherit system pkgs;
    modules = [
      {
        home.packages = [pkgs.stu];
        aws.enable = true;
        git.enable = true;
        git.wsl = true;
        rclone.enable = true;
        kind.enable = true;
      }
    ];
  };

  nuc = homeBuilder {
    name = "jo";
    inherit system pkgs;
    modules = [
      {
        aws.enable = false;
        git.enable = true;

        home.packages = [pkgs.k9s];
        programs.bash = {
          shellAliases = {
            k = "kubectl";
          };
          sessionVariables = {
            KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
          };
        };
      }
    ];
  };

  container = homeBuilder {
    name = "root";
    inherit system pkgs;
    modules = [
      (
        {lib, ...}: let
          options = ["aws" "git" "gitui" "rclone" "kind" "k8s" "kind"];
          disable = options:
            builtins.listToAttrs (map (name: {
                name = name;
                value = {enable = lib.mkForce false;};
              })
              options);
        in
          (disable options)
          // {
            home.homeDirectory = lib.mkForce "/root";
          }
      )
    ];
  };
in {
  # hostname = homeConfiguration
  "work" = work;
  "home" = work;
  "dell" = work;
  "jonuc" = nuc;
  "container" = container;
}
