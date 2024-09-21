let
  nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAsTK5qze+z5HT/RGoYKanltHGUm+ed8RrZSUeD8XIU3 nixos@nixos";
in {
  "credentials.age".publicKeys = [nixos];
}
