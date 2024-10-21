{
  config,
  lib,
  pkgs,
  ...
}: let
  ageEnabled = config.age != null;
in {
  options = {
    git.enable = lib.mkEnableOption "enable git";
    git.wsl = lib.mkEnableOption "use git.exe instead of git in symlinked repo";
  };

  config = lib.mkIf config.git.enable {
    # todo: add gpg signing
    programs.git = {
      enable = true;
      userName = "jo";
      userEmail = "95hyouka@gmail.com";

      aliases = {
        # Prettier `git log`
        lg = "log --color --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        rb = "rebase --interactive";
        last = "show HEAD";
        oops = "commit -a --amend --no-edit";
        fp = "push --force";
        ig = "!vim \"$(git rev-parse --show-toplevel)/.gitignore\"";
        gc-all = "gc -q --prune --aggressive --keep-largest-pack --force";
      };

      delta = {
        enable = true;
        options = {
          navigate = true;
          line-numbers = true;
          hyperlinks = true;
          side-by-side = true;
          colorMoved = "default";
        };
      };

      extraConfig = {
        init.defaultBranch = "main";
        merge.conflictstyle = "diff3";
      };
    };

    programs.git.package = lib.mkIf config.git.wsl (pkgs.writeShellApplication {
      name = "git";
      runtimeInputs = [pkgs.git pkgs.coreutils];
      text = ''
        is_windows_symlinked_repo() {
        	[[ "$(readlink -f .)" =~ "/mnt/c/" ]]
        }

        if is_windows_symlinked_repo; then
        	git.exe "$@"
        else
        	git "$@"
        fi
      '';
    });

    age.secrets.github_ed25519 = lib.mkIf ageEnabled {
      file = ./github_ed25519.age;
    };

    programs.ssh = lib.mkIf ageEnabled {
      enable = true;
      extraConfig = ''
        Host github.com
                User jo
                HostName github.com
                PreferredAuthentications publickey
                IdentityFile ${config.age.secrets.github_ed25519.path}
      '';
    };
  };
}
