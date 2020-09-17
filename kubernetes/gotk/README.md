gotk - GitOpts Toolkit
=============

## what is gotk
gotk is an open source toolkit that assembles all the necessary parts together to help you to create a GitOps workflow.

Documentation: https://toolkit.fluxcd.io/get-started/

## Why a GitOps workflow
A GitOps workflow has many desireable features to it:
* We don't have to create individual pipelines for everything that we want to deploy
* Removes the reliance on manually deploying
* For the clusters that we want the confiurations matching to what is in Git, we add`gotk` to it and it will handle all of the syncing for us
* Our clusters won't be in a mix/unknown state.  We can now definitively go to Git for the source of truth

## Download gotk CLI
This is the open source GitOps Tool Kit that we are using:
* https://github.com/fluxcd/toolkit/releases

## Launching

### Set your GITHUB access
You can create a personal Github token with these instructions:
* https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token
* check all permissions under repo

```
export GITHUB_TOKEN=<your-token>
```

This personal token is not used as a deployment mechanism.  This token is used in the provisioning process.  It will use this token to create a deployment ssh key in the repository.  This is more of a convenience way of adding all the necessary permissions for the in-cluster source controllers can reach the Git repository to sync.  If you don't want to do this, you can alternatively add the Kubernetes secret into the `gitops-system` namespace with the private key to use. 

### Setting up the `dev` cluster
Bootstrap the `dev` cluster:

Setup variables
```
export GITHUB_USER=ManagedKube                             # The repository organization/owner
export GITHUB_REPOSITORY=kubernetes-common-services
export REPOSITORY_HOSTNAME=github.com
export REPOSITORY_PATH=kubernetes/gotk/deployments/aws/dev
export GOTK_VERSION=v0.0.28                                # Release: https://github.com/fluxcd/toolkit/releases
export GIT_BRANCH=master
```

```
gotk bootstrap github \
  --version=$GOTK_VERSION \
  --namespace gitops-system \
  --components=source-controller,kustomize-controller,helm-controller,notification-controller \
  --owner=$GITHUB_USER \
  --hostname=$REPOSITORY_HOSTNAME \
  --repository=$GITHUB_REPOSITORY \
  --path=$REPOSITORY_PATH \
  --private=true \
  --interval=1m \
  --personal \
  --branch $GIT_BRANCH
```

## Directory structure

```
├── aws
│   ├── clusters
│   │   └── dev                                         <---(2)
│   │       ├── common
│   │       │   ├── app-cluster.yaml                       <---(4)
│   │       │   └── README.me
│   │       └── gitops-system                              <---(3)
│   │           ├── toolkit-components.yaml
│   │           ├── toolkit-kustomization.yaml
│   │           └── toolkit-source.yaml
│   └── common
│       └── app-clusters                                   <---(5)
│           ├── namespaces
│           │   ├── ingress.yaml
│           │   ├── kustomization.yaml
│           │   └── monitoring.yaml
│           ├── prometheus-operator
│           │   ├── helmrelease.yaml
│           │   └── kustomization.yaml
│           ├── sources
│           │   ├── gitrepository
│           │   │   └── kubernetes-common-services.yaml
│           │   └── helmrepository
│           │       ├── kubernetes-charts.yaml
│           │       ├── prometheus-community.yaml
│           │       └── sumologic.yaml
│           └── sumologic
│               ├── helmrelease.yaml
│               └── kustomization.yaml
└── base                                                    <---(1)
    ├── prometheus-operator
    │   ├── helmrelease.yaml
    │   ├── kustomization.yaml
    │   └── README.md
    └── sumologic
        ├── helmrelease.yaml
        ├── kustomization.yaml
        └── README.md
```

### (1) base
The base folders holds common configuration across all clusters on how an application should be configured.  These are the defaults settings we would like for the applications but this can be overriden by the local's cluster values.

### (2) dev
This is a cluster we are naming `dev`.  This is where we will hold various clusters and this is an example of one cluster and how it is configured.

### (3) gitops-system
This is the directory that the `gotk` tool creates and pushes into this repository on how it configured itself in this cluster.  As we update `gotk` and apply it to a cluster, this will also change.

### (4) app-cluster.yaml
A lot of our clusters looks fairly similar because we have a promotion scheme going from dev -> qa -> prod.  Each of these clusters has the same items installed on it and most likely only the application version changes as we promote versions and new items from each cluster.  You can think of this as an "include" these items into this cluster.

This allows us to keep these configurations DRY.

While we can still put items under `./aws/clusters/dev`, that are not common or that is new and we only want to test in this cluster into the clusters local path which will mean this only gets deployed to this cluster.

### (5) app-cluster
`app-cluster` is a cluster profile type.  Our application clusters will all have these items in it.  

We can create new cluster profile types by creating more directories under `./aws/common` and "including" them from a cluster.  For a cluster, we can even include multiple items under `./aws/common` if we want to decompose the profiles even more.
