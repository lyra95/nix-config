let
  identities = import ../../../identities.nix;
in {
  "github_ed25519.age".publicKeys = with identities; [home work dell nas];
}
