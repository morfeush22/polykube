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

filter and map import paths from aggr adj file to directories

test-cmd

unit -> int -> cmd -> e2e

removed packages that have no tests

Python 3.9.5 (default, May 24 2021, 12:50:35)
[GCC 11.1.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import networkx as x
>>> x.re
x.reaching                    x.read_graph6(                x.read_sparse6(               x.recursive_simple_cycles(    x.release                     x.restricted_view(
x.read_adjlist(               x.read_graphml(               x.read_weighted_edgelist(     x.regular                     x.reportviews                 x.reverse(
x.read_edgelist(              x.read_leda(                  x.read_yaml(                  x.relabel                     x.rescale_layout(             x.reverse_view(
x.read_gexf(                  x.read_multiline_adjlist(     x.readwrite                   x.relabel_gexf_graph(         x.rescale_layout_dict(        
x.read_gml(                   x.read_pajek(                 x.reciprocity(                x.relabel_nodes(              x.resistance_distance(        
x.read_gpickle(               x.read_shp(                   x.reconstruct_path(           x.relaxed_caveman_graph(      x.resource_allocation_index(  
>>> x.re
x.reaching                    x.read_graph6(                x.read_sparse6(               x.recursive_simple_cycles(    x.release                     x.restricted_view(
x.read_adjlist(               x.read_graphml(               x.read_weighted_edgelist(     x.regular                     x.reportviews                 x.reverse(
x.read_edgelist(              x.read_leda(                  x.read_yaml(                  x.relabel                     x.rescale_layout(             x.reverse_view(
x.read_gexf(                  x.read_multiline_adjlist(     x.readwrite                   x.relabel_gexf_graph(         x.rescale_layout_dict(        
x.read_gml(                   x.read_pajek(                 x.reciprocity(                x.relabel_nodes(              x.resistance_distance(        
x.read_gpickle(               x.read_shp(                   x.reconstruct_path(           x.relaxed_caveman_graph(      x.resource_allocation_index(  
>>> x.read_adjlist("/home/morfeush22/Projects/masters/polyrepo/filtered_aggr_adj_file_merged.txt")
<networkx.classes.graph.Graph object at 0x7efca52f7100>
>>> graph = x.read_adjlist("/home/morfeush22/Projects/masters/polyrepo/filtered_aggr_adj_file_merged.txt")
>>> x.write_
x.write_adjlist(            x.write_gml(                x.write_graphml(            x.write_multiline_adjlist(  x.write_sparse6(            
x.write_edgelist(           x.write_gpickle(            x.write_graphml_lxml(       x.write_pajek(              x.write_weighted_edgelist(  
x.write_gexf(               x.write_graph6(             x.write_graphml_xml(        x.write_shp(                x.write_yaml(               
>>> from networkx.drawing.nx_agraph import write_dot
>>> write_dot(graph, "./dot.graph")
Traceback (most recent call last):
File "/home/morfeush22/Projects/masters/kub/venv/lib/python3.9/site-packages/networkx/drawing/nx_agraph.py", line 130, in to_agraph
import pygraphviz
ModuleNotFoundError: No module named 'pygraphviz'

The above exception was the direct cause of the following exception:

Traceback (most recent call last):
File "<stdin>", line 1, in <module>
File "/home/morfeush22/Projects/masters/kub/venv/lib/python3.9/site-packages/networkx/drawing/nx_agraph.py", line 183, in write_dot
A = to_agraph(G)
File "/home/morfeush22/Projects/masters/kub/venv/lib/python3.9/site-packages/networkx/drawing/nx_agraph.py", line 132, in to_agraph
raise ImportError("requires pygraphviz " "http://pygraphviz.github.io/") from e
ImportError: requires pygraphviz http://pygraphviz.github.io/
>>> write_dot(graph, "./dot.graph")
>>> sgraph=x.edge_subgraph(graph, x.edges(graph, ["k8s.io/kubernetes/pkg/scheduler"]))
>>> write_dot(sgraph, "./dot.graph")
sfdp -x -Goverlap=scale -Tpng dot.graph > data.png

import networkx as x
g=x.read_edgelist("/home/morfeush22/Projects/masters/polyrepo/filtered_aggr_adj_file_merged.txt", create_using=x.DiGraph)
rg=g.reverse()
srg=x.edge_subgraph(rg, x.edges(rg, ["k8s.io/kubernetes/pkg/scheduler"]))
from networkx.drawing.nx_agraph import write_dot
write_dot(srg, "./dot.graph")
sfdp -x -Goverlap=scale -Tpng dot.graph > data.png

export PATH="/home/morfeush22/Projects/kubernetes/third_party/etcd:${PATH}"
etcd --advertise-client-urls http://127.0.0.1:2379 --data-dir /tmp/tmp.Gevfp9wZmC --listen-client-urls http://127.0.0.1:2379 --log-level=debug > "/dev/null" 2>/dev/null

go test -c ./test/e2e_kubeadm
(alpha)
export KUBECONFIG="${HOME}/.kube/kind-test-config"
./e2e_kubeadm.test --context kind-kind --num-nodes 2 --ginkgo.skip="\[copy-certs\]"
kind build node-image
./e2e.test --context kind-kind --num-nodes 2 --ginkgo.focus="\[Conformance\]"
--kubectl-path