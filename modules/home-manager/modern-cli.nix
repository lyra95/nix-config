{pkgs, ...}: {
  home.packages = with pkgs; [
    bat-extras.batman # modern man
    delta # modern diff
  ];

  # modern ls
  programs.eza = {
    enable = true;
    enableBashIntegration = true;
    git = true;
    icons = "auto";
  };

  # modern grep
  programs.ripgrep.enable = true;

  # modern find
  programs.fd.enable = true;

  # modern cat
  programs.bat = {
    enable = true;
  };

  programs.bash = {
    shellAliases = {
      ls = "eza";
      ll = "eza -al";
      cat = "bat";
      tree = "eza --tree";
      find = "fd";
      grep = "rg";
      man = "batman";
      diff = "delta";
    };
  };
}
