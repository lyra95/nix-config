  수정된 절차

  1. jo 프로세스 없는 상태 만들기. usermod -u는 대상 유저의 프로세스가 살아있으면 거부합니다.

  wsl --terminate NixOS
  wsl -d NixOS -u root

  2. uid 변경 + 홈 밖 chown. usermod -u는 홈 디렉터리 안의 옛 uid 파일만 자동으로 chown하므로 밖은 수동입니다.

  pgrep -u jo                      # 비어 있어야 함. 있으면: loginctl terminate-user jo
  usermod -u 1001 jo
  id jo                            # uid=1001(jo) gid=100(users)

  chown -R 1001:100 /etc/nixos \
    /nix/var/nix/profiles/per-user/jo /nix/var/nix/gcroots/per-user/jo

  find / -xdev -uid 1000 -printf '%p\n' | head -50   # 남은 게 있으면 chown

  3. rebuild — 이제 선언값(1001)과 실제가 일치하므로 경고 없이 통과하고, wsl.conf의 automount 옵션이 갱신됩니다.

  nixos-rebuild switch --flake /etc/nixos#work
  grep options /etc/wsl.conf        # metadata,uid=1001,gid=100

  4. 재시작 & 확인. podman machine은 일부러 켜둔 채로 (그래야 우회 성공을 검증):

  wsl --terminate NixOS
  wsl -d NixOS

  id                                        # uid=1001
  systemctl is-active user@1001.service     # active
  systemctl --user status agenix.service    # 정상
  stat -c '%u' /mnt/c /mnt/d                # 1001 1001
  sudo find /mnt/c /mnt/d -uid 1000 2>/dev/null | head   # 나오면 명시적 metadata → chown 1001:100
  home-manager switch --flake /etc/nixos#work

  /nix 전체를 포함한 전수 스캔은 아직 백그라운드에서 돌고 있습니다 (store가 커서 느립니다). 끝나면 /home/jo 밖에 남은 uid/gid 1000 경로 목록을 알려드리겠습니다 — /nix/store 내부는 전부
  root 소유이므로 새로운 게 나올 가능성은 낮지만, 확인 없이 "이거 말고는 없다"고 말하진 않겠습니다.