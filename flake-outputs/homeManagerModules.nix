{...}: let
  modules = {
    aws = ../modules/home-manager/aws;
    git = ../modules/home-manager/git;
    gitui = ../modules/home-manager/gitui;
    starship = ../modules/home-manager/starship;
    k8s = ../modules/home-manager/k8s.nix;
    nvim = ../modules/home-manager/nvim.nix;
    rclone = ../modules/home-manager/rclone;
  };

  all = {
    imports = builtins.attrValues modules;
  };
in
  modules // {default = all;}
