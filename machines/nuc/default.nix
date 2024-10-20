{
  config,
  hostName,
  ...
}: {
  imports = [
    ./generated/configuration.nix
  ];

  age.secrets.smb-secrets.file = ./smb-secrets.age;
  cifs = {
    mount = "/mnt/nuc_backup";
    remote = "//jo-home/nuc_backup";
    secret = config.age.secrets.smb-secrets.path;
  };

  k3s = {
    enable = true;
  };

  age.secrets.tailscale-authkey.file = ./tailscale_authkey.age;
  tailscale = {
    enable = true;
    inherit hostName;
    authKeyFile = config.age.secrets.tailscale-authkey.path;
  };

  xrdp.enable = true;

  programs.firefox.enable = true;
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };
}
