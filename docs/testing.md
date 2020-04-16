Testing
============
This document describes the area we test for and why.

Automation reduces cost and errors.  To have confidence in your automation you need tests to tell you everything is working as expected.

# Helm linting
This set of test is to ensure the way that you are using the chart is valid initially and going forward with updates.  As Helm Charts updates it sometimes might deprecate a functionality, change the way something is used, or there might be a bug in it.  This category of tests are here to make sure that the way you are using the chart lints out correctly with the expected results.

# Rollback testing
In a highly automated environment were services can be deployed automatically if it passes some tests or meets a set of requirements it is critical to know that once deployed out, it can be rolled back if needed in a manual and automated fashion.  We can write all the tests in the world and it might not catch all of the corner cases.  In most cases, writing tests is usually a trade off between time verus reward.  We might only spend enough time to reasonably assure us that the tests will catch 80% of the cases because writing the rest of the 20% of the test cases will take a lot of time and it is just not worth it.  You can look at the rollback tests as cover all insurance policy.  This one set of tests can do a catch all (kind of).

There should be a roll back test to ensure that rolling back works.  This is important because if you roll forward and it doesnt work in production, you want to know that it can be rolled back to a previous working state.

Sometimes rollback is not possibly which is ok.  This test will tell you that the rollback does not work for this version.  With this information, you can watch the roll forward more closely if it is something like the nginx-ingress to make sure everything goes alright.  If it is something like the external-dns, it might not be that important to you if it goes down for a little bit and you won't focus your time on watching it roll forward.

This is all very useful information for an automated GitOps workflow so that you can be confident that all of the automation worked as expected behind the scene.

# e2e tests / integration tests
This set of tests are done after a deployment to a live system.  These tests will check if the deployed out items are functioning as expected.

## Use cases:

### nginx-ingress
* I want to make sure traffic is still flowing through the nginx-ingress
* I want to make sure if I add an ingress that the nginx-ingress picks it up and can route traffic through to the pod
* I want to make sure that the nginx config of a 10MB body size is enforced

### prometheus-operator
* I want to make sure the prometheus GUI still works after I updated it.  This is a fast check to make sure that prometheus is running

### External-dns
* I want to make sure that it can set a DNS entry in my DNS server with the correct address (Route53, CloudDNS, etc)

### cert-manager
* I want to make sure it can get a cert via the http01 issuer
* I want to make sure it can get a cert via the dns01 issuer
