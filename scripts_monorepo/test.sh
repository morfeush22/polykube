#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

make test WHAT=./staging/src/k8s.io/apiextensions-apiserver/pkg/...
make test WHAT=./staging/src/k8s.io/kube-aggregator/...
make test WHAT=./cmd/kube-apiserver/...
make test WHAT=./cmd/kube-controller-manager/...
make test WHAT=./cmd/kubectl/...
make test WHAT=./cmd/kubectl-convert/...
make test WHAT=./cmd/kubelet/...
make test WHAT=./cmd/kube-proxy/...
make test WHAT=./cmd/kube-scheduler/...
make test WHAT=./cluster/gce/gci/mounter/...

make test WHAT=./pkg/api/...
make test WHAT=./pkg/apis/...
make test WHAT=./pkg/auth/...
make test WHAT=./pkg/capabilities/...
make test WHAT=./pkg/client/...
make test WHAT=./pkg/cloudprovider/...
make test WHAT=./pkg/controller/...
make test WHAT=./pkg/controlplane/...
make test WHAT=./pkg/credentialprovider/...
make test WHAT=./pkg/fieldpath/...
make test WHAT=./pkg/generated/...
make test WHAT=./pkg/kubeapiserver/...
make test WHAT=./pkg/kubectl/...
make test WHAT=./pkg/kubelet/...
make test WHAT=./pkg/printers/...
make test WHAT=./pkg/probe/...
make test WHAT=./pkg/proxy/...
make test WHAT=./pkg/quota/...
make test WHAT=./pkg/registry/...
make test WHAT=./pkg/scheduler/...
make test WHAT=./pkg/security/...
make test WHAT=./pkg/securitycontext/...
make test WHAT=./pkg/serviceaccount/...
make test WHAT=./pkg/ssh/...
make test WHAT=./pkg/util/...
make test WHAT=./pkg/volume/...
make test WHAT=./plugin/pkg/admission/...
make test WHAT=./plugin/pkg/auth/...
make test WHAT=./staging/src/k8s.io/api/...
make test WHAT=./staging/src/k8s.io/apimachinery/...
make test WHAT=./staging/src/k8s.io/apiserver/...
make test WHAT=./staging/src/k8s.io/cli-runtime/...
make test WHAT=./staging/src/k8s.io/client-go/...
make test WHAT=./staging/src/k8s.io/cloud-provider/...
make test WHAT=./staging/src/k8s.io/cluster-bootstrap/...
make test WHAT=./staging/src/k8s.io/component-base/...
make test WHAT=./staging/src/k8s.io/component-helpers/...
make test WHAT=./staging/src/k8s.io/controller-manager/...
make test WHAT=./staging/src/k8s.io/cri-api/...
make test WHAT=./staging/src/k8s.io/csi-translation-lib/...
make test WHAT=./staging/src/k8s.io/kube-proxy/...
make test WHAT=./staging/src/k8s.io/kube-scheduler/...
make test WHAT=./staging/src/k8s.io/kubectl/...
make test WHAT=./staging/src/k8s.io/kubelet/...
make test WHAT=./staging/src/k8s.io/legacy-cloud-providers/...
make test WHAT=./staging/src/k8s.io/metrics/...
make test WHAT=./staging/src/k8s.io/mount-utils/...
