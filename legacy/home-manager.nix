# 기록 보관용
# 예전에 쓰던 home-manager 설정
{ config, pkgs, ... }:

let
  python = pkgs.python39;
  nodejs = pkgs.nodejs-16_x;
in
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "jo";
  home.homeDirectory = "/Users/jo";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  home.packages = [ python nodejs ];

  # nodejs 18 is unable to be installed
  nixpkgs.overlays = [ (self: super: { nodejs = nodejs; }) ];

  # begin fish
  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      switch = "home-manager switch";
      build = "home-manager build";
      home-edit = "nvim ~/.config/nixpkgs/home.nix";
    };
    initExtra = ''
      PATH=$PATH:~/flutter/bin:/Users/jo/Library/Android/sdk/tools/bin
      PATH=$PATH:/usr/local/bin:~/.local/share/bin
      source <(kubectl completion zsh)
    '';
    zplug = {
      enable = true;
      plugins = [
        { name = "plugins/git"; tags = [ from:oh-my-zsh ]; }
        { name = "junegunn/fzf"; tags = [ from:gh-r as:command use:'*darwin*arm64*' ]; }
        { name = "themes/robbyrussell"; tags = [ from:oh-my-zsh ]; }
        { name = "greymd/docker-zsh-completion"; }
      ];
    };
  };
  # end fish
  programs.git = {
    enable = true;
    userName = "Jo";
    userEmail = "95hyouka@gmail.com";
    aliases = {
      # Prettier `git log`
      lg = "log --color --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      # Fetch a branch from a remote and rebase it on the current branch
      frb = "!git fetch $1 && git rebase $1/$2 && :";

      new = "checkout -b";
      rb = "rebase --interactive";
      last = "show HEAD";
      cim = "commit --amend";
      oops = "!f(){ \
      git add -A; \
      if [ \"$1\" == '' ]; then \
        git commit --amend --no-edit; \
      else \
        git commit --amend \"$@\"; \
      fi;\
      }; f";
      cimn = "commit -a --amend --no-edit";
      st = "status";
      br = "branch";
      ci = "commit";
      df = "diff";
      ps = "push";
      fp = "push --force";
      ig = "!nvim \"$(git rev-parse --show-toplevel)/.gitignore\"";
    };
  };
  programs.fzf.enable = true;
  programs.tmux.enable = true;
  programs.gpg.enable = true;
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = false;
    plugins = with pkgs.vimPlugins; [
      vim-airline
      tokyonight-nvim
      nerdtree
    ];
    coc = {
      enable = true;
    };
    extraConfig = ''
      set number
      set relativenumber
      set autoindent
      set mouse=a
      set encoding=UTF-8
      set autoindent
      set smartindent
      set shiftwidth=4
      set softtabstop=4
      set expandtab
      syntax enable
      colorscheme tokyonight
      filetype plugin indent on
      autocmd FileType nix setlocal shiftwidth=2 softtabstop=2 expandtab
      nnoremap <leader>n :NERDTreeFocus<CR>
      nnoremap <C-n> :NERDTree<CR>
      nnoremap <C-t> :NERDTreeToggle<CR>
      nnoremap <C-f> :NERDTreeFind<CR>
    '';
  };
}
