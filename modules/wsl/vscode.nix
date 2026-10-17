{vscode-server}: {lib, ...}: {
  imports = [
    vscode-server.nixosModules.default
    (lib.mkAliasOptionModule ["vscode-remote-workaround" "enable"] ["services" "vscode-server" "enable"])
    (lib.mkAliasOptionModule ["vscode-remote-workaround" "package"] ["services" "vscode-server" "nodejsPackage"])
  ];

  # The upstream watcher handles both bin/<commit> and cli/servers installations,
  # and patches their bundled runtime without assuming a compatible Node version.
}
