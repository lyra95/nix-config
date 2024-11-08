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
    nvim,
    ...
  }:
    {
      homeConfigurations = import ./flake-outputs/homeConfigurations inputs;
      homeManagerModules = import ./flake-outputs/homeManagerModules.nix inputs;
      nixosConfigurations = import ./flake-outputs/nixosConfigurations inputs;
      nixosModules = import ./flake-outputs/nixosModules.nix inputs;
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      formatter = pkgs.alejandra;
      devShells.default = pkgs.mkShell {packages = [nvim.packages."${system}".default];};
    });
}
