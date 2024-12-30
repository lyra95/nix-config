{
  config,
  lib,
  pkgs,
  ...
}: {
  options.fix.docker-desktop.enable = lib.mkEnableOption "docker desktop fix";

  config = let
    resources = "C:\\Program Files\\Docker\\Docker\\resources";
  in
    lib.mkIf (config.wsl.docker-desktop.enable && config.fix.docker-desktop.enable) {
      # https://github.com/nix-community/NixOS-WSL/commit/3a22a1981ebb1edea051cf918a98fe10e1b3a99e
      # this service unit does the same thing with 'Docker Desktop -> Settings -> Resources -> WSL Integration toggle'
      # but docker-desktop-proxy commandline interface often makes breaking changes
      systemd.services.docker-desktop-proxy = {
        path = [pkgs.mount];
        description = "Docker Desktop proxy";
        script = ''
          ${config.wsl.wslConf.automount.root}/wsl/docker-desktop/docker-desktop-user-distro proxy --distro-name NixOS --docker-desktop-root ${config.wsl.wslConf.automount.root}/wsl/docker-desktop "${resources}"
        '';
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Restart = "on-failure";
          RestartSec = "30s";
        };
      };
    };
}
