# issues:
# 1. side-by-side diff (https://github.com/extrawurst/gitui/issues/1294)
# 2. git push ssh credential (https://github.com/extrawurst/gitui/issues/495)
# git push with ssh is not working currently due to libgit2 ssh client issue
{pkgs, ...}: {
  home.packages = with pkgs; [
    wl-clipboard # gitui clipboard dependency
  ];

  programs.gitui = {
    enable = true;
  };
}
