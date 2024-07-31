{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options.fix.docker-desktop.enable = mkEnableOption "docker desktop fix";

  config = let
    resources = "C:\\Program Files\\Docker\\Docker\\resources";
  in
    mkIf (config.wsl.docker-desktop.enable && config.fix.docker-desktop.enable) {
      systemd.services.docker-desktop-proxy = {
        # This Command Line Interface is keep changing. This is the latest command to run the docker-desktop-proxy (Docker Desktop Version: 4.33.1 (161083))
        script = mkForce ''
          ${config.wsl.wslConf.automount.root}/wsl/docker-desktop/docker-desktop-user-distro proxy --docker-desktop-root ${config.wsl.wslConf.automount.root}/wsl/docker-desktop '${resources}'
        '';
        path = [pkgs.mount];
      };
    };
}
