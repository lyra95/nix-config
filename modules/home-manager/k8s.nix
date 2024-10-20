{
  pkgs,
  lib,
  config,
  ...
}: {
  options.k8s.enable = lib.mkEnableOption "k8s cli tools";
  config = lib.mkIf config.k8s.enable {
    home.packages = with pkgs; [
      kubernetes-helm
      kubectl
      kustomize
    ];

    programs.bash = {
      initExtra = ''
        eval "$(kubectl completion bash)"
        eval "$(helm completion bash)"
        eval "$(kustomize completion bash)"
      '';
    };
  };
}
