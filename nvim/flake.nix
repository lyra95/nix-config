{
  description = "My neovim setup";

  inputs = {
    systems.url = "github:nix-systems/default";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    nixpkgs.url = "github:NixOS/nixpkgs";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    nixvim,
    devshell,
    ...
  }:
    (let
      # https://discourse.nixos.org/t/using-nixpkgs-legacypackages-system-vs-import/17462/8
      # import vs legacyPackages
      # the latter has performance gain
      pkgsBuilder = system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      moduleBuilder = pkgs: {
        inherit pkgs;
        module = {
          imports = [
            self.nixvimModules.default
            ./default.nix
          ];
        };
        extraSpecialArgs = {};
      };

      # https://github.com/nix-community/nixvim/blob/356896f58dde22ee16481b7c954e340dceec340d/modules/top-level/test.nix#L70
      # https://ryantm.github.io/nixpkgs/builders/trivial-builders/#trivial-builder-runCommandLocal
      # builds nvim locally, and tests `nvim -mn --headless "+q"` to see if it exits successfully
      checkBuilder = module: system: let
        nixvimLib = nixvim.lib.${system};
      in
        nixvimLib.checkModule module;

      vimBuilder = module: system: let
        nixvim' = nixvim.legacyPackages.${system};
      in
        nixvim'.makeNixvimWithModule module;
    in
      flake-utils.lib.eachDefaultSystem (system: let
        pkgs = pkgsBuilder system;
        module = moduleBuilder pkgs;
      in {
        formatter = pkgs.alejandra;
        devShells.default = let
          mkShell =
            (import devshell {
              inherit system;
              nixpkgs = pkgs;
            })
            .mkShell;
        in
          mkShell {
            packages = [(vimBuilder module system) pkgs.alejandra];
            commands = [
              {
                help = "run formatter";
                name = "fmt";
                command = ''
                  alejandra "$PWD"
                '';
              }
              {
                help = "debug nix expression";
                name = "debug";
                command = ''
                  nix repl --extra-experimental-features 'flakes repl-flake' "$PWD"
                '';
              }
            ];
          };
        packages.default = vimBuilder module system;
        check = checkBuilder module system;
      }))
    // {
      nixvimModules = let
        modules = {
          folding = ./modules/folding.nix;
          completion = ./modules/completion.nix;
          copilot = ./modules/copilot.nix;
          telescope = ./modules/telescope.nix;
          neotree = ./modules/neotree.nix;
          bufferline = ./modules/bufferline.nix;
          lsp = ./modules/lsp;
          misc = ./modules/misc;
        };
        all = {
          imports = builtins.attrValues modules;
        };
      in
        modules // {default = all;};
    };
}
