gotk
=============

Documentation: https://toolkit.fluxcd.io/get-started/



## Launching

### Set your GITHUB access
You can create a personal Github token with these instructions:
* https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token

```
export GITHUB_TOKEN=<your-token>
```

### Setting up the `dev` cluster
Bootstrap the `dev` cluster:

Setup variables
```
export GITHUB_USER=ManagedKube
export GITHUB_REPOSITORY=kubernetes-common-services
export REPOSITORY_HOSTNAME=github.com
export REPOSITORY_PATH=kubernetes/gotk/deployments/aws/dev
```

```
gotk bootstrap github \
  --version=v0.0.22 \
  --namespace gitops-system \
  --components=source-controller,kustomize-controller,helm-controller,notification-controller \
  --owner=$GITHUB_USER \
  --hostname=$REPOSITORY_HOSTNAME \
  --repository=$GITHUB_REPOSITORY \
  --path=$REPOSITORY_PATH \
  --private=true \
  --interval=1m \
  --personal
```

