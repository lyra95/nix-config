{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    aws.enable = lib.mkEnableOption "enable aws";
  };
  config =
    lib.mkIf config.aws.enable
    {
      programs.awscli = {
        enable = true;
        settings = {
          "default" = {
            region = "ap-northeast-2";
          };
        };
      };

      programs.k9s.enable = true;
    };
}
