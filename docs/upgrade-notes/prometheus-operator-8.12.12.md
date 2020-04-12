Prometheus Operator upgrade to 8.12.12
======================================

The latest version at the time of the writing is: `8.12.12`
* Versions can be found here: https://github.com/helm/charts/blob/master/stable/prometheus-operator/Chart.yaml#L15

Here is the commit to update the `prometheus-operator` Helm chart to version `8.12.12`: https://github.com/ManagedKube/kubernetes-common-services/commit/bb283b23ea918c96339818bb398863a7eb34f871

However, it looks like the update operation didn't fully work:

```yaml
 kubectl -n monitoring describe hr                       
Name:         prometheus-operator
Namespace:    monitoring
Labels:       fluxcd.io/sync-gc-mark=sha256.1g1AWjFhC1miidT8l5yKS2Euq7YoyocsQAO1pl4bnsY
Annotations:  fluxcd.io/sync-checksum: 14185d6cbb6357633ce002ed5534b5f1642e09eb
              kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"helm.fluxcd.io/v1","kind":"HelmRelease","metadata":{"annotations":{"fluxcd.io/sync-checksum":"14185d6cbb6357633ce002ed5534b...
API Version:  helm.fluxcd.io/v1
Kind:         HelmRelease
Metadata:
  Creation Timestamp:  2020-03-28T04:22:18Z
  Generation:          3
  Resource Version:    18745236
  Self Link:           /apis/helm.fluxcd.io/v1/namespaces/monitoring/helmreleases/prometheus-operator
  UID:                 d3951886-9217-4347-b9b1-4ba8fb174952
Spec:
  Chart:
    Name:        prometheus-operator
    Repository:  https://kubernetes-charts.storage.googleapis.com/
    Version:     8.12.12
  Helm Version:  v3
  Release Name:  prometheus-operator
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
    Last Transition Time:  2020-04-12T08:35:22Z
    Last Update Time:      2020-04-12T16:14:18Z
    Message:               chart fetched: prometheus-operator-8.12.12.tgz
    Reason:                RepoChartInCache
    Status:                True
    Type:                  ChartFetched
    Last Transition Time:  2020-04-12T16:16:43Z
    Last Update Time:      2020-04-12T16:16:43Z
    Message:               failed to upgrade chart for release [prometheus-operator]: failed to create resource: Timeout: request did not complete within requested timeout
    Reason:                HelmUpgradeFailed
    Status:                False
    Type:                  Released
  Observed Generation:     3
  Release Name:            prometheus-operator
  Release Status:          failed
  Revision:                8.11.1
Events:
  Type    Reason       Age                      From           Message
  ----    ------       ----                     ----           -------
  Normal  ChartSynced  2m36s (x155 over 7h46m)  helm-operator  Chart managed by HelmRelease processed
```

Something about a `Timeout` from the `HelmRelease`
```
      Message:               failed to upgrade chart for release [prometheus-operator]: failed to create resource: Timeout: request did not complete within requested timeout
```

Looking at the logs from the Flux Helm Operator, it sounds like it can't sync the `status` field for some reason:

```
kubectl -n flux logs helm-operator-77cb687cc7-4dz7q --since 1h | grep prom
...
...
ts=2020-04-12T16:59:10.30924419Z caller=release.go:347 component=release release=prometheus-operator targetNamespace=monitoring resource=monitoring:helmrelease/prometheus-operator helmVersion=v3 warning="unable to sync release with status failed" action=skip
...
...
```

Looking at Helm, the update `failed`!
```
helm -n monitoring list
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS  CHART                           APP VERSION
prometheus-operator     monitoring      3               2020-04-12 16:14:21.071440988 +0000 UTC failed  prometheus-operator-8.12.12     0.37.0 
```

And the pods did roll in with the new updates (can tell by the pods restarting recently):
```
kubectl -n monitoring get pods 
NAME                                                      READY   STATUS    RESTARTS   AGE
alertmanager-prometheus-operator-alertmanager-0           2/2     Running   0          2d9h
prometheus-operator-grafana-56c5dd798c-tnzhx              2/2     Running   0          61m
prometheus-operator-kube-state-metrics-868fb5d6d4-zr4mf   1/1     Running   0          2d9h
prometheus-operator-operator-c5576c965-sxdtq              2/2     Running   0          61m
prometheus-operator-prometheus-node-exporter-bcsn5        1/1     Running   0          61m
prometheus-prometheus-operator-prometheus-0               3/3     Running   1          60m
```

