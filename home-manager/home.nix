{nvim}: {pkgs, ...}: {
  imports = [
    ./modules/git
    ./modules/aws
    ./modules/k8s.nix
    ./modules/gitui
  ];

  aws.enable = true;
  git.enable = true;

  home.packages =
    (with pkgs; [
      jq
      yq-go
      hex
    ])
    ++ [nvim];

  programs.eza = {
    enable = true;
    enableBashIntegration = true;
    git = true;
    icons = true;
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      command_timeout = 10000;
    };
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
      vi = "nvim";
      ls = "eza";
      ll = "eza -al";
      tree = "eza --tree";
    };
  };

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  # Don't know well but sometimes user level services are not started/restarted
  # Looklike home-manager do not reload services when its parent services?
  # https://github.com/nix-community/home-manager/issues/355
  systemd.user.startServices = "sd-switch";
}
