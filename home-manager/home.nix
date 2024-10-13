{nvim}: {pkgs, ...}: {
  imports = [
    ./modules/git
    ./modules/aws
    ./modules/k8s.nix
    ./modules/gitui
    ./modules/starship
  ];

  aws.enable = true;
  git.enable = true;
  starship = {
    enable = true;
    enableBashIntegration = true;
  };

  home.packages =
    (with pkgs; [
      jq
      yq-go
      hex
    ])
    ++ [nvim];

  # modern ls
  programs.eza = {
    enable = true;
    enableBashIntegration = true;
    git = true;
    icons = true;
  };

  # modern cat
  programs.bat = {
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

  # fuzzy finder (bash history, etc)
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
      cat = "bat";
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
