{
  config,
  lib,
  pkgs,
  ...
}: let
  ageEnabled = config.age != null;
in {
  options = {
    git.enable = lib.mkEnableOption "enable git";
  };

  config = lib.mkIf config.git.enable {
    programs.git = {
      enable = true;
      userName = "jo";
      userEmail = "95hyouka@gmail.com";
    };

    age.secrets.github_ed25519 = lib.mkIf ageEnabled {
      file = ./github_ed25519.age;
    };

    programs.ssh = lib.mkIf ageEnabled {
      enable = true;
      extraConfig = ''
        Host github.com
                User jo
                HostName github.com
                PreferredAuthentications publickey
                IdentityFile ${config.age.secrets.github_ed25519.path}
      '';
    };
  };
}
