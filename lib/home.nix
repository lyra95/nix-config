inputs @ {
  self,
  home-manager,
  agenix,
  nvim,
  ...
}: {
  name,
  modules,
  system,
  pkgs,
  ...
}: let
  coreModules = {
    age = agenix.homeManagerModules.default;
    importAll = self.homeManagerModules.default;
    nvim = {
      nvim.pkg = nvim.packages.${system}.default;
      nvim.enableBashIntegration = true;
    };
    home = {
      home.username = name;
      home.homeDirectory = "/home/${name}";
      home.packages = [
        home-manager.packages.${system}.default
      ];

      home.stateVersion = "24.05";

      programs.home-manager.enable = true;

      # https://github.com/nix-community/home-manager/issues/355
      systemd.user.startServices = "sd-switch";
    };
  };
  commonModules = {
    misc = {
      home.packages = with pkgs; [
        jq
        yq-go
        hex
      ];

      starship = {
        enable = true;
        enableBashIntegration = true;
      };
      k8s.enable = true;
      gitui.enable = true;

      programs.bash = {
        enable = true;
        historyControl = ["erasedups" "ignoredups" "ignorespace"];
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
        icons = true;
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
in
  home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules =
      modules
      ++ (builtins.attrValues commonModules)
      ++ (builtins.attrValues coreModules);
  }
