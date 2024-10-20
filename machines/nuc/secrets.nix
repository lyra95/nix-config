let
  identities = import ../../identities.nix;
in {
  "smb-secrets.age".publicKeys = with identities; [nas-root];
  "tailscale_authkey.age".publicKeys = with identities; [nas-root];
}
