#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

make all WHAT=./staging/src/k8s.io/apiextensions-apiserver
make all WHAT=./staging/src/k8s.io/kube-aggregator
make all WHAT=./cmd/kube-apiserver
make all WHAT=./cmd/kube-controller-manager
make all WHAT=./cmd/kubectl
make all WHAT=./cmd/kubectl-convert
make all WHAT=./cmd/kubelet
make all WHAT=./cmd/kube-proxy
make all WHAT=./cmd/kube-scheduler
make all WHAT=./cluster/gce/gci/mounter
