# WSL2 (Ubuntu 22.04)

## 1. nameserver 설정 수정

처음에 이유를 모르겠으나 domain name resolving이 안 됨.

/etc/resolv.conf 파일에서 nameserver를 1.1.1.1로 변경함.

/etc/resolv.conf가 WSL에 의해 자동생성 되지 않도록 /etc/wsl.conf에 다음 설정 추가:

```
[network]
generateResolvConf = false
```

## 2. [nix package manager](https://nixos.org/download.html#nix-install-windows) 설치

## 3. 이 저장소를 clone

`nix-shell -p git`으로 git이 설치된 shell을 임시로 실행 한 후, `git clone https://github.com/lyra95/nix-config.git`

## 4. flake build

`nix build --extra-experimental-features 'nix-command flakes' .\homeConfigurations.WSL2Ubuntu.activationPackage`

## 5. home-manager switch

`./result/bin/home-manager-generation switch --flake .`

## 6. fish를 login shell로 지정

home-manager로 설정 가능한 부분이 아니라서, chsh로 바꾸려했는데 /etc/shell에 fish가 없어서 `sudo usermod --shell /home/jo/.nix-profile/bin/fish jo`로 함

## 7. windows에 있는 도커 엔진과 unix socket으로 연결하기

wsl default dist로 설정해줘야함

https://docs.docker.com/desktop/windows/wsl/#enabling-docker-support-in-wsl-2-distros

