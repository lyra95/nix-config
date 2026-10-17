{inputs, ...}: {
  imports = [
    inputs.devshell.flakeModule
    inputs.pre-commit.flakeModule
  ];

  perSystem = {
    config,
    lib,
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

      commands =
        [
          {
            help = "update flake inputs";
            name = "update";
            command = "nix flake update --commit-lock-file";
          }
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
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
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
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
          {
            help = "darwin-rebuild switch";
            name = "ds";
            command = "sudo darwin-rebuild switch --flake .#$(hostname)";
            category = "darwin";
          }
        ];
    };
  };
}
