# single node k3s cluster
{
  config,
  lib,
  ...
}: {
  options = {
    k3s.enable = lib.mkEnableOption "k3s";
  };

  config = lib.mkIf config.k3s.enable {
    networking.firewall.allowedTCPPorts = [
      6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    ];

    services.k3s.enable = true;
    services.k3s.role = "server";
  };
}
