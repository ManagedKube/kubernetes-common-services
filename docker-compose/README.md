Test
=========


* Create a container environment using Docker Compose to serve a static page grabbed from the host’s disk.
* Set up the containers to serve the page.
* Setup a provisioner-managed database server in the container.
* Add a statistics page in the scripted language of your choice. Loading a page will grab information about the database server (existing databases and users).
* All containers have to be in one Docker compose file.
* Put your provisioner files up into the Git Toptal repository.
* Deploy this setup to a cloud provider using an automation tool like Kubernetes/Terraform/another.

# Create a container environment using Docker Compose to serve a static page grabbed from the host’s disk.
* Create a container environment using Docker Compose to serve a static page grabbed from the host’s disk.
* Set up the containers to serve the page.

Create
```
docker-compose up
```

Delete
```
docker-compose down
```

build
```
docker-compose build
```
