{
  flake,
  inputs,
  pkgs,
}: let
  homes = flake.homeConfigurations;
  container = homes.container.config;
  work = homes.work.config;
  wsl = flake.nixosConfigurations.work.config;
  nuc = flake.nixosConfigurations.jonuc.config;
  darwin = flake.darwinConfigurations.jo-macbook-air.config;
  standalone = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = homes.container.pkgs;
    modules = [
      flake.homeModules.default
      {
        home.username = "test";
        home.homeDirectory = "/home/test";
        home.stateVersion = "24.05";
      }
    ];
  };
  customWsl = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      (import ../modules/wsl/profile.nix {
        inherit inputs;
        name = "test";
        system = "x86_64-linux";
        userName = "test";
        userUid = 1234;
      })
    ];
  };
in
  assert container.home.homeDirectory == "/root";
  assert !container.k8s.enable && !container.gitui.enable && !container.aws.enable;
  assert container.nvim.pkg != null;
  assert work.programs.git.settings.alias.rb == "rebase --interactive";
  assert work.programs.git.settings.init.defaultBranch == "main";
  assert work.programs.git.settings.merge.conflictstyle == "diff3";
  assert !(work.programs.git.settings ? extraConfig) && !(work.programs.git.settings ? aliases);
  assert work.programs.ssh.settings."github.com".data.User == "git";
  assert standalone.config.nvim.pkg == null;
  assert !standalone.config.nvim.enableBashIntegration;
  assert !standalone.config.git.enable && !standalone.config.aws.enable;
  assert wsl.users.users.jo.uid == 1001;
  assert wsl.wsl.wslConf.automount.options == "metadata,uid=1001,gid=100";
  assert customWsl.config.wsl.wslConf.automount.options == "metadata,uid=1234,gid=100";
  assert wsl.services.vscode-server.enable;
  assert wsl.services.vscode-server.nodejsPackage == null;
  assert !(wsl.systemd.user.services ? vscode-remote-workaround);
  assert wsl.systemd.services.chmod-podman-socket.requires == [];
  assert builtins.elem "--write-kubeconfig-mode=0640" nuc.services.k3s.extraFlags;
  assert !(nuc.systemd.services ? chmod-config);
  assert darwin.defaultApplications."com.adobe.pdf" == "info.sioyek.sioyek";
  assert darwin.defaultApplications."public.source-code" == "com.microsoft.VSCode";
    pkgs.runCommand "module-regressions" {} ''
      touch "$out"
    ''
