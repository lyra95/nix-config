{vscode-server}: {
  imports = [
    ./podman.nix
    (import ./vscode.nix {inherit vscode-server;})
  ];
}
