{
  description = "NixOS WSL flake";

  inputs = {
    systems.url = "github:nix-systems/default";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";
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
    nixvim.url = "github:nix-community/nixvim/nixos-24.05";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    nixos-wsl,
    flake-utils,
    agenix,
    home-manager,
    nixvim,
    ...
  }:
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {};
          modules = let
            configurationNix =
              (import ./configuration.nix)
              {
                inherit agenix;
                inherit nixos-wsl;
                system = "x86_64-linux";
                defaultUserName = "nixos";
              };
          in [
            configurationNix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                sharedModules = [
                  agenix.homeManagerModules.default
                ];
                extraSpecialArgs = {};
                users.nixos = import ./home.nix;
              };
            }
          ];
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
      devShells.default = let
        nixvim' = nixvim.legacyPackages.${system};
        nixvimModule = {
          inherit pkgs;
          module = import ./nixvim;
          extraSpecialArgs = {};
        };
        nvim = nixvim'.makeNixvimWithModule nixvimModule;
      in
        pkgs.mkShell {packages = [nvim];};
    });
}
