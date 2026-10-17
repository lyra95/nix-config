{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.podman;
in {
  options.podman = {
    enable = lib.mkEnableOption "the Docker client with a shared Podman backend";
    user = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "User allowed to connect to the Podman socket.";
    };
    socketPath = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/wsl/podman-sockets/podman-machine-default/podman-root.sock";
      description = "Path to the Unix socket shared by Podman Desktop.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.docker-client];
    users.groups.podman.members = lib.mkIf (cfg.user != null) [cfg.user];
    environment.variables.DOCKER_HOST = "unix://${cfg.socketPath}";

    # The external WSL machine may start after NixOS or replace its socket.
    # Watch the directory rather than requiring transient mount unit names.
    systemd.paths.chmod-podman-socket = {
      wantedBy = ["multi-user.target"];
      pathConfig.PathChanged = builtins.dirOf cfg.socketPath;
    };
    systemd.services.chmod-podman-socket = {
      wantedBy = ["multi-user.target"];
      unitConfig.ConditionPathIsSocket = cfg.socketPath;
      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.getExe (pkgs.writeShellApplication {
          name = "chmod-podman-socket";
          runtimeInputs = [pkgs.coreutils];
          text = ''
            chown :podman ${lib.escapeShellArg cfg.socketPath}
            chmod g+rw ${lib.escapeShellArg cfg.socketPath}
          '';
        });
      };
    };
  };
}
