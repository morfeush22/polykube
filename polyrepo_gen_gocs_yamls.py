import logging
import os
import sys

import networkx as x
import yaml

import polyrepo_filter_import_paths as fip
from polyrepo_gocd_pipeline_templates import generate_binary_component_yaml_file, generate_integration_test_yaml_file, \
    generate_api_yaml_file, generate_plugin_yaml_file, generate_staging_yaml_file, e2e_cluster_pipeline_name, \
    e2e_cmd_pipeline_name, generate_e2e_test_cluster_yaml_file, generate_e2e_test_cmd_yaml_file, artifacts_dir_name

LOGLEVEL = os.environ.get('LOGLEVEL', 'WARNING').upper()
logging.basicConfig(level=LOGLEVEL)


# these cycles are present in graph, but they are harmless
# during traversal, we still want to visit them
def known_harmless_cycles():
    return [
        ('k8s.io/kubernetes/pkg/api', 'k8s.io/kubernetes/pkg/apis'),
        ('k8s.io/kubernetes/pkg/api', 'k8s.io/kubernetes/pkg/kubelet'),
        ('k8s.io/kubernetes/pkg/api', 'k8s.io/kubernetes/pkg/security'),
        ('k8s.io/kubernetes/pkg/api', 'k8s.io/kubernetes/pkg/util'),
        ('k8s.io/kubernetes/pkg/apis', 'k8s.io/kubernetes/pkg/kubelet'),
        ('k8s.io/kubernetes/pkg/apis', 'k8s.io/kubernetes/pkg/security'),
        ('k8s.io/kubernetes/pkg/apis', 'k8s.io/kubernetes/pkg/util'),
        ('k8s.io/kubernetes/pkg/controller', 'k8s.io/kubernetes/pkg/controlplane'),
        ('k8s.io/kubernetes/pkg/controller', 'k8s.io/kubernetes/pkg/kubeapiserver'),
        ('k8s.io/kubernetes/pkg/kubelet', 'k8s.io/kubernetes/pkg/credentialprovider'),
        ('k8s.io/kubernetes/pkg/kubelet', 'k8s.io/kubernetes/pkg/probe'),
        ('k8s.io/kubernetes/pkg/kubelet', 'k8s.io/kubernetes/pkg/proxy'),
        ('k8s.io/kubernetes/pkg/controller', 'k8s.io/kubernetes/pkg/kubelet'),
        ('k8s.io/kubernetes/pkg/controller', 'k8s.io/kubernetes/pkg/printers'),
        ('k8s.io/kubernetes/pkg/controller', 'k8s.io/kubernetes/pkg/probe'),
        ('k8s.io/kubernetes/pkg/controller', 'k8s.io/kubernetes/pkg/proxy'),
        ('k8s.io/kubernetes/pkg/controller', 'k8s.io/kubernetes/pkg/quota'),
        ('k8s.io/kubernetes/pkg/controller', 'k8s.io/kubernetes/pkg/registry'),
        ('k8s.io/kubernetes/pkg/controller', 'k8s.io/kubernetes/pkg/scheduler'),
        ('k8s.io/kubernetes/pkg/controller', 'k8s.io/kubernetes/pkg/security'),
        ('k8s.io/kubernetes/pkg/controller', 'k8s.io/kubernetes/pkg/serviceaccount'),
        ('k8s.io/kubernetes/pkg/controller', 'k8s.io/kubernetes/pkg/util'),
        ('k8s.io/kubernetes/pkg/controller', 'k8s.io/kubernetes/pkg/volume'),
        ('k8s.io/kubernetes/pkg/controller', 'k8s.io/kubernetes/plugin/pkg/admission'),
        ('k8s.io/kubernetes/pkg/controller', 'k8s.io/kubernetes/plugin/pkg/auth'),
        ('k8s.io/kubernetes/pkg/kubelet', 'k8s.io/kubernetes/pkg/scheduler'),
        ('k8s.io/kubernetes/pkg/kubelet', 'k8s.io/kubernetes/pkg/security'),
        ('k8s.io/kubernetes/pkg/kubelet', 'k8s.io/kubernetes/pkg/util'),
        ('k8s.io/kubernetes/pkg/kubelet', 'k8s.io/kubernetes/pkg/volume'),
        ('k8s.io/kubernetes/pkg/kubeapiserver', 'k8s.io/kubernetes/pkg/proxy'),
        ('k8s.io/kubernetes/pkg/kubeapiserver', 'k8s.io/kubernetes/pkg/quota'),
        ('k8s.io/kubernetes/pkg/kubeapiserver', 'k8s.io/kubernetes/pkg/registry'),
        ('k8s.io/kubernetes/pkg/kubeapiserver', 'k8s.io/kubernetes/pkg/security'),
        ('k8s.io/kubernetes/pkg/kubeapiserver', 'k8s.io/kubernetes/pkg/serviceaccount'),
        ('k8s.io/kubernetes/pkg/kubeapiserver', 'k8s.io/kubernetes/pkg/util'),
        ('k8s.io/kubernetes/pkg/kubeapiserver', 'k8s.io/kubernetes/pkg/volume'),
        ('k8s.io/kubernetes/pkg/kubeapiserver', 'k8s.io/kubernetes/plugin/pkg/admission'),
        ('k8s.io/kubernetes/pkg/kubeapiserver', 'k8s.io/kubernetes/plugin/pkg/auth'),
        ('k8s.io/kubernetes/pkg/printers', 'k8s.io/kubernetes/pkg/util'),
        ('k8s.io/kubernetes/pkg/proxy', 'k8s.io/kubernetes/pkg/security'),
        ('k8s.io/kubernetes/pkg/proxy', 'k8s.io/kubernetes/pkg/util'),
        ('k8s.io/kubernetes/pkg/security', 'k8s.io/kubernetes/pkg/serviceaccount'),
        ('k8s.io/kubernetes/pkg/util', 'k8s.io/kubernetes/pkg/security'),
        ('k8s.io/kubernetes/pkg/registry', 'k8s.io/kubernetes/pkg/scheduler'),
        ('k8s.io/kubernetes/pkg/registry', 'k8s.io/kubernetes/pkg/security'),
        ('k8s.io/kubernetes/pkg/registry', 'k8s.io/kubernetes/pkg/serviceaccount'),
        ('k8s.io/kubernetes/pkg/registry', 'k8s.io/kubernetes/pkg/volume'),
        ('k8s.io/kubernetes/pkg/registry', 'k8s.io/kubernetes/plugin/pkg/auth'),
        ('k8s.io/kubernetes/pkg/security', 'k8s.io/kubernetes/plugin/pkg/admission'),
        ('k8s.io/kubernetes/pkg/scheduler', 'k8s.io/kubernetes/pkg/volume')
    ]


