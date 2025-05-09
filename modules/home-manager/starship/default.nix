{
  config,
  lib,
  ...
}: {
  options.starship = {
    enable = lib.mkEnableOption "enable starship";
    enableBashIntegration = lib.mkEnableOption "enable bash integration";
  };

  config = {
    # shell status bar
    programs.starship = {
      enable = config.starship.enable;
      enableBashIntegration = config.starship.enableBashIntegration;

      # https://starship.rs/config/
      settings = {
        command_timeout = 1000;

        nix_shell = {
          heuristic = true;
        };

        custom.kubecontext = lib.mkIf config.starship.enableBashIntegration {
          command = "yq '.current-context' $KUBECONFIG | awk -F'/' '{print $NF}'";
          when = "yq '.current-context' $KUBECONFIG | grep -qP '\\S'";
          shell = "bash";
          style = "bold blue";
          format = "[⎈ $output ]($style)";
        };
      };
    };
  };
}
