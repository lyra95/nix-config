.Phony: darwin-switch
darwin-switch:
	./result/sw/bin/darwin-rebuild switch --flake .

.Phony: darwin-build
darwin-build:
	nix build .\#darwinConfigurations.jos-MacBook-Air.system --show-trace

.Phony: wsl-switch
wsl-switch: wsl-build
	./result/bin/home-manager-generation switch --flake .

.Phony: wsl-build
wsl-build:
	nix build --extra-experimental-features 'nix-command flakes' .\#homeConfigurations.WSL2Ubuntu.activationPackage --show-trace

.Phony: fmt
fmt:
	nix-shell -p nixpkgs-fmt --run 'nixpkgs-fmt .'

.ONESHELL: gc
.Phony: gc
gc:
	nix-env --delete-generations old
	nix-store --gc
	nix-collect-garbage -d
