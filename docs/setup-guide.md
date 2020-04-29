Kubernetes Common Services - Setup Guide
========================================================
This guide will walk you through step by step on how to setup Kubernetes Common Services in your Kubernetes cluster.

The assumption is that you have a working Kubernetes cluster.

The following sections will guide you through on how to set this up.

- [Install the pre-requisite tools](#install-the-pre-requisite-tools)
  * [Requirements](#requirements)
- [Check to make sure you can access your Kubernetes cluster](#check-to-make-sure-you-can-access-your-kubernetes-cluster)
- [Copy the content of this repository to your repository](#copy-the-content-of-this-repository-to-your-repository)
  * [What to copy](#what-to-copy)
  * [To where](#to-where)
- [Flux Setup](#flux-setup)
  * [Deploy the Flux Operator](#deploy-the-flux-operator)
    + [Create the Flux's namespace](#create-the-flux-s-namespace)
    + [Add an environment's values.yaml file](#add-an-environment-s-valuesyaml-file)
    + [Deploy it out to your Kubernetes cluster](#deploy-it-out-to-your-kubernetes-cluster)
    + [Verify Helm install](#verify-helm-install)
    + [Get the Git public key](#get-the-git-public-key)
  * [Deploy the Flux helm-operator](#deploy-the-flux-helm-operator)
    + [Deploy](#deploy)
    + [Verify Helm install](#verify-helm-install-1)
  * [Why we are using Helm to deploy Flux and not the fluxctl tool?](#why-we-are-using-helm-to-deploy-flux-and-not-the-fluxctl-tool-)
  * [Git commit the Flux Operator items](#git-commit-the-flux-operator-items)
- [Kubernetes Common Services](#kubernetes-common-services)
  * [Required files](#required-files)
    + [`.flux.yaml`](#-fluxyaml-)
    + [kustomize](#kustomize)
    + [HelmRelease files](#helmrelease-files)
  * [Add in an easy example service: sealed-secrets](#add-in-an-easy-example-service--sealed-secrets)
    + [Check to make sure everything is in place](#check-to-make-sure-everything-is-in-place)
    + [Git commit files](#git-commit-files)
    + [Check if Flux deployed our service](#check-if-flux-deployed-our-service)
  * [Add in a service that uses an encrypted secret and the kustomize base values: external-dns](#add-in-a-service-that-uses-an-encrypted-secret-and-the-kustomize-base-values--external-dns)
    + [Create an AWS user and keys with access to the DNS](#create-an-aws-user-and-keys-with-access-to-the-dns)
    + [Create the sealed secret with the access key information](#create-the-sealed-secret-with-the-access-key-information)
      - [GCP](#gcp)
      - [AWS](#aws)
    + [Edit this environments `kustomization.yaml` file to add in the `external-dns` folder](#edit-this-environments--kustomizationyaml--file-to-add-in-the--external-dns--folder)
    + [Check to make sure everything is in place](#check-to-make-sure-everything-is-in-place-1)
    + [Git commit files](#git-commit-files-1)
  * [Cert-Manager](#cert-manager)
    + [Add the cert-manager](#add-the-cert-manager)
    + [Edit this environments `kustomization.yaml` file to add in the `cert-manager` folder](#edit-this-environments--kustomizationyaml--file-to-add-in-the--cert-manager--folder)
    + [Check to make sure everything is in place](#check-to-make-sure-everything-is-in-place-2)
    + [Git commit files](#git-commit-files-2)
    + [Add the cert-manager's cluster-issuers helper chart](#add-the-cert-manager-s-cluster-issuers-helper-chart)
    + [Create the sealed secret with the access key information](#create-the-sealed-secret-with-the-access-key-information-1)
      - [GCP](#gcp-1)
      - [AWS](#aws-1)
    + [Check to make sure everything is in place](#check-to-make-sure-everything-is-in-place-3)
    + [Git commit files](#git-commit-files-3)
  * [Prometheus Operator](#prometheus-operator)
    + [Uncomment the namespace](#uncomment-the-namespace)
    + [add folder into the environment's `kustomization.yaml` file](#add-folder-into-the-environment-s--kustomizationyaml--file)
    + [Copy files to your repository](#copy-files-to-your-repository)
    + [Check to make sure everything is in place](#check-to-make-sure-everything-is-in-place-4)
    + [Git commit files](#git-commit-files-4)
  * [nginx-ingress](#nginx-ingress)
    + [Uncomment the namespace](#uncomment-the-namespace-1)
    + [add folder into the environment's `kustomization.yaml` file](#add-folder-into-the-environment-s--kustomizationyaml--file-1)
    + [Copy files to your repository](#copy-files-to-your-repository-1)
    + [Check to make sure everything is in place](#check-to-make-sure-everything-is-in-place-5)
    + [Git commit files](#git-commit-files-5)
    + [Check that it deployed](#check-that-it-deployed)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>

# Install the pre-requisite tools

## Requirements
You need these CLI tools locally:

* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [helm3](https://helm.sh/docs/intro/install/)
* [fluxctl](https://docs.fluxcd.io/en/1.18.0/references/fluxctl.html)
* [kustomize](https://github.com/kubernetes-sigs/kustomize#kustomize)
* [sealed-secret cli](https://github.com/bitnami-labs/sealed-secrets#homebrew)

# Check to make sure you can access your Kubernetes cluster
As a check to ensure you can acces the Kuberenetes cluster run the following:

```
kubectl get nodes
```
This should return a list of nodes to the cluster you want to set this up on.

# Copy the content of this repository to your repository
You will have to copy the content of this repository into your own repository or fork this repository.  The reason is that, you will have to give the Flux operator running in your cluster access to your repository with this content so that it can sync the Kubernetes resources you want it to apply to your cluster.

You **can not** use the `git clone`.  Cloning this repository will not give you access to this repository since you don't have permission to it.

## What to copy
I would copy over the `docs` and the `kubernetes` directory to your repository.

## To where
The easiest method is to copy these directories to the root of your project.  You can change the directory location and names but by doing so, you will also have to update a few other things to make sure everything is pointing to the correct place.  Changing the location and directory name would be consider an advance usage of this project and outside the scope of this documentation.

This documentation is assuming that both of these directories are at the root of your project.

# Flux Setup

The following is **not** meant to be a definitive guide on how to use [WeaveWorks Flux](https://github.com/fluxcd/flux).  This guide explains enough of it to get you started.  For an indepth explanation refer to the [Flux docs](https://docs.fluxcd.io/).

Flux is the open source tool that we will be using for our GitOps workflow where it will sync what is in this Git repository over to our cluster(s).

We will deploy Flux to one or more cluster that we want it to perform the Git syncing action.

## Deploy the Flux Operator
Your current path: `/<root of the project>`

```
cd ./kubernetes/helm/flux
```

### Create the Flux's namespace

```
kubectl apply -f namespaces/namespace.yaml
```

### Add an environment's values.yaml file

Your current path: `/<root of the project>`
Change directory to: `./kubernetes/helm/flux/flux`

For each environment you want to deploy Flux into and for the Git repository you want it to watch, you will have to configure this.

For example, if you have a `dev` environment in the cloud `gcp` watching this repository, you will make a values file like (`./environments/gcp/dev/values.yaml`):

```yaml
flux:
  git:
    url: git@github.com:ManagedKube/kubernetes-ops.git
    branch: master
    path: "kubernetes/flux/releases/gcp/dev"
```

This is pointing to the repository int the `url` key and at the `branch`.  The `path` configures what this Flux instantiation should monitor in this repository in a comma separated list.  In this case, it is set to watch the release files for our environment `dev`: `kubernetes/flux/releases/gcp/dev`.  Notice we named a directory named `dev` here as well.  It is recommended trying to keep all of the environment names consistent to make it easier to denote what environment these configurations belongs to.  The second path is watching the base values which applies to all environments (we'll be talking about what that does later).

### Deploy it out to your Kubernetes cluster
The `ENVIRONMENT` variable name is the name of the folder you just created in the previous step.

Your current path: `/<root of the project>`
Change directory to: `./kubernetes/helm/flux/flux`

```
make ENVIRONMENT=gcp/dev apply
```

### Verify Helm install

```
make ENVIRONMENT=gcp/dev list
```

You should recieve a response which indicates the `STATUS` is in a `deployed` state:
```
helm --namespace flux list
NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
flux    flux            1               2020-04-26 05:31:08.197783259 -0700 PDT deployed        flux-1.3.0      1.19.0   
```

### Get the Git public key
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

## Deploy the Flux helm-operator
While the Flux Operator syncs and deploys Kubernetes yaml files, the Flux helm-operator acts on the kind:

```yaml
apiVersion: helm.fluxcd.io/v1
kind: HelmRelease
```

With this Flux CRD, we can express Helm deployments in a yaml file and the Flux helm-operator will run the Helm3 commands for us and deploy it in the cluster.  In short, this helps us to sync Helm3 definitions in our Git repository to a Helm deployment in our Kubernetes cluster.

### Deploy

```
cd ../helm-operator
make ENVIRONMENT=gcp/dev apply-crd
make ENVIRONMENT=gcp/dev apply
```

### Verify Helm install

```
make ENVIRONMENT=gcp/dev list
```

You should recieve a response which indicates the `STATUS` is in a `deployed` state:
```
helm --namespace flux list
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
flux            flux            1               2020-04-26 05:31:08.197783259 -0700 PDT deployed        flux-1.3.0              1.19.0     
helm-operator   flux            1               2020-04-26 05:36:29.159387514 -0700 PDT deployed        helm-operator-1.0.1     1.0.1  
```

## Why we are using Helm to deploy Flux and not the fluxctl tool?
While it is easier to use the `fluxtctl` tool to get started, it does not provide us with the lifecycle management of Flux that we require in a real world setting when maintaining live infrastructure.  The `fluxctl` tool has you creating flux with a CLI command inputting the same parameters we are inputting in our `values.yaml` files.  The problem with this is how to we make this reproducible and reflected in Git?  Do we write a script to wrap around the CLI command and then pass in a values file of some sort to this script to use?  We can but that sounds pretty much like what Helm does.  So why not just use Helm?

So it might seem like we are taking a more complex route and we agree, if you are just getting started it is a lot to take in at first.  In the long run we have found that maintaining the lifecycle of these configs in this manor works better and it is actually less for us to maintain.

## Git commit the Flux Operator items
Now that you have deployed Flux, you should check it into your repository.

Your current path: `/<root of the project>`
Change directory to: `./kubernetes/helm/flux`

```
git add .
git commit -m 'Adding Flux Operator' -a
git push origin master
```

You an alternatively push to another branch and open a PR for merging into the `master` branch.

# Kubernetes Common Services
We are at a point now to start adding services/applications that we want to be deployed into our Kubernetes cluster and have Flux sync it over there.

Your current path: `/<root of the project>`
Change directory to: `./kubernetes/flux/releases`

There are some pre-requisites for certain items such as an access key for the service to perform it's job.  For example, the `external-dns` needs access to your DNS provider to be able to set the DNS.

While technically there is an order you should install these items the GitOps workflow helps us to retry the applying of these resources until it all eventually succeeds.  An example of an ordering dependency is the `nginx-ingress`'s Prometheus metrics.  In this project, the base values of the `nginx-ingress` has this enabled.  For most standard installs you will want this enabled since it gives you a lot of valuable metrics on how the nginx is performing and how your applications going through this nginx is performing as well.  You get metrics such as number of 2xx, 4xx, 5xx and repsonse times for every single route.  As the name of this implies that it is a Prometheus metrics and under the covers it uses the Prometheus `ServiceMonitor` CRDs to tell Prometheus to scrape it and collect it's metrics.  This means that Prometheus has to be installed first or installation of the `nginx-ingress` Helm chart will fail.  With the GitOps workflow, it is fine to install it before Prometheus is installed.  The GitOps workflow will try to install the `nginx-ingress` and fail and then it will try again during the next sync period.  While it is trying Prometheus will be installed and started up and once this dependency is forefilled, the `nginx-ingress` will be able to install.

## Required files

### `.flux.yaml`
There is a `.flux.yaml` at the `kubernetes/flux/releases/.flux.yaml` path.  This is a required file for Flux to work correctly with this setup.  This is telling Flux that we are using `kustomize` for templating (explained in the next section).  Without this file this setup will not work.

### kustomize
We are using [https://github.com/kubernetes-sigs/kustomize](kustomize) to help us template the Kubernetes yaml files that are applied to our cluster(s).  You might be wondering why we are using `kustomize` when we are already using Helm Charts and isn't that doing templating as well?  The short answer is, yes, the Helm Charts is taking in values we want to give it for each environment and then inserting those values into it's template for the app (eg: external-dns, cert-manager, nginx-ingress, etc).  However, we have the Flux Kubernetes yaml files that we have to apply onto the Kubernetes cluster so that Flux can launch the Helm Chart via the `HelmRelease` (explained in the next section) and we are giving the `HelmRelease`' values to use.  Some of these values are common among all environments and some are different for an environment.  We are using `kustomize` to help us combine the `base` values and the environment local specific values together for Flux to apply.

Doesn't this make it more complex?  

Short answer is yes.  However, we think that this added complexity is worth the trade off on what it gets us.  

What does this get us?
* Keeping the configuration DRY (Don't Repeat Yourself).  There can be large blocks of configuration that is common to all environments and we want to reduce the copy and pasting to a minimum.
* Allows us to run linting tools locally to make sure what we are changing is valid and that Flux will be able to apply it

### HelmRelease files
A short description of a `HelmRelease` is, it is a Flux CRD that gives it Helm information so that Flux can deploy a Helm chart.  The information it contains are items such as, source Chart repository URL, name, version, and values.  Flux uses this information so it can go and download the chart and deploy it out with the settings and values you want.

This doc will not try to go into all the details and will refer you to the official docs: [https://docs.fluxcd.io/projects/helm-operator/en/stable/helmrelease-guide/introduction/](Helm Docs).

## Add in an easy example service: sealed-secrets
Let's walk through adding one of the easier service with no dependencies like keys or something that has to be installed prior.  This should give you the feel of the steps necessary to add in one or an additional service.

`sealed-secrets` is a service that gives you the ability to encrypt a secret that only the `sealed-secrets` operator running inside of your cluster can decrypt (the private key is located inside of your cluster).  What this allows you to do is to encrypt the secret and then check the encrypted secret into your git repository (even if it is a public repository) safely.  You will only be able to decrypt the secret if you had access to the private key on the cluster.    

What are the files you would have to check in for Flux to deploy `sealed-secrets` out?  

Given you forefilled the requirements above on the `.flux.yaml` file.

Your current path: `/<root of the project>`
Change directory to: `./kubernetes/flux/releases/gcp/dev`

You need these file:
```
.
├── kustomization.yaml
├── namespaces
│   ├── kustomization.yaml
│   ├── sealed-secrets.yaml
└── sealed-secrets
    ├── helmrelease.yaml
    └── kustomization.yaml
```

You can all of these files as is except the `namespaces/kustomization.yaml` file.  The content should be:

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
# - ingress.yaml
# - monitoring.yaml
# - cert-manager.yaml
# - test1.yaml
# - external-dns.yaml
# - loki.yaml
# - lyfted.yaml
# - http-echo.yaml
- sealed-secrets.yaml
```

Everything is commented out (will be needed for future use) except for the the `sealed-secrets.yaml` file.

### Check to make sure everything is in place
At this point, you can run `kustomize` to see if most of the files are in the correct location and it can template it out.

Your current path: `/<root of the project>`
Change directory to: `./kubernetes/flux/releases/gcp/dev`

Run:
```
kustomize build .
```

You should see:
```
apiVersion: v1
kind: Namespace
metadata:
  labels:
    name: sealed-secrets
  name: sealed-secrets
---
apiVersion: helm.fluxcd.io/v1
kind: HelmRelease
metadata:
  name: sealed-secrets
  namespace: sealed-secrets
spec:
  chart:
    name: sealed-secrets
    repository: https://kubernetes-charts.storage.googleapis.com/
    version: 1.8.0
  helmVersion: v3
  releaseName: sealed-secrets
```

You might have noticed that it really doesn't have anything to really template out.  `kustomize` is not referencing any base or anything like that and this is true.  What the action we just did tell us is that the `kustomize` files are in the correct locations and that it can do it's job.  This is a very good indicator we are on the correct path and if we checked these items into git, Flux would be able to deploy this out to our cluster.

### Git commit files
We will need to commit these files into our repo for Flux to be able to read them and deploy them out onto our cluster.

Your current path: `/<root of the project>`
Change directory to: `./kubernetes/flux/releases/gcp/dev`

```
git add .
git commit -m 'Adding sealed-secrets' -a
git push origin master
```

You an alternatively push to another branch and open a PR for merging into the `master` branch.

**Note**: We set (above) our Flux Operator to look for changes on the `master` branch at this path.  Flux will not do anything or have anything to apply until thse files show up on the branch and path you set it to watch.

Now we just have to wait a while or run the `fluxctl` command to force it to sync.

```
fluxctl --k8s-fwd-ns flux sync
```

### Check if Flux deployed our service
The first thing to check is if the namespace exist or not.  Without the namespace, nothing else can deploy because it wants to deploy into the `sealed-secrets` namespace:

```
kubectl get namespaces
NAME              STATUS   AGE
...
...
sealed-secrets    Active   2m58s
```

You should see the `sealed-secrets` namespace.

Let's check if the Flux Helm Operator deployed out our `sealed-secrets` Helm chart

```
kubectl -n sealed-secrets get helmrelease
NAME             RELEASE          PHASE       STATUS     MESSAGE                                                                         AGE
sealed-secrets   sealed-secrets   Succeeded   deployed   Release was successful for Helm release 'sealed-secrets' in 'sealed-secrets'.   21s
```

The `STATUS` is `deployed` which is good and the message looks all good as well.

We can finally take a look at what pods the Helm Chart created:

```
kubectl -n sealed-secrets get pods
NAME                              READY   STATUS    RESTARTS   AGE
sealed-secrets-6c5f7d8df9-k5w4c   1/1     Running   0          13m
```

This is all looking good.

Those are the basic procedure for adding in a simple chart and how to check to make sure it is working.

## Add in a service that uses an encrypted secret and the kustomize base values: external-dns
This next example is a more complex because it builds on the functionality that we have installed in this cluster (sealed-secrets) and it uses the `base` kustomize values to help it do the templating of the `HelmRelease` yaml file.

### Create an AWS user and keys with access to the DNS
The `external-dns` service needs access to be able to control your DNS.  In this example, we are going to assume your DNS is in AWS Route53.  Create a user and generate the AWS access keys for it.

This is the IAM policy for this user: https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md#iam-policy

### Create the sealed secret with the access key information

#### GCP

#### AWS
Your current path: `/<root of the project>`
Change directory to: `./kubernetes/flux/releases/aws/dev/external-dns`

```
# Secret source information
NAMESPACE=external-dns
SECRET_NAME=tmp_kubernetes_secret.json
FILE_PATH=$PWD
PUB_CERT=$PWD/pub-cert.pem
KUBESEAL_SECRET_OUTPUT_FILE=credentials.yaml

AWS_ACCESS_KEY_ID=<Your AWS ACCESS KEY>
AWS_SECRET_ACCESS_KEY=<Your AWS SECRET ACCESS KEY>
```

Fetch the `sealed-secret` public cert:
```
kubeseal --fetch-cert \
--controller-namespace=sealed-secrets \
--controller-name=sealed-secrets \
> pub-cert.pem
```
This is the public cert side of the private/public cert.  This does not have to be treated as a secret and can be checked into your git repository if you wanted to.  You encrypt with this public cert and only the private cert side can decrypt what this public cert has encrypted.

Output a temporary file that contains your AWS keys in the AWS `credentials` file [format](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html):
```
cat <<EOT >> credentials
[default]
aws_access_key_id=${AWS_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}
EOT
```

This will output a temporary Kubernetes secret file that we will give to `sealed-secrets` to encrypt:
```
kubectl -n ${NAMESPACE} create secret generic credentials \
--from-file=${FILE_PATH}/credentials \
--dry-run \
-o json > ${SECRET_NAME}
```

Use the `kubeseal` CLI to encrypt the previously generated Kubernetes secret into a `sealed-secrets` CRD format:
```
kubeseal --format=yaml --cert=${PUB_CERT} < ${SECRET_NAME} > ${KUBESEAL_SECRET_OUTPUT_FILE}
```

Clean up temporary files:
```
rm pub-cert.pem
rm ${SECRET_NAME}
rm credentials
```

### Edit this environments `kustomization.yaml` file to add in the `external-dns` folder

Your current path: `/<root of the project>`
Change directory to: `./kubernetes/flux/releases/gcp/dev`

Edit the file: `kustomization.yaml`

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- external-dns
- namespaces
- sealed-secrets
```

We are going to add in the `external-dns` directory to the list of directories that `kustomize` should template.

We will also need to update the `namespaces/kustomization.yaml` file to uncomment (or add in) the `external-dns.yaml` namespace file so that it adds this into the `kustomize` template output.

Edit the file: `namespaces/kustomization.yaml`

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
# - ingress.yaml
# - monitoring.yaml
# - cert-manager.yaml
# - test1.yaml
- external-dns.yaml
# - loki.yaml
# - lyfted.yaml
# - http-echo.yaml
- sealed-secrets.yaml
```

### Check to make sure everything is in place
At this point, you can run `kustomize` to see if most of the files are in the correct location and it can template it out.

Your current path: `/<root of the project>`
Change directory to: `./kubernetes/flux/releases/gcp/dev`

Run:
```
kustomize build .
```

A few things to note:
* The `external-dns` namespace is in the output
* The `external-dns` `HelmRelease` is in the output
* The `sealed-secrets` items we had previously should be there as well

These are all of the items that the Flux Operator will deploy into our cluster after we push this into the `master` branch.

### Git commit files
We will need to commit these files into our repo for Flux to be able to read them and deploy them out onto our cluster.

Your current path: `/<root of the project>`
Change directory to: `./kubernetes/flux/releases`

Files to check in and update:
```
.
├── aws
│   └── dev
│       ├── external-dns
│       │   ├── credentials.yaml
│       │   ├── helmrelease.yaml
│       │   └── kustomization.yaml
│       ├── kustomization.yaml
│       ├── namespaces
│       │   ├── external-dns.yaml
│       │   ├── kustomization.yaml            <---An update to this file to uncomment the `external-dns.yaml` in the list
├── base
│   ├── external-dns
│   │   ├── helmrelease.yaml
│   │   └── kustomization.yaml
```

Add files:
```
git add gcp/staging/external-dns
```

Show what files were added and modified:
```
git status -s
A  gcp/dev/external-dns/credentials.yaml
A  gcp/dev/external-dns/helmrelease.yaml
A  gcp/dev/external-dns/kustomization.yaml
 M gcp/dev/kustomization.yaml
A  gcp/dev/namespaces/external-dns.yaml
 M gcp/dev/namespaces/kustomization.yaml
A  base/external-dns/helmrelease.yaml
A  base/external-dns/kustomization.yaml
```

Commit and push the changes into the repository to the `master` branch:
```
git commit -m 'Adding external-dns' -a
git push origin master
```

**Note**: We set (above) our Flux Operator to look for changes on the `master` branch at this path.  Flux will not do anything or have anything to apply until thse files show up on the branch and path you set it to watch.

Now we just have to wait a while or run the `fluxctl` command to force it to sync.

```
fluxctl --k8s-fwd-ns flux sync
```

## Cert-Manager
The `cert-manager` service helps you to automate the workflow of getting and renewing certs from [Let's Encrypt](https://letsencrypt.org/).

In our usage there are two parts to this.  The `cert-manager` Operator and the `cluster-issuer` which helps you to easily create `cluster-issuers` which are the `cert-manager'`s CRDs for how to get a cert via Let's Encrypt.  There is an HTTP and a DNS challenge method.  The HTTP method will expose an endpoint to the internet and Let's Encrypt will try to reach this endpoint to make sure that you own the domain before issuing you a SSL/TLS cert for the domain you asked for. The DNS method will ask you to set a DNS record with some random text that Let's Encrypt provides.  Let's Encrypt will then verify it can find this DNS TXT entry via the public DNS to verify that you own this domain before issuing a certificate.

### Add the cert-manager

Your current path: `/<root of the project>`
Change directory to: `./kubernetes/flux/releases`

Files you will need:
```
├── base
│   ├── cert-manager
│   │   ├── cert-manager
│   │   │   ├── crds
│   │   │   │   ├── certificaterequests.yaml
│   │   │   │   ├── certificates.yaml
│   │   │   │   ├── challenges.yaml
│   │   │   │   ├── clusterissuers.yaml
│   │   │   │   ├── issuers.yaml
│   │   │   │   ├── kustomization.yaml
│   │   │   │   └── orders.yaml
│   │   │   ├── helmrelease.yaml
│   │   │   └── kustomization.yaml
│   │   └── kustomization.yaml
├── gcp
│       ├── cert-manager
│       │   ├── cert-manager
│       │   │   ├── crds
│       │   │   │   ├── certificaterequests.yaml
│       │   │   │   ├── certificates.yaml
│       │   │   │   ├── challenges.yaml
│       │   │   │   ├── clusterissuers.yaml
│       │   │   │   ├── issuers.yaml
│       │   │   │   ├── kustomization.yaml
│       │   │   │   └── orders.yaml
│       │   │   ├── helmrelease.yaml
│       │   │   └── kustomization.yaml
│       ├── namespaces
│       │   ├── cert-manager.yaml
│       │   ├── kustomization.yaml
```

Copy these files over to your repository.

### Edit this environments `kustomization.yaml` file to add in the `cert-manager` folder

Your current path: `/<root of the project>`
Change directory to: `./kubernetes/flux/releases/gcp/dev`

Edit the file: `kustomization.yaml`

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- cert-manager
- external-dns
- namespaces
- sealed-secrets
```

We are going to add in the `cert-manager`'s directory to the list of directories that `kustomize` should template.

We will also need to update the `namespaces/kustomization.yaml` file to uncomment (or add in) the `cert-manager.yaml` namespace file so that it adds this into the `kustomize` template output.

Edit the file: `namespaces/kustomization.yaml`

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
# - ingress.yaml
# - monitoring.yaml
- cert-manager.yaml
# - test1.yaml
- external-dns.yaml
# - loki.yaml
# - lyfted.yaml
# - http-echo.yaml
- sealed-secrets.yaml
```

### Check to make sure everything is in place
At this point, you can run `kustomize` to see if most of the files are in the correct location and it can template it out.

Your current path: `/<root of the project>`
Change directory to: `./kubernetes/flux/releases/gcp/dev`

Run:
```
kustomize build .
```

A few things to note:
* The output will now be really long and hard to go through.  You can grep for `cert-manager` to spot check
* The `external-dns` items we had previously should be there as well
* The `sealed-secrets` items we had previously should be there as well

These are all of the items that the Flux Operator will deploy into our cluster after we push this into the `master` branch.


### Git commit files
Your current path: `/<root of the project>`
Change directory to: `./kubernetes/flux/releases`

```
git status -s
 M gcp/dev/kustomization.yaml
A  gcp/dev/cert-manager/kustomization.yaml
A  gcp/dev/cert-manager/cert-manager/crds/certificaterequests.yaml
A  gcp/dev/cert-manager/cert-manager/crds/certificates.yaml
A  gcp/dev/cert-manager/cert-manager/crds/challenges.yaml
A  gcp/dev/cert-manager/cert-manager/crds/clusterissuers.yaml
A  gcp/dev/cert-manager/cert-manager/crds/issuers.yaml
A  gcp/dev/cert-manager/cert-manager/crds/kustomization.yaml
A  gcp/dev/cert-manager/cert-manager/crds/orders.yaml
A  gcp/dev/cert-manager/cert-manager/helmrelease.yaml
A  gcp/dev/cert-manager/cert-manager/kustomization.yaml
A  gcp/dev/namespaces/cert-manager.yaml
 M gcp/dev/namespaces/kustomization.yaml
A  base/cert-manager/cert-manager/crds/certificaterequests.yaml
A  base/cert-manager/cert-manager/crds/certificates.yaml
A  base/cert-manager/cert-manager/crds/challenges.yaml
A  base/cert-manager/cert-manager/crds/clusterissuers.yaml
A  base/cert-manager/cert-manager/crds/issuers.yaml
A  base/cert-manager/cert-manager/crds/kustomization.yaml
A  base/cert-manager/cert-manager/crds/orders.yaml
A  base/cert-manager/cert-manager/helmrelease.yaml
A  base/cert-manager/cert-manager/kustomization.yaml
```

Commit and push the changes into the repository to the `master` branch:
```
git commit -m 'Adding cert-manager' -a
git push origin master
```

**Note**: We set (above) our Flux Operator to look for changes on the `master` branch at this path.  Flux will not do anything or have anything to apply until thse files show up on the branch and path you set it to watch.

Now we just have to wait a while or run the `fluxctl` command to force it to sync.

```
fluxctl --k8s-fwd-ns flux sync
```

### Add the cert-manager's cluster-issuers helper chart

Your current path: `/<root of the project>`
Change directory to: `./kubernetes/flux/releases`

This is the IAM policy for this user: https://cert-manager.io/docs/configuration/acme/dns01/route53/#set-up-a-iam-role

### Create the sealed secret with the access key information

#### GCP

#### AWS
Your current path: `/<root of the project>`
Change directory to: `./kubernetes/flux/releases/aws/dev/cert-manager/cluster-issuer`

```
# Secret source information
NAMESPACE=cert-manager
SECRET_NAME=tmp_kubernetes_secret.json
FILE_PATH=$PWD
PUB_CERT=$PWD/pub-cert.pem
KUBESEAL_SECRET_OUTPUT_FILE=credentials.yaml

AWS_ACCESS_KEY_ID=<Your AWS ACCESS KEY>
AWS_SECRET_ACCESS_KEY=<Your AWS SECRET ACCESS KEY>
```

Fetch the `sealed-secret` public cert:
```
kubeseal --fetch-cert \
--controller-namespace=sealed-secrets \
--controller-name=sealed-secrets \
> pub-cert.pem
```
This is the public cert side of the private/public cert.  This does not have to be treated as a secret and can be checked into your git repository if you wanted to.  You encrypt with this public cert and only the private cert side can decrypt what this public cert has encrypted.

This will output a temporary Kubernetes secret file that we will give to `sealed-secrets` to encrypt:
```
kubectl -n ${NAMESPACE} create secret generic aws-route53-credentials-secret --from-literal=secret-access-key=${AWS_SECRET_ACCESS_KEY} --dry-run -o json > ${SECRET_NAME}
```

Use the `kubeseal` CLI to encrypt the previously generated Kubernetes secret into a `sealed-secrets` CRD format:
```
kubeseal --format=yaml --cert=${PUB_CERT} < ${SECRET_NAME} > ${KUBESEAL_SECRET_OUTPUT_FILE}
```

Clean up temporary files:
```
rm pub-cert.pem
rm ${SECRET_NAME}
```

### Check to make sure everything is in place
At this point, you can run `kustomize` to see if most of the files are in the correct location and it can template it out.

Your current path: `/<root of the project>`
Change directory to: `./kubernetes/flux/releases/gcp/dev`

Run:
```
kustomize build .
```

A few things to note:
* The output will now be really long and hard to go through.  You can grep for `cert-manager` and `cluster-issuer` to spot check
* The `external-dns` items we had previously should be there as well
* The `sealed-secrets` items we had previously should be there as well

These are all of the items that the Flux Operator will deploy into our cluster after we push this into the `master` branch.


### Git commit files
Your current path: `/<root of the project>`
Change directory to: `./kubernetes/flux/releases`

```
git status -s
A  gcp/dev/cert-manager/cluster-issuer/credentials.yaml
A  gcp/dev/cert-manager/cluster-issuer/helmrelease.yaml
A  gcp/dev/cert-manager/cluster-issuer/kustomization.yaml
M  gcp/dev/cert-manager/kustomization.yaml
A  base/cert-manager/cluster-issuer/helmrelease.yaml
A  base/cert-manager/cluster-issuer/kustomization.yaml
```

Commit and push the changes into the repository to the `master` branch:
```
git commit -m 'Adding cluster-issuer' -a
git push origin master
```

**Note**: We set (above) our Flux Operator to look for changes on the `master` branch at this path.  Flux will not do anything or have anything to apply until thse files show up on the branch and path you set it to watch.

Now we just have to wait a while or run the `fluxctl` command to force it to sync.

```
fluxctl --k8s-fwd-ns flux sync
```

## Prometheus Operator
The `prometheus-operator` monitors this cluster.

Your current path: `/<root of the project>`
Change directory to: `./kubernetes/flux/releases`

### Uncomment the namespace
This will be installed in the `monitoring` namespace.  We will need to uncomment the `monitoring.yaml` in the `gcp/dev/namespaces/kustomization.yaml` file so that it will add this file to it's output.

### add folder into the environment's `kustomization.yaml` file
```
├── gcp
│   ├── dev
│       ├── kustomization.yaml
```

Add `prometheus-operator` folder to the resource list:
```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- cert-manager
- external-dns
- namespaces
# - nginx-ingress/external
- prometheus-operator
- sealed-secrets
```

### Copy files to your repository
Copy these files to your repository:

```
├── gcp
│   ├── dev
│       ├── kustomization.yaml
│       ├── namespaces
│       │   ├── kustomization.yaml
│       │   ├── monitoring.yaml
│       ├── prometheus-operator
│       │   ├── certificate.yaml
│       │   ├── helmrelease.yaml
│       │   └── kustomization.yaml
├── base
│   └── prometheus-operator
│       ├── certificate.yaml
│       ├── helmrelease.yaml
│       └── kustomization.yaml
```

### Check to make sure everything is in place
At this point, you can run `kustomize` to see if most of the files are in the correct location and it can template it out.

Your current path: `/<root of the project>`
Change directory to: `./kubernetes/flux/releases/gcp/dev`

Run:
```
kustomize build .
```

A few things to note:
* The output will be very long
* Grep for `prometheus`.  Should see some output about it
* Grep for `cert-manager` and `cluster-issuer` to spot check
* The `external-dns` items we had previously should be there as well
* The `sealed-secrets` items we had previously should be there as well

These are all of the items that the Flux Operator will deploy into our cluster after we push this into the `master` branch.

### Git commit files
Your current path: `/<root of the project>`
Change directory to: `./kubernetes/flux/releases`

```
git status -s
 M gcp/dev/kustomization.yaml
 M gcp/dev/namespaces/kustomization.yaml
A  gcp/dev/prometheus-operator/certificate.yaml
A  gcp/dev/prometheus-operator/helmrelease.yaml
A  gcp/dev/prometheus-operator/kustomization.yaml
A  base/prometheus-operator/certificate.yaml
A  base/prometheus-operator/helmrelease.yaml
A  base/prometheus-operator/kustomization.yaml
```

Commit and push the changes into the repository to the `master` branch:
```
git commit -m 'Adding prometheus-operator' -a
git push origin master
```

**Note**: We set (above) our Flux Operator to look for changes on the `master` branch at this path.  Flux will not do anything or have anything to apply until thse files show up on the branch and path you set it to watch.

Now we just have to wait a while or run the `fluxctl` command to force it to sync.

```
fluxctl --k8s-fwd-ns flux sync
```

## nginx-ingress
The nginx ingress will create us a cloud loadbalancer that will be able to get traffic from the internet into our cluster.


Your current path: `/<root of the project>`
Change directory to: `./kubernetes/flux/releases`

### Uncomment the namespace
This will be installed in the `ingress` namespace.  We will need to uncomment the `ingress.yaml` in the `gcp/dev/namespaces/kustomization.yaml` file so that it will add this file to it's output.

### add folder into the environment's `kustomization.yaml` file
```
├── gcp
│   ├── dev
│       ├── kustomization.yaml
```

Add `prometheus-operator` folder to the resource list:
```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- cert-manager
- external-dns
- namespaces
- nginx-ingress/external
- prometheus-operator
- sealed-secrets
```

### Copy files to your repository
Copy these files to your repository:

```
├── aws
│   ├── dev
│       ├── namespaces
│       │   ├── ingress.yaml
│       │   ├── kustomization.yaml
│       ├── nginx-ingress
│       │   └── external
│       │       ├── helmrelease.yaml
│       │       └── kustomization.yaml
├── base
│   ├── nginx-ingress
│   │   └── external
│   │       ├── helmrelease.yaml
│   │       └── kustomization.yaml
```

### Check to make sure everything is in place
At this point, you can run `kustomize` to see if most of the files are in the correct location and it can template it out.

Your current path: `/<root of the project>`
Change directory to: `./kubernetes/flux/releases/gcp/dev`

Run:
```
kustomize build .
```

A few things to note:
* The output will be very long
* Grep for `ingress-controller-leader-external`.  Tihs is a specific output that will be in the nginx-ingress output
* Grep for `prometheus`.  Should see some output about it
* Grep for `cert-manager` and `cluster-issuer` to spot check
* The `external-dns` items we had previously should be there as well
* The `sealed-secrets` items we had previously should be there as well

These are all of the items that the Flux Operator will deploy into our cluster after we push this into the `master` branch.

### Git commit files
Your current path: `/<root of the project>`
Change directory to: `./kubernetes/flux/releases`

```
git status -s
 M gcp/dev/kustomization.yaml
A  gcp/dev/nginx-ingress/external/helmrelease.yaml
A  gcp/dev/nginx-ingress/external/kustomization.yaml
 M gcp/dev/namespaces/kustomization.yaml
A  base/nginx-ingress/external/helmrelease.yaml
A  base/nginx-ingress/external/kustomization.yaml
```

Commit and push the changes into the repository to the `master` branch:
```
git commit -m 'Adding nginx-ingressperator' -a
git push origin master
```

**Note**: We set (above) our Flux Operator to look for changes on the `master` branch at this path.  Flux will not do anything or have anything to apply until thse files show up on the branch and path you set it to watch.

Now we just have to wait a while or run the `fluxctl` command to force it to sync.

```
fluxctl --k8s-fwd-ns flux sync
```

### Check that it deployed

Should see the `ingress` namespace created:

```
kubectl get ns
NAME              STATUS   AGE
...
ingress           Active   15s
...
```

The Helm chart should be deployed out successfully:
```
kubectl -n ingress get hr
NAME                     RELEASE                  PHASE       STATUS     MESSAGE                                                                          AGE
nginx-ingress-external   nginx-ingress-external   Succeeded   deployed   Release was successful for Helm release 'nginx-ingress-external' in 'ingress'.   19s
```

We should see pods:
```
kubectl -n ingress get pods
NAME                                                      READY   STATUS    RESTARTS   AGE
nginx-ingress-external-controller-64cb7fdd-9bfw7          0/1     Running   0          19s
nginx-ingress-external-default-backend-6876b6655d-shlqb   1/1     Running   0          19s
```

We will see an `EXTERNAL-IP` in the field:
```
kubectl -n ingress get services (staging.us-east-1.k8s.local/default)
NAME                                        TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)                      AGE
nginx-ingress-external-controller           LoadBalancer   100.64.57.96     34.2.4.8   80:32318/TCP,443:30085/TCP   2m2s
nginx-ingress-external-controller-metrics   ClusterIP      100.71.237.81    <none>                                                                    9913/TCP                     2m2s
nginx-ingress-external-default-backend      ClusterIP      100.65.110.210   <none>                                                                    80/TCP                       2m2s
```

If we have been following the guide and have deployed out the `prometheus-operator`, we can get it's ingresses:
```
kubectl -n monitoring get ing   (staging.us-east-1.k8s.local/default)
NAME                               HOSTS                                          ADDRESS                                                                   PORTS     AGE
prometheus-operator-alertmanager   alertmanager.internal.managedkube.com   34.2.4.8   80, 443   14m
prometheus-operator-grafana        grafana.internal.managedkube.com        34.2.4.8   80, 443   14m
prometheus-operator-prometheus     prometheus.internal.managedkube.com     34.2.4.8   80, 443   14m
```

There are a few things to note here:
* The `ADDRESS` column should match the `EXTERNAL-IP` address from the previous output.  This means that this ingress is going to that cloud loadbalancer
* The `HOSTS` names should be in our DNS via the `external-dns`

We can try going to: http://prometheus.internal.managedkube.com

If will notice that it will automatically redirect us to an `https` SSL/TLS encrypted connection in the browser.
