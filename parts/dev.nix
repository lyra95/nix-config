{inputs, ...}: {
  imports = [
    inputs.devshell.flakeModule
    inputs.pre-commit.flakeModule
  ];

  perSystem = {
    config,
    pkgs,
    ...
  }: {
    formatter = pkgs.alejandra;

    checks.devshell = config.devShells.default;

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
