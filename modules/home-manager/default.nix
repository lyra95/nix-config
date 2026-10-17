{agenix}: {
  imports = [
    (import ./agenix.nix {inherit agenix;})
    ./aws
    ./git
    ./gitui
    ./k8s.nix
    ./kind.nix
    ./nvim.nix
    ./rclone
    ./starship
  ];
}
