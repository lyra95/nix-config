{
  lib,
  pkgs,
  ...
}: let
  modules = {
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
in {
  config = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (lib.mkMerge (builtins.attrValues modules));
}
