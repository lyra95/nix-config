# 모듈과 flake 조합의 경계

`parts`는 input 연결, 공개 output 등록, 머신별 모듈 선택, checks 연결을 담당한다.
실제 프로그램·운영체제 설정은 `modules`에 둔다. 외부 input이나 사용자 정보가
필요한 모듈은 필요한 값을 명시적으로 받아 Nix module을 반환하는 함수로 만든다.
`lib.modules.importApply`는 이런 함수형 모듈을 flake output으로 노출할 때 사용한다.

- `modules/home-manager/default.nix`: 기능 모듈 및 agenix 의존성 등록.
  import만으로 AWS, Git, Kubernetes 같은 선택 기능을 켜지 않는다.
- `modules/home-manager/shell.nix`, `modern-cli.nix`, `darwin.nix`: 목적별 사용자 설정.
- `modules/home-manager/profiles`: 공통 홈 구성과 work, k3s, container의 기능 선택.
  공통 프로필의 홈 경로와 선택 도구 기본값은 일반 설정으로 재정의할 수 있다.
- `modules/nixos/base.nix`: WSL과 일반 NixOS가 공유하는 Nix·콘솔 설정.
- `modules/nixos/profiles/default.nix`: 일반 NixOS 사용자·로케일·네트워크 구성.
  패키지는 NixOS가 평가하는 `pkgs`를 사용한다.
- `modules/wsl/profile.nix`: NixOS-WSL과 WSL 기능 조합.
- `modules/darwin/desktop.nix`: 데스크톱 설정 및 기본 앱 선택.
- `modules/darwin/default-apps.nix`: UTI → bundle ID 설정을 primaryUser에게 적용.
- `modules/devshell/default.nix`: 개발 명령과 셸 설정.

기존 `homeModules`, `homeManagerModules`, `nixosModules`, `darwinModules`,
`nixvimModules` output 이름은 유지한다. `home`, `dell`, `work`의 홈 설정도 계속
같은 구성을 공유한다. 사용자명·아키텍처·stateVersion 선택은 `parts`에 남긴다.

# 우회 처리 점검

## 교체하거나 수정한 것

- VS Code: 직접 Node symlink를 만들던 WSL 스크립트를 lock에 고정된
  `nixos-vscode-server` 모듈로 교체했다. upstream watcher가 기존 `bin/<commit>`과
  `cli/servers` 설치 경로를 처리한다. 기존 `vscode-remote-workaround.enable`과
  `.package`는 upstream 옵션의 alias로 유지한다. Node 버전은 기본적으로 강제하지 않는다.
- Podman Desktop: 특정 외부 mount unit 두 개에 대한 의존성을 제거했다.
  부팅 때와 소켓 디렉터리가 바뀔 때 권한을 적용한다. Unix socket 연결에 필요한
  그룹 쓰기 권한도 부여한다. `podman.socketPath`로 다른 머신의 소켓을 지정할 수 있다.
- k3s: 부팅 때 한 번 실행하던 chmod 서비스 대신 k3s 자체
  `--write-kubeconfig-group=k3s`, `--write-kubeconfig-mode=0640`을 사용한다.
  kubeconfig 재생성에도 권한이 적용된다.
  [k3s 공식 옵션](https://docs.k3s.io/cli/server#client)
- Git: `[aliases]`, `[extraConfig]` 아래로 들어가던 값을 실제 Git의 `[alias]`,
  `[init]`, `[merge]` 설정으로 수정했다. GitHub SSH 사용자도 `git`으로 수정했다.
- `enter-kind`: subshell에서 실행하고 임시 kubeconfig를 EXIT trap으로 지운다.
  GNU 전용 `mktemp --suffix`를 제거하고 인자를 kind에 전달한다.
  kind 실패와 자식 셸 종료 코드를 보존하며 호출자 환경변수는 건드리지 않는다.
- Sioyek: PDF 및 VS Code 기본 앱 등록을 별도 모듈로 분리했다.
  등록은 idempotent한 `duti -s`를 사용하며 activation 전체의 shell option을 바꾸지 않는다.
  Qt wrapper의 PATH에는 uv, Nix 프로필, 현재 아키텍처의 Homebrew 경로를 넣는다.
- devshell: 이미 제거된 `repl-flake` experimental feature를 요청하지 않는다.

## 유지한 것과 제거 조건

- WSL UID 1001: 실행 중인 Windows WSL 버전을 이 저장소만으로 확인할 수 없어서
  유지했다. `modules/wsl/user-session.nix`로 분리하고 automount UID/GID를 실제 사용자
  설정에서 계산한다. 프로필의 `userUid` 인자로 다른 UID를 선택할 수 있다.
  이미 존재하는 계정의 UID 변경은 NixOS가 자동 적용하지 않는다.
  변경 시 `usermod`와 홈 외부의 기존 소유 파일 이전이 별도로 필요하다.
- getty → logind 시작 순서: 빠른 콘솔 로그인 시 user bus 생성 문제에 대한 기존
  workaround를 유지했다. `After`만 두며 강한 `Requires` 의존성은 추가하지 않는다.
  최신 호스트에서 빠른 로그인으로 재현되지 않는지 확인한 뒤 제거할 수 있다.
- Sioyek Resources 복사: lock에 고정된 nixpkgs는 여전히 리소스를
  `Contents/MacOS`에 설치하므로 `Contents/Resources` 복사를 유지했다.
  upstream 패키지 설치 위치가 바뀌면 제거 여부를 다시 점검한다.
- Neo-tree 테스트 데이터 디렉터리: 현재 플러그인의 logger가 첫 실행에 data 경로를
  사용하므로 sandbox 테스트의 XDG_DATA_HOME 초기화를 유지했다.
  `checks.nvim` 빌드로 시작 검사를 실행한다.
- Podman Desktop CLI PATH: `/opt/podman/bin`을 노출하는 기존 모듈을 유지했다.

# 검증

```sh
nix flake check --no-build --all-systems
nix build --no-link .#checks.x86_64-linux.modules \
  .#checks.x86_64-linux.enter-kind .#checks.x86_64-linux.nvim \
  .#checks.x86_64-linux.devshell .#checks.x86_64-linux.home-container
```

`checks.modules`는 공개 기본 홈 모듈의 독립 사용, 컨테이너 기능 비활성화,
Git 설정, UID 재정의 시 automount 소유권, VS Code 모듈 연결, k3s 옵션,
Darwin 기본 앱 선택을 검사한다. `checks.enter-kind`는 외부 cluster 없이 mock으로
성공·실패·종료 코드·공백이 포함된 경로·환경변수 보존·임시 파일 정리를 검사한다.

Darwin 앱 실행·기본 앱 등록과 WSL/Podman/k3s의 실제 서비스 동작은 각 호스트에서
activation 후 확인해야 한다. 이 작업에서는 시스템 switch나 사용자 UID 변경을 하지 않는다.
