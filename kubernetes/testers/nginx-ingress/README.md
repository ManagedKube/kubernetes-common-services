nginx-ingress tests
===================

It seems like we will have some golang programs that will run some tests and some bash scripts that will run some tests.
* golang - check to make sure all pods are in a running state
* goland - check to make sure the logs in the app are generally good
* bash - connectivity test through nginx
* bash - large payload POST test

How will we run these tests?
* Each test will be containerized so it shouldnt matter if it is golang or a bash script
* Will need a pipeline thing
  * Argo Workflow?

## Testing workflows

### Local testing
* Launch Kind cluster
* Install gotk - Tell it to look at the branch we are testing on (or the user can tell it to use another branch for upgrade testing)
* Wait until gotk syncs
* Run the tests

### CI testing
Github actions

* A PR is opened with some changes
* Launch a Kind cluster
* Install gotk - tell it to look at the `master` branch
* wait until gotk syncs and launches everything
* Run the tests
* Change gotk to look at the branch of the PR
* wait until gotk syncs and updates everything
* Run the tests
  * Run the check all pods are up container
  * Run the logs tests
  * Run the connectivity tests
  * Run the large POST test


## standard checks

### Make sure all pods are in a running state

```
kubectl -n ingress get pods                                             
NAME                                                      READY   STATUS    RESTARTS   AGE
nginx-ingress-external-controller-64cb7fdd-9lwnn          1/1     Running   0          23h
nginx-ingress-external-default-backend-6876b6655d-k4mzf   1/1     Running   0          23h
```

#### Todo:
Create a generic golang program that will handle this and other "standard" checks

The program will:
Take input:
* namespace
* the deployment name(s)
* The number of pods that should exist for each deployment

Output:
* exit status 0/1
* Disposition of the test based on the inputs

### No obvious failures in the logs
Not sure how we will do this one

Maybe about the same as above?

## Test connectivity through the nginx-ingress

Launch the `echo-server` pod:
```
kubectl apply -f .
```

Get the nginx-ingress' external ELB:
```
kubectl -n ingress get svc 
NAME                                        TYPE           CLUSTER-IP     EXTERNAL-IP                                                              PORT(S)                      AGE
nginx-ingress-external-controller           LoadBalancer   172.20.15.22   a7bacf91c04e6474c9e284e4f5795a10-157226797.us-east-1.elb.amazonaws.com   80:31415/TCP,443:30723/TCP   22h
nginx-ingress-external-controller-metrics   ClusterIP      172.20.34.25   <none>                                                                   9913/TCP                     22h
nginx-ingress-external-default-backend      ClusterIP      172.20.53.59   <none>                                                                   80/TCP                       22h
```

Call through the ELB:
```
curl -v -H "HOST: http-echo.dev.k8s.managedkube.com" http://a7bacf91c04e6474c9e284e4f5795a10-157226797.us-east-1.elb.amazonaws.com
```

### Todo
Probably can do this with a bash script.

Can probably just run the above and make the getting the `EXTERNAL-IP` dynamic.
* This also might be different if we are running in cluster.  We can just hit the ingress service `CLUSTER-IP`

## Test posting a large file

```
truncate -s 11M large_file.txt
```

Call through the ELB:
```
curl -v -H "HOST: http-echo.dev.k8s.managedkube.com" http://a7bacf91c04e6474c9e284e4f5795a10-157226797.us-east-1.elb.amazonaws.com -F large_file=@large_file.txt
```

