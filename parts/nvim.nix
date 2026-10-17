{inputs, ...}: {
  flake.nixvimModules = let
    modules = {
      folding = ../modules/nvim/folding.nix;
      completion = ../modules/nvim/completion.nix;
      copilot = ../modules/nvim/copilot.nix;
      telescope = ../modules/nvim/telescope.nix;
      neotree = ../modules/nvim/neotree.nix;
      bufferline = ../modules/nvim/bufferline.nix;
      lsp = ../modules/nvim/lsp;
      misc = ../modules/nvim/misc;
    };
  in
    modules
    // {
      default = {imports = builtins.attrValues modules;};
    };

  perSystem = {
    pkgsUnfree,
    system,
    ...
  }: let
    module = {
      pkgs = pkgsUnfree;
      module = ../modules/nvim;
    };
    nvim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule module;
  in {
    packages = {inherit nvim;};
    checks.nvim-package = nvim;
    checks.nvim =
      nvim.config.build.test.overrideAttrs
      (old: {
        # Neo-tree needs its log directory before the first sandboxed launch.
        buildCommand =
          ''
            export XDG_DATA_HOME="$TMPDIR/nvim-data"
            mkdir -p "$XDG_DATA_HOME/nvim"
          ''
          + old.buildCommand;
      });
  };
}
