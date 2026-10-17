{pkgs, ...}: {
  home.packages = with pkgs; [
    jq
    yq-go
    hex
    nix-search-cli
  ];

  starship = {
    enable = true;
    enableBashIntegration = true;
  };
  k8s.enable = true;
  gitui.enable = true;

  programs.nix-search-tv = {
    enable = true;
    settings = {
      indexes = ["nixpkgs" "home-manager" "nixos"];

      experimental = {
        render_docs_indexes = {
          nvf = "https://notashelf.github.io/nvf/options.html";
        };
      };
    };
  };

  programs.bash = {
    enable = true;
    historyControl = ["erasedups" "ignoredups" "ignorespace"];
    historyIgnore = ["ls" "cd" "exit"];
    shellAliases = {
      ns = "nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history";
    };
  };

  # file explorer, Windows Terminal (>= v1.22.2362.0)
  programs.yazi = {
    enable = true;
    shellWrapperName = "yy";
    enableBashIntegration = true;
  };

  # tmux alternative
  programs.zellij = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  # fuzzy finder (bash history, etc)
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };
}
