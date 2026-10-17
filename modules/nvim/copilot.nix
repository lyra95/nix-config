{
  config,
  lib,
  ...
}: {
  options.copilot.enable = lib.mkEnableOption "use copilot";

  # need to run :Copilot setup once
  config = lib.mkIf config.copilot.enable {
    globals.copilot_no_tab_map = true;
    plugins = {
      copilot-vim.enable = true;
      cmp = {
        enable = true;
        settings.mapping."<leader>j" = ''
          vim.keymap.set('i', '<leader>j', 'copilot#Accept("\\<CR>")', {
            expr = true,
            replace_keycodes = false
          })
        '';
      };
    };
  };
}
