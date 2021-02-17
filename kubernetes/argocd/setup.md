Argo Setup
===========


```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v1.8.4/manifests/install.yaml
```



https://argo-cd.readthedocs.io/en/stable/getting_started/

```
% kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
argocd-server-8d76ffdd5-w75l8
% 
% 
% argocd login argocd-server-8d76ffdd5-w75l8
FATA[0000] dial tcp: lookup argocd-server-8d76ffdd5-w75l8 on 10.216.0.14:53: server misbehaving 
% argocd login localhost                    
FATA[0000] dial tcp [::1]:443: connect: connection refused 
% argocd login localhost:8080
WARNING: server certificate had error: x509: certificate signed by unknown authority. Proceed insecurely (y/n)? y
Username: admin
Password: 
'admin' logged in successfully
Context 'localhost:8080' updated
% argocd account update-password
*** Enter current password: 
*** Enter new password: 
*** Confirm new password: 
Password updated
Context 'localhost:8080' updated
% 
```


```
kubectl create ns guestbook
argocd app create guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path guestbook --dest-server https://kubernetes.default.svc --dest-namespace guestbook
```

Port forward to the argocd's API:
```
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Sync app:
```
argocd app sync guestbook
```
