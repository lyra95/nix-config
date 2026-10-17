{
  config,
  lib,
  ...
}: {
  options.completion.enable = lib.mkEnableOption "use completion";

  # https://github.com/hrsh7th/nvim-cmp
  config = lib.mkIf config.completion.enable {
    plugins = {
      cmp.enable = true;
      cmp-treesitter.enable = true;

      cmp.settings.sources = [
        {name = "nvim_lsp";}
        {name = "path";}
        {name = "buffer";}
        {name = "treesitter";}
      ];

      # :help cmp-mapping
      cmp.settings.mapping = {
        "<C-Space>" = "cmp.mapping.complete()";
        "<C-d>" = "cmp.mapping.scroll_docs(-4)";
        "<C-e>" = "cmp.mapping.close()";
        "<C-f>" = "cmp.mapping.scroll_docs(4)";
        "<CR>" = "cmp.mapping.confirm({ select = true })";
        "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
        "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
      };
    };
  };
}
