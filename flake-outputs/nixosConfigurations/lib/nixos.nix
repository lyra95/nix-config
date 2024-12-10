{
  self,
  nixpkgs,
  agenix,
  ...
}: {
  hostName,
  system,
  defaultUserName,
  modules,
  pkgs,
}: let
  coreModules = {
    age = agenix.nixosModules.age;

    i18n = {
      # Select internationalisation properties.
      i18n.defaultLocale = "en_US.UTF-8";

      i18n.extraLocaleSettings = {
        LC_ADDRESS = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "en_US.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
        LC_TIME = "en_US.UTF-8";
      };
    };

    system = {
      networking.hostName = hostName;
      networking.networkmanager.enable = true;
      time.timeZone = "Asia/Seoul";
      # Allow unfree packages
      #   nixpkgs.config.allowUnfree = true;

      nix.settings.experimental-features = ["nix-command" "flakes"];

      # List packages installed in system profile. To search, run:
      # $ nix search wget
      environment.systemPackages = with pkgs; [git vim];

      environment.variables.EDITOR = "vim";
      bug-fix.fix-logind-race-condition = true;
    };

    superUser = {
      users.users.${defaultUserName} = {
        isNormalUser = true;
        description = "default user";
        extraGroups = ["networkmanager" "wheel"];
        packages = with pkgs; [kate];
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
    };

    importAll = {
      imports = [
        self.nixosModules.default
      ];
    };
  };
in
  nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit hostName defaultUserName;
    };
    inherit system;
    modules =
      modules
      ++ (builtins.attrValues coreModules);
  }
