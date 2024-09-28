let
  identities = import ../../../identities.nix;
in {
  "credentials.age".publicKeys = with identities; [work home];
}
