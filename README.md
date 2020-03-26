# kubernetes-common-services
These services help make it easier to manage your applications environment in Kubernetes.

When running your application in Kubernetes, you often add various open source applications to your cluster to help you do stuff such as automatically getting Let's Encrypt certificates for your HTTPS endpoints and automatically renewing them, automatically syncing DNS entries that you have on an ingress to your DNS provider, monitoring and alerting for your cluster, and many more items.

These are services are super fantastic and works really well but it takes time to set them up, integrate it into your cluster and then over the lifetime of it, you have to revisit each one to update them.  This is all undifferentiated heavy lifting that you shouldn't have to do.

This project maintains all of these open source applications for you so you don't have to do it.

![ManagedKube Kubernetes Common Services](./docs/common-services.png "ManagedKube Kubernetes Common Services")

# Table of Content
- [Supported Services](#supported-services)
- [How this works](#how-this-works)
- [What this project provides](#what-this-project-provides)
- [How to set this up](#how-to-set-this-up)
  * [Copy the items from this repository to your repository](#copy-the-items-from-this-repository-to-your-repository)
  * [Install the Flux Operators](#install-the-flux-operators)
  * [Deploy items into your Kubernetes cluster](#deploy-items-into-your-kubernetes-cluster)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>


# Supported Services

* [cert-manager](https://github.com/jetstack/cert-manager) (For HTTPS certs)
* [external-dns](https://github.com/helm/charts/tree/master/stable/external-dns) (manages your DNS automatically via annotations)
* [kube-metric-adapter](https://github.com/zalando-incubator/kube-metrics-adapter) (Scale by any Prometheus metrics)
* [nginx-ingress](https://github.com/helm/charts/tree/master/stable/nginx-ingress) (To expose HTTP services to consumers from outside of the cluster such as the internet)
* [prometheus-operator](https://github.com/helm/charts/tree/master/stable/prometheus-operator) (Monitoring and alerting for your cluster)
* [prometheus-blockbox-exporter](https://github.com/prometheus/blackbox_exporter) (checks on URLs)
* [sealed-secrets](https://github.com/bitnami-labs/sealed-secrets) (Keep your secrets encrypted in Git and delivered as secrets into Kubernetes)

If you don't see a service that you want to use but want us to support it, please open an issue in this project and let us know!

# How this works
We are leveraging [Weaveworks Flux](https://github.com/fluxcd/flux) to provide us with the GitOps workflow.  

![Weaveworks flux operator](./docs/images/fluxcd-helm-operator-diagram.png "Weaveworks Flux Operator")

# What this project provides
There is no magic here.  Everything in here you can do and everything we use is absolutely 100% open source.  The value add this project provides is an opinionated way of deploying these items and the curration of each service.  We put in the work to make sure everything is structured correctly, updated in a timely manor, and reasonably easy to use.  The other major piece is that we validate that these pieces are working in various types of Kubernetes clusters and cloud.  

# How to set this up

## Copy the items from this repository to your repository
To use these items, you need to copy the folder `<repo root>/kubernetes` to the root of your repository.  It has to be at the root of your repository because all of the paths are pointing from that fixed location.  You can change the location but then you will have to change various paths in the deployment files to point to the correct location.

You don't need to enable everything.  Only copy the services that you want to deploy out.

## Install the Flux Operators

There are detailed instructions on how to do this [here](./kubernetes/helm/flux/).

## Deploy items into your Kubernetes cluster

There are detailed instructions on how to do this [here](./kubernetes/flux/).

# Community

* Email: help@managedkube.com
* [@gar454 on Kubernetes Slack](https://app.slack.com/client/T09NY5SBT/D1QQUQEG1)