It seems like the Flux `HelmRelease` error, did not prevent it from updating the prometheus-operator Helm chart.  Looking at the Flux Helm Operator's Github issues, this did come up:  https://github.com/fluxcd/helm-operator/issues/144

It looks like it is a Helm issue and not a Flux issue.  The issues seems to be that this chart is taking a long time to apply and Helm holds a connection open to the Kube API and the Kube API eventually closes the connection because there is no traffic going through it.

To test this theory out, I am deleting the prometheus-operator Helm chart from the cluster:
```
helm -n monitoring delete prometheus-operator
release "prometheus-operator" uninstalled
```

If the initial install does not take long, then it will succeed and this might be an update issue for the prometheus-operator only.

Waiting a few minutes, the prometheus-operator is deployed back out in a successful deployment:

```
helm -n monitoring list
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                           APP VERSION
prometheus-operator     monitoring      1               2020-04-12 18:05:11.584522845 +0000 UTC deployed        prometheus-operator-8.12.12     0.37.0
```

This looks to be like an update issue only.

Testing a manual upgrade with no changes to see what would happen.

```
helm -n monitoring upgrade prometheus-operator stable/prometheus-operator
coalesce.go:196: warning: cannot overwrite table with non table for storageSpec (map[])
coalesce.go:196: warning: cannot overwrite table with non table for storageSpec (map[])
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"

Error: UPGRADE FAILED: cannot patch "prometheus-operator-alertmanager.rules" with kind PrometheusRule: Timeout: request did not complete within requested timeout 30s && cannot patch "prometheus-operator-general.rules" with kind PrometheusRule: context deadline exceeded && cannot patch "prometheus-operator-k8s.rules" with kind PrometheusRule: Timeout: request did not complete within requested timeout 30s && cannot patch "prometheus-operator-kube-apiserver-error" with kind PrometheusRule: Timeout: request did not complete within requested timeout 30s && cannot patch "prometheus-operator-kube-apiserver.rules" with kind PrometheusRule: context deadline exceeded && cannot patch "prometheus-operator-kube-prometheus-node-recording.rules" with kind PrometheusRule: Timeout: request did not complete within requested timeout 30s && cannot patch "prometheus-operator-kube-scheduler.rules" with kind PrometheusRule: Timeout: request did not complete within requested timeout 30s && cannot patch "prometheus-operator-kubernetes-absent" with kind PrometheusRule: Timeout: request did not complete within requested timeout 30s && cannot patch "prometheus-operator-kubernetes-apps" with kind PrometheusRule: Timeout: request did not complete within requested timeout 30s && cannot patch "prometheus-operator-kubernetes-resources" with kind PrometheusRule: Timeout: request did not complete within requested timeout 30s && cannot patch "prometheus-operator-kubernetes-storage" with kind PrometheusRule: context deadline exceeded && cannot patch "prometheus-operator-kubernetes-system-apiserver" with kind PrometheusRule: Timeout: request did not complete within requested timeout 30s && cannot patch "prometheus-operator-kubernetes-system-controller-manager" with kind PrometheusRule: Timeout: request did not complete within requested timeout 30s && cannot patch "prometheus-operator-kubernetes-system-kubelet" with kind PrometheusRule: Timeout: request did not complete within requested timeout 30s && cannot patch "prometheus-operator-kubernetes-system-scheduler" with kind PrometheusRule: Timeout: request did not complete within requested timeout 30s && cannot patch "prometheus-operator-kubernetes-system" with kind PrometheusRule: Timeout: request did not complete within requested timeout 30s && cannot patch "prometheus-operator-node-exporter.rules" with kind PrometheusRule: Timeout: request did not complete within requested timeout 30s && cannot patch "prometheus-operator-node-exporter" with kind PrometheusRule: Timeout: request did not complete within requested timeout 30s && cannot patch "prometheus-operator-node-network" with kind PrometheusRule: Timeout: request did not complete within requested timeout 30s && cannot patch "prometheus-operator-node-time" with kind PrometheusRule: Timeout: request did not complete within requested timeout 30s && cannot patch "prometheus-operator-node.rules" with kind PrometheusRule: Timeout: request did not complete within requested timeout 30s && cannot patch "prometheus-operator-prometheus-operator" with kind PrometheusRule: Timeout: request did not complete within requested timeout 30s && cannot patch "prometheus-operator-prometheus" with kind PrometheusRule: Timeout: request did not complete within requested timeout 30s
```

