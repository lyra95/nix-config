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

      nixpkgs.config.allowUnfree = true;

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
      wsl.wslConf.boot.initTimeout = 60000;

      # WSL2 runs every distro in one shared cgroup v2 hierarchy, so the
      # `user.slice/user-$UID.slice/user@$UID.service` cgroup is contested
      # between distros. podman-machine-default's default user is uid 1000 with
      # linger enabled, so whenever it boots first it turns that cgroup into a
      # populated parent and our systemd can no longer attach to it:
      #
      #   user@1000.service: Failed to spawn executor: Device or resource busy
      #
      # which takes down every `systemd --user` unit (agenix, home-manager).
      # Moving off uid 1000 gives us an uncontested cgroup path.
      # Fixed upstream in WSL 2.9.8 by https://github.com/microsoft/WSL/pull/40519.
      #
      # NOTE: this is declarative only for a *fresh* install. NixOS refuses to
      # apply a uid change to an already-existing user (update-users-groups.pl
      # only warns "not applying UID change"), so an existing machine needs a
      # one-time `usermod -u 1001 jo` plus a chown of jo-owned paths outside
      # /home/jo before this value takes effect.
      users.users.${userName}.uid = 1001;
      # Must track the uid above, otherwise the Windows drives stay owned by the
      # now-nonexistent uid 1000 (NixOS-WSL defaults to "metadata,uid=1000,gid=100").
      wsl.wslConf.automount.options = "metadata,uid=1001,gid=100";

      vscode-remote-workaround.enable = true;

      programs.bash.interactiveShellInit = ''
        function open {
          explorer.exe `wslpath -w "$1"`
        }
      '';
    };

    container = {
      podman = {
        enable = true;
        user = userName;
      };
    };
  };
in
  nixpkgs.lib.nixosSystem {
    specialArgs = {};
    modules =
      modules
      ++ (builtins.attrValues commonModules);
  }