# not used, we only trigger in integration tests, so no cycles
def remove_unwanted_cycles(graph):
    unwanted_cycles = [
        ('k8s.io/apiextensions-apiserver', 'k8s.io/apiextensions-apiserver/test/integration'),
        # *known_harmless_cycles()
    ]

    for cycle in unwanted_cycles:
        graph.remove_edge(*cycle)


def escape_node_forbidden_chars(node):
    return node.replace("/", "_").replace(".", "_").replace("-", "_")


def construct_node_pipeline_name(node):
    return f"{escape_node_forbidden_chars(node)}_pipeline"


def construct_node_material_name(node):
    return f"{escape_node_forbidden_chars(node)}_material"


def get_binary_artifact_name_from_node_name(node):
    return node.split("/")[-1]


def generate_gocd_yaml_file(node, node_triggers, node_type, node_git_server_repo_path, gocd_yamls_dest_root_dir):
    node_pipeline_name = construct_node_pipeline_name(node)
    node_material_name = construct_node_material_name(node)

    node_gocd_yaml_dest_path = f"{gocd_yamls_dest_root_dir}/{node_pipeline_name}.yaml"

    node_pipeline_triggers_list = []

    for node_trigger in node_triggers:
        node_trigger_pipeline_name = construct_node_pipeline_name(node_trigger)
        node_pipeline_triggers_list.append(node_trigger_pipeline_name)

    group = f"POLYREPO_{node_type}"

    config = None

    if node_type == fip.API:
        config = generate_api_yaml_file(node_pipeline_name, node_pipeline_triggers_list, group, node_material_name,
                                        node_git_server_repo_path)
    elif node_type == fip.BINARY_COMPONENT:
        binary_artifact_name = get_binary_artifact_name_from_node_name(node)
        config = generate_binary_component_yaml_file(node_pipeline_name, node_pipeline_triggers_list, group,
                                                     node_material_name,
                                                     node_git_server_repo_path, binary_artifact_name)
    elif node_type == fip.INTEGRATION_TEST:
        config = generate_integration_test_yaml_file(node_pipeline_name, node_pipeline_triggers_list, group,
                                                     node_material_name,
                                                     node_git_server_repo_path)
    elif node_type == fip.PLUGIN:
        config = generate_plugin_yaml_file(node_pipeline_name, node_pipeline_triggers_list, group, node_material_name,
                                           node_git_server_repo_path)
    elif node_type == fip.STAGING:
        config = generate_staging_yaml_file(node_pipeline_name, node_pipeline_triggers_list, group, node_material_name,
                                            node_git_server_repo_path)

    if config is not None:
        with open(node_gocd_yaml_dest_path, 'w') as gocd_yaml_file:
            yaml.dump(config, gocd_yaml_file)
    else:
        logging.warning(f"could not determine node type and config for {node}")


