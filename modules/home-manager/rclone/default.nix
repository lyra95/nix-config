{
  config,
  lib,
  pkgs,
  ...
}: {
  options.rclone.enable = lib.mkEnableOption "use rclone";

  config = lib.mkIf config.rclone.enable {
    home.packages = [pkgs.rclone];

    age.secrets."rclone.conf" = {
      file = ./rclone.conf.age;
      path = "${config.home.homeDirectory}/.config/rclone/rclone.conf";
    };
  };
}
