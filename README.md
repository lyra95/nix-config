# BOOTSTRAP

BOOTSTRAP-XXX.md 파일들 참고

# 변경 적용 및 업데이트

`make darwin-switch` 혹은 `make wsl-switch`

# HELP

## 내 architecture 찾기

```console
jo@jos-MacBook-Air$ nix-shell -p nix-info
```

```console
[nix-shell:~/dev/nix-config]$ nix-info
system: "aarch64-darwin", multi-user?: yes, version: nix-env (Nix) 2.13.2, channels(jo): "home-manager", channels(root): "nixpkgs", nixpkgs: /nix/var/nix/profiles/per-user/root/channels/nixpkgs
```

# TODO

 - [ ] : (chore) username, pc name, system에 하드코드된거 `let... in...` expression으로 변경
 - [ ] : neovim 설정 변경
 - [ ] : 각종 필요한 패키지들 더 설치
   - awscli, pulumi
   - kubectl, helm, kustomize, docker, ...
   - dotnet, rust, node, python, haskell, ...
 - [ ] : lint 및 formatter 적용
