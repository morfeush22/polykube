# The set of server targets that we are only building for Linux
# If you update this list, please also update build/BUILD.
kube::golang::server_targets() {
  local targets=(
    cmd/kube-proxy
    cmd/kube-apiserver
    cmd/kube-controller-manager
    cmd/kubelet
    cmd/kubeadm
    cmd/kube-scheduler
    vendor/k8s.io/kube-aggregator
    vendor/k8s.io/apiextensions-apiserver
    cluster/gce/gci/mounter
  )
  echo "${targets[@]}"
}

# The set of server targets that we are only building for Kubernetes nodes
# If you update this list, please also update build/BUILD.
kube::golang::node_targets() {
  local targets=(
    cmd/kube-proxy
    cmd/kubeadm
    cmd/kubelet
  )
  echo "${targets[@]}"
}

# integration test - single repo
# makefile integration test autodiscovery

cmd/kubelet


./bartender "/home/morfeush22/Projects/kubernetes" "/home/morfeush22/Projects/kubernetes/cmd/kubectl-convert/deps.txt" "/home/morfeush22/Projects/test_bartender"
./waitress "/home/morfeush22/Projects/kubernetes" "cmd/kubectl-convert" "/home/morfeush22/Projects/test_bartender"

1. generate deps (with test) in temporary path
2. pass path to temporary