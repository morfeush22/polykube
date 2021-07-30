1. Generate bindata file (./hack/run-in-gopath.sh hack/generate-bindata.sh && rm -rf _output)
2. Apply patches (kub.patch):
    - https://github.com/kubernetes/kubernetes/pull/98960
    - https://github.com/kubernetes/kubernetes/pull/100215
    - https://github.com/kubernetes/kubernetes/pull/99174
