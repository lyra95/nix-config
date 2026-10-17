{
  config,
  lib,
  pkgs,
  ...
}: let
  # GUI launches have a minimal PATH. Give this app its own runtime tools.
  sioyekPath = lib.concatStringsSep ":" [
    (lib.makeBinPath [pkgs.uv])
    "/run/current-system/sw/bin"
    "/nix/var/nix/profiles/default/bin"
    "${config.homebrew.prefix}/bin"
    "${config.homebrew.prefix}/sbin"
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
  ];

  sioyek = pkgs.sioyek.overrideAttrs (old: {
    # nixpkgs installs sioyek's shaders and default configs into the app bundle's
    # Contents/MacOS, but sioyek looks them up under Contents/Resources, so every
    # page renders blank without this.
    postInstall =
      old.postInstall
      + ''
        resources=$out/Applications/sioyek.app/Contents/Resources
        mkdir -p $resources
        cp -r pdf_viewer/shaders $resources/shaders
        cp pdf_viewer/{prefs,keys}.config tutorial.pdf $resources/
      '';

    # sioyek is a Qt app, so wrapQtAppsHook already replaces
    # Contents/MacOS/sioyek with a makeBinaryWrapper that sets QT_PLUGIN_PATH and
    # execs .sioyek-wrapped. qtWrapperArgs appends to that same wrapper, so this
    # costs no extra layer and applies however the app is started -- Dock, Finder,
    # `open`, aerospace or straight from a shell.
    #
    # --prefix, not --set: whatever PATH the launcher provided is kept as the
    # tail, so /usr/bin and friends survive.
    qtWrapperArgs =
      (old.qtWrapperArgs or [])
      ++ [
        "--prefix PATH : ${sioyekPath}"
      ];
  });
in {
  imports = [../default-apps.nix];

  environment.systemPackages = [
    pkgs.duti
    sioyek
    pkgs.uv
  ];

  defaultApplications."com.adobe.pdf" = lib.mkDefault "info.sioyek.sioyek";
}
