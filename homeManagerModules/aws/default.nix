{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    aws.enable = lib.mkEnableOption "enable aws";
  };
  config = lib.mkIf config.aws.enable {
    assertions = [
      {
        assertion = config.age != null;
        message = "age must be configured";
      }
    ];

    age.secrets.awscli-credentials = {
      file = ./credentials.age;
      path = "${config.home.homeDirectory}/.aws/credentials";
    };

    programs.awscli = {
      enable = true;
      settings = {
        "default" = {
          region = "ap-northeast-2";
        };
      };
    };
  };
}
