import logging
import os
import sys

LOGLEVEL = os.environ.get('LOGLEVEL', 'WARNING').upper()
logging.basicConfig(level=LOGLEVEL)


def filter_adj_to_n_depth(label, n=None):
    return "/".join(label.split("/")[:n])


def aggr_adj(label):
    kubernetes_repo_import_path = "k8s.io/kubernetes"
    kubernetes_staging_import_path = "k8s.io"

    kubernetes_test_integration_import_path = f"{kubernetes_repo_import_path}/test/integration"
    kubernetes_plugin_import_path = f"{kubernetes_repo_import_path}/plugin/pkg"
    kubernetes_cmd_import_path = f"{kubernetes_repo_import_path}/cmd"
    kubernetes_pkg_import_path = f"{kubernetes_repo_import_path}/pkg"
    kubernetes_third_party_import_path = f"{kubernetes_repo_import_path}/third_party"

    # from most specific one...
    if label.startswith(kubernetes_test_integration_import_path):
        return filter_adj_to_n_depth(label, 5)
    elif label.startswith(kubernetes_plugin_import_path):
        return filter_adj_to_n_depth(label, 5)
    elif label.startswith(kubernetes_cmd_import_path):
        return filter_adj_to_n_depth(label, 4)
    elif label.startswith(kubernetes_pkg_import_path):
        return filter_adj_to_n_depth(label, 4)
    elif label.startswith(kubernetes_third_party_import_path):
        return filter_adj_to_n_depth(label, 3)
    elif label.startswith(kubernetes_repo_import_path):
        logging.info(f"using less specific {kubernetes_repo_import_path} path spec for {label}")
        return filter_adj_to_n_depth(label)
    elif label.startswith(kubernetes_staging_import_path):
        logging.info(f"using less specific {kubernetes_staging_import_path} path spec for {label}")
        return filter_adj_to_n_depth(label, 2)
    else:
        logging.warning(f"do not know how to aggregate {label}")

    return ""


def create_label(src, dst):
    return " ".join([src, dst])


def aggr_adjs(line):
    adjs = line.strip().split(" ")

    src = adjs[0]
    dst = adjs[1]

    return create_label(aggr_adj(src), aggr_adj(dst))


def infer_aggr_adj_labels(adj_file_merged_handle):
    labels = []

    for line in adj_file_merged_handle:
        labels.append(aggr_adjs(line))

    return set(labels)


def remove_self_ref_labels(labels):
    filtered_labels = []

    for label in labels:
        adjs = label.split(" ")

        src = adjs[0]
        dst = adjs[1]

        if src != dst:
            filtered_labels.append(create_label(src, dst))

    return filtered_labels


def save_aggr_labels_to_file(aggr_adj_file_merged_dest_path, labels):
    for label in sorted(labels):
        aggr_adj_file_merged_dest_path.write(f"{label}\n")


def main():
    adj_file_merged_path = sys.argv[1]
    aggr_adj_file_merged_dest_path = sys.argv[2]

    with open(adj_file_merged_path, "r") as adj_file_merged_handle:
        labels = infer_aggr_adj_labels(adj_file_merged_handle)

    filtered_labels = remove_self_ref_labels(labels)

    with open(aggr_adj_file_merged_dest_path, "w") as aggr_adj_file_merged_handle:
        save_aggr_labels_to_file(aggr_adj_file_merged_handle, filtered_labels)


if __name__ == '__main__':
    main()
