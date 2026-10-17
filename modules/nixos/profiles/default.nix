{
  inputs,
  hostName,
  defaultUserName,
}: {pkgs, ...}: {
  imports = [
    ../default.nix
    ../base.nix
    inputs.agenix.nixosModules.age
    inputs.vscode-server.nixosModules.default
  ];

  services.vscode-server.enable = true;
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = builtins.listToAttrs (map (name: {
    inherit name;
    value = "en_US.UTF-8";
  }) ["LC_ADDRESS" "LC_IDENTIFICATION" "LC_MEASUREMENT" "LC_MONETARY" "LC_NAME" "LC_NUMERIC" "LC_PAPER" "LC_TELEPHONE" "LC_TIME"]);

  networking.hostName = hostName;
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Seoul";

  users.users.${defaultUserName} = {
    isNormalUser = true;
    description = "default user";
    extraGroups = ["networkmanager" "wheel"];
    packages = [pkgs.kdePackages.kate];
  };
  security.sudo.extraRules = [
    {
      users = [defaultUserName];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];
}
