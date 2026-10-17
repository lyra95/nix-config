{
  inputs,
  inputs',
  homeModules,
  nvimPackage,
  name,
  stateVersion,
}: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  darwinModules = {
    ssh = {
      programs.ssh = {
        enableDefaultConfig = false;
        settings = {
          "*" = {
            ForwardAgent = false;
            AddKeysToAgent = "no";
            Compression = false;
            ServerAliveInterval = 0;
            ServerAliveCountMax = 3;
            HashKnownHosts = false;
            UserKnownHostsFile = "~/.ssh/known_hosts";
            ControlMaster = "no";
            ControlPath = "~/.ssh/master-%r@%n:%p";
            ControlPersist = "no";
          };
        };
      };
    };
    homebrew = {
      programs.bash.shellAliases = {
        bs = "brew search --eval-all '' | fzf --preview 'brew info {}'";
        bu = "brew upgrade -g";
      };
    };
  };
  coreModules = {
    age = {
      imports = [inputs.agenix.homeManagerModules.default];
      xdg.enable = lib.mkIf isDarwin true;
      # SSH cannot expand the shell command in agenix's default Darwin path.
      age.secretsDir = lib.mkIf isDarwin "${config.xdg.cacheHome}/agenix";
    };
    importAll = homeModules.default;
    nvim = {
      nvim.pkg = nvimPackage;
      nvim.enableBashIntegration = true;
    };
    home = {
      home.username = name;
      home.homeDirectory =
        if isDarwin
        then "/Users/${name}"
        else "/home/${name}";
      home.packages = [
        inputs'.home-manager.packages.default
      ];

      home.stateVersion = stateVersion;
      home.sessionPath = ["$HOME/.local/bin"];

      programs.home-manager.enable = true;

      # https://github.com/nix-community/home-manager/issues/355
      systemd.user.startServices = lib.mkIf pkgs.stdenv.hostPlatform.isLinux "sd-switch";
    };
  };
  commonModules = {
    misc = {
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
    };

    modern = {
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
    };
  };
in {
  imports =
    (builtins.attrValues commonModules)
    ++ (builtins.attrValues coreModules)
    ++ [{config = lib.mkIf isDarwin (lib.mkMerge (builtins.attrValues darwinModules));}];
}
