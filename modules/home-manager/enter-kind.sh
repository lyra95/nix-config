function enter-kind() {
	ORIGINAL_IN_NIX_SHELL=$IN_NIX_SHELL
	ORIGINAL_KUBECONFIG=$KUBECONFIG

	TEMPFILE=$(mktemp --suffix=.kubeconfig)
	kind get kubeconfig >"$TEMPFILE"

	IN_NIX_SHELL=impure \
		name=kind \
		KUBECONFIG="$TEMPFILE" \
		bash -c 'eval "$(kind completion bash)"; exec bash'

	IN_NIX_SHELL=$ORIGINAL_IN_NIX_SHELL
	KUBECONFIG=$ORIGINAL_KUBECONFIG
	unset ORIGINAL_IN_NIX_SHELL ORIGINAL_KUBECONFIG
}
