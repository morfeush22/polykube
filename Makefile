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

KUBERNETES_PLUGINS := \
	admission \
	auth

KUBERNETES_STAGING := \
	api \
	apiextensions-apiserver \
	apimachinery \
	apiserver \
	cli-runtime \
	client-go \
	cloud-provider \
	cluster-bootstrap \
	component-base \
	component-helpers \
	controller-manager \
	cri-api \
	csi-translation-lib \
	kube-aggregator \
	kube-controller-manager \
	kube-proxy \
	kube-scheduler \
	kubectl \
	kubelet \
	legacy-cloud-providers \
	metrics \
	mount-utils

KUBERNETES_BINARY_COMPONENTS_SUBDIRS_TARGETS := $(addprefix _create_binary_component_subdir_,$(KUBERNETES_BINARY_COMPONENTS))
KUBERNETES_BINARY_COMPONENTS_MIGRATE_TARGETS := $(addprefix _migrate_binary_component_to_polyrepo_,$(KUBERNETES_BINARY_COMPONENTS))

KUBERNETES_INTEGRATION_TESTS_SUBDIRS_TARGETS := $(addprefix _create_integration_test_subdir_,$(KUBERNETES_INTEGRATION_TESTS))
KUBERNETES_INTEGRATION_TESTS_MIGRATE_TARGETS := $(addprefix _migrate_integration_test_to_polyrepo_,$(KUBERNETES_INTEGRATION_TESTS))

KUBERNETES_APIS_SUBDIRS_TARGETS := $(addprefix _create_api_subdir_,$(KUBERNETES_APIS))
KUBERNETES_APIS_MIGRATE_TARGETS := $(addprefix _migrate_api_to_polyrepo_,$(KUBERNETES_APIS))

KUBERNETES_PLUGINS_SUBDIRS_TARGETS := $(addprefix _create_plugin_subdir_,$(KUBERNETES_PLUGINS))
KUBERNETES_PLUGINS_MIGRATE_TARGETS := $(addprefix _migrate_plugin_to_polyrepo_,$(KUBERNETES_PLUGINS))

KUBERNETES_STAGING_SUBDIRS_TARGETS := $(addprefix _create_staging_subdir_,$(KUBERNETES_STAGING))
KUBERNETES_STAGING_MIGRATE_TARGETS := $(addprefix _migrate_staging_to_polyrepo_,$(KUBERNETES_STAGING))

SHELL = bash

create_binary_components_subdirs: $(KUBERNETES_BINARY_COMPONENTS_SUBDIRS_TARGETS)
create_integration_tests_subdirs: $(KUBERNETES_INTEGRATION_TESTS_SUBDIRS_TARGETS)
create_apis_subdirs: $(KUBERNETES_APIS_SUBDIRS_TARGETS)
create_plugins_subdirs: $(KUBERNETES_PLUGINS_SUBDIRS_TARGETS)
create_staging_subdirs: $(KUBERNETES_STAGING_SUBDIRS_TARGETS)

create_all_subdirs: create_binary_components_subdirs
create_all_subdirs: create_integration_tests_subdirs
create_all_subdirs: create_apis_subdirs
create_all_subdirs: create_plugins_subdirs
create_all_subdirs: create_staging_subdirs

migrate_binary_components_to_polyrepo: $(KUBERNETES_BINARY_COMPONENTS_MIGRATE_TARGETS)
migrate_integration_tests_to_polyrepo: $(KUBERNETES_INTEGRATION_TESTS_MIGRATE_TARGETS)
migrate_apis_to_polyrepo: $(KUBERNETES_APIS_MIGRATE_TARGETS)
migrate_plugins_to_polyrepo: $(KUBERNETES_PLUGINS_MIGRATE_TARGETS)
migrate_staging_to_polyrepo: $(KUBERNETES_STAGING_MIGRATE_TARGETS)

migrate_all_to_polyrepo: migrate_binary_components_to_polyrepo
migrate_all_to_polyrepo: migrate_integration_tests_to_polyrepo
migrate_all_to_polyrepo: migrate_apis_to_polyrepo
migrate_all_to_polyrepo: migrate_plugins_to_polyrepo
migrate_all_to_polyrepo: migrate_staging_to_polyrepo

BINARY_COMPONENTS_RELATIVE_DIR := binary_components
INTEGRATION_TESTS_RELATIVE_DIR := integration_tests
APIS_RELATIVE_DIR              := apis
PLUGINS_RELATIVE_DIR           := plugins
STAGING_RELATIVE_DIR           := staging

