# 1. https://nix-community.github.io/nixvim/search/
# 2. https://nix-community.github.io/nixvim/user-guide/config-examples.html
# 3. https://grep.app/
{
  folding.enable = true;
  completion.enable = true;
  telescope.enable = true;
  neo-tree.enable = true;
  neo-tree.enableBufferlineIntegration = true;
  bufferline.enable = true;
  copilot.enable = true;

  lsp = {
    enable = true;
    k8s.enable = true;
    bash.enable = true;
    nix.enable = true;
    markdown.enable = true;
  };

  plugins.lazygit.enable = true;
}
