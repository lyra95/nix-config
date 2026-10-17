{
  config,
  lib,
  ...
}: {
  options = {
    folding.enable = lib.mkEnableOption "use folding";
  };

  # https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#folding
  config = lib.mkIf config.folding.enable {
    # zo: open fold
    # zc: close fold
    # zO: open all folds
    # zC: close all folds
    # za: toggle fold (cursor doesn't need to be at fold)
    # zj, zk: move to next/previous fold
    keymaps = [
      {
        mode = "n";
        key = "<CR>";
        action = "zo";
        options = {
          desc = "unfold";
        };
      }
      {
        mode = "n";
        key = "<S-CR>";
        options = {
          desc = "fold";
        };
        action = "zc";
      }
      {
        mode = "n";
        key = "zz";
        action.__raw = ''
          function(fallback)
            if vim.wo.foldlevel == 99 then
              vim.wo.foldlevel = vim.o.foldlevelstart
            else
              vim.wo.foldlevel = 99
            end
          end
        '';
        options.desc = "fold/unfold all";
      }
    ];

    opts = {
      foldlevelstart = 2;
      foldlevel = 99;
      foldminlines = 9;
    };

    extraConfigVim = "
      autocmd BufWinLeave * if &buftype != 'nofile' && expand('%') != '' | mkview | endif
      autocmd BufWinEnter * if &buftype != 'nofile' && expand('%') != '' | silent! loadview | endif
    ";

    plugins.treesitter.enable = true;
    plugins.treesitter.folding = true;
  };
}
