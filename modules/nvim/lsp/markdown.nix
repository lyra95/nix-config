{
  lib,
  config,
  ...
}: {
  options.lsp.markdown = {
    enable = lib.mkEnableOption "use markdown lsp";
  };
  config = lib.mkIf config.lsp.markdown.enable {
    plugins.lsp.servers.markdown_oxide = {
      enable = true;
    };

    plugins.markdown-preview = {
      enable = true;
    };

    keymaps = [
      {
        action = "<cmd>MarkdownPreview<cr>";
        mode = "n";
        key = "<leader>mp";
        options.desc = "Markdown Preview";
      }
    ];

    plugins.render-markdown = {
      enable = true;
    };

    plugins.none-ls.enable = true;
    plugins.none-ls.sources = {
      diagnostics.markdownlint.enable = true;
      formatting.markdownlint.enable = true;
    };
  };
}