POLYREPO_BINARY_COMPONENTS_DEST_ROOT_DIR := $(POLYREPO_DEST_ROOT_DIR)/$(BINARY_COMPONENTS_RELATIVE_DIR)
POLYREPO_INTEGRATION_TESTS_DEST_ROOT_DIR := $(POLYREPO_DEST_ROOT_DIR)/$(INTEGRATION_TESTS_RELATIVE_DIR)
POLYREPO_APIS_DEST_ROOT_DIR              := $(POLYREPO_DEST_ROOT_DIR)/$(APIS_RELATIVE_DIR)
POLYREPO_PLUGINS_DEST_ROOT_DIR           := $(POLYREPO_DEST_ROOT_DIR)/$(PLUGINS_RELATIVE_DIR)
POLYREPO_STAGING_DEST_ROOT_DIR           := $(POLYREPO_DEST_ROOT_DIR)/$(STAGING_RELATIVE_DIR)

clean:
	rm -rf $(POLYREPO_DEST_ROOT_DIR)

_create_binary_component_subdir_%:
	mkdir -p $(POLYREPO_BINARY_COMPONENTS_DEST_ROOT_DIR)/$(*)

_create_integration_test_subdir_%:
	mkdir -p $(POLYREPO_INTEGRATION_TESTS_DEST_ROOT_DIR)/$(*)

_create_api_subdir_%:
	mkdir -p $(POLYREPO_APIS_DEST_ROOT_DIR)/$(*)

_create_plugin_subdir_%:
	mkdir -p $(POLYREPO_PLUGINS_DEST_ROOT_DIR)/$(*)

_create_staging_subdir_%:
	mkdir -p $(POLYREPO_STAGING_DEST_ROOT_DIR)/$(*)

_migrate_binary_component_common_%:
	migrators/bar.sh $(KUBERNETES_REPO_ROOT_DIR) $($(*)_RELATIVE_SUBPATH) $(POLYREPO_BINARY_COMPONENTS_DEST_ROOT_DIR)/$(*)

_migrate_integration_test_common_%:
	migrators/bar.sh $(KUBERNETES_REPO_ROOT_DIR) test/integration/$(*) $(POLYREPO_INTEGRATION_TESTS_DEST_ROOT_DIR)/$(*)

_migrate_api_common_%:
	migrators/bar.sh $(KUBERNETES_REPO_ROOT_DIR) pkg/$(*) $(POLYREPO_APIS_DEST_ROOT_DIR)/$(*)

_migrate_plugin_common_%:
	migrators/bar.sh $(KUBERNETES_REPO_ROOT_DIR) plugin/pkg/$(*) $(POLYREPO_PLUGINS_DEST_ROOT_DIR)/$(*)

_migrate_staging_common_%:
	migrators/bar.sh $(KUBERNETES_REPO_ROOT_DIR) staging/src/k8s.io/$(*) $(POLYREPO_STAGING_DEST_ROOT_DIR)/$(*)

_migrate_binary_component_to_polyrepo_%: _create_binary_component_subdir_% _migrate_binary_component_common_%
	migrators/binary_components/$(*).sh \
		$(KUBERNETES_REPO_ROOT_DIR) \
		$($(*)_RELATIVE_SUBPATH) \
		$(POLYREPO_BINARY_COMPONENTS_DEST_ROOT_DIR)/$(*)

_migrate_integration_test_to_polyrepo_%: _create_integration_test_subdir_% _migrate_integration_test_common_%
	migrators/integration_tests/$(*).sh \
		$(KUBERNETES_REPO_ROOT_DIR) \
		test/integration/$(*) \
		$(POLYREPO_INTEGRATION_TESTS_DEST_ROOT_DIR)/$(*)

_migrate_api_to_polyrepo_%: _create_api_subdir_% _migrate_api_common_%
	migrators/apis/$(*).sh \
		$(KUBERNETES_REPO_ROOT_DIR) \
		pkg/$(*) \
		$(POLYREPO_APIS_DEST_ROOT_DIR)/$(*)

_migrate_plugin_to_polyrepo_%: _create_plugin_subdir_% _migrate_plugin_common_%
	migrators/plugins/$(*).sh \
		$(KUBERNETES_REPO_ROOT_DIR) \
		plugin/pkg/$(*) \
		$(POLYREPO_PLUGINS_DEST_ROOT_DIR)/$(*)

