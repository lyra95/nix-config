{
  config,
  lib,
  ...
}: {
  options = {
    # While booting, if you login to shell quickly enough before logind starts,
    # you may find some user services (user@.service, user-runtime-dir@.service) missing.
    # From the user perspective, commands like `systemctl --user` will output "Failed to connect to bus: No such file or directory".
    #
    # Steps to reproduce:
    # 1. a user logs in, while logind is not yet started
    # 2. user-runtime-dir@.service not started because logind is not yet started
    # 3. user runtime dir (/run/user/$UID) is not created
    # 4. dbus socket file is not created due to missing user runtime dir
    bug-fix.fix-logind-race-condition = lib.mkEnableOption "Fix logind race condition";
  };
  config = lib.mkIf config.bug-fix.fix-logind-race-condition {
    # not `required`, because `required` could cause a deadlock situation where you can't login
    systemd.services."getty@".after = ["systemd-logind.service"];
  };
}
