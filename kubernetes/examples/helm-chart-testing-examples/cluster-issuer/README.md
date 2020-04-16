This is a test chart to show the functionality of the chart-testing tool
================================

The chart-testing tool used: https://github.com/helm/chart-testing

The objective of this example is to show how using various testing values input files and parameters can help exercise the chart usage and functionality.

In this example in the file `./templates/dns01.yaml` on line 6 there is a clear yaml error.

The default of this chart in the `./values.yaml` file the parameter `issuer.dns.enable` is by default `false`.  When running this test with the default parameters, the rendering of this chart never hits line 6.

In a variation test with additional values file in `./ci/enable-dns01-issuer-values.yaml` file, the `issuer.dns.enable` is set to `true` which will make the Helm template run that code block and at which point it will fail.

## Switch to the branch which has the failing tests

This branch `helm-chart-testing-examples` has the failing items that can be demo'ed against.

## Starting the docker container for the test
We are using the chart-testing Docker container for testing to be consistent.

```
docker run -it \
-v ${PWD}:/opt/app \
quay.io/helmpack/chart-testing:v3.0.0-rc.1 sh

cd /opt/app/
```

The root of the repository is at: `/opt/app`

## running the test:
Run from the root of this repository

```
# ct lint --config ./kubernetes/examples/helm-chart-testing-examples/ct.yaml --debug
Linting charts...
Using config file:  ./kubernetes/examples/helm-chart-testing-examples/ct.yaml
------------------------------------------------------------------------------------------------------------------------
 Configuration
------------------------------------------------------------------------------------------------------------------------
Remote: origin
TargetBranch: master
BuildId: 
LintConf: /etc/ct/lintconf.yaml
ChartYamlSchema: /etc/ct/chart_schema.yaml
ValidateMaintainers: true
ValidateChartSchema: true
ValidateYaml: true
CheckVersionIncrement: true
ProcessAllCharts: false
Charts: []
ChartRepos: [incubator=https://kubernetes-charts-incubator.storage.googleapis.com/ stable=https://kubernetes-charts.storage.googleapis.com/]
ChartDirs: [kubernetes/helm-tmp]
ExcludedCharts: [common]
HelmExtraArgs: --timeout 600
HelmRepoExtraArgs: []
Debug: true
Upgrade: false
SkipMissingValues: false
Namespace: 
ReleaseLabel: 
------------------------------------------------------------------------------------------------------------------------
>>> helm version --short
>>> git rev-parse --is-inside-work-tree
>>> git merge-base origin/master HEAD
>>> git diff --find-renames --name-only 0a50291cf752f4bcf630f34727eb834adcf76a70 -- kubernetes/helm-tmp

------------------------------------------------------------------------------------------------------------------------
 Charts to be processed:
------------------------------------------------------------------------------------------------------------------------
 cluster-issuer => (version: "v0.1.2", path: "kubernetes/helm-tmp/cluster-issuer")
------------------------------------------------------------------------------------------------------------------------

>>> helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
"incubator" has been added to your repositories
>>> helm repo add stable https://kubernetes-charts.storage.googleapis.com/
"stable" has been added to your repositories
>>> helm dependency build kubernetes/helm-tmp/cluster-issuer
Linting chart 'cluster-issuer => (version: "v0.1.2", path: "kubernetes/helm-tmp/cluster-issuer")'
Checking chart 'cluster-issuer => (version: "v0.1.2", path: "kubernetes/helm-tmp/cluster-issuer")' for a version bump...
>>> git cat-file -e origin/master:kubernetes/helm-tmp/cluster-issuer/Chart.yaml
>>> git show origin/master:kubernetes/helm-tmp/cluster-issuer/Chart.yaml
Old chart version: v0.1.1
New chart version: v0.1.2
Chart version ok.
>>> yamale --schema /etc/ct/chart_schema.yaml kubernetes/helm-tmp/cluster-issuer/Chart.yaml
Validating /opt/app/kubernetes/helm-tmp/cluster-issuer/Chart.yaml...
Validation success! 👍
>>> yamllint --config-file /etc/ct/lintconf.yaml kubernetes/helm-tmp/cluster-issuer/Chart.yaml
>>> yamllint --config-file /etc/ct/lintconf.yaml kubernetes/helm-tmp/cluster-issuer/values.yaml
>>> yamllint --config-file /etc/ct/lintconf.yaml kubernetes/helm-tmp/cluster-issuer/ci/default-values.yaml
>>> yamllint --config-file /etc/ct/lintconf.yaml kubernetes/helm-tmp/cluster-issuer/ci/enable-dns01-issuer-values.yaml
Validating maintainers...
>>> git ls-remote --get-url origin

Linting chart with values file 'kubernetes/helm-tmp/cluster-issuer/ci/default-values.yaml'...

>>> helm lint kubernetes/helm-tmp/cluster-issuer --values kubernetes/helm-tmp/cluster-issuer/ci/default-values.yaml
==> Linting kubernetes/helm-tmp/cluster-issuer
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed

Linting chart with values file 'kubernetes/helm-tmp/cluster-issuer/ci/enable-dns01-issuer-values.yaml'...

>>> helm lint kubernetes/helm-tmp/cluster-issuer --values kubernetes/helm-tmp/cluster-issuer/ci/enable-dns01-issuer-values.yaml
==> Linting kubernetes/helm-tmp/cluster-issuer
[INFO] Chart.yaml: icon is recommended
[ERROR] templates/dns01.yaml: unable to parse YAML: error converting YAML to JSON: yaml: line 7: could not find expected ':'

Error: 1 chart(s) linted, 1 chart(s) failed
------------------------------------------------------------------------------------------------------------------------
 ✖︎ cluster-issuer => (version: "v0.1.2", path: "kubernetes/helm-tmp/cluster-issuer") > Error waiting for process: exit status 1
------------------------------------------------------------------------------------------------------------------------
Error: Error linting charts: Error processing charts
Error linting charts: Error processing charts
```

