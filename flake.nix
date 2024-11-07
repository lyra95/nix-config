{
  description = "NixOS WSL flake";

  inputs = {
    systems.url = "github:nix-systems/default";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.systems.follows = "systems";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvim = {
      url = "github:lyra95/nvim/main";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    flake-utils,
    agenix,
    home-manager,
    nvim,
    ...
  }: let
    system = "x86_64-linux";
    # https://discourse.nixos.org/t/using-nixpkgs-legacypackages-system-vs-import/17462/8
    # import vs legacyPackages
    # the latter has performance gain
    pkgsBuilder = system: nixpkgs.legacyPackages.${system};
    pkgs = pkgsBuilder system;
    _lib = import ./lib;
    wslBuilder = _lib.wslBuilder inputs;
    homeBuilder = _lib.homeBuilder inputs;
    nixosBuilder = _lib.nixosBuilder inputs;
  in
    # todo: add check 1. eval nix expression test 2. vm test
    {
      homeConfigurations = {
        "jo" = homeBuilder {
          name = "jo";
          inherit system pkgs;
          modules = [
            {
              aws.enable = true;
              git.enable = true;
              git.wsl = true;
              rclone.enable = true;
            }
          ];
        };
        "jo-nuc" = homeBuilder {
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
      };
      nixosConfigurations = {
        "home" = wslBuilder {
          name = "home";
          inherit system;
          userName = "jo";
          modules = [
            {
              wsl.docker-desktop.enable = true;
              fix.docker-desktop.enable = true;

              # This value determines the NixOS release from which the default
              # settings for stateful data, like file locations and database versions
              # on your system were taken. It's perfectly fine and recommended to leave
              # this value at the release version of the first install of this system.
              # Before changing this value read the documentation for this option
              # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
              system.stateVersion = "23.11"; # Did you read the comment?
            }
          ];
        };
        "dell" = wslBuilder {
          name = "dell";
          inherit system;
          userName = "jo";
          modules = [
            {
              # todos: podman setup
              wsl.docker-desktop.enable = false;

              system.stateVersion = "23.11";
            }
          ];
        };
        "work" = wslBuilder {
          name = "work";
          inherit system;
          userName = "jo";
          modules = [
            {
              wsl.docker-desktop.enable = true;
              fix.docker-desktop.enable = true;

              system.stateVersion = "23.11";
            }
          ];
        };
        "jonuc" = nixosBuilder {
          hostName = "jonuc";
          inherit system pkgs;
          defaultUserName = "jo";
          modules = [
            ./machines/nuc
          ];
        };
      };
    }
    // {
      nixosModules = let
        modules = {
          tailscale = ./modules/nixos/tailscale;
          xrdp = ./modules/nixos/xrdp;
          cifs = ./modules/nixos/cifs;
          k3s = ./modules/nixos/k3s;
        };
        wslModules = {
          docker-desktop-fix = ./modules/wsl/docker-desktop-fix.nix;
          vscode = ./modules/wsl/vscode.nix;
        };
        _wsl = {
          imports = builtins.attrValues wslModules;
        };
        _all = {
          imports = builtins.attrValues modules;
        };
      in
        modules
        // wslModules
        // {
          default = _all;
          wsl = _wsl;
        };
      homeManagerModules = let
        modules = {
          aws = ./modules/home-manager/aws;
          git = ./modules/home-manager/git;
          gitui = ./modules/home-manager/gitui;
          starship = ./modules/home-manager/starship;
          k8s = ./modules/home-manager/k8s.nix;
          nvim = ./modules/home-manager/nvim.nix;
          rclone = ./modules/home-manager/rclone;
        };

        _all = {
          imports = builtins.attrValues modules;
        };
      in
        modules // {default = _all;};
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = pkgsBuilder system;
    in {
      formatter = pkgs.alejandra;
      devShells.default = pkgs.mkShell {packages = [nvim.packages."${system}".default];};
    });
}
