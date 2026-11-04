{
  config,
  lib,
  pkgs,
  ...
}: {
  options.rclone.enable = lib.mkEnableOption "use rclone";

  config = lib.mkIf config.rclone.enable {
    home.packages = [pkgs.rclone];
  };
}
