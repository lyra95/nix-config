{
  config,
  inputs,
  lib,
  withSystem,
  ...
}: let
  inherit (config.flake) nixosModules;
in {
  perSystem = {system, ...}: {
    checks = lib.optionalAttrs (system == "x86_64-linux") (
      lib.mapAttrs' (name: host:
        lib.nameValuePair "nixos-${name}" host.config.system.build.toplevel)
      config.flake.nixosConfigurations
    );
  };

  flake.nixosConfigurations =
    lib.genAttrs ["home" "dell" "work"] (name:
      inputs.nixpkgs.lib.nixosSystem {
        modules = [
          {
            wsl.docker-desktop.enable = false;
            system.stateVersion = "23.11";
          }
          (import ./profiles/wsl.nix {
            inherit inputs nixosModules name;
            system = "x86_64-linux";
            userName = "jo";
          })
        ];
      })
    // {
      jonuc = withSystem "x86_64-linux" ({
        pkgs,
        system,
        ...
      }: let
        hostName = "jonuc";
        defaultUserName = "jo";
      in
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {inherit hostName defaultUserName;};
          modules = [
            ../machines/nuc
            (import ./profiles/nixos.nix {
              inherit inputs nixosModules pkgs hostName defaultUserName;
            })
          ];
        });
    };
}
