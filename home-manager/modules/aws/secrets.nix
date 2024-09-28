let
  home = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDnXUyIHoD17qpH4m8aRfCDXNqYV27sTSlttEx3/ge/M root@nixos";
  work = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAsTK5qze+z5HT/RGoYKanltHGUm+ed8RrZSUeD8XIU3 nixos@nixos";
in {
  "credentials.age".publicKeys = [work home];
}
