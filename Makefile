.Phony: build
build:
	./result/sw/bin/darwin-rebuild switch --flake .

.ONESHELL: gc
.Phony: gc
gc:
	nix-env --delete-generations old
	nix-store --gc
	nix-collect-garbage -d