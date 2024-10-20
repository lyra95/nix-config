{
  config,
  pkgs,
  lib,
  ...
}: {
  options.tailscale = {
    enable = lib.mkEnableOption "Enable Tailscale";
    hostName = lib.mkOption {
      type = lib.types.str;
      description = "The hostname to use for the Tailscale node";
    };
    pkgs = lib.mkOption {
      type = lib.types.package;
      default = pkgs.tailscale;
      description = "The package to use for Tailscale";
    };
    authKeyFile = lib.mkOption {
      type = lib.types.path;
      description = "The path to the Tailscale authentication key";
    };
  };

  config = lib.mkIf config.tailscale.enable {
    services.tailscale = {
      enable = true;
      openFirewall = true;
      package = config.tailscale.pkgs;
      authKeyFile = config.tailscale.authKeyFile;
      extraUpFlags = ["--advertise-exit-node" "--ssh" "--hostname" config.tailscale.hostName];
    };
  };
}
