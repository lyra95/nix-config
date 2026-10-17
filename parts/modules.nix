{config, ...}: {
  flake = {
    nixosModules = {
      tailscale = ../modules/nixos/tailscale;
      xrdp = ../modules/nixos/xrdp;
      cifs = ../modules/nixos/cifs;
      k3s = ../modules/nixos/k3s;
      bug-fix = ../modules/nixos/bug-fix;
      vscode = ../modules/wsl/vscode.nix;
      podman = ../modules/wsl/podman.nix;

      default = {
        imports = with config.flake.nixosModules; [bug-fix cifs k3s tailscale xrdp];
      };
      wsl = {
        imports = with config.flake.nixosModules; [podman vscode];
      };
    };

    homeModules = {
      aws = ../modules/home-manager/aws;
      git = ../modules/home-manager/git;
      gitui = ../modules/home-manager/gitui;
      starship = ../modules/home-manager/starship;
      k8s = ../modules/home-manager/k8s.nix;
      nvim = ../modules/home-manager/nvim.nix;
      rclone = ../modules/home-manager/rclone;
      kind = ../modules/home-manager/kind.nix;

      default = {
        imports = with config.flake.homeModules; [aws git gitui k8s kind nvim rclone starship];
      };
    };

    # Preserve the existing public output alongside Home Manager's homeModules.
    homeManagerModules = config.flake.homeModules;
  };
}
