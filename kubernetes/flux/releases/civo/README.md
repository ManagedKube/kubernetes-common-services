Civo Cloud
=============

https://www.civo.com

# What works:
* Flux
* Flux Helm Operator
* Prometheus
* http-echo server
* sealed-secrets

# What does not work:
* Nginx-ingress
* external-dns - doesn't support the Civo's DNS
* cert-manager - doesnt't support the Civo's DNS - HTTP01 validation will probably work

For DNS, you can use another clouds DNS like AWS Route53 or GCP Cloud DNS.
