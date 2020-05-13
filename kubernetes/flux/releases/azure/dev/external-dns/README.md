external-dns
=============

# How to setup your DNS zones in Azure

https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/azure.md#creating-an-azure-dns-zone


# Permissions for external-dns to edit the DNS zone

Running through these steps will help you setup the access and the credential file:
https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/azure.md#permissions-to-modify-dns-zone


From the output of the previous commands, you are now able to fill out the credential file information.  Create a temporary file named: `azure.json
` with this content:
```json
{
  "tenantId": "01234abc-de56-ff78-abc1-234567890def",
  "subscriptionId": "01234abc-de56-ff78-abc1-234567890def",
  "resourceGroup": "MyDnsResourceGroup",
  "aadClientId": "01234abc-de56-ff78-abc1-234567890def",
  "aadClientSecret": "uKiuXeiwui4jo9quae9o"
}
```

Replace the IDs with the output from the `external-dns` instructions.  

Be real careful to make sure these are correct.  If they are not, the `external-dns` will not be able to authenticate to make any changes.

NOTE: The information in the `json` content is a secret.  This should never be checked into Git.

TODO: This process is fairly confusing.  I think we can help automate most of the comlexity out of this with a simple script.

## Creating a sealed-secret
Since the `json` information is a secret, we will use `sealed-secret` to help us encrypt this so that we can check it into Git safely.  The `sealed-secret` operator running in our Kubernetes cluster will decrypt the secret and put it in the `external-dns` namespace for it to use.  

Make sure you have deployed `sealed-secrets` to your Kubernetes cluster first.

### Creating an encrypted sealed-secret
Your current working directory should be where this `README.md` file is if you are creating the secret for the `azure/dev` environment.  The last command in this sequence outputs a file named `credentials.yaml` which is the encrypted `sealed-secret` that contains the `azure.json` content.  This `sealed-secret` CRD will be deployed out by Flux and the `sealed-secret` operator will unseal (unencrypt) this and create a Kubernetes secret with the content for `external-dns` to use.

```
# Secret source information
NAMESPACE=external-dns
SECRET_NAME=credentials
FILE_PATH=${PWD}/azure.json

# Get kubeseal pub cert
kubeseal --fetch-cert \
--controller-namespace=sealed-secrets \
--controller-name=sealed-secrets > temp-kubeseal-pub-cert.pem

# kubeseal info
PUB_CERT=./temp-kubeseal-pub-cert.pem
KUBESEAL_SECRET_OUTPUT_FILE=${SECRET_NAME}.yaml

kubectl -n ${NAMESPACE} create secret generic ${SECRET_NAME} \
--from-file=${FILE_PATH} \
--dry-run \
-o json > ${SECRET_NAME}.json

kubeseal --format=yaml --cert=${PUB_CERT} < ${SECRET_NAME}.json > ${KUBESEAL_SECRET_OUTPUT_FILE}
```

### Remove secret files and temp files
Now that we have created our encrypted secret and we are going to check that into our Git repository.  We don't need the plain text unencrypted version and the temp files we created to encrypt the secret.  We can safely delete those files now.

```bash
rm ${PUB_CERT}
rm ${SECRET_NAME}.json
rm azure.json
```