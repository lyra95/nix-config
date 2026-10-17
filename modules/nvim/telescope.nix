{
  config,
  lib,
  ...
}: {
  options.telescope.enable = lib.mkEnableOption "use telescope";
  config = lib.mkIf config.telescope.enable {
    plugins = {
      web-devicons.enable = true;
      telescope.enable = true;
      telescope.extensions.ui-select.enable = true;
      telescope.keymaps = {
        "<leader>f" = {
          action = "git_files";
          options = {
            desc = "Search files (respecting .gitignore)";
          };
        };
        "<leader>g" = {
          action = "live_grep";
          options.desc = "Search through files by keywords";
        };
      };
    };
  };
}
