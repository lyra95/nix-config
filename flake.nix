{
  description = "NixOS WSL flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
  };

  outputs =
    { nixpkgs, nixos-wsl, ... }:
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit nixos-wsl;
          };
          modules = [ ./configuration.nix ];
        };
      };
    };
}
