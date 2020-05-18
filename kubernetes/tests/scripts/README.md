Test Scripts
=============

# kustomize_and_hrval_check.sh
This script runs [kustomize](https://github.com/kubernetes-sigs/kustomize) to output all of the overlays then runs [hrval](https://github.com/stefanprodan/hrval-action) on the `HelmRelease`s.

Steps:
* `kustomize` output all overlays in the given directory path
* In the output, find all YAML documents that are `HelmRelease`s
* Run `hrval` on each `HelmRelease`

## Usage:

Start the `hrval` Docker container at the root of your project:
```
docker run -it -v ${PWD}:/opt/app -v /usr/local/bin/kustomize:/opt/bin/kustomize --entrypoint bash stefanprodan/hrval
```
This is assuming you have `kustomized` installed locally at `/usr/local/bin/kustomize`

Run:
```
/opt/app/kubernetes/tests/scripts/kustomize_and_hrval_check.sh /opt/app/kubernetes/flux/releases/gcp/dev
```
