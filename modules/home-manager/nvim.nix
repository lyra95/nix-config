{
  lib,
  config,
  ...
}: {
  options = {
    nvim.pkg = lib.mkOption {
      type = with lib.types; (nullOr package);
      description = "The neovim package to use";
    };

    nvim.enableBashIntegration = lib.mkOption {
      type = lib.types.bool;
      description = "Enable bash integration";
    };
  };

  config = lib.mkIf (config.nvim.pkg != null) {
    home.packages = [config.nvim.pkg];
    programs.bash = lib.mkIf config.nvim.enableBashIntegration {
      sessionVariables = {
        EDITOR = "nvim";
      };

      shellAliases = {
        vim = "nvim";
        vi = "nvim";
      };
    };
  };
}