_migrate_staging_to_polyrepo_%: _create_staging_subdir_% _migrate_staging_common_%
	migrators/staging/$(*).sh \
		$(KUBERNETES_REPO_ROOT_DIR) \
		staging/src/k8s.io/$(*) \
		$(POLYREPO_STAGING_DEST_ROOT_DIR)/$(*)

KUBERNETES_BINARY_COMPONENTS_POLYREPO_ADJ_FILE_TARGETS := $(addprefix _construct_binary_component_polyrepo_adj_file_,$(KUBERNETES_BINARY_COMPONENTS))
KUBERNETES_INTEGRATION_TESTS_POLYREPO_ADJ_FILE_TARGETS := $(addprefix _construct_integration_test_polyrepo_adj_file_,$(KUBERNETES_INTEGRATION_TESTS))
KUBERNETES_APIS_POLYREPO_ADJ_FILE_TARGETS              := $(addprefix _construct_api_polyrepo_adj_file_,$(KUBERNETES_APIS))
KUBERNETES_PLUGINS_POLYREPO_ADJ_FILE_TARGETS           := $(addprefix _construct_plugin_polyrepo_adj_file_,$(KUBERNETES_PLUGINS))
KUBERNETES_STAGING_POLYREPO_ADJ_FILE_TARGETS           := $(addprefix _construct_staging_polyrepo_adj_file_,$(KUBERNETES_STAGING))

construct_binary_components_polyrepo_adj_files: $(KUBERNETES_BINARY_COMPONENTS_POLYREPO_ADJ_FILE_TARGETS)
construct_integration_tests_polyrepo_adj_files: $(KUBERNETES_INTEGRATION_TESTS_POLYREPO_ADJ_FILE_TARGETS)
construct_apis_polyrepo_adj_files: $(KUBERNETES_APIS_POLYREPO_ADJ_FILE_TARGETS)
construct_plugins_polyrepo_adj_files: $(KUBERNETES_PLUGINS_POLYREPO_ADJ_FILE_TARGETS)
construct_staging_polyrepo_adj_files: $(KUBERNETES_STAGING_POLYREPO_ADJ_FILE_TARGETS)

ADJ_FILE_NAME             := adj_file.txt
ADJ_FILE_MERGED_NAME      := adj_file_merged.txt
AGGR_ADJ_FILE_MERGED_NAME := aggr_adj_file_merged.txt

ADJ_FILE_MERGED_PATH      := $(POLYREPO_DEST_ROOT_DIR)/$(ADJ_FILE_MERGED_NAME)
AGGR_ADJ_FILE_MERGED_PATH := $(POLYREPO_DEST_ROOT_DIR)/$(AGGR_ADJ_FILE_MERGED_NAME)

_construct_binary_component_polyrepo_adj_file_%:
	./adj.sh $(POLYREPO_BINARY_COMPONENTS_DEST_ROOT_DIR)/$(*) $($(*)_RELATIVE_SUBPATH) $(ADJ_FILE_NAME)

_construct_integration_test_polyrepo_adj_file_%:
	./adj.sh $(POLYREPO_INTEGRATION_TESTS_DEST_ROOT_DIR)/$(*) test/integration/$(*) $(ADJ_FILE_NAME)

_construct_api_polyrepo_adj_file_%:
	./adj.sh $(POLYREPO_APIS_DEST_ROOT_DIR)/$(*) pkg/$(*) $(ADJ_FILE_NAME)

_construct_plugin_polyrepo_adj_file_%:
	./adj.sh $(POLYREPO_APIS_DEST_ROOT_DIR)/$(*) plugin/pkg/$(*) $(ADJ_FILE_NAME)

_construct_staging_polyrepo_adj_file_%:
	./adj.sh $(POLYREPO_APIS_DEST_ROOT_DIR)/$(*) staging/src/k8s.io/$(*) $(ADJ_FILE_NAME)

VENV_PATH := ./venv

construct_all_polyrepo_adj_files: construct_binary_components_polyrepo_adj_files construct_integration_tests_polyrepo_adj_files construct_apis_polyrepo_adj_files
	find $(POLYREPO_DEST_ROOT_DIR) -maxdepth 3 -name "$(ADJ_FILE_NAME)" | xargs cat | sort > $(ADJ_FILE_MERGED_PATH)
	$(VENV_PATH)/bin/python ./conv-adj.py $(ADJ_FILE_MERGED_PATH) $(AGGR_ADJ_FILE_MERGED_PATH)
