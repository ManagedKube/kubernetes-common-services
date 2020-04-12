Prometheus Operator upgrade to 8.12.12
======================================

Looking here at the time version `8.12.12` was the latest version:  https://github.com/helm/charts/blob/master/stable/prometheus-operator/Chart.yaml#L15

Here is the commit to update the `prometheus-operator` Helm chart to version 8.12.12: https://github.com/ManagedKube/kubernetes-common-services/commit/bb283b23ea918c96339818bb398863a7eb34f871

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

Looking at the logs of the Flux Helm Operator, it sounds like it can't sync the `status` field for some reason:

```
kubectl -n flux logs helm-operator-77cb687cc7-4dz7q --since 1h | grep prom
...
...
ts=2020-04-12T16:59:10.30924419Z caller=release.go:347 component=release release=prometheus-operator targetNamespace=monitoring resource=monitoring:helmrelease/prometheus-operator helmVersion=v3 warning="unable to sync release with status failed" action=skip
...
...
```

Looking at Helm, it did update:
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

It looks like it is a Helm issue and not a Flux issue.





