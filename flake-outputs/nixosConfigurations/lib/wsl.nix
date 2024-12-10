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

      bug-fix.fix-logind-race-condition = true;

      environment.systemPackages = with pkgs; [git vim file];
      environment.variables.EDITOR = "vim";
    };

    wsl = {
      imports = [
        nixos-wsl.nixosModules.wsl
        self.nixosModules.wsl
        self.nixosModules.bug-fix
      ];
      wsl.enable = true;
      wsl.defaultUser = userName;
      wsl.wslConf.network.hostname = name;

      vscode-remote-workaround.enable = true;

      programs.bash.interactiveShellInit = ''
        function open {
          explorer.exe `wslpath -w "$1"`
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
