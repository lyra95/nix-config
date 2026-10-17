{
  lib,
  pkgs,
  ...
}: {
  imports = [./bug-fix];

  documentation.nixos.enable = false;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  environment.systemPackages = with pkgs; [git vim];
  environment.variables.EDITOR = "vim";

  # Keep the boot-order workaround until fast console login is verified on hosts.
  bug-fix.fix-logind-race-condition = lib.mkDefault true;
}
