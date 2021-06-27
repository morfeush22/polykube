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

/_output/bin/e2e.test -context kind-kind -ginkgo.focus="\[Conformance\]" -num-nodes 2
kind create cluster --config kind-config.yaml --image kindest/node:latest -v4
export KUBECONFIG="${HOME}/.kube/kind-test-config"

deps.txt in all packages
Makefile template

# necessary for conformance
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  ipFamily: ipv4
nodes:
# the control plane node
- role: control-plane
- role: worker
- role: worker

staging packages

generate just deps files

add aggregate targets

cut -1
generate package names: cmd, pkg, integration, staging
x subdirectories max (cmd/x, pkg/x test/integration/x, etc.)
save do adj matrix in txt file
parse file in python
output graph and txt for each package

generate automatically gocd yaml files

staging

filter third_party in yaml

plugin/pkg

kubernetes_repo_import_path = "k8s.io/kubernetes" <- umbrella, not interesting
kubernetes_staging_import_path = "k8s.io" <- staging, OK

kubernetes_test_integration_import_path = f"{kubernetes_repo_import_path}/test/integration" <- OK
kubernetes_plugin_import_path = f"{kubernetes_repo_import_path}/plugin/pkg" <- OK
kubernetes_cmd_import_path = f"{kubernetes_repo_import_path}/cmd" <- OK
kubernetes_pkg_import_path = f"{kubernetes_repo_import_path}/pkg" <- OK
kubernetes_test_import_path = f"{kubernetes_repo_import_path}/test" <- test framework, not interesting
kubernetes_third_party_import_path = f"{kubernetes_repo_import_path}/third_party" <- third party Go, not interesting

CI/CD pipelines model?

to filter:
kube-openapi
klog
heapster
utils
system-validators
test/integration/framework
test/utils
test/integration
test/utils/image
test/integration/util