The linter points out the file and the error:

```
>>> helm lint kubernetes/helm-tmp/cluster-issuer --values kubernetes/helm-tmp/cluster-issuer/ci/enable-dns01-issuer-values.yaml
==> Linting kubernetes/helm-tmp/cluster-issuer
[INFO] Chart.yaml: icon is recommended
[ERROR] templates/dns01.yaml: unable to parse YAML: error converting YAML to JSON: yaml: line 7: could not find expected ':'
```

## Verify that the chart-testing tool is taking action on this
You might think, ok, the chart-testing tool is just linting out the file and is catching the error somehow.

We can test for this.

If you change in the file `./ci/enable-dns01-issuer-values.yaml` value `issuer.dns.enable` to `false` and run it again, you get a successful lint run:

```
# ct lint --config ./kubernetes/examples/helm-chart-testing-examples/ct.yaml --debug
Linting charts...
Using config file:  ./kubernetes/examples/helm-chart-testing-examples/ct.yaml
------------------------------------------------------------------------------------------------------------------------
 Configuration
------------------------------------------------------------------------------------------------------------------------
Remote: origin
TargetBranch: master
BuildId: 
LintConf: /etc/ct/lintconf.yaml
ChartYamlSchema: /etc/ct/chart_schema.yaml
ValidateMaintainers: true
ValidateChartSchema: true
ValidateYaml: true
CheckVersionIncrement: true
ProcessAllCharts: false
Charts: []
ChartRepos: [incubator=https://kubernetes-charts-incubator.storage.googleapis.com/ stable=https://kubernetes-charts.storage.googleapis.com/]
ChartDirs: [kubernetes/helm-tmp]
ExcludedCharts: [common]
HelmExtraArgs: --timeout 600
HelmRepoExtraArgs: []
Debug: true
Upgrade: false
SkipMissingValues: false
Namespace: 
ReleaseLabel: 
------------------------------------------------------------------------------------------------------------------------
>>> helm version --short
>>> git rev-parse --is-inside-work-tree
>>> git merge-base origin/master HEAD
>>> git diff --find-renames --name-only 0a50291cf752f4bcf630f34727eb834adcf76a70 -- kubernetes/helm-tmp

------------------------------------------------------------------------------------------------------------------------
 Charts to be processed:
------------------------------------------------------------------------------------------------------------------------
 cluster-issuer => (version: "v0.1.2", path: "kubernetes/helm-tmp/cluster-issuer")
------------------------------------------------------------------------------------------------------------------------

>>> helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
"incubator" has been added to your repositories
>>> helm repo add stable https://kubernetes-charts.storage.googleapis.com/
"stable" has been added to your repositories
>>> helm dependency build kubernetes/helm-tmp/cluster-issuer
Linting chart 'cluster-issuer => (version: "v0.1.2", path: "kubernetes/helm-tmp/cluster-issuer")'
Checking chart 'cluster-issuer => (version: "v0.1.2", path: "kubernetes/helm-tmp/cluster-issuer")' for a version bump...
>>> git cat-file -e origin/master:kubernetes/helm-tmp/cluster-issuer/Chart.yaml
>>> git show origin/master:kubernetes/helm-tmp/cluster-issuer/Chart.yaml
Old chart version: v0.1.1
New chart version: v0.1.2
Chart version ok.
>>> yamale --schema /etc/ct/chart_schema.yaml kubernetes/helm-tmp/cluster-issuer/Chart.yaml
Validating /opt/app/kubernetes/helm-tmp/cluster-issuer/Chart.yaml...
Validation success! 👍
>>> yamllint --config-file /etc/ct/lintconf.yaml kubernetes/helm-tmp/cluster-issuer/Chart.yaml
>>> yamllint --config-file /etc/ct/lintconf.yaml kubernetes/helm-tmp/cluster-issuer/values.yaml
>>> yamllint --config-file /etc/ct/lintconf.yaml kubernetes/helm-tmp/cluster-issuer/ci/default-values.yaml
>>> yamllint --config-file /etc/ct/lintconf.yaml kubernetes/helm-tmp/cluster-issuer/ci/enable-dns01-issuer-values.yaml
Validating maintainers...
>>> git ls-remote --get-url origin

Linting chart with values file 'kubernetes/helm-tmp/cluster-issuer/ci/default-values.yaml'...

>>> helm lint kubernetes/helm-tmp/cluster-issuer --values kubernetes/helm-tmp/cluster-issuer/ci/default-values.yaml
==> Linting kubernetes/helm-tmp/cluster-issuer
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed

Linting chart with values file 'kubernetes/helm-tmp/cluster-issuer/ci/enable-dns01-issuer-values.yaml'...

>>> helm lint kubernetes/helm-tmp/cluster-issuer --values kubernetes/helm-tmp/cluster-issuer/ci/enable-dns01-issuer-values.yaml
==> Linting kubernetes/helm-tmp/cluster-issuer
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed
------------------------------------------------------------------------------------------------------------------------
 ✔︎ cluster-issuer => (version: "v0.1.2", path: "kubernetes/helm-tmp/cluster-issuer")
------------------------------------------------------------------------------------------------------------------------
All charts linted successfully
```

Looking at the outputs, it did use all of the configs in the `./ci` directory.  It didn't fail because nothing triggered the chart templating to hit that part of the code block so with those testing parameters, this chart lints out fine.
