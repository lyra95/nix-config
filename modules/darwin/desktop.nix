profile: {pkgs, ...}: {
  networking.hostName = profile.hostName;

  imports = [./default-apps.nix];
  defaultApplications = {
    "public.plain-text" = "com.microsoft.VSCode";
    "public.source-code" = "com.microsoft.VSCode";
    "public.data" = "com.microsoft.VSCode";
  };

  fonts.packages = [pkgs.d2coding];

  environment.systemPackages = [
    pkgs.vim
    pkgs.git
    pkgs.direnv
    pkgs.home-manager
    pkgs.uv
  ];

  system.primaryUser = profile.userName;

  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
  system.defaults.NSGlobalDomain.AppleShowAllFiles = true;

  system.defaults.screencapture.target = "clipboard";

  nix.settings.experimental-features = "nix-command flakes";

  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults.finder = {
    AppleShowAllExtensions = true;
    AppleShowAllFiles = true;
  };
}
