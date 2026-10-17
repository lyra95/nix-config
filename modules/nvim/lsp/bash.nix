{
  config,
  lib,
  ...
}: {
  options.lsp.bash.enable = lib.mkEnableOption "bash language server";
  config = lib.mkIf config.lsp.bash.enable {
    plugins.lsp.servers.bashls = {
      enable = true;
    };

    plugins.none-ls.enable = true;
    plugins.none-ls.sources.formatting.shfmt.enable = true;
  };
}
