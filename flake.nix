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
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.systems.follows = "systems";
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
  in
    {
      homeConfigurations."jo" = homeBuilder {
        name = "jo";
        inherit system pkgs;
        modules = [
          {
            aws.enable = true;
            git.enable = true;
          }
        ];
      };
      nixosConfigurations = {
        "home" = wslBuilder {
          name = "home";
          inherit system;
          userName = "jo";
          modules = [
            {
              imports = [
                ./modules/docker-desktop-fix.nix
              ];

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
              imports = [
                ./modules/docker-desktop-fix.nix
              ];

              wsl.docker-desktop.enable = true;
              fix.docker-desktop.enable = true;

              system.stateVersion = "23.11";
            }
          ];
        };
      };
    }
    // {
      homeManagerModules = rec {
        aws = ./modules/home-manager/aws;
        git = ./modules/home-manager/git;
        gitui = ./modules/home-manager/gitui;
        starship = ./modules/home-manager/starship;
        k8s = ./modules/home-manager/k8s.nix;
        nvim = ./modules/home-manager/nvim.nix;
        _all = {
          imports = [
            aws
            git
            gitui
            starship
            k8s
            nvim
          ];
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = pkgsBuilder system;
    in {
      formatter = pkgs.alejandra;
      devShells.default = pkgs.mkShell {packages = [nvim.packages."${system}".default];};
    });
}
