{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.agenix.homeManagerModules.default
    ./homeManagerModules/git
  ];

  git.enable = true;

  home.packages = with pkgs; [
    jq
  ];

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  # Don't know well but sometimes user level services are not started/restarted
  # Looklike home-manager do not reload services when its parent services?
  # https://github.com/nix-community/home-manager/issues/355
  systemd.user.startServices = "sd-switch";
}
