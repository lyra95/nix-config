# https://mipmip.github.io/home-manager-option-search/ 에서 검색 가능
{ username, homeDirectory }: { pkgs, ... }: {
  home.username = username;
  home.homeDirectory = homeDirectory;
  
  home.stateVersion = "22.11";
  home.packages = with pkgs; [
    curl
  ];

  # home.file.".inputrc".source = ./dotfiles/inputrc;
  
  # home.sessionVariables = {
  #   PAGER = "less";
  #   CLICLOLOR = 1;
  #   EDITOR = "nvim";
  # };

  programs.bat.enable = true;
  programs.bat.config.theme = "TwoDark";
  
  programs.fzf.enable = true;
  programs.fzf.enableFishIntegration = true;
  
  programs.starship.enable = true;
  programs.starship.enableFishIntegration = true;
  
  programs.exa.enable = true;
  
  programs.git = {
    enable = true;
    userName = "jo";
    userEmail = "95hyouka@gmail.com";
  };

  programs.neovim = {
    enable = true;
    coc.enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };
  
  programs.fish.enable = true;
}
