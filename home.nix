{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.agenix.homeManagerModules.default
  ];

  age.identityPaths = ["/home/nixos/.ssh/id_ed25519"];

  home.packages = with pkgs; [
    jq
  ];

  programs.git = {
    enable = true;
    userName = "95hyouka";
    userEmail = "95hyouka@gmail.com";
  };

  age.secrets.github_ed25519 = {
    file = ./secrets/.ssh/github_ed25519.age;
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host github.com
              User jo
              HostName github.com
              PreferredAuthentications publickey
              IdentityFile ${config.age.secrets.github_ed25519.path}
    '';
  };

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch";
}
