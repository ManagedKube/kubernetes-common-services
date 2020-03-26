Flux Usage
============
Flux will sync the Kubernetes yaml files in these directories to your Kubernetes cluster based on the path that you set your Flux operator to watch when you deployed it out.

You don't need to enable everything.  Only copy the services that you want to deploy out.

# Directory structures
There are two main directories here: `./kubernetes/flux` and `./kubernetes/helm`.

# Directory - ./kubernetes/flux
The `./kubernetes/flux` directory holds the Flux release material for each environment you have.  When you [installed Flux](/kubernetes/helm/flux/), in the `environments/<env name>/values.yaml` file, you specified what directory/path the Flux operator was looking at in your repository.  Flux will deploy everything out in this directory to your cluster.  

The Flux operator applies the items with `kubectl`.  This means that it has to be a valid Kubernetes resource and a format.  If you get an error running `kubectl appy -f <file>` on it, Flux will not be able to apply it either.

Since Flux only applies Kubernetes yamls, the Flux Helm Operator applies Helm deployments via the `helmrelease.yaml` files.  This is a Flux CRD that the Flux Helm Operator understands and acts on for deploying the described Helm deployment.

```
.
└── releases
    └── gcp                                             <-- The cloud you are in
        └── dev                                         <-- The environment name
        │   ├── external-dns                            <-- An app you want to deploy into the cluster
        │   │   ├── gcp-credentials-json.yaml           <-- A sealed-secret of the GCP credentails needed to manipulate CloudDNS
        │   │   ├── helmrelease.yaml                    <-- The Flux helm-operator's helmrelease file
        │   │   └── values.yaml                         <-- Values specific to the dev environment for the external-dns app
        │   ├── namespaces                              <-- Namespaces directory to hold all of the namespaces you want Flux to deploy out  
        │   │   ├── external-dns.yaml
        │   │   └── sealed-secrets.yaml
        │   └── sealed-secrets
        │       ├── cert-manager-issuers
        │       └── helmrelease.yaml
        └── prod                                        <-- The environment name
        │   ├── external-dns                            <-- An app you want to deploy into the cluster
        │   │   ├── gcp-credentials-json.yaml           <-- A sealed-secret of the GCP credentails needed to manipulate CloudDNS
        │   │   ├── helmrelease.yaml                    <-- The Flux helm-operator's helmrelease file
        │   │   └── values.yaml                         <-- Values specific to the dev environment for the external-dns app
        │   ├── namespaces                              <-- Namespaces directory to hold all of the namespaces you want Flux to deploy out
        ...
        ...
        ...      
```

# Directory - ./kubernetes/helm
The `./kubernetes/helm` holds the source chart files.  The `helmrelease.yaml` file points to this chart for deployment.  The `helmrelease.yaml` file only contains information about the Helm deployment and not the actual deployed material itself.  It has items like the name of it and the local values for that environment.

Let's take a look at a directory structure of one of the charts.  Here is the `external-dns` chart:

```
├── charts
│   └── external-dns-2.5.3.tgz         <-- Chart artifact from the upstream provider.  This holds the actual templates
├── Chart.yaml                         <-- The chart definition, version, and upstream location URL     
├── Makefile                           <-- Makefile for local chart operations
├── README.md
├── requirements.lock                  <-- Lock file on the charts version
└── values.yaml                        <-- Global default values for this chart that applies to all environments
```
