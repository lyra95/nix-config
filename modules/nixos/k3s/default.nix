# single node k3s cluster
{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    k3s.enable = lib.mkEnableOption "k3s";
    k3s.user = lib.mkOption {
      type = with lib.types; (nullOr str);
      default = null;
      description = "user to have access to the k3s cluster";
    };
  };

  config =
    lib.mkIf config.k3s.enable
    (let
      user = config.k3s.user;
    in {
      networking.firewall.allowedTCPPorts = [
        6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
      ];

      services.k3s.enable = true;
      services.k3s.role = "server";

      users.groups.k3s.members = lib.mkIf (user != null) [config.k3s.user];

      systemd.services.chmod-config = lib.mkIf (user != null) {
        wantedBy = ["multi-user.target"];
        after = ["k3s.service"];
        wants = ["k3s.service"];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = let
            app = pkgs.writeShellApplication {
              name = "chmod-config";
              runtimeInputs = [pkgs.coreutils];
              text = ''
                chown :k3s /etc/rancher/k3s/k3s.yaml
                chmod g+r /etc/rancher/k3s/k3s.yaml
              '';
            };
          in
            lib.getExe app;
        };
      };
    });
}
