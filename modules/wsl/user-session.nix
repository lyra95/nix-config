{uid ? 1001}: {
  config,
  lib,
  ...
}: let
  userName = config.wsl.defaultUser;
  actualUid = config.users.users.${userName}.uid;
in {
  # WSL distros can contend for user@1000.service in their shared cgroup tree.
  # Keep the existing UID until the installed Windows WSL version is verified.
  # Existing users need a manual UID migration; NixOS only applies this on creation.
  users.users.${userName}.uid = uid;
  # Follow an overridden UID instead of silently leaving Windows drives at 1001.
  wsl.wslConf.automount.options = lib.mkDefault "metadata,uid=${toString actualUid},gid=${toString config.users.groups.users.gid}";
}
