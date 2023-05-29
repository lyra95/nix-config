# 설정가능한 옵션은 https://daiderd.com/nix-darwin/manual/index.html#sec-options 에서 참고
# https://github.com/zmre/mac-nix-simple-example/blob/master/modules/darwin/default.nix 참고함
{ username, homeDirectory }: { pkgs, ... }: {
  programs.fish.enable = true;
  environment = {
    shells = with pkgs; [ bash zsh fish ];
    loginShell = pkgs.fish;
    systemPackages = [ pkgs.coreutils pkgs.git ];
    systemPath = [ "/opt/homebrew/bin" ];
    pathsToLink = [ "/Applications" ];
  };
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  fonts.fontDir.enable = true;
  fonts.fonts = [ (pkgs.nerdfonts.override { fonts = [ "Meslo" ]; }) ];
  services.nix-daemon.enable = true;
  system.defaults = {
    finder.AppleShowAllExtensions = true;
    finder._FXShowPosixPathInTitle = true;
    dock.autohide = true;
    NSGlobalDomain.AppleShowAllExtensions = true;
    NSGlobalDomain.InitialKeyRepeat = 14;
    NSGlobalDomain.KeyRepeat = 1;
  };

  users.users.jo = {
    name = username;
    home = homeDirectory;
  };
}
