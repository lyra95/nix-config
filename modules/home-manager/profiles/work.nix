{pkgs, ...}: {
  home.packages = [pkgs.stu pkgs.claude-code];
  aws.enable = true;
  git.enable = true;
  git.wsl = true;
  rclone.enable = true;
  kind.enable = true;
}
