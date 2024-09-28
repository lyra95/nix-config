{nvim}: {pkgs, ...}: {
  imports = [
    ./modules/git
    ./modules/aws
  ];

  aws.enable = true;
  git.enable = true;

  home.packages =
    (with pkgs; [
      jq
      wl-clipboard # gitui clipboard dependency
    ])
    ++ [nvim];

  # https://github.com/extrawurst/gitui/issues/495
  # git push with ssh is not working currently due to libgit2 ssh client issue
  programs.gitui = {
    enable = true;
  };

  # file explorer, Windows Terminal (>= v1.22.2362.0)
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
  };

  # tmux alternative
  programs.zellij = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };
  programs.bash = {
    enable = true;
    historyControl = ["erasedups" "ignoredups" "ignorespace"];
    sessionVariables = {
      EDITOR = "nvim";
    };
    shellAliases = {
      vim = "nvim";
    };
  };

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  # Don't know well but sometimes user level services are not started/restarted
  # Looklike home-manager do not reload services when its parent services?
  # https://github.com/nix-community/home-manager/issues/355
  systemd.user.startServices = "sd-switch";
}