This seems like the same or similar error that the Helm Operator is reporting.

At this point, I still can't tell why.

With some Google searching on the failure terms such as:
* `UPGRADE FAILED: cannot patch "prometheus-operator" with kind Timeout: request did not complete within requested timeout 30s`

I came to this GitHub issue: https://github.com/helm/charts/issues/19928

The issue is eluding to the addmission web hooks are timing out and failing and you can turn it off to by pass this error by running:

```
helm -n monitoring upgrade prometheus-operator \
--set prometheusOperator.admissionWebhooks.enabled=false \
--set prometheusOperator.admissionWebhooks.patch.enabled=false \
--set prometheusOperator.tlsProxy.enabled=false \
 stable/prometheus-operator

manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"

manifest_sorter.go:192: info: skipping unknown hook: "crd-install"


Release "prometheus-operator" has been upgraded. Happy Helming!
NAME: prometheus-operator
LAST DEPLOYED: Sun Apr 12 11:42:12 2020
NAMESPACE: monitoring
STATUS: deployed
REVISION: 3
NOTES:
The Prometheus Operator has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "release=prometheus-operator"

Visit https://github.com/coreos/prometheus-operator for instructions on how
to create & configure Alertmanager and Prometheus instances using the Operator.
```

That seemed to have worked.

Running the simple update works as well now:

```
helm -n monitoring upgrade prometheus-operator stable/prometheus-operator


manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"


Release "prometheus-operator" has been upgraded. Happy Helming!
NAME: prometheus-operator
LAST DEPLOYED: Sun Apr 12 11:44:01 2020
NAMESPACE: monitoring
STATUS: deployed
REVISION: 4
NOTES:
The Prometheus Operator has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "release=prometheus-operator"

Visit https://github.com/coreos/prometheus-operator for instructions on how
to create & configure Alertmanager and Prometheus instances using the Operator.
```

Helm list is looking good:
```
helm -n monitoring list                        NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                           APP VERSION
prometheus-operator     monitoring      4               2020-04-12 11:44:01.910023532 -0700 PDT deployed        prometheus-operator-8.12.2      0.37.0
```

There seems to be a workaround/fix for this error but do we really want to diable these?  What do these items do?

Looking at the prometheus-operator Helm chart this is a GKE specific issue:
* https://github.com/helm/charts/tree/master/stable/prometheus-operator#running-on-private-gke-clusters

**tl;dr** is that when running a private GKE cluster, you need to open a firewall rule to allow the private GKE masters to reach the pod for this validation.

I think the fix is to open up the firewall for the private GKE masters to reach it and the fix is not disabling this since it does the checks and checks seems to be a good thing to have.

The next question is which port to enable?

I created a quick Terraform module to add in the firewall to my GCP network: 
* https://github.com/ManagedKube/kubernetes-ops/releases/tag/v0.1.22

Just as a test, I enabled allow all on all ports from the GKE private Kube masters and this worked.  I think this verifies that it is a port issue and by opening up the correct port, this will work.

From a previous experience we had problems with the prometheus-adapter for HPA in a private GKE cluster and the private GKE Kube master needed to reach it on port `6443`.

To get prometheus-operator back to the update failure state, I am going to delete it and let the Flux `HelmRelease` install it again:

```bash
helm -n monitoring delete prometheus-operator
release "prometheus-operator" uninstalled
```

Now, I still have to figure out what port needs to be opened.  Googling around didnt come up with anything definitive but it led me to these posts:
* https://github.com/helm/charts/issues/16174#issuecomment-529431349
* https://github.com/helm/charts/issues/19928

So I just started to try all of the ports in the `monitoring` namespace's service list:

