# MAC (aarch64-darwin, M1)

시행착오 및 히스토리도 포함되어있음

## 1. [nix package manager](https://nixos.org/download.html#nix-install-macos) 설치

```console
$ sh <(curl -L https://nixos.org/nix/install)
```

다 yes 함

## 2. 이 저장소를 clone

`nix-shell -p git`으로 git이 설치된 shell을 임시로 실행 한 후, `git clone https://github.com/lyra95/nix-config.git`

## 3. [nix-darwin](https://github.com/LnL7/nix-darwin#install) 설치

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

## 4. flake build

```console
nix build .\#darwinConfigurations.jos-MacBook-Air.system
````

## 5. darwin-rebuild switch

```console
./result/sw/bin/darwin-rebuild switch --flake .
```
