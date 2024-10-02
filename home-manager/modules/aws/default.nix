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

      programs.k9s.enable = true;

      home.sessionVariables = {
        KUBECONFIG = "${config.home.homeDirectory}/.eks.kubeconfig";
      };

      systemd.user.services."gen-eks-conf" = {
        Unit = {
          scription = "generate eks kubeconfig file";
          Documentation = "man:gen-eks-conf";
          Requires = ["agenix"];
        };

        Install = {
          WantedBy = ["default.target"];
        };

        Service = let
          app = pkgs.writeShellApplication {
            name = "gen-eks-conf";
            runtimeInputs = [pkgs.coreutils config.programs.awscli.package];
            runtimeEnv.CONF_PATH = "${config.home.homeDirectory}/.eks.kubeconfig";
            text = ''
              #!/usr/bin/env bash

              if [ -e "$CONF_PATH" ]; then
                exit 0;
              fi

              aws eks update-kubeconfig --region ap-northeast-2 --name eks-dev --kubeconfig "$CONF_PATH";
            '';
          };
        in {
          Type = "oneshot";
          ExecStart = lib.getExe app;
        };
      };
    };
}
