function enter-kind() (
	local kubeconfig
	kubeconfig=$(mktemp "${TMPDIR:-/tmp}/kind-kubeconfig.XXXXXX") || return
	trap 'rm -f -- "$kubeconfig"' EXIT

	kind get kubeconfig "$@" >"$kubeconfig" || return
	IN_NIX_SHELL=impure name=kind KUBECONFIG="$kubeconfig" bash
)
