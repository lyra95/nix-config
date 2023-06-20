{
  description = "Jo's Declarative Personal Computer Setup";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      # https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html#flake-inputs
      # 위에서 정의한 nixpkgs 인풋을 home-manager flake에 들어가는 nixpkgs 인풋으로 재활용
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/LnL7/nix-darwin
    # maxOS의 설정을 선언적으로 관리하게 해줌
    # 설정가능한 옵션은 https://daiderd.com/nix-darwin/manual/index.html#sec-options 에서 참고
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    astroNvim = {
      url = "github:AstroNvim/AstroNvim/main";
      flake = false;
    };
  };
  outputs = inputs@{ nixpkgs, home-manager, darwin, astroNvim, ... }: {
    darwinConfigurations = {
      # PC 이름
      jos-MacBook-Air = darwin.lib.darwinSystem {
        # nix-info로 현재 pc의 system 변수에 해당하는 값 찾아낼 수 있음
        system = "aarch64-darwin";
        pkgs = import nixpkgs { system = "aarch64-darwin"; };
        modules = [
          (import ./modules/darwin { username = "jo"; homeDirectory = "/Users/jo"; })
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { };
              users.jo = import ./modules/home-manager { username = "jo"; homeDirectory = "/Users/jo"; astroNvim = astroNvim; };
            };
          }
        ];
      };
    };

    homeConfigurations = {
      WSL2Ubuntu = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          (import ./modules/home-manager { username = "jo"; homeDirectory = "/home/jo"; astroNvim = astroNvim; })
        ];
      };
    };
  };
}
