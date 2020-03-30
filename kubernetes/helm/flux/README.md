Flux Setup
============
Flux is a GitOps workflow tool that runs an operator in each cluster you want it to be able to deploy into.  You link it up with your Git repository and it syncs your repository with your cluster.  This means that if you wanted to deploy something or update something in the Kubernetes cluster, all you have to do is make the changes in the source repository, commit, and push it in.  Flux will check with the source repository every so often and sync what is there to the Kubernetes cluster.  The Flux operator will sync and deploy items based on Kubernetes yaml files only.

Here is the official documentation for reference: [https://docs.fluxcd.io/en/latest/introduction.html](https://docs.fluxcd.io/en/latest/introduction.html)

# Requirements
You need these CLI tools locally:

* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [helm3](https://helm.sh/docs/intro/install/)
* [fluxctl](https://docs.fluxcd.io/en/1.18.0/references/fluxctl.html)

# Deploy the Flux Operator

```
cd ./flux
```

## Add an environment's values.yaml file

For each environment you want to deploy Flux into and for the Git repository you want it to watch, you will have to configure this.

For example, if you have a `dev` environment in the cloud `gcp` watching this repository, you will make a values file like (`./environments/gcp/dev/values.yaml`):

```yaml
flux:
  git:
    url: git@github.com:ManagedKube/kubernetes-ops.git
    branch: master
    path: "kubernetes/flux/releases/gcp/dev,kubernetes/flux/releases/base-values"
```

This is pointing to the repository int the `url` key and at the `branch`.  The `path` configures what this Flux instantiation should monitor in this repository in a comma separated list.  In this case, it is set to watch the release files for our environment `dev`: `kubernetes/flux/releases/gcp/dev`.  Notice we named a directory named `dev` here as well.  It is recommended trying to keep all of the environment names consistent to make it easier to denote what environment these configurations belongs to.  The second path is watching the base values which applies to all environments (we'll be talking about what that does later).

## Deploy it out to your Kubernetes cluster
The `ENVIRONMENT` variable name is the name of the folder you just created in the previous step.

```
make ENVIRONMENT=gcp/dev apply
```

## Get the Git public key
For Flux to be able to watch your repository, you will need to add it's public ssh key to your Git repository.

Get the public ssh key:

```
make get-identity
```

This will output a key.

```
In order to sync your cluster state with git you need to copy the public key and create a deploy key with write access on your GitHub repository.

Open GitHub, navigate to your fork, go to Setting > Deploy keys, click on Add deploy key, give it a Title, check Allow write access, paste the Flux public key and click Add key.
```

# Deploy the Flux helm-operator
While the Flux Operator syncs and deploys Kubernetes yaml files, the Flux helm-operator acts on the kind:

```yaml
apiVersion: helm.fluxcd.io/v1
kind: HelmRelease
```

With this Flux CRD, we can express Helm deployments in a yaml file and the Flux helm-operator will run the Helm3 commands for us and deploy it in the cluster.  In short, this helps us to sync Helm3 definitions in our Git repository to a Helm deployment in our Kubernetes cluster.

## Deploy

```
cd ./helm-operator
make ENVIRONMENT=gcp/dev apply-crd
make ENVIRONMENT=gcp/dev apply
```

# Why we are using Helm to deploy Flux and not the fluxctl tool?
While it is easier to use the `fluxtctl` tool to get started, it does not provide us with the lifecycle management of Flux that we require in a real world setting when maintaining live infrastructure.  The `fluxctl` tool has you creating flux with a CLI command inputting the same parameters we are inputting in our `values.yaml` files.  The problem with this is how to we make this reproducible and reflected in Git?  Do we write a script to wrap around the CLI command and then pass in a values file of some sort to this script to use?  We can but that sounds pretty much like what Helm does.  So why not just use Helm?

So it might seem like we are taking a more complex route and we agree, if you are just getting started it is a lot to take in at first.  In the long run we have found that maintaining the lifecycle of these configs in this manor works better and it is actually less for us to maintain.
