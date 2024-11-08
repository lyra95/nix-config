inputs: {
  wslBuilder = import ./wsl.nix inputs;
  nixosBuilder = import ./nixos.nix inputs;
}
