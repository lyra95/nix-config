{
  inputs,
  name,
  system,
  userName,
  userUid ? 1001,
}: {pkgs, ...}: {
  imports = [
    ../nixos/base.nix
    ./default.nix
    (import ./user-session.nix {uid = userUid;})
    inputs.nixos-wsl.nixosModules.wsl
  ];

  nixpkgs.hostPlatform = system;
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = [pkgs.file];

  wsl = {
    enable = true;
    defaultUser = userName;
    docker-desktop.enable = false;
    wslConf.network.hostname = name;
    wslConf.boot.initTimeout = 60000;
  };
  system.stateVersion = "23.11";

  vscode-remote-workaround.enable = true;
  podman = {
    enable = true;
    user = userName;
  };

  programs.bash.interactiveShellInit = ''
    function open {
      explorer.exe "$(wslpath -w "$1")"
    }
  '';
}
