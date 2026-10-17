{
  config,
  inputs,
  lib,
  withSystem,
  ...
}: {
  flake.nixosModules = {
    tailscale = ../modules/nixos/tailscale;
    xrdp = ../modules/nixos/xrdp;
    cifs = ../modules/nixos/cifs;
    k3s = ../modules/nixos/k3s;
    bug-fix = ../modules/nixos/bug-fix;
    vscode = lib.modules.importApply ../modules/wsl/vscode.nix {inherit (inputs) vscode-server;};
    podman = ../modules/wsl/podman.nix;

    default = ../modules/nixos;
    base = ../modules/nixos/base.nix;
    wsl = lib.modules.importApply ../modules/wsl/default.nix {inherit (inputs) vscode-server;};
  };

  perSystem = {system, ...}: {
    checks = (
      lib.mapAttrs' (name: host:
        lib.nameValuePair "nixos-${name}" host.config.system.build.toplevel)
      (lib.filterAttrs (_: host: host.pkgs.stdenv.hostPlatform.system == system) config.flake.nixosConfigurations)
    );
  };

  flake.nixosConfigurations =
    lib.genAttrs ["home" "dell" "work"] (name:
      inputs.nixpkgs.lib.nixosSystem {
        modules = [
          (import ../modules/wsl/profile.nix {
            inherit inputs name;
            system = "x86_64-linux";
            userName = "jo";
          })
        ];
      })
    // {
      jonuc = withSystem "x86_64-linux" ({system, ...}: let
        hostName = "jonuc";
        defaultUserName = "jo";
      in
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {inherit hostName defaultUserName;};
          modules = [
            ../machines/nuc
            (import ../modules/nixos/profiles/default.nix {
              inherit inputs hostName defaultUserName;
            })
          ];
        });
    };
}
