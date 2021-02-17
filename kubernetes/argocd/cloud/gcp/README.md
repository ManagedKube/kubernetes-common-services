


This will point to the gcp dir and recursively sync everything over

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: k8s-infrastructure
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  # https://argoproj.github.io/argo-cd/user-guide/auto_sync/
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
  source:
    repoURL: https://github.com/ManagedKube/kubernetes-common-services.git
    targetRevision: HEAD
    path: kubernetes/argocd/cloud/gcp
    directory:
      recurse: true
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
```
