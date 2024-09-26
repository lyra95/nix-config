{
  nixos-wsl,
  agenix,
  system,
  defaultUserName,
  hostName,
}:
# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL
{pkgs, ...}: {
  imports = [
    nixos-wsl.nixosModules.wsl
    ./modules/docker-desktop-fix.nix
  ];

  nixpkgs.hostPlatform = system;

  wsl.enable = true;
  wsl.defaultUser = defaultUserName;
  wsl.wslConf.network.hostname = hostName;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  environment.systemPackages =
    [
      agenix.packages."${system}".default
    ]
    ++ (with pkgs; [
      git
      vim
      file
    ]);
  wsl.docker-desktop.enable = true;
  fix.docker-desktop.enable = true;
  environment.variables.EDITOR = "vim";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
