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
        nix_shell = {
          heuristic = true;
        };

        custom.kubecontext = lib.mkIf config.starship.enableBashIntegration {
          command = "kubectl config current-context | awk -F'/' '{print $NF}'";
          when = "kubectl config current-context &> /dev/null";
          shell = "bash";
          style = "bold blue";
          format = "[⎈ $output ]($style)";
        };
      };
    };
  };
}
