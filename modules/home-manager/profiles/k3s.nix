{pkgs, ...}: {
  aws.enable = false;
  git.enable = true;
  home.packages = [pkgs.k9s];
  programs.bash = {
    shellAliases.k = "kubectl";
    sessionVariables.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
  };
}
