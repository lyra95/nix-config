{
  config,
  inputs,
  ...
}: let
  flake = config.flake;
in {
  imports = [
    inputs.devshell.flakeModule
    inputs.pre-commit.flakeModule
  ];

  perSystem = {
    config,
    lib,
    system,
    pkgs,
    ...
  }: {
    formatter = pkgs.alejandra;

    checks =
      {
        devshell = config.devShells.default;
        enter-kind = pkgs.callPackage ../tests/enter-kind.nix {};
      }
      // lib.optionalAttrs (system == "x86_64-linux") {
        modules = pkgs.callPackage ../tests/modules.nix {inherit flake inputs;};
      };

    pre-commit.settings.hooks.alejandra = {
      enable = true;
      package = pkgs.alejandra;
    };

    devshells.default = import ../modules/devshell {
      shellHook = config.pre-commit.shellHook;
      enabledPackages = config.pre-commit.settings.enabledPackages;
    };
  };
}
