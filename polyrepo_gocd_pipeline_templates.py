_all = "all"
_pre_arguments = "set -a; eval `go env`; set +a;"

_common_env_name = "common"
_e2e_cluster_env_name = "e2e_cluster"

artifacts_dir_name = "_artifacts"

polyrepo_e2e_cluster_pipeline_name = "polyrepo_e2e_cluster_pipeline"
polyrepo_e2e_cmd_pipeline_name = "polyrepo_e2e_cmd_pipeline"


def generate_gocd_yaml_common_job(artifacts):
    return {
        "timeout": 0,
        "tasks": [
            {
                "exec": {
                    "arguments": [
                        "-c",
                        f"{_pre_arguments} make all"
                    ],
                    "command": "/bin/bash",
                    "run_if": "passed"
                }
            }
        ],
        "artifacts": artifacts
    }


def generate_binary_component_gocd_yaml_job(artifacts):
    return {
        "timeout": 0,
        "tasks": [
            {
                "exec": {
                    "arguments": [
                        "-c",
                        f"{_pre_arguments} make build"
                    ],
                    "command": "/bin/bash",
                    "run_if": "passed"
                }
            },
            {
                "exec": {
                    "arguments": [
                        "-c",
                        f"{_pre_arguments} make tests"
                    ],
                    "command": "/bin/bash",
                    "run_if": "passed"
                }
            }
        ],
        "artifacts": artifacts
    }


def generate_integration_test_gocd_yaml_job():
    return {
        "timeout": 0,
        "tasks": [
            {
                "exec": {
                    "arguments": [
                        "-c",
                        f"{_pre_arguments} make setup"
                    ],
                    "command": "/bin/bash",
                    "run_if": "passed"
                }
            },
            {
                "exec": {
                    "arguments": [
                        "-c",
                        f"{_pre_arguments} make all"
                    ],
                    "command": "/bin/bash",
                    "run_if": "passed"
                }
            },
            {
                "exec": {
                    "arguments": [
                        "-c",
                        f"{_pre_arguments} make teardown"
                    ],
                    "command": "/bin/bash",
                    "run_if": "any"
                }
            },
        ],
    }


def generate_api_gocd_yaml_job():
    return generate_gocd_yaml_common_job([])


def generate_plugin_gocd_yaml_job():
    return generate_gocd_yaml_common_job([])


def generate_staging_gocd_yaml_job():
    return generate_gocd_yaml_common_job([])


def generate_gocd_yaml_fetch(pipeline, source, destination):
    return {
        "pipeline": pipeline,
        "stage": _all,
        "job": _all,
        "is_file": True,
        "source": source,
        "destination": destination
    }


def generate_e2e_cluster_test_gocd_yaml_job(fetch_artifacts_list):
    return {
        "timeout": 0,
        "tasks": [
            *[
                {
                    "fetch": generate_gocd_yaml_fetch(
                        pipeline=artifact["pipeline"],
                        source=artifact["source"],
                        destination=artifact["destination"]
                    )
                } for artifact in fetch_artifacts_list
            ],
            {
                "exec": {
                    "arguments": [
                        "-c",
                        f"{_pre_arguments} make bootstrap"
                    ],
                    "command": "/bin/bash",
                    "run_if": "passed"
                }
            },
            {
                "exec": {
                    "arguments": [
                        "-c",
                        f"{_pre_arguments} make setup"
                    ],
                    "command": "/bin/bash",
                    "run_if": "passed"
                }
            },
            {
                "exec": {
                    "arguments": [
                        "-c",
                        f"{_pre_arguments} make cluster"
                    ],
                    "command": "/bin/bash",
                    "run_if": "passed"
                }
            },
            {
                "exec": {
                    "arguments": [
                        "-c",
                        f"{_pre_arguments} make teardown"
                    ],
                    "command": "/bin/bash",
                    "run_if": "any"
                }
            },
        ],
    }


def generate_e2e_cmd_test_gocd_yaml_job(fetch_artifacts_list):
    return {
        "timeout": 0,
        "tasks": [
            *[
                {
                    "fetch": generate_gocd_yaml_fetch(
                        pipeline=artifact["pipeline"],
                        source=artifact["source"],
                        destination=artifact["destination"]
                    )
                } for artifact in fetch_artifacts_list
            ],
            {
                "exec": {
                    "arguments": [
                        "-c",
                        f"{_pre_arguments} make bootstrap"
                    ],
                    "command": "/bin/bash",
                    "run_if": "passed"
                }
            },
            {
                "exec": {
                    "arguments": [
                        "-c",
                        f"{_pre_arguments} make cmd"
                    ],
                    "command": "/bin/bash",
                    "run_if": "passed"
                }
            }
        ],
    }


