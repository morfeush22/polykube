import logging
import os
import sys

import networkx as x
import yaml

import filter_import_paths as fip

LOGLEVEL = os.environ.get('LOGLEVEL', 'WARNING').upper()
logging.basicConfig(level=LOGLEVEL)

_all = "all"


def generate_gocd_yaml_job(artifacts):
    return {
        "timeout": 0,
        "tasks": [
            {
                "exec": {
                    "arguments": [
                        "-c",
                        "make all"
                    ],
                    "command": "/bin/sh",
                    "run_if": "passed"
                }
            }
        ],
        "artifacts": artifacts
    }


def generate_gocd_yaml_artifact(artifact_name):
    return {
        "source": artifact_name
    }


def generate_gocd_yaml_stage(jobs):
    return {
        "fetch_materials": True,
        "keep_artifacts": False,
        "clean_workspace": False,
        "approval": {
            "type": "success",
            "allow_only_on_success": False
        },
        "jobs": jobs
    }


def generate_gocd_yaml_git_material(git_server_repo_path):
    return {
        "git": git_server_repo_path,
        "shallow_clone": False,
        "auto_update": True,
        "branch": "master"
    }


def generate_gocd_yaml_pipeline_material(pipeline, stage):
    return {
        "pipeline": pipeline,
        "stage": stage,
        "ignore_for_scheduling": False
    }


def generate_gocd_yaml_pipeline(group, materials, stages):
    return {
        "group": group,
        "label_template": "${COUNT}",
        "lock_behavior": None,
        "display_order": -1,
        "materials": materials,
        "stages": stages
    }


def generate_gocd_yaml(pipelines):
    return {
        "format_version": 10,
        "pipelines": pipelines
    }


def generate_binary_component_yaml_file(node, node_triggers_list, group, node_git_server_repo_path,
                                        binary_artifact_name):
    return generate_gocd_yaml(
        pipelines={
            node: generate_gocd_yaml_pipeline(
                group=group,
                materials={
                    node_git_server_repo_path: generate_gocd_yaml_git_material(
                        git_server_repo_path=node_git_server_repo_path
                    ),
                    **{
                        trigger: generate_gocd_yaml_pipeline_material(
                            pipeline=trigger,
                            stage=_all
                        ) for trigger in node_triggers_list
                    },
                },
                stages=[
                    {
                        _all: generate_gocd_yaml_stage(
                            jobs=generate_gocd_yaml_job(
                                artifacts=[
                                    {
                                        binary_artifact_name: generate_gocd_yaml_artifact(
                                            artifact_name=binary_artifact_name,
                                        ),
                                    }
                                ]
                            )
                        )
                    }
                ]
            )
        }
    )


def generate_integration_test_yaml_file(node, node_triggers_list, group, node_git_server_repo_path):
    return generate_gocd_yaml(
        pipelines={
            node: generate_gocd_yaml_pipeline(
                group=group,
                materials={
                    node_git_server_repo_path: generate_gocd_yaml_git_material(
                        git_server_repo_path=node_git_server_repo_path
                    ),
                    **{
                        trigger: generate_gocd_yaml_pipeline_material(
                            pipeline=trigger,
                            stage=_all
                        ) for trigger in node_triggers_list
                    },
                },
                stages=[
                    {
                        _all: generate_gocd_yaml_stage(
                            jobs=generate_gocd_yaml_job(
                                artifacts=[]
                            )
                        )
                    }
                ]
            )
        }
    )


def generate_api_yaml_file(node, node_triggers_list, group, node_git_server_repo_path):
    return generate_gocd_yaml(
        pipelines={
            node: generate_gocd_yaml_pipeline(
                group=group,
                materials={
                    node_git_server_repo_path: generate_gocd_yaml_git_material(
                        git_server_repo_path=node_git_server_repo_path
                    ),
                    **{
                        trigger: generate_gocd_yaml_pipeline_material(
                            pipeline=trigger,
                            stage=_all
                        ) for trigger in node_triggers_list
                    },
                },
                stages=[
                    {
                        _all: generate_gocd_yaml_stage(
                            jobs=generate_gocd_yaml_job(
                                artifacts=[]
                            )
                        )
                    }
                ]
            )
        }
    )


def generate_plugin_yaml_file(node, node_triggers_list, group, node_git_server_repo_path):
    return generate_gocd_yaml(
        pipelines={
            node: generate_gocd_yaml_pipeline(
                group=group,
                materials={
                    node_git_server_repo_path: generate_gocd_yaml_git_material(
                        git_server_repo_path=node_git_server_repo_path
                    ),
                    **{
                        trigger: generate_gocd_yaml_pipeline_material(
                            pipeline=trigger,
                            stage=_all
                        ) for trigger in node_triggers_list
                    },
                },
                stages=[
                    {
                        _all: generate_gocd_yaml_stage(
                            jobs=generate_gocd_yaml_job(
                                artifacts=[]
                            )
                        )
                    }
                ]
            )
        }
    )


