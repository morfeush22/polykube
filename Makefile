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
	volume \
	volumescheduling

KUBERNETES_APIS := \
	api\
	apis \
	auth \
	capabilities \
	client \
	cloudprovider \
	controller \
	controlplane \
	credentialprovider \
	fieldpath \
	generated \
	kubeapiserver \
	kubectl \
	kubelet \
	printers \
	probe \
	proxy \
	quota \
	registry \
	scheduler \
	security \
	securitycontext \
	serviceaccount \
	ssh \
	util \
	volume

KUBERNETES_BINARY_COMPONENTS_SUBDIRS_TARGETS := $(addprefix _create_binary_component_subdir_,$(KUBERNETES_BINARY_COMPONENTS))
KUBERNETES_BINARY_COMPONENTS_MIGRATE_TARGETS := $(addprefix _migrate_binary_component_to_polyrepo_,$(KUBERNETES_BINARY_COMPONENTS))

KUBERNETES_INTEGRATION_TESTS_SUBDIRS_TARGETS := $(addprefix _create_integration_test_subdir_,$(KUBERNETES_INTEGRATION_TESTS))
KUBERNETES_INTEGRATION_TESTS_MIGRATE_TARGETS := $(addprefix _migrate_integration_test_to_polyrepo_,$(KUBERNETES_INTEGRATION_TESTS))

KUBERNETES_APIS_SUBDIRS_TARGETS := $(addprefix _create_api_subdir_,$(KUBERNETES_APIS))
KUBERNETES_APIS_MIGRATE_TARGETS := $(addprefix _migrate_api_to_polyrepo_,$(KUBERNETES_APIS))

SHELL = bash

create_binary_components_subdirs: $(KUBERNETES_BINARY_COMPONENTS_SUBDIRS_TARGETS)
create_integration_tests_subdirs: $(KUBERNETES_INTEGRATION_TESTS_SUBDIRS_TARGETS)
create_apis_subdirs: $(KUBERNETES_APIS_SUBDIRS_TARGETS)

migrate_binary_components_to_polyrepo: $(KUBERNETES_BINARY_COMPONENTS_MIGRATE_TARGETS)
migrate_integration_tests_to_polyrepo: $(KUBERNETES_INTEGRATION_TESTS_MIGRATE_TARGETS)
migrate_apis_to_polyrepo: $(KUBERNETES_APIS_MIGRATE_TARGETS)

POLYREPO_BINARY_COMPONENTS_DEST_ROOT_DIR := $(POLYREPO_DEST_ROOT_DIR)/binary_components
POLYREPO_INTEGRATION_TESTS_DEST_ROOT_DIR := $(POLYREPO_DEST_ROOT_DIR)/integration_tests
POLYREPO_APIS_DEST_ROOT_DIR              := $(POLYREPO_DEST_ROOT_DIR)/apis

clean:
	rm -rf $(POLYREPO_DEST_ROOT_DIR)

_create_binary_component_subdir_%:
	mkdir -p $(POLYREPO_BINARY_COMPONENTS_DEST_ROOT_DIR)/$(*)

_create_integration_test_subdir_%:
	mkdir -p $(POLYREPO_INTEGRATION_TESTS_DEST_ROOT_DIR)/$(*)

_create_api_subdir_%:
	mkdir -p $(POLYREPO_APIS_DEST_ROOT_DIR)/$(*)

_migrate_binary_component_common_%:
	migrators/bar.sh $(KUBERNETES_REPO_ROOT_DIR) $($(*)_RELATIVE_SUBPATH) $(POLYREPO_BINARY_COMPONENTS_DEST_ROOT_DIR)/$(*)

_migrate_integration_test_common_%:
	migrators/bar.sh $(KUBERNETES_REPO_ROOT_DIR) test/integration/$(*) $(POLYREPO_INTEGRATION_TESTS_DEST_ROOT_DIR)/$(*)

_migrate_api_common_%:
	migrators/bar.sh $(KUBERNETES_REPO_ROOT_DIR) pkg/$(*) $(POLYREPO_APIS_DEST_ROOT_DIR)/$(*)

_migrate_binary_component_to_polyrepo_%: _create_binary_component_subdir_% _migrate_binary_component_common_%
	migrators/binary_components/$(*).sh $(KUBERNETES_REPO_ROOT_DIR) $(POLYREPO_BINARY_COMPONENTS_DEST_ROOT_DIR)/$(*)

_migrate_integration_test_to_polyrepo_%: _create_integration_test_subdir_% _migrate_integration_test_common_%
	migrators/integration_tests/$(*).sh $(KUBERNETES_REPO_ROOT_DIR) $(POLYREPO_INTEGRATION_TESTS_DEST_ROOT_DIR)/$(*)

_migrate_api_to_polyrepo_%: _create_api_subdir_% _migrate_api_common_%
	migrators/apis/$(*).sh $(KUBERNETES_REPO_ROOT_DIR) $(POLYREPO_APIS_DEST_ROOT_DIR)/$(*)
