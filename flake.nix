{
  description = "NixOS WSL flake";

  inputs = {
    systems.url = "github:nix-systems/default";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.systems.follows = "systems";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvim.url = "github:lyra95/nvim/main";

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit = {
      url = "github:cachix/git-hooks.nix";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    nvim,
    devshell,
    pre-commit,
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

      checks = {
        pre-commit = pre-commit.lib.${system}.run {
          src = ./.;
          hooks = {
            alejandra.enable = true;
            alejandra.package = pkgs.alejandra;
          };
        };
      };

      devShells.default = let
        mkShell =
          (import devshell {
            inherit system;
            nixpkgs = pkgs;
          })
          .mkShell;
      in
        mkShell {
          env = [
            {
              name = "FLAKE_ROOT";
              eval = "$PWD";
            }
          ];

          devshell.startup."pre-commit".text = self.checks.${system}.pre-commit.shellHook;

          packages =
            [
              pkgs.alejandra
              nvim.packages."${system}".default
            ]
            ++ self.checks.${system}.pre-commit.enabledPackages;

          commands = [
            {
              help = "run formatter";
              name = "fmt";
              command = ''
                alejandra "$FLAKE_ROOT"
              '';
            }
            {
              help = "debug nix expression";
              name = "debug";
              command = ''
                nix repl --extra-experimental-features 'flakes repl-flake' "$FLAKE_ROOT"
              '';
            }
            {
              help = "home-manager switch";
              name = "hs";
              command = "home-manager switch --flake .#$(hostname)";
              category = "home-manager";
            }
            {
              help = "nixos-rebuild switch";
              name = "ns";
              command = "sudo nixos-rebuild switch --flake .#$(hostname)";
              category = "nixos";
            }
            {
              help = "nixos-rebuild boot";
              name = "nb";
              command = "sudo nixos-rebuild boot --flake .#$(hostname)";
              category = "nixos";
            }
          ];
        };
    });
}
