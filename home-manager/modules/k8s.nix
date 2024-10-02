{pkgs, ...}: {
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
}
