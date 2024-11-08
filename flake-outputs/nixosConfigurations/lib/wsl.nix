{
  self,
  nixpkgs,
  nixos-wsl,
  ...
}: {
  name,
  system,
  userName,
  modules,
}: let
  commonModules = {
    nix = {pkgs, ...}: {
      nixpkgs.hostPlatform = system;
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      environment.systemPackages = with pkgs; [git vim file];
      environment.variables.EDITOR = "vim";
    };

    wsl = {
      imports = [
        nixos-wsl.nixosModules.wsl
        self.nixosModules.wsl
      ];
      wsl.enable = true;
      wsl.defaultUser = userName;
      wsl.wslConf.network.hostname = name;

      vscode-remote-workaround.enable = true;

      programs.bash.interactiveShellInit = ''
        wsl_to_windows_path() {
                local wsl_path
                wsl_path=$(readlink -f "$1")

                local win_path

                if [[ "$wsl_path" =~ ^/mnt/([a-z])(|/.*) ]]; then
                        # Convert /mnt/c/... to C:\...
                        local drive="''${BASH_REMATCH[1]}"
                        local path="''${BASH_REMATCH[2]}"
                        path="''${path//\//\\}"
                        win_path="''${drive^^}:''${path:-\\}"
                else
                        # Convert /home/user/... to \\wsl$\distro_name\...
                        local distro_name=NixOS
                        win_path="\\\\wsl.localhost\\''${distro_name}\\''${wsl_path//\//\\}"
                fi

                echo "$win_path"
        }

        function open {
                local path
                path=$(wsl_to_windows_path "$1")
                explorer.exe /root="$path"
        }
      '';
    };
  };
in
  nixpkgs.lib.nixosSystem {
    specialArgs = {};
    modules =
      modules
      ++ (builtins.attrValues commonModules);
  }