def generate_staging_yaml_file(node, node_triggers_list, group, node_git_server_repo_path):
    return generate_gocd_yaml(
        pipelines={
            node: generate_gocd_yaml_pipeline(
                group=group,
                materials={
                    node_git_server_repo_path: generate_gocd_yaml_git_material(
                        git_server_repo_path=node_git_server_repo_path
                    ),
                    **{
                        trigger: generate_gocd_yaml_pipeline_material(
                            pipeline=trigger,
                            stage=_all
                        ) for trigger in node_triggers_list
                    },
                },
                stages=[
                    {
                        _all: generate_gocd_yaml_stage(
                            jobs=generate_gocd_yaml_job(
                                artifacts=[]
                            )
                        )
                    }
                ]
            )
        }
    )


def get_binary_artifact_name_from_node_name(node):
    return node.split("/")[-1]


def construct_node_gocd_file_name(node):
    return node.replace("/", "_")


def generate_gocd_yaml_file(node, node_triggers, node_type, node_git_server_repo_path, gocd_yamls_dest_root_dir):
    node_gocd_yaml_dest_path = f"{gocd_yamls_dest_root_dir}/{construct_node_gocd_file_name(node)}.yaml"

    node_triggers_list = []

    for node_trigger in node_triggers:
        node_triggers_list.append(node_trigger)

    group = f"POLYREPO_{node_type}"

    config = None

    if node_type == fip.BINARY_COMPONENT:
        binary_artifact_name = get_binary_artifact_name_from_node_name(node)
        config = generate_binary_component_yaml_file(node, node_triggers_list, group, node_git_server_repo_path,
                                                     binary_artifact_name)
    elif node_type == fip.INTEGRATION_TEST:
        config = generate_integration_test_yaml_file(node, node_triggers_list, group, node_git_server_repo_path)
    elif node_type == fip.API:
        config = generate_api_yaml_file(node, node_triggers_list, group, node_git_server_repo_path)
    elif node_type == fip.PLUGIN:
        config = generate_plugin_yaml_file(node, node_triggers_list, group, node_git_server_repo_path)
    elif node_type == fip.STAGING:
        config = generate_staging_yaml_file(node, node_triggers_list, group, node_git_server_repo_path)

    if config is not None:
        with open(node_gocd_yaml_dest_path, 'w') as gocd_yaml_file:
            yaml.dump(config, gocd_yaml_file)
    else:
        logging.warning(f"could not determine node type and config for {node}")


def generate_gocd_yaml_files(filtered_aggr_adj_file_merged_path, node_type_to_relative_dir, git_server_repos_prefix,
                             gocd_yamls_dest_root_dir):
    deps_graph = x.read_edgelist(filtered_aggr_adj_file_merged_path, create_using=x.DiGraph)

    # we need list of deps that should trigger that node
    reversed_deps_graph = deps_graph.reverse()

    for node in reversed_deps_graph.nodes():
        node_triggers = x.neighbors(reversed_deps_graph, node)

        node_type, node_subdir = fip.infer_type_and_subdir(node)

        node_git_server_repo_path = f"{git_server_repos_prefix}/{node_type_to_relative_dir[node_type]}/{node_subdir}"

        generate_gocd_yaml_file(node, node_triggers, node_type, node_git_server_repo_path, gocd_yamls_dest_root_dir)


def main():
    polyrepo_binary_components_relative_dir = sys.argv[1]
    polyrepo_integration_tests_relative_dir = sys.argv[2]
    polyrepo_apis_relative_dir = sys.argv[3]
    polyrepo_plugins_relative_dir = sys.argv[4]
    polyrepo_staging_relative_dir = sys.argv[5]
    filtered_aggr_adj_file_merged_path = sys.argv[6]
    git_server_repos_prefix = sys.argv[7]
    gocd_yamls_dest_root_dir = sys.argv[8]

    node_type_to_relative_dir = {
        fip.BINARY_COMPONENT: polyrepo_binary_components_relative_dir,
        fip.INTEGRATION_TEST: polyrepo_integration_tests_relative_dir,
        fip.API: polyrepo_apis_relative_dir,
        fip.PLUGIN: polyrepo_plugins_relative_dir,
        fip.STAGING: polyrepo_staging_relative_dir
    }

    generate_gocd_yaml_files(filtered_aggr_adj_file_merged_path, node_type_to_relative_dir, git_server_repos_prefix,
                             gocd_yamls_dest_root_dir)


if __name__ == '__main__':
    main()
