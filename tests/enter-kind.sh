set -euo pipefail
source "$1"

test_root=$(mktemp -d)
trap 'rm -rf -- "$test_root"' EXIT
mkdir -p "$test_root/bin" "$test_root/tmp with spaces"
export TMPDIR="$test_root/tmp with spaces"
export KIND_TEST_ARGS="$test_root/args"
export KIND_TEST_CONFIG="$test_root/last-config"

cat >"$test_root/bin/kind" <<'MOCK'
#!/usr/bin/env bash
printf '%s\n' "$@" >"$KIND_TEST_ARGS"
if [[ ${KIND_TEST_FAIL:-0} == 1 ]]; then exit 17; fi
printf '%s\n' 'test kubeconfig'
MOCK
cat >"$test_root/bin/bash" <<'MOCK'
#!/usr/bin/env bash
[[ "$IN_NIX_SHELL" == impure && "$name" == kind ]] || exit 1
[[ "$(cat "$KUBECONFIG")" == 'test kubeconfig' ]] || exit 2
printf '%s\n' "$KUBECONFIG" >"$KIND_TEST_CONFIG"
exit "${KIND_TEST_SHELL_STATUS:-0}"
MOCK
# Use an absolute interpreter to avoid recursion through the mock bash on PATH.
sed -i "1c #!$(command -v bash)" "$test_root/bin/kind" "$test_root/bin/bash"
chmod +x "$test_root/bin/"*
export PATH="$test_root/bin:$PATH"

unset KUBECONFIG IN_NIX_SHELL name
enter-kind --name 'cluster with spaces'
[[ ! -v KUBECONFIG && ! -v IN_NIX_SHELL && ! -v name ]]
[[ "$(cat "$KIND_TEST_ARGS")" == $'get\nkubeconfig\n--name\ncluster with spaces' ]]
[[ ! -e "$(cat "$KIND_TEST_CONFIG")" ]]

export KUBECONFIG=original IN_NIX_SHELL=pure name=original
export KIND_TEST_SHELL_STATUS=42
status=0
enter-kind || status=$?
[[ $status == 42 ]]
[[ $KUBECONFIG == original && $IN_NIX_SHELL == pure && $name == original ]]
[[ ! -e "$(cat "$KIND_TEST_CONFIG")" ]]

rm "$KIND_TEST_CONFIG"
export KIND_TEST_FAIL=1
status=0
enter-kind || status=$?
[[ $status == 17 ]]
[[ ! -e "$KIND_TEST_CONFIG" ]]
[[ -z "$(ls -A "$TMPDIR")" ]]