def generate_repo_path(git_server_repos_prefix, node_type, name):
    return f"{git_server_repos_prefix}/polyrepo/{node_type}/{name}.git"


def generate_gocd_yaml_mounter_file(node_type_to_relative_dir, git_server_repos_prefix, gocd_yamls_dest_root_dir):
    mounter_node = "k8s.io/kubernetes/cluster/gce/gci/mounter"

    node_type, node_subdir = fip.infer_type_and_subdir(mounter_node)

    node_git_server_repo_path = generate_repo_path(git_server_repos_prefix, node_type_to_relative_dir[node_type],
                                                   node_subdir)

    generate_gocd_yaml_file(mounter_node, [], node_type, node_git_server_repo_path, gocd_yamls_dest_root_dir)


def generate_gocd_yaml_e2e_tests_files(e2e_cluster_test_node_triggers, e2e_cmd_test_node_triggers,
                                       node_type_to_relative_dir,
                                       git_server_repos_prefix,
                                       gocd_yamls_dest_root_dir):
    e2e_cluster_test_pipeline_name = e2e_cluster_pipeline_name
    e2e_cmd_test_pipeline_name = e2e_cmd_pipeline_name

    e2e_cluster_test_gocd_yaml_dest_path = f"{gocd_yamls_dest_root_dir}/{e2e_cluster_test_pipeline_name}.yaml"
    e2e_cmd_test_gocd_yaml_dest_path = f"{gocd_yamls_dest_root_dir}/{e2e_cmd_test_pipeline_name}.yaml"

    e2e_cluster_test_triggers_list = []
    e2e_cmd_test_triggers_list = []

    e2e_cluster_test_fetch_artifacts_list = []
    e2e_cmd_test_fetch_artifacts_list = []

    for node_trigger in e2e_cluster_test_node_triggers:
        node_trigger_pipeline_name = construct_node_pipeline_name(node_trigger)
        e2e_cluster_test_triggers_list.append(node_trigger_pipeline_name)

        binary_artifact_name = get_binary_artifact_name_from_node_name(node_trigger)

        e2e_cluster_test_fetch_artifacts_list.append({
            "pipeline": node_trigger_pipeline_name,
            "source": binary_artifact_name,
            "destination": f"{artifacts_dir_name}/{binary_artifact_name}",
        })

    for node_trigger in e2e_cmd_test_node_triggers:
        node_trigger_pipeline_name = construct_node_pipeline_name(node_trigger)
        e2e_cmd_test_triggers_list.append(node_trigger_pipeline_name)

        binary_artifact_name = get_binary_artifact_name_from_node_name(node_trigger)

        e2e_cmd_test_fetch_artifacts_list.append({
            "pipeline": node_trigger_pipeline_name,
            "source": binary_artifact_name,
            "destination": f"{artifacts_dir_name}/{binary_artifact_name}",
        })

    group = f"POLYREPO_E2E"

    e2e_cluster_test_node_git_server_repo_path = generate_repo_path(git_server_repos_prefix,
                                                                    node_type_to_relative_dir[fip.E2E_TEST], "cluster")

    e2e_cmd_test_node_git_server_repo_path = generate_repo_path(git_server_repos_prefix,
                                                                node_type_to_relative_dir[fip.E2E_TEST], "cmd")

    e2e_cluster_test_config = generate_e2e_test_cluster_yaml_file(e2e_cluster_test_triggers_list, group,
                                                                  e2e_cluster_test_node_git_server_repo_path,
                                                                  e2e_cluster_test_fetch_artifacts_list)

    e2e_cmd_test_config = generate_e2e_test_cmd_yaml_file(e2e_cmd_test_triggers_list, group,
                                                          e2e_cmd_test_node_git_server_repo_path,
                                                          e2e_cmd_test_fetch_artifacts_list)

    with open(e2e_cluster_test_gocd_yaml_dest_path, 'w') as gocd_yaml_file:
        yaml.dump(e2e_cluster_test_config, gocd_yaml_file)

    with open(e2e_cmd_test_gocd_yaml_dest_path, 'w') as gocd_yaml_file:
        yaml.dump(e2e_cmd_test_config, gocd_yaml_file)


