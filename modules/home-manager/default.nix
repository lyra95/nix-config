# https://mipmip.github.io/home-manager-option-search/ 에서 검색 가능
{ username, homeDirectory, astroNvim }: { pkgs, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin;
  inherit (pkgs) lib;
in
{
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
        just # make 대체제
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
      others = [ zola git-commands ];
    in
    essentials ++ tool ++ cloud ++ langs ++ editor ++ others;

  home.file.nixconf = {
    text = "experimental-features = nix-command flakes";
    target = ".config/nix/nix.conf";
    enable = !isDarwin;
  };

  home.file.awsconfig = {
    source = ./.aws/config;
    target = ".aws/config";
    # .aws/credentials 파일은 aws configure로 알아서 생성해야됨
    # 아니면 개인용 vault라도 셋업해야되나
  };

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
    aliases = {
      oops = "commit --amend -a --no-edit";
      gc-all = "gc -q --prune --aggressive --keep-largest-pack --force";
    };
    delta.enable = true;
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  home.file.astronvim = {
    source = astroNvim;
    target = ".config/nvim";
  };

  programs.fish =
    {
      enable = true;
    } //
    {
      shellAbbrs = {
        k = "kubectl";
        km = "kustomize";
        ls = "exa";
        ll = "exa -al";
        tree = "exa --tree";
      };

      functions =
        let
          commonFunc = {
            man = {
              body = "command man $argv | most";
              description = "Display colored man pages";
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
        if isDarwin then
          commonFunc
        else
          commonFunc // wslFunc;
    } //
    (
      let
        # WSL2 Ubuntu에서 이게 먼저 로드가 안되니까 nix 커맨드를 못 찾음
        nix-init =
          ''
            source $HOME/.nix-profile/etc/profile.d/nix.fish
            source $HOME/.nix-profile/etc/profile.d/nix-daemon.fish
          '';
        fishCompPath = "~/.config/fish/completions";
        justfile =
          "just --completions fish > ${fishCompPath}/just.fish";
        kubectl =
          "kubectl completion fish > ${fishCompPath}/kubectl.fish";
        helm =
          "helm completion fish > ${fishCompPath}/helm.fish";
        kustomize =
          "kustomize completion fish > ${fishCompPath}/kustomize.fish";
        common = [ justfile kubectl helm kustomize ];
      in
      {
        shellInit =
          if
            isDarwin then lib.concatLines common
          else lib.concatLines ([ nix-init ] ++ common);
      }
    );
}
