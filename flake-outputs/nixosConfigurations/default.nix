inputs: let
  system = "x86_64-linux";
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  _lib = import ./lib inputs;
  wslBuilder = _lib.wslBuilder;
  nixosBuilder = _lib.nixosBuilder;
in {
  "home" = wslBuilder {
    name = "home";
    inherit system;
    userName = "jo";
    modules = [
      {
        wsl.docker-desktop.enable = true;
        fix.docker-desktop.enable = true;

        # This value determines the NixOS release from which the default
        # settings for stateful data, like file locations and database versions
        # on your system were taken. It's perfectly fine and recommended to leave
        # this value at the release version of the first install of this system.
        # Before changing this value read the documentation for this option
        # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
        system.stateVersion = "23.11"; # Did you read the comment?
      }
    ];
  };
  "dell" = wslBuilder {
    name = "dell";
    inherit system;
    userName = "jo";
    modules = [
      {
        # todos: podman setup
        wsl.docker-desktop.enable = false;

        system.stateVersion = "23.11";
      }
    ];
  };
  "work" = wslBuilder {
    name = "work";
    inherit system;
    userName = "jo";
    modules = [
      {
        wsl.docker-desktop.enable = true;
        fix.docker-desktop.enable = true;

        system.stateVersion = "23.11";
      }
    ];
  };
  "jonuc" = nixosBuilder {
    hostName = "jonuc";
    inherit system pkgs;
    defaultUserName = "jo";
    modules = [
      ./machines/nuc
    ];
  };
}
