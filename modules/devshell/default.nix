{
  shellHook,
  enabledPackages,
}: {
  lib,
  pkgs,
  ...
}: {
  env = [
    {
      name = "FLAKE_ROOT";
      eval = "$(${pkgs.git}/bin/git rev-parse --show-toplevel)";
    }
  ];

  devshell.startup.pre-commit.text = shellHook;
  packages =
    [pkgs.alejandra]
    ++ enabledPackages;

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
      {
        help = "evaluate checks for all systems";
        name = "ch";
        command = "nix flake check --no-build --all-systems";
      }
      {
        help = "build checks for the current system";
        name = "chb";
        command = "nix flake check";
      }
      {
        help = "profile flake evaluation and generate a flame graph";
        name = "profile";
        command = ''
          nix flake check --no-build --all-systems \
            --option eval-cache false \
            --eval-profiler flamegraph \
            --eval-profile-file nix-eval.profile &&
            nix shell nixpkgs#flamegraph -c \
              flamegraph.pl nix-eval.profile > nix-eval.svg
        '';
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
}
