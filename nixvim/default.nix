# 1. https://nix-community.github.io/nixvim/search/
# 2. https://nix-community.github.io/nixvim/user-guide/config-examples.html
# 3. https://grep.app/
{
  colorscheme = "catppuccin";
  colorschemes.catppuccin.enable = true;

  globalOpts = {
    number = true;
    relativenumber = true;
    ruler = true;

    # reserve some space on the left for some icons (breakpoints, warning, etc)
    signcolumn = "yes";

    cursorline = true;
  };

  plugins = {
    neo-tree = {
      enable = true;
      filesystem = {
        filteredItems = {
          hideDotfiles = false;
          hideGitignored = false;
        };
      };
    };
    bufferline.enable = true;
    lualine.enable = true;
    lsp-format = {
      enable = true;
    };
    lsp = {
      enable = true;
      servers = {
        nil-ls.enable = true;
        nil-ls.settings.formatting.command = ["alejandra"];
        nixd.enable = true;
      };
      keymaps = {
        silent = true;
        lspBuf = {
          gd = {
            action = "definition";
            desc = "Goto Definition";
          };
          gr = {
            action = "references";
            desc = "Goto References";
          };
          gD = {
            action = "declaration";
            desc = "Goto Declaration";
          };
          gI = {
            action = "implementation";
            desc = "Goto Implementation";
          };
          gT = {
            action = "type_definition";
            desc = "Type Definition";
          };
          K = {
            action = "hover";
            desc = "Hover";
          };
          "<leader>cw" = {
            action = "workspace_symbol";
            desc = "Workspace Symbol";
          };
          "<leader>cr" = {
            action = "rename";
            desc = "Rename";
          };
        };
        diagnostic = {
          "<leader>cd" = {
            action = "open_float";
            desc = "Line Diagnostics";
          };
          "[d" = {
            action = "goto_next";
            desc = "Next Diagnostic";
          };
          "]d" = {
            action = "goto_prev";
            desc = "Previous Diagnostic";
          };
        };
      };
    };
  };
}
