{
  imports = [
    ./themes.nix
    ./globalOpts.nix
  ];

  plugins = {
    nvim-autopairs = {
      enable = true;
      settings.check_ts = true;
    };
    lualine.enable = true;

    # # Linewise
    #
    # `gcw` - Toggle from the current cursor position to the next word
    # `gc$` - Toggle from the current cursor position to the end of line
    # `gc}` - Toggle until the next blank line
    # `gc5j` - Toggle 5 lines after the current cursor position
    # `gc8k` - Toggle 8 lines before the current cursor position
    # `gcip` - Toggle inside of paragraph
    # `gca}` - Toggle around curly brackets
    #
    # # Blockwise
    #
    # `gb2}` - Toggle until the 2 next blank line
    # `gbaf` - Toggle comment around a function (w/ LSP/treesitter support)
    # `gbac` - Toggle comment around a class (w/ LSP/treesitter support)
    comment.enable = true;
  };
}
