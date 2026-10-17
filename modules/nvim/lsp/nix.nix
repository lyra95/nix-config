{
  config,
  lib,
  pkgs,
  ...
}: {
  options.lsp.nix.enable = lib.mkEnableOption "nix-lsp";

  config = lib.mkIf config.lsp.nix.enable {
    extraPackages = [pkgs.alejandra];

    plugins = {
      lsp = {
        servers = {
          nil_ls.enable = true;
          nil_ls.settings.formatting.command = ["alejandra"];
          nil_ls.settings.nix.flake.autoArchive = true; # setting true, this would use networks to fetch codes
        };
      };
    };
  };
}
