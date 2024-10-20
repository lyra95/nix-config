{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    cifs = {
      mount = lib.mkOption {
        type = with lib.types; (nullOr string);
        default = null;
        description = "e.g. /mnt/nuc_backup";
      };

      remote = lib.mkOption {
        type = with lib.types; (nullOr string);
        default = null;
        description = "e.g. //jo-home/nuc_backup";
      };

      secret = lib.mkOption {
        type = with lib.types; (nullOr string);
        default = null;
        description = "path to username/passwd secret file";
      };
    };

    config = let
      cfg = config.cifs;
      allNull = lib.all (attr: attr == null) (lib.attrValues cfg);
      allSet = lib.all (attr: attr != null) (lib.attrValues cfg);
    in {
      assertions = [
        {
          assertion = allNull || allSet;
          message = "cifs options must be all set or all null";
        }
      ];
      environment.systemPackages = lib.mkIf allSet (with pkgs; [cifs-utils]);

      fileSystems."${cfg.mount}" = lib.mkIf allSet {
        device = "${cfg.remote}";
        fsType = "cifs";
        options = let
          # this line prevents hanging on network split
          automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
        in ["${automount_opts},credentials=${cfg.secret}"];
      };
    };
  };
}
