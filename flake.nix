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
    # https://discourse.nixos.org/t/using-nixpkgs-legacypackages-system-vs-import/17462/8
    # import vs legacyPackages
    # the latter has performance gain
    pkgsBuilder = system: nixpkgs.legacyPackages.${system};
    _lib = import ./lib;
    wslBuilder = _lib.wslBuilder inputs;
  in
    {
      homeConfigurations."jo" =
        home-manager.lib.homeManagerConfiguration
        {
          pkgs = pkgsBuilder "x86_64-linux";
          modules = [
            agenix.homeManagerModules.default
            ((import ./home-manager/home.nix)
              {
                nvim = nvim.packages."x86_64-linux".default;
              })
            {
              home.username = "jo";
              home.homeDirectory = "/home/jo";
            }
          ];
        };
      nixosConfigurations = {
        "home" = wslBuilder {
          name = "home";
          system = "x86_64-linux";
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
        "dell" = wslBuilder {
          name = "dell";
          system = "x86_64-linux";
          userName = "jo";
          modules = [
            {
              wsl.docker-desktop.enable = false;

              system.stateVersion = "23.11";
            }
          ];
        };
        "work" = wslBuilder {
          name = "work";
          system = "x86_64-linux";
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
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = pkgsBuilder system;
    in {
      formatter = pkgs.alejandra;
      devShells.default = pkgs.mkShell {packages = [nvim.packages."${system}".default];};
    });
}
