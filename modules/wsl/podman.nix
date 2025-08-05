{
  config,
  lib,
  pkgs,
  ...
}: let
  machinePath = "/mnt/wsl/podman-sockets/podman-machine-default";
  socketPath = "${machinePath}/podman-root.sock";
  cfg = config.podman;
in {
  options.podman = {
    enable = lib.mkEnableOption "Enable the docker client with podman backend";
    user = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "user to have access to the docker client";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [docker-client];

    users.groups.podman.members = lib.mkIf (cfg.user != null) [cfg.user];

    environment.variables.DOCKER_HOST = "unix://${socketPath}";

    systemd.services.chmod-podman-socket = let
      units = [
        "mnt-wsl-podman\\x2dsockets-podman\\x2dmachine\\x2ddefault-podman\\x2droot.sock.mount"
        "mnt-wsl-podman\\x2dsockets-podman\\x2dmachine\\x2ddefault-podman\\x2duser.sock.mount"
      ];
    in {
      wantedBy = ["multi-user.target"];
      after = units;
      requires = units;
      serviceConfig = {
        Type = "oneshot";
        ExecStart = let
          app = pkgs.writeShellApplication {
            name = "chmod-podman-socket";
            runtimeInputs = [pkgs.coreutils];
            text = ''
              chown :podman ${socketPath}
              chmod g+r ${socketPath}
            '';
          };
        in
          lib.getExe app;
      };
    };
  };
}
