# Using Flux with Kustomize

## Scenario and Goals

The following example makes use of Flux's manifest-generation feature
together with [Kustomize](https://github.com/kubernetes-sigs/kustomize) (and other such tooling, in theory).

For this example we assume an scenario with two clusters, `staging` and
`production`. The goal is to levarage the full functionality of Flux (including
automatic releases and supporting all `fluxctl` commands) to manage both
clusters while minimizing duplicated declarations.

`staging` and `production` are almost identical, they both deploy a
[`podinfo`](https://github.com/stefanprodan/k8s-podinfo) service. However, we
have different requirments for each cluster:

1. We want automated deployments for `staging` but not for `production` since we want a rubber-stamp 
   every change. However, we want to still be able to make the changes with `fluxctl`.
2. Since we expect `production` to have a higher load than `staging`, we want a higher replica range there.

## How to run the example

In order to run this example, you need to:

1. Deploy Flux version 1.13.0 or newer.

2. Make sure to pass the flag `--manifest-generation=true` to fluxd, in its container spec.

3. Fork this repository and add the fork's URL as the `--git-url` flag for the fluxd container.

4. Pick an environment to run (`staging` or `production`) and ask Flux to use
that environment by passing flag `--git-path=staging` or `--git-path=production`

5. As usual, you need to make sure that the ssh key shown by `fluxctl identity`
is added to the your github fork.

## How does this example work?

```
├── .flux.yaml
├── base
│   ├── demo-ns.yaml
│   ├── kustomization.yaml
│   ├── podinfo-dep.yaml
│   ├── podinfo-hpa.yaml
│   └── podinfo-svc.yaml
├── staging
│   ├── flux-patch.yaml
│   └── kustomization.yaml
└── production
    ├── flux-patch.yaml
    ├── kustomization.yaml
    └── replicas-patch.yaml
```

* `base` contains the base manifests. The resources to be deployed in 
  `staging` and `production` are almost identical to the ones described here.
* the `staging` and `production` directories make use of `base`, with a few patches, 
  to generate the final manifests for each environment:
    * `staging/kustomization.yaml` and `production/kustomization.yaml`
       are Kustomize config files which indicate how to apply the patches.
    * `staging/flux-patch.yaml` and `production/flux-patch.yaml` contain
       environment-specific Flux [annotations](https://docs.fluxcd.io/en/latest/tutorials/driving-flux/)
       and the container images to be deployed in each environment.
    * `production/replicas-patch.yaml` increases the number of replicas of podinfo in production.
* `.flux.yaml` is used by Flux to generate and update manifests. 
  Its commands are run in the directory (`staging` or `production`). 
  In this particular case, `.flux.yaml` tells Flux to generate manifests running 
  `kustomize build` and update policy annotations and container images by editing 
  `flux-patch.yaml`, which will implicitly applied to the manifests generated with
  `kustomize build`.

## I want to know more

For a more sophisticated example of using Flux with Kustomize for creating a
multitenant cluster you can go to https://github.com/fluxcd/multi-tenancy .

For more details about how `.flux.yaml` files work  you can read the
[reference documentation](https://docs.fluxcd.io/en/latest/references/fluxyaml-config-files/)
