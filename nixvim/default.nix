# 1. https://nix-community.github.io/nixvim/search/
# 2. https://nix-community.github.io/nixvim/user-guide/config-examples.html
# 3. https://grep.app/
{
  imports = [
    ./modules/bufferline.nix
    ./modules/lsp.nix
  ];

  colorscheme = "catppuccin";
  colorschemes.catppuccin.enable = true;

  globalOpts = {
    number = true;
    relativenumber = true;

    # reserve some space on the left for some icons (breakpoints, warning, etc)
    signcolumn = "yes";

    cursorline = true;
  };

  plugins = {
    nvim-autopairs.enable = true;
    lualine.enable = true;
    comment.enable = true;
  };
}