def generate_gocd_yaml_files(filtered_aggr_adj_file_merged_path, node_type_to_relative_dir, git_server_repos_prefix,
                             gocd_yamls_dest_root_dir):
    deps_graph = x.read_edgelist(filtered_aggr_adj_file_merged_path, create_using=x.DiGraph)

    # we need list of deps that should trigger that node
    target_deps_graph = deps_graph

    apis_nodes = []
    binary_component_nodes = []
    # this is handled separately
    # e2e_tests_nodes = []
    integration_tests_nodes = []
    plugins_nodes = []
    stating_nodes = []

    for node in target_deps_graph.nodes():
        node_type, _ = fip.infer_type_and_subdir(node)
        if node_type == fip.API:
            apis_nodes.append(node)
        elif node_type == fip.BINARY_COMPONENT:
            binary_component_nodes.append(node)
        elif node_type == fip.INTEGRATION_TEST:
            integration_tests_nodes.append(node)
        elif node_type == fip.PLUGIN:
            plugins_nodes.append(node)
        elif node_type == fip.STAGING:
            stating_nodes.append(node)
        else:
            logging.warning(f"unrecognized node: {node}")

    triggering_integration_tests_nodes = integration_tests_nodes
    untriggering_nodes = binary_component_nodes + apis_nodes + plugins_nodes + stating_nodes

    for node in triggering_integration_tests_nodes:
        node_triggers = x.neighbors(target_deps_graph, node)
        node_type, node_subdir = fip.infer_type_and_subdir(node)
        node_git_server_repo_path = generate_repo_path(git_server_repos_prefix, node_type_to_relative_dir[node_type],
                                                       node_subdir)

        generate_gocd_yaml_file(node, node_triggers, node_type, node_git_server_repo_path, gocd_yamls_dest_root_dir)

    for node in untriggering_nodes:
        node_type, node_subdir = fip.infer_type_and_subdir(node)
        node_git_server_repo_path = generate_repo_path(git_server_repos_prefix, node_type_to_relative_dir[node_type],
                                                       node_subdir)

        generate_gocd_yaml_file(node, [], node_type, node_git_server_repo_path,
                                gocd_yamls_dest_root_dir)

    # out-of-band
    generate_gocd_yaml_mounter_file(node_type_to_relative_dir, git_server_repos_prefix, gocd_yamls_dest_root_dir)

    e2e_cluster_test_node_triggers = [
        "k8s.io/kubernetes/cmd/kubeadm",
        "k8s.io/kubernetes/cmd/kubelet",
        "k8s.io/kubernetes/cmd/kubectl",
        "k8s.io/kubernetes/cmd/kube-apiserver",
        "k8s.io/kubernetes/cmd/kube-controller-manager",
        "k8s.io/kubernetes/cmd/kube-proxy",
        "k8s.io/kubernetes/cmd/kube-scheduler"
    ]

    e2e_cmd_test_triggers_list = [
        "k8s.io/kubernetes/cmd/kubectl",
        "k8s.io/kubernetes/cmd/kube-apiserver",
        "k8s.io/kubernetes/cmd/kube-controller-manager"
    ]

    generate_gocd_yaml_e2e_tests_files(e2e_cluster_test_node_triggers, e2e_cmd_test_triggers_list,
                                       node_type_to_relative_dir,
                                       git_server_repos_prefix,
                                       gocd_yamls_dest_root_dir)


def main():
    polyrepo_binary_components_relative_dir = sys.argv[1]
    polyrepo_integration_tests_relative_dir = sys.argv[2]
    polyrepo_apis_relative_dir = sys.argv[3]
    polyrepo_plugins_relative_dir = sys.argv[4]
    polyrepo_staging_relative_dir = sys.argv[5]
    polyrepo_e2e_tests_relative_dir = sys.argv[6]
    filtered_aggr_adj_file_merged_path = sys.argv[7]
    git_server_repos_prefix = sys.argv[8]
    gocd_yamls_dest_root_dir = sys.argv[9]

    node_type_to_relative_dir = {
        fip.BINARY_COMPONENT: polyrepo_binary_components_relative_dir,
        fip.INTEGRATION_TEST: polyrepo_integration_tests_relative_dir,
        fip.API: polyrepo_apis_relative_dir,
        fip.PLUGIN: polyrepo_plugins_relative_dir,
        fip.STAGING: polyrepo_staging_relative_dir,
        fip.E2E_TEST: polyrepo_e2e_tests_relative_dir,
    }

    generate_gocd_yaml_files(filtered_aggr_adj_file_merged_path, node_type_to_relative_dir, git_server_repos_prefix,
                             gocd_yamls_dest_root_dir)


if __name__ == '__main__':
    main()
