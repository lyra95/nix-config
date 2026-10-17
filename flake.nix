{
  description = "NixOS WSL flake";

  inputs = {
    systems.url = "github:nix-systems/default";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # Retained for nvim's flake-utils input.
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-wsl = {
      # Track the WSL branch that supports nixos-unstable.
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "pre-commit/flake-compat";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.flake-parts.follows = "flake-parts";
    };

    nvim = {
      url = "github:lyra95/nvim/main";
      inputs.systems.follows = "systems";
      inputs.flake-utils.follows = "flake-utils";
      inputs.devshell.follows = "devshell";
      # Keep nvim's pinned nixpkgs: its Nixvim version references removed packages
      # (e.g. lexical) when evaluated with the root nixos-unstable input.
      inputs.nixvim.inputs = {
        flake-parts.follows = "flake-parts";
        systems.follows = "systems";
        nuschtosSearch.inputs.flake-utils.follows = "flake-utils";
      };
    };

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = import inputs.systems;

      imports = [
        ./parts/modules.nix
        ./parts/nixos.nix
        ./parts/homes.nix
        ./parts/dev.nix
      ];
    };
}
