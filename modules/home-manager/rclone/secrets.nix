let
  identities = import ../../../identities.nix;
in {
  "rclone.conf.age".publicKeys = with identities; [home work dell];
}
