{
  config,
  lib,
  ...
}: {
  options.xrdp.enable = lib.mkEnableOption "to run rdp server";

  config = lib.mkIf config.xrdp.enable {
    # Enable the X11 windowing system.
    services.xserver.enable = true;
    services.xrdp.enable = true;
    services.xrdp.defaultWindowManager = "startplasma-x11";
    services.xrdp.openFirewall = true;

    # Enable the KDE Plasma Desktop Environment.
    services.xserver.displayManager.sddm.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;

    # Configure keymap in X11
    services.xserver = {
      layout = "us";
      xkbVariant = "";
    };
  };
}
