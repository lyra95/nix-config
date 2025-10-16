{
  pkgs,
  lib,
  config,
  ...
}: {
  options.kind.enable = lib.mkEnableOption "kind";

  config = lib.mkIf config.kind.enable {
    home.packages = [pkgs.kind];

    programs.bash = {
      shellAliases = {
        ek = "enter-kind";
      };

      initExtra = builtins.readFile ./enter-kind.sh;
    };
  };
}
