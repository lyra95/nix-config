{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.defaultApplications;
in {
  options.defaultApplications = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {};
    example = {"com.adobe.pdf" = "info.sioyek.sioyek";};
    description = "Default application bundle IDs by UTI, applied for system.primaryUser.";
  };

  config = lib.mkIf (cfg != {}) {
    assertions = [
      {
        assertion = config.system.primaryUser != null;
        message = "defaultApplications requires system.primaryUser.";
      }
    ];

    # duti is idempotent; setting associations avoids parsing its display output.
    system.activationScripts.postActivation.text = lib.concatStringsSep "\n" (
      lib.mapAttrsToList (uti: bundleId: ''
        sudo -u ${lib.escapeShellArg config.system.primaryUser} -- ${lib.getExe pkgs.duti} -s ${lib.escapeShellArg bundleId} ${lib.escapeShellArg uti} all
      '')
      cfg
    );
  };
}
