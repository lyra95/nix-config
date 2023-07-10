[macos]
switch: build
	./result/sw/bin/darwin-rebuild switch --flake .

[linux]
switch: build
	./result/bin/home-manager-generation switch --flake .

[macos]
build:
	nix build .\#darwinConfigurations.jos-MacBook-Air.system --show-trace

[linux]
build:
	nix build --extra-experimental-features 'nix-command flakes' .\#homeConfigurations.WSL2Ubuntu.activationPackage --show-trace

fmt:
	nix-shell -p nixpkgs-fmt --run 'nixpkgs-fmt .'

gc:
	nix-env --delete-generations old
	nix-store --gc
	nix-collect-garbage -d
