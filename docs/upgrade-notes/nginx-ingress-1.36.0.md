nginx-ingress upgrade to 1.36.0
=================================

Check the source chart for the latest update
* https://github.com/helm/charts/blob/master/stable/nginx-ingress/Chart.yaml#L3

Looking at what has changed with nginx-ingress and the various pull requests
* https://github.com/helm/charts/pulls?q=nginx-ingress

Checked out what version of the nginx-ingress controller we are running:
```yaml
kubectl -n ingress describe pod nginx-ingress-external-controller-64cb7fdd-5flfc
Name:         nginx-ingress-external-controller-64cb7fdd-5flfc
Namespace:    ingress
Priority:     0
Node:         gke-dev-pool-1-135cd9f3-z3mn/10.32.32.31
Start Time:   Fri, 10 Apr 2020 01:11:32 -0700
Labels:       app=nginx-ingress
              app.kubernetes.io/component=controller
              pod-template-hash=64cb7fdd
              release=nginx-ingress-external
Annotations:  cni.projectcalico.org/podIP: 10.36.0.18/32
Status:       Running
IP:           10.36.0.18
IPs:
  IP:           10.36.0.18
Controlled By:  ReplicaSet/nginx-ingress-external-controller-64cb7fdd
Containers:
  nginx-ingress-controller:
    Container ID:  docker://5e7399d86bf92ee9edc2fefb2330703f8ec7348823359643a2bfd6173ec3dbe1
    Image:         quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.30.
```

Looks like it came out two months ago and it is the latest:
* https://quay.io/repository/kubernetes-ingress-controller/nginx-ingress-controller?tag=latest&tab=tags

The commit with the version change:
* https://github.com/ManagedKube/kubernetes-common-services/commit/ec3c213238f9c4b246da8d05d06501e2164181b4

Helm updated the version:
```yaml
kubectl -n ingress describe hr                       
Name:         nginx-ingress-external
Namespace:    ingress
Labels:       fluxcd.io/sync-gc-mark=sha256.s2g1jYrfnvYE6erdy2_jDhusJi9qwWLlxmHyo5cxZYY
Annotations:  fluxcd.io/sync-checksum: 73cc5cabb6b734cc008ad900defd8be0852345fa
              kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"helm.fluxcd.io/v1","kind":"HelmRelease","metadata":{"annotations":{"fluxcd.io/sync-checksum":"73cc5cabb6b734cc008ad900defd8...
API Version:  helm.fluxcd.io/v1
Kind:         HelmRelease
Metadata:
  Creation Timestamp:  2020-03-28T03:52:14Z
  Generation:          2
  Resource Version:    18780307
  Self Link:           /apis/helm.fluxcd.io/v1/namespaces/ingress/helmreleases/nginx-ingress-external
  UID:                 9e827195-7eaf-44aa-85be-d617d6a5d0be
Spec:
  Chart:
    Name:        nginx-ingress
    Repository:  https://kubernetes-charts.storage.googleapis.com/
    Version:     1.36.0
  Helm Version:  v3
  Release Name:  nginx-ingress-external
  Values From:
    Config Map Key Ref:
      Key:       base-values.yaml
      Name:      helmrelease-base-values
      Optional:  false
    Config Map Key Ref:
      Key:       values.yaml
      Name:      helmrelease-env-values
      Optional:  false
Status:
  Conditions:
    Last Transition Time:  2020-04-10T08:17:51Z
    Last Update Time:      2020-04-12T17:54:30Z
    Message:               chart fetched: nginx-ingress-1.36.0.tgz
    Reason:                RepoChartInCache
    Status:                True
    Type:                  ChartFetched
    Last Transition Time:  2020-03-28T03:58:37Z
    Last Update Time:      2020-04-12T17:54:32Z
    Message:               Helm release sync succeeded
    Reason:                HelmSuccess
    Status:                True
    Type:                  Released
  Observed Generation:     2
  Release Name:            nginx-ingress-external
  Release Status:          deployed
  Revision:                1.36.0
Events:
  Type    Reason       Age                 From           Message
  ----    ------       ----                ----           -------
  Normal  ChartSynced  49s (x189 over 9h)  helm-operator  Chart managed by HelmRelease processed
```

```yaml
kubectl -n ingress get events                     
LAST SEEN   TYPE     REASON        OBJECT                                                       MESSAGE
3m27s       Normal   NoPods        poddisruptionbudget/nginx-ingress-external-controller        No matching pods found
99s         Normal   UPDATE        configmap/nginx-ingress-external-controller                  ConfigMap ingress/nginx-ingress-external-controller
99s         Normal   UPDATE        configmap/nginx-ingress-external-controller                  ConfigMap ingress/nginx-ingress-external-controller
3m27s       Normal   NoPods        poddisruptionbudget/nginx-ingress-external-default-backend   No matching pods found
97s         Normal   ChartSynced   helmrelease/nginx-ingress-external                           Chart managed by HelmRelease processed
```

The Helm chart successfully deployed to version 1.36.0:
```
helm -n ingress list   
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
nginx-ingress-external  ingress         2               2020-04-12 17:54:31.277774886 +0000 UTC deployed        nginx-ingress-1.36.0    0.30.0
```

The pods didn't roll so there were probably no changes to the nginx deployment specs:

```yaml
kubectl -n ingress get pods                             
NAME                                                      READY   STATUS    RESTARTS   AGE
nginx-ingress-external-controller-64cb7fdd-5flfc          1/1     Running   0          2d9h
nginx-ingress-external-controller-64cb7fdd-k8h6f          1/1     Running   0          2d9h
nginx-ingress-external-default-backend-6876b6655d-drbzq   1/1     Running   0          2d9h
nginx-ingress-external-default-backend-6876b6655d-frhxm   1/1     Running   0          2d9h
```

