# https://mipmip.github.io/home-manager-option-search/ 에서 검색 가능
{ username, homeDirectory }: { pkgs, ... }: {
  home.username = username;
  home.homeDirectory = homeDirectory;

  home.stateVersion = "23.05";
  home.packages = with pkgs;
    let
      essentials =
        [
          curl
          gnumake
        ];
      tool = [
        jq
        yq-go
        most
        fd # find 대체제
        ripgrep # grep 대체제
      ];
      cloud = [
        kubectl # https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html eks kubeconfig 파일 생성 필요
        kubernetes-helm
        kustomize
        awscli2
        pulumi-bin # infra as a code with TypeScript
        docker-client # engine은 도커 데스크탑을 쓰므로 client만
      ];
      langs = [
        nodejs
        dotnet-sdk_7
        python311Full
        rustup
      ];
      editor = # neovim with AstroNvim dependencies
        [
          neovim
          unzip
          gcc
          lazygit # gui git
          bottom # cpu, mem usage gui
          gdu # disk usage
        ];
    in
    essentials ++ tool ++ cloud ++ langs ++ editor;

  home.file.awsconfig.source = ./.aws/config;
  home.file.awsconfig.target = ".aws/config";
  # .aws/credentials 파일은 aws configure로 알아서 생성해야됨
  # 아니면 개인용 vault라도 셋업해야되나

  home.sessionVariables = {
    #  PAGER = "less";
    #  CLICLOLOR = 1;
    EDITOR = "nvim";
  };

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

  home.file.astronvim = {
    source = pkgs.fetchFromGitHub {
      owner = "AstroNvim";
      repo = "AstroNvim";
      rev = "master";
      sha256 = "0fd0s38i153rmidzmi98qgljr919y8i6dz0k1a3g4bmsywgpkkgf";
    };
    target = ".config/nvim";
  };

  programs.fish.enable = true;
  programs.fish.functions =
    let
      commonFunc = {
        man = {
          body = "command man $argv | most";
          description = "Display colored man pages";
        };
        k = {
          body = "kubectl $argv";
        };
        km = {
          body = "kustomize $argv";
        };
        ll = {
          body = "exa -al $argv";
        };
        remove-cr = {
          body = ''
            set file $argv
            set tempf $(mktemp)
            cat "$file" > "$tempf"
            tr -d '\r' < "$tempf" > "$file";
          '';
        };
      };
      wslFunc = {
        open = {
          body = "explorer.exe $argv";
          description = "Open in a File Explorer, like a MacOS";
        };
        wit = {
          body = "git.exe $argv";
          description = "windows git";
        };
        wode = {
          body = "powershell.exe code $argv";
          description = "windows vscode";
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
