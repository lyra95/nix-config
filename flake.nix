{
  description = "NixOS WSL flake";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    nixos-wsl,
    flake-utils,
    ...
  }:
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit nixos-wsl;
          };
          modules = [./configuration.nix];
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      # https://discourse.nixos.org/t/using-nixpkgs-legacypackages-system-vs-import/17462/8
      # import vs legacyPackages
      # the latter uses less disk size
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      formatter = pkgs.alejandra;
      devShells.default = pkgs.mkShell {packages = with pkgs; [alejandra];};
    });
}
