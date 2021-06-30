import logging
import os
import re
import sys

LOGLEVEL = os.environ.get('LOGLEVEL', 'WARNING').upper()
logging.basicConfig(level=LOGLEVEL)

BINARY_COMPONENT = "BINARY_COMPONENT"
INTEGRATION_TEST = "INTEGRATION_TEST"
API = "API"
PLUGIN = "PLUGIN"
STAGING = "STAGING"


def infer_type_and_subdir(import_path):
    kubernetes_repo_import_path = "k8s.io/kubernetes"

    binary_components_import_path = f"{kubernetes_repo_import_path}/cmd"
    integration_tests_import_path = f"{kubernetes_repo_import_path}/test/integration"
    apis_import_path = f"{kubernetes_repo_import_path}/pkg"
    plugins_import_path = f"{kubernetes_repo_import_path}/plugin/pkg"
    staging_import_path = "k8s.io"

    if import_path.startswith(binary_components_import_path):
        return BINARY_COMPONENT, import_path.removeprefix(f"{binary_components_import_path}/")
    elif import_path.startswith(integration_tests_import_path):
        return INTEGRATION_TEST, import_path.removeprefix(f"{integration_tests_import_path}/")
    elif import_path.startswith(apis_import_path):
        return API, import_path.removeprefix(f"{apis_import_path}/")
    elif import_path.startswith(plugins_import_path):
        return PLUGIN, import_path.removeprefix(f"{plugins_import_path}/")
    elif import_path.startswith(staging_import_path):
        return STAGING, import_path.removeprefix(f"{staging_import_path}/")
    else:
        logging.warning(f"do not know the type of {import_path}")

    return ""


def verify_dir_exists(pac_dir):
    if not os.path.isdir(pac_dir):
        logging.warning(f"directory does not exist {pac_dir}")


# these packages are either considered third party or have no tests
def not_important_package(dst_import_path):
    filters = [
        "k8s.io/klog",
        "k8s.io/kube-openapi",
        "k8s.io/utils",
        "k8s.io/kubernetes/pkg/cluster",
        "k8s.io/kubernetes/pkg/features",
        "k8s.io/kubernetes/pkg/routes",
        "k8s.io/kubernetes/test/utils",
        "k8s.io/kubernetes/third_party",
        "k8s.io/heapster",
        "k8s.io/kube-controller-manager",
        "k8s.io/system-validators",
        "k8s.io/kubernetes/test/utils/harness",
        "k8s.io/kubernetes/test/integration/framework",
        "k8s.io/gengo",
        "k8s.io/kubernetes/test/integration",
        "k8s.io/kubernetes/test/utils/image",
        "k8s.io/sample-apiserver",
        "k8s.io/kubernetes/test/integration/util",
    ]

    filters_regexp = [
        ".*_test",
        "k8s\\.io/kubernetes/test/e2e.*",
    ]

    regexp_match = False

    for re_filter in filters_regexp:
        if re.match(re_filter, dst_import_path):
            regexp_match = True

    return dst_import_path in filters or regexp_match


def verify_import_paths(aggr_adj_file_merged_handle, type_to_root_dir):
    for line in aggr_adj_file_merged_handle:
        import_paths = line.strip().split(" ")

        src_import_path = import_paths[0]
        dst_import_path = import_paths[1]

        src_type, src_subdir = infer_type_and_subdir(src_import_path)
        dst_type, dst_subdir = infer_type_and_subdir(dst_import_path)

        if not_important_package(dst_import_path):
            logging.info(f"skipping package with dest {dst_import_path}")
            continue

        verify_dir_exists(f"{type_to_root_dir[src_type]}/{src_subdir}")
        verify_dir_exists(f"{type_to_root_dir[dst_type]}/{dst_subdir}")


def main():
    polyrepo_binary_components_dest_root_dir = sys.argv[1]
    polyrepo_integration_tests_dest_root_dir = sys.argv[2]
    polyrepo_apis_dest_root_dir = sys.argv[3]
    polyrepo_plugins_dest_root_dir = sys.argv[4]
    polyrepo_staging_dest_root_dir = sys.argv[5]
    aggr_adj_file_merged_path = sys.argv[6]

    type_to_root_dir = {
        BINARY_COMPONENT: polyrepo_binary_components_dest_root_dir,
        INTEGRATION_TEST: polyrepo_integration_tests_dest_root_dir,
        API: polyrepo_apis_dest_root_dir,
        PLUGIN: polyrepo_plugins_dest_root_dir,
        STAGING: polyrepo_staging_dest_root_dir
    }

    with open(aggr_adj_file_merged_path, "r") as aggr_adj_file_merged_handle:
        verify_import_paths(aggr_adj_file_merged_handle, type_to_root_dir)


if __name__ == '__main__':
    main()
