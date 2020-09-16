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

