# single node k3s cluster
{
  config,
  lib,
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

      # Let k3s apply permissions every time it writes or rotates kubeconfig.
      # https://docs.k3s.io/cli/server#client
      services.k3s.extraFlags = lib.optionals (user != null) [
        "--write-kubeconfig-group=k3s"
        "--write-kubeconfig-mode=0640"
      ];
    });
}
