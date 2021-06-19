KUBERNETES_REPO_ROOT_DIR := $(HOME)/Projects/kubernetes
POLYREPO_DEST_ROOT_DIR   := $(HOME)/Projects/masters/polyrepo

KUBERNETES_BINARY_COMPONENTS := \
	apiextensions-apiserver \
	kubeadm \
	kube-aggregator \
	kube-apiserver \
	kube-controller-manager \
	kubectl \
	kubectl-convert \
	kubelet \
	kube-proxy \
	kube-scheduler \
	mounter

apiextensions-apiserver_RELATIVE_SUBPATH := vendor/k8s.io/apiextensions-apiserver
kubeadm_RELATIVE_SUBPATH                 := cmd/kubeadm
kube-aggregator_RELATIVE_SUBPATH         := vendor/k8s.io/kube-aggregator
kube-apiserver_RELATIVE_SUBPATH          := cmd/kube-apiserver
kube-controller-manager_RELATIVE_SUBPATH := cmd/kube-controller-manager
kubectl_RELATIVE_SUBPATH                 := cmd/kubectl
kubectl-convert_RELATIVE_SUBPATH         := cmd/kubectl-convert
kubelet_RELATIVE_SUBPATH                 := cmd/kubelet
kube-proxy_RELATIVE_SUBPATH              := cmd/kube-proxy
kube-scheduler_RELATIVE_SUBPATH          := cmd/kube-scheduler
mounter_RELATIVE_SUBPATH                 := cluster/gce/gci/mounter

KUBERNETES_INTEGRATION_TESTS := \
	apimachinery \
	apiserver \
	auth \
	benchmark \
	certificates \
	client \
	configmap \
	cronjob \
	daemonset \
	defaulttolerationseconds \
	deployment \
	disruption \
	dryrun \
	dualstack \
	endpoints \
	endpointslice \
	etcd \
	events \
	evictions \
	examples \
	framework \
	garbagecollector \
	ipamperf \
	kubelet \
	master \
	metrics \
	namespace \
	node \
	objectmeta \
	openshift \
	pods \
	quota \
	replicaset \
	replicationcontroller \
	scale \
	scheduler \
	scheduler_perf \
	secrets \
	serviceaccount \
	serving \
	statefulset \
	storageclasses \
	storageversion \
	tls \
	ttlcontroller \
	util \
	volume \
	volumescheduling

KUBERNETES_BINARY_COMPONENTS_SUBDIRS_TARGETS := $(addprefix _create_binary_component_subdir_,$(KUBERNETES_BINARY_COMPONENTS))
KUBERNETES_BINARY_COMPONENTS_MIGRATE_TARGETS := $(addprefix _migrate_binary_component_to_polyrepo_,$(KUBERNETES_BINARY_COMPONENTS))

KUBERNETES_INTEGRATION_TESTS_SUBDIRS_TARGETS := $(addprefix _create_integration_test_subdir_,$(KUBERNETES_INTEGRATION_TESTS))
KUBERNETES_INTEGRATION_TESTS_MIGRATE_TARGETS := $(addprefix _migrate_integration_test_to_polyrepo_,$(KUBERNETES_INTEGRATION_TESTS))

SHELL = bash

create_binary_components_subdirs: $(KUBERNETES_BINARY_COMPONENTS_SUBDIRS_TARGETS)
create_integration_tests_subdirs: $(KUBERNETES_INTEGRATION_TESTS_SUBDIRS_TARGETS)

migrate_binary_components_to_polyrepo: $(KUBERNETES_BINARY_COMPONENTS_MIGRATE_TARGETS)
migrate_integration_tests_to_polyrepo: $(KUBERNETES_INTEGRATION_TESTS_MIGRATE_TARGETS)

POLYREPO_BINARY_COMPONENTS_DEST_ROOT_DIR := $(POLYREPO_DEST_ROOT_DIR)/binary_component
POLYREPO_INTEGRATION_TESTS_DEST_ROOT_DIR := $(POLYREPO_DEST_ROOT_DIR)/integration_test

clean:
	rm -rf $(POLYREPO_DEST_ROOT_DIR)

_create_binary_component_subdir_%:
	mkdir -p $(POLYREPO_BINARY_COMPONENTS_DEST_ROOT_DIR)/$(*)

_create_integration_test_subdir_%:
	mkdir -p $(POLYREPO_INTEGRATION_TESTS_DEST_ROOT_DIR)/$(*)

_migrate_common_%:
	migrators/bar.sh $(KUBERNETES_REPO_ROOT_DIR) $($(*)_RELATIVE_SUBPATH) $(POLYREPO_BINARY_COMPONENTS_DEST_ROOT_DIR)/$(*)

_migrate_binary_component_to_polyrepo_%: _create_binary_component_subdir_% _migrate_common_%
	migrators/binary_components/$(*).sh $(KUBERNETES_REPO_ROOT_DIR) $($(*)_RELATIVE_SUBPATH) $(POLYREPO_BINARY_COMPONENTS_DEST_ROOT_DIR)/$(*)

_migrate_integration_test_to_polyrepo_%: _create_integration_test_subdir_% _migrate_common_%
	migrators/integration_tests/$(*).sh $(KUBERNETES_REPO_ROOT_DIR) $($(*)_RELATIVE_SUBPATH) $(POLYREPO_INTEGRATION_TESTS_DEST_ROOT_DIR)/$(*)