```
kubectl -n monitoring get svc                      
NAME                                           TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
alertmanager-operated                          ClusterIP   None           <none>        9093/TCP,9094/TCP,9094/UDP   9m11s
prometheus-operated                            ClusterIP   None           <none>        9090/TCP                     9m
prometheus-operator-alertmanager               ClusterIP   10.32.78.243   <none>        9093/TCP                     9m25s
prometheus-operator-grafana                    ClusterIP   10.32.84.184   <none>        80/TCP                       9m25s
prometheus-operator-kube-state-metrics         ClusterIP   10.32.80.67    <none>        8080/TCP                     9m25s
prometheus-operator-operator                   ClusterIP   10.32.94.234   <none>        8080/TCP,443/TCP             9m25s
prometheus-operator-prometheus                 ClusterIP   10.32.77.197   <none>        9090/TCP                     9m25s
prometheus-operator-prometheus-node-exporter   ClusterIP   10.32.67.226   <none>        9100/TCP                     9m25s
```

None of those worked.  One of the Github issues above metioned port `8443`.  When I opened up that port, the prometheus upgrade worked!

However, I didn't know where the port was attached to.  Describing all of the pods and grepping for `8443` gave the answer:

```
kubectl -n monitoring describe pods
Name:         prometheus-operator-operator-c5576c965-tcbqm
Namespace:    monitoring
Priority:     0
Node:         gke-dev-pool-1-135cd9f3-z3mn/10.32.32.31
Start Time:   Sun, 12 Apr 2020 14:51:50 -0700
Labels:       app=prometheus-operator-operator
              chart=prometheus-operator-8.12.12
              heritage=Helm
              pod-template-hash=c5576c965
              release=prometheus-operator
Annotations:  cni.projectcalico.org/podIP: 10.36.0.152/32
Status:       Running
IP:           10.36.0.152
IPs:
  IP:           10.36.0.152
Controlled By:  ReplicaSet/prometheus-operator-operator-c5576c965
Containers:
  prometheus-operator:
    Container ID:  docker://6ca39a64ae4637474d076a1a321c6dac2f2d2df1fcdc64ce809c0da7f80b9b4a
    Image:         quay.io/coreos/prometheus-operator:v0.37.0
    Image ID:      docker-pullable://quay.io/coreos/prometheus-operator@sha256:51c4b3180aa4cb819ae918da49776dba9a17e11d5a5d1eb22d878e1141aa23c9
    Port:          8080/TCP
    Host Port:     0/TCP
    Args:
      --manage-crds=true
      --kubelet-service=kube-system/prometheus-operator-kubelet
      --logtostderr=true
      --localhost=127.0.0.1
      --prometheus-config-reloader=quay.io/coreos/prometheus-config-reloader:v0.37.0
      --config-reloader-image=quay.io/coreos/configmap-reload:v0.0.1
      --config-reloader-cpu=100m
      --config-reloader-memory=25Mi
    State:          Running
      Started:      Sun, 12 Apr 2020 14:51:53 -0700
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from prometheus-operator-operator-token-7vl25 (ro)
  tls-proxy:
    Container ID:  docker://d9526a02c6b8ddb43ae796f33726780b77f6446d5db550858f4c376915d5976f
    Image:         squareup/ghostunnel:v1.5.2
    Image ID:      docker-pullable://squareup/ghostunnel@sha256:70f4cf270425dee074f49626ec63fc96e6712e9c0eedf127e7254e8132d25063
    Port:          8443/TCP
    Host Port:     0/TCP
    Args:
      server
      --listen=:8443
      --target=127.0.0.1:8080
      --key=cert/key
      --cert=cert/cert
      --disable-authentication
```

Ok, it is listening on this port.  What does this tihng do?

A quick search lead to the DockerHub page for it:  https://hub.docker.com/r/squareup/ghostunnel

Looks like this is just a front end with mTLS for some HTTP backend, and the backend is pointed to `--target=127.0.0.1:8080` in the same pod.  From looking at the pod definition in the last output, this is the `prometheus-operator` container.  It looks like the webhook validations are going here.

That seems to make sense and that solve the mystery.  

Now our prometheus-operator Helm setup is able to update correctly with the webhook validations.
