{
  pkgs,
  lib,
  config,
  ...
}: {
  options.kind.enable = lib.mkEnableOption "kind";

  config = lib.mkIf config.kind.enable {
    home.packages = [pkgs.kind];

    programs.bash = {
      shellAliases = {
        ek = "enter-kind";
      };

      initExtra = ''
        function enter-kind() {
          ORIGINAL_IN_NIX_SHELL=$IN_NIX_SHELL
          ORIGINAL_KUBECONFIG=$KUBECONFIG

          IN_NIX_SHELL=impure \
            name=kind \
            KUBECONFIG="~/.kube/kind-config" \
            bash -c 'eval "$(kind completion bash)"; exec bash'

          IN_NIX_SHELL=$ORIGINAL_IN_NIX_SHELL
          KUBECONFIG=$ORIGINAL_KUBECONFIG
          unset ORIGINAL_IN_NIX_SHELL ORIGINAL_KUBECONFIG
        }
      '';
    };
  };
}
