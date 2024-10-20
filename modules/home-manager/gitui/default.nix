# issues:
# 1. side-by-side diff (https://github.com/extrawurst/gitui/issues/1294)
# 2. git push ssh credential (https://github.com/extrawurst/gitui/issues/495)
# git push with ssh is not working currently due to libgit2 ssh client issue
{
  config,
  lib,
  pkgs,
  ...
}: {
  options.gitui.enable = lib.mkEnableOption "gitui";

  config = lib.mkIf config.gitui.enable {
    home.packages = with pkgs; [
      wl-clipboard # gitui clipboard dependency
    ];

    programs.gitui = {
      enable = true;
    };
  };
}
