kustomize
=============

This project is using [kustomize](https://github.com/kubernetes-sigs/kustomize) to templatize the items that Flux uses.

# Why use kustomize?
Kustomize is doing two things for us in this project.  

The first is it helps us keep things DRY (Don't Repeat Yourself).  For configurations and settings that needs to be placed in multiple environments it can be defined once and then used in multiple places or a slight variation of it if the environment wants to only change certain aspects of the config.

The second is also keeping things DRY in the `HelmRelease` files.  Kustomize helps us to be able to define a `base` values that all environment inherits from merged in with what a single environment wants the settings to be.  For example, `nginx-ingress` has a lot of default settings like pod affinity rules and metrics that we want to set and enable on all environments.  These are fairly lengthy configs and we don't want to have to copy that from one environment to another.  With kustomize, we can define the common stuff in a directory named `base` which has all of the common items, and in each environment configs, it will take that and combine it with it's local environment settings. One example of a local environment setting is how many replicas you want running.  In dev there might be 2, in prod there might be 4.

# Troubleshooting

## Will this work in Flux?
One of the problems with GitOps and Flux in general is that you don't know if it will work.  Many things can go wrong when Flux tries to apply it.  There are a few things we can do to test locally if changes we made can at least lint out.

At the base of each environment, we should be able to run `kustomize build .` successfully without any errors.  By being able to run it successfully, it tells us that all of our configs lints out and is in the correct kustomize format.

### Run
Path: `kubernetes/flux/gcp/dev`

Run: `kustomize build .`

You will see a lot of yaml go buy.  This is a good thing.  This means that kustomize is able to walk all of the directories and template everything out.

If you get an error, then you are missing something and will have to debug the error.
