{pkgs, ...}: {
  imports = [
    ./homeManagerModules/git
    ./homeManagerModules/aws
  ];

  aws.enable = true;
  git.enable = true;

  home.packages = with pkgs; [
    jq
  ];

  programs.gitui = {
    enable = true;
  };

  # file explorer, Windows Terminal (>= v1.22.2362.0)
  programs.yazi = {
    enable = true;
  };

  # tmux alternative
  programs.zellij = {
    enable = true;
  };

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  # Don't know well but sometimes user level services are not started/restarted
  # Looklike home-manager do not reload services when its parent services?
  # https://github.com/nix-community/home-manager/issues/355
  systemd.user.startServices = "sd-switch";
}
