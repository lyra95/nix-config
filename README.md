# 내 architecture 찾기

```console
jo@jos-MacBook-Air$ nix-shell -p nix-info
```

```console
[nix-shell:~/dev/nix-config]$ nix-info
system: "aarch64-darwin", multi-user?: yes, version: nix-env (Nix) 2.13.2, channels(jo): "home-manager", channels(root): "nixpkgs", nixpkgs: /nix/var/nix/profiles/per-user/root/channels/nixpkgs
```
# bootstrap

1. [nix package manager](https://nixos.org/download.html#nix-install-macos) 설치

```console
$ sh <(curl -L https://nixos.org/nix/install)
```

다 yes 함

2. [nix-darwin](https://github.com/LnL7/nix-darwin#install) 설치

```console
$ nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
```

```console
$ ./result/bin/darwin-installer
```

다 yes 함

```console
error: not linking environment.etc."nix/nix.conf" because /etc/nix/nix.conf already exists, skipping...
existing file has unknown content ff08c12813680da98c4240328f828647b67a65ba7aa89c022bd8072cba862cf1, move and activate again to apply
```

이런게 떠서 `mv /etc/nix/nix.conf /etc/nix/nix.conf.bak`함

```console
$ diff /etc/nix/nix.conf /etc/nix/nix.conf.bak
1,16d0
< # WARNING: this file is generated from the nix.* options in
< # your nix-darwin configuration. Do not edit it!
< allowed-users = *
< auto-optimise-store = false
< build-users-group = nixbld
< builders =
< cores = 0
< extra-sandbox-paths =
< max-jobs = auto
< require-sigs = true
< sandbox = false
< sandbox-fallback = false
< substituters = https://cache.nixos.org/
< trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
< trusted-substituters =
< trusted-users = root
17a2
> build-users-group = nixbld
```

3. flake build 및 home-manager 설정 적용

```console
nix build .\#darwinConfigurations.jos-MacBook-Air.system
````

```console
./result/sw/bin/darwin-rebuild switch --flake .
```
