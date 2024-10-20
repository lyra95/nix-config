{
  wslBuilder = import ./wsl.nix;
  homeBuilder = import ./home.nix;
  nixosBuilder = import ./nixos.nix;
}
