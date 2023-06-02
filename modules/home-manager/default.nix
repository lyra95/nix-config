# https://mipmip.github.io/home-manager-option-search/ 에서 검색 가능
{ username, homeDirectory }: { pkgs, ... }: {
  home.username = username;
  home.homeDirectory = homeDirectory;

  home.stateVersion = "22.11";
  home.packages = with pkgs; [
    curl
    most
    fd # find 대체제
    ripgrep # grep 대체제
    gnumake
    jq
    yq-go
    kubectl
    kubernetes-helm
    awscli2
  ];

  home.file.awsconfig.source = ./.aws/config;
  # home.file.awsconfig.target = ".aws/config";

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

  # ls 대체제 https://the.exa.website/
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
  programs.fish.functions =
    let
      commonFunc = {
        man = {
          body = "command man $argv | most";
          description = "Display colored man pages";
        };
      };
      wslFunc = {
        open = {
          body = "explorer.exe $argv";
          description = "Open in a File Explorer, like a MacOS";
        };
        fit = {
          body = "git.exe $argv";
          description = "Faster git";
        };
      };
    in
    if pkgs.stdenv.isDarwin then
      commonFunc
    else
      commonFunc // wslFunc;
  # WSL2 Ubuntu에서 이게 먼저 로드가 안되니까 nix 커맨드를 못 찾음
  programs.fish.shellInit =
    if pkgs.stdenv.isDarwin then ""
    else "source $HOME/.nix-profile/etc/profile.d/nix.fish\nsource $HOME/.nix-profile/etc/profile.d/nix-daemon.fish";
}