def generate_gocd_yaml_build_artifact(artifact_name):
    return {
        "build": {
            "source": artifact_name
        }
    }


def generate_gocd_yaml_stage(jobs):
    return {
        "fetch_materials": True,
        "keep_artifacts": False,
        "clean_workspace": True,
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


def generate_gocd_yaml_pipeline(group, materials, stages, environment_variables):
    return {
        "group": group,
        "label_template": "${COUNT}",
        "lock_behavior": "none",
        "display_order": -1,
        "materials": materials,
        "stages": stages,
        "environment_variables": environment_variables
    }


def generate_gocd_yaml_environment(pipeline):
    return {
        "pipelines": [
            pipeline
        ]
    }


def generate_gocd_yaml(pipelines, environments):
    return {
        "format_version": 10,
        "pipelines": pipelines,
        "environments": environments
    }


def generate_binary_component_yaml_file(node_pipeline_name, node_pipeline_triggers_list, group, node_material_name,
                                        node_git_server_repo_path, binary_artifact_name):
    return generate_gocd_yaml(
        pipelines={
            node_pipeline_name: generate_gocd_yaml_pipeline(
                group=group,
                materials={
                    node_material_name: generate_gocd_yaml_git_material(
                        git_server_repo_path=node_git_server_repo_path
                    ),
                    **{
                        trigger: generate_gocd_yaml_pipeline_material(
                            pipeline=trigger,
                            stage=_all
                        ) for trigger in node_pipeline_triggers_list
                    },
                },
                stages=[
                    {
                        _all: generate_gocd_yaml_stage(
                            jobs={
                                _all: generate_binary_component_gocd_yaml_job(
                                    artifacts=[
                                        generate_gocd_yaml_build_artifact(
                                            artifact_name=binary_artifact_name,
                                        ),
                                    ]
                                )
                            }
                        )
                    }
                ],
                environment_variables={
                    "MATERIAL_NAME": node_material_name
                }
            )
        },
        environments={
            _common_env_name: generate_gocd_yaml_environment(node_pipeline_name)
        }
    )


def generate_integration_test_yaml_file(node_pipeline_name, node_pipeline_triggers_list, group, node_material_name,
                                        node_git_server_repo_path):
    return generate_gocd_yaml(
        pipelines={
            node_pipeline_name: generate_gocd_yaml_pipeline(
                group=group,
                materials={
                    node_material_name: generate_gocd_yaml_git_material(
                        git_server_repo_path=node_git_server_repo_path
                    ),
                    **{
                        trigger: generate_gocd_yaml_pipeline_material(
                            pipeline=trigger,
                            stage=_all
                        ) for trigger in node_pipeline_triggers_list
                    },
                },
                stages=[
                    {
                        _all: generate_gocd_yaml_stage(
                            jobs={
                                _all: generate_integration_test_gocd_yaml_job()
                            }
                        )
                    }
                ],
                environment_variables={
                    "MATERIAL_NAME": node_material_name
                }

            )
        },
        environments={
            _common_env_name: generate_gocd_yaml_environment(node_pipeline_name)
        }
    )


def generate_api_yaml_file(node_pipeline_name, node_pipeline_triggers_list, group, node_material_name,
                           node_git_server_repo_path):
    return generate_gocd_yaml(
        pipelines={
            node_pipeline_name: generate_gocd_yaml_pipeline(
                group=group,
                materials={
                    node_material_name: generate_gocd_yaml_git_material(
                        git_server_repo_path=node_git_server_repo_path
                    ),
                    **{
                        trigger: generate_gocd_yaml_pipeline_material(
                            pipeline=trigger,
                            stage=_all
                        ) for trigger in node_pipeline_triggers_list
                    },
                },
                stages=[
                    {
                        _all: generate_gocd_yaml_stage(
                            jobs={
                                _all: generate_api_gocd_yaml_job()
                            }
                        )
                    }
                ],
                environment_variables={
                    "MATERIAL_NAME": node_material_name
                }
            )
        },
        environments={
            _common_env_name: generate_gocd_yaml_environment(node_pipeline_name)
        }
    )


def generate_plugin_yaml_file(node_pipeline_name, node_pipeline_triggers_list, group, node_material_name,
                              node_git_server_repo_path):
    return generate_gocd_yaml(
        pipelines={
            node_pipeline_name: generate_gocd_yaml_pipeline(
                group=group,
                materials={
                    node_material_name: generate_gocd_yaml_git_material(
                        git_server_repo_path=node_git_server_repo_path
                    ),
                    **{
                        trigger: generate_gocd_yaml_pipeline_material(
                            pipeline=trigger,
                            stage=_all
                        ) for trigger in node_pipeline_triggers_list
                    },
                },
                stages=[
                    {
                        _all: generate_gocd_yaml_stage(
                            jobs={
                                _all: generate_plugin_gocd_yaml_job()
                            }
                        )
                    }
                ],
                environment_variables={
                    "MATERIAL_NAME": node_material_name
                }
            )
        },
        environments={
            _common_env_name: generate_gocd_yaml_environment(node_pipeline_name)
        }
    )


def generate_staging_yaml_file(node_pipeline_name, node_pipeline_triggers_list, group, node_material_name,
                               node_git_server_repo_path):
    return generate_gocd_yaml(
        pipelines={
            node_pipeline_name: generate_gocd_yaml_pipeline(
                group=group,
                materials={
                    node_material_name: generate_gocd_yaml_git_material(
                        git_server_repo_path=node_git_server_repo_path
                    ),
                    **{
                        trigger: generate_gocd_yaml_pipeline_material(
                            pipeline=trigger,
                            stage=_all
                        ) for trigger in node_pipeline_triggers_list
                    },
                },
                stages=[
                    {
                        _all: generate_gocd_yaml_stage(
                            jobs={
                                _all: generate_staging_gocd_yaml_job()
                            }
                        )
                    }
                ],
                environment_variables={
                    "MATERIAL_NAME": node_material_name
                }
            )
        },
        environments={
            _common_env_name: generate_gocd_yaml_environment(node_pipeline_name)
        }
    )


def generate_e2e_test_cluster_yaml_file(node_pipeline_triggers_list, group, node_git_server_repo_path,
                                        fetch_artifacts_list):
    return generate_gocd_yaml(
        pipelines={
            polyrepo_e2e_cluster_pipeline_name: generate_gocd_yaml_pipeline(
                group=group,
                materials={
                    polyrepo_e2e_cluster_pipeline_name: generate_gocd_yaml_git_material(
                        git_server_repo_path=node_git_server_repo_path
                    ),
                    **{
                        trigger: generate_gocd_yaml_pipeline_material(
                            pipeline=trigger,
                            stage=_all
                        ) for trigger in node_pipeline_triggers_list
                    },
                },
                stages=[
                    {
                        _all: generate_gocd_yaml_stage(
                            jobs={
                                _all: generate_e2e_cluster_test_gocd_yaml_job(
                                    fetch_artifacts_list=fetch_artifacts_list
                                )
                            }
                        )
                    }
                ],
                environment_variables={
                    "MATERIAL_NAME": polyrepo_e2e_cluster_pipeline_name,
                    "ARTIFACTS_DIR": artifacts_dir_name
                }

            )
        },
        environments={
            _e2e_cluster_env_name: generate_gocd_yaml_environment(polyrepo_e2e_cluster_pipeline_name)
        }
    )


def generate_e2e_test_cmd_yaml_file(node_pipeline_triggers_list, group, node_git_server_repo_path,
                                    fetch_artifacts_list):
    return generate_gocd_yaml(
        pipelines={
            polyrepo_e2e_cmd_pipeline_name: generate_gocd_yaml_pipeline(
                group=group,
                materials={
                    polyrepo_e2e_cmd_pipeline_name: generate_gocd_yaml_git_material(
                        git_server_repo_path=node_git_server_repo_path
                    ),
                    **{
                        trigger: generate_gocd_yaml_pipeline_material(
                            pipeline=trigger,
                            stage=_all
                        ) for trigger in node_pipeline_triggers_list
                    },
                },
                stages=[
                    {
                        _all: generate_gocd_yaml_stage(
                            jobs={
                                _all: generate_e2e_cmd_test_gocd_yaml_job(
                                    fetch_artifacts_list=fetch_artifacts_list
                                )
                            }
                        )
                    }
                ],
                environment_variables={
                    "MATERIAL_NAME": polyrepo_e2e_cmd_pipeline_name,
                    "ARTIFACTS_DIR": artifacts_dir_name
                }

            )
        },
        environments={
            _common_env_name: generate_gocd_yaml_environment(polyrepo_e2e_cmd_pipeline_name)
        }
    )
