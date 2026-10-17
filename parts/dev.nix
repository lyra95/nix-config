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

    devshells.default = {
      env = [
        {
          name = "FLAKE_ROOT";
          eval = "$PWD";
        }
      ];

      devshell.startup.pre-commit.text = config.pre-commit.shellHook;
      packages =
        [pkgs.alejandra config.packages.nvim]
        ++ config.pre-commit.settings.enabledPackages;

      commands = [
        {
          help = "run formatter";
          name = "fmt";
          command = ''
            alejandra "$FLAKE_ROOT"
          '';
        }
        {
          help = "debug nix expression";
          name = "debug";
          command = ''
            nix repl --extra-experimental-features 'flakes repl-flake' "$FLAKE_ROOT"
          '';
        }
        {
          help = "home-manager switch";
          name = "hs";
          command = "home-manager switch --flake .#$(hostname)";
          category = "home-manager";
        }
        {
          help = "nixos-rebuild switch";
          name = "ns";
          command = "sudo nixos-rebuild switch --flake .#$(hostname)";
          category = "nixos";
        }
        {
          help = "nixos-rebuild boot";
          name = "nb";
          command = "sudo nixos-rebuild boot --flake .#$(hostname)";
          category = "nixos";
        }
      ];
    };
  };
}
